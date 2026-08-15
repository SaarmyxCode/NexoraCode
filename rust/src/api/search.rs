use regex::RegexBuilder;
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;
use walkdir::WalkDir;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SearchResultMatch {
    pub file_path: String,
    pub file_name: String,
    pub line_number: usize,
    pub line_content: String,
    pub start_col: usize,
    pub end_col: usize,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SearchOptions {
    pub query: String,
    pub root_dir: String,
    pub is_regex: bool,
    pub match_case: bool,
    pub match_whole_word: bool,
    pub file_include_filter: Option<String>, // Ej: "*.dart, *.rs"
    pub file_exclude_filter: Option<String>, // Ej: "target, build, .git"
}

pub fn search_in_workspace(options: SearchOptions) -> Result<Vec<SearchResultMatch>, String> {
    let root = Path::new(&options.root_dir);
    if !root.exists() || !root.is_dir() {
        return Err("Directorio de trabajo no válido".to_string());
    }

    // 1. Construir el patrón Regex
    let pattern_str = if options.is_regex {
        options.query.clone()
    } else {
        let escaped = regex::escape(&options.query);
        if options.match_whole_word {
            format!(r"\b{}\b", escaped)
        } else {
            escaped
        }
    };

    let regex_builder = RegexBuilder::new(&pattern_str)
        .case_insensitive(!options.match_case)
        .build()
        .map_err(|e| format!("Error en expresión regular: {}", e))?;

    // 2. Filtros de inclusión / exclusión
    let includes: Vec<String> = options
        .file_include_filter
        .unwrap_or_default()
        .split(',')
        .map(|s| s.trim().to_lowercase().replace("*.", ""))
        .filter(|s| !s.is_empty())
        .collect();

    let excludes: Vec<String> = options
        .file_exclude_filter
        .unwrap_or_default()
        .split(',')
        .map(|s| s.trim().to_lowercase())
        .filter(|s| !s.is_empty())
        .collect();

    let mut results = Vec::new();

    // 3. Recorrido rápido con WalkDir
    for entry in WalkDir::new(root)
        .into_iter()
        .filter_entry(|e| {
            let file_name = e.file_name().to_string_lossy().to_lowercase();
            // Ignorar directorios pesados por defecto
            if file_name == ".git" || file_name == "target" || file_name == "build" || file_name == ".dart_tool" {
                return false;
            }
            !excludes.iter().any(|ex| file_name.contains(ex))
        })
        .filter_map(|e| e.ok())
    {
        let path = entry.path();
        if path.is_file() {
            // Validar filtro de extensiones/inclusiones
            if !includes.is_empty() {
                if let Some(ext) = path.extension() {
                    let ext_str = ext.to_string_lossy().to_lowercase();
                    if !includes.contains(&ext_str) {
                        continue;
                    }
                } else {
                    continue;
                }
            }

            // Lectura por buffer de líneas
            if let Ok(file) = File::open(path) {
                let reader = BufReader::new(file);
                for (idx, line_res) in reader.lines().enumerate() {
                    if let Ok(line) = line_res {
                        for mat in regex_builder.find_iter(&line) {
                            results.push(SearchResultMatch {
                                file_path: path.to_string_lossy().to_string(),
                                file_name: entry.file_name().to_string_lossy().to_string(),
                                line_number: idx + 1,
                                line_content: line.clone(),
                                start_col: mat.start(),
                                end_col: mat.end(),
                            });
                        }
                    }
                }
            }
        }
    }

    Ok(results)
}