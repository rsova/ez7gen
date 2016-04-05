# require "minitest/autorun"
require "benchmark"
require 'test/unit'
require 'ruby-hl7'
# require_relative "../lib/ez7gen/service/segment_generator"
require_relative '../lib/ez7gen/structure_parser'
require_relative  '../lib/ez7gen/service/utils'


class StructureParserTest < Test::Unit::TestCase
  include Utils
 #parse xml once
  # TESTS #
  # def setup
  #   puts Benchmark.measure{
  #     # pp = ProfilerParser.new(@attrs).generate()
  #     profilers = { 'primary'=> @@pp }
  #   @segmentGen = SegmentGenerator.new("2.4","ADT_A01", profilers)
  #   # @msg = HL7::Message.new
  #   # @msg << @segmentGen.init_msh()
  #   }
  #
  # end

 def test_init
   parser = StructureParser.new()
   assert_equal([],parser.encodedSegments)
   assert_equal(0, parser.idx)

   # puts @msg
 end

 def test_process_opt
   parser = StructureParser.new()
   struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
   # regEx = parser.regExOp
   # parser.process(struct, regEx, '[]')
   parser.process_opt_groups(struct)
   # assert_equal 29,parser.idx
   assert_equal 29,parser.encodedSegments.size
   puts struct
 end

 def test_process_rep
   parser = StructureParser.new()
   struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
   # regEx = parser::REGEX_REP
   # parser.process(struct, regEx, parser::PRNTHS_REP)# {}
   parser.process_rep_groups(struct)
   # assert_equal 17,parser.idx
   assert_equal 17,parser.encodedSegments.size
   puts struct
 end

  def test_process_not_optional_group
    # <MessageStructure name='ADT_A45' definition='MSH~EVN~PID~[~PD1~]~{~MRG~PV1~}' />
    parser = StructureParser.new()
    struct = "MSH~MSA~[~ERR~]~QAK~QPD~{~[~PID~[~PD1~]~[~QRI~]~]~}~[~DSC~]"
    # regEx = parser.regExOp
    # parser.process(struct, regEx, '[]')
    # # assert_equal 17,parser.encodedSegments.size
    # p parser.encodedSegments
    # puts struct
    #
    # regEx = parser.regExRep
    # parser.process(struct, regEx, '{}')
    parser.process_struct(struct)
    p parser.encodedSegments
    p struct

    # ["[~ERR~]", "[~PD1~]", "[~QRI~]", "[~PID~1~2~]", "{~3~}", "[~DSC~]"]
    #["MSH", "MSA", 0, "QAK", "QPD", 4, 5]
  end

 def test_process_struct
   parser = StructureParser.new()
   struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
   # regEx = parser::REGEX_REP
   # parser.process(struct, regEx, parser::PRNTHS_REP)# {}
   parser.process_struct(struct)
   # assert_equal 17,parser.idx
   # assert_equal 17,parser.encodedSegments.size
   p parser.encodedSegments
   puts struct

   # ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]

 end

  def test_process_struct_ADT_A01
    struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    parser = StructureParser.new()
    parser.process_struct(struct)
    # assert_equal 17,parser.idx
    # assert_equal 17,parser.encodedSegments.size
    p parser.encodedSegments
    puts struct
  # ["MSH", "EVN", "PID", 0, 1, 2, "PV1", 3, 4, 5, 6, 7, 8, 9, 11, 12, 16, 17, 18, 19, 20]
  # ["[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~ROL~}~]", "[~{~PR1~10~}~]", "[~{~GT1~}~]", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]", "[~{~IN1~13~14~15~}~]", "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
  end

  def test_handle_groups
    # arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]
    #arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "~17~19~21~31~", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "{~17~19~21~31~}", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    # MSH~0~1~29
    parser = StructureParser.new()

    parser.encodedSegments = arr
    parser.idx=parser.encodedSegments.size


    seg = parser.handle_groups(["[~PV1~5~]"])
    # parser.handle_groups(arr)
    #   groupFound, tokens = is_group?(el)
    #   if(groupFound)
    #     parser.process_struct(el)
    #   end
    #
    # }
    p parser.encodedSegments
  end

  def test_handle_groups_optMult
    arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "{~17~19~21~31~}", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    # MSH~0~1~29
    parser = StructureParser.new()

    parser.encodedSegments = arr
    parser.idx=parser.encodedSegments.size


    seg = parser.handle_groups(["[~PID~2~3~4~6~9~10~]"])
    p seg

  end
  def test_is_group_resolved
    arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]


    seg = "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]"
    p seg.scan(StructureParser::REGEX_OP).size()
    p seg.scan(StructureParser::REGEX_REP).size()

    p (seg.scan(StructureParser::REGEX_OP).size()>1 || seg.scan(StructureParser::REGEX_REP).size()>1)
    #   p 'yes'
    # end
      #

    arr.each{|seg|
     p seg
     p seg =~ StructureParser::REGEX_OP
     p seg.scan(StructureParser::REGEX_OP)
     # p seg.match(StructureParser::REGEX_OP)

     p seg =~ StructureParser::REGEX_REP
     p seg.scan(StructureParser::REGEX_REP)
     # p seg.match(StructureParser::REGEX_OP)
     if(seg.scan(StructureParser::REGEX_OP).size()>1 || seg.scan(StructureParser::REGEX_REP).size()>1)
       p 'yes'
     else
       p 'not'
     end

     p '--'
    }

  end

  def test_is_complex_group
    a = OptionalGroup.new([1,2,3])
    assert_equal(OptionalGroup, a.class)
    assert a.instance_of?(OptionalGroup)
    assert !a.instance_of?(Array)
    a.each{|it| puts it}
    assert a.kind_of?(Array) # => true
    a = Marker.gen("[~IN1~7~8~]")
    assert_equal OptionalGroup, a.class
    a = Marker.gen("{~IN1~7~8~}")
    assert_equal RepeatingGroup, a.class
    a = Marker.gen("[~{~IN1~7~8~}~]")
    assert_equal OptionalGroup, a.class
    # "[~{~IN1~7~8~}~]"

    #[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]
    #segment can be an array
  end

  def test_markers

    a = Marker.gen("[~IN1~7~8~]")
    assert_equal OptionalGroup, a.class

    a = Marker.gen("[~{~IN1~7~8~}~]")
    assert_equal OptionalGroup, a.class
    assert_equal RepeatingGroup, a[0].class

    p a
  end
  def test_groups_markers

   o = OptionalGroup.new('~IN1~7~8~')
   p o
  end

#  def handle_groups(segments)
#
#    #find groups and decode the group elements and put them in array
#    segments.map!{ |seg|
#      groupFound, tokens = is_group?(seg)
#      if(groupFound)
#        #substitute encoded group elements with values
#        # tokens.map!{|it| is_number?(it)? encodedSegments[it.to_i]: it}.flatten
#        tokens.map!{|it| is_number?(it)? @encodedSegments[it.to_i]: it}.flatten
#
#        handle_groups(tokens)
#        # tokens.each{|el|
#        #   p el
#        #   gp, tkns = is_group?(el)
#        #   p tokens
#        #   if(gp || is_number?(el))
#        #     p 'yes'
#        #   else
#        #     p 'no'
#        #   end
#        # }
#
#      else
#        seg
#      end
#    }
#    return segments
#  end
#
# # check if encoded segment is a group
#   def is_group?(encoded)
#     # group has an index of encoded optional element
#     isGroupWithEncodedElements = ((encoded =~ /\~\d+\~/) || is_number?(encoded)) ? true: false
#
#     # group consists of all required elements {~MRG~PV1~}, so look ahead for that
#     subGroups = encoded.split(/[~\{\[\}\]]/).delete_if{|it| blank?(it)}
#     isGroupOfRequiredElements = (subGroups.size > 1)? true: false
#
#     return (isGroupWithEncodedElements || isGroupOfRequiredElements), subGroups
#   end


end