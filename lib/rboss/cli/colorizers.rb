require 'yummi'

module JBoss
  module Cli
    module Colorizers

      def self.boolean params
        lambda do |value|
          return params[:if_true] if value
          params[:if_false]
        end
      end

      def self.use params
        lambda do |value|
          params[:color]
        end
      end

    end
  end
end
