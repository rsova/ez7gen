require "minitest/autorun"
require_relative '../lib/ez7gen/service/segment_picker'
# require_relative '../lib/ez7gen/profile_parser'


class SegmentPickerTest < MiniTest::Unit::TestCase
  # @@pp = ProfileParser.new('2.4', 'ADT_A01')


  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    profile = 'MSH~EVN~PID~0~1~2~PV1~3~4~5~6~7~8~9~11~12~16~17~18~19~20'
    # Array (21 elements)
    elements =[]
    elements << "[~PD1~]"
    elements << "[~{~ROL~}~]"
    elements << "[~{~NK1~}~]"
    elements << "[~PV2~]"
    elements << "[~{~ROL~}~]"
    elements << "[~{~DB1~}~]"
    elements << "[~{~OBX~}~]"
    elements << "[~{~AL1~}~]"
    elements << "[~{~DG1~}~]"
    elements << "[~DRG~]"
    elements << "[~{~ROL~}~]"
    elements << "[~{~PR1~10~}~]"
    elements << "[~{~GT1~}~]"
    elements << "[~IN2~]"
    elements << "[~{~IN3~}~]"
    elements << "[~{~ROL~}~]"
    elements << "[~{~IN1~13~14~15~}~]"
    elements << "[~ACC~]"
    elements << "[~UB1~]"
    elements << "[~UB2~]"
    elements << "[~PDA~]"
    @segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(@segmentMap)

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
    p @segmentPicker.getSegmentsToBuild()

  end

  def test_getSegmentCandidatesCount
    assert_equal 11, @segmentPicker.getLoadCandidatesCount(21)
    assert_equal 2, @segmentPicker.getLoadCandidatesCount(3)
    assert_equal 5, @segmentPicker.getLoadCandidatesCount(10)
  end

  def test_isGroup
    assert_equal true, @segmentPicker.isGroup?('[~{~PR1~10~}~]')
    assert_equal false, @segmentPicker.isGroup?('[~UB2~]')
  end

  # def test_isRequired
  #
  # end

  def test_qetRequiredSegments
    assert_equal ["MSH", "EVN", "PID", "PV1"], @segmentPicker.getRequiredSegments()
  end

  # def test_handleRequiredSegments
  #   assert_equal  12, @segmentPicker.pickOptionalSegments().size, '11 picked out of 21'
  # end

  def test_pickOptionalSegments
    p @segmentPicker.pickOptionalSegments([])
  end

  def test_getSegmentsToBuild
    p @segmentPicker.getSegmentsToBuild()
  end

  def test_getRequiredSegments_withZ
    #profilebase:MSH~base:EVN~base:PID~0~1~base:PV1~2~3~4~5~6~7~9~10~13~14~15~16~17~18~19
    # [0] = "[~base:PD1~]"
    # [1] = "[~{~base:NK1~}~]"
    # [2] = "[~base:PV2~]"
    # [3] = "[~{~base:DB1~}~]"
    # [4] = "[~{~base:OBX~}~]"
    # [5] = "[~{~base:AL1~}~]"
    # [6] = "[~{~base:DG1~}~]"
    # [7] = "[~base:DRG~]"
    # [8] = "[~{~base:ROL~}~]"
    # [9] = "[~{~base:PR1~8~}~]"
    # [10] = "[~{~base:GT1~}~]"
    # [11] = "[~base:IN2~]"
    # [12] = "[~base:IN3~]"
    # [13] = "[~{~base:IN1~11~12~}~]"
    # [14] = "[~base:ACC~]"
    # [15] = "[~base:UB1~]"
    # [16] = "[~base:UB2~]"
    # [17] = "[~ZEM~]"
    # [18] = "[~ZEN~]"
    # [19] = "[~ZMH~]"
    profile = 'base:MSH~base:EVN~base:PID~0~1~base:PV1~2~3~4~5~6~7~9~10~13~14~15~16~17~18~19'
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
    @segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(@segmentMap)
    required = @segmentPicker.getRequiredSegments()
    assert_equal ["base:MSH", "base:EVN", "base:PID", nil, nil, "base:PV1", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "[~ZEM~]", "[~ZEN~]", "[~ZMH~]", nil], required
    assert_equal ["base:MSH", "base:EVN", "base:PID", "base:PV1", "[~ZEM~]", "[~ZEN~]", "[~ZMH~]"], required.compact()

  end

  def test_getSegmentsToBuild_with_repeating_required_segments

    elements = []
    elements <<  "[~PD1~]"
    elements <<  "[~PV2~]"
    elements <<  "[~{~DB1~}~]"
    elements <<  "[~{~OBX~}~]"
    elements <<  "[~PD1~]"
    elements <<  "[~PV2~]"
    elements <<  "[~{~DB1~}~]"
    elements <<  "[~{~OBX~}~]"

    # [0] = "MSH"
    # [1] = "EVN"
    # [2] = "PID"
    # [3] = "0"
    # [4] = "PV1"
    # [5] = "1"
    # [6] = "2"
    # [7] = "3"
    # [8] = "PID"
    # [9] = "4"
    # [10] = "PV1"
    # [11] = "5"
    # [12] = "6"
    # [13] = "7"
    profile = 'MSH~EVN~PID~0~PV1~1~2~3~PID~4~PV1~5~6~7'

    @segmentMap = {:segments => elements, :profile => profile}
    @segmentPicker = SegmentPicker.new(@segmentMap)
    segments = @segmentPicker.getSegmentsToBuild()
    #  ["MSH", "EVN", "PID", "PV1", "PID", "PV1"]
    assert_equal 1,segments.count("MSH")
    assert_equal 1, segments.count("EVN")
    assert_equal 2, segments.count("PID")
    assert_equal 2, segments.count("PV1")

  end

end