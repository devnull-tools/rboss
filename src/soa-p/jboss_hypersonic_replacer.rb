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

module JBoss

  class HypersonicReplacer

    alias_method :old_process, :process
    alias_method :old_initialize, :initialize


    def initialize jboss, logger, config
      soa_p = config[:soa_p]
      @source_dir = soa_p[:source_dir]
      @db_name = soa_p[:db_name]
      @db_hostname = soa_p[:db_hostname]
      @db_port = soa_p[:db_port]

      old_initialize jboss, logger, config
    end

    def process
      old_process

      # TODO: create a build.properties temp file inside tools/schema based on datasource config
      # and invoke the ant script
      build_properties = <<BUILD_PROPERTIES
org.jboss.esb.server.home=#{@jboss.home}
org.jboss.esb.server.clustered=#{File.exists? "#{@jboss.profile}/farm"}
org.jboss.esb.server.config=#{@jboss.profile_name}

db.username=#{@datasource.attributes[:user]}
db.password=#{@datasource.attributes[:password]}

source.dir=#{@source_dir}

db.name=#{@db_name}
db.hostname=#{@db_hostname}
db.port=#{@db_port}

db.minpoolsize=15
db.maxpoolsize=50
BUILD_PROPERTIES

      # make a backup of build.properties
      invoke "mv #{@jboss.home}/tools/schema/build.properties #{@jboss.home}/tools/schema/build.properties~"

      File.open("#{@jboss.home}/tools/schema/build.properties", 'w+') { |f| f.write build_properties }

      invoke "cd #{@jboss.home}/tools/schema; ant"

      invoke "mv #{@jboss.home}/tools/schema/build.properties~ #{@jboss.home}/tools/schema/build.properties"
    end

  end

end
