module Kcl
  class Config
    attr_accessor :aws_region,
      :aws_access_key_id,
      :aws_secret_access_key,
      :dynamodb_endpoint,
      :dynamodb_table_name,
      :dynamodb_read_capacity,
      :dynamodb_write_capacity,
      :dynamodb_failover_seconds,
      :kinesis_endpoint,
      :kinesis_stream_name,
      :logger,
      :log_level,
      :max_lease_count,
      :use_ssl,
      :worker_count

    # Set default values
    def initialize
      @aws_region              = nil
      @aws_access_key_id       = nil
      @aws_secret_access_key   = nil
      @dynamodb_endpoint       = 'https://localhost:4566'
      @dynamodb_table_name     = nil
      @dynamodb_read_capacity  = 10
      @dynamodb_write_capacity = 10
      @dynamodb_failover_seconds = 10
      @kinesis_endpoint        = 'https://localhost:4566'
      @kinesis_stream_name     = nil
      @logger                  = nil
      @max_lease_count         = 1
      @use_ssl                 = false
      @worker_count            = 1
    end
  end
end
