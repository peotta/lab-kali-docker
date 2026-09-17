# Guia de Preparação do Professor: Build e Distribuição das Imagens do Laboratório

O resultado final é um arquivo `lab-images.tar` que os alunos baixam e carregam localmente (Seção 3.5 do [roteiro do aluno](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md)), sem precisar buildar nada.

---

## 0. Instalando o Docker e o GitHub CLI no Kali

Se você ainda não tem Docker instalado na máquina que vai usar para buildar/testar as imagens, siga os passos abaixo - é o mesmo processo documentado na Seção 3.2 do [roteiro do aluno](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md) (você vai precisar dele de qualquer forma para validar o ambiente antes de distribuir).

### 0.1 Docker

O Kali **não** vem com Docker pré-instalado por padrão, e os pacotes do repositório oficial dele têm nomes/disponibilidade inconsistentes - o caminho mais confiável é o instalador oficial da própria Docker.

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Se aparecer o erro `the repository 'https://download.docker.com/linux/debian kali-rolling Release' does not have a Release file`:** o script detecta o Kali como Debian, mas usa o codinome `kali-rolling`, que os repositórios do Docker não reconhecem. Corrija apontando para um codinome Debian válido:

```bash
sudo rm /etc/apt/sources.list.d/docker.list
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Não instale `podman-docker`** mesmo que o terminal sugira esse pacote - ele substitui o comando `docker` por uma camada de compatibilidade do Podman, o que causa comportamento inconsistente com o [`docker-compose.yml`](https://github.com/peotta/lab-kali-docker/blob/main/docker-compose.yml) deste laboratório (especialmente a rede com IP fixo). Se instalou por engano:

```bash
sudo apt remove -y podman-docker
sudo apt autoremove -y
```

Aplique a permissão de grupo e confirme:

```bash
sudo usermod -aG docker $USER
newgrp docker

docker --version
docker compose version
docker run hello-world
```

Se aparecer a mensagem "Hello from Docker!", está tudo certo.

### 0.2 GitHub CLI (`gh`) - necessário para publicar a Release (Seção 6)

Também não está nos repositórios padrão do Kali. Instale pelo repositório oficial:

```bash
(type -p wget >/dev/null || sudo apt install wget -y) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
```

Depois, autentique (escolha `GitHub.com` → `HTTPS` → `Paste an authentication token`, usando um Personal Access Token com escopo `repo` gerado em [github.com/settings/tokens](https://github.com/settings/tokens)):

```bash
gh auth login
```

---

## 1. Buildar a imagem da página de login simples

Esse é o único alvo que você precisa construir - é uma página PHP de poucas linhas, sem banco de dados, feita especificamente para os exercícios de sniffing (Atividade 4), brute force (Atividade 5), quebra de hash offline (Atividade 6) e enumeração de diretórios (Atividade 1).

Crie uma pasta `login-simples/` com quatro arquivos:

**[`login-simples/index.php`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/index.php):**

```php
<?php
$erro = "";
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $usuario = $_POST["usuario"] ?? "";
    $senha = $_POST["senha"] ?? "";
    if ($usuario === "admin" && $senha === "password123") {
        echo "<h2>Login efetuado com sucesso!</h2><p>Bem-vindo, admin.</p>";
        exit;
    } else {
        $erro = "Usuário ou senha incorretos.";
    }
}
?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Portal do Laboratório</title>
</head>
<body>
    <h1>Portal do Laboratório</h1>
    <?php if ($erro): ?>
        <p style="color:red;"><?php echo htmlspecialchars($erro); ?></p>
    <?php endif; ?>
    <form method="POST" action="">
        <label>Usuário: <input type="text" name="usuario"></label><br><br>
        <label>Senha: <input type="password" name="senha"></label><br><br>
        <input type="submit" value="Entrar">
    </form>
</body>
</html>
```

**[`login-simples/admin/index.html`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/admin/index.html)** (diretório escondido, para o exercício de enumeração da Fase 1 - não é linkado em lugar nenhum da aplicação, só é descoberto por força bruta com `gobuster`):

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Painel Administrativo</title>
</head>
<body>
    <h1>Painel Administrativo</h1>
    <p>Este recurso não está linkado em nenhum lugar da aplicação.</p>
    <p>Se você chegou até aqui, foi por enumeração de diretórios — exatamente
       o tipo de recurso "esquecido" que times de segurança encontram em
       ambientes reais: paineis de administração, backups, arquivos de
       configuração, expostos sem querer, sem estarem em nenhum menu visível.</p>
</body>
</html>
```

**[`login-simples/admin/backup_users.txt`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/admin/backup_users.txt)** (hash de senha vazado, para o exercício de cracking offline da Trilha D - reaproveita a mesma senha `password123` que a Trilha C descobre por força bruta):

```
admin:482c811da5d5b4bc6d497ffa98491e38
```

> Esse é o hash MD5 de `password123` (mesma senha do formulário de login). Se quiser trocar a senha do laboratório, gere um novo hash com `echo -n "sua-nova-senha" | md5sum` e atualize tanto este arquivo quanto o `if ($usuario === "admin" && $senha === "...")` dentro do [`index.php`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/index.php).

**[`login-simples/Dockerfile`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/Dockerfile):**

```dockerfile
FROM php:8.2-apache
COPY index.php /var/www/html/index.php
COPY admin/ /var/www/html/admin/
```

Builde e tagueie com o nome que o [`docker-compose.yml`](https://github.com/peotta/lab-kali-docker/blob/main/docker-compose.yml) do [roteiro do aluno](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md) espera:

```bash
cd login-simples
docker build -t lab-kali-docker/login-simples:latest .
cd ..
```

---

## 2. Baixar a imagem do Samba (SambaCry)

O Samba vulnerável (CVE-2017-7494, "SambaCry") já está disponível pronto no Docker Hub - não é necessário buildar nada:

```bash
docker pull vulhub/samba:4.6.3
```

Esse serviço também precisa de um segundo arquivo, [`smb.conf`](https://github.com/peotta/lab-kali-docker/blob/main/smb.conf), na mesma pasta do [`docker-compose.yml`](https://github.com/peotta/lab-kali-docker/blob/main/docker-compose.yml) - veja o conteúdo na Seção 3.6 do [roteiro do aluno](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md).

---

## 3. Confirmar que as 2 imagens estão prontas e com as tags certas

```bash
docker images | grep -E "login-simples|vulhub/samba"
```

Você deve ver as 2 linhas. Os nomes precisam bater exatamente com o que está no [`docker-compose.yml`](https://github.com/peotta/lab-kali-docker/blob/main/docker-compose.yml) do [roteiro do aluno](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md) - se você usou tags diferentes, ajuste um dos dois lados antes de seguir.

---

## 4. Testar o ambiente do zero, como se você fosse o aluno

Antes de empacotar e distribuir, valide o fluxo completo simulando a experiência do aluno - isso pega qualquer problema antes que 20+ pessoas encontrem o mesmo problema ao mesmo tempo:

```bash
docker compose down -v      # se já tiver algo rodando
docker compose up -d
docker compose ps           # os 2 alvos devem estar "Up"

# Testes básicos por alvo
curl -s -o /dev/null -w "%{http_code}\n" http://172.20.0.10                    # página de login
curl -s -o /dev/null -w "%{http_code}\n" http://172.20.0.10/admin/             # diretório escondido
curl -s http://172.20.0.10/admin/backup_users.txt                              # hash vazado
nmap -sV -p 445 172.20.0.13                                                      # deve mostrar Samba smbd
```

Rode também o exploit do Metasploit para o SambaCry (Atividade 3 do roteiro), a captura com `ngrep` (Atividade 4), o `hydra` (Atividade 5) e o `john`/`hashcat` (Atividade 6), ponta a ponta, para confirmar que os quatro exercícios funcionam com as imagens que você vai distribuir. Se for usar o `hashcat` em VM sem GPU dedicada, confirme com antecedência que o runtime OpenCL (`pocl-opencl-icd`) está instalado - sem ele, o comando falha com "No OpenCL... platform found".

---

## 5. Empacotar as 2 imagens em um único arquivo

```bash
docker save \
  lab-kali-docker/login-simples:latest \
  vulhub/samba:4.6.3 \
  -o lab-images.tar

# Verifique o tamanho (validado: ~391MB no total - bem leve, já que
# camadas base compartilhadas entre as imagens não se duplicam no .tar)
du -h lab-images.tar
```

---

## 6. Disponibilizar o arquivo para os alunos

O `.tar` é grande demais para versionar direto no Git (GitHub tem limite de 100MB por arquivo, e mesmo abaixo disso não é uma boa prática). Três opções, da mais para a menos recomendada:

### Opção A - GitHub Release (recomendada)

Anexe o `.tar` como asset de uma *Release* do seu repositório (não como arquivo commitado) - o GitHub permite até 2GB por asset em releases:

```bash
# Via GitHub CLI, se tiver instalado
gh release create v1.0 lab-images.tar --title "Imagens do Laboratório v1.0" \
  --notes "Imagens prontas: página de login simples, Samba 4.6.3 (SambaCry)"
```

Ou pela interface web: `Releases` → `Draft a new release` → arraste o `lab-images.tar` em *assets*.

O link direto do asset é o que você coloca no [`README.md`](https://github.com/peotta/lab-kali-docker/blob/main/README.md) do repositório, para o aluno rodar:

```bash
wget https://github.com/peotta/lab-kali-docker/releases/download/v1.0/lab-images.tar
```

### Opção B - Armazenamento em nuvem institucional

Google Drive, OneDrive institucional, ou storage da própria universidade. Gere um link de download direto (não um link que abre visualização) e cole no [`README.md`](https://github.com/peotta/lab-kali-docker/blob/main/README.md).

### Opção C - Pendrive / rede local no dia da aula

Sempre mantenha isso como contingência, mesmo usando A ou B - para os alunos que não conseguiram baixar em casa por qualquer motivo.

---

## 7. Atualizar o [`README.md`](https://github.com/peotta/lab-kali-docker/blob/main/README.md) do repositório

Inclua no topo do repositório, de forma bem visível:

```markdown
## Preparação obrigatória (fazer ANTES da aula)

1. Baixe o pacote de imagens:
   wget https://github.com/peotta/lab-kali-docker/releases/download/v1.0/lab-images.tar

2. Carregue no Docker:
   docker load -i lab-images.tar

3. Suba o ambiente:
   docker compose up -d
   docker compose ps

Consulte o roteiro completo em `roteiro-lab-kali-docker.md`, Seção 3.
```

Inclua também no repositório os arquivos [`login-simples/index.php`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/index.php), [`login-simples/Dockerfile`](https://github.com/peotta/lab-kali-docker/blob/main/login-simples/Dockerfile), [`docker-compose.yml`](https://github.com/peotta/lab-kali-docker/blob/main/docker-compose.yml) e [`smb.conf`](https://github.com/peotta/lab-kali-docker/blob/main/smb.conf) - são pequenos, versionam bem no Git normalmente (só o `.tar` fica de fora, via `.gitignore`).

---

Material produzido pelo professor Laerte Peotta de Melo, com auxílio da IA Claude (Anthropic).
