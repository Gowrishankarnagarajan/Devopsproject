const express = require('express');
const app = express();
const port = process.env.PORT || 8084; // Matches target_port in Terraform

// Environment variables expected from Terraform/Container Apps
const cosmosDbMongoConnectionString = process.env.COSMOSDB_MONGODB_CONNECTION_STRING || 'Not Set';
const appInsightsConnectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || 'Not Set';
const keyVaultUri = process.env.KEY_VAULT_URI || 'Not Set';


app.get('/', (req, res) => {
  res.send(`
    <h1>Delivery Service Running!</h1>
    <p>Listening on port: ${port}</p>
    <p>CosmosDB MongoDB Connection String: ${cosmosDbMongoConnectionString.substring(0, 20)}...</p>
    <p>Application Insights Connection String: ${appInsightsConnectionString.substring(0, 20)}...</p>
    <p>Key Vault URI: ${keyVaultUri}</p>
    <p>This service manages delivery logistics.</p>
  `);
});

app.listen(port, () => {
  console.log(`Delivery service listening on port ${port}`);
});



// This service is responsible for managing delivery logistics and related tasks.
// It listens on the specified port and provides basic information about its configuration.