#!/bin/sh
echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID="8e00eb60-e4e5-4e8b-9952-a44dadeb87df"
export ARM_CLIENT_ID="68a994b9-4d17-4461-8de9-1c7de87c4d18"
export ARM_CLIENT_SECRET="40a9046c-41ec-4ccf-8121-bd7987561370"
export ARM_TENANT_ID="6296ce25-9464-4155-8133-749f8e6179c5"

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public


