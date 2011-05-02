require_relative "file_processor"

class String

  def camelize
    (self.split(/_/).collect { |n| n.capitalize }).join
  end

  def uncapitalize
    self[0, 1].downcase + self[1..-1]
  end

end
