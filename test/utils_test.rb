# require "minitest/autorun"
require 'test/unit'
require_relative "../lib/ez7gen/service/utils"

class UtilsTest < Test::Unit::TestCase
	include Utils
	@@random = Random.new

	# TESTS #
	def setup
	end

	def test_getSegmentName
			p Utils.class_variables
   		assert_equal('PV1', get_segment_name('PV1'))
   		assert_equal('PD1', get_segment_name('[~PD1~]'))
   		assert_equal('AL1', get_segment_name('[~{~AL1~}~]'))
	end

	def test_isNumber
		assert is_number?('2')
		assert !is_number?('A')
		total = 8
		kpr = []
		arr = ['msh','1','a','3','4','b','5','6','c','7']
		req =  arr.select{|it| !is_number?(it)}
		p req
		req.each{|it| kpr[arr.index(it)] = it}
		p kpr
		x = @@random.rand(1...total-req.size)
		p x
		picked =  arr.select{|it| is_number?(it)}.sample(x)
		p picked
		picked.each{|it| kpr[arr.index(it)]= it}
		p kpr
		p kpr.compact
	end

	def test_blank
		assert blank?(nil)
		assert blank?('')
		assert blank?([])
		assert blank?({})
		str = ' '
		assert !blank?(str)
		assert_equal 1, str.size # str has not change
	end

	def test_getTypeByName
		# 1 standard no base: - one parser only, added

		# 2 no base is vaz2.4, base its going to base2.4
		assert_equal 'primary', get_type_by_name('ENV')
		#primary is vaz 2.4
		#base is 2.4
		assert_equal 'base', get_type_by_name('base:ENV')
		assert_nil get_type_by_name(nil)
	end

	def test_numToNil
		assert_equal nil, num_to_nil('5')
		assert_equal 'MSH', num_to_nil('MSH')
	end

	def test_safeLen
		#max_len greater
		reqLen = 3
		map = {:max_length => '10'}
		assert_equal 3, safe_len(map[:max_length], reqLen)

		# no max_len
		map = {}
		assert_equal 3, safe_len(map[:max_length], reqLen)

		#max_len lesser
		map = {:max_length => '1'}
		assert_equal 1, safe_len(map[:max_length], reqLen)

		#max_len not number, safe fail
		map = {:max_length => 'abc'}
		actual = safe_len(map[:max_length], reqLen)
		# puts actual
		assert_equal(0, actual)
	end

	def test_hasSpecialCh
		str = 'Degeneration & necrosis'
		assert has_special_ch?(str)
    str = 'Approved by the PSRO/UR as billed'
    assert_false has_special_ch?(str)
    str = 'Degeneration &amp; necrosis'
    assert has_special_ch?(str)

  end

end