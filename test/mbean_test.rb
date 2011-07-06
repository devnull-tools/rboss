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
require_relative '../lib/rboss'

class MBeanTest < Test::Unit::TestCase

  def twiddle
    twiddle = Object.new
    def twiddle.invoke command, *args
      "#{command} #{args.join " "}".strip
    end
    twiddle
  end

  def test_pattern_with_resource
    mbean = JBoss::MBean::new :pattern => 'query=/#{resource}', :twiddle => twiddle
    mbean.resource= "my_resource"
    assert_equal "get query=/my_resource my_property", mbean[:my_property]
  end

  def test_pattern_without_resource
    mbean = JBoss::MBean::new :pattern => 'query=/resource', :twiddle => twiddle
    assert_equal "get query=/resource my_property", mbean[:my_property]
  end

  def test_invoke
    mbean = JBoss::MBean::new :pattern => 'jboss.system:type=Server', :twiddle => twiddle
    assert_equal "invoke jboss.system:type=Server shutdown", mbean.shutdown
    assert_equal "invoke jboss.system:type=Server traceInstructions true", mbean.traceInstructions(true)
  end

end
