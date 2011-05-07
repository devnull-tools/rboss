require 'test/unit'
require 'logger'
require 'rexml/document'

require_relative '../src/jboss_profile'
require_relative '../src/file_processor'

include JBoss
include REXML

module TestHelper

  attr_accessor :all

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
    map ||= {
      :eap => "#{jboss_dir}/eap/jboss-eap-#{version}/jboss-as",
      :soa_p => "#{jboss_dir}/soa-p/jboss-soa-p-#{version}/jboss-as",
      :org => "#{jboss_dir}/org/jboss-#{version}"
    }
    @logger = Logger::new STDOUT
    @logger.level = Logger::INFO
    @jboss_profile = Profile::new map[type],
                                  :type => type,
                                  :base_profile => :all,
                                  :profile => :rboss,
                                  :logger => @logger
    @jboss = @jboss_profile.jboss
    blocks[:configure].call @jboss_profile
    @jboss_profile.create
    blocks[:assertion].call @jboss
    #@jboss_profile.remove
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
