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

require_relative "../file_processor"
require_relative "../jboss_path"
require_relative "../utils"

require 'yaml'

module JBoss

  # A base helper module for JBoss Components
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  module Component

    def initialize jboss, logger, config
      @jboss = jboss
      @logger = logger
      config = defaults.merge! config if self.respond_to? :defaults
      configure(config)
    end

    def configure config
      @config = config
    end

    # Creates a FileProcessor using the same logger and
    # jboss path as the variable
    def new_file_processor
      FileProcessor::new :logger => @logger, :var => @jboss
    end

    def load_yaml resource
      YAML::load_file File::join(File.dirname(__FILE__), "#{resource}.yaml")
    end

  end
end
