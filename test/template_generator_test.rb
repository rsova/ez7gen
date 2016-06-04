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
    usages = ['R','RE']

    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    p map
    assert_equal(4, map.size)
    assert_equal 'Recorded Date/Time', map['EVN'].first[:Name]
    assert_equal '20', map['EVN'].first[:components].first[:Length]

  end

  def test_read_template_EVN

    templatePath = 'test-config/templates/ADT_A60_EVN.xml'
    usages = ['R','RE']
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)

    puts map
    assert_equal(4, map.size)
    assert_equal 'Recorded Date/Time', map['EVN'].first[:Name]
    assert_equal '20', map['EVN'].first[:components].first[:Length]
  end

  def test_read_template_PID

    templatePath = 'test-config/templates/ADT_A60_PID.xml'
    usages = ['R','RE']
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    # p map
    assert_equal 1, map.size
    assert_equal 9, map['PID'].size

    # puts map
    puts map['PID']
    puts
    assert_equal 0, map['PID'].first[:components].first[:Pos]
    assert_equal 0, map['PID'].first[:components].first[:Pos]
    puts map['PID'][1][:components]
    puts
    puts map['PID'][1][:components][0][:subComponents]
    # map['PID'].first[2][:components].each {|it| p it.keys}
    # puts map['PID'].first[4]
  end

  def test_read_template_MFN_M01

    usages = ['R','RE']
    templatePath = 'test-config/templates/2.4/eiv table update-mfn_m01 20151201.xml'
    map = TemplateGenerator.new(templatePath,{'primary' => @@pp }).build_template_metadata( usages)
    p map
    assert_equal 3, map.size
    assert_equal 3, map['MFI'].size
    assert_equal 5, map['MFE'].size
  end

  # End of tests, supporting methods to be moved to the class
  # def build_template_metadata(path, usages)
  #   text = File.path(path)
  #   xml = Ox.parse(IO.read(text))
  #
  #   # list of segments
  #   segs = xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')
  #
  #   map = {}
  #   for seg in segs
  #
  #     puts seg.attributes[:Name]
  #     meta = []
  #     # list of fields
  #     seg.locate('Field').each_with_index { |fld, fld_idx|
  #       if (usages.include?(fld.Usage)) #Usage="R"
  #         fld.attributes.merge!(:Pos => fld_idx)
  #
  #         cmps = []
  #         fld.locate('Component').each_with_index { |cmp, cmp_idx|
  #
  #           if (usages.include?(cmp.Usage))
  #
  #             cmp.attributes.merge!(:Pos => cmp_idx)
  #
  #             sub_comps = []
  #             cmp.locate('SubComponent').each_with_index { |sub, sub_idx|
  #               if (usages.include?(sub.Usage))
  #                 sub_comps << sub.attributes.merge(:Pos => sub_idx)
  #               end
  #             }# end locate SubComponent
  #
  #             if (!sub_comps.empty?) then
  #               cmp.attributes.merge!(:subComponents => sub_comps)
  #             end
  #             if (cmp.attributes) then
  #               cmps << cmp.attributes
  #             end
  #
  #           end
  #         }# end locate Component
  #
  #         if (!cmps.empty?) then
  #           fld.attributes.merge!(:components => cmps)
  #         end
  #
  #         meta << fld.attributes
  #       end
  #
  #     }# end locate Field
  #
  #     map[seg.attributes[:Name]] = meta
  #   end
  #
  #   return map
  # end
  #
  #
  # def find_field_exValue(fld, idx)
  #
  #   if (!fld.locate('DataValues').empty?)
  #     {idx => fld.DataValues.attributes[:ExValue]  }
  #     # {fld.attributes[:ItemNo] => fld.DataValues.attributes[:ExValue]  }
  #   elsif (!fld.locate('Component/DataValues').empty?)
  #     puts fld
  #     {idx => fld.Component.DataValues.attributes[:ExValue]}
  #     # {fld.attributes[:ItemNo] => fld.Component.DataValues.attributes[:ExValue]}
  #   elsif ()
  #   end
  #
  # end

end