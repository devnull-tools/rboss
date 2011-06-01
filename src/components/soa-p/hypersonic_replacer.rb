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

require 'fileutils'

module JBoss

  # A class to replace Hypersonic in SOA-P. This class makes a build.properties file
  # and calls the ant script present in $JBOSS_HOME/tools/schema/build.xml since this
  # script does everything we need to replace Hypersonic.
  #
  # The configuration must be in a form key => value and the keys needs to be
  # in the $JBOSS_HOME/tools/schema/build.properties file.
  #
  # The ant script minimal keys are:
  #   - db.name
  #   - db.hostname
  #   - db.port
  #   - db.username
  #   - db.password
  #   - source.dir (the directory in $JBOSS_HOME/tools/schema/ that matches the database type)
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class HypersonicReplacer
    include FileUtils

    def defaults
      {
        "org.jboss.esb.server.home" => "#{@jboss.home}",
        "org.jboss.esb.server.clustered" => "#{File.exists? "#{@jboss.profile}/farm"}",
        "org.jboss.esb.server.config" => "#{@jboss.profile_name}",

        "db.minpoolsize" => 15,
        "db.maxpoolsize" => 50
      }
    end

    def process
      properties = @config.collect { |key, value| "#{key} = #{value}" }

      # make a backup of build.properties
      mv "#{@jboss.home}/tools/schema/build.properties", "#{@jboss.home}/tools/schema/build.properties~"

      File.open("#{@jboss.home}/tools/schema/build.properties", 'w+') { |f| f.write properties.join("\n") }

      cd "#{@jboss.home}/tools/schema" do
        @logger.info "Executing ant..."
        `ant`
      end

      mv "#{@jboss.home}/tools/schema/build.properties~", "#{@jboss.home}/tools/schema/build.properties"
    end

  end

end
