require "minitest/autorun"
require_relative "../lib/ez7gen/service/utils_class"

class TestUtils < MiniTest::Unit::TestCase
	@@random = Random.new

	# TESTS #
	def setup
	end

	def test_getSegmentName
			p Utils_Class.class_variables
   		assert_equal('PV1', Utils_Class.get_segment_name('PV1'))
   		assert_equal('PD1', Utils_Class.get_segment_name('[~PD1~]'))
   		assert_equal('AL1', Utils_Class.get_segment_name('[~{~AL1~}~]'))
	end

	def test_isNumber
		assert Utils_Class.is_number?('2')
		assert !Utils_Class.is_number?('A')
		total = 8
		kpr = []
		arr = ['msh','1','a','3','4','b','5','6','c','7']
		req =  arr.select{|it| !Utils_Class.is_number?(it)}
		p req
		req.each{|it| kpr[arr.index(it)] = it}
		p kpr
		x = @@random.rand(1...total-req.size)
		p x
		picked =  arr.select{|it| Utils_Class.is_number?(it)}.sample(x)
		p picked
		picked.each{|it| kpr[arr.index(it)]= it}
		p kpr
		p kpr.compact
	end

	def test_isZ
		assert Utils_Class.is_z?('[~ZMH~]')
		assert Utils_Class.is_z?('[~{~ZMH~}~]')
		assert !Utils_Class.is_z?('[~{~AL1~}~]')
		assert !Utils_Class.is_z?('[~{~AZL1~}~]')
	end

	def test_blank
		assert Utils_Class.blank?(nil)
		assert Utils_Class.blank?('')
		assert Utils_Class.blank?([])
		assert Utils_Class.blank?({})
		str = ' '
		assert !Utils_Class.blank?(str)
		assert_equal 1, str.size # str has not change
	end

	def test_getTypeByName
		# 1 standard no base: - one parser only, added

		# 2 no base is vaz2.4, base its going to base2.4
		assert_equal 'primary', Utils_Class.get_type_by_name('ENV')
		#primary is vaz 2.4
		#base is 2.4
		assert_equal 'base', Utils_Class.get_type_by_name('base:ENV')
	end

	def test_numToNil
		assert_equal nil, Utils_Class.num_to_nil('5')
		assert_equal 'MSH', Utils_Class.num_to_nil('MSH')
	end

	def test_safeLen
		#max_len greater
		reqLen = 3
		map = {:max_length => '10'}
		assert_equal 3, Utils_Class.safe_len(map[:max_length], reqLen)

		# no max_len
		map = {}
		assert_equal 3, Utils_Class.safe_len(map[:max_length], reqLen)

		#max_len lesser
		map = {:max_length => '1'}
		assert_equal 1, Utils_Class.safe_len(map[:max_length], reqLen)

		#max_len not number, safe fail
		map = {:max_length => 'abc'}
		actual = Utils_Class.safe_len(map[:max_length], reqLen)
		# puts actual
		assert_equal(0, actual)
	end

end