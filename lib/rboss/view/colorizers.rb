require 'yummi'

module RBoss

  #
  # A module that holds the builtin colorizers
  #
  module Colorizers

    #
    # A colorizer for boolean values.
    #
    # Parameters:
    #   - if_true: color used if the value is true
    #   - if_false: color used if the value is false
    #
    def self.boolean params = {}
      Yummi::to_colorize do |value|
        value ? (params[:if_true] or :green) : (params[:if_false] or :brown)
      end
    end
    
    #
    # A colorizer that uses a set of minimun values to use a color.
    #
    # Parameters:
    #   - MINIMUN_VALUE: COLOR_TO_USE
    #
    def self.threshold params
      colorizer = lambda do |value|
        params.sort.reverse_each do |limit, color|
          return color if value > limit
        end
      end
      Yummi::to_colorize(&colorizer)
    end
    
    #
    # A colorizer for the types returned by invocations in jboss-cli.
    #
    # Parameter:
    #   The type to use the color
    #
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
    
    #
    # A colorizer that uses the given color.
    #
    def self.with color
      Yummi::to_colorize do |value|
        color
      end
    end

  end
end
