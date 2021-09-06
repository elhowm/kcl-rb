require 'json'
require 'securerandom'

require_relative './kcl_demo/demo_record_processor'
require_relative './kcl_demo/demo_record_processor_factory'

module KclDemo
  class App
    def self.config
      @config ||= Kcl::Config.new(
        dynamodb_endpoint: 'https://localhost:4566',
        dynamodb_table_name: 'kcl-rb-demo',
        kinesis_endpoint: 'https://localhost:4566',
        kinesis_stream_name: 'kcl-rb-demo',
        credentials: Aws::Credentials.new(
          'dummy', 'dummy'
        ),
        use_ssl: false
      )
    end

    def self.run
      factory = KclDemo::DemoRecordProcessorFactory.new
      Kcl::Worker.run('kcl-demo', factory, config)
    end

    def self.seed(record_count = 1000)
      proxy = Kcl::Proxies::KinesisProxy.new(config)

      # puts records
      record_count.times do |i|
        str = SecureRandom.alphanumeric
        hash = JSON.generate({ id: i, name: str })
        resp = proxy.put_record(
          {
            stream_name: config.kinesis_stream_name,
            data: Base64.strict_encode64(hash),
            partition_key: str
          }
        )
        puts resp
      end
    end
  end
end
