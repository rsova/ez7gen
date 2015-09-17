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

	def test_init
		 assert_equal 'Odysseus', @tafGen.yml['person.names.first'][0]
	end

	def test_CE
		line = '[max_length:250, description:Role Action Reason, ifrepeating:0, datatype:CE, required:R, piece:8]'
		row= lineToHash(line)
		#puts row
		fld = @tafGen.CE(row)
		assert fld.to_i < 1000
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
		assert fld.to_i < 1000
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
		puts fld_past
		assert_equal 18, fld_past.size, 'datetime format YYYYMMDDHHSS.SSS, like 20150321201748.373'

		line ='[max_length:26, description:Role End Date/Time, ifrepeating:0, datatype:TS, required:R, piece:44]'
		fld_future = @tafGen.TS(lineToHash(line))
		puts "past timestamp #{fld_past}, future timestamp #{fld_future}"
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
		line ="[max_length:25, description:Driver's License Number - Patient, ifrepeating:0, datatype:DLN, required:O, piece:20]"
		fld = @tafGen.DLN(lineToHash(line),true)
		assert_equal 3, fld.split('^').size
	end

	def test_DR
		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:R, piece:37, codetable:112]'
		fld = @tafGen.DR(lineToHash(line))
		puts fld
		assert fld.include?('^') #
	end

	def test_DT
		line ='[max_length:8, symbol:*, description:Contract Effective Date, ifrepeating:1, datatype:DT, required:O, piece:25]'
		fld = @tafGen.DT(lineToHash(line),true)
		puts fld
		assert_equal 8, fld.size, 'date format yyyymmdd, like 20141228'
	end

	def test_IS
		line ='[max_length:2, description:Interest Code, ifrepeating:0, datatype:IS, required:O, piece:28, codetable:44]'
		fld = @tafGen.IS(lineToHash(line),true)
		assert ['C','K','S','P'].include?(fld)

		line ='[max_length:2, description:Interest Code, ifrepeating:0, datatype:IS, required:O, piece:28]' #, codetable:44]'
		fld = @tafGen.IS(lineToHash(line),true)
		assert fld.to_i <1000
	end

	def test_FC
		line ='[max_length:50, symbol:*, description:Financial Class, ifrepeating:1, datatype:FC, required:O, piece:20, codetable:64]'
		fld = @tafGen.FC(lineToHash(line),true)
		puts fld
    end

	def test_FN
		line ='[required:O, piece:20]'
		fld = @tafGen.FN(lineToHash(line),true)
		assert fld
		puts fld
    end

	def test_HD
		line ='[max_length:180, description:Event Facility, ifrepeating:0, datatype:HD, required:O, piece:7]'
		fld = @tafGen.HD(lineToHash(line),true)
		assert fld
		puts fld
    end

	def test_JSS
		line ='[required:O, piece:20]'
		fld = @tafGen.JSS(lineToHash(line),true)
		assert fld.include?('^')
		puts fld
	end

	def test_OCD
		line ='[required:R, piece:20]'
		fld = @tafGen.OCD(lineToHash(line))
		assert fld.include?('^')
		puts fld
    end

	def test_OSP
		line ='[required:R, piece:20]'
		fld = @tafGen.OSP(lineToHash(line))
		assert fld.include?('^')
		puts fld
    end

    def test_PL
		line ='[max_length:80, description:Assigned Patient Location, ifrepeating:0, datatype:PL, required:O, piece:3]'
		fld = @tafGen.PL(lineToHash(line), true)
		assert fld.include?('^')
		assert_equal 4, fld.split('^').size
		puts fld
    end

    def test_PT
        line ='[datatype:PT, required:O, piece:3]'
        fld = @tafGen.PT(lineToHash(line), true)
        assert fld
        puts fld
    end

    def test_SI
        line ='[max_length:4, symbol:!, description:Set ID - DG1, ifrepeating:0, datatype:SI, required:R, piece:1]'
        fld = @tafGen.SI(lineToHash(line), true)
        assert_equal 4, fld.size
        puts fld
    end

    def test_TN
        line ='[datatype:TN, required:R, piece:1]'
        fld = @tafGen.TN(lineToHash(line), true)
        puts fld
        assert_equal 13, fld.size
    end

    def test_UVC
        line ='[datatype:UVC, required:R, piece:1]'
        fld = @tafGen.UVC(lineToHash(line), true)
        puts fld
        assert fld.include?('^')
    end

    def test_VID
        line ='[datatype:VID, required:R, piece:1]'
        fld = @tafGen.VID(lineToHash(line), true)
        puts fld
        assert fld.to_i < 1000
    end

    def test_XAD
        line ='[max_length:250, symbol:*, description:Patient Address, ifrepeating:1, datatype:XAD, required:O, piece:11]'
        fld = @tafGen.XAD(lineToHash(line), true)
        puts fld
        assert_equal 6, fld.split('^').size
    end

    def test_XCN
        line ='[max_length:250, symbol:*, description:Operator ID, ifrepeating:1, datatype:XCN, required:O, piece:5, codetable:188]'
        fld = @tafGen.XCN(lineToHash(line), true)
        puts fld
        assert_equal 4, fld.split('^').size

       line = '[max_length:250, symbol:*, description:Diagnosing Clinician, ifrepeating:1, datatype:XCN, required:O, piece:16]'
        fld = @tafGen.XCN(lineToHash(line), true)
        puts fld
        assert_equal 4, fld.split('^').size
    end

	def test_XON
		line ='[max_length:250, symbol:*, description:Patient Primary Facility, ifrepeating:1, datatype:XON, required:O, piece:3]'
		fld = @tafGen.XON(lineToHash(line), true)
		puts fld
		assert_equal 3, fld.split('^').size
	end

	def test_XPN
		line ='[max_length:250, symbol:*, description:Patient Alias, ifrepeating:1, datatype:XPN, required:B, piece:9]'
		fld = @tafGen.XPN(lineToHash(line), true)
		puts fld
		assert_equal 3, fld.split('^').size
	end

	def test_XTN
		line ='[max_length:250, symbol:*, description:Phone Number - Business, ifrepeating:1, datatype:XTN, required:O, piece:14]'
		fld = @tafGen.XTN(lineToHash(line), true)
		puts fld
		assert 'Starts with (...)', /(\d{3})/.match(fld)
	#	assert fld.include?/(\d{3}\\)\d{3}-\d{4}/
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

	def test_getCodedValues_range3
		# {"position"=>position='3', "value"=>value='2 ...', "description"=>description='For ranked secondary diagnoses'}
		actual = @tafGen.getCodedValue({'codetable'=>'1','max_length' =>'2'})
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