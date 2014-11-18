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

    class InvocationFailed < Exception

      def initialize(message)
        super(message)
      end

    end

    module ResultParser

      class Type

        attr_reader :name

        def initialize (name, &block)
          @name = name
          @converter_block = block
        end

        def convert (value)
          @converter_block.call value
        end

        def to_s
          @name
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
      LIST = Type::new 'LIST'
      OBJECT = Type::new 'OBJECT'

      def eval_result(result)
        # prevents error because undefined means nil in result object
        undefined = nil
        # removes the long type mark
        result = result.gsub(/(\d+)L/, '\1')
        # removes the expression indicator
        result = result.gsub(/expression\s/, '')
        # Check if the operation has failed
        return if result.to_s.start_with? 'Failed'
        # eval the result to a hash
        result = eval(result)
        raise InvocationFailed::new(result['failure-description']) if result['outcome'] == 'failed'
        result['result']
      end

      def format(result, offset = 0)
        str = ''
        mod = (' ' * offset)
        if result.is_a? Hash
          result.each do |key, value|
            str << mod << "#{key.to_s.bold.blue} : #{format value, offset + 2}" << $/
          end
        elsif result.is_a? Array
          result.each do |row|
            str << $/ << mod << "#{format row, offset + 2}"
          end
        else
          str << result.to_s
        end
        str.strip.chomp
      end

    end

  end
end
