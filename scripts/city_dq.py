import sys
import logging
import json

from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import col, sum, when

def log_event(level, event, **kwargs):
    payload = {
        "event": event,
        **kwargs
    }

    message = json.dumps(payload, default=str)

    if level == "ERROR":
        logger.error(message)
    elif level == "WARNING":
        logger.warning(message)
    else:
        logger.info(message)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter("%(message)s"))
logger.addHandler(handler)

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "bucket_name",
    "file_path"
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

s3_path = f"s3://{args['bucket_name']}/{args['file_path']}"

log_event(
    "INFO",
    "read_parquet_started",
    job_name=args["JOB_NAME"],
    s3_path=s3_path
)

df = spark.read.parquet(s3_path)

row_count = df.count()
log_event(
    "INFO",
    "parquet_loaded",
    row_count=row_count,
    column_count=len(df.columns)
)

# --------------------------------------------------
# Data Quality Check: NULL values
# --------------------------------------------------

null_counts = df.select([
    sum(when(col(c).isNull(), 1).otherwise(0)).alias(c)
    for c in df.columns
])

result = null_counts.collect()[0]

bad_columns = []

for column in df.columns:
    if result[column] > 0:
        bad_columns.append((column, result[column]))

# --------------------------------------------------
# Fail job if nulls exist
# --------------------------------------------------

# if bad_columns:
#     logger.error("*** Data quality failure: NULL values detected")
#
# #     for col_name, count in bad_columns:
# #         logger.error(f"{col_name}: {count} NULL values")
#
#     raise Exception("*** Data quality checks failed")
#
# logger.info("***Data quality checks passed")

if bad_columns:
    log_event(
        "ERROR",
        "data_quality_failure",
        check="null_values",
        failed_columns=bad_columns,
        failed_column_count=len(bad_columns)
    )

    raise Exception("Data quality checks failed")

log_event(
    "INFO",
    "data_quality_passed",
    check="null_values"
)

output_path = f"s3://{args['bucket_name']}/curated/output/"

df.write.mode("overwrite").parquet(output_path)

log_event(
    "INFO",
    "data_written",
    output_path=output_path,
    row_count=row_count
)
