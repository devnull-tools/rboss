require 'yummi'

module RBoss

  #
  # A module that holds the colorizers
  #
  module Colorizers

    module_function

    #
    # A colorizer for the types returned by invocations in jboss-cli.
    #
    # Parameter:
    #   The type to use the color
    #
    def type type
      Yummi::to_colorize do |ctx|
        case type
          when RBoss::Cli::ResultParser::STRING then
            :green
          when RBoss::Cli::ResultParser::INT,
            RBoss::Cli::ResultParser::LONG then
            :blue
          when RBoss::Cli::ResultParser::BOOLEAN then
            :magenta
          else
            :cyan
        end
      end
    end

  end
end
