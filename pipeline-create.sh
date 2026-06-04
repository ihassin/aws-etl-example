#!/bin/zsh

set -a      # automatically export all variables
source .env
set +a

echo "Submitting stack"
aws cloudformation deploy \
  --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
  --template-file "$PIPELINE_TEMPLATE_FILE" \
  --stack-name "$PIPELINE_STACK_NAME" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      GitHubOwner=ihassin \
      GitHubRepo=aws-etl-example  \
      PipelineS3BucketName="$PIPELINE_S3_BUCKET_NAME" \
      PipelineStackName="$PIPELINE_STACK_NAME"        \
      ETLWorkflowTemplateFile="$ETL_WORKFLOW_TEMPLATE_FILE"


#aws cloudformation list-stack-resources \
#  --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
#    --stack-name "$PIPELINE_STACK_NAME"
#
#aws cloudformation continue-update-rollback \
#  --stack-name "$PIPELINE_STACK_NAME" \
#  --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION"
#
#aws iam create-role \
#  --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
#  --role-name CFNDeploymentRole \
#  --assume-role-policy-document '{
#    "Version":"2012-10-17",
#    "Statement":[{
#      "Effect":"Allow",
#      "Principal":{"Service":"cloudformation.amazonaws.com"},
#      "Action":"sts:AssumeRole"
#    }]
#  }'
#
#  aws iam attach-role-policy \
#  --profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
#    --role-name CFNDeploymentRole \
#    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
#
