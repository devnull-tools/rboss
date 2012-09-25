require 'yummi'

module RBoss
  #
  # A module that holds the builtin formatters
  #
  module Formatters
    
    #
    # A formatter for boolean values. Uses "yes" for a true value
    # and "no" for a false value.
    #
    def self.yes_or_no
      Yummi::Formatters.yes_or_no
    end
    
    #
    # A formatter for byte values. See Yummi::Formatters::byte 
    # documentation for a list of parameters
    #
    def self.byte params = {}
      Yummi::Formatters.byte params
    end
    
    #
    # A formatter for percentual values.
    #
    # Paramters:
    #   The precision to use (defaults to 3)
    #
    def self.percentage precision = 3
      Yummi::to_format do |value|
        "%.#{precision}f%%" % (value * 100)
      end
    end

  end
end
