require 'yummi'

module RBoss
  module HealthCheckers

    def self.percentage params
      PercentageColorizer::new params
    end

    class PercentageColorizer

      def initialize(params)
        @max = params[:max]
        @free = params[:free]
        @using = params[:using]
        @color = params[:color] || {
          :bad => :red,
          :warn => :brown,
          :good => :green
        }
        @threshold = params[:threshold] || {
          :warn => 0.30,
          :bad => 0.15
        }
      end

      def call(data)
        max = data[@max.to_sym].to_f
        free = @using ? max - data[@using.to_sym].to_f : data[@free.to_sym].to_f

        percentage = free / max

        return @color[:bad] if percentage <= @threshold[:bad]
        return @color[:warn] if percentage <= @threshold[:warn]
        @color[:good]
      end

    end

  end
end
