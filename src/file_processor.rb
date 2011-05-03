require "rexml/document"
require "fileutils"
require "ostruct"
require "logger"

class FileProcessor

  def initialize opts = {}
    @logger = opts[:logger]
    @var = opts[:var]
    @logger ||= Logger::new(STDOUT)
    @handlers = {
      :plain => {
        :load => lambda do |file|
          @logger.info "Loading file #{file}"
          File.read(file)
        end,
        :store => lambda do |file, content|
          @logger.info "Saving file #{file}"
          File.open(file, 'w+') { |f| f.write (content) }
        end
      },
      :xml => {
        :load => lambda do |file|
          @logger.info "Parsing file #{file}"
          REXML::Document::new File::new(file)
        end,

        :store => lambda do |file, xml|
          @logger.info "Saving file #{file}"
          content = ''
          xml.write(content, 2)
          File.open(file, 'w+') { |f| f.write content }
        end
      }
    }

    @actions = {}
  end

  def register type, actions
    @handlers[type] = actions
  end

  def with file, type = :plain
    @current_file = file.to_s
    @actions[@current_file] = {}
    to_load &@handlers[type][:load]
    to_store &@handlers[type][:store]
    yield self
  end

  def copy_to file
    @actions[@current_file][:copy] = file.to_s
  end

  def return
    @actions[@current_file][:return] = true
  end

  def to_load &block
    @actions[@current_file][:to_load] = block
  end

  def to_store &block
    @actions[@current_file][:to_store] = block
  end

  def to_process &block
    @actions[@current_file][:to_process] = block
  end

  def process
    @actions.each do |file, action|
      action[:obj] = action[:to_load].call file
      @logger.info "Processing file #{file}"
      action[:obj] = action[:to_process].call(action[:obj], @var) if action[:obj]
      file = action[:copy] if action[:copy]
      return action[:obj] if action[:return]
      action[:to_store].call file, action[:obj]
    end
  end

end
