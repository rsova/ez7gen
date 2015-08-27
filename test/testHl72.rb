require 'ruby-hl7'
require 'date'

# seg = HL7::Message::Segment::Default.new(['a','b','c'])
# puts seg.to_info

 # create a message
msg = HL7::Message.new

# create a MSH segment for our new message
msh = HL7::Message::Segment::MSH.new
msh.recv_app = "ruby hl7"
msh.recv_facility = "my office"
msh.processing_id = rand(10000).to_s
msh.sending_facility = 'facility 2'
msh.sending_app = 'integration app2'
msh.time =  DateTime.now
#puts msh.methods
msg << msh # add the MSH segment to the message
puts msh.to_info
puts "----------"
#puts msg.to_s # readable version of the message
#puts msg.to_s.class
#puts msg.to_hl7 # hl7 version of the message (as a string)
#puts msg.to_hl7.class

#\puts msg.to_mllp # mllp version of the message (as a string)

seg = HL7::Message::Segment::Default.new
seg.e0 = "NK1"
seg.e1 = "SOMETHING ELSE"
seg.e2 = "KIN HERE"
seg.e3 = "94^20150630135433.349-1000" # dld discharge location id + time
# puts seg.methods.sort()
puts seg.e2.class

msg << seg
puts msg.to_s
puts "-----------"

seg = HL7::Message::Segment::Default.new
seg.add_field
msg << seg
puts msg.to_s

exit
#identifier (ST) (ST)
# -- ce.getIdentifier().setValue(codes.codetable)
#text (ST)
# -- ce.getText().setValue(codes.description)
# name of coding system (IS)
# alternate identifier (ST) (ST)
# alternate text (ST)
#name of alternate coding system (IS)


#ROL
# [max_length:60, symbol:?, description:Role Instance ID, ifrepeating:0, datatype:EI, required:C, piece:1]
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

rol = HL7::Message::Segment::Default.new
rol.e0 = "ROL"
# map = [max_length:60, symbol:?, description:Role Instance ID, ifrepeating:0, datatype:EI, required:C, piece:1]
#puts seg.methods
msg << rol
puts msg.to_s

puts '--------MSH------------- \n'
msg = HL7::Message.new
msh_seg = HL7::Message::Segment::Default.new
msh_seg.e0 = "MSH"
# MSH-1: Field Separator (ST)
msh_seg.e1 ='^~\&|'
# MSH-2: Encoding Characters (ST)
# MSH-3: Sending Application (HD) optional
msh_seg.e3='Sending App'
msh_seg.e3='^^123^3'
puts '~~~~~~~~~'
p msh_seg.class
p msh_seg.item_delim()
p msh_seg.is_child_segment?
p msh_seg.has_children?
puts '~~~~~~~~~'

# MSH-4: Sending Facility (HD) optional
msh_seg.e4='My Sending Facility'
# MSH-5: Receiving Application (HD) optional
# MSH-6: Receiving Facility (HD) optional
# MSH-7: Date/Time Of Message (TS)
# MSH-8: Security (ST) optional
# MSH-9: Message Type (MSG)
# MSH-10: Message Control ID (ST)
# MSH-11: Processing ID (PT)
# MSH-12: Version ID (VID)
# MSH-13: Sequence Number (NM) optional
# MSH-14: Continuation Pointer (ST) optional
# MSH-15: Accept Acknowledgment Type (ID) optional
# MSH-16: Application Acknowledgment Type (ID) optional
# MSH-17: Country Code (ID) optional
# MSH-18: Character Set (ID) optional repeating
# MSH-19: Principal Language Of Message (CE) optional
# MSH-20: Alternate Character Set Handling Scheme (ID) optional
# MSH-21: Conformance Statement ID (ID) optional repeating

msg << msh_seg
puts msg.to_s

puts  '------ Hash ----------'
arr = ["max_length","1", "symbol","!"]
map = Hash[*arr]
# map = Hash["max_length"=>"1", "symbol"=>"!"]
puts map.class
puts map['max_length']

puts "-- atrbs --"
atrbs= "[max_length:1, symbol:!, description:Field Separator, ifrepeating:0, datatype:ST, required:R, piece:1]".gsub(":",",")
p atrbs
ar = atrbs.split(',')
p arr[0]
p ar
puts ar.class()
map = Hash[*(ar.collect{|x| x.strip})] #squish
puts map.class
p map
#map.each() {|z| puts z}
puts map["description"]

# [max_length:1, symbol:!, description:Field Separator, ifrepeating:0, datatype:ST, required:R, piece:1]
# [max_length:4, symbol:!, description:Encoding Characters, ifrepeating:0, datatype:ST, required:R, piece:2]
# [max_length:180, description:Sending Application, ifrepeating:0, datatype:HD, required:O, piece:3, codetable:361]
# [max_length:180, description:Sending Facility, ifrepeating:0, datatype:HD, required:O, piece:4, codetable:362]
# [max_length:180, description:Receiving Application, ifrepeating:0, datatype:HD, required:O, piece:5, codetable:361]
# [max_length:180, description:Receiving Facility, ifrepeating:0, datatype:HD, required:O, piece:6, codetable:362]
# [max_length:26, symbol:!, description:Date/Time Of Message, ifrepeating:0, datatype:TS, required:R, piece:7]
# [max_length:40, description:Security, ifrepeating:0, datatype:ST, required:O, piece:8]
# [max_length:15, symbol:!, description:Message Type, ifrepeating:0, datatype:MSG, required:R, piece:9, codetable:76]
# [max_length:20, symbol:!, description:Message Control ID, ifrepeating:0, datatype:ST, required:R, piece:10]
# [max_length:3, symbol:!, description:Processing ID, ifrepeating:0, datatype:PT, required:R, piece:11]
# [max_length:60, symbol:!, description:Version ID, ifrepeating:0, datatype:VID, required:R, piece:12, codetable:104]
# [max_length:15, description:Sequence Number, ifrepeating:0, datatype:NM, required:O, piece:13]
# [max_length:180, description:Continuation Pointer, ifrepeating:0, datatype:ST, required:O, piece:14]
# [max_length:2, description:Accept Acknowledgment Type, ifrepeating:0, datatype:ID, required:O, piece:15, codetable:155]
# [max_length:2, description:Application Acknowledgment Type, ifrepeating:0, datatype:ID, required:O, piece:16, codetable:155]
# [max_length:3, description:Country Code, ifrepeating:0, datatype:ID, required:O, piece:17, codetable:399]
# [max_length:16, symbol:*, description:Character Set, ifrepeating:1, datatype:ID, required:O, piece:18, codetable:211]
# [max_length:250, description:Principal Language Of Message, ifrepeating:0, datatype:CE, required:O, piece:19]
# [max_length:20, description:Alternate Character Set Handling Scheme, ifrepeating:0, datatype:ID, required:O, piece:20, codetable:356]
# [max_length:10, symbol:*, description:Conformance Statement ID, ifrepeating:1, datatype:ID, required:O, piece:21, codetable:449]
