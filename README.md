# 📸 LOCAlbum - Offline Photo Album

<p align="center">
  <img src="https://i.imgur.com/NIZtRbw.png" alt="LOCAlbum Logo" width="200"/>
</p>


**🇵🇹 LOCAlbum** é uma aplicação leve e totalmente offline que transforma as tuas pastas de fotos num álbum moderno e interativo — com visualização por **anos e meses**, **slideshow automático**, e **temas personalizáveis**.  
Funciona **sem internet**, diretamente a partir do teu disco local ou pen USB.

**🇬🇧 LOCAlbum** is a lightweight and fully offline app that turns your photo folders into a modern and interactive album — with **year/month navigation**, **automatic slideshow**, and **customizable themes**.  
It works **completely offline**, directly from your local drive or USB stick.

---

## 💡 Pensado para pais e memórias de infância / Designed for childhood memories

> 🇵🇹 **LOCAlbum** foi desenvolvido especialmente para pais que desejam guardar as memórias dos filhos desde o nascimento.  
> Durante a configuração inicial, podes inserir a **data de nascimento** — o álbum mostrará automaticamente a **idade exata do bebé/criança** à data de cada foto.  
>  
> (Funcionalidade opcional — se deixares o campo vazio, o álbum funcionará normalmente para qualquer outro tipo de recordação.)

> 🇬🇧 **LOCAlbum** was designed especially for parents who want to preserve their child's memories from birth.  
> During setup, you can enter the **birthdate** — the album will automatically display the **exact age of the baby/child** at the date of each photo.  
>  
> (This feature is optional — if you leave it blank, the album works perfectly for any other kind of memories.)

---

## ✨ Highlights / Destaques

| 🇬🇧 **Highlights** | 🇵🇹 **Destaques** |
|--------------------|-------------------|
| 🗂️ Automatic organization by **year and month** | 🗂️ Organização automática por **ano e mês** |
| 🖼️ Support for **photos and videos** | 🖼️ Suporte para **fotos e vídeos** |
| 🌙 Themes: Dark, Sky and Pink | 🌙 Temas: Escuro, Azul Céu e Rosa |
| ⏱️ **Automatic slideshow** with adjustable speed | ⏱️ **Slideshow automático** com velocidade ajustável |
| 👶 Optional **age display** based on birthdate | 👶 Cálculo de idade opcional (a partir da data de nascimento) |
| 💾 Works **completely offline** — no internet needed | 💾 Funciona **totalmente offline** — nada é enviado para a internet |
| 🔄 One-click update (`[_1_]_update_album.bat`) | 🔄 Atualização rápida com 1 clique (`[_1_]_update_album.bat`) |
| 🌍 **Bilingual interface (PT/EN)** | 🌍 Interface **bilingue (PT/EN)** |

---

## 📂 Estrutura de pastas / Folder structure

> ⚠️ **IMPORTANTE:** As pastas dos meses devem ser criadas em português ou inglês, sem acentos.  
> (Exemplo: `Janeiro` ou `January`)

> ⚠️ **IMPORTANT:** Month folders should be created in Portuguese or English, without accents.  
> (Example: `Janeiro` or `January`)

---

## 🚀 Como usar / How to use

### 🇵🇹 **Passos**

1. 📦 **Descarrega o projeto** e extrai-o **para a raiz de um disco ou pen USB**  
   _(ex.: `C:\Album\` ou `E:\Album\`)_  
   > ⚠️ **Importante:** o projeto deve estar diretamente na raiz, **não dentro de subpastas**.

2. 🖼️ **Coloca as tuas fotos e vídeos** dentro da pasta `Fotos/`, organizadas por pastas **Ano/Mês**  
   _(ex.: `2024/Janeiro/`)_.

3. ▶️ **Executa o ficheiro** `[_1_]_update_album.bat` **pela primeira vez.**  
   - Serás guiado por uma configuração rápida *(idioma, nome do álbum, data opcional de nascimento)*.

4. 💾 O ficheiro `Ver album.html` será criado automaticamente **ao lado da pasta `Album/`.**

5. 🌐 **Abre o ficheiro** `Ver album.html` **num navegador**  
   _(Chrome, Edge, Firefox, etc.)_.

6. 🎨 **Escolhe o teu tema favorito** e guarda as tuas preferências.

---

### 🇬🇧 **Steps**

1. 📦 **Download the project** and extract it **to the root of a drive or USB stick**  
   _(e.g., `C:\Album\` or `E:\Album\`)_.  
   > ⚠️ **Important:** the project must be placed directly in the drive root, **not inside subfolders**.

2. 🖼️ **Place your photos and videos** inside the `Fotos/` folder, organized by folders **Year/Month**  
   _(e.g., `2024/January/`)_.

3. ▶️ **Run** the `[_1_]_update_album.bat` **for the first time.**  
   - You’ll go through a short setup *(language, album name, optional birthdate)*.

4. 💾 The file `View album.html` (or `Ver album.html`) will be automatically created **next to the `Album/` folder.**

5. 🌐 **Open the file** `View album.html` **in your browser**  
   _(Chrome, Edge, Firefox, etc.)_.

6. 🎨 **Choose your preferred theme** and save your settings.

---

💡 *Because your memories deserve a place — even without internet.*

---

## ⚙️ Atualizações / Updating the album

🇵🇹 Sempre que adicionares novas fotos ou pastas de meses ou anos, **executa novamente o `[_1_]_update_album.bat`**.  
O programa atualizará automaticamente o `Ver album.html` sem perder as tuas configurações.  

🇬🇧 Every time you add new photos or folders of months or years, just **run `[_1_]_update_album.bat` again**.  
The app will refresh the `View album.html` automatically, keeping all your settings intact.

---

## 🧹 Repor o Álbum / Reset the Album

🇵🇹  
Se quiseres restaurar o LOCALBUM ao estado original (por exemplo, eliminar configurações antigas ou começar um novo álbum):  

1. Vai à pasta **Album**.  
2. Executa o ficheiro **`[_2_]_reset_album.bat`**.  
3. Escolhe o idioma (Português ou English).  
4. Quando o processo terminar, o script perguntará:  
   > “Queres criar um novo álbum agora?”  
   - Responde **Sim (s)** para recriar imediatamente o álbum.  
   - Ou **Não (n)** se quiseres fazê-lo mais tarde.  

O script apaga apenas os ficheiros de configuração (`config.ini`, `Album.ini`) e o ficheiro HTML gerado (`Ver album.html` / `View album.html`) —  
⚠️ **As tuas fotos e vídeos não são apagados.**

💡 Caso o antivírus apresente algum alerta, **podes ignorar com segurança** —  
os ficheiros `.bat` são totalmente inofensivos e apenas automatizam tarefas locais.

---

🇬🇧  
If you want to restore LOCALBUM to its original state (for example, to remove old settings or start a new album):  

1. Go to the **Album** folder.  
2. Run **`[_2_]_reset_album.bat`**.  
3. Choose your language (Portuguese or English).  
4. When the process ends, the script will ask:  
   > “Do you want to rebuild the album now?”  
   - Answer **Yes (y)** to rebuild immediately.  
   - Or **No (n)** to do it manually later.  

The script deletes only configuration files (`config.ini`, `Album.ini`) and the generated HTML (`View album.html` / `Ver album.html`).  
⚠️ **Your photos and videos are never deleted.**

💡 If your antivirus shows a warning, you can safely ignore it —  
these `.bat` scripts are 100% safe and run only locally.

---

## 🧠 Dicas e Cuidados / Tips & Notes

### 🇵🇹 **Português**

- 📁 A **pasta principal** é aquela onde estão todos os ficheiros do LocAlbum — por exemplo:

```
X:
└── Album (pasta principal)
      ├── Fotos
      ├── [_1_]_update_album.bat
      ├── [_2_]_reset_album.bat
      ├── gerar_album.ps1 (oculto)
      ├── template.html (oculto)
      ├── config.ini (oculto)
      └── (ficheiros gerados automaticamente))
└──Ver album.html (aparece depois de correr o [_1_]_update_album.bat)
```

Podes **renomear esta pasta principal** (ex.: `LOCAlbum`, `Memorias`, `FamiliaMartim`, etc.) —  
o programa continuará a funcionar sem problema.

- 🚫 **Não alteres os seguintes nomes**, pois são obrigatórios para o funcionamento correto:
  - `Fotos/` → onde colocas as tuas fotos (organizadas por pastas de anos e meses)
  - `template.html`
  - `config.ini`
  - `gerar_album.ps1`

- ⚙️ Os ficheiros `[_1_]_update_album.bat` e `[_2_]_reset_album.bat` **podem ser renomeados** se quiseres (ex.: “Atualizar Álbum.bat”, “Repor Álbum.bat”) sem afetar nada.

- ⚙️ O ficheiro `config.ini` é criado automaticamente e deve permanecer oculto.

- 🌐 O álbum funciona **totalmente offline**, mas o navegador deve permitir abrir ficheiros locais (`file://`).

- 💾 Podes copiar o projeto completo (a pasta principal) para uma pen USB ou disco externo —  
funciona em **qualquer PC Windows**.

- 📺 Também pode ser aberto em **Smart TVs** (com navegador compatível) ou em **macOS/Linux**,  
bastando abrir o ficheiro `Ver album.html` (ou `View album.html`).

---

### 🇬🇧 **English**

- 📁 The **main folder** is the one containing all LocAlbum files — for example:

```
X:
└── Album (main folder)
      ├── Fotos
      ├── [_1_]_update_album.bat
      ├── [_2_]_reset_album.bat
      ├── gerar_album.ps1 (hidden)
      ├── template.html (hidden)
      ├── config.ini (hidden)
      └── (automatically generated files)
└──View album.html (appears after run [_1_]_update_album.bat)
```

You can **rename this main folder** (e.g., `LocAlbum`, `Memories`, `FamilyAlbum`, etc.) —  
the program will continue to work normally.

- 🚫 **Do not rename or move** the following items — they are required:
  - `Fotos/` → where you place your photos (organized by folders of years and months)
  - `template.html`
  - `config.ini`
  - `gerar_album.ps1`

- ⚙️ The files `[_1_]_update_album.bat` and `[_2_]_reset_album.bat` **can be renamed** safely if you prefer friendlier names.

- ⚙️ The `config.ini` file is generated automatically and should remain hidden.

- 🌐 Works **completely offline**, but your browser must allow local file access (`file://`).

- 💾 You can copy the whole project (the main folder) to a USB stick or external drive —  
it works on **any Windows PC**.

- 📺 Also compatible with **Smart TVs** (with supported browsers) and **macOS/Linux**,  
simply open the `View album.html` (or `Ver album.html`) file.

---

## 💝 Apoia o projeto / Support the project

Se este projeto te foi útil, considera apoiar o desenvolvimento.  
If this project was useful to you, consider supporting its development.

<p align="center">
  <a href="https://www.buymeacoffee.com/rubsil" target="_blank">
    <img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-FFDD00?logo=buymeacoffee&logoColor=black&style=for-the-badge" />
  </a>
  <a href="https://www.paypal.me/rubsil" target="_blank">
    <img src="https://img.shields.io/badge/Donate%20via%20PayPal-0070ba?logo=paypal&logoColor=white&style=for-the-badge" />
  </a>
</p>

---

## 🧑‍💻 Autor / Author

**Desenvolvido por Rúben Silva**  
📧 [GitHub Profile](https://github.com/rubsil)  
📸 Projeto: *LOCAlbum - Offline Photo Album*  

💡 *Because your memories deserve a place — even without internet.*

---

## 📜 Licença / License

Distribuído sob a **licença MIT** — uso livre, com crédito ao autor.  
Distributed under the **MIT License** — free to use, with author attribution.
