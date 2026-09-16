# Laboratório de Testes de Intrusão com Kali Linux em Ambiente Docker

Curso de extensão prático de 4h: Kali Linux contra alvos vulneráveis em Docker, sem relatório final, foco em manuseio de ferramentas.

**Data:** 23/09/2026
**Professor:** Prof. Dr. Laerte Peotta de Melo

---

## ⚠️ Preparação obrigatória (fazer ANTES da aula)

Cada aluno prepara o próprio ambiente, na própria máquina, com antecedência. **Não deixe para o dia da aula.**

1. Instale o Docker (veja [`roteiro-lab-kali-docker.md`](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md), Seção 3.2, se ainda não tiver)

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

Se qualquer passo falhar, procure o professor com antecedência: resolver isso no dia da aula tira tempo de prática de todo mundo.

---

## Estrutura do repositório

```
lab-kali-docker/
├── README.md
├── roteiro-lab-kali-docker.md
├── guia-professor-preparacao.md
├── guia-monitores-preparacao.md
├── setup.sh
├── docker-compose.yml
├── smb.conf
└── login-simples/
    ├── Dockerfile
    ├── index.php
    └── admin/
        ├── index.html
        └── backup_users.txt
```

## Documentos deste curso

| Arquivo | O que é | Para quem |
|---|---|---|
| [`README.md`](https://github.com/peotta/lab-kali-docker/blob/main/README.md) | Este arquivo: visão geral do repositório, preparação rápida e índice de tudo o mais | Todo mundo, primeiro contato com o repositório |
| [`roteiro-lab-kali-docker.md`](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md) | Roteiro completo da aula: metodologia de pentest, preparação do ambiente e as 7 atividades práticas (reconhecimento, SambaCry, sniffing, força bruta, hash cracking, pós-exploração), com comandos e resultados esperados | **Alunos**, é o documento que se segue durante a aula, do início ao fim |
| [`guia-professor-preparacao.md`](https://github.com/peotta/lab-kali-docker/blob/main/guia-professor-preparacao.md) | Como buildar as imagens Docker do zero, empacotar no `.tar`, publicar como Release do GitHub e testar tudo antes de disponibilizar aos alunos | **Professor**, preparação de bastidor, feita uma vez antes da turma usar |
| [`guia-monitores-preparacao.md`](https://github.com/peotta/lab-kali-docker/blob/main/guia-monitores-preparacao.md) | Versão curta e direta: só o essencial para instalar e subir o ambiente numa máquina nova, com solução de problemas comuns | **Monitores/equipe técnica**, quem vai preparar as máquinas físicas do laboratório |
| [`setup.sh`](https://github.com/peotta/lab-kali-docker/blob/main/setup.sh) | Script que automatiza tudo: instala o Docker (corrigindo os problemas conhecidos do Kali), clona o repositório, baixa as imagens e sobe o ambiente com um único comando | Monitores/equipe técnica, referenciado pelo guia acima |

## Os 2 alvos

| Alvo | Container | IP | Portas | Usado em |
|---|---|---|---|---|
| Página de login | `alvo-login` | 172.20.0.10 | 80 | Enumeração, sniffing, brute force, hash cracking |
| Samba 4.6.3 (SambaCry) | `alvo-samba` | 172.20.0.13 | 445, 6699 | Exploração via Metasploit (CVE-2017-7494) |

## Escopo

> Todo comando e técnica deste laboratório deve ser usado **exclusivamente** contra os alvos acima, dentro da rede isolada `172.20.0.0/24`. Ver Seção 2 do [roteiro completo](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md) para o aviso legal.

## Próximos passos

- **Alunos:** siga o [`roteiro-lab-kali-docker.md`](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md) do início ao fim
- **Professor:** siga o [`guia-professor-preparacao.md`](https://github.com/peotta/lab-kali-docker/blob/main/guia-professor-preparacao.md) para buildar/empacotar as imagens antes de disponibilizar o link da Release
- **Monitores/equipe técnica:** siga o [`guia-monitores-preparacao.md`](https://github.com/peotta/lab-kali-docker/blob/main/guia-monitores-preparacao.md) (ou rode o [`setup.sh`](https://github.com/peotta/lab-kali-docker/blob/main/setup.sh) direto) para preparar as máquinas do laboratório

## Licença / uso

Material didático para fins educacionais, em ambiente isolado. Uso fora desse contexto não é autorizado nem endossado.
