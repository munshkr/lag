require 'spec_helper'

describe Lug::Logger do
  before do
    @io = StringIO.new
  end

  describe '#initialize' do
    it 'creates a logger with stderr as default IO' do
      logger = Lug::Logger.new
      assert_equal STDERR, logger.io
    end

    it 'accepts an optional +io+ parameter' do
      logger = Lug::Logger.new(@io)
      assert_equal @io, logger.io
    end
  end

  describe '#on' do
    it 'creates a Namespace thats wraps logger with +namespace+' do
      logger = Lug::Logger.new(@io)
      ns = logger.on(:script)

      assert_instance_of Lug::Namespace, ns
      assert_equal logger, ns.logger
      assert_equal 'script', ns.namespace
    end
  end

  describe '#log' do
    before do
      @logger = Lug::Logger.new(@io)
    end

    describe 'without +namespace+' do
      it 'logs message' do
        Timecop.freeze(Time.now) do
          @logger.log('my message')
          assert_equal "#{Time.now} #{$$} my message\n", @io.string
        end
      end

      it 'logs message from block' do
        Timecop.freeze(Time.now) do
          @logger.log { 'my message' }
          assert_equal "#{Time.now} #{$$} my message\n", @io.string
        end
      end

      it 'logs +message+ if not nil, even if a block is given' do
        Timecop.freeze(Time.now) do
          @logger.log('my message') { 'another message' }
          assert_equal "#{Time.now} #{$$} my message\n", @io.string
        end
      end
    end

    describe 'with +namespace+' do
      it 'logs message' do
        Timecop.freeze(Time.now) do
          @logger.log('my message', :main)
          assert_equal "#{Time.now} #{$$} [main] my message\n", @io.string
        end
      end

      it 'logs message from block' do
        Timecop.freeze(Time.now) do
          @logger.log(nil, :main) { 'my message' }
          assert_equal "#{Time.now} #{$$} [main] my message\n", @io.string
        end
      end
    end
  end

  describe '#<<' do
    it 'is an alias of #log' do
      logger = Lug::Logger.new(@io)
      logger.log 'message'
      res_log = @io.string

      @io.truncate(0)

      logger << 'message'
      res = @io.string

      assert_equal res_log, res
    end
  end
end
