# Guia Rápido para Monitores: Preparar o Laboratório

Este guia é para quem vai **ajudar a preparar o ambiente** do laboratório (não é o roteiro da aula, é só a instalação). Leva uns 10-15 minutos, a maior parte esperando download.

**Diretório onde tudo vai ficar:** `~/Desktop/lab-kali-docker`

---

## Passo a passo

**1. Abra um terminal no Kali.**

**2. Baixe o script de instalação:**

```bash
wget https://github.com/peotta/lab-kali-docker/releases/download/v1.0/setup.sh
```

Se o link acima não funcionar (o script ainda não foi anexado à Release), peça o arquivo `setup.sh` diretamente ao professor e salve na sua pasta pessoal.

**3. Dê permissão de execução e rode:**

```bash
chmod +x setup.sh
./setup.sh
```

**4. Acompanhe a saída no terminal.** O script faz tudo sozinho:
- Instala o Docker (se ainda não estiver instalado)
- Cria a pasta `~/Desktop/lab-kali-docker`
- Clona o repositório do laboratório
- Baixa o pacote de imagens (`lab-images.tar`, ~390MB)
- Carrega as imagens no Docker
- Sobe os 2 containers (`alvo-login`, `alvo-samba`)

**5. No final, o script mostra o resultado do `docker compose ps`.** Confirme que os dois alvos aparecem como `Up`:

```
alvo-login   Up   0.0.0.0:80->80/tcp
alvo-samba   Up   0.0.0.0:445->445/tcp
```

Se aparecer isso, terminou — o ambiente está pronto.

---

## Se o Docker acabou de ser instalado agora (primeira vez nessa máquina)

O script já tenta contornar isso automaticamente, mas se algum comando `docker` falhar com `permission denied` mesmo assim, feche o terminal, abra um novo, e rode de novo:

```bash
cd ~/Desktop/lab-kali-docker
docker compose up -d
docker compose ps
```

---

## Problemas comuns

| Sintoma | Causa | Solução |
|---|---|---|
| Erro `kali-rolling Release file` durante instalação do Docker | Kali não é reconhecido pelo repositório oficial do Docker | O script já corrige isso automaticamente |
| `permission denied` ao rodar `docker` | Grupo `docker` só aplica em sessão nova | Feche e abra o terminal de novo, ou rode `newgrp docker` |
| `Pool overlaps with other one` ao subir os containers | Já existe outra rede Docker usando `172.20.0.0/24` (ex.: outra cópia do laboratório rodando) | `docker compose down -v` na outra pasta antes de subir esta |
| `wget` do `.tar` falha | Rede lenta ou instável | Tente de novo — o arquivo é grande (~390MB) |

Se nada disso resolver, chame o professor.

---

## Verificação final

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://172.20.0.10
nmap -sV -p 445 172.20.0.13
```

O primeiro comando deve retornar `200`, o segundo deve mostrar `Samba smbd`. Se os dois baterem, o ambiente está validado e pronto para os alunos usarem.
