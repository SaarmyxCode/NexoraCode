use std::path::Path;

#[derive(Debug, Clone)]
pub struct FileEntry {
    pub name: String,
    pub path: String,
    pub is_dir: bool,
}

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

pub async fn read_file_content(file_path: String) -> String {
    tokio::fs::read_to_string(file_path)
        .await
        .unwrap_or_else(|_| "Error al leer el archivo".to_string())
}

pub async fn write_file_content(file_path: String, content: String) -> bool {
    tokio::fs::write(file_path, content).await.is_ok()
}

pub async fn create_new_file(file_path: String) -> bool {
    tokio::fs::File::create(file_path).await.is_ok()
}

pub async fn rename_entry(old_path: String, new_path: String) -> bool {
    tokio::fs::rename(old_path, new_path).await.is_ok()
}

pub async fn remove_entry(path: String) -> bool {
    let p = std::path::Path::new(&path);
    if p.is_dir() {
        tokio::fs::remove_dir_all(path).await.is_ok()
    } else {
        tokio::fs::remove_file(path).await.is_ok()
    }
}