const express = require('express');
const app = express();
const port = process.env.PORT || 8081; // Matches target_port in Terraform

// Environment variables expected from Terraform/Container Apps
const serviceBusConnectionString = process.env.SERVICEBUS_CONNECTION_STRING || 'Not Set';
const cosmosDbWorkflowConnectionString = process.env.COSMOSDB_WORKFLOW_CONNECTION_STRING || 'Not Set';
const appInsightsConnectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || 'Not Set';
const keyVaultUri = process.env.KEY_VAULT_URI || 'Not Set';


app.get('/', (req, res) => {
  res.send(`
    <h1>Workflow Service Running!</h1>
    <p>Listening on port: ${port}</p>
    <p>Service Bus Connection String: ${serviceBusConnectionString.substring(0, 20)}...</p>
    <p>CosmosDB Workflow Connection String: ${cosmosDbWorkflowConnectionString.substring(0, 20)}...</p>
    <p>Application Insights Connection String: ${appInsightsConnectionString.substring(0, 20)}...</p>
    <p>Key Vault URI: ${keyVaultUri}</p>
    <p>This service orchestrates workflows.</p>
  `);
});

app.listen(port, () => {
  console.log(`Workflow service listening on port ${port}`);
});
// This service is responsible for orchestrating workflows and handling related tasks.
// It listens on the specified port and provides basic information about its configuration.