$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lug'

require 'minitest/autorun'
require 'timecop'

class TtyMockIO < StringIO
  def isatty
    true
  end
end
