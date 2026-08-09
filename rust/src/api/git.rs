use std::process::Command;

#[derive(Debug, Clone)]
pub struct GitFileChange {
    pub path: String,
    pub status: String, // "M" (Modified), "A" (Added), "D" (Deleted), "??" (Untracked)
}

// Obtener la rama activa actual
pub async fn get_git_branch(repo_path: String) -> String {
    tokio::task::spawn_blocking(move || {
        let output = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("rev-parse")
            .arg("--abbrev-ref")
            .arg("HEAD")
            .output();

        match output {
            Ok(out) if out.status.success() => {
                String::from_utf8_lossy(&out.stdout).trim().to_string()
            }
            _ => "sin repo".to_string(),
        }
    })
    .await
    .unwrap_or_else(|_| "sin repo".to_string())
}

// Obtener todas las ramas locales
pub async fn get_git_branches(repo_path: String) -> Vec<String> {
    tokio::task::spawn_blocking(move || {
        let mut branches = Vec::new();
        let output = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("branch")
            .arg("--format=%(refname:short)")
            .output();

        if let Ok(out) = output {
            if out.status.success() {
                let stdout = String::from_utf8_lossy(&out.stdout);
                for line in stdout.lines() {
                    if !line.trim().is_empty() {
                        branches.push(line.trim().to_string());
                    }
                }
            }
        }
        branches
    })
    .await
    .unwrap_or_default()
}

// Cambiar de rama (Checkout)
pub async fn checkout_git_branch(repo_path: String, branch_name: String) -> bool {
    tokio::task::spawn_blocking(move || {
        let status = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("checkout")
            .arg(&branch_name)
            .status();

        status.map(|s| s.success()).unwrap_or(false)
    })
    .await
    .unwrap_or(false)
}

// Crear y cambiar a una nueva rama
pub async fn create_git_branch(repo_path: String, new_branch_name: String) -> bool {
    tokio::task::spawn_blocking(move || {
        let status = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("checkout")
            .arg("-b")
            .arg(&new_branch_name)
            .status();

        status.map(|s| s.success()).unwrap_or(false)
    })
    .await
    .unwrap_or(false)
}

// Obtener lista de archivos modificados/sin rastrear
pub async fn get_git_status(repo_path: String) -> Vec<GitFileChange> {
    tokio::task::spawn_blocking(move || {
        let mut changes = Vec::new();
        let output = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("status")
            .arg("--porcelain")
            .output();

        if let Ok(out) = output {
            if out.status.success() {
                let stdout = String::from_utf8_lossy(&out.stdout);
                for line in stdout.lines() {
                    if line.len() > 3 {
                        let status = line[..2].trim().to_string();
                        let path = line[3..].trim().to_string();
                        changes.push(GitFileChange { path, status });
                    }
                }
            }
        }
        changes
    })
    .await
    .unwrap_or_default()
}

// Stage de un archivo individual
pub async fn git_stage_file(repo_path: String, file_path: String) -> bool {
    tokio::task::spawn_blocking(move || {
        let status = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("add")
            .arg(&file_path)
            .status();

        status.map(|s| s.success()).unwrap_or(false)
    })
    .await
    .unwrap_or(false)
}

// Ejecutar Commit
pub async fn git_commit(repo_path: String, message: String) -> bool {
    tokio::task::spawn_blocking(move || {
        let add_status = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("add")
            .arg(".")
            .status();

        if add_status.map(|s| s.success()).unwrap_or(false) {
            let commit_status = Command::new("git")
                .arg("-C")
                .arg(&repo_path)
                .arg("commit")
                .arg("-m")
                .arg(message)
                .status();

            return commit_status.map(|s| s.success()).unwrap_or(false);
        }
        false
    })
    .await
    .unwrap_or(false)
}

// Sincronizar / Push a GitHub
pub async fn git_push(repo_path: String) -> String {
    tokio::task::spawn_blocking(move || {
        let output = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("push")
            .output();

        match output {
            Ok(out) => {
                let stderr = String::from_utf8_lossy(&out.stderr).to_string();
                let stdout = String::from_utf8_lossy(&out.stdout).to_string();
                if out.status.success() {
                    "OK".to_string()
                } else if !stderr.is_empty() {
                    stderr
                } else {
                    stdout
                }
            }
            Err(e) => format!("Error de ejecución: {}", e),
        }
    })
    .await
    .unwrap_or_else(|_| "Error de hilo".to_string())
}

// Pull desde GitHub
pub async fn git_pull(repo_path: String) -> String {
    tokio::task::spawn_blocking(move || {
        let output = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("pull")
            .output();

        match output {
            Ok(out) => {
                let stdout = String::from_utf8_lossy(&out.stdout).to_string();
                if out.status.success() {
                    "OK".to_string()
                } else {
                    String::from_utf8_lossy(&out.stderr).to_string()
                }
            }
            Err(e) => format!("Error: {}", e),
        }
    })
    .await
    .unwrap_or_else(|_| "Error de hilo".to_string())
}