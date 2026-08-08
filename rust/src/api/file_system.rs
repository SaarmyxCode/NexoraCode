use walkdir::WalkDir;
use std::path::Path;

#[derive(Debug, Clone)]
pub struct FileEntry {
    pub name: String,
    pub path: String,
    pub is_dir: bool,
}

// Lectura de directorio asíncrona (no congela la interfaz)
pub async fn read_directory(dir_path: String) -> Vec<FileEntry> {
    tokio::task::spawn_blocking(move || {
        let mut entries = Vec::new();
        let path = Path::new(&dir_path);

        if let Ok(read_dir) = std::fs::read_dir(path) {
            for entry in read_dir.flatten() {
                let metadata = entry.metadata();
                let is_dir = metadata.map(|m| m.is_dir()).unwrap_or(false);

                entries.push(FileEntry {
                    name: entry.file_name().to_string_lossy().into_owned(),
                    path: entry.path().to_string_lossy().into_owned(),
                    is_dir,
                });
            }
        }

        // Ordenar: Directorios primero, luego archivos
        entries.sort_by(|a, b| {
            if a.is_dir == b.is_dir {
                a.name.to_lowercase().cmp(&b.name.to_lowercase())
            } else {
                b.is_dir.cmp(&a.is_dir)
            }
        });

        entries
    }).await.unwrap_or_default()
}

// Lectura de archivo asíncrona
pub async fn read_file_content(file_path: String) -> String {
    tokio::fs::read_to_string(file_path)
        .await
        .unwrap_or_else(|_| "Error al leer el archivo".to_string())
}

// Escritura de archivo asíncrona
pub async fn write_file_content(file_path: String, content: String) -> bool {
    tokio::fs::write(file_path, content).await.is_ok()
}