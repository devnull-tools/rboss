#                         The MIT License
#
# Copyright (c) 2011 Marcelo Guimarães <ataxexe@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative "jboss_component"

module JBoss

  class ServiceScript
    include Component

    def initialize jboss, logger, config
      @logger = logger
      @jboss = jboss
      @template_path = config.delete :path
      @config = config
      @config[:configuration] = @jboss.profile_name
      @config[:jboss_home] = @jboss.home
    end

    def process
      @logger.info "Configuring service script..."
      processor = create_file_processor
      processor.with @template_path do |action|
        action.to_process do |content|
          [
            :jmx_user,
            :jmx_password,
            :jnp_port,
            :jboss_home,
            :jboss_user,
            :java_path,
            :configuration,
            :bind_address].each do |arg|
            @logger.debug "init script: #{arg} -> #{@config[arg]}"
            content.gsub! /\[#{arg.to_s.upcase}\]/, @config[arg].to_s if @config.has_key? arg
          end
          content
        end
        processor.copy_to @jboss.bin("jboss_init_#{@jboss.profile_name}.sh")
      end
      processor.process
    end

  end
end
