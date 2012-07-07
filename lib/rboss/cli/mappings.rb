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

module JBoss
  module Cli
    module Mappings

      def resource_mappings
        @resource_mappings ||= {}
        load_default_resources if @resource_mappings.empty?
        @resource_mappings
      end

      def load_resource(file)
        name = File.basename(file, '.yaml').gsub('_', '-')
        mapping = YAML::load_file(file).symbolize_keys
        @resource_mappings[name.to_sym] = mapping
      end

      def load_resources(dir)
        resource_files = Dir.entries(dir).find_all { |f| f.end_with?('.yaml') }
        resource_files.each do |file|
          load_resource File.join(dir, file)
        end
      end

      def load_default_resources
        load_resources File.join(File.dirname(__FILE__), 'mappings/resources')
      end

      module_function :load_resources, :load_resource, :resource_mappings, :load_default_resources

    end

  end
end
