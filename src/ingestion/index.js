const express = require('express');
const app = express();
const port = process.env.PORT || 8080; // Container Apps exposes target_port as PORT env var

// Environment variables expected from Terraform/Container Apps
const serviceBusConnectionString = process.env.SERVICEBUS_CONNECTION_STRING || 'Not Set';
const cosmosDbMongoConnectionString = process.env.COSMOSDB_MONGODB_CONNECTION_STRING || 'Not Set';
const appInsightsConnectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || 'Not Set';
const keyVaultUri = process.env.KEY_VAULT_URI || 'Not Set';

app.get('/', (req, res) => {
  res.send(`
    <h1>Ingestion Service Running!</h1>
    <p>Listening on port: ${port}</p>
    <p>Service Bus Connection String: ${serviceBusConnectionString.substring(0, 20)}...</p>
    <p>CosmosDB MongoDB Connection String: ${cosmosDbMongoConnectionString.substring(0, 20)}...</p>
    <p>Application Insights Connection String: ${appInsightsConnectionString.substring(0, 20)}...</p>
    <p>Key Vault URI: ${keyVaultUri}</p>
    <p>This service handles incoming data.</p>
  `);
});

app.listen(port, () => {
  console.log(`Ingestion service listening on port ${port}`);
});
