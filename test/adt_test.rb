# require "minitest/autorun"
require 'test/unit'
require_relative '../lib/ez7gen/message_factory'

# .*_.*
#def test_$& \n msg = '$&'\n fail('Not implemented')\nend \n
class AdtTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @factory = MessageFactory.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @factory = nil
  end


def test_ADT_A01
  msg = 'ADT_A01'
  hl7 = @factory.generate("2.4", msg)
  puts hl7
end

def test_ADT_A02
  msg = 'ADT_A02'
  hl7 = @factory.generate("2.4", msg)
  puts hl7
end

# def test_ADT_A03
#   msg = 'ADT_A03'
#   fail('Not implemented')
# end
#
# def test_ADT_A05
#   msg = 'ADT_A05'
#   fail('Not implemented')
# end
#
# def test_ADT_A06
#   msg = 'ADT_A06'
#   fail('Not implemented')
# end
#
# def test_ADT_A09
#   msg = 'ADT_A09'
#   fail('Not implemented')
# end
#
# def test_ADT_A15
#   msg = 'ADT_A15'
#   fail('Not implemented')
# end
#
# def test_ADT_A16
#   msg = 'ADT_A16'
#   fail('Not implemented')
# end
#
# def test_ADT_A17
#   msg = 'ADT_A17'
#   fail('Not implemented')
# end
#
# def test_ADT_A18
#   msg = 'ADT_A18'
#   fail('Not implemented')
# end
#
# def test_ADT_A20
#   msg = 'ADT_A20'
#   fail('Not implemented')
# end
#
# def test_ADT_A21
#   msg = 'ADT_A21'
#   fail('Not implemented')
# end
#
# def test_ADT_A24
#   msg = 'ADT_A24'
#   fail('Not implemented')
# end
#
# def test_ADT_A30
#   msg = 'ADT_A30'
#   fail('Not implemented')
# end
#
# def test_ADT_A37
#   msg = 'ADT_A37'
#   fail('Not implemented')
# end
#
# def test_ADT_A38
#   msg = 'ADT_A38'
#   fail('Not implemented')
# end
#
# def test_ADT_A39
#   msg = 'ADT_A39'
#   fail('Not implemented')
# end
#
# def test_ADT_A43
#   msg = 'ADT_A43'
#   fail('Not implemented')
# end
#
# def test_ADT_A45
#   msg = 'ADT_A45'
#   fail('Not implemented')
# end
#
# def test_ADT_A50
#   msg = 'ADT_A50'
#   fail('Not implemented')
# end
#
# def test_ADT_A52
#   msg = 'ADT_A52'
#   fail('Not implemented')
# end
#
# def test_ADT_A54
#   msg = 'ADT_A54'
#   fail('Not implemented')
# end
#
# def test_ADT_A60
#   msg = 'ADT_A60'
#   fail('Not implemented')
# end
#
# def test_ADT_A61
#   msg = 'ADT_A61'
#   fail('Not implemented')
# end
#
# def test_QBP_Q21
#   msg = 'QBP_Q21'
#   fail('Not implemented')
# end
#
# def test_RSP_K21
#   msg = 'RSP_K21'
#   fail('Not implemented')
# end
#
# def test_RSP_K22
#   msg = 'RSP_K22'
#   fail('Not implemented')
# end
#
# def test_RSP_K23
#   msg = 'RSP_K23'
#   fail('Not implemented')
# end
#
# def test_RSP_K24
#   msg = 'RSP_K24'
#   fail('Not implemented')
# end

end