module Kcl
  module Types
    # Container for the parameters to the IRecordProcessor's method.
    class ShutdownInput
      attr_reader :shutdown_reason, :record_checkpointer

      # @param [Kcl::Worker::ShutdownReason] shutdown_reason
      # @param [Kcl::Workers::RecordCheckpointer] record_checkpointer
      def initialize(shutdown_reason, record_checkpointer)
        @shutdown_reason     = shutdown_reason
        @record_checkpointer = record_checkpointer
      end

      def terminated?
        shutdown_reason == Kcl::Workers::ShutdownReason::TERMINATE
      end

      def requested?
        shutdown_reason == Kcl::Workers::ShutdownReason::REQUESTED
      end
    end
  end
end
