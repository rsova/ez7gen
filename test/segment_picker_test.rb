# require "minitest/autorun"
require 'test/unit'
require_relative '../lib/ez7gen/service/segment_picker'
require_relative '../lib/ez7gen/service/utils'
# require_relative '../lib/ez7gen/profile_parser'


class SegmentPickerTest < Test::Unit::TestCase
  # @@pp = ProfileParser.new('2.4', 'ADT_A01')
include Utils

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # profile = 'MSH~EVN~PID~0~1~2~PV1~3~4~5~6~7~8~9~11~12~16~17~18~19~20'
    @profile = ["MSH","EVN","PID",0,1,2,"PV1",3,4,5,6,7,8,9,11,12,16,17,19,20]

    # # Array (21 elements)
    @elements =[]
    @elements << "[~PD1~]"
    @elements << "[~{~ROL~}~]"
    @elements << "[~{~NK1~}~]"
    @elements << "[~PV2~]"
    @elements << "[~{~ROL~}~]"
    @elements << "[~{~DB1~}~]"
    @elements << "[~{~OBX~}~]"
    @elements << "[~{~AL1~}~]"
    @elements << "[~{~DG1~}~]"
    @elements << "[~DRG~]"
    @elements << "[~{~ROL~}~]"
    @elements << "[~{~PR1~10~}~]"
    @elements << "[~{~GT1~}~]"
    @elements << "[~IN2~]"
    @elements << "[~{~IN3~}~]"
    @elements << "[~{~ROL~}~]"
    @elements << "[~{~IN1~13~14~15~}~]"
    @elements << "[~ACC~]"
    @elements << "[~UB1~]"
    @elements << "[~UB2~]"
    @elements << "[~PDA~]"
    # segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(@profile, @elements)

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @segmentMap = {}
  end

  def test_init
    assert_equal 21, @segmentPicker.encodedSegments.size
    assert_equal Array, @segmentPicker.encodedSegments.class
    assert_equal Array, @segmentPicker.profile.class
  end

  def test_getSegmentCandidates
    p @segmentPicker.get_segments_to_build()

  end

  def test_getSegmentCandidatesCount
    assert_equal 11, @segmentPicker.get_load_candidates_count(21)
    assert_equal 2, @segmentPicker.get_load_candidates_count(3)
    assert_equal 5, @segmentPicker.get_load_candidates_count(10)
  end

  # def test_isGroup
  #   assert_equal true, @segmentPicker.in_group?('[~{~PR1~10~}~]')
  #   assert_equal false, @segmentPicker.in_group?('[~UB2~]')
  # end

  # def test_isRequired
  #
  # end

  def test_qetRequiredSegments
    assert_equal ["MSH", "EVN", "PID", "PV1"], @segmentPicker.get_required_segments()

    assert_equal [0,1,2,6], @segmentPicker.get_required_segment_idxs()
    segments = [0,1,2,6].map{|it| @profile[it]}
    p segments
    assert_equal ["MSH", "EVN", "PID", "PV1"], segments
  end

  # def test_handleRequiredSegments
  #   assert_equal  12, @segmentPicker.pick_optional_segments().size, '11 picked out of 21'
  # end

  def test_pickOptionalSegments
    p @segmentPicker.pick_optional_segments()
  end

  def test_getSegmentsToBuild
    p @segmentPicker.get_segments_to_build()
  end

  def test_getRequiredSegments_withZ
    # profile = 'base:MSH~base:EVN~base:PID~0~1~base:PV1~2~3~4~5~6~7~9~10~13~14~15~16~17~18~19'
    profile = ["base:MSH","base:EVN","base:PID",0,1,"base:PV1",2,3,4,5,6,7,9,10,13,14,15,16,17,18,19]

    elements = []
    elements << "[~base:PD1~]"
    elements << "[~{~base:NK1~}~]"
    elements << "[~base:PV2~]"
    elements << "[~{~base:DB1~}~]"
    elements << "[~{~base:OBX~}~]"
    elements << "[~{~base:AL1~}~]"
    elements << "[~{~base:DG1~}~]"
    elements << "[~base:DRG~]"
    elements << "[~{~base:ROL~}~]"
    elements << "[~{~base:PR1~8~}~]"
    elements << "[~{~base:GT1~}~]"
    elements << "[~base:IN2~]"
    elements << "[~base:IN3~]"
    elements << "[~{~base:IN1~11~12~}~]"
    elements << "[~base:ACC~]"
    elements << "[~base:UB1~]"
    elements << "[~base:UB2~]"
    elements << "[~ZEM~]"  #17
    elements << "[~ZEN~]"  #18
    elements << "[~ZMH~]"  #19
    # @segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(profile, elements)
    required = @segmentPicker.get_required_segments()
    expected = ["base:MSH", "base:EVN", "base:PID", "base:PV1", "[~ZEM~]", "[~ZEN~]", "[~ZMH~]"]
    assert_equal expected, required

    @segmentPicker = SegmentPicker.new(profile, elements)
    assert_equal [0, 1, 2, 5, 18, 19, 20], @segmentPicker.get_required_segment_idxs()
    reqs = [0, 1, 2, 5, 18, 19, 20].map{|it| profile[it]}
    p reqs
    assert_equal expected, reqs
  end

  def test_getSegmentsToBuild_with_repeating_required_segments
    # profile = 'MSH~EVN~PID~0~PV1~1~2~3~PID~4~PV1~5~6~7'
    profile = ["MSH","EVN","PID",0,"PV1",1,2,3,'PID',4,'PV1',5,6,7]

    elements = []
    elements <<  "[~PD1~]"
    elements <<  "[~PV2~]"
    elements <<  "[~{~DB1~}~]"
    elements <<  "[~{~OBX~}~]"
    elements <<  "[~PD1~]"
    elements <<  "[~PV2~]"
    elements <<  "[~{~DB1~}~]"
    elements <<  "[~{~OBX~}~]"

    # # @segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(profile.clone, elements.clone)
    segments = @segmentPicker.get_segments_to_build()
    #  ["MSH", "EVN", "PID", "PV1", "PID", "PV1"]
    assert_equal 1,segments.count("MSH")
    assert_equal 1, segments.count("EVN")
    assert_equal 2, segments.count("PID")
    assert_equal 2, segments.count("PV1")

    @segmentPicker = SegmentPicker.new(profile.clone, elements.clone)
    segments = @segmentPicker.get_required_segments()
    #  ["MSH", "EVN", "PID", "PV1", "PID", "PV1"]
    p segments
    assert_equal 1,segments.count("MSH")
    assert_equal 1, segments.count("EVN")
    assert_equal 2, segments.count("PID")
    assert_equal 2, segments.count("PV1")

    @segmentPicker = SegmentPicker.new(profile.clone, elements.clone)
    assert_equal [0, 1, 2, 4, 8, 10], @segmentPicker.get_required_segment_idxs()
    segments = [0, 1, 2, 4, 8, 10].map{|it| is_number?(profile[it])?@segmentPicker.encodedSegments[profile[it]]: profile[it]}
    p segments
    assert_equal 1,segments.count("MSH")
    assert_equal 1, segments.count("EVN")
    assert_equal 2, segments.count("PID")
    assert_equal 2, segments.count("PV1")
  end

  def test_getSegmentsToBuild_with_repeating_Z_segments
    # profile = 'base:MSH~base:EVN~base:PID~0~1~base:PV1~2~3~4~5~6~7~9~10~13~14~15~16~17~18~19'
    profile = ["base:MSH","base:EVN","base:PID",0,1,"base:PV1",2,3,4,5,6,7,9,10,13,14,15,16,17,18,19]

    elements = []
    elements << "[~base:PD1~]"
    elements << "[~{~base:NK1~}~]"
    elements << "[~base:PV2~]"
    elements << "[~{~base:DB1~}~]"
    elements << "[~{~base:OBX~}~]"
    elements << "[~{~base:AL1~}~]"
    elements << "[~{~base:DG1~}~]"
    elements << "[~base:DRG~]"
    elements << "[~{~base:ROL~}~]"
    elements << "[~{~base:PR1~8~}~]"
    elements << "[~{~base:GT1~}~]"
    elements << "[~base:IN2~]"
    elements << "[~base:IN3~]"
    elements << "[~{~base:IN1~11~12~}~]"
    elements << "[~ZEM~]"
    elements << "[~ZEN~]"
    elements << "[~ZMH~]"
    elements << "[~ZEM~]"  #17
    elements << "[~ZEN~]"  #18
    elements << "[~ZMH~]"  #19

    # @segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(profile.clone, elements.clone)
    segments = @segmentPicker.get_segments_to_build()
    assert_equal 1,segments.count("base:MSH")
    assert_equal 1, segments.count("base:EVN")
    assert_equal 2, segments.count("[~ZEM~]")
    assert_equal 2, segments.count("[~ZEN~]")
    assert_equal 2, segments.count("[~ZMH~]")

    @segmentPicker = SegmentPicker.new(profile.clone, elements.clone)
    segments = @segmentPicker.get_required_segments()
    assert_equal 1,segments.count("base:MSH")
    assert_equal 1, segments.count("base:EVN")
    assert_equal 2, segments.count("[~ZEM~]")
    assert_equal 2, segments.count("[~ZEN~]")
    assert_equal 2, segments.count("[~ZMH~]")


    @segmentPicker = SegmentPicker.new(profile.clone, elements.clone)
    rs = @segmentPicker.get_required_segment_idxs()
    # assert_equal [0, 1, 2, 5], @segmentPicker.get_required_segment_idxs()
    segments = rs.map{|it| is_number?(profile[it])?@segmentPicker.encodedSegments[profile[it]]: profile[it]}
    p segments
    assert_equal 1,segments.count("base:MSH")
    assert_equal 1, segments.count("base:EVN")
    assert_equal 2, segments.count("[~ZEM~]")
    assert_equal 2, segments.count("[~ZEN~]")
    assert_equal 2, segments.count("[~ZMH~]")

  end

  # def test_handleGroups
  #   # profile = ["MSH", "EVN", "PID", "[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "PV1", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~PR1~10~}~]", "[~{~GT1~}~]", "[~{~IN1~13~14~15~}~]", "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
  #   profile = ["MSH","[~{~PR1~10~}~]"]
  #   # [~{~PR1~[~{~ROL~}~]~}~] = {RP1 ~ ROL}
  #   segments = @segmentPicker.handle_groups(profile)
  #   p segments
  #   # [~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]
  # end

  def test_pickSegments
    # profile = ["MSH", "EVN", "PID", "[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "PV1", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~PR1~10~}~]", "[~{~GT1~}~]", "[~{~IN1~13~14~15~}~]", "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
    # profile = [ "[~{~PR1~10~}~]"]
    # [~{~PR1~[~{~ROL~}~]~}~] = {RP1 ~ ROL}
    segments = @segmentPicker.pick_segments
    p segments

    teardown
    setup()

    segments = @segmentPicker.pick_segments1()
    p segments
    # p @profile
    # idxs = @segmentPicker.pick_segment_idx_to_build
    # p idxs
    # segments = idxs.map{|it| is_number?(@profile[it])?@segmentPicker.encodedSegments[@profile[it]]: @profile[it]}
    # p segments
  end

  #refactoring
  # def test_get_required_segment_complex_groups
  #   p @segmentPicker.pick_required_segments1()
  #
  #   # "MSH~EVN~PID~0~1~2~PV1~3~4~5~6~7~8~9~11~12~16~17~18~19~20"
  #   # ["[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~ROL~}~]", ["PR1", "[~{~ROL~}~]"], "[~{~GT1~}~]", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]", ["IN1", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]"], "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
  #
  # end
  def test_isZ
    assert @segmentPicker.is_z?('[~ZMH~]')
    assert @segmentPicker.is_z?('[~{~ZMH~}~]')
    assert !@segmentPicker.is_z?('[~{~AL1~}~]')
    assert !@segmentPicker.is_z?('[~{~AZL1~}~]')
    # segment <<  OptionalGroup.new().concat(["PID", "[~PD1~]", "[~{~NTE~}~]", OptionalGroup.new().concat(["PV1", "[~PV2~]"]), OptionalGroup.new(RepeatingGroup.new().concat(["IN1", "[~IN2~]", "[~IN3~]"])), "[~GT1~]", "[~{~AL1~}~]"])
    elements =[]
    elements <<  RepeatingGroup.new().concat(["PID", "[~ZMH~]", "[~{~NTE~}~]", OptionalGroup.new().concat(["PV1", "[~PV2~]"]), OptionalGroup.new(RepeatingGroup.new().concat(["IN1", "[~IN2~]", "[~IN3~]"])), "[~GT1~]", "[~{~AL1~}~]"])
    # elements << segment
    @segmentPicker = SegmentPicker.new([0], elements.clone)
    # segment = segment.flatten!().to_s
    # puts (segment =~ /\~Z/)? true: false
    assert @segmentPicker.is_z1?(0)
    p elements
  end
end