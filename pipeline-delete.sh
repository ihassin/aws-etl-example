#!/bin/zsh

set -a      # automatically export all variables
source .env
set +a

echo "Deleting stack"
aws cloudformation delete-stack --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
  --stack-name "$PIPELINE_STACK_NAME" \

#echo "Emptying pipeline bucket"
#aws s3 rm --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
#  s3://"$PIPELINE_S3_BUCKET_NAME" --recursive
