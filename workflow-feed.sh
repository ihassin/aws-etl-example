#!/bin/zsh

DATA_PATH=city-data

echo "Uploading data to s3://$STAGING_BUCKET_NAME/$DATA_PATH"
aws s3 sync ./data/ "s3://$STAGING_BUCKET_NAME/$DATA_PATH" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
