#!/bin/bash


set -e


check_tool_installed() {
    case $1 in
        "python") command -v python3 &> /dev/null ;;
        "vscode") command -v code &> /dev/null ;;
        "docker") command -v docker &> /dev/null ;;
        "jenkins") command -v jenkins &> /dev/null ;;
        "kubernetes") command -v kubectl &> /dev/null ;;
    esac
}


get_tool_version() {
    case $1 in
        "python") python3 --version | cut -d' ' -f2 ;;
        "vscode") code --version | head -n1 ;;
        "docker") docker --version | cut -d' ' -f3 | sed 's/,//' ;;
        "jenkins") jenkins --version 2>/dev/null || echo "Not available" ;;
        "kubernetes") kubectl version --client -o yaml | grep gitVersion | cut -d':' -f2 | tr -d ' ' ;;
    esac
}


install_python() {
    echo "Installing Python..."
    apt-get update
    apt-get install -y python3 python3-pip
}

install_vscode() {
    echo "Installing VS Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    apt-get update
    apt-get install -y code
}

install_docker() {
    echo "Installing Docker..."
    apt-get update
    apt-get install -y docker.io docker-compose
}

install_jenkins() {
    echo "Installing Jenkins..."
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
    sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get install -y jenkins
}

install_kubernetes() {
    echo "Installing Kubernetes..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

#  ye menu h 
main_menu() {
    echo "Select tools to install/update:"
    tools=("python" "vscode" "docker" "jenkins" "kubernetes" "Exit")
    select tool in "${tools[@]}"; do
        case $tool in
            "Exit") 
                echo "Exiting installer."
                exit 0
                ;;
            *)
                if check_tool_installed "$tool"; then
                    current_version=$(get_tool_version "$tool")
                    echo "$tool is already installed (Version: $current_version)"
                    read -p "Do you want to update? (y/n): " update_choice
                    if [[ $update_choice == "y" ]]; then
                        "install_$tool"
                    fi
                else
                    read -p "Install $tool? (y/n): " install_choice
                    if [[ $install_choice == "y" ]]; then
                        "install_$tool"
                    fi
                fi
                main_menu
                break
                ;;
        esac
    done
}

#  see If thee sccripttt is with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo" 
   exit 1
fi

# Startt thee mennu
main_menu
