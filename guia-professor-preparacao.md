# Guia de Preparação do Professor: Build e Distribuição das Imagens do Laboratório

Este guia é para você, antes da aula. O resultado final é um arquivo `lab-images.tar` que os alunos baixam e carregam localmente (Seção 3.4 do roteiro do aluno), sem precisar buildar nada.

---

## 1. Buildar a imagem da página de login simples

Esse é o único alvo que você precisa construir — é uma página PHP de poucas linhas, sem banco de dados, feita especificamente para os exercícios de sniffing (Trilha B), brute force (Trilha C), quebra de hash offline (Trilha D) e enumeração de diretórios (Fase 1).

Crie uma pasta `login-simples/` com quatro arquivos:

**`login-simples/index.php`:**

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

**`login-simples/admin/index.html`** (diretório escondido, para o exercício de enumeração da Fase 1 — não é linkado em lugar nenhum da aplicação, só é descoberto por força bruta com `gobuster`):

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

**`login-simples/admin/backup_users.txt`** (hash de senha vazado, para o exercício de cracking offline da Trilha D — reaproveita a mesma senha `password123` que a Trilha C descobre por força bruta):

```
admin:482c811da5d5b4bc6d497ffa98491e38
```

> Esse é o hash MD5 de `password123` (mesma senha do formulário de login). Se quiser trocar a senha do laboratório, gere um novo hash com `echo -n "sua-nova-senha" | md5sum` e atualize tanto este arquivo quanto o `if ($usuario === "admin" && $senha === "...")` dentro do `index.php`.

**`login-simples/Dockerfile`:**

```dockerfile
FROM php:8.2-apache
COPY index.php /var/www/html/index.php
COPY admin/ /var/www/html/admin/
```

Builde e tagueie com o nome que o `docker-compose.yml` do roteiro do aluno espera:

```bash
cd login-simples
docker build -t lab-kali-docker/login-simples:latest .
cd ..
```

---

## 2. Baixar a imagem do Samba (SambaCry)

O Samba vulnerável (CVE-2017-7494, "SambaCry") já está disponível pronto no Docker Hub — não é necessário buildar nada:

```bash
docker pull vulhub/samba:4.6.3
```

Esse serviço também precisa de um segundo arquivo, `smb.conf`, na mesma pasta do `docker-compose.yml` — veja o conteúdo na Seção 3.5 do roteiro do aluno.

---

## 3. Confirmar que as 2 imagens estão prontas e com as tags certas

```bash
docker images | grep -E "login-simples|vulhub/samba"
```

Você deve ver as 2 linhas. Os nomes precisam bater exatamente com o que está no `docker-compose.yml` do roteiro do aluno — se você usou tags diferentes, ajuste um dos dois lados antes de seguir.

---

## 4. Testar o ambiente do zero, como se você fosse o aluno

Antes de empacotar e distribuir, valide o fluxo completo simulando a experiência do aluno — isso pega qualquer problema antes que 20+ pessoas encontrem o mesmo problema ao mesmo tempo:

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

Rode também o exploit do Metasploit para o SambaCry (Seção 6.1 do roteiro), a captura com `ngrep` (Seção 6.2), o `hydra` (Seção 6.3) e o `john`/`hashcat` (Seção 6.4), ponta a ponta, para confirmar que os quatro exercícios funcionam com as imagens que você vai distribuir. Se for usar o `hashcat` em VM sem GPU dedicada, confirme com antecedência que o runtime OpenCL (`pocl-opencl-icd`) está instalado — sem ele, o comando falha com "No OpenCL... platform found".

---

## 5. Empacotar as 2 imagens em um único arquivo

```bash
docker save \
  lab-kali-docker/login-simples:latest \
  vulhub/samba:4.6.3 \
  -o lab-images.tar

# Verifique o tamanho (validado: ~391MB no total — bem leve, já que
# camadas base compartilhadas entre as imagens não se duplicam no .tar)
du -h lab-images.tar
```

---

## 6. Disponibilizar o arquivo para os alunos

O `.tar` é grande demais para versionar direto no Git (GitHub tem limite de 100MB por arquivo, e mesmo abaixo disso não é uma boa prática). Três opções, da mais para a menos recomendada:

### Opção A — GitHub Release (recomendada)

Anexe o `.tar` como asset de uma *Release* do seu repositório (não como arquivo commitado) — o GitHub permite até 2GB por asset em releases:

```bash
# Via GitHub CLI, se tiver instalado
gh release create v1.0 lab-images.tar --title "Imagens do Laboratório v1.0" \
  --notes "Imagens prontas: página de login simples, Samba 4.6.3 (SambaCry)"
```

Ou pela interface web: `Releases` → `Draft a new release` → arraste o `lab-images.tar` em *assets*.

O link direto do asset é o que você coloca no `README.md` do repositório, para o aluno rodar:

```bash
wget https://github.com/peotta/lab-kali-docker/releases/download/v1.0/lab-images.tar
```

### Opção B — Armazenamento em nuvem institucional

Google Drive, OneDrive institucional, ou storage da própria universidade. Gere um link de download direto (não um link que abre visualização) e cole no `README.md`.

### Opção C — Pendrive / rede local no dia da aula

Sempre mantenha isso como contingência, mesmo usando A ou B — para os alunos que não conseguiram baixar em casa por qualquer motivo.

---

## 7. Atualizar o `README.md` do repositório

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

Inclua também no repositório os arquivos `login-simples/index.php`, `login-simples/Dockerfile`, `docker-compose.yml` e `smb.conf` — são pequenos, versionam bem no Git normalmente (só o `.tar` fica de fora, via `.gitignore`).

---

## 8. Cronograma sugerido (aula em 23/09)

| Data | O que fazer |
|---|---|
| até 09/09 (hoje) | Build + teste ponta a ponta (Seções 1–4 deste guia) |
| até 16/09 | Publicar `lab-images.tar` (Seção 6) e atualizar o `README.md` |
| 16 a 18/09 | Avisar a turma, com o link e o checklist de verificação (Seção 3.7 do roteiro do aluno) |
| 21 a 22/09 | Cobrar confirmação de quem ainda não testou; preparar pendrives de contingência |
| 23/09 — dia da aula | Só trazer os pendrives de backup — nenhum download deve ser necessário |
