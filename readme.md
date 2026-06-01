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

run `./workflow-feed.sh` that load data to S3, triggering the workflow.

run `./workflow-delete.sh` to remove everything.

# Verifying the work manually

- Install `duckdb` using brew
- Download the parquet file from the curated folder in S3
- Run the query: `duckdb -c "SELECT * FROM '~/Downloads/file.snappy.parquet';"`


# Technotes

Creating a table for the Crawler is not needed as the crawler will create one on its first run.
