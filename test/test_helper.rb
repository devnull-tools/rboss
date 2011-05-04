require 'test/unit'
require_relative '../src/jboss_profile'

include JBoss

module TestHelper

  def jboss_dir
    ENV["JBOSS_DIR"] or File.expand_path "~/jboss"
  end

  def with type, version, base_profile = :all
    map ||= {
      :eap => "#{jboss_dir}/eap/jboss-eap-#{version}/jboss-as",
      :soa_p => "#{jboss_dir}/soa-p/jboss-soa-p-#{version}/jboss-as",
      :org => "#{jboss_dir}/org/jboss-#{version}"
    }

    @jboss_profile = Profile::new map[type],
                                  :type => :eap,
                                  :base_profile => base_profile,
                                  :profile => :rboss
    @jboss = @jboss_profile.jboss
    yield @jboss_profile
    @jboss_profile.create
  end

  def for_assertions
    yield
    @jboss_profile.remove
  end

end

class Test::Unit::TestCase
  include TestHelper
end
