require 'test/unit'
require 'ox'

class TemplateGeneratorTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_read_template

    templatePath = File.path('test-config/templates/ADT_A60.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    # list of segments
    segs = xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')

    map = {}
    for seg in segs
      puts seg.attributes[:Name]
      requiredFlds = []
      # list of fields
      # flds = seg.locate('Field')
      seg.locate('Field').each_with_index { |fld,idx |
        if(fld.Usage == 'R') #Usage="R"
          requiredFlds << {idx+1 => fld.attributes}
        end
      }
      map[seg.attributes[:Name]] = requiredFlds
      puts map
    end
    p map
  end

  def test_read_template_EVN

    templatePath = File.path('test-config/templates/ADT_A60_EVN.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    # list of segments
    segs = xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')

    map = {}
    for seg in segs
      puts seg.attributes[:Name]
      requiredFlds = []
      # list of fields
      # flds = seg.locate('Field')
      seg.locate('Field').each_with_index { |fld,idx |
        if(fld.Usage == 'R') #Usage="R"
            requiredFlds << {idx => fld.attributes}
        end
      }
      map[seg.attributes[:Name]] = requiredFlds
      puts map
    end
    puts map
    assert_equal(4, map.size)
  end

  def test_read_template_PID

    usages = ['R','RE']

    templatePath = File.path('test-config/templates/ADT_A60_PID.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    # list of segments
    segs = xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')

    map = {}
    for seg in segs
      puts seg.attributes[:Name]
      requiredFlds = []
      # list of fields
      # flds = seg.locate('Field')
      seg.locate('Field').each_with_index { |fld,fld_idx |
        # meta = []
        if(usages.include?(fld.Usage)) #Usage="R"
          fld.attributes.merge!(:Pos => fld_idx)

          cmps = []
          fld.locate('Component').each_with_index { |cmp,cmp_idx |
            if(usages.include?(cmp.Usage))
              cmp.attributes.merge!(:Pos => cmp_idx)

              sub_comps = []
              cmp.locate('SubComponent').each_with_index { |sub,sub_idx |
                if(usages.include?(sub.Usage))
                  sub_comps << sub.attributes.merge(:Pos => sub_idx)
                end
              }

              if(!sub_comps.empty?) then cmp.attributes.merge!(:subComponents => sub_comps) end
              if(cmp.attributes) then cmps << cmp.attributes end

            end
          }

          if(!cmps.empty?)then fld.attributes.merge!(:components => cmps)end
          requiredFlds <<  fld.attributes
        end

      }

      map[seg.attributes[:Name]] = requiredFlds
    end
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


  def find_field_exValue(fld, idx)

    if (!fld.locate('DataValues').empty?)
      {idx => fld.DataValues.attributes[:ExValue]  }
      # {fld.attributes[:ItemNo] => fld.DataValues.attributes[:ExValue]  }
    elsif (!fld.locate('Component/DataValues').empty?)
      puts fld
      {idx => fld.Component.DataValues.attributes[:ExValue]}
      # {fld.attributes[:ItemNo] => fld.Component.DataValues.attributes[:ExValue]}
    elsif ()
    end


  end

  def test_subcomponents

  pid_seg ='<Field Name="Patient Name" Usage="R" Min="1" Max="*" Datatype="XPN" Length="250" ItemNo="00108">
<Reference>3.4.2.5</Reference>
<Component Name="family name" Usage="R" Datatype="FN" Length="60">
<SubComponent Name="surname" Usage="R" Datatype="ST" Length="35">
<DataValues ExValue="SQWMGW" />
</SubComponent>
<SubComponent Name="own surname prefix" Usage="X" Datatype="ST">
</SubComponent>
<SubComponent Name="own surname" Usage="X" Datatype="ST">
</SubComponent>
<SubComponent Name="surname prefix from partner/spouse" Usage="X" Datatype="ST">
</SubComponent>
<SubComponent Name="surname from partner/spouse" Usage="X" Datatype="ST">
</SubComponent>
</Component>
<Component Name="given name" Usage="R" Datatype="ST" Length="25">
<DataValues ExValue="ALLERGIC" />
</Component>
<Component Name="second and further given names or initials thereof" Usage="RE" Datatype="ST" Length="25">
<DataValues ExValue="ONE" />
</Component>
<Component Name="suffix (e.g., JR or III)" Usage="X" Datatype="ST">
</Component>
<Component Name="prefix (e.g., DR)" Usage="X" Datatype="ST">
</Component>
<Component Name="degree (e.g., MD)" Usage="X" Datatype="IS" Table="0360">
</Component>
<Component Name="name type code" Usage="X" Datatype="ID" Table="0200">
</Component>
<Component Name="Name Representation code" Usage="X" Datatype="ID" Table="0465">
</Component>
<Component Name="name context" Usage="X" Datatype="CE" Table="0448">
<SubComponent Name="identifier" Usage="O" Datatype="ST" Table="0448">
</SubComponent>
<SubComponent Name="text" Usage="O" Datatype="ST" Length="3">
</SubComponent>
<SubComponent Name="name of coding system" Usage="O" Datatype="IS" Length="3" Table="0396">
</SubComponent>
<SubComponent Name="alternate identifier" Usage="O" Datatype="ST" Length="3">
</SubComponent>
<SubComponent Name="alternate text" Usage="O" Datatype="ST" Length="3">
</SubComponent>
<SubComponent Name="name of alternate coding system" Usage="O" Datatype="IS" Length="3" Table="0396">
</SubComponent>
</Component>
<Component Name="name validity range" Usage="X" Datatype="DR">
<SubComponent Name="range start date/time" Usage="RE" Datatype="TS" Length="3">
</SubComponent>
<SubComponent Name="range end date/time" Usage="RE" Datatype="TS" Length="3">
</SubComponent>
</Component>
<Component Name="name assembly order" Usage="X" Datatype="ID" Table="0444">
</Component>
</Field>'
    assert(false)
  end

  def test_subcomponents_1
 fld = '<Field Name="Sending Application" Usage="R" Min="1" Max="1" Datatype="HD" Length="180" Table="0361" ItemNo="00003">
<Reference>2.16.9.3</Reference>
<Component Name="namespace ID" Usage="R" Datatype="IS" Length="120" "Table="0363>
<DataValues ExValue="VISTA SQWM" />
</Component>
<Component Name="universal ID" Usage="X" Datatype="ST">
</Component>
<Component Name="universal ID type" Usage="X" Datatype="ID" Table="0301">
</Component>
</Field>'
  #   HD table 0361
  #   IS Table="0363 R
  #
  end
end