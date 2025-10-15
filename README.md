# Salmon Roe - Mobile App

## Introduction 
The following project aims to develop a mobile application for the external community, namely the oriental restaurant ***Salmon Roe***, as a required component for the evaluation of the discipline ***Projeto Integrado de Extensão 1***, taught by Prof. Marcelo T. Santana, M.Sc.

## Key Features
- Orders placed directly by customers;
- In-app payment;
- Connection with the [dashboard]();

> A link to the *dashboard application* will be added soon.

## Objectives
- Develop a functional mobile application
- Integrate a non-relational database (MongoDB) and a Node.js backend
- Implement a user-friendly interface using Flutter and Dart
- Establish full connectivity with the restaurant’s dashboard

## System Definitions
- Mobile Application (Frontend)
- Backend Server (API)
- Database
- Dashboard (Administrative Panel)
- Project Management and Deployment Tools

## Required Technologies
Below is the step-by-step guide for installing the technologies required to run the app.
As technologies for the development of the mobile app, it was decided that we will use the following technologies — listed in the table beside, along with brief descriptions and documentation.

|Technology|Description|Documentation|
|-|-|-|
|![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)|Main programming language|[Click here to read documentation](https://dart.dev/docs)|
|![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)|Programming kit for UI|[Click here to read documentation](https://docs.flutter.dev/?_gl=1*7aexul*_gcl_aw*R0NMLjE3NjAzOTIzMDMuQ2p3S0NBand4ckxIQmhBMkVpd0F1OUVkTTlReXNFWl9YckdMaERHeWp5UXZPM2g0V294UWJORTFqdU0zMm9JQzk1QmpkUEZqWkVzZV9Sb0NhQ2tRQXZEX0J3RQ..*_gcl_dc*R0NMLjE3NjAzOTIzMDMuQ2p3S0NBand4ckxIQmhBMkVpd0F1OUVkTTlReXNFWl9YckdMaERHeWp5UXZPM2g0V294UWJORTFqdU0zMm9JQzk1QmpkUEZqWkVzZV9Sb0NhQ2tRQXZEX0J3RQ..*_up*MQ..*_gs*MQ..*_ga*MTk5MzI5ODU2My4xNzYwMzkyMjgz*_ga_04YGWK0175*czE3NjAzOTIyODMkbzEkZzEkdDE3NjAzOTIzMDIkajQxJGwwJGgw&gclid=CjwKCAjwxrLHBhA2EiwAu9EdM9QysEZ_XrGLhDGyjyQvO3h4WoxQbNE1juM32oIC95BjdPFjZEse_RoCaCkQAvD_BwE&gclsrc=aw.ds)|
|![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)|Back-End Programming Language|[Click here to read documentation](https://nodejs.org/docs/latest/api/)|
|![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)|Non-relational Database|[Click here to read documentation](https://www.mongodb.com/pt-br/docs/)|
|![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)|IDE for Flutter, Dart and Node.Js|[Click here to read documentation](https://www.mongodb.com/pt-br/docs/)|
|![Android Studio](https://img.shields.io/badge/android%20studio-346ac1?style=for-the-badge&logo=android%20studio&logoColor=white)|IDE for Android Emulator|[Click here to read documentation](https://www.mongodb.com/pt-br/docs/)|
|![Azure](https://img.shields.io/badge/azuredevops-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)|Project management tool|[Click here to read documentation](https://learn.microsoft.com/en-us/azure/devops/?view=azure-devops)|

> All badges used are sourced from the repository: https://github.com/Ileriayo/markdown-badges#. Copyright © 2025 [Ileriayo](https://github.com/Ileriayo). All rights reserved.

### ***Installing Flutter***
**Step 1 - Flutter SDK (with Dart)**
___
1. Go to the official Flutter page: [Flutter - Get Started](https://docs.flutter.dev/get-started)  
2. Click **Windows** and download the SDK zip file.  
3. Choose a directory on your computer (e.g., `C:\flutter`) and extract the contents of the zip file.
> 💡 Since the Flutter SDK already contains Dart, there is no need to install it separately.

**Step 2 - Add Flutter to the PATH**
___
1. Open **Control Panel** → **System and Security** → **System** → **Advanced system settings**.  
2. Click **Environment Variables**.  
3. Under **System variables**, select **Path** → **Edit** → **New**.  
4. Add the path to the Flutter `bin` folder.
5. Click **OK** to save. 

**Step 3 - Verify Flutter Installation**
___
1. Open **Command Prompt** or **PowerShell**.  
2. Run:  ```flutter doctor```.
3. Flutter will check your environment and list any missing dependencies.

### ***Installing Android Studio***

**Step 1 - Install Android Studio**
___
1. Download **Android Studio**: https://developer.android.com/studio
2. Run the installer and follow the default steps.
3. Make sure to select **Android SDK**, **Android SDK Platform**, and **Android Virtual Device (AVD)** during installation.
4. Open **Android Studio** and configure the **SDK and an Android emulator.**
> 💡If you need, use this [tutorial](https://www.youtube.com/watch?v=8gc5z3aKc6k). Copyright © 2024 [ProgrammingKnowledge](https://www.youtube.com/@ProgrammingKnowledge). All rights reserved.

**Step 2 - Configure Flutter for Android**
___

1. Open **Command Prompt** or **PowerShell**.  
2. Run the command again to check your environment: **```flutter doctor```**
3. Make sure Flutter detects Android Studio and the Android SDK.
> ⚠️ If there are license issues, run: **```flutter doctor --android-licenses```**, then and accept all licenses.

**Step 3 - Install a Code Editor (Recommended: Visual Studio Code)**
___
1. Download VS Code: https://code.visualstudio.com/
2. Install the [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) and [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) extensions in VS Code.
> 💡The links are attached to the name of the language; just click on it.

### ***Installing Node.JS***
___
1. Go to the official Node.js website: [https://nodejs.org/](https://nodejs.org/)  
2. Download the **LTS (Long-Term Support)** version for Windows.  
3. Run the installer and follow the prompts:  
   - Accept the license agreement.  
   - Select the destination folder (default is fine).  
   - Ensure **"Add to PATH"** is checked.  
   - Install the optional tools if prompted (can be skipped for basic usage).  
4. Verify installation by opening **Command Prompt** or **PowerShell** and running:  **```node -v```** then **```npm -v```**
    - **```node -v```** should display the Node.js version.
    -  **```npm -v```** should display the npm (Node Package Manager) version.

### ***Installing MongoDB***

**Step 1 - Install MongoDB**
___
1. Go to the official MongoDB download page: https://www.mongodb.com/try/download/community
2. Select **Windows** as your OS.
3. Download the **MSI installer** for the latest stable version.
4. Run the installer and follow these steps:

    - Choose **Complete setup type**.
    - Check **Install MongoDB as a Service** (recommended).
    - Select **Run service as Network Service user** (default).
    - ***Optional**: install MongoDB Compass (GUI for MongoDB).*
5. Finish the installation.

**Step 2 - Add MongoDB to the PATH (if needed)** 
___
1. Open Control **Panel** → **System** → **Advanced system settings** → **Environment Variables**.
2. Under System variables, find and select **Path** → **Edit** → **New**.
3. Add the path to MongoDB bin folder, e.g. It's going to be something like this: **```C:\Program Files\MongoDB\Server\<version>\bin```**
4. Click *OK* to save.

**Step 3 - Verify MongoDB Installation**
___
1. Open **Command Prompt** or **PowerShell**.
2. Start the MongoDB server (if not installed as a service): **```mongod```**
3. In a new terminal, run the MongoDB shell: **```mongo```**.
4. You should see the MongoDB shell prompt (```>```), indicating MongoDB is running.

### ***Running Project - Back-End (Node.JS) and Database (MongoDB)***

**Step 1 - Run Databse**
___
For this step, use the video bellow to connect database properly:
- https://www.youtube.com/watch?v=nHLhaaL0Uwg 

> Copyright © 2025 [The Code City](https://www.youtube.com/@TheCodeCity). All rights reserved. 

**Step 2 - Run backend**
___
1. Navigate into the project folder: **```cd <repository-name>```**.
2. Navigate to **backend** folder: **```cd backend```**
3. Run the following command: **```npx nodemon server.js```**
    - If you haven’t installed it yet, run: **```npm install -g npm nodemon```**
    - Verify the installation with: **```npx -v```** and **```nodemon -v```**
4. You should see the following output in the terminal:
```
[nodemon] 3.1.10
[nodemon] to restart at any time, enter `rs`
[nodemon] watching path(s): *.*
[nodemon] watching extensions: js,mjs,cjs,json
[nodemon] starting `node server.js`
Servidor rodando na porta 5000
Conectado ao MongoDB!
```

### ***Running Front-End (UI) - Flutter and Android Studio***
**Step 1 - Open the Project in VS Code**
___
1. Open **VS Code**.
2. Navigate to the directory where you want to store your project, example: **```cd C:\Users\<YourUsername>\Documents\```**
3. Clone this repository: **```git clone <https or ssh>```**
4. After cloning, navigate into the project folder: **```cd <repository-name>```**
5.  To get all project dependencies, run: **```flutter pub get```**

**Step 5 - Open the Project in Android Studio**
___
1. Launch **Android Studio**.
2. On the start screen, select Open an **existing project**.
3. Browse to the folder **where you cloned the repository** and **open it**.
4. Wait for Android Studio to finish indexing the files and **syncing dependencies**.

**Step 6 - Run the Application on an Android Device or Emulator**
___

1. Connect an **Android device via USB**, or start an **Android emulator from Android Studio**. 
2. In **VS Code**, open a new terminal and run: **```flutter run```**
3. **Wait for the build process** — the app will launch on your selected device.

**Step 7 - Verify Everything is Working**
___
You can confirm the environment is properly configured by running: **```flutter doctor -v```**. If all checkmarks are green, your environment is ***ready for Flutter development***.

________

<p style="text-align:center;">
  This project is being developed by students: 
  <a href="https://github.com/BizerraGuU" target="_blank">Gustavo B. Andrade</a>, 
  <a href="https://github.com/IgorLima100" target="_blank">Igor M. França</a>, 
  <a href="https://github.com/JeffersonBJesus" target="_blank">Jefferson B. L. Jesus</a>
  <a href="https://github.com/JAOOUJIN" target="_blank">Seung Jin J. Casierra</a>
  <a href="https://github.com/Vitor0608" target="_blank">Vitor A. Santos</a>
</p>

