use std::fs;
use std::path::Path;
use walkdir::WalkDir;

#[derive(Debug, Clone)]
pub struct SearchResult {
    pub file_path: String,
    pub line_number: usize,
    pub line_text: String,
}

// Búsqueda global recursiva por letra/palabra
pub async fn search_in_workspace(root_path: String, query: String) -> Vec<SearchResult> {
    tokio::task::spawn_blocking(move || {
        let mut results = Vec::new();
        if query.trim().is_empty() {
            return results;
        }

        let query_lower = query.to_lowercase();

        for entry in WalkDir::new(&root_path)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.file_type().is_file())
        {
            let path = entry.path();
            
            // Ignorar carpetas pesadas/binarias
            let path_str = path.to_string_lossy();
            if path_str.contains("/.git/") 
                || path_str.contains("/build/") 
                || path_str.contains("/target/") 
                || path_str.contains("/.dart_tool/") {
                continue;
            }

            if let Ok(content) = fs::read_to_string(path) {
                for (index, line) in content.lines().enumerate() {
                    if line.to_lowercase().contains(&query_lower) {
                        results.push(SearchResult {
                            file_path: path_str.to_string(),
                            line_number: index + 1,
                            line_text: line.trim().to_string(),
                        });
                        if results.len() >= 500 {
                            return results; // Límite de seguridad
                        }
                    }
                }
            }
        }
        results
    })
    .await
    .unwrap_or_default()
}

// Reemplazo global en todos los archivos del proyecto
pub async fn replace_in_workspace(root_path: String, query: String, replacement: String) -> usize {
    tokio::task::spawn_blocking(move || {
        if query.trim().is_empty() {
            return 0;
        }

        let mut replaced_files_count = 0;

        for entry in WalkDir::new(&root_path)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.file_type().is_file())
        {
            let path = entry.path();
            let path_str = path.to_string_lossy();

            if path_str.contains("/.git/") 
                || path_str.contains("/build/") 
                || path_str.contains("/target/") 
                || path_str.contains("/.dart_tool/") {
                continue;
            }

            if let Ok(content) = fs::read_to_string(path) {
                if content.contains(&query) {
                    let new_content = content.replace(&query, &replacement);
                    if fs::write(path, new_content).is_ok() {
                        replaced_files_count += 1;
                    }
                }
            }
        }
        replaced_files_count
    })
    .await
    .unwrap_or(0)
}