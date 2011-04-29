require_relative "file_processor"

module JBoss
  module Component

    def create_file_processor
      FileProcessor::new :logger => @logger, :var => @jboss
    end

  end
end
