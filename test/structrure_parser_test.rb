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
    assert_equal ["[~ERR~]", "[~PID~2~3~]", "[~PD1~]", "[~QRI~]", "[~DSC~]", "{~1~}"], parser.encodedSegments
    # p parser.encodedSegments
    assert_equal "MSH~MSA~0~QAK~QPD~5~4", struct
    #p struct

    # ["[~ERR~]", "[~PD1~]", "[~QRI~]", "[~PID~1~2~]", "{~3~}", "[~DSC~]"]
    #["MSH", "MSA", 0, "QAK", "QPD", 4, 5]
  end

 def test_process_struct
   #omg_019
   parser = StructureParser.new()
   struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
   # regEx = parser::REGEX_REP
   # parser.process(struct, regEx, parser::PRNTHS_REP)# {}
   parser.process_struct(struct)
   assert_equal 33,parser.idx
   assert_equal 33,parser.encodedSegments.size
   p parser.encodedSegments
   puts struct
   expected =["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~31~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
   assert_equal expected, parser.encodedSegments
   # ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]

 end

  def test_process_struct_ADT_A01
    struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    parser = StructureParser.new()
    parser.process_struct(struct)
    assert_equal 21, parser.idx
    assert_equal 21, parser.encodedSegments.size
    p parser.encodedSegments
    # p struct
    # expected = ["MSH", "EVN", "PID", 0, 1, 2, "PV1", 3, 4, 5, 6, 7, 8, 9, 11, 12, 16, 17, 18, 19, 20]
    assert_equal "MSH~EVN~PID~0~1~2~PV1~3~4~5~6~7~8~9~10~12~13~17~18~19~20", struct
    expected = ["[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~PR1~11~}~]", "[~{~ROL~}~]", "[~{~GT1~}~]", "[~{~IN1~14~15~16~}~]", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]", "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
    assert_equal expected, parser.encodedSegments

    # old = ["[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~ROL~}~]", "[~{~PR1~10~}~]", "[~{~GT1~}~]", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]", "[~{~IN1~13~14~15~}~]", "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
    # assert_equal expected, parser.encodedSegments
  end

  def test_handle_groups
    # arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]
    #arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "~17~19~21~31~", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "{~17~19~21~31~}", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    # MSH~0~1~29
    parser = StructureParser.new()

    parser.encodedSegments = arr
    parser.idx=parser.encodedSegments.size

    seg = parser.handle_groups(arr)
    p parser.encodedSegments
    expected = ["[~{~NTE~}~]", ["PID", "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], [["IN1", "[~IN2~]", "[~IN3~]"]], "[~GT1~]", "[~{~AL1~}~]"], "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], "[~PV2~]", [["IN1", "[~IN2~]", "[~IN3~]"]], "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", [["OBX", "[~{~NTE~}~]"]], "[~{~NTE~}~]", [["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]], ["PID", "[~PD1~]"], "[~PD1~]", ["PV1", "[~PV2~]"], "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", ["ORC", "OBR", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", [["OBX", "[~{~NTE~}~]"]], [[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]], "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]"], [[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]], ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]], ["OBX", "[~{~NTE~}~]"]]
    assert_equal expected, parser.encodedSegments

  end

  def test_handle_groups_optMult
    arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "{~17~19~21~31~}", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    # MSH~0~1~29
    parser = StructureParser.new()

    parser.encodedSegments = arr
    parser.idx=parser.encodedSegments.size

    seg = parser.handle_groups(["[~PID~2~3~4~6~9~10~]"])
    assert_equal( [["PID", "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], [["IN1", "[~IN2~]", "[~IN3~]"]], "[~GT1~]", "[~{~AL1~}~]"]], seg)
    # p seg
  end

  def test_is_group_resolved
    arr = ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]

    seg = "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]"
    assert_equal 1, seg.scan(StructureParser::REGEX_OP).size()
    assert_equal 2, seg.scan(StructureParser::REGEX_REP).size()

    assert (seg.scan(StructureParser::REGEX_OP).size()>1 || seg.scan(StructureParser::REGEX_REP).size()>1)
  end

  def test_has_subgroups
    a = nil || 'a'

    regEx = /\[~{(.*)}~\]/
    puts "[~{~NTE~}~]".scan(regEx)
    puts "[~ERR~]".scan(regEx)
    parser = StructureParser.new()

    arr = ["[~ERR~]", "[~{~NTE~}~]", "[~3~{~ORC~5~}~]", "[~PID~4~]", "[~{~NTE~}~]", "[~RXE~{~RXR~}~6~]", "[~{~RXC~}~]"]
    assert !parser.has_subgroups?(arr[0])
    assert !parser.has_subgroups?(arr[1])
    assert parser.has_subgroups?(arr[2])
    p arr[2].scan(StructureParser::REGEX_OP)
    p arr[2].scan(StructureParser::REGEX_REP)

    assert !parser.has_subgroups?(arr[3])
    assert !parser.has_subgroups?(arr[4])
    assert parser.has_subgroups?(arr[5])
    assert !parser.has_subgroups?(arr[6])

    assert parser.has_subgroups?("[~{~RXA~}~RXR~]")
  end

  def test_process_segments_ORM_O01
    parser = StructureParser.new()
    # struct='MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~[~&lt;~OBR~|~RQD~|~RQ1~|~RXO~|~ODS~|~ODT~&gt;~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~]~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
    # struct='MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~[~<~OBR~|~RQD~|~RQ1~|~RXO~|~ODS~|~ODT~>~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~]~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
    struct='MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~[~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~]~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
    parser.process_segments(struct)
    assert_equal 'MSH~0~1~20', struct
    # expected = ["[~{~NTE~}~]", ["PID", "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], [["IN1", "[~IN2~]", "[~IN3~]"]], "[~GT1~]", "[~{~AL1~}~]"], "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], "[~PV2~]", [["IN1", "[~IN2~]", "[~IN3~]"]], "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", [["OBX", "[~{~NTE~}~]"]], "[~{~NTE~}~]", [["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]], ["PID", "[~PD1~]"], "[~PD1~]", ["PV1", "[~PV2~]"], "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", ["ORC", "OBR", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", [["OBX", "[~{~NTE~}~]"]], [[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]], "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]"], [[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]], ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]], ["OBX", "[~{~NTE~}~]"]]
    # assert_equal expected, parser.encodedSegments
   p parser.encodedSegments
  end

  def test_process_segments_RDE_O11
    parser = StructureParser.new()
    struct='MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~[~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~RXE~{~RXR~}~[~{~RXC~}~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~CTI~}~]~}'
    # parser.process_segments(struct)
    # assert_equal 'MSH~0~1~19', struct
    # z=parser.process_struct(struct)
    # p z
    # ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~RXO~12~{~RXR~}~13~]", "[~{~NTE~}~]", "[~{~RXC~}~14~]", "[~{~NTE~}~]", "[~{~RXC~}~]", "[~{~OBX~17~}~]", "[~{~NTE~}~]", "[~{~CTI~}~]", "{~ORC~11~RXE~20~15~16~18~}", "{~RXR~}"]
    # parser.handle_groups()
    # assert_equal expected, parser.encodedSegments
  end

  def test_process_segments_OMG_O19
    #omg_019
    parser = StructureParser.new()
    struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
    parser.process_segments(struct)
    assert_equal 'MSH~0~1~29', struct
    expected = ["[~{~NTE~}~]", ["PID", "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], [["IN1", "[~IN2~]", "[~IN3~]"]], "[~GT1~]", "[~{~AL1~}~]"], "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], "[~PV2~]", [["IN1", "[~IN2~]", "[~IN3~]"]], "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", [["OBX", "[~{~NTE~}~]"]], "[~{~NTE~}~]", [["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]], ["PID", "[~PD1~]"], "[~PD1~]", ["PV1", "[~PV2~]"], "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", ["ORC", "OBR", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", [["OBX", "[~{~NTE~}~]"]], [[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]], "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]"], [[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]], ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]], ["OBX", "[~{~NTE~}~]"]]
    assert_equal expected, parser.encodedSegments
  end

  def test_is_complex_group

    a = OptionalGroup.new([1,2,3])
    assert_equal(OptionalGroup, a.class)
    assert a.instance_of?(OptionalGroup)
    assert !a.instance_of?(Array)
    a.each{|it| puts it}
    assert a.kind_of?(Array) # => true

    group = "[~IN1~7~8~]"
    a = Marker.gen(group)
    assert_equal OptionalGroup, a.class
    a = Marker.whatGroup?(group)
    assert_equal OptionalGroup, a.class

    group = "{~IN1~7~8~}"
    a = Marker.gen(group)
    assert_equal RepeatingGroup, a.class
    a = Marker.whatGroup?(group)
    assert_equal RepeatingGroup, a.class

    group = "[~{~IN1~7~8~}~]"
    a = Marker.gen(group)
    assert_equal OptionalGroup, a.class
    a = Marker.whatGroup?(group)
    assert_equal OptionalGroup, a.class

    group = "~IN1~7~8~"
    a = Marker.gen(group)
    assert_nil a
    a = Marker.whatGroup?(group)
    assert_nil a

    # group ='[~{~NTE~}~]' # not a group!
    # a = Marker.gen(group)
    # assert_nil a
    # a = Marker.whatGroup?(group)
    # assert_nil a

      # "[~{~IN1~7~8~}~]"

    # a = Marker.gen("[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]")
    # p a
    # a = Marker.new("[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]")
    # p a
    #[["PID", "[~PD1~]"], ["PV1", "[~PV2~]"], "[~{~AL1~}~]", ["[~ORC~]", "OBR", "[~{~NTE~}~]", "[~CTD~]", ["OBX", "[~{~NTE~}~]"]]]
    #segment can be an array
  end

  def test_markers

    # [RXE~{~RXR~}~6]
    a = Marker.gen1("[~RXE~{~RXR~}~6~]")
    assert_equal OptionalGroup, a.class
    # assert_equal RepeatingGroup, a[0].class

    a = Marker.gen("[~IN1~7~8~]")
    assert_equal OptionalGroup, a.class

    a = Marker.gen("{~IN1~7~8~}")
    assert_equal RepeatingGroup, a.class

    a = Marker.gen("[~{~IN1~7~8~}~]")
    assert_equal OptionalGroup, a.class
    assert_equal RepeatingGroup, a[0].class


  end

  def test_groups_markers
   o = OptionalGroup.new('~IN1~7~8~')
   assert_equal 3, o.size

   o = OptionalGroup.new().concat(['a','b','c'])
   assert_equal 3, o.size

   RepeatingGroup.new('~IN1~7~8~')
   assert_equal 3, o.size
  end

  def test_process_struct_PRE_012

    parser = StructureParser.new()
    # struct = '[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXE~{~RXR~}~[~{~RXC~}~]~]~}~]'
    struct = 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXE~{~RXR~}~[~{~RXC~}~]~]~}~]'
    # struct = 'RXE~{~RXR~}~6'
    parser.process_struct(struct)
    # assert_equal 33,parser.idx
    # assert_equal 33,parser.encodedSegments.size
    p parser.encodedSegments
    puts struct
    # expected =["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "{~17~19~21~31~}", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}", "{~22~OBR~23~24~32~}", "{~OBX~25~}"]
    # assert_equal expected, parser.encodedSegments
    # ["[~{~NTE~}~]", "[~PID~2~3~4~6~9~10~]", "[~PD1~]", "[~{~NTE~}~]", "[~PV1~5~]", "[~PV2~]", "[~{~IN1~7~8~}~]", "[~IN2~]", "[~IN3~]", "[~GT1~]", "[~{~AL1~}~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~DG1~}~]", "[~{~OBX~15~}~]", "[~{~NTE~}~]", "[~17~19~21~{~22~OBR~23~24~{~OBX~25~}~}~]", "[~PID~18~]", "[~PD1~]", "[~PV1~20~]", "[~PV2~]", "[~{~AL1~}~]", "[~ORC~]", "[~{~NTE~}~]", "[~CTD~]", "[~{~NTE~}~]", "[~{~FT1~}~]", "[~{~CTI~}~]", "[~BLG~]", "{~ORC~OBR~11~12~13~14~30~26~27~28~}", "{~16~}"]
    # [~RXE~{~RXR~}~6~]
    seg = parser.handle_groups(parser.encodedSegments)
    # assert_equal( [["PID", "[~PD1~]", "[~{~NTE~}~]", ["PV1", "[~PV2~]"], [["IN1", "[~IN2~]", "[~IN3~]"]], "[~GT1~]", "[~{~AL1~}~]"]], seg)
    # ["[~ERR~]", "[~{~NTE~}~]", "[~3~{~ORC~5~}~]", "[~PID~4~]", "[~{~NTE~}~]", "[~RXE~{~RXR~}~6~]", "[~{~RXC~}~]"]

    # seg = parser.handle_groups(["[~RXE~{~RXR~}~6~]"])
     p seg
  end
  def test_process_struct_PRE_018

    parser = StructureParser.new()
    struct = 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~{~RXA~}~RXR~]~}~]'

    parser.process_struct(struct)
    p parser.encodedSegments
    puts struct
    seg = parser.handle_groups(parser.encodedSegments)
    p seg
  end

  def test_process_struct_ADT_A45

    parser = StructureParser.new()
    struct = 'MSH~EVN~PID~[~PD1~]~{~MRG~PV1~}'

    parser.process_struct(struct)
    p parser.encodedSegments
    puts struct
    seg = parser.handle_groups(parser.encodedSegments)
    p seg
  end

  # def test_process_struct_ORL_O22
  #   parser = StructureParser.new()
  #   struct = 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~{~[~SAC~[~{~OBX~}~]~]~[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~}~]~]'
  #   # [~OBR~8~] -broken
  #   parser.process_struct(struct)
  #   p parser.encodedSegments
  #   puts struct
  #   seg = parser.handle_groups(parser.encodedSegments)
  #   p seg
  # end

  end