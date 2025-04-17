# PowerNixx

PowerNixx is a cross-platform PowerShell-based monitoring and management tool designed to streamline the administration of Linux systems. By leveraging the flexibility of PowerShell, PowerNixx provides a unified interface for system monitoring, service management, and resource utilization tracking. It is built to address the needs of system administrators and DevOps professionals seeking efficient, scalable, and secure solutions for managing Linux environments.

## Purpose

PowerNixx was created to solve common challenges in Linux system administration by providing:

- **Cross-platform compatibility**: A single tool to manage Linux systems using PowerShell.
- **Comprehensive monitoring**: Real-time insights into system performance and resource utilization.
- **Customizable dashboards**: Interactive web interfaces for streamlined management.
- **Robust testing and security**: Ensuring reliability and adherence to best practices.
- **AI Integrations**: Cross platform AI tool wrappers such as the Ollama and LlamaCpp sub modules

This project demonstrates how modern scripting and web technologies can be combined to create a powerful, extensible, and user-friendly solution for managing complex systems.

## Features

- **System Monitoring**:
  - Real-time CPU, memory, disk, and network usage statistics.
  - Visualization of resource usage through interactive web charts.
  - Detailed process and service management.

- **AI Integration**:
  - PowerShell wrappers for managing AI tools like Ollama and llama.cpp.
  - Functions for starting, stopping, and managing AI models.

- **Service Management**:
  - Start, stop, and restart Linux services using PowerShell functions.
  - Securely connect to remote Linux systems via SSH.

- **Web Interface**:
  - Interactive dashboards built with Pode.Web for monitoring and management.
  - Customizable pages for processes, dependencies, and system information.

- **Extensibility**:
  - Modular design with public and private functions for easy customization.
  - Support for additional plugins and integrations.

- **Testing and CI**:
  - Comprehensive unit tests written with Pester.
  - Automated build and test pipelines using `Invoke-Build`.

## Technical Highlights

- **PowerShell Modules**:
  - Modularized codebase with reusable functions.
  - Functions for CPU, memory, disk, and network monitoring.

- **Pode Framework**:
  - Lightweight web server for hosting dashboards and APIs.
  - WebSocket support for real-time updates.

- **Security**:
  - Secure handling of credentials and sensitive data.
  - Adherence to CIS benchmarks and best practices.

- **Cross-Platform Compatibility**:
  - Designed to work seamlessly on Linux systems.
  - Avoids platform-specific dependencies where possible.

## Getting Started

### Prerequisites

- PowerShell 7.0 or later
- Linux-based system
- Pode module (`Install-Module Pode -Scope CurrentUser`)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/PowerNixx.git
   cd PowerNixx