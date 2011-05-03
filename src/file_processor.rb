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

require "rexml/document"
require "fileutils"
require "ostruct"
require "logger"

class FileProcessor

  def initialize opts = {}
    @logger = opts[:logger]
    @var = opts[:var]
    @logger ||= Logger::new(STDOUT)
    @handlers = {
      :plain => {
        :load => lambda do |file|
          @logger.info "Loading file #{file}"
          File.read(file)
        end,
        :store => lambda do |file, content|
          @logger.info "Saving file #{file}"
          File.open(file, 'w+') { |f| f.write (content) }
        end
      },
      :xml => {
        :load => lambda do |file|
          @logger.info "Parsing file #{file}"
          REXML::Document::new File::new(file)
        end,

        :store => lambda do |file, xml|
          @logger.info "Saving file #{file}"
          content = ''
          xml.write(content, 2)
          File.open(file, 'w+') { |f| f.write content }
        end
      }
    }

    @actions = {}
  end

  def register type, actions
    @handlers[type] = actions
  end

  def with file, type = :plain
    @current_file = file.to_s
    @actions[@current_file] = {}
    to_load &@handlers[type][:load]
    to_store &@handlers[type][:store]
    yield self
  end

  def copy_to file
    @actions[@current_file][:copy] = file.to_s
  end

  def return
    @actions[@current_file][:return] = true
  end

  def to_load &block
    @actions[@current_file][:to_load] = block
  end

  def to_store &block
    @actions[@current_file][:to_store] = block
  end

  def to_process &block
    @actions[@current_file][:to_process] = block
  end

  def process
    @actions.each do |file, action|
      action[:obj] = action[:to_load].call file
      @logger.info "Processing file #{file}"
      action[:obj] = action[:to_process].call(action[:obj], @var) if action[:obj]
      file = action[:copy] if action[:copy]
      return action[:obj] if action[:return]
      action[:to_store].call file, action[:obj]
    end
  end

end
