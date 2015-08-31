require "minitest/autorun"
require_relative '../lib/ez7gen/profile_parser'
require_relative '../lib/ez7gen/service/type_aware_field_generator'

class TestTypeAwareFieldGenerator < MiniTest::Unit::TestCase
#parse xml once
@@pp = ProfileParser.new('2.4','ADT_A01')

#helper method
	def lineToHash(line)
		return line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
	end

	def setup
		@tafGen = TypeAwareFieldGenerator.new(@@pp)
	end

	def test_CE
		line = '[max_length:250, description:Role Action Reason, ifrepeating:0, datatype:CE, required:R, piece:8]'
		row= lineToHash(line)
		#puts row
		fld = @tafGen.CE(row)
		assert fld.to_i < 200
		#puts fld
	end

	def test_segment_CE_codetable
	 attrs = []
	 line = '[max_length:250, symbol:*, description:Race, ifrepeating:1, datatype:CE, required:R, piece:10, codetable:5]'
	 row= lineToHash(line)
	 fld = @tafGen.CE(row)
	 assert fld.include?('^')
	 puts fld
	end

	def test_NM
		line =	'[max_length:12, description:Total Charges, ifrepeating:0, datatype:NM, required:R, piece:47]'
		fld = @tafGen.NM(lineToHash(line))
		puts fld
		assert fld.include?('.00')
		assert fld.to_f < 1000

		line =	'[max_length:2, description:Birth Order, ifrepeating:0, datatype:NM, required:R, piece:25]'
		fld = @tafGen.NM(lineToHash(line))
		puts fld
		refute fld.include?('.00')
		assert fld.to_i < 20
  end

  def test_CP
    line ='[max_length:12, description:???, ifrepeating:0, datatype:CP, required:R, piece:13]'
    fld = @tafGen.CP(lineToHash(line))
    puts fld
    assert fld.include?('.00^USD')
	end

  def test_CX
    line ='[max_length:250, symbol:+, description:Patient Identifier List, ifrepeating:1, datatype:CX, required:R, piece:3]'
    fld = @tafGen.CX(lineToHash(line))
		assert /^[-+]?[1-9]([0-9]*)?$/.match(fld) # is a number
    puts fld
	end

	def test_ID
		line ='[max_length:1, description:Separate Bill, ifrepeating:0, datatype:ID, required:R, piece:9, codetable:136]'
		fld = @tafGen.ID(lineToHash(line))
		puts fld
		assert /[Y|N]/.match(fld)
	end

	def test_TS
		line ='[max_length:26, description:Admit Date/Time, ifrepeating:0, datatype:TS, required:R, piece:44]'
		fld_past = @tafGen.TS(lineToHash(line))
		#assert /^[-+]?[1-9]([0-9]*)?$/.match(fld) # is a number
		assert fld_past

		line ='[max_length:26, description:Role End Date/Time, ifrepeating:0, datatype:TS, required:R, piece:44]'
		fld_future = @tafGen.TS(lineToHash(line))
		#assert /^[-+]?[1-9]([0-9]*)?$/.match(fld) # is a number
		assert fld_past < fld_future
	end

	def test_DLD
		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:R, piece:37, codetable:112]'
		fld = @tafGen.DLD(lineToHash(line))
		puts fld
		assert fld.include?('^') #

		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:X, piece:37]'
		fld = @tafGen.DLD(lineToHash(line), true)
		puts fld
		assert fld.include?('^') #
	end

	def test_DLN
		# line =''
		# fld = @tafGen.DLN(lineToHash(line))
	end

	def test_DR
		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:R, piece:37, codetable:112]'
		fld = @tafGen.DR(lineToHash(line))
		puts fld
		assert fld.include?('^') #
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

		map = {'required'=>'O'}
		assert @tafGen.autoGenerate?(map,true) # true or false random

		map = {'required'=>'W'}
		assert @tafGen.autoGenerate?(map,true) # true or false random


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