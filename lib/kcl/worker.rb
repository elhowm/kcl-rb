require 'eventmachine'

module Kcl
  class Worker
    PROCESS_INTERVAL = 1 # by sec

    def self.run(id, record_processor_factory)
      worker = self.new(id, record_processor_factory)
      worker.start
    end

    def initialize(id, record_processor_factory)
      @id = id
      @record_processor_factory = record_processor_factory
      @live_shards  = {} # Map<String, Boolean>
      @shards       = {} # Map<String, Kcl::Workers::ShardInfo>
      @kinesis      = nil # Kcl::Proxies::KinesisProxy
      @checkpointer = nil # Kcl::Checkpointer
      @timer        = nil
    end

    # Start consuming data from the stream,
    # and pass it to the application record processors.
    def start
      Kcl.logger.info("Start worker at #{object_id}")

      EM.run do
        trap_signals

        @timer = EM::PeriodicTimer.new(PROCESS_INTERVAL) do
          sync_shards!
          consume_shards! if available_lease_shard?
        end
      end

      cleanup
      Kcl.logger.info("Finish worker at #{object_id}")
    rescue => e
      Kcl.logger.error("#{e.class}: #{e.message}")
      raise e
    end

    # Shutdown gracefully
    def shutdown(signal = :NONE)
      unless @timer.nil?
        @timer.cancel
        @timer = nil
      end
      EM.stop

      Kcl.logger.info("Shutdown worker with signal #{signal} at #{object_id}")
    rescue => e
      Kcl.logger.error("#{e.class}: #{e.message}")
      raise e
    end

    # Cleanup resources
    def cleanup
      @live_shards  = {}
      @shards       = {}
      @kinesis      = nil
      @checkpointer = nil
    end

    # Add new shards and delete unused shards
    def sync_shards!
      @live_shards.transform_values! { |_| false }

      kinesis.shards.each do |shard|
        @live_shards[shard.shard_id] = true
        next if @shards[shard.shard_id]
        @shards[shard.shard_id] = Kcl::Workers::ShardInfo.new(
          shard.shard_id,
          shard.parent_shard_id,
          shard.sequence_number_range
        )
        Kcl.logger.info("Found new shard at shard_id: #{shard.shard_id}")
      end

      @live_shards.each do |shard_id, alive|
        next if alive
        checkpointer.remove_lease(@shards[shard_id])
        @shards.delete(shard_id)
        Kcl.logger.info("Remove shard at shard_id: #{shard_id}")
      end

      @shards
    end

    # Count the number of leases hold by worker excluding the processed shard
    # @return [Boolean]
    def available_lease_shard?
      leased_count = @shards.values.inject(0) do |num, shard|
        shard.lease_owner == @id && !shard.completed? ? num + 1 : num
      end
      Kcl.config.max_lease_count > leased_count
    end

    # Process records by shard
    def consume_shards!
      threads = []
      @shards.each do |shard_id, shard|
        # already owner of the shard
        next if shard.lease_owner == @id

        begin
          shard = checkpointer.fetch_checkpoint(shard)
        rescue Kcl::Errors::CheckpointNotFoundError
          Kcl.logger.info("Not found checkpoint of shard at #{shard.to_h}")
          next
        end
        # shard is closed and processed all records
        next if shard.completed?

        shard = checkpointer.lease(shard, @id)

        threads << Thread.new do
          begin
            consumer = Kcl::Workers::Consumer.new(
              shard,
              @record_processor_factory.create_processor,
              kinesis,
              checkpointer
            )
            consumer.consume!
          ensure
            shard = checkpointer.remove_lease_owner(shard)
            Kcl.logger.info("Finish to consume shard at shard_id: #{shard_id}")
          end
        end
      end
      threads.each(&:join)
    end

    private

    def kinesis
      if @kinesis.nil?
        @kinesis = Kcl::Proxies::KinesisProxy.new(Kcl.config)
        Kcl.logger.info('Created Kinesis session in worker')
      end
      @kinesis
    end

    def checkpointer
      if @checkpointer.nil?
        @checkpointer = Kcl::Checkpointer.new(Kcl.config)
        Kcl.logger.info('Created Checkpoint in worker')
      end
      @checkpointer
    end

    def trap_signals
      [:HUP, :INT, :TERM].each do |signal|
        trap signal do
          EM.add_timer(0) { shutdown(signal) }
        end
      end
    end
  end
end
