require "minitest/autorun"
require_relative '../lib/ez7gen/profile_parser'
require_relative '../lib/ez7gen/service/type_aware_field_generator'

class TestTypeAwareFieldGenerator < MiniTest::Unit::TestCase
#parse xml once
@@pp = ProfileParser.new('2.4','ADT_A01')

#helper method
	def lineToHash(line)
		hash = line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
		return Hash[hash.map{|(k,v)| [k.to_sym,v]}]

	end

	def setup
		@fldGenerator = TypeAwareFieldGenerator.new(@@pp)
	end

	def test_init
		 assert_equal 'Odysseus', @fldGenerator.yml['person.names.first'][0]
	end

	def test_CE
    # IAM.3 ‘Allergen Code/Mnemonic/Description’ with the ICD 10 Allergy Reaction Codes from the properties file.
    # However, it needs to be populated with the ICD 10 Allergen Codes from the properties file (e.g. T78.40XA Allergy, unspecified, initial encounter)
    line = '[piece:3, description:Allergen Code/Mnemonic/Description, datatype:CE, symbol:!, max_length:250, required:R, ifrepeating:0]'
    row= lineToHash(line)
    fld = @fldGenerator.CE(row)
    puts fld
    icd10s =
    ['T78.40XA^Allergy unspecified initial encounter',
    'T78.40XD^Allergy unspecified subsequent encounter',
    'Z91.048^Other nonmedicinal substance allergy status',
    'Z91.09^Other allergy status, other than to drugs and biological substances',
    'Z91.013^Allergy to seafood',
    'Z91.010^Allergy to peanuts',
    'Z88.0^Allergy status to penicillin',
    'Z91.038^Other insect allergy status',
    'Z91.030^Bee Allergy status']

    assert_includes(icd10s, fld) # conditional should skip on auto generate


    # PID.35 – PID.38 should be always blank, as they deal with animals, not humans.
    line = '[max_length:250, symbol:?, description:Species Code, ifrepeating:0, datatype:CE, required:C, piece:35, codetable:446]'
    row= lineToHash(line)
    fld = @fldGenerator.CE(row)
    puts fld
    assert_equal('',fld) # conditional should skip on auto generate

    line = '[[max_length:250, symbol:?, description:Breed Code, ifrepeating:0, datatype:CE, required:C, piece:36, codetable:447]'
    row= lineToHash(line)
    fld = @fldGenerator.CE(row)
    puts fld
    assert_equal('',fld) # conditional should skip on auto generate

		line = '[max_length:250, description:Production Class Code, ifrepeating:0, datatype:CE, required:O, piece:38, codetable:429]'
    row= lineToHash(line)
    fld = @fldGenerator.CE(row, true)
    puts fld
    assert_equal('',fld) # conditional should skip on auto generate

		line = '[max_length:250, description:Role Action Reason, ifrepeating:0, datatype:CE, required:R, piece:8]'
		row= lineToHash(line)
		#puts row
		fld = @fldGenerator.CE(row)
		assert fld.to_i < 1000
		#puts fld
	end

	def test_CNN
		line = '[required:R, piece:8]'
		row= lineToHash(line)
		fld = @fldGenerator.CNN(row)
		puts fld
	end

	def test_segment_CE_codetable
	 attrs = []
	 line = '[max_length:250, symbol:*, description:Race, ifrepeating:1, datatype:CE, required:R, piece:10, codetable:5]'
	 row= lineToHash(line)
	 fld = @fldGenerator.CE(row)
	 assert fld.include?('^')
	 puts fld
	end

	def test_NM
		# Field size restriction exceeded in segment 8:
		# PV2. Field 20, repetition 1 is larger than segment structure 2.4:
		# PV2 permits it to be. (alert request ID=9)
# '<SegmentSubStructure piece='20' description='Expected Number of Insurance Plans' datatype='NM' max_length='1' required='O' ifrepeating='0' />'		line ='[max_length:4, symbol:!, description:Set ID - DG1, ifrepeating:0, datatype:SI, required:R, piece:1]'
		line = '[piece:20, description:Expected Number of Insurance Plans, datatype=:NM, max_length:1,required:O, ifrepeating:0]'
		fld = @fldGenerator.NM(lineToHash(line), true)
		puts fld
		assert_equal 1, fld.size

		line =	'[max_length:12, description:Total Charges, ifrepeating:0, datatype:NM, required:R, piece:47]'
		fld = @fldGenerator.NM(lineToHash(line))
		puts fld
		assert fld.include?('.00')
		assert fld.to_f < 1000

		line =	'[max_length:2, description:Birth Order, ifrepeating:0, datatype:NM, required:R, piece:25]'
		fld = @fldGenerator.NM(lineToHash(line))
		puts fld
		assert fld.to_i < 10
  end

  def test_CP
    line ='[max_length:12, description:???, ifrepeating:0, datatype:CP, required:R, piece:13]'
    fld = @fldGenerator.CP(lineToHash(line))
    puts fld
    assert fld.include?('.00')

		line = '[piece:27, description:Guarantor Household Annual Income, datatype:CP, max_length:10, required:O, ifrepeating:0]'
		fld = @fldGenerator.CP(lineToHash(line),true)
		puts fld
		assert fld.include?('.00')

	end

  def test_CX
    line = '[max_length:250, description:Alternate Visit ID, ifrepeating:0, datatype:CX, required:O, piece:50, codetable:203]'
    fld = @fldGenerator.CX(lineToHash(line),true)
    puts fld

    line ='[max_length:250, symbol:+, description:Patient Identifier List, ifrepeating:1, datatype:CX, required:R, piece:3]'
    fld = @fldGenerator.CX(lineToHash(line))
    assert /^[-+]?[1-9]([0-9]*)?$/.match(fld) # is a number
    puts fld
	end

  def test_ELD
    line ='[max_length:250, symbol:+, description:Mockup, datatype:ELD, required:R, piece:3]'
    fld = @fldGenerator.ELD(lineToHash(line))
		# assert /^[-+]?[1-9]([0-9]*)?$/.match(fld) # is a number
    puts fld
	end

	def test_ID
		line ='[max_length:1, description:Separate Bill, ifrepeating:0, datatype:ID, required:R, piece:9, codetable:136]'
		fld = @fldGenerator.ID(lineToHash(line))
		puts fld
		assert /[Y|N]/.match(fld)
	end

	def test_TS

		#The field IAM.13 ‘Reported Date/Time’ needs to be just the date  - 8 characters long
		line = '[max_length:8, description:Reported Date/Time, ifrepeating:0, datatype:TS, required:R, piece:13]'
    # <SegmentSubStructure piece='13' description='Reported Date/Time' datatype='TS' max_length='8' required='O' ifrepeating='0' />
		fld = @fldGenerator.TS(lineToHash(line))
		puts fld
		assert_equal 8, fld.size

    # PID.7 Date of Birth – please make the date within 50-20 years into the past.
    line = '[max_length:26, description:Date/Time Of Birth, ifrepeating:0, datatype:TS, required:R, piece:7]'
    fld = @fldGenerator.TS(lineToHash(line))
    puts fld
		assert_equal 18, fld.size

		line ='[max_length:26, description:Admit Date/Time, ifrepeating:0, datatype:TS, required:R, piece:44]'
		fld_past = @fldGenerator.TS(lineToHash(line))
		puts fld_past
		assert_equal 18, fld_past.size, 'datetime format YYYYMMDDHHSS.SSS, like 20150321201748.373'

		line ='[max_length:26, description:Role End Date/Time, ifrepeating:0, datatype:TS, required:R, piece:44]'
		fld_future = @fldGenerator.TS(lineToHash(line))
		puts "past timestamp #{fld_past}, future timestamp #{fld_future}"
		assert fld_past < fld_future
	end

	def test_DLD
		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:R, piece:37, codetable:112]'
		fld = @fldGenerator.DLD(lineToHash(line))
		puts fld
		assert fld.include?('^') #

		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:X, piece:37]'
		fld = @fldGenerator.DLD(lineToHash(line), true)
		puts fld
		assert fld.include?('^') #
	end

	def test_DLN
		line ="[max_length:25, description:Driver's License Number - Patient, ifrepeating:0, datatype:DLN, required:O, piece:20]"
		fld = @fldGenerator.DLN(lineToHash(line),true)
		puts fld
		assert_equal 3, fld.split('^').size
	end

	def test_DR
		line ='[max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:R, piece:37, codetable:112]'
		fld = @fldGenerator.DR(lineToHash(line))
		puts fld
		assert fld.include?('^') #
	end

	def test_DT
		line ='[max_length:8, symbol:*, description:Contract Effective Date, ifrepeating:1, datatype:DT, required:O, piece:25]'
		fld = @fldGenerator.DT(lineToHash(line),true)
		puts fld
		assert_equal 8, fld.size, 'date format yyyymmdd, like 20141228'
	end

	def test_IS
    # PD1.20 has a value of 27. The value is supposed to come from table 141 (this was the error picked by Ensemble):
    line ='[max_length:2, description:Military Rank/Grade, ifrepeating:0, datatype:IS, required:O, piece:20, codetable:141]'
    fld = @fldGenerator.IS(lineToHash(line),true)
    puts fld

    line ='[max_length:2, description:Interest Code, ifrepeating:0, datatype:IS, required:O, piece:28, codetable:44]'
		fld = @fldGenerator.IS(lineToHash(line),true)
		assert ['C','K','S','P'].include?(fld)

		line ='[max_length:2, description:Interest Code, ifrepeating:0, datatype:IS, required:O, piece:28]' #, codetable:44]'
		fld = @fldGenerator.IS(lineToHash(line),true)
		assert fld.to_i <1000
	end

	def test_FC
		line ='[max_length:50, symbol:*, description:Financial Class, ifrepeating:1, datatype:FC, required:O, piece:20, codetable:64]'
		fld = @fldGenerator.FC(lineToHash(line),true)
		puts fld
    end

	def test_FN
		line ='[required:O, piece:20]'
		fld = @fldGenerator.FN(lineToHash(line),true)
		assert fld
		puts fld
    end

	def test_HD
		line ='[max_length:180, description:Event Facility, ifrepeating:0, datatype:HD, required:O, piece:7]'
		fld = @fldGenerator.HD(lineToHash(line),true)
		assert fld
		puts fld
    end

	def test_JCC
		line ='[required:O, piece:20]'
		fld = @fldGenerator.JCC(lineToHash(line),true)
		assert fld.include?('^')
		puts fld
	end

	def test_LA1
		line ='[required:R, piece:1]'
		fld = @fldGenerator.LA1(lineToHash(line))
		assert fld.include?('^')
		puts fld
	end

	def test_LA2
		line ='[required:R, piece:1]'
		fld = @fldGenerator.LA2(lineToHash(line))
		assert fld.include?('^')
		puts fld
	end

	def test_MOP
		line ='[required:R, piece:1]'
		fld = @fldGenerator.MOP(lineToHash(line))
		assert fld.include?('^')
		puts fld
  end

	def test_MSG
		line ='[required:R, piece:1]'
		fld = @fldGenerator.MSG(lineToHash(line))
		assert fld.include?('^')
		puts fld
	end

	def test_OCD
		line ='[required:R, piece:20]'
		fld = @fldGenerator.OCD(lineToHash(line))
		assert fld.include?('^')
		puts fld
    end

	def test_OSP
		line ='[required:R, piece:20]'
		fld = @fldGenerator.OSP(lineToHash(line))
		assert fld.include?('^')
		puts fld
  end

	def test_PI
		line ='[required:R, piece:20]'
		fld = @fldGenerator.PI(lineToHash(line))
		puts fld
	end

	def test_PL
		line ='[max_length:80, description:Assigned Patient Location, ifrepeating:0, datatype:PL, required:O, piece:3]'
		fld = @fldGenerator.PL(lineToHash(line), true)
		assert fld.include?('^')
    puts fld
    assert_equal 7, fld.split('^').size
	end

	def test_PT
		line ='[datatype:PT, required:O, piece:3]'
		fld = @fldGenerator.PT(lineToHash(line), true)
		assert fld
		puts fld
	end


	def test_SI
			line ='[max_length:4, symbol:!, description:Set ID - DG1, ifrepeating:0, datatype:SI, required:R, piece:1]'
			fld = @fldGenerator.SI(lineToHash(line), true)
			assert_equal 4, fld.size
			puts fld
	end

	def test_ST
		#ZEL.29 should be 1 digit integer.
		# line = '[piece:29, description:AGENT ORANGE EXPOSURE LOCATION,  datatype=base:ST, max_length:1, required=O , ifrepeating:0]'
		line = '[piece:29, description:AGENT ORANGE EXPOSURE LOCATION,  datatype:base:ST, max_length:1, required=O , ifrepeating:0]'
		fld = @fldGenerator.ST(lineToHash(line), true)
		puts fld
		assert_equal(1,fld.size)

		#PID.35 – PID.38 should be always blank, as they deal with animals, not humans.
    line ='[max_length:80, description:Strain, ifrepeating:0, datatype:ST, required:O, piece:37]'
    fld = @fldGenerator.ST(lineToHash(line), true)
    puts fld
    assert_equal(nil,fld)

    fld = @fldGenerator.ST({}, true)
    puts fld

    line ='[max_length:15, symbol:*, description:Allergy Reaction Code, ifrepeating:1, datatype:ST, required:O, piece:5]'
    fld = @fldGenerator.ST(lineToHash(line), true)
    puts fld

	end

	def test_TN
			line ='[datatype:TN, required:R, piece:1]'
			fld = @fldGenerator.TN(lineToHash(line), true)
			puts fld
			assert_equal 13, fld.size
	end

	def test_UVC
			line ='[datatype:UVC, required:R, piece:1]'
			fld = @fldGenerator.UVC(lineToHash(line), true)
			puts fld
			assert fld.include?('^')
	end

	def test_VID
			line ='[datatype:VID, required:R, piece:1]'
			fld = @fldGenerator.VID(lineToHash(line), true)
			puts fld
			assert fld.to_i < 1000
	end

	def test_XAD
			line ='[max_length:250, symbol:*, description:Patient Address, ifrepeating:1, datatype:XAD, required:O, piece:11]'
			fld = @fldGenerator.XAD(lineToHash(line), true)
			puts fld
			assert_equal 6, fld.split('^').size
	end

	def test_XCN
			line ='[max_length:250, symbol:*, description:Operator ID, ifrepeating:1, datatype:XCN, required:O, piece:5, codetable:188]'
			fld = @fldGenerator.XCN(lineToHash(line), true)
			puts fld
			assert_equal 4, fld.split('^').size

		 line = '[max_length:250, symbol:*, description:Diagnosing Clinician, ifrepeating:1, datatype:XCN, required:O, piece:16]'
			fld = @fldGenerator.XCN(lineToHash(line), true)
			puts fld
			assert_equal 4, fld.split('^').size
	end

	def test_XON
		line ='[max_length:250, symbol:*, description:Patient Primary Facility, ifrepeating:1, datatype:XON, required:O, piece:3]'
		fld = @fldGenerator.XON(lineToHash(line), true)
		puts fld
		assert_equal 3, fld.split('^').size
	end

	def test_XPN
		line ='[max_length:250, symbol:*, description:Patient Alias, ifrepeating:1, datatype:XPN, required:B, piece:9]'
		fld = @fldGenerator.XPN(lineToHash(line), true)
		puts fld
		assert_equal 3, fld.split('^').size
	end

	def test_XTN
		line ='[max_length:250, symbol:*, description:Phone Number - Business, ifrepeating:1, datatype:XTN, required:O, piece:14]'
		fld = @fldGenerator.XTN(lineToHash(line), true)
		puts fld
		assert 'Starts with (...)', /(\d{3})/.match(fld)
	#	assert fld.include?/(\d{3}\\)\d{3}-\d{4}/
	end

	def test_autoGenerate
		map = {:required =>'B'}
		refute (@fldGenerator.autoGenerate?(map)) # false

		map = {:required =>'X'}
		refute (@fldGenerator.autoGenerate?(map)) # false

		map = {:required =>'W'}
		refute (@fldGenerator.autoGenerate?(map)) # false

		map = {:required =>'R'}
		assert (@fldGenerator.autoGenerate?(map)) # true

		map = {:required =>'O'}
		puts @fldGenerator.autoGenerate?(map) # true or false random

		map = {:required =>'O'}
		assert @fldGenerator.autoGenerate?(map,true) # true or false random

		map = {'required'=>'W'}
		assert @fldGenerator.autoGenerate?(map,true) # true or false random
	end


	def test_generateLengthBoundId
		actual = @fldGenerator.generateLengthBoundId(10, '12345')
		puts actual
		assert_equal('1234500000', actual)

		actual = @fldGenerator.generateLengthBoundId(9)
		puts actual
		assert_equal(9, actual.size)

		actual = @fldGenerator.generateLengthBoundId(1, '3000')
		puts actual
		assert_equal(1, actual.size)

		actual = @fldGenerator.generateLengthBoundId(0)
		puts actual
		# assert_equal(, actual.size)
	end

	def test_getCodedValue_lenViolation
		actual = @fldGenerator.getCodedValue({'codetable'=>'162','max_length' =>'1'})
		puts actual
	end

	def test_getCodedValue_range1
		actual = @fldGenerator.getCodedValue({'codetable'=>'112','max_length' =>'2'})
		puts actual
	end

	def test_getCodedValue_range2
		actual = @fldGenerator.getCodedValue({'codetable'=>'141','max_length' =>'2'})
		puts actual
	end

	def test_getCodedValues_range3
		# {"position"=>position='3', "value"=>value='2 ...', "description"=>description='For ranked secondary diagnoses'}
		actual = @fldGenerator.getCodedValue({'codetable'=>'1','max_length' =>'2'})
		puts actual
	end

	def test_getCodedMap_lenViolation
		actual = @fldGenerator.getCodedMap({'codetable'=>'162','max_length' =>'1'})
		puts actual
	end

	def test_getCodedValue_range1
		actual = @fldGenerator.getCodedMap({'codetable'=>'112','max_length' =>'2'})
		puts actual
	end

	def test_getCodedValue_range2
		actual = @fldGenerator.getCodedMap({'codetable'=>'141','max_length' =>'2'})
		puts actual
	end

	def test_handleRanges

		# { :position=>'1', :value=>'...', :description=>'No suggested values defined'}
	  code = @fldGenerator.handleRanges('...')
		assert_equal '', code

		# {"position"=>'12' value='12 ... 16' description='Payer codes.' }
		code = @fldGenerator.handleRanges('12 ... 16').to_i
		# puts code
		assert 11 < code && code < 17
		#position='1' value='E1 ... E9' description='Enlisted'
		code = @fldGenerator.handleRanges('E1 ... E9')
		puts code
		assert 'E0' < code && code <= 'E9'
		# {"position"=>position='3', "value"=>value='2 ...', "description"=>description='For ranked secondary diagnoses'}
		code = @fldGenerator.handleRanges('2 ...')
		# puts code
		assert_equal '2',  code
		code = @fldGenerator.handleRanges('A2 ...')
		assert_equal 'A2', code
		# puts code
		# assert 'E0' < code && code <= 'E9'
	end

	# 112 141
	def test_applyRules
		# codes = Array (6 elements)
		# [0] = Hash (3 elements)
		# position => 1
		# value => 1002-5
		# description => American Indian or Alaska Native
		# [1] = Hash (3 elements)
		# [2] = Hash (3 elements)
		# [3] = Hash (3 elements)
		# [4] = Hash (3 elements)
		# [5] = Hash (3 elements)


		# attributes = Hash (8 elements)
		# max_length => 250
		# symbol => *
		# description => Race
		# ifrepeating => 1
		# datatype => CE
		# required => O
		# piece => 10
		# codetable => 5
		# 	actual = @fldGenerator.applyRules({'codetable'=>'141','max_length' =>'2'})
		# puts actual
	end

end