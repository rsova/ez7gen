require "minitest/autorun"
require 'ruby-hl7'
require_relative "../lib/ez7gen/service/segment_generator"

class TestProfileParser < MiniTest::Unit::TestCase
 #parse xml once
 @@pp = ProfileParser.new('2.4','ADT_A01')

def setup
	@segmentGen = SegmentGenerator.new("2.4","ADT_A01", @@pp)
	@msg = HL7::Message.new
	@msg << @segmentGen.initMsh()
end

def test_addField_CE
	#PID
 line = '[max_length:250, description:Role Action Reason, ifrepeating:0, datatype:CE, required:R, piece:8]'
 row=line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
 puts row
 fld = @segmentGen.addField(row)
 puts fld
end

def test_segment_PD
 attrs = []
 line = '[max_length:250, symbol:*, description:Race, ifrepeating:1, datatype:CE, required:R, piece:10, codetable:5]'
 row=line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
 p row
 attrs<<row
 p attrs
 seg = @segmentGen.generateSegment("PD",attrs)
 puts seg.to_info
 puts seg
end
exit

def test_init
	assert(@segmentGen !=nil)
	puts @msg
end

def test_addField_EI
  attrs = []
  row = {'max_length'=> '60', 'symbol'=>'?', 'description'=>'Role Instance ID', 'ifrepeating'=>'0', 'datatype'=>'EI', 'required'=>'C', 'piece'=>'1'}
  attrs << row

  seg = @segmentGen.generateSegment("ROL",attrs)
  puts seg.to_info
  puts seg
end


end