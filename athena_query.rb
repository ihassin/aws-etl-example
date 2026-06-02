#!/usr/bin/env ruby
# # frozen_string_literal: true

require 'bundler/setup'

require 'aws-sdk-cloudformation'
require 'aws-sdk-athena'
require 'terminal-table'

STACK_NAME = 'glue-example-workflow'
QUERY_ID = 'AthenaProcessedCityDataQueryId'
RESULTS_BUCKET = "s3://#{ENV['STAGING_BUCKET_NAME']}/athena/"

def get_query_id_from_cloudformation(stack_name:, query_id:)
  cf = Aws::CloudFormation::Client.new(profile: ENV['AWS_GLUE_EXAMPLE_PROFILE'], region: ENV['AWS_GLUE_EXAMPLE_REGION'])

  stack = cf.describe_stacks(
    stack_name: stack_name
  ).stacks.first

  query_id = stack.outputs
                  .find { |o| o.output_key == query_id }
               &.output_value
end

def execute_query(stack_name:, query_id:)

  query_id = get_query_id_from_cloudformation(stack_name: STACK_NAME, query_id: QUERY_ID)

  raise "CloudFormation output '#{QUERY_ID}' not found" unless query_id

  athena = Aws::Athena::Client.new(profile: ENV['AWS_GLUE_EXAMPLE_PROFILE'], region: ENV['AWS_GLUE_EXAMPLE_REGION'])

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
  [table_rows, named_query.name]
end

table_rows, named_query = execute_query(stack_name: STACK_NAME, query_id: QUERY_ID)

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
    title: named_query,
    headings: headers,
    rows: data_rows
  )

  puts
  puts table
end
