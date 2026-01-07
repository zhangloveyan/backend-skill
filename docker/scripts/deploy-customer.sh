#!/bin/bash
set -e

# 私有化部署脚本（模板）

CUSTOMER=$1
ENV_FILE="envs/.env.${CUSTOMER}"

if [ -z "$CUSTOMER" ]; then
    echo "Usage: $0 <customer-code>"
    echo "Example: $0 company-a"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file not found: $ENV_FILE"
    exit 1
fi

echo "Deploying for customer: $CUSTOMER"
echo "Using env file: $ENV_FILE"

docker-compose --env-file $ENV_FILE pull
docker-compose --env-file $ENV_FILE up -d
docker-compose --env-file $ENV_FILE ps

echo "Deployment completed for: $CUSTOMER"
