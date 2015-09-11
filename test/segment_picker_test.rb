require "minitest/autorun"
require_relative '../lib/ez7gen/service/segment_picker'
require_relative '../lib/ez7gen/profile_parser'


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
    @segmentMap = {'segments'=>elements, 'profile' => profile}
    @segmentPicker = SegmentPicker.new(@segmentMap)

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @segmentMap = {}
  end

  def test_init
    assert_equal 21, @segmentPicker.segments.size
    assert_equal Array, @segmentPicker.segments.class
    assert_equal String, @segmentPicker.profile.class
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
   assert_equal true,  @segmentPicker.isGroup?('[~{~PR1~10~}~]')
   assert_equal false,  @segmentPicker.isGroup?('[~UB2~]')
  end


end