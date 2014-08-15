require 'yummi'

module RBoss
  #
  # A module that holds the formatters
  #
  module Formatters

    def self.date(format = '%d-%m-%Y %H:%M:%S %z')
      Yummi::to_format do |ctx|
        value = ctx.value
        Time.at(value / 1000).strftime(format)
      end
    end

    def self.time
      Yummi::to_format do |ctx|
        value = ctx.value / 1000
        seconds = value % 60
        minutes = (value / 60) % 60
        hours = (value / 60 / 60) % 24
        days = (value / 60 / 60 / 24)
        "#{days}d #{hours}h #{minutes}m #{seconds}s"
      end
    end

    def self.trim(max)
      Yummi::to_format do |ctx|
        value = ctx.value.to_s
        if value.size > max
          value[0..max] << '...'
        else
          value
        end
      end
    end

    def self.array(separator = ', ')
      Yummi::to_format do |ctx|
        ctx.value.join separator
      end
    end

  end
end
