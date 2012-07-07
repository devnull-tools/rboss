require 'yummi'

module JBoss
  module Cli
    module HealthCheckers

      def self.boolean params
        lambda do |value|
          return params[:if_true] if value
          params[:if_false]
        end
      end

    end
  end
end
