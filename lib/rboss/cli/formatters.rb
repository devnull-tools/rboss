
require 'yummi'

module JBoss
  module Cli
    module Formatters

      def self.yes_or_no
        Yummi::Formatters.yes_or_no
      end

      def self.byte
        Yummi::Formatters.byte
      end

    end
  end
end
