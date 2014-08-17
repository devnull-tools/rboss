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

class String

  # Converter contract. Replaces '-' to '_' and converts do a Symbol.
  def to_key
    self.gsub('-', '_').to_sym
  end

end

class Symbol

  # Converter contract. Returns +self+.
  def to_key
    self
  end

end

class Hash
  def symbolize_keys
    replace(inject({}) do |h, (k, v)|
      v = v.symbolize_keys if v.is_a? Hash
      if v.is_a? Array
        v.each do |e|
          if e.is_a? Hash
            e.symbolize_keys
          end
        end
      end
      k = k.to_sym if k.respond_to? :to_sym
      h[k] = v
      h
    end)
  end
end
