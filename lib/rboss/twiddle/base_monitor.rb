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

require_relative 'monitor'
require_relative 'twiddle'

module JBoss
  module Twiddle

    class BaseMonitor
      include JBoss::Twiddle::Monitor

      def initialize twiddle
        @twiddle = twiddle
        defaults.each do |mbean_id, config|
          monitor mbean_id, config
        end
      end

    end

    class Invoker

      def monitor
        @monitor ||= BaseMonitor::new self
        @monitor
      end

      def mbean id
        monitor.mbean id
      end

      def get params
        mbean = extract params
        mbean[params[:property]]
      end

      def set params
        mbean = extract params
        mbean[params[:property]] = params[:value]
      end

      def invoke params
        mbean = extract params
        mbean.invoke params[:method], *params[:args]
      end

      def query params
        mbean = extract params
        execute :query, mbean.name, *params[:args]
      end

      def info params
        mbean = extract params
        execute :info, mbean.name, *params[:args]
      end

      private

      def extract params
        mbean = monitor.mbean params[:mbean]
        mbean.with params[:name]
      end

    end

  end

end
