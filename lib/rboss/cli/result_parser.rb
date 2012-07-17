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

module RBoss
  module Cli
    module ResultParser

      class Type

        def initialize (name, &block)
          @name = name
          @converter_block = block
        end

        def convert (value)
          @converter_block.call value
        end

      end

      class InvocationFailed < Exception

        def initialize(message)
          super(message)
        end

      end

      STRING = Type::new 'STRING' do |string|
        "\"#{string}\""
      end
      BOOLEAN = Type::new 'BOOLEAN' do |string|
        'true' == string.downcase
      end
      INT = Type::new 'INT' do |string|
        string.to_i
      end
      LONG = Type::new 'LONG' do |string|
        string.to_i
      end
      OBJECT = Type::new 'OBJECT' do |string|
        "\"#{string}\""
      end

      def eval_result(result)
        undefined = nil #prevents error because undefined means nil in result object
        result = result.gsub /(\d+)L/, '\1' #removes the long type mark
        result = eval(result)
        raise InvocationFailed::new(result["failure-description"]) if result["outcome"] == "failed"
        result["result"]
      end

    end
  end
end
