require 'yummi'

module RBoss
  module Formatters

    def self.yes_or_no
      Yummi::Formatters.yes_or_no
    end

    def self.byte params = {}
      Yummi::Formatters.byte params
    end

  end
end
