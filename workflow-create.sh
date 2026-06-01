#!/bin/zsh

echo "Submitting stack"
aws cloudformation deploy --template-file glue-workflow.yaml --stack-name glue-workflow --capabilities CAPABILITY_NAMED_IAM \
--profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
  --parameter-overrides \
CityDataBucketName=$STAGING_BUCKET_NAME

echo "Loading scripts"
aws s3 sync ./scripts/ "s3://$STAGING_BUCKET_NAME/scripts" \
--profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION"
