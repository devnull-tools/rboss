#                         The MIT License
#
# Copyright (c) 2011-2012 Marcelo Guimarães <ataxexe@gmail.com>
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

require_relative "component"

module RBoss

  class ServiceScript
    include Component

    def initialize jboss, logger, config
      @logger = logger
      @jboss = jboss
      @template_path = config.delete :path
      @config = config
      @config[:profile] = @jboss.profile_name
      @config[:jboss_home] = @jboss.home
      @name = @config[:name]
      @name ||= "jboss_init_#{@jboss.profile_name}.sh"
    end

    def process
      @logger.info "Configuring service script..."
      processor = new_file_processor
      processor.with @template_path do |action|
        action.to_process do |content|
          erb = ERB::new(content, 0, "%<>")
          erb.result binding
        end
        processor.copy_to "#{@jboss}/bin/#{@name}"
      end
      processor.process
    end

  end
end
