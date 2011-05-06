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

require_relative "jboss_component"

module JBoss

  # A class to add resources to a JBoss Profile
  #
  # Any resource can be added using the following structure:
  #
  # absolute_path => [resource_a_path, resource_b_path, ...],
  # relative_path => resource_c_path
  #
  # Relative paths are based on the profile path (example: "lib" is $JBOSS_HOME/server/$JBOSS_PROFILE/lib)
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class Resource
    include Component

    def initialize jboss, logger, resources
      @jboss = jboss
      @logger = logger
      @resources = resources
    end

    def process
      @logger.info "Including resources..." unless @resources.empty?
      @resources.each do |to_path, resources|
        resources = [resources] unless resources.is_a? Array
        resources.each do |resource|
          to_path = "#{@jboss.profile}/#{to_path}" unless to_path.to_s.start_with? '/'
          invoke "cp #{resource} #{to_path}"
        end
      end
    end

  end

end
