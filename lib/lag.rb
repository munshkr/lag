# frozen_string_literal: true
require 'lag/version'
require 'lag/colors'
require 'thread'

# Small utility class for logging messages to stderr or other IO device
#
module Lag
  def self.create(namespace = nil, io = STDERR)
    io.isatty ? TtyLogger.new(namespace, io) : Logger.new(namespace, io)
  end

  class Logger
    LEVEL_TEXT = [
      'DEBUG'.freeze,
      'INFO'.freeze,
      'WARN'.freeze,
      'ERROR'.freeze,
      'FATAL'.freeze,
      'UNKNOWN'.freeze
    ].freeze

    attr_reader :io, :namespace

    # Create a logger with an optional +namespace+ and +io+ device as output
    #
    # @param io [IO] output device (default: stderr)
    # @param namespace [String, Symbol] (default: nil)
    #
    def initialize(namespace = nil, io = STDERR)
      @namespace = namespace.to_s if namespace
      @io = io
      @io.sync = true
    end

    # Clone logger with a custom namespace appended
    #
    # @param namespace [String, Symbol]
    # @return [Lag]
    #
    def on(namespace)
      namespace = "#{@namespace}:#{namespace}" if @namespace
      self.class.new(namespace, @io)
    end

    # Log a message to output device
    #
    # If IO device is a TTY, it will print namespaces with different ANSI
    # colors to make them easily distinguishable.
    #
    # @example
    #   lag = Lag.new
    #   lag << 'This is the message'
    #   # => "This is the message"
    #
    # @example logger with namespace
    #   lag = Lag.new(:myapp)
    #   lag << 'This is the message'
    #   # => "myapp This is the message"
    #
    # @param msg [String]
    # @return [NilClass]
    #
    def log(msg = nil, &block)
      log_with_level(nil, msg, &block)
    end
    alias << log

    def debug(msg = nil, &block)
      log_with_level(0, msg, &block)
    end

    def info(msg = nil, &block)
      log_with_level(1, msg, &block)
    end

    def warn(msg = nil, &block)
      log_with_level(2, msg, &block)
    end

    def error(msg = nil, &block)
      log_with_level(3, msg, &block)
    end

    def fatal(msg = nil, &block)
      log_with_level(4, msg, &block)
    end

    def unknown(msg = nil, &block)
      log_with_level(5, msg, &block)
    end

    private

    def log_with_level(level = nil, message = nil)
      message ||= yield if block_given?
      @io.puts(build_line(message, level, Time.now))
      nil
    end

    def build_line(message, level, now)
      res = []
      res << now
      res << "[#{@namespace}]" if @namespace
      res << LEVEL_TEXT[level] if level
      res << message
      res.join(' '.freeze)
    end
  end

  class TtyLogger < Logger
    MSG_COLOR = Colors::WHITE

    NS_COLORS = [
      Colors::LIGHT_CYAN,
      Colors::LIGHT_GREEN,
      Colors::LIGHT_YELLOW,
      Colors::LIGHT_BLUE,
      Colors::LIGHT_MAGENTA,
      Colors::LIGHT_CYAN,
      Colors::LIGHT_RED,
      Colors::CYAN,
      Colors::GREEN,
      Colors::YELLOW,
      Colors::BLUE,
      Colors::MAGENTA,
      Colors::CYAN,
      Colors::RED
    ].freeze

    LEVEL_COLOR = [
      Colors::CYAN,
      Colors::GREEN,
      Colors::YELLOW,
      Colors::RED,
      Colors::LIGHT_RED,
      Colors::MAGENTA
    ].freeze

    @@mutex = Mutex.new
    @@colors_map = {}
    @@prev_time = nil

    # Create a logger with an optional +namespace+ and +io+ device as output
    #
    # @param io [IO] output device (default: stderr)
    # @param namespace [String, Symbol] (default: nil)
    #
    def initialize(namespace = nil, io = STDERR)
      super(namespace, io)
      @namespace_color = choose_color(@namespace) if @namespace
    end

    private

    def log_with_level(level = nil, message = nil)
      message ||= yield if block_given?

      @@mutex.synchronize do
        now = Time.now
        @io.puts(build_line(message, level, now))
        @@prev_time = now
      end

      nil
    end

    def build_line(message, level, now)
      res = []
      res << colorized(@namespace, @namespace_color) if @namespace
      res << colorized(LEVEL_TEXT[level], LEVEL_COLOR[level]) if level
      res << colorized(message, MSG_COLOR)
      res << elapsed(now)
      res.join(' '.freeze)
    end

    def colorized(string, color)
      "\e[#{color}m#{string}\e[0m"
    end

    def choose_color(namespace)
      @@mutex.synchronize do
        idx = @@colors_map.size % NS_COLORS.size
        @@colors_map[namespace] ||= NS_COLORS[idx]
      end
    end

    def elapsed(now)
      return '+0ms'.freeze unless @@prev_time
      secs = now - @@prev_time
      if secs >= 60
        "+#{(secs / 60).to_i}m"
      elsif secs >= 1
        "+#{secs.to_i}s"
      else
        "+#{(secs * 1000).to_i}ms"
      end
    end
  end
end
