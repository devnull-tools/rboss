require 'yummi'

module RBoss
  module Colorizers

    def self.boolean params = {}
      Yummi::to_colorize do |value|
        value ? (params[:if_true] or :green) : (params[:if_false] or :brown)
      end
    end

    def self.threshold params
      colorize = lambda do |value|
        params.sort.reverse_each do |limit, color|
          return color if value > limit
        end
      end
      Yummi::to_colorize &colorize
    end

    def self.type type
      Yummi::to_colorize do |value|
        case type
          when RBoss::Cli::ResultParser::STRING then
            :green
          when RBoss::Cli::ResultParser::INT,
            RBoss::Cli::ResultParser::LONG then
            :blue
          when RBoss::Cli::ResultParser::BOOLEAN then
            :purple
          else
            :cyan
        end
      end
    end

    def self.with color
      Yummi::to_colorize do |value|
        color
      end
    end

  end
end
