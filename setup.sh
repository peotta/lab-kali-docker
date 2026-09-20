#!/bin/bash
# ============================================================
# Script de preparação do Laboratório Kali Linux + Docker
# Instala Docker (se necessário), clona o repositório, baixa
# as imagens e sobe o ambiente completo.
# ============================================================

set -e  # para o script se algum comando falhar

REPO_URL="https://github.com/peotta/lab-kali-docker.git"
RELEASE_TAR_URL="https://github.com/peotta/lab-kali-docker/releases/download/v1.0/lab-images.tar"
LAB_DIR="$HOME/Desktop/lab-kali-docker"

echo "=================================================="
echo " Laboratório Kali Linux + Docker — Instalação"
echo " Diretório de destino: $LAB_DIR"
echo "=================================================="
echo ""

# ------------------------------------------------------------
# 1. Verificar/instalar o Docker
# ------------------------------------------------------------
if command -v docker >/dev/null 2>&1 && docker --version >/dev/null 2>&1; then
    echo "[OK] Docker já está instalado: $(docker --version)"
else
    echo "[..] Docker não encontrado. Instalando..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh

    if sudo sh /tmp/get-docker.sh 2>&1 | tee /tmp/docker-install.log | grep -q "kali-rolling Release"; then
        DOCKER_INSTALL_FAILED=1
    fi

    if [ "$DOCKER_INSTALL_FAILED" = "1" ] || ! command -v docker >/dev/null 2>&1; then
        echo "[..] Corrigindo repositório (problema conhecido do Kali com o codinome 'kali-rolling')..."
        sudo rm -f /etc/apt/sources.list.d/docker.list
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    echo "[OK] Docker instalado: $(docker --version)"
fi

# Remove o podman-docker se tiver sido instalado por engano (conflita com o Docker real)
if dpkg -l | grep -q podman-docker; then
    echo "[..] Removendo podman-docker (conflita com o Docker real)..."
    sudo apt remove -y podman-docker
    sudo apt autoremove -y
fi

# ------------------------------------------------------------
# 2. Garantir permissão do usuário no grupo docker
# ------------------------------------------------------------
if ! groups "$USER" | grep -q docker; then
    echo "[..] Adicionando $USER ao grupo docker..."
    sudo usermod -aG docker "$USER"
    NEEDS_NEW_GROUP=1
fi

# Função para rodar docker com o grupo já aplicado nesta mesma sessão,
# mesmo que o terminal ainda não tenha sido reaberto
run_docker() {
    if [ "$NEEDS_NEW_GROUP" = "1" ]; then
        sg docker -c "$1"
    else
        eval "$1"
    fi
}

# ------------------------------------------------------------
# 3. Verificar/instalar o Git
# ------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo "[..] Git não encontrado. Instalando..."
    sudo apt-get update -qq
    sudo apt-get install -y git
    echo "[OK] Git instalado: $(git --version)"
else
    echo "[OK] Git já está instalado: $(git --version)"
fi

# ------------------------------------------------------------
# 5. Criar diretório e clonar o repositório
# ------------------------------------------------------------
mkdir -p "$(dirname "$LAB_DIR")"

if [ -d "$LAB_DIR/.git" ]; then
    echo "[OK] Repositório já existe em $LAB_DIR — atualizando..."
    cd "$LAB_DIR"
    git pull
else
    echo "[..] Clonando repositório em $LAB_DIR ..."
    git clone "$REPO_URL" "$LAB_DIR"
    cd "$LAB_DIR"
fi

# ------------------------------------------------------------
# 6. Baixar o pacote de imagens (.tar)
# ------------------------------------------------------------
cd "$LAB_DIR"
if [ -f "lab-images.tar" ]; then
    echo "[OK] lab-images.tar já existe, pulando download."
else
    echo "[..] Baixando lab-images.tar (~390MB, pode demorar)..."
    wget -q --show-progress "$RELEASE_TAR_URL" -O lab-images.tar
fi

# ------------------------------------------------------------
# 7. Carregar as imagens no Docker
# ------------------------------------------------------------
echo "[..] Carregando imagens no Docker..."
run_docker "docker load -i '$LAB_DIR/lab-images.tar'"

# ------------------------------------------------------------
# 8. Subir o ambiente
# ------------------------------------------------------------
echo "[..] Subindo o ambiente (docker compose up -d)..."
cd "$LAB_DIR"
run_docker "cd '$LAB_DIR' && docker compose up -d"

echo ""
echo "=================================================="
echo " Status final dos containers:"
echo "=================================================="
run_docker "cd '$LAB_DIR' && docker compose ps"

echo ""
if [ "$NEEDS_NEW_GROUP" = "1" ]; then
    echo "[ATENÇÃO] Seu usuário acabou de ser adicionado ao grupo 'docker'."
    echo "Fechar e abrir um terminal novo (ou reiniciar a sessão) antes de"
    echo "rodar comandos 'docker' manualmente, sem passar por este script."
fi
echo ""
echo "Pronto! Se os 2 alvos apareceram como 'Up' acima, o ambiente está OK."
echo "Diretório do laboratório: $LAB_DIR"
