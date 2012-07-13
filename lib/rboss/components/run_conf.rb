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

require 'yaml'
require 'erb'

module RBoss
  # A class to create a custom run.conf file to a JBoss Profile
  #
  # The configuration is based on a erb template, variables and jvm args:
  #
  # :template_path  => an absolute path to the template
  # :template       => the template string
  # :jvm_args       => array with the jvm args to use in JAVA_OPTS, stored in @jvm_args
  # any other key will be stored in a @config variable
  #
  # This class is used as the binding for erb processor.
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class RunConf
    include Component

    def defaults
      {:jvm_args => []}
    end

    def configure config
      @template_path = config.delete :template_path
      @template = config.delete :template
      @jvm_args = config.delete :jvm_args
      @config = config
      parse_config
    end

    def process
      @logger.info "Creating and configuring run.conf"
      if @template_path
        processor = new_file_processor
        processor.with @template_path do |action|
          action.to_process do |content|
            process_template content
          end
          processor.copy_to "#{@jboss.profile}/run.conf"
        end
        processor.process
      else
        File.open("#{@jboss.profile}/run.conf", "w+") { |f| f.write process_template @template }
      end
    end

    private

    def process_template content
      erb = ERB::new(content, 0, "%<>")
      erb.result binding
    end

    def parse_config
      map = load_yaml "run_conf"

      (@config.find_all { |key, value| map.has_key? key.to_s }).each do |key, value|
        @jvm_args << "-D#{map[key.to_s]}=#{value}"
        @config.delete key.to_sym
      end
    end

  end

end
