require 'kcl/checkpointer'
require 'kcl/checkpoints/sentinel'
require 'kcl/config'
require 'kcl/errors'
require 'kcl/logger'
require 'kcl/log_formatter'
require 'kcl/proxies/dynamo_db_proxy'
require 'kcl/proxies/kinesis_proxy'
require 'kcl/record_processor'
require 'kcl/record_processor_factory'
require 'kcl/types/extended_sequence_number'
require 'kcl/types/initialization_input'
require 'kcl/types/records_input'
require 'kcl/types/shutdown_input'
require 'kcl/worker'
require 'kcl/workers/consumer'
require 'kcl/workers/record_checkpointer'
require 'kcl/workers/shard_info'
require 'kcl/workers/shutdown_reason'

module Kcl
  def self.logger
    @_logger ||= Kcl::Logger.new($stdout)
  end

  def self.logger=(value)
    @_logger = value
  end
end
