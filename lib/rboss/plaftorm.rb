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


module RBoss

  if RUBY_PLATFORM['mingw'] #Windows
    module Platform
      def twiddle
        "#@jboss_home/bin/twiddle.bat"
      end

      def jboss_cli
        "#@jboss_home/bin/jboss-cli.bat"
      end

      def run_conf_template
        "#{@base_dir}/resources/run.conf.bat.erb"
      end

      def run_conf
        "#{@jboss.profile}/run.conf"
      end
    end
  else
    module Platform
      def twiddle
        "#@jboss_home/bin/twiddle.sh"
      end

      def jboss_cli
        "#@jboss_home/bin/jboss-cli.sh"
      end

      def run_conf_template
        "#{@base_dir}/resources/run.conf.erb"
      end

      def run_conf
        "#{@jboss.profile}/run.conf"
      end
    end
  end

end
