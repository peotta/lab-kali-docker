# Laboratório de Testes de Intrusão com Kali Linux em Ambiente Docker

Curso de extensão prático de 4h — Kali Linux contra alvos vulneráveis em Docker, sem relatório final, foco em manuseio de ferramentas.

**Data:** 23/09/2026
**Professor:** Prof. Dr. Laerte Peotta de Melo

---

## ⚠️ Preparação obrigatória (fazer ANTES da aula)

Cada aluno prepara o próprio ambiente, na própria máquina, com antecedência. **Não deixe para o dia da aula.**

1. Instale o Docker (veja `roteiro-lab-kali-docker.md`, Seção 3.2, se ainda não tiver)

2. Clone este repositório:
   ```bash
   git clone https://github.com/peotta/lab-kali-docker.git
   cd lab-kali-docker
   ```

3. Baixe o pacote de imagens pré-construídas:
   ```bash
   wget https://github.com/peotta/lab-kali-docker/releases/download/v1.0/lab-images.tar
   ```

4. Carregue as imagens no Docker local:
   ```bash
   docker load -i lab-images.tar
   docker images
   ```
   Deve mostrar `lab-kali-docker/login-simples` e `vulhub/samba`.

5. Suba o ambiente e confirme:
   ```bash
   docker compose up -d
   docker compose ps
   ```
   Os 2 alvos (`alvo-login`, `alvo-samba`) devem aparecer como `Up`.

6. Confirme o acesso: `http://172.20.0.10` deve abrir a página de login no navegador.

Se qualquer passo falhar, procure o professor com antecedência — resolver isso no dia da aula tira tempo de prática de todo mundo.

---

## Estrutura do repositório

```
lab-kali-docker/
├── README.md
├── roteiro-lab-kali-docker.md
├── guia-professor-preparacao.md
├── docker-compose.yml
├── smb.conf
└── login-simples/
    ├── Dockerfile
    ├── index.php
    └── admin/
        ├── index.html
        └── backup_users.txt
```

## Os 2 alvos

| Alvo | Container | IP | Portas | Usado em |
|---|---|---|---|---|
| Página de login | `alvo-login` | 172.20.0.10 | 80 | Enumeração, sniffing, brute force, hash cracking |
| Samba 4.6.3 (SambaCry) | `alvo-samba` | 172.20.0.13 | 445, 6699 | Exploração via Metasploit (CVE-2017-7494) |

## Escopo

> Todo comando e técnica deste laboratório deve ser usado **exclusivamente** contra os alvos acima, dentro da rede isolada `172.20.0.0/24`. Ver Seção 2 do roteiro completo para o aviso legal.

## Próximos passos

- **Alunos:** siga `roteiro-lab-kali-docker.md` do início ao fim
- **Professor:** siga `guia-professor-preparacao.md` para buildar/empacotar as imagens antes de disponibilizar o link da Release

## Licença / uso

Material didático para fins educacionais, em ambiente isolado. Uso fora desse contexto não é autorizado nem endossado.
