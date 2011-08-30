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

require "logger"

module JBoss

  # A class that represents the JBoss structure.
  #
  # author Marcelo Guimarães <ataxexe@gmail.com>
  class Path

    attr_reader :profile, :profile_name, :home, :type, :version

    def initialize jboss_home, params = {}
      params = {
        :profile => :custom,
        :type => :undefined,
        version => :undefined
      }.merge params
      @home = jboss_home
      @profile ="#{@home}/server/#{params[:profile]}"
      @profile_name = params[:profile].to_s
      @type = params[:type]
      @version = params[:version]
    end

    def to_s
      @home
    end

    def jboss_logging_lib_path
      %W{#{@home}/client/jboss-logging-spi.jar #{@home}/client/jboss-logging.jar}.each do |path|
        return path if File.exist? path
      end
    end

    def jbosssx_lib_path
      %W{#{@home}/lib/jbosssx.jar #{@home}/common/lib/jbosssx.jar}.each do |path|
        return path if File.exist? path
      end
    end

    # Encrypts the given password using the SecureIdentityLoginModule
    def encrypt password
      encrypted = `java -cp #{jboss_logging_lib_path}:#{jbosssx_lib_path} org.jboss.resource.security.SecureIdentityLoginModule #{password}`
      encrypted.chomp.split(/:/)[1].strip
    end

  end

end
