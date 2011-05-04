require 'test/unit'
require_relative '../src/jboss_profile'

include JBoss

module TestHelper

  def jboss_dir
    ENV["JBOSS_DIR"] or File.expand_path "~/jboss"
  end

  def create_eap version = "5.1", base_profile = :all
    @jboss_profile = Profile::new "#{jboss_dir}/eap/jboss-eap-#{version}/jboss-as",
                          :type => :eap,
                          :base_profile => base_profile,
                          :profile => :rboss
    @jboss = @jboss_profile.jboss
    if block_given?
      yield @jboss_profile
      @jboss_profile.create
    end
  end

  def assertions
    yield
    @jboss_profile.remove
  end

end

class Test::Unit::TestCase
  include TestHelper
end
