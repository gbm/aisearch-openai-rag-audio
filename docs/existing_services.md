# Connecting VoiceRAG to existing services

VoiceRAG now operates in a bring-your-own-resource mode. The infrastructure template references existing Azure resources instead of creating them. This guide summarizes the configuration values you must provide before running `azd up` and shows how to reuse resources from other solutions, such as [azure-search-openai-demo](https://www.github.com/Azure-samples/azure-search-openai-demo).

## Required environment values

Set these values in your azd environment before running `azd up`:

```bash
azd env set AZURE_RESOURCE_GROUP <RESOURCE_GROUP_WITH_APP_SERVICE>
azd env set AZURE_WEBAPP_NAME <APP_SERVICE_NAME>
azd env set AZURE_OPENAI_ENDPOINT https://<YOUR_OPENAI_RESOURCE>.openai.azure.com
azd env set AZURE_OPENAI_REALTIME_DEPLOYMENT <REALTIME_DEPLOYMENT_NAME>
azd env set AZURE_SEARCH_ENDPOINT https://<YOUR_SEARCH_RESOURCE>.search.windows.net
azd env set AZURE_SEARCH_INDEX <INDEX_NAME>
azd env set AZURE_TENANT_ID <YOUR_TENANT_ID>
```

### Optional settings

Depending on how your Azure AI Search index is structured, you may also need to set the field-mapping variables:

```bash
azd env set AZURE_SEARCH_SEMANTIC_CONFIGURATION default
azd env set AZURE_SEARCH_IDENTIFIER_FIELD id
azd env set AZURE_SEARCH_CONTENT_FIELD content
azd env set AZURE_SEARCH_TITLE_FIELD sourcepage
azd env set AZURE_SEARCH_EMBEDDING_FIELD embedding
azd env set AZURE_SEARCH_USE_VECTOR_QUERY true
```

If your index relies solely on semantic search (no vector queries), set `AZURE_SEARCH_USE_VECTOR_QUERY` to `false`.

To change the default voice used by Azure OpenAI Realtime, update:

```bash
azd env set AZURE_OPENAI_REALTIME_VOICE_CHOICE <echo|alloy|shimmer>
```

## Reusing resources from azure-search-openai-demo

The popular RAG sample [`azure-search-openai-demo`](https://www.github.com/Azure-samples/azure-search-openai-demo) creates an Azure AI Search index that works well with VoiceRAG. After setting the required environment variables above, use the following values to match that demo's index schema:

```bash
azd env set AZURE_SEARCH_SEMANTIC_CONFIGURATION default
azd env set AZURE_SEARCH_IDENTIFIER_FIELD id
azd env set AZURE_SEARCH_CONTENT_FIELD content
azd env set AZURE_SEARCH_TITLE_FIELD sourcepage
azd env set AZURE_SEARCH_EMBEDDING_FIELD embedding
azd env set AZURE_SEARCH_INDEX gptkbindex
```

If the index was created with integrated vectorization (October 17, 2024 release or later), you can keep `AZURE_SEARCH_USE_VECTOR_QUERY` set to `true`.

## Local development

To run the solution locally without azd, create a `.env` file in `app/backend` with the required values. Example:

```bash
AZURE_TENANT_ID=<YOUR-TENANT-ID>
AZURE_OPENAI_ENDPOINT=https://<YOUR_OPENAI_RESOURCE>.openai.azure.com
AZURE_OPENAI_REALTIME_DEPLOYMENT=gpt-4o-realtime-preview
AZURE_OPENAI_REALTIME_VOICE_CHOICE=<echo|alloy|shimmer>
AZURE_SEARCH_ENDPOINT=https://<YOUR_SEARCH_RESOURCE>.search.windows.net
AZURE_SEARCH_INDEX=<INDEX_NAME>
AZURE_SEARCH_SEMANTIC_CONFIGURATION=default
AZURE_SEARCH_IDENTIFIER_FIELD=id
AZURE_SEARCH_CONTENT_FIELD=content
AZURE_SEARCH_TITLE_FIELD=sourcepage
AZURE_SEARCH_EMBEDDING_FIELD=embedding
AZURE_SEARCH_USE_VECTOR_QUERY=true
```

Add `AZURE_OPENAI_API_KEY` and/or `AZURE_SEARCH_API_KEY` if you are authenticating with keys instead of Microsoft Entra ID. Then follow the steps in the project's [README](../README.md#development-server) to run the app locally.
