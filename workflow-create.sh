#!/bin/zsh

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
ScriptPath=scripts

echo "Loading scripts"
aws s3 sync ./scripts/ "s3://$STAGING_BUCKET_NAME/scripts" \
--profile "$AWS_GLUE_EXAMPLE_PROFILE" --region "$AWS_GLUE_EXAMPLE_REGION"
