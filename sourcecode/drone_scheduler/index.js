const express = require('express');
const app = express();
const port = process.env.PORT || 8083; // Matches target_port in Terraform

// Environment variables expected from Terraform/Container Apps
const redisConnectionString = process.env.REDIS_CONNECTION_STRING || 'Not Set';
const appInsightsConnectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || 'Not Set';
const keyVaultUri = process.env.KEY_VAULT_URI || 'Not Set';


app.get('/', (req, res) => {
  res.send(`
    <h1>Drone Scheduler Service Running!</h1>
    <p>Listening on port: ${port}</p>
    <p>Redis Connection String: ${redisConnectionString.substring(0, 20)}...</p>
    <p>Application Insights Connection String: ${appInsightsConnectionString.substring(0, 20)}...</p>
    <p>Key Vault URI: ${keyVaultUri}</p>
    <p>This service schedules drone operations.</p>
  `);
});

app.listen(port, () => {
  console.log(`Drone Scheduler service listening on port ${port}`);
});