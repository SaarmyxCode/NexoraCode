import_std!();
use std::io::{Read, Write};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};

pub struct TerminalSession {
    child: Arc<Mutex<std::process::Child>>,
}

pub fn execute_command(cmd: String) -> String {
    let output = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .output();

    match output {
        Ok(out) => String::from_utf8_lossy(&out.stdout).to_string(),
        Err(e) => format!("Error al ejecutar comando: {}", e),
    }
}