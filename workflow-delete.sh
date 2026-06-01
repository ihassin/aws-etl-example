#!/bin/zsh

echo "Emptying staging bucket"
aws s3 rm --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
  s3://"$STAGING_BUCKET_NAME" --recursive

echo "Deleting stack"
aws cloudformation delete-stack --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
  --stack-name glue-workflow
