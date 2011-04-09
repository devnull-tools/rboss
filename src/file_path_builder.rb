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
