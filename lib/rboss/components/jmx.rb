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

require_relative "component"

module JBoss
  # This class configures the JXM user for a JBoss profile.
  #
  # Configuration:
  #
  # :user => the jxm user (default: 'admin')
  # :password => the jmx user password (default: 'admin')
  # :roles => the roles mapped for the user (default: 'JBossAdmin,HttpInvoker')
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class JMX
    include Component

    def configure config
      @config = config
      @password = config[:password]
      @user = config[:user]
      @roles = config[:roles]
    end

    def defaults
      {
        :user => "admin",
        :password => "admin",
        :roles => "JBossAdmin,HttpInvoker"
      }
    end

    def process
      configure_users
      configure_roles
    end

    def configure_users
      processor = new_file_processor
      processor.with "#{@jboss.profile}/conf/props/#{users_properties_file}" do |action|
        action.to_process do |content, jboss|
          [@user, @password].join '='
        end
      end
      processor.process
    end

    def configure_roles
      processor = new_file_processor
      processor.with "#{@jboss.profile}/conf/props/#{roles_properties_file}" do |action|
        action.to_process do |content, jboss|
          [@user, @roles].join '='
        end
      end
      processor.process
    end

    def users_properties_file
      "jmx-console-users.properties"
    end

    def roles_properties_file
      "jmx-console-roles.properties"
    end

  end

end
