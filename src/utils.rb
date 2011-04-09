require_relative "file_processor"

class String
  def to_jboss_property
    (self.split(/_/).collect { |n| n.capitalize }).join
  end

  def uncapitalize
    self[0, 1].downcase + self[1..-1]
  end

end

module FileProcessorBuilder
  # Creates a file processor with logger and jboss variable setted
  def create_file_processor
    FileProcessor::new :logger => @logger, :var => @jboss
  end
end
