require "minitest/autorun"
require "benchmark"
require 'ruby-hl7'
require_relative "../lib/ez7gen/service/segment_generator"

class TestProfileParser < MiniTest::Unit::TestCase
 #parse xml once
 @@pp = ProfileParser.new('2.4','ADT_A01')


 # EVN: EVN
 @@evn_attributes ="[max_length:3, description:Event Type Code, ifrepeating:0, datatype:ID, required:B, piece:1, codetable:3]
  [max_length:26, symbol:!, description:Recorded Date/Time, ifrepeating:0, datatype:TS, required:R, piece:2]
  [max_length:26, description:Date/Time Planned Event, ifrepeating:0, datatype:TS, required:O, piece:3]
  [max_length:3, description:Event Reason Code, ifrepeating:0, datatype:IS, required:O, piece:4, codetable:62]
  [max_length:250, symbol:*, description:Operator ID, ifrepeating:1, datatype:XCN, required:O, piece:5, codetable:188]
  [max_length:26, description:Event Occurred, ifrepeating:0, datatype:TS, required:O, piece:6]
  [max_length:180, description:Event Facility, ifrepeating:0, datatype:HD, required:O, piece:7]"

 # PID: PID
 @@pid_attributes ="[max_length:4, description:Set ID - PID, ifrepeating:0, datatype:SI, required:O, piece:1]
  [max_length:20, description:Patient ID, ifrepeating:0, datatype:CX, required:B, piece:2]
  [max_length:250, symbol:+, description:Patient Identifier List, ifrepeating:1, datatype:CX, required:R, piece:3]
  [max_length:20, symbol:*, description:Alternate Patient ID - PID, ifrepeating:1, datatype:CX, required:B, piece:4]
  [max_length:250, symbol:+, description:Patient Name, ifrepeating:1, datatype:XPN, required:R, piece:5]
  [max_length:250, symbol:*, description:Mother's Maiden Name, ifrepeating:1, datatype:XPN, required:O, piece:6]
  [max_length:26, description:Date/Time Of Birth, ifrepeating:0, datatype:TS, required:O, piece:7]
  [max_length:1, description:Administrative Sex, ifrepeating:0, datatype:IS, required:O, piece:8, codetable:1]
  [max_length:250, symbol:*, description:Patient Alias, ifrepeating:1, datatype:XPN, required:B, piece:9]
  [max_length:250, symbol:*, description:Race, ifrepeating:1, datatype:CE, required:O, piece:10, codetable:5]
  [max_length:250, symbol:*, description:Patient Address, ifrepeating:1, datatype:XAD, required:O, piece:11]
  [max_length:4, description:County Code, ifrepeating:0, datatype:IS, required:B, piece:12, codetable:289]
  [max_length:250, symbol:*, description:Phone Number - Home, ifrepeating:1, datatype:XTN, required:O, piece:13]
  [max_length:250, symbol:*, description:Phone Number - Business, ifrepeating:1, datatype:XTN, required:O, piece:14]
  [max_length:250, description:Primary Language, ifrepeating:0, datatype:CE, required:O, piece:15, codetable:296]
  [max_length:250, description:Marital Status, ifrepeating:0, datatype:CE, required:O, piece:16, codetable:2]
  [max_length:250, description:Religion, ifrepeating:0, datatype:CE, required:O, piece:17, codetable:6]
  [max_length:250, description:Patient Account Number, ifrepeating:0, datatype:CX, required:O, piece:18]
  [max_length:16, description:SSN Number - Patient, ifrepeating:0, datatype:ST, required:B, piece:19]
  [max_length:25, description:Driver's License Number - Patient, ifrepeating:0, datatype:DLN, required:O, piece:20]
  [max_length:250, symbol:*, description:Mother's Identifier, ifrepeating:1, datatype:CX, required:O, piece:21]
  [max_length:250, symbol:*, description:Ethnic Group, ifrepeating:1, datatype:CE, required:O, piece:22, codetable:189]
  [max_length:250, description:Birth Place, ifrepeating:0, datatype:ST, required:O, piece:23]
  [max_length:1, description:Multiple Birth Indicator, ifrepeating:0, datatype:ID, required:O, piece:24, codetable:136]
  [max_length:2, description:Birth Order, ifrepeating:0, datatype:NM, required:O, piece:25]
  [max_length:250, symbol:*, description:Citizenship, ifrepeating:1, datatype:CE, required:O, piece:26, codetable:171]
  [max_length:250, description:Veterans Military Status, ifrepeating:0, datatype:CE, required:O, piece:27, codetable:172]
  [max_length:250, description:Nationality, ifrepeating:0, datatype:CE, required:B, piece:28, codetable:212]
  [max_length:26, description:Patient Death Date and Time, ifrepeating:0, datatype:TS, required:O, piece:29]
  [max_length:1, description:Patient Death Indicator, ifrepeating:0, datatype:ID, required:O, piece:30, codetable:136]
  [max_length:1, description:Identity Unknown Indicator, ifrepeating:0, datatype:ID, required:O, piece:31, codetable:136]
  [max_length:20, symbol:*, description:Identity Reliability Code, ifrepeating:1, datatype:IS, required:O, piece:32, codetable:445]
  [max_length:26, description:Last Update Date/Time, ifrepeating:0, datatype:TS, required:O, piece:33]
  [max_length:40, description:Last Update Facility, ifrepeating:0, datatype:HD, required:O, piece:34]
  [max_length:250, symbol:?, description:Species Code, ifrepeating:0, datatype:CE, required:C, piece:35, codetable:446]
  [max_length:250, symbol:?, description:Breed Code, ifrepeating:0, datatype:CE, required:C, piece:36, codetable:447]
  [max_length:80, description:Strain, ifrepeating:0, datatype:ST, required:O, piece:37]
  [max_length:250, description:Production Class Code, ifrepeating:0, datatype:CE, required:O, piece:38, codetable:429]"

 # PV1: PV1
 @@pv1_attributes="[max_length:4, description:Set ID - PV1, ifrepeating:0, datatype:SI, required:O, piece:1]
  [max_length:1, symbol:!, description:Patient Class, ifrepeating:0, datatype:IS, required:R, piece:2, codetable:4]
  [max_length:80, description:Assigned Patient Location, ifrepeating:0, datatype:PL, required:O, piece:3]
  [max_length:2, description:Admission Type, ifrepeating:0, datatype:IS, required:O, piece:4, codetable:7]
  [max_length:250, description:Preadmit Number, ifrepeating:0, datatype:CX, required:O, piece:5]
  [max_length:80, description:Prior Patient Location, ifrepeating:0, datatype:PL, required:O, piece:6]
  [max_length:250, symbol:*, description:Attending Doctor, ifrepeating:1, datatype:XCN, required:O, piece:7, codetable:10]
  [max_length:250, symbol:*, description:Referring Doctor, ifrepeating:1, datatype:XCN, required:O, piece:8, codetable:10]
  [max_length:250, symbol:*, description:Consulting Doctor, ifrepeating:1, datatype:XCN, required:B, piece:9, codetable:10]
  [max_length:3, description:Hospital Service, ifrepeating:0, datatype:IS, required:O, piece:10, codetable:69]
  [max_length:80, description:Temporary Location, ifrepeating:0, datatype:PL, required:O, piece:11]
  [max_length:2, description:Preadmit Test Indicator, ifrepeating:0, datatype:IS, required:O, piece:12, codetable:87]
  [max_length:2, description:Re-admission Indicator, ifrepeating:0, datatype:IS, required:O, piece:13, codetable:92]
  [max_length:6, description:Admit Source, ifrepeating:0, datatype:IS, required:O, piece:14, codetable:23]
  [max_length:2, symbol:*, description:Ambulatory Status, ifrepeating:1, datatype:IS, required:O, piece:15, codetable:9]
  [max_length:2, description:VIP Indicator, ifrepeating:0, datatype:IS, required:O, piece:16, codetable:99]
  [max_length:250, symbol:*, description:Admitting Doctor, ifrepeating:1, datatype:XCN, required:O, piece:17, codetable:10]
  [max_length:2, description:Patient Type, ifrepeating:0, datatype:IS, required:O, piece:18, codetable:18]
  [max_length:250, description:Visit Number, ifrepeating:0, datatype:CX, required:O, piece:19]
  [max_length:50, symbol:*, description:Financial Class, ifrepeating:1, datatype:FC, required:O, piece:20, codetable:64]
  [max_length:2, description:Charge Price Indicator, ifrepeating:0, datatype:IS, required:O, piece:21, codetable:32]
  [max_length:2, description:Courtesy Code, ifrepeating:0, datatype:IS, required:O, piece:22, codetable:45]
  [max_length:2, description:Credit Rating, ifrepeating:0, datatype:IS, required:O, piece:23, codetable:46]
  [max_length:2, symbol:*, description:Contract Code, ifrepeating:1, datatype:IS, required:O, piece:24, codetable:44]
  [max_length:8, symbol:*, description:Contract Effective Date, ifrepeating:1, datatype:DT, required:O, piece:25]
  [max_length:12, symbol:*, description:Contract Amount, ifrepeating:1, datatype:NM, required:O, piece:26]
  [max_length:3, symbol:*, description:Contract Period, ifrepeating:1, datatype:NM, required:O, piece:27]
  [max_length:2, description:Interest Code, ifrepeating:0, datatype:IS, required:O, piece:28, codetable:73]
  [max_length:1, description:Transfer to Bad Debt Code, ifrepeating:0, datatype:IS, required:O, piece:29, codetable:110]
  [max_length:8, description:Transfer to Bad Debt Date, ifrepeating:0, datatype:DT, required:O, piece:30]
  [max_length:10, description:Bad Debt Agency Code, ifrepeating:0, datatype:IS, required:O, piece:31, codetable:21]
  [max_length:12, description:Bad Debt Transfer Amount, ifrepeating:0, datatype:NM, required:O, piece:32]
  [max_length:12, description:Bad Debt Recovery Amount, ifrepeating:0, datatype:NM, required:O, piece:33]
  [max_length:1, description:Delete Account Indicator, ifrepeating:0, datatype:IS, required:O, piece:34, codetable:111]
  [max_length:8, description:Delete Account Date, ifrepeating:0, datatype:DT, required:O, piece:35]
  [max_length:3, description:Discharge Disposition, ifrepeating:0, datatype:IS, required:O, piece:36, codetable:112]
  [max_length:25, description:Discharged to Location, ifrepeating:0, datatype:DLD, required:O, piece:37, codetable:113]
  [max_length:250, description:Diet Type, ifrepeating:0, datatype:CE, required:O, piece:38, codetable:114]
  [max_length:2, description:Servicing Facility, ifrepeating:0, datatype:IS, required:O, piece:39, codetable:115]
  [max_length:1, description:Bed Status, ifrepeating:0, datatype:IS, required:B, piece:40, codetable:116]
  [max_length:2, description:Account Status, ifrepeating:0, datatype:IS, required:O, piece:41, codetable:117]
  [max_length:80, description:Pending Location, ifrepeating:0, datatype:PL, required:O, piece:42]
  [max_length:80, description:Prior Temporary Location, ifrepeating:0, datatype:PL, required:O, piece:43]
  [max_length:26, description:Admit Date/Time, ifrepeating:0, datatype:TS, required:O, piece:44]
  [max_length:26, symbol:*, description:Discharge Date/Time, ifrepeating:1, datatype:TS, required:O, piece:45]
  [max_length:12, description:Current Patient Balance, ifrepeating:0, datatype:NM, required:O, piece:46]
  [max_length:12, description:Total Charges, ifrepeating:0, datatype:NM, required:O, piece:47]
  [max_length:12, description:Total Adjustments, ifrepeating:0, datatype:NM, required:O, piece:48]
  [max_length:12, description:Total Payments, ifrepeating:0, datatype:NM, required:O, piece:49]
  [max_length:250, description:Alternate Visit ID, ifrepeating:0, datatype:CX, required:O, piece:50, codetable:203]
  [max_length:1, description:Visit Indicator, ifrepeating:0, datatype:IS, required:O, piece:51, codetable:326]
  [max_length:250, symbol:*, description:Other Healthcare Provider, ifrepeating:1, datatype:XCN, required:B, piece:52, codetable:10]"

 # [~PD1~]: PD1
 @@pd1_attributes="[max_length:2, symbol:*, description:Living Dependency, ifrepeating:1, datatype:IS, required:O, piece:1, codetable:223]
  [max_length:2, description:Living Arrangement, ifrepeating:0, datatype:IS, required:O, piece:2, codetable:220]
  [max_length:250, symbol:*, description:Patient Primary Facility, ifrepeating:1, datatype:XON, required:O, piece:3]
  [max_length:250, symbol:*, description:Patient Primary Care Provider Name & ID No., ifrepeating:1, datatype:XCN, required:B, piece:4]
  [max_length:2, description:Student Indicator, ifrepeating:0, datatype:IS, required:O, piece:5, codetable:231]
  [max_length:2, description:Handicap, ifrepeating:0, datatype:IS, required:O, piece:6, codetable:295]
  [max_length:2, description:Living Will Code, ifrepeating:0, datatype:IS, required:O, piece:7, codetable:315]
  [max_length:2, description:Organ Donor Code, ifrepeating:0, datatype:IS, required:O, piece:8, codetable:316]
  [max_length:1, description:Separate Bill, ifrepeating:0, datatype:ID, required:O, piece:9, codetable:136]
  [max_length:250, symbol:*, description:Duplicate Patient, ifrepeating:1, datatype:CX, required:O, piece:10]
  [max_length:250, description:Publicity Code, ifrepeating:0, datatype:CE, required:O, piece:11, codetable:215]
  [max_length:1, description:Protection Indicator, ifrepeating:0, datatype:ID, required:O, piece:12, codetable:136]
  [max_length:8, description:Protection Indicator Effective Date, ifrepeating:0, datatype:DT, required:O, piece:13]
  [max_length:250, symbol:*, description:Place of Worship, ifrepeating:1, datatype:XON, required:O, piece:14]
  [max_length:250, symbol:*, description:Advance Directive Code, ifrepeating:1, datatype:CE, required:O, piece:15, codetable:435]
  [max_length:1, description:Immunization Registry Status, ifrepeating:0, datatype:IS, required:O, piece:16, codetable:441]
  [max_length:8, description:Immunization Registry Status Effective Date, ifrepeating:0, datatype:DT, required:O, piece:17]
  [max_length:8, description:Publicity Code Effective Date, ifrepeating:0, datatype:DT, required:O, piece:18]
  [max_length:5, description:Military Branch, ifrepeating:0, datatype:IS, required:O, piece:19, codetable:140]
  [max_length:2, description:Military Rank/Grade, ifrepeating:0, datatype:IS, required:O, piece:20, codetable:141]
  [max_length:3, description:Military Status, ifrepeating:0, datatype:IS, required:O, piece:21, codetable:142]"

 # [~{~AL1~}~]: AL1
 @@al1_attributes="[max_length:250, symbol:!, description:Set ID - AL1, ifrepeating:0, datatype:CE, required:R, piece:1]
  [max_length:250, description:Allergen Type Code, ifrepeating:0, datatype:CE, required:O, piece:2, codetable:127]
  [max_length:250, symbol:!, description:Allergen Code/Mnemonic/Description, ifrepeating:0, datatype:CE, required:R, piece:3]
  [max_length:250, description:Allergy Severity Code, ifrepeating:0, datatype:CE, required:O, piece:4, codetable:128]
  [max_length:15, symbol:*, description:Allergy Reaction Code, ifrepeating:1, datatype:ST, required:O, piece:5]
  [max_length:8, description:Identification Date, ifrepeating:0, datatype:DT, required:B, piece:6]"

 # [~{~DG1~}~]: DG1
 @@dg1_attributes="[max_length:4, symbol:!, description:Set ID - DG1, ifrepeating:0, datatype:SI, required:R, piece:1]
  [max_length:2, description:Diagnosis Coding Method, ifrepeating:0, datatype:ID, required:(B) R, piece:2, codetable:53]
  [max_length:250, description:Diagnosis Code - DG1, ifrepeating:0, datatype:CE, required:O, piece:3, codetable:51]
  [max_length:40, description:Diagnosis Description, ifrepeating:0, datatype:ST, required:B, piece:4]
  [max_length:26, description:Diagnosis Date/Time, ifrepeating:0, datatype:TS, required:O, piece:5]
  [max_length:2, symbol:!, description:Diagnosis Type, ifrepeating:0, datatype:IS, required:R, piece:6, codetable:52]
  [max_length:250, description:Major Diagnostic Category, ifrepeating:0, datatype:CE, required:B, piece:7, codetable:118]
  [max_length:250, description:Diagnostic Related Group, ifrepeating:0, datatype:CE, required:B, piece:8, codetable:55]
  [max_length:1, description:DRG Approval Indicator, ifrepeating:0, datatype:ID, required:B, piece:9, codetable:136]
  [max_length:2, description:DRG Grouper Review Code, ifrepeating:0, datatype:IS, required:B, piece:10, codetable:56]
  [max_length:250, description:Outlier Type, ifrepeating:0, datatype:CE, required:B, piece:11, codetable:83]
  [max_length:3, description:Outlier Days, ifrepeating:0, datatype:NM, required:B, piece:12]
  [max_length:12, description:Outlier Cost, ifrepeating:0, datatype:CP, required:B, piece:13]
  [max_length:4, description:Grouper Version And Type, ifrepeating:0, datatype:ST, required:B, piece:14]
  [max_length:2, description:Diagnosis Priority, ifrepeating:0, datatype:ID, required:O, piece:15, codetable:359]
  [max_length:250, symbol:*, description:Diagnosing Clinician, ifrepeating:1, datatype:XCN, required:O, piece:16]
  [max_length:3, description:Diagnosis Classification, ifrepeating:0, datatype:IS, required:O, piece:17, codetable:228]
  [max_length:1, description:Confidential Indicator, ifrepeating:0, datatype:ID, required:O, piece:18, codetable:136]
  [max_length:26, description:Attestation Date/Time, ifrepeating:0, datatype:TS, required:O, piece:19]"

 #helper method
   def lineToHash(line)
     return line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
   end

  # TESTS #
  def setup
    puts Benchmark.measure{
    profilers = { Utils.PRIMARY => @@pp }
    @segmentGen = SegmentGenerator.new("2.4","ADT_A01", profilers)
    @msg = HL7::Message.new
    @msg << @segmentGen.initMsh()

         }

  end

 def test_init
   assert(@segmentGen !=nil)
   puts @msg
 end

 # def test_addField_CE
 #    #PID
 #   line = '[max_length:250, description:Role Action Reason, ifrepeating:0, datatype:CE, required:R, piece:8]'
 #   row=line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
 #   puts row
 #   fld = @segmentGen.addField(row, @pp)
 #   puts fld
 #  end
 #
 #  def test_segment_PD
 #   attrs = []
 #   line = '[max_length:250, symbol:*, description:Race, ifrepeating:1, datatype:CE, required:R, piece:10, codetable:5]'
 #   row=line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
 #   p row
 #   attrs<<row
 #   p attrs
 #   seg = @segmentGen.generateSegment("PD",attrs)
 #   puts seg.to_info
 #   puts seg
 #  end
 #
 #  def test_addField_EI
 #    attrs = []
 #    row = {'max_length'=> '60', 'symbol'=>'?', 'description'=>'Role Instance ID', 'ifrepeating'=>'0', 'datatype'=>'EI', 'required'=>'C', 'piece'=>'1'}
 #    attrs << row
 #    seg = @segmentGen.generateSegment("ROL",attrs)
 #    puts seg.to_info
 #    puts seg
 #  end

  def test_EVN
    attributes = []
    attributes << lineToHash('[max_length:3, description:Event Type Code, ifrepeating:0, datatype:ID, required:B, piece:1, codetable:3]')
    attributes << lineToHash('[max_length:26, symbol:!, description:Recorded Date/Time, ifrepeating:0, datatype:TS, required:R, piece:2]')
    attributes << lineToHash('[max_length:26, description:Date/Time Planned Event, ifrepeating:0, datatype:TS, required:O, piece:3]')
    attributes << lineToHash('[max_length:3, description:Event Reason Code, ifrepeating:0, datatype:IS, required:O, piece:4, codetable:62]')
    attributes << lineToHash('[max_length:250, symbol:*, description:Operator ID, ifrepeating:1, datatype:XCN, required:O, piece:5, codetable:188]')
    attributes << lineToHash('[max_length:26, description:Event Occurred, ifrepeating:0, datatype:TS, required:O, piece:6]')
    attributes << lineToHash('[max_length:180, description:Event Facility, ifrepeating:0, datatype:HD, required:O, piece:7]')
    puts Benchmark.measure(){
      puts @segmentGen.generateSegment('EVN', attributes)
         }
  end

  def test_ADT_A01_EVN
    attributes = []
    @@evn_attributes.each_line do |line|
      attributes << lineToHash( line)
    end
    msg = HL7::Message.new
    msg << @segmentGen.initMsh
    puts @segmentGen.generate(msg,'EVN', attributes)
  end

 def test_ADT_A01_PID
   attributes = []
   @@pid_attributes.each_line do |line|
     attributes << lineToHash( line)
   end

   msg = HL7::Message.new
   msg << @segmentGen.initMsh
   puts @segmentGen.generate(msg,'PID', attributes)
 end

 def test_ADT_A01_PV1
   attributes = []
   @@pv1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end

   msg = HL7::Message.new
   msg << @segmentGen.initMsh
   puts @segmentGen.generate(msg,'PV1', attributes)
 end

 def test_ADT_A01_PD1
   attributes = []
   @@pd1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end

   msg = HL7::Message.new
   msg << @segmentGen.initMsh
   puts @segmentGen.generate(msg,'[~PD1~]', attributes)
 end

 def test_ADT_A01_AL1
   attributes = []
   @@al1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end

   msg = HL7::Message.new
   msg << @segmentGen.initMsh
   puts @segmentGen.generate(msg,'[~{~AL1~}~]', attributes)
 end

 def test_ADT_A01_DG1
   attributes = []
   @@dg1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end

   msg = HL7::Message.new
   msg << @segmentGen.initMsh
   puts @segmentGen.generate(msg,'[~{~DG1~}~]', attributes)
 end

 def test_ADT_ALL1
   attributes = []
   @@pid_attributes.each_line do |line|
     attributes << lineToHash( line)
   end

   msg = HL7::Message.new
   msg << @segmentGen.initMsh
   @segmentGen.generate(msg,'PID', attributes)

   attributes = []
   @@evn_attributes.each_line do |line|
     attributes << lineToHash( line)
   end
   @segmentGen.generate(msg,'EVN', attributes)

   attributes = []
   @@pv1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end
   @segmentGen.generate(msg,'PV1', attributes)

   attributes = []
   @@pd1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end
   @segmentGen.generate(msg,'[~PD1~]', attributes)

   attributes = []
   @@al1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end
   @segmentGen.generate(msg,'[~{~AL1~}~]', attributes)

   attributes = []
   @@dg1_attributes.each_line do |line|
     attributes << lineToHash( line)
   end
   puts @segmentGen.generate(msg,'[~{~DG1~}~]', attributes)

 end
end
