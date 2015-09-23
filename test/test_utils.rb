require "minitest/autorun"
require_relative "../lib/ez7gen/service/utils"

class TestUtils < MiniTest::Unit::TestCase
	@@random = Random.new

	# TESTS #
	def setup
	end

	def test_getSegmentName
			p Utils.class_variables
   		assert_equal('PV1', Utils.getSegmentName('PV1'))
   		assert_equal('PD1', Utils.getSegmentName('[~PD1~]'))
   		assert_equal('AL1', Utils.getSegmentName('[~{~AL1~}~]'))
	end

	def test_isNumber
		assert Utils.isNumber?('2')
		assert !Utils.isNumber?('A')
		total = 8
		kpr = []
		arr = ['msh','1','a','3','4','b','5','6','c','7']
		req =  arr.select{|it| !Utils.isNumber?(it)}
		p req
		req.each{|it| kpr[arr.index(it)] = it}
		p kpr
		x = @@random.rand(1...total-req.size)
		p x
		picked =  arr.select{|it| Utils.isNumber?(it)}.sample(x)
		p picked
		picked.each{|it| kpr[arr.index(it)]= it}
		p kpr
		p kpr.compact
	end

	def test_isZ
		assert Utils.isZ?('[~ZMH~]')
		assert Utils.isZ?('[~{~ZMH~}~]')
		assert !Utils.isZ?('[~{~AL1~}~]')
		assert !Utils.isZ?('[~{~AZL1~}~]')
	end

	def test_blank
		assert Utils.blank?(nil)
		assert Utils.blank?('')
		assert Utils.blank?([])
		assert Utils.blank?({})
		str = ' '
		assert Utils.blank?(str)
		assert_equal 1, str.size # str has not change
	end

end