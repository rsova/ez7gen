require "minitest/autorun"
require 'ruby-hl7'
require_relative "../lib/ez7gen/service/segment_generator"

class TestProfileParser < MiniTest::Unit::TestCase

def setup
	@segmentGen = SegmentGenerator.new("2.4","ADT_A01")
	@msg = HL7::Message.new
	@msg << @segmentGen.initMsh()
end

def test_init
	assert(@segmentGen !=nil)
	puts @msg
end

def test_addField
	#ROL
 attrs = []	
 row = {'max_length'=> '60', 'symbol'=>'?', 'description'=>'Role Instance ID', 'ifrepeating'=>'0', 'datatype'=>'EI', 'required'=>'C', 'piece'=>'1'}
 attrs << row
# [max_length:2, symbol:!, description:Action Code, ifrepeating:0, datatype:ID, required:R, piece:2, codetable:287]
# [max_length:250, symbol:!, description:Role-ROL, ifrepeating:0, datatype:CE, required:R, piece:3, codetable:443]
# [max_length:250, symbol:+, description:Role Person, ifrepeating:1, datatype:XCN, required:R, piece:4]
# [max_length:26, description:Role Begin Date/Time, ifrepeating:0, datatype:TS, required:O, piece:5]
# [max_length:26, description:Role End Date/Time, ifrepeating:0, datatype:TS, required:O, piece:6]
# [max_length:250, description:Role Duration, ifrepeating:0, datatype:CE, required:O, piece:7]
# [max_length:250, description:Role Action Reason, ifrepeating:0, datatype:CE, required:O, piece:8]
# [max_length:250, symbol:*, description:Provider Type, ifrepeating:1, datatype:CE, required:O, piece:9]
# [max_length:250, description:Organization Unit Type - ROL, ifrepeating:0, datatype:CE, required:O, piece:10, codetable:406]
# [max_length:250, symbol:*, description:Office/Home Address, ifrepeating:1, datatype:XAD, required:O, piece:11]
# [max_length:250, symbol:*, description:Phone, ifrepeating:1, datatype:XTN, required:O, piece:12]

  seg = @segmentGen.generateSegment("ROL",attrs)
  puts seg.to_info
  puts seg
 end
end