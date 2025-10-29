# Customizing the VoiceRAG deployment

This guide shows you how to customize the [VoiceRAG](../README.md#deploying-the-app) deployment when running against existing Azure resources. If you need help pointing the sample at services you already have, see the [existing services guide](./existing_services.md).

## Customizing the real-time voice choice

Run this command to set the voice choice for the real-time deployment:

```bash
azd env set AZURE_OPENAI_REALTIME_VOICE_CHOICE <echo, alloy, or shimmer>
```

The default voice choice is `alloy`, but 2 other voices are available.

Once you have set the voice choice, run `azd up` to apply the changes to the deployed app.
If you've already run `azd up` and want to first preview the voice with the development server, then update your local `.env` file by running `./scripts/write_env.sh` or `pwsh ./scripts/write_env.ps1`, and then restart the development server.

## Updating the Azure OpenAI deployment

Because the infrastructure template no longer creates Azure OpenAI deployments, changes to capacity, versions, or model SKUs must be performed directly on your existing Azure OpenAI resource. Use the Azure portal, CLI, or ARM/Bicep templates in your own infrastructure repository to adjust those settings. After making changes, ensure the deployment name remains the same value referenced by `AZURE_OPENAI_REALTIME_DEPLOYMENT`, or update that environment variable before running `azd up` again.
