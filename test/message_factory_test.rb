require "minitest/autorun"
require_relative "../lib/ez7gen/message_factory"

class TestMessageFactory < MiniTest::Unit::TestCase

  def test_msh
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A01")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end
end