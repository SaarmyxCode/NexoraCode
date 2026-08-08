use std::process::Command;

pub async fn execute_command(cmd: String) -> String {
    tokio::task::spawn_blocking(move || {
        let output = Command::new("sh")
            .arg("-c")
            .arg(cmd)
            .output();

        match output {
            Ok(out) => {
                let stdout = String::from_utf8_lossy(&out.stdout).to_string();
                let stderr = String::from_utf8_lossy(&out.stderr).to_string();
                if !stdout.is_empty() {
                    stdout
                } else if !stderr.is_empty() {
                    stderr
                } else {
                    "Comando ejecutado sin salida.".to_string()
                }
            }
            Err(e) => format!("Error al ejecutar comando: {}", e),
        }
    }).await.unwrap_or_else(|_| "Error de ejecución en hilo".to_string())
}