require 'test/unit'
require_relative '../src/jboss_profile'

include JBoss

module TestHelper

  def jboss_dir
    ENV["JBOSS_DIR"] or File.expand_path "~/jboss"
  end

  def for_test &block
    @test_block = block
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

    @jboss_profile = Profile::new map[type],
                                  :type => type,
                                  :base_profile => base_profile,
                                  :profile => :rboss
    @jboss = @jboss_profile.jboss
    yield @jboss_profile
  end

  def for_assertions
    @jboss_profile.create
    yield
    @jboss_profile.remove
  end

end

class Test::Unit::TestCase
  include TestHelper
end
