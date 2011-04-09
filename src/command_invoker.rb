module CommandInvoker

  def invoke command
    @logger.debug "Command: #{command}"
    `#{command}`
  end

end
