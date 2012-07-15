require 'yummi'

module RBoss
  module Colorizers

    def self.boolean params = {}
      lambda do |value|
        return (params[:if_true] or :green) if value
        params[:if_false] or :brown
      end
    end

    def self.with params
      lambda do |value|
        params[:color]
      end
    end

  end
end
