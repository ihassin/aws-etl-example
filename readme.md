# Intro

Messing about with AWS Glue: Creating a database, crawler, etl job, athena qureies

# Running stuff

run `./workflow-create.sh` to create the worklflow and the objects and scripts it will run when triggered.

run `./workflow-feed.sh` to load data to S3, which will trigger the workflow

run `./workflow-delete.sh` to remove everything.

# Technotes

Creating a table for the Crawler is not needed as the crawler will create one on its first run.
