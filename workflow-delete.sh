#!/bin/zsh

echo "Emptying staging bucket"
aws s3 rm --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  s3://"$STAGING_BUCKET_NAME" --recursive

echo "Deleting stack"
aws cloudformation delete-stack --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  --stack-name glue-workflow
