#!/bin/bash
# direnvで環境変数にサブスクリプションIDを設定するスクリプト

ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" >.envrc
direnv allow
