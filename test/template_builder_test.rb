require 'test/unit'
require 'ox'

class TemplateBuilderTest < Test::Unit::TestCase

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

  def test_read_tmplate
    # File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%Y%m%d%H%M%S%L')}.txt", hl7);

    templatePath = File.path('test-config/templates/ADT_A60.xml')
    xml = Ox.parse(IO.read(templatePath))
    segs = xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')
    assert_not_nil (xml)

    map = {}
    for seg in segs
        puts seg.attributes[:Name]
        flds = []
        seg.locate('Field').each { |fld|
          flds << find_field_exValue(fld)
        }
      # map.put(seg.attributes[:Name], flds)
      map[seg.attributes[:Name]] = flds
      puts map
    end
    puts map
  end

  def find_field_exValue(fld)

    if (!fld.locate('DataValues').empty?)
      {fld.attributes[:ItemNo] => fld.DataValues.attributes[:ExValue]  }
    elsif (!fld.locate('Component/DataValues').empty?)
      puts fld
      {fld.attributes[:ItemNo] => fld.Component.DataValues.attributes[:ExValue]}
    # else
    #   nil
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

end