require "minitest/autorun"
require_relative "../lib/ez7gen/service/utils"

class TestProfileParser < MiniTest::Unit::TestCase
	@@random = Random.new

	def test_getSegmentName
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

end