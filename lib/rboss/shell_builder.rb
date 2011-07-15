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

require_relative 'twiddle'

require 'erb'

module JBoss
  module Twiddle
    module Monitor
      class ShellBuilder

        attr_reader :monitor, :twiddle, :opts

        def initialize monitor, params = {}
          @opts = {
            :sleep_time => 10,
            :template_path => File.join(File.dirname(__FILE__), "resources", "monitor.template.sh.erb"),
            :twiddle_command_var => "TWIDDLE_CMD"
          }.merge! params
          @monitor = monitor
          @twiddle = monitor.twiddle
          @twiddle.command = "$#{@opts[:twiddle_command_var]}"
          # return the shell command instead of executing it
          def @twiddle.execute shell
            shell
          end

          @template = @opts[:template] if @opts.has_key? :template
          @template ||= File.read @opts[:template_path]
        end

        def result
          erb = ERB::new(@template, 0, "%<>")
          erb.result binding
        end

      end
    end
  end
end
