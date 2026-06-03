#!/bin/zsh

set -a      # automatically export all variables
source .env
set +a

echo "Uploading data to s3://$STAGING_BUCKET_NAME/$DATA_PATH"
aws s3 sync ./data/ "s3://$STAGING_BUCKET_NAME/$DATA_PATH" --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION"
