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

require_relative "component"

require 'yaml'

module JBoss
  # A class to create a custom run.conf file to a JBoss Profile
  #
  # The configuration
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class RunConf
    include Component

    def configure config
      @template_path = config[:template_path]
      @template = config[:template]
      @config = {:jvm_args => []}.merge! config
      @args = @config[:jvm_args]
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
        File.open("#{@jboss.profile}/run.conf", "w+") {|f| f.write process_template @template}
      end
    end

    private

    def process_template content
      @config.each do |arg, value|
        @logger.debug "template: #{arg} -> #{value}"
        content.gsub! /\[#{arg.to_s.upcase}\]/, value.to_s
      end
      buff = @args.join " "
      unless buff.empty?
        @logger.debug "jvm arg: #{buff}"
        content << "\nJAVA_OPTS=\"$JAVA_OPTS #{buff}\""
      end
      content
    end

    def parse_config
      map = YAML::load File.open(File::join(File.dirname(__FILE__), "run_conf.yaml"))

      (@config.find_all { |key, value| map.has_key? key }).each do |key, value|
        @args << "-D#{map[key]}=#{value}"
        @config.delete key
      end
    end

  end

end
