#!/bin/zsh

set -a      # automatically export all variables
source .env
set +a

echo "Submitting stack"

aws cloudformation deploy --template-file glue-example-workflow.yaml --stack-name glue-example-workflow --capabilities CAPABILITY_NAMED_IAM \
--profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION" \
--parameter-overrides \
CityDataBucketName=$STAGING_BUCKET_NAME             \
CityDataPath=city-data                              \
CityDBName=city-data-db                             \
CityTableName=city_data                             \
CityDataProcessedTableName=city-data-processed      \
ParquetPath=city_data.parquet                       \
CityDataFileName=CityData.csv                       \
CityDataETLScriptName=city_etl.py                   \
CityDataDQScriptName=city_dq.py                     \
CityDataProcessedPath=processed                     \
ScriptPath="$SCRIPT_PATH"

echo "Loading scripts to $SCRIPT_PATH"
aws s3 sync ./"$SCRIPT_PATH"/ "s3://$STAGING_BUCKET_NAME/$SCRIPT_PATH" \
--profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION"
