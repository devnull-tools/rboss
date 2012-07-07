require 'yummi'

module JBoss
  module Cli
    module Formatters

      def self.yes_or_no
        Yummi::Formatters.yes_or_no
      end

      def self.byte params
        Yummi::Formatters.byte params
      end

      def self.undefined params = {:return => 'undefined'}
        lambda do |value|
          return params[:return] unless value
          value
        end
      end

    end
  end
end
