# Intro

Messing about with AWS Glue: Creating a database, crawler, etl job, athena qureies

# Setup

## AWS Profile and credentials

Your rc file, i.e. .zshrc, should contain an exported environment variable named `AWS_GLUE_EXAMPLE_PROFILE`. This variable's value is the AWS profile name used to run the code.

For example:
```shell
export AWS_GLUE_EXAMPLE_PROFILE=TW
```

In conjunction with this, create the '[TW]' entry in your local credentials file, i.e. `~/.aws/credentials`.
For example:
```shell
[TW]
aws_access_key_id=ABC
aws_secret_access_key=DEF
aws_session_token=GHI
```

## AWS Region

Your rc file, i.e. .zshrc, should contain an exported environment variable named `AWS_GLUE_EXAMPLE_REGION`. This variable's value is the AWS region name used to run the code.

For example:
```shell
export AWS_GLUE_EXAMPLE_REGION=us-east-1
```

## S3 Bucket name

Your rc file, i.e. .zshrc, should contain an exported environment variable named `STAGING_BUCKET_NAME`. This variable's value is the name of the bucket that code and data will be using.

For example:
```shell
export STAGING_BUCKET_NAME=com-yourcompany-bucket-name
```

# Running stuff

run `./workflow-create.sh` to create the workflow that will run when triggered.

run `./workflow-feed.sh` that loads data to the `STAGING_BUCKET_NAME` S3 bucket, triggering the workflow.
Please note that the job won't run unless it's the first time, or if the data is identical to a previous run. This is by design

run `./workflow-delete.sh` to remove everything.

# Monitoring

Monitor the workflow [here](https://us-east-1.console.aws.amazon.com/glue/home?region=us-east-1#/v2/etl-configuration/workflows/view/CityDataWorkflow?activeViewTab=id-tab-history)

Monitor the workflow logs [here](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws$252Flambda$252Fstart-glue-workflow)

Monitor the crawler [here](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws-glue$252Fcrawlers/log-events/CityDataCrawler)

Monitor jobs [here](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws-glue$252Fjobs$252Foutput)

Monitor errors [here](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws-glue$252Fjobs$252Ferror)

# Verifying the work manually

## Parquet files

- Install duckdb using `brew install duckdb`
- Download the parquet file from the curated folder in S3
- Run the query: `duckdb -c "SELECT * FROM '~/Downloads/file.snappy.parquet';"`

## Using Athena

- Run the Athena queries in 'Saved Queries' using the console
- Run `./athena_query.rb` (after installing ruby and running `bundle`)

# Technotes

Creating a table for the Crawler is not needed as the crawler will create one on its first run.
