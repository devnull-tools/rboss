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

require 'test/unit'
require 'logger'
require 'rexml/document'

require_relative '../lib/rboss'
require_relative '../lib/rboss/file_processor'

include JBoss
include REXML

module TestHelper

  def all
    @all ||= {
      :org => [5.1],
      :eap => [5.1],
      :soa_p => 5
    }
    @all
  end

  def jboss_dir
    ENV["JBOSS_DIR"] or File.expand_path "~/jboss"
  end

  def for_test_with type, version = nil, &block
    @test_blocks ||= {}
    if type == :all
      all.each do |key, value|
        set_block key, value, :configure, block
      end
    else
      set_block type, version, :configure, block
    end
  end

  def for_assertions_with type, version = nil, &block
    @assertion_blocks ||= {}
    if type == :all
      all.each do |key, value|
        set_block key, value, :assertion, block
      end
    else
      set_block type, version, :assertion, block
    end
  end

  def do_test
    @test_blocks.each do |type, versions|
      versions.each do |version, blocks|
        do_test_with type, version, blocks
      end
    end
  end

  def do_test_with type, version, blocks
    map = {
      :eap => "#{jboss_dir}/eap/jboss-eap-#{version}/jboss-as",
      :epp => "#{jboss_dir}/epp/jboss-epp-#{version}/jboss-as",
      :soa_p => "#{jboss_dir}/soa-p/jboss-soa-p-#{version}/jboss-as",
      :org => "#{jboss_dir}/org/jboss-#{version}"
    }
    return unless File.exist? map[type]
    @logger = Logger::new STDOUT
    @logger.level = Logger::WARN
    @jboss_profile = Profile::new :jboss_home => map[type],
                                  :type => type,
                                  :version => version,
                                  :base_profile => :all,
                                  :profile => :rboss,
                                  :logger => @logger
    @jboss = @jboss_profile.jboss
    block = blocks[:configure]
    if block
      block.call @jboss_profile
      puts "Creating #{type} #{version}"
      @jboss_profile.create
      puts "Running assertion block"
      blocks[:assertion].call @jboss
    end
  end

  def create_file_processor
    FileProcessor::new :logger => @logger, :var => @jboss
  end

  private

  def set_block(type, version, key, block)
    @test_blocks[type] ||= {}
    if version.kind_of? Array
      version.each do |v|
        @test_blocks[type][v] ||= {}
        @test_blocks[type][v][key] = block
      end
    else
      @test_blocks[type][version] ||= {}
      @test_blocks[type][version][key] = block
    end
  end

end

class Test::Unit::TestCase
  include TestHelper
end
