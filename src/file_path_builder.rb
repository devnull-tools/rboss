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
