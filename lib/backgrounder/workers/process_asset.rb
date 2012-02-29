# encoding: utf-8
module CarrierWave
  module Workers

    class ProcessAsset < Struct.new(:klass, :id, :column)
      @queue = :process_asset

      def self.perform(*args)
        new(*args).perform
      end

      def perform
        resource = klass.is_a?(String) ? klass.constantize : klass
        record = resource.find id
        record.send(:"process_#{column}_upload=", true)
        if record.send(:"#{column}").recreate_versions!
          record.send(:after_processing) if record.respond_to?(:after_processing)
          record.update_attribute(:"#{column}_processing", nil) if record.respond_to?(:"#{column}_processing")
        end
      end
      
    end # ProcessAsset
    
  end # Workers
end # Backgrounder
