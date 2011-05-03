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

# A simple class to build a path based on method_missing.
#
# Every call to a method will create a path appended to the last one.
# Example:
#   path = FilePathBuilder::new "/home/user"
#   path.download.jboss
#   => /home/user/download/jboss
# Any argument passed will be added as a method call
#
# author: Marcelo Guimarães <ataxexe@gmail.com>
class FilePathBuilder

  def initialize path
    @path = path.to_s
  end

  def method_missing(method_name, *args, &block)
    path = "#{self.to_s}/#{method_name.to_s.gsub(/_/,'-')}"
    unless args.empty?
      path << "/" << args.join("/")
    end
    path = yield path if block_given?
    FilePathBuilder::new path
  end

  def to_s
    @path
  end

  def to_str
    to_s
  end

end
