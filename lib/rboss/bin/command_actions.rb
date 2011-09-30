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

module JBoss
  module CommandActions
    class Twiddle

      def initialize invoker
        @twiddle = invoker
      end

      def parse_and_execute commands
        commands.each do |method, args|
        send method, *args
      end

      def native command
        puts @twiddle.execute(command)
      end

      def set id, property, value
        mbean, name = extract id
        puts @twiddle.set :mbean => mbean.to_sym,
                         :name => name,
                         :property => property,
                         :value => value
      end

      def get id, property
        mbean, name = extract id
        puts @twiddle.get :mbean => mbean.to_sym,
                         :name => name,
                         :property => property
      end

      def invoke id, method, *args
        mbean, name = extract id
        puts @twiddle.invoke :mbean => mbean.to_sym,
                            :name => name,
                            :method => method,
                            :args => normalize(args)
      end

      def query id, *args
        mbean, name = extract id
        puts @twiddle.query :mbean => mbean.to_sym,
                           :name => name,
                           :args => normalize(args)
      end

      def info id, *args
        mbean, name = extract id
        puts @twiddle.info :mbean => mbean.to_sym,
                          :name => name,
                          :args => normalize(args)
      end

    end

  end

end
end

