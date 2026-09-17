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

Se o link acima não funcionar (o script ainda não foi anexado à Release), peça o arquivo [`setup.sh`](https://github.com/peotta/lab-kali-docker/blob/main/setup.sh) diretamente ao professor e salve na sua pasta pessoal.

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
NAME         IMAGE                                  SERVICE         STATUS         PORTS
alvo-login   lab-kali-docker/login-simples:latest   login-simples   Up             0.0.0.0:80->80/tcp
alvo-samba   vulhub/samba:4.6.3                     samba           Up             0.0.0.0:445->445/tcp, 0.0.0.0:6699->6699/tcp
```

Se aparecer isso, terminou - o ambiente está pronto.

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
| `wget` do `.tar` falha | Rede lenta ou instável | Tente de novo - o arquivo é grande (~390MB) |

Se nada disso resolver, chame o professor.

---

## Verificação final

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://172.20.0.10
nmap -sV -p 445 172.20.0.13
```

**Resultado esperado do `curl`:**

```
200
```

**Resultado esperado do `nmap`:**

```
PORT    STATE SERVICE     VERSION
445/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
Service Info: Host: <nome-do-container>
```

Se os dois baterem, o ambiente está validado e pronto para os alunos usarem.

Para uma verificação ainda mais completa (opcional, confirma que os exercícios de verdade funcionam, não só que os containers estão de pé):

```bash
curl http://172.20.0.10/admin/backup_users.txt
```

**Resultado esperado:**

```
admin:482c811da5d5b4bc6d497ffa98491e38
```

```bash
smbclient -L 172.20.0.13 -N
```

**Resultado esperado:**

```
        Sharename       Type      Comment
        ---------       ----      -------
        myshare         Disk
        IPC$            IPC       IPC Service (Samba Server Version 4.6.3)
Reconnecting with SMB1 for workgroup listing.

        Server               Comment
        ---------            -------

        Workgroup            Master
        ---------            -------
```

---

Material produzido pelo professor Laerte Peotta de Melo, com auxílio da IA Claude (Anthropic).
