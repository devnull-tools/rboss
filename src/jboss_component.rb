require_relative "file_processor"

module JBoss

  # A base helper module for JBoss Components
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  module Component

    # Creates a FileProcessor using the same logger and
    # jboss path as the variable
    def create_file_processor
      FileProcessor::new :logger => @logger, :var => @jboss
    end

  end
end
