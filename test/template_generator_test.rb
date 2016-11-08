require 'test/unit'
require 'ox'

require_relative '../lib/ez7gen/service/template_generator'
require_relative '../lib/ez7gen/profile_parser'



class TemplateGeneratorTest < Test::Unit::TestCase
  @@VS =
      [
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]
  @attrs = {std: '2.4', version: '2.4.HL7', event: 'ADT_A01', version_store: @@VS}
  @@pp = ProfileParser.new(@attrs)

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # @attrs = {std: '2.4', version: '2.4.HL7', event: 'ADT_A01'}
    # @pp = [ProfileParser.new(@attrs)]
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    @pp = nil
  end

  def test_read_template_ADT_A60
    templatePath = 'test-config/templates/ADT_A60.xml'

    useExVal = false
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_metadata(useExVal)

    p map
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    p map
    assert_equal(4, map.size)
    assert_equal 'Recorded Date/Time', map['EVN'].first[:Name]
    assert_equal '20', map['EVN'].first[TemplateGenerator::COMP].first[:Length]

  end

  def test_read_template_EVN

    templatePath = 'test-config/templates/ADT_A60_EVN.xml'
    useExVal = false
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_metadata(useExVal)
    #map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    puts map
    assert_equal(4, map.size)
    assert_equal 'Recorded Date/Time', map['EVN'].first[:Name]
    assert_equal '20', map['EVN'].first[TemplateGenerator::COMP].first[:Length]
  end

  def test_read_template_PID

    templatePath = 'test-config/templates/ADT_A60_PID.xml'
    useExVal = false
    tg = TemplateGenerator.new(templatePath,{'primary' => @@pp })
    # tg.class.const_set('USAGES_REQ', [])
    map = tg.build_metadata(useExVal)

    # TemplateGenerator.USAGES_REQ = ['R','RE']
    # map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    # p map
    assert_equal 1, map.size
    assert_equal 9, map['PID'][0].size

    # puts map
    puts map['PID']
    puts
    assert_equal 0, map['PID'].first[TemplateGenerator::COMP].first[:Pos]
    assert_equal 0, map['PID'].first[TemplateGenerator::COMP].first[:Pos]
    puts map['PID'][1][TemplateGenerator::COMP]
    puts
    puts map['PID'][1][TemplateGenerator::COMP][0][TemplateGenerator::SUB]
    # map['PID'].first[2][:components].each {|it| p it.keys}
    # puts map['PID'].first[4]
  end

  def test_read_template_PID_1

    templatePath = 'test-config/templates/ADT_A60_PID.xml'
    useExVal = false
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_metadata(useExVal)

    puts map
    assert_equal 1, map.size
    assert_equal 9, map['PID'][0].size

    # puts map
    puts map['PID']
    puts
    assert_equal 0, map['PID'].first[TemplateGenerator::COMP].first[:Pos]
    assert_equal 0, map['PID'].first[TemplateGenerator::COMP].first[:Pos]
    puts map['PID'][1][TemplateGenerator::COMP]
    puts
    puts map['PID'][1][TemplateGenerator::COMP][0][TemplateGenerator::SUB]
    # map['PID'].first[2][:components].each {|it| p it.keys}
    # puts map['PID'].first[4]
  end

  def test_read_template_MFN_M01

    templatePath = 'test-config/templates/2.4/eiv table update-mfn_m01 20151201.xml'
    usages = ['R','RE']
    useExVal = false
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_metadata(useExVal)
    # map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    p map
    assert_equal 3, map.size
    assert_equal 3, map['MFI'].size
    assert_equal 5, map['MFE'].size
  end

  def test_get_metadata_EVN

    # templatePath = 'test-config/templates/ADT_A60_EVN_only.xml'
    templatePath = 'test-config/templates/ADT_A60_EVN.xml'
    usages = ['R','RE']
    useExVal = false
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_metadata(useExVal)

    puts map
    # assert_equal(4, map.size)
    assert_equal 'Recorded Date/Time', map['EVN'].first[:Name]
    assert_equal '20', map['EVN'].first[TemplateGenerator::COMP].first[:Length]
    # {"MSH"=>[],
    # "EVN"=>[
    #  {:Name=>"Recorded Date/Time", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :ItemNo=>"00100", :Pos=>1,
    #   :components=>[
    #     {:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"20", :Pos=>0}
    #    ]
    #   }
    # ],
    # "PID"=>[],
    # "IAM"=>[]}

    # {"MSH"=>[{:Name=>"MSH", :LongName=>"Message Header", :Usage=>"R", :Min=>"1", :Max=>"1"}],
    # "EVN"=>[
    # {"Field"=>[[{"Component"=>[[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"20", :Pos=>0}]]}]]}],

    # "PID"=>[{:Name=>"PID", :LongName=>"Patient identification", :Usage=>"R", :Min=>"1", :Max=>"1"}], "IAM"=>[{:Name=>"IAM", :LongName=>"Patient adverse reaction information - unique iden", :Usage=>"R", :Min=>"1", :Max=>"*"}]}

  end

  def test_use
    templatePath = 'test-config/templates/ADT_A60_EVN.xml'
    tg = TemplateGenerator.new(templatePath,{'primary' => @@pp })
    assert_true  tg.use?('R')
    assert_true [true, false].include? tg.use?('RE') # could be either

    tg.class.const_set('USAGES_REQ', ['R','RE']) # force to build both for testing
    assert_true tg.use?('RE')

    assert_false tg.use?('X')

  end


end