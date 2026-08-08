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

// Obtener la lista de archivos modificados
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

// Ejecutar Git Commit
pub async fn git_commit(repo_path: String, message: String) -> bool {
    tokio::task::spawn_blocking(move || {
        // 1. Git Add .
        let add_status = Command::new("git")
            .arg("-C")
            .arg(&repo_path)
            .arg("add")
            .arg(".")
            .status();

        if add_status.map(|s| s.success()).unwrap_or(false) {
            // 2. Git Commit
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