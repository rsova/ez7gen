require "minitest/autorun"
require_relative "../lib/service/Utils"

class TestProfileParser < MiniTest::Unit::TestCase


def test_getSegmentName
   		assert_equal('PV1', Utils.getSegmentName('PV1'))
   		assert_equal('PD1', Utils.getSegmentName('[~PD1~]'))
   		assert_equal('AL1', Utils.getSegmentName('[~{~AL1~}~]'))
   		asser
  end

end