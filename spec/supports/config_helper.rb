class KclTestHelper
  def self.config
    # use localstack
    @_config ||= Kcl::Config.new(
      dynamodb_endpoint: 'https://localhost:4566',
      dynamodb_table_name: 'kcl-rb-test',
      kinesis_endpoint: 'https://localhost:4566',
      kinesis_stream_name: 'kcl-rb-test'
    )
  end
end
Kcl.logger = Kcl::Logger.new('/dev/null')
