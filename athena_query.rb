# frozen_string_literal: true

require 'aws-sdk-cloudformation'
require 'aws-sdk-athena'
require 'terminal-table'

REGION = 'us-east-1'
STACK_NAME = 'my-city-data-stack'
OUTPUT_KEY = 'CityDataValidationQueryId'
RESULTS_BUCKET = 's3://my-athena-results/results/'

#
# Get Athena Named Query ID from CloudFormation
#
cf = Aws::CloudFormation::Client.new(region: REGION)

stack = cf.describe_stacks(
  stack_name: STACK_NAME
).stacks.first

query_id = stack.outputs
                .find { |o| o.output_key == OUTPUT_KEY }
             &.output_value

raise "CloudFormation output '#{OUTPUT_KEY}' not found" unless query_id

puts "Found Athena Named Query ID: #{query_id}"

#
# Retrieve the Named Query
#
athena = Aws::Athena::Client.new(region: REGION)

named_query = athena.get_named_query(
  named_query_id: query_id
).named_query

puts "Executing query: #{named_query.name}"

#
# Start Query Execution
#
execution = athena.start_query_execution(
  query_string: named_query.query_string,
  query_execution_context: {
    database: named_query.database
  },
  result_configuration: {
    output_location: RESULTS_BUCKET
  }
)

query_execution_id = execution.query_execution_id

puts "Started query execution: #{query_execution_id}"

#
# Wait for completion
#
loop do
  execution = athena.get_query_execution(
    query_execution_id: query_execution_id
  )

  status = execution.query_execution.status.state

  case status
  when 'SUCCEEDED'
    puts "\nQuery completed successfully."
    break
  when 'FAILED'
    raise <<~ERROR
      Athena query failed:
      #{execution.query_execution.status.state_change_reason}
    ERROR
  when 'CANCELLED'
    raise 'Athena query was cancelled.'
  else
    print '.'
    sleep 2
  end
end

#
# Retrieve all result pages
#
rows = []
next_token = nil

loop do
  response = athena.get_query_results(
    query_execution_id: query_execution_id,
    next_token: next_token
  )

  rows.concat(response.result_set.rows)

  next_token = response.next_token
  break unless next_token
end

#
# Convert Athena rows to arrays
#
table_rows = rows.map do |row|
  row.data.map { |col| col.var_char_value.to_s }
end

if table_rows.empty?
  puts 'No rows returned.'
  exit
end

#
# Athena returns headers as the first row
#
headers = table_rows.first
data_rows = table_rows.drop(1)

#
# Special handling for single-value results
#
if headers.length == 1 && data_rows.length == 1
  puts "\n#{headers.first}: #{data_rows.first.first}"
else
  table = Terminal::Table.new(
    title: named_query.name,
    headings: headers,
    rows: data_rows
  )

  puts
  puts table
end
