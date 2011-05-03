# A simple module to print commands for using in reports
#
# author: Marcelo Guimarães <ataxexe@gmail.com>
module CommandInvoker

  def invoke command
    @logger.debug "Command: #{command}"
    `#{command}`
  end

end
