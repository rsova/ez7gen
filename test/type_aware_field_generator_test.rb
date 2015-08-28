require "minitest/autorun"
require_relative '../lib/ez7gen/profile_parser'
require_relative '../lib/ez7gen/service/type_aware_field_generator'

class TestTypeAwareFieldGenerator < MiniTest::Unit::TestCase
	#parse xml once
	@@pp = ProfileParser.new('2.4','ADT_A01')

	def setup
		@tafGen = TypeAwareFieldGenerator.new(@@pp)
	end

	# def test_init
	# 	assert(@tafGen != nil)
	# end
	def ceTest
		@tafGen.CE([piece])
	end

	def test_autoGenerate
		map = {'required'=>'B'}
		refute (@tafGen.autoGenerate?(map)) # false


		map = {'required'=>'X'}
		refute (@tafGen.autoGenerate?(map)) # false

	    map = {'required'=>'W'}
		refute (@tafGen.autoGenerate?(map)) # false

		map = {'required'=>'R'}
		assert (@tafGen.autoGenerate?(map)) # true

		map = {'required'=>'O'}
		puts @tafGen.autoGenerate?(map) # true or false random

	end


	def test_generateLengthBoundId
		actual = @tafGen.generateLengthBoundId(10, '12345')
		puts actual
		assert_equal('1234500000', actual)
		
		actual = @tafGen.generateLengthBoundId(9)
		puts actual
		assert_equal(9, actual.size)

	end

	def test_getCodedValue_lenViolation
		actual = @tafGen.getCodedValue({'codetable'=>'162','max_length' =>'1'})
		puts actual
	end

	def test_getCodedValue_range1
		actual = @tafGen.getCodedValue({'codetable'=>'112','max_length' =>'2'})
		puts actual
	end

	def test_getCodedValue_range2
		actual = @tafGen.getCodedValue({'codetable'=>'141','max_length' =>'2'})
		puts actual
	end

	def test_getCodedMap_lenViolation
		actual = @tafGen.getCodedMap({'codetable'=>'162','max_length' =>'1'})
		puts actual
	end

	def test_getCodedValue_range1
		actual = @tafGen.getCodedMap({'codetable'=>'112','max_length' =>'2'})
		puts actual
	end

	def test_getCodedValue_range2
		actual = @tafGen.getCodedMap({'codetable'=>'141','max_length' =>'2'})
		puts actual
	end

# 112 141
	def test_applyRules
    actual = @tafGen.getCodedMap({'codetable'=>'141','max_length' =>'2'})

	end

end