require 'test/unit'
require_relative '../src/jboss_profile'
require 'logger'

include JBoss

module TestHelper

  def jboss_dir
    ENV["JBOSS_DIR"] or File.expand_path "~/jboss"
  end

  def for_test &block
    @test_block = block
  end

  def do_test_with_all
    do_test_with :org, "5.1.0.GA"
    do_test_with :eap, "5.1"
    do_test_with :eap, "5.0"
    do_test_with :soa_p, 5
    do_test_with :soa_p, "5.0.0"
  end

  def do_test_with type, version, base_profile = :all
    with type, version, base_profile, &@test_block
  end

  def with type, version, base_profile
    map ||= {
      :eap => "#{jboss_dir}/eap/jboss-eap-#{version}/jboss-as",
      :soa_p => "#{jboss_dir}/soa-p/jboss-soa-p-#{version}/jboss-as",
      :org => "#{jboss_dir}/org/jboss-#{version}"
    }
    logger = Logger::new STDOUT
    logger.level = Logger::INFO
    @jboss_profile = Profile::new map[type],
                                  :type => type,
                                  :base_profile => base_profile,
                                  :profile => :rboss,
                                  :logger => logger
    @jboss = @jboss_profile.jboss
    yield @jboss, @jboss_profile
  end

  def for_assertions type = nil, version = nil
    if type
      return if @jboss.type != type
      if version
        return if @jboss.version != version
      end
    end
    @jboss_profile.create
    yield
    @jboss_profile.remove
  end

end

class Test::Unit::TestCase
  include TestHelper
end
