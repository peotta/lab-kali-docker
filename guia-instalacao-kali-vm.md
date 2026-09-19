# Guia de Instalação: Kali Linux em Máquina Virtual

Este guia cobre a instalação do Kali Linux em máquina virtual (VM) usando a **imagem pré-construída oficial** - a forma mais rápida e confiável para ter um Kali funcional sem precisar passar por uma instalação completa do zero.

Dois softwares de virtualização são cobertos: **VirtualBox** (seção 1) e **VMware Workstation Pro** (seção 2). Siga a seção do software que você vai usar - não precisa fazer os dois.

> ℹ️ **Por que usar a imagem pré-construída?** O site do Kali distribui VMs já configuradas, com ferramentas instaladas e credenciais padrão definidas. Você baixa, importa e já tem um sistema funcional em minutos - sem particionar disco, sem configurar bootloader, sem escolher pacotes.

---

## Sumário

1. [VirtualBox (gratuito, multiplataforma)](#1-virtualbox-gratuito-multiplataforma)
   - [1.1 Instalar o VirtualBox](#11-instalar-o-virtualbox)
   - [1.2 Baixar a imagem do Kali para VirtualBox](#12-baixar-a-imagem-do-kali-para-virtualbox)
   - [1.3 Importar a VM](#13-importar-a-vm)
   - [1.4 Configurações recomendadas](#14-configurações-recomendadas)
   - [1.5 Primeiro acesso](#15-primeiro-acesso)
2. [VMware Workstation Pro (gratuito desde 2024)](#2-vmware-workstation-pro-gratuito-desde-2024)
   - [2.1 Instalar o VMware Workstation Pro](#21-instalar-o-vmware-workstation-pro)
   - [2.2 Baixar a imagem do Kali para VMware](#22-baixar-a-imagem-do-kali-para-vmware)
   - [2.3 Abrir a VM](#23-abrir-a-vm)
   - [2.4 Configurações recomendadas](#24-configurações-recomendadas)
   - [2.5 Primeiro acesso](#25-primeiro-acesso)
3. [Pós-instalação: ajustes comuns](#3-pós-instalação-ajustes-comuns)
4. [Requisitos mínimos de hardware](#4-requisitos-mínimos-de-hardware)
5. [Próximos passos](#5-próximos-passos)

---

## 1. VirtualBox (gratuito, multiplataforma)

### 1.1 Instalar o VirtualBox

O VirtualBox é gratuito e roda em Windows, macOS e Linux.

1. Acesse a página oficial de downloads: **<https://www.virtualbox.org/wiki/Downloads>**
2. Baixe o instalador para o seu sistema operacional (Windows, macOS ou Linux).
3. Execute o instalador e siga os passos padrão (Next → Next → Install). Aceite a instalação do driver de rede quando solicitado.
4. *(Opcional, mas recomendado)* Na mesma página, baixe e instale também o **VirtualBox Extension Pack** - ele adiciona suporte a USB 2.0/3.0 e outras integrações úteis.

> ⚠️ **Windows:** durante a instalação, o Windows pode avisar que a rede vai cair por alguns segundos - isso é normal, confirme e aguarde.

### 1.2 Baixar a imagem do Kali para VirtualBox

1. Acesse a página oficial de downloads do Kali: **<https://www.kali.org/get-kali/#kali-virtual-machines>**
2. Na seção **Virtual Machines**, clique em **VirtualBox**.
3. Baixe o arquivo `.7z` correspondente à arquitetura do seu sistema (geralmente `amd64`).
4. *(Recomendado)* Verifique a integridade do arquivo comparando o SHA256 exibido na página com o hash calculado localmente:

   **Windows (PowerShell):**
   ```powershell
   Get-FileHash .\kali-linux-*-virtualbox-amd64.7z -Algorithm SHA256
   ```

   **Linux/macOS:**
   ```bash
   sha256sum kali-linux-*-virtualbox-amd64.7z
   ```

   O hash deve bater com o valor exibido no site do Kali ao lado do arquivo baixado.

5. Extraia o `.7z`. Você precisará do **7-Zip** (Windows/Linux) ou do **The Unarchiver** (macOS):
   - Windows: <https://www.7-zip.org/>
   - macOS: <https://theunarchiver.com/>
   - Linux: `sudo apt install p7zip-full && 7z x kali-linux-*-virtualbox-amd64.7z`

   Após a extração, você terá uma pasta contendo um arquivo `.vbox` e um `.vdi` (ou similar).

### 1.3 Importar a VM

1. Abra o **VirtualBox**.
2. **Opção mais rápida:** localize o arquivo `.vbox` na pasta extraída e dê um duplo clique nele. O VirtualBox registra e abre a VM automaticamente.

   **Opção alternativa (via menu):** se o duplo clique não funcionar:
   - Clique em **Arquivo → Importar Appliance** (ou **File → Import Appliance**).
   - Navegue até o arquivo `.ova` ou `.vbox`.
   - Clique em **Próximo** → revise as configurações → **Importar**.

3. Aguarde. A importação pode levar alguns minutos dependendo do seu disco.

### 1.4 Configurações recomendadas

Antes de ligar a VM pela primeira vez, ajuste os recursos conforme sua máquina:

1. Selecione a VM na lista e clique em **Configurações** (ícone de engrenagem ou `Ctrl+S`).

2. **Sistema → Placa-mãe:**
   - **Memória base:** mínimo **4096 MB (4 GB)**; ideal **8 GB** se disponível.

3. **Sistema → Processador:**
   - **Processadores:** mínimo **2**; ideal **4** se tiver 8+ núcleos físicos.
   - Marque **Habilitar PAE/NX** se disponível.

4. **Vídeo:**
   - **Memória de vídeo:** 128 MB.
   - **Controladora Gráfica:** VMSVGA.

5. **Rede:**
   - **Adaptador 1:** deixe como **NAT** para acesso à internet dentro da VM.
   - Para o laboratório Docker, o adaptador NAT é suficiente - o Docker cria a rede isolada (`172.20.0.0/24`) internamente.

6. Clique em **OK** para salvar.

### 1.5 Primeiro acesso

1. Selecione a VM e clique em **Iniciar**.
2. Na tela de login, use as credenciais padrão da imagem oficial:
   - **Usuário:** `kali`
   - **Senha:** `kali`

3. Após logar, abra um terminal e atualize o sistema:

   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```

4. *(Recomendado)* Instale os **VirtualBox Guest Additions** para melhorar a integração (arrastar e soltar, área de transferência compartilhada, resolução de tela automática):

   ```bash
   sudo apt install -y virtualbox-guest-x11
   sudo reboot
   ```

5. Troque a senha padrão imediatamente:

   ```bash
   passwd
   ```

> ✅ **Checklist VirtualBox:** VM ligando ✓ → login com `kali`/`kali` ✓ → terminal abrindo ✓ → `sudo apt update` funcionando ✓

---

## 2. VMware Workstation Pro (gratuito desde 2024)

Desde o final de 2024, a Broadcom (que adquiriu a VMware) tornou o **VMware Workstation Pro gratuito para todos os usos** - pessoal, educacional e comercial. A edição "Player" foi descontinuada; o Workstation Pro é agora a versão padrão e gratuita.

### 2.1 Instalar o VMware Workstation Pro

1. Acesse o portal de downloads da Broadcom:
   **<https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro&freeDownloads=true>**

2. Será necessário criar uma **conta gratuita** na Broadcom para prosseguir com o download. Cadastre-se e faça login.

3. Selecione a versão mais recente do **VMware Workstation Pro** para o seu sistema operacional (Windows ou Linux).

4. Execute o instalador:
   - **Windows:** clique duas vezes no `.exe` e siga o assistente (Next → aceite o EULA → Next → Install).
   - **Linux:** torne o instalador executável e rode como root:
     ```bash
     chmod +x VMware-Workstation-Full-*.bundle
     sudo ./VMware-Workstation-Full-*.bundle
     ```

5. Quando solicitado se deseja inserir uma chave de licença, clique em **Continuar sem licença** (ou equivalente) - o software é gratuito e funciona sem chave.

### 2.2 Baixar a imagem do Kali para VMware

1. Acesse a página oficial de downloads do Kali: **<https://www.kali.org/get-kali/#kali-virtual-machines>**
2. Na seção **Virtual Machines**, clique em **VMware**.
3. Baixe o arquivo `.7z` correspondente à arquitetura `amd64`.
4. *(Recomendado)* Verifique o SHA256 do arquivo:

   **Windows (PowerShell):**
   ```powershell
   Get-FileHash .\kali-linux-*-vmware-amd64.7z -Algorithm SHA256
   ```

   **Linux/macOS:**
   ```bash
   sha256sum kali-linux-*-vmware-amd64.7z
   ```

5. Extraia o `.7z`. Após a extração, você terá uma pasta com um arquivo `.vmx` e arquivos `.vmdk`.

### 2.3 Abrir a VM

1. Abra o **VMware Workstation Pro**.
2. Clique em **Open a Virtual Machine** (ou **Arquivo → Abrir**).
3. Navegue até a pasta extraída e selecione o arquivo **`.vmx`**.
4. A VM aparece na lista lateral. Clique em **Power On** para iniciá-la.

   > ℹ️ O VMware pode perguntar se a VM foi **movida** ou **copiada** - selecione **Copiei** (*I copied it*). Isso regenera os identificadores únicos da VM sem problemas.

### 2.4 Configurações recomendadas

Com a VM desligada, clique com o botão direito na VM → **Settings** (ou `Ctrl+D`):

1. **Memory:** mínimo **4096 MB (4 GB)**; ideal **8 GB**.

2. **Processors:**
   - **Number of processors:** 1
   - **Number of cores per processor:** mínimo 2, ideal 4.
   - Marque **Virtualize Intel VT-x/EPT or AMD-V/RVI** se disponível.

3. **Display:** marque **Accelerate 3D graphics** (se tiver GPU dedicada).

4. **Network Adapter:** deixe como **NAT** para acesso à internet dentro da VM.

5. Clique em **OK** para salvar.

### 2.5 Primeiro acesso

1. Clique em **Power On** para iniciar a VM.
2. Na tela de login, use:
   - **Usuário:** `kali`
   - **Senha:** `kali`

3. Após logar, abra um terminal e atualize o sistema:

   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```

4. As imagens oficiais do Kali para VMware já incluem o **VMware Tools** pré-instalado. Se por algum motivo não estiver ativo, instale manualmente:

   ```bash
   sudo apt install -y open-vm-tools-desktop
   sudo reboot
   ```

   Isso ativa resolução de tela automática, área de transferência compartilhada e arrastar/soltar.

5. Troque a senha padrão imediatamente:

   ```bash
   passwd
   ```

> ✅ **Checklist VMware:** VM ligando ✓ → login com `kali`/`kali` ✓ → terminal abrindo ✓ → `sudo apt update` funcionando ✓

---

## 3. Pós-instalação: ajustes comuns

Independentemente do software de virtualização usado, estes ajustes são recomendados antes de usar o Kali para o laboratório:

### 3.1 Tirar um snapshot ("foto" do estado atual)

Antes de qualquer coisa, tire um **snapshot** da VM recém-configurada e atualizada. Se algo der errado durante o laboratório, você pode restaurar o estado original em segundos - sem reinstalar nada.

**VirtualBox:**
```
Menu → Máquina → Tirar snapshot    (ou Ctrl+Shift+S)
Nome sugerido: "Kali limpo - pós-instalação"
```

**VMware:**
```
Menu → VM → Snapshot → Take Snapshot
Nome sugerido: "Kali limpo - pós-instalação"
```

### 3.2 Instalar o Git (se não estiver instalado)

```bash
sudo apt install -y git
git --version
```

### 3.3 Teclado em português

Se o teclado estiver com layout errado (caracteres especiais não batem):

```bash
sudo dpkg-reconfigure keyboard-configuration
```

Siga o assistente e selecione o layout **Portuguese (Brazil)** ou equivalente. Depois reinicie o serviço:

```bash
sudo service keyboard-setup restart
```

Ou reinicie a VM.

### 3.4 Verificar o Docker (se já instalado)

Se você instalou o Docker e tirou um snapshot depois disso, confirme que está funcional:

```bash
docker --version
docker compose version
```

Se o Docker ainda não estiver instalado, siga a Seção 3.2 do [`roteiro-lab-kali-docker.md`](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md).

---

## 4. Requisitos mínimos de hardware

| Componente | Mínimo | Recomendado |
|---|---|---|
| CPU | 64 bits, 4 núcleos, VT-x/AMD-V habilitado na BIOS | 8+ núcleos |
| RAM total no host | 8 GB | 16 GB |
| RAM alocada para a VM | 4 GB | 8 GB |
| Espaço em disco | 40 GB livres | 80 GB (SSD) |
| Sistema operacional host | Windows 10/11, macOS 12+, ou Linux | - |

> ⚠️ **Virtualização na BIOS/UEFI:** se ao iniciar a VM aparecer um erro como `VT-x is not available` (VirtualBox) ou `VMX is not supported` (VMware), é necessário habilitar a virtualização nas configurações da BIOS/UEFI. Procure pelas opções "Virtualization Technology", "Intel VT-x" ou "AMD-V/SVM" nas configurações avançadas - o caminho exato varia por fabricante (geralmente acessado pressionando F2, Del ou F10 durante o boot).

---

## 5. Próximos passos

Com a VM do Kali funcionando:

1. **Instale o Docker** dentro da VM: siga a Seção 3.2 do [`roteiro-lab-kali-docker.md`](https://github.com/peotta/lab-kali-docker/blob/main/roteiro-lab-kali-docker.md).
2. **Prepare o ambiente do laboratório:** siga a Atividade 0 do mesmo roteiro do início ao fim.
3. **No dia da aula:** com o ambiente preparado, vá direto para a Atividade 1.

---

Material produzido pelo professor Laerte Peotta de Melo, com auxílio da IA Claude (Anthropic).

