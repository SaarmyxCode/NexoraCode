<div align="center">

# NCODE

**Ultra-minimalist, high-performance Code Editor engineered for velocity.**

Powered by **Flutter**, **Rust**, and the **Nexora UI Design System**.

[![Platform - Linux](https://img.shields.io/badge/Platform-Linux%20%28.deb%29-E11F2F?style=for-the-badge&logo=ubuntu&logoColor=white)](https://github.com/saarmyx/ncode/releases)
[![Platform - Windows](https://img.shields.io/badge/Platform-Windows%20%28.exe%29-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/saarmyx/ncode/releases)
[![Architecture - Flutter/Rust](https://img.shields.io/badge/Architecture-Flutter%20%2B%20Rust-black?style=for-the-badge&logo=rust&logoColor=white)](https://github.com/saarmyx/ncode)

---

</div>

## 📌 Overview

**Ncode** is a light-speed, distraction-free code editor designed with an edge-to-edge floating card layout. Built on top of Rust for native system operations and Flutter for desktop rendering, Ncode combines high-throughput file indexing, instantaneous text processing, and integrated developer tools.

---

## ✨ Key Features

- **🏎️ Native Rust Core Engine:** Blazing-fast recursive directory traversal, multi-file searching, and regex replacement using multithreaded Tokio tasks.
- **📂 Dynamic Tree Explorer:** Recursive nested file tree with expand/collapse states, folder root lock, and workspace item creation/renaming/deletion.
- **🔍 Global Search & Multi-File Replace:** Real-time search across your workspace with fine-grained line match navigation and instant replace-all execution.
- **🌿 Built-in Git & GitHub Control:** Branch manager, stage individual changes, commit logs, and push/pull deployment directly to remote repositories.
- **🧩 Floating Cards UI:** Clean, modern editorial interface with rounded floating card containers, customizable active states, and padding separation.
- **🎨 Nexora Theme Engine:** Switch instantly between Base Dark, Base Light, and official Nexora Suite themes (**Nexora Rename**, **Nexora Drive**).
- **💻 Integrated Terminal:** Built-in shell interface (`xterm`) for quick command execution without leaving the editor canvas.

---

## ⚡ Keyboard Shortcuts

| Action                  | Shortcut          |
| :---------------------- | :---------------- |
| **Save Active File**    | `Ctrl + S`        |
| **Format Code**         | `Alt + Shift + F` |
| **Rename Focused Item** | `F2`              |
| **Delete Focused Item** | `Delete`          |

---

## 🚀 Building & Packaging

### Prerequisites

- [Flutter SDK](https://flutter.dev/) (`stable` channel)
- [Rust Toolchain](https://rustup.rs/)
- `flutter_rust_bridge_codegen` (`cargo install flutter_rust_bridge_codegen`)

### 🐧 Linux (`.deb` Package)

To build and package the native Debian installer on Linux:

```bash
# 1. Generate FFI bindings & build release bundle
flutter_rust_bridge_codegen generate
flutter build linux --release

# 2. Package into .deb
rm -rf dist/ncode-installer
mkdir -p dist/ncode-installer/DEBIAN
mkdir -p dist/ncode-installer/usr/bin
mkdir -p dist/ncode-installer/usr/lib/ncode
mkdir -p dist/ncode-installer/usr/share/applications

cp -r build/linux/x64/release/bundle/* dist/ncode-installer/usr/lib/ncode/
ln -s /usr/lib/ncode/ncode dist/ncode-installer/usr/bin/ncode

cat << 'EOF' > dist/ncode-installer/usr/share/applications/ncode.desktop
[Desktop Entry]
Name=Ncode
Comment=Ultra-minimalist Code Editor by Nexora Labs
Exec=/usr/bin/ncode
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=ncode
EOF

cat << 'EOF' > dist/ncode-installer/DEBIAN/control
Package: ncode
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Santiago Sarmiento <saarmyx@nexoralabs.com>
Description: Ultra-minimalist Code Editor by Nexora Labs
EOF

dpkg-deb --build dist/ncode-installer dist/ncode-1.0.0-linux-amd64.deb
```
