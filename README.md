# VoiceRAG: An Application Pattern for RAG + Voice Using Azure AI Search and the GPT-4o Realtime API for Audio



This repo contains an example of how to implement RAG support in applications that use voice as their user interface, powered by the GPT-4o realtime API for audio. We describe the pattern in more detail in [this blog post](https://aka.ms/voicerag), and you can see this sample app in action in [this short video](https://youtu.be/vXJka8xZ9Ko).

* [Features](#features)
* [Architecture Diagram](#architecture-diagram)
* [Getting Started](#getting-started)
  * [GitHub Codespaces](#github-codespaces)
  * [VS Code Dev Containers](#vs-code-dev-containers)
  * [Local environment](#local-environment)
* [Deploying the app](#deploying-the-app)
* [Development server](#development-server)
* [Guidance](#guidance)
* [Resources](#resources)
* [Getting help](#getting-help)

## Features

* **Voice interface**: The app uses the browser's microphone to capture voice input, and sends it to the backend where it is processed by the Azure OpenAI GPT-4o Realtime API.
* **RAG (Retrieval Augmented Generation)**: The app uses the Azure AI Search service to answer questions about a knowledge base, and sends the retrieved documents to the GPT-4o Realtime API to generate a response.
* **Audio output**: The app plays the response from the GPT-4o Realtime API as audio, using the browser's audio capabilities.
* **Citations**: The app shows the search results that were used to generate the response.

### Architecture Diagram

The `RTClient` in the frontend receives the audio input, sends that to the Python backend which uses an `RTMiddleTier` object to interface with the Azure OpenAI real-time API, and includes a tool for searching Azure AI Search.

![Diagram of real-time RAG pattern](docs/RTMTPattern.png)

This repository includes infrastructure as code to deploy the app to an existing Azure App Service (Linux). The Bicep template no longer provisions new Azure resources, so you must supply your own Azure OpenAI, Azure AI Search, and App Service instances. The app can also run locally with the same configuration values supplied through a `.env` file.

## Getting Started

### Local environment

1. Install the required tools:
   * [Azure Developer CLI](https://aka.ms/azure-dev/install)
   * [Node.js](https://nodejs.org/)
   * [Python >=3.11](https://www.python.org/downloads/)
      * **Important**: Python and the pip package manager must be in the path in Windows for the setup scripts to work.
      * **Important**: Ensure you can run `python --version` from console. On Ubuntu, you might need to run `sudo apt install python-is-python3` to link `python` to `python3`.
   * [Git](https://git-scm.com/downloads)
   * [Powershell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) - For Windows users only.

2. Clone the repo (`git clone https://github.com/Azure-Samples/aisearch-openai-rag-audio`)
3. Proceed to the next section to [deploy the app](#deploying-the-app).

## Deploying the app

The steps below assume that you already have the required Azure resources. At minimum you need:

* An Azure App Service (Linux) plan with a Web App that will host the backend.
* An Azure OpenAI resource with a real-time deployment available.
* An Azure AI Search service with an index containing the content you want to ground the model with.

If these resources do not exist yet, create or reuse them before continuing. The [`docs/manual_setup.md`](docs/manual_setup.md) guide lists the required Azure services and offers tips for preparing an Azure AI Search index.

1. Login to your Azure account:

    ```shell
    azd auth login
    ```


1. Create a new azd environment:

    ```shell
    azd env new
    ```

    Enter a name that will be used for the resource group.
    This will create a new folder in the `.azure` folder, and set it as the active environment for any calls to `azd` going forward.

1. Configure the azd environment with the details of your existing resources:

   ```shell
   azd env set AZURE_RESOURCE_GROUP rg-devtest-1
   azd env set AZURE_WEBAPP_NAME devtest-1-webapp 
   azd env set AZURE_OPENAI_ENDPOINT https://devtest-1-resource.openai.azure.com
   azd env set AZURE_OPENAI_REALTIME_DEPLOYMENT gpt-realtime
   azd env set AZURE_SEARCH_ENDPOINT https://devtest-1-ai-search.search.windows.net
   azd env set AZURE_SEARCH_INDEX rag-1761216185868

   azd env set AZURE_RESOURCE_GROUP <RESOURCE_GROUP_WITH_APP_SERVICE>
   azd env set AZURE_WEBAPP_NAME <APP_SERVICE_NAME>
   azd env set AZURE_OPENAI_ENDPOINT https://<YOUR_OPENAI_RESOURCE>.openai.azure.com
   azd env set AZURE_OPENAI_REALTIME_DEPLOYMENT <REALTIME_DEPLOYMENT_NAME>
   azd env set AZURE_SEARCH_ENDPOINT https://<YOUR_SEARCH_RESOURCE>.search.windows.net
   azd env set AZURE_SEARCH_INDEX <INDEX_NAME>
   azd env set AZURE_TENANT_ID <YOUR_TENANT_ID>
   ```

   Additional optional environment variables that control search field mapping or voice selection are described in [`docs/existing_services.md`](docs/existing_services.md) and [`docs/customizing_deploy.md`](docs/customizing_deploy.md).

1. Run this command to deploy the application to the existing App Service and sync a local `.env` file:

   ```shell
   azd up
   ````

   * **Important**: This command does not create infrastructure. It assumes the App Service and supporting resources already exist and will fail if they cannot be found. The command uploads the backend package, sets App Service configuration values, and writes a `.env` file locally using the values from the azd environment.

1. After the application has been successfully deployed you will see a URL printed to the console (you can also retrieve it with `azd env get-value BACKEND_URI`). Navigate to that URL to interact with the app in your browser. To try out the app, click the "Start conversation" button, say "Hello", and then ask a question about your data like "What is the whistleblower policy for Contoso electronics?" You can also now run the app locally by following the instructions in [the next section](#development-server).

## Development server

You can run this app locally using either the Azure services you provisioned by following the [deployment instructions](#deploying-the-app), or by pointing the local app at already [existing services](docs/existing_services.md).

1. If you deployed with `azd up`, you should see a `app/backend/.env` file with the necessary environment variables.

2. If did *not* use `azd up`, you will need to create `app/backend/.env` file with the following environment variables:

   ```shell
   AZURE_OPENAI_ENDPOINT=wss://<your instance name>.openai.azure.com
   AZURE_OPENAI_REALTIME_DEPLOYMENT=gpt-4o-realtime-preview
   AZURE_OPENAI_REALTIME_VOICE_CHOICE=<choose one: echo, alloy, shimmer>
   AZURE_OPENAI_API_KEY=<your api key>
   AZURE_SEARCH_ENDPOINT=https://<your service name>.search.windows.net
   AZURE_SEARCH_INDEX=<your index name>
   AZURE_SEARCH_API_KEY=<your api key>
   ```

   To use Entra ID (your user when running locally, managed identity when deployed) simply don't set the keys.

3. Run this command to start the app:

   Windows:

   ```pwsh
   pwsh .\scripts\start.ps1
   ```

   Linux/Mac:

   ```bash
   ./scripts/start.sh
   ```

4. The app is available on [http://localhost:8765](http://localhost:8765).

   Once the app is running, when you navigate to the URL above you should see the start screen of the app:
   ![app screenshot](docs/talktoyourdataapp.png)

   To try out the app, click the "Start conversation button", say "Hello", and then ask a question about your data like "What is the whistleblower policy for Contoso electronics?"

## Guidance

### Costs

Pricing varies per region and usage, so it isn't possible to predict exact costs for your usage.
However, you can try the [Azure pricing calculator](https://azure.com/e/a87a169b256e43c089015fda8182ca87) for the resources below.

* Azure App Service (Linux): Premium v3 plan (P1v3 by default). Pricing varies by tier. [Pricing](https://azure.microsoft.com/pricing/details/app-service/linux/)
* Azure OpenAI: Standard tier, gpt-4o-realtime and text-embedding-3-large models. Pricing per 1K tokens used. [Pricing](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/)
* Azure AI Search: Standard tier, 1 replica, free level of semantic search. Pricing per hour. [Pricing](https://azure.microsoft.com/pricing/details/search/)
* Azure Blob Storage: Standard tier with ZRS (Zone-redundant storage). Pricing per storage and read operations. [Pricing](https://azure.microsoft.com/pricing/details/storage/blobs/)
* Azure Monitor: Pay-as-you-go tier. Costs based on data ingested. [Pricing](https://azure.microsoft.com/pricing/details/monitor/)

To reduce costs, you can switch to free SKUs for various services, but those SKUs have limitations.

⚠️ To avoid unnecessary costs, remember to take down your app if it's no longer in use,
either by deleting the resource group in the Portal or running `azd down`.

### Security

This template uses [Managed Identity](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/overview) to eliminate the need for developers to manage these credentials. Applications can use managed identities to obtain Microsoft Entra tokens without having to manage any credentials.To ensure best practices in your repo we recommend anyone creating solutions based on our templates ensure that the [Github secret scanning](https://docs.github.com/code-security/secret-scanning/about-secret-scanning) setting is enabled in your repos.

### Notes

>Sample data: The PDF documents used in this demo contain information generated using a language model (Azure OpenAI Service). The information contained in these documents is only for demonstration purposes and does not reflect the opinions or beliefs of Microsoft. Microsoft makes no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, suitability or availability with respect to the information contained in this document. All rights reserved to Microsoft.

## Resources

* [Blog post: VoiceRAG](https://aka.ms/voicerag)
* [Demo video: VoiceRAG](https://youtu.be/vXJka8xZ9Ko)
* [Azure OpenAI Realtime Documentation](https://github.com/Azure-Samples/aoai-realtime-audio-sdk/)

### Getting help

This is a sample built to demonstrate the capabilities of modern Generative AI apps and how they can be built in Azure. For help with deploying this sample, please post in [GitHub Issues](/issues). If you're a Microsoft employee, you can also post in [our Teams channel](https://aka.ms/azai-python-help).

This repository is supported by the maintainers, _not_ by Microsoft Support,
so please use the support mechanisms described above, and we will do our best to help you out.

For general questions about developing AI solutions on Azure,
join the Azure AI Foundry Developer Community:

[![Azure AI Foundry Discord](https://img.shields.io/badge/Discord-Azure_AI_Foundry_Community_Discord-blue?style=for-the-badge&logo=discord&color=5865f2&logoColor=fff)](https://aka.ms/foundry/discord)
[![Azure AI Foundry Developer Forum](https://img.shields.io/badge/GitHub-Azure_AI_Foundry_Developer_Forum-blue?style=for-the-badge&logo=github&color=000000&logoColor=fff)](https://aka.ms/foundry/forum)