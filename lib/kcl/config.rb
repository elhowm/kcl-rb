module Kcl
  class Config
    attr_accessor :dynamodb_endpoint,
      :dynamodb_table_name,
      :dynamodb_read_capacity,
      :dynamodb_write_capacity,
      :dynamodb_failover_seconds,
      :kinesis_endpoint,
      :kinesis_stream_name,
      :max_records

    DEFAULTS = {
      dynamodb_endpoint: 'https://localhost:4566',
      dynamodb_table_name: nil,
      dynamodb_read_capacity: 10,
      dynamodb_write_capacity: 10,
      dynamodb_failover_seconds: 10,
      kinesis_endpoint: 'https://localhost:4566',
      kinesis_stream_name: nil,
      max_records: 10,
    }.freeze

    def initialize(options)
      DEFAULTS.keys.each do |key|
        instance_variable_set("@#{key}", options[key] || DEFAULTS[key])
      end
    end
  end
end
