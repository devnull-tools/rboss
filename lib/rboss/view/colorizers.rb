require 'yummi'

module RBoss
  module Colorizers

    def self.boolean params = {}
      Yummi::to_colorize do |value|
        value ? (params[:if_true] or :green) : (params[:if_false] or :brown)
      end
    end

    def self.with color
      Yummi::to_colorize do |value|
        color
      end
    end

  end
end
