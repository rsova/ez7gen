# require "minitest/autorun"
require 'test/unit'
require_relative "../lib/ez7gen/message_factory"
require_relative "../lib/ez7gen/version"

class MessageFactoryTemplate24Test < Test::Unit::TestCase


  # alias :orig_run :run
  # def run(*args,&blk)
  #   10.times { orig_run(*args,&blk) }
  # end

  # set to true to write messages to a file
  # @@PERSIST = true

  @@VS =
      [
          # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml"}]},
          {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]


  # helper message to persist the
  def saveMsg(event, hl7, ver)
    # if(defined?(@@PERSIST) && @@PERSIST) then
    #   # File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
    #   File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%Y%m%d%H%M%S%L')}.txt", hl7);
    # end
  end


  def test_ADT_A60_no_ExValue
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='ADT_A60'
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista sqwm-adt_a60.xml"
    hl7 = factory.generate() #     useExValue = false by default
    # saveMsg(Ez7gen::VERSION+event, hl7, ver)

    puts hl7
    assert_equal 'MSH', hl7[0].e0
    assert_equal 'EVN', hl7[1].e0
    assert_equal 'PID', hl7[2].e0
    assert_equal 'IAM', hl7[3].e0
  end

  def test_ADT_A60_ExValue
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='ADT_A60'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista sqwm-adt_a60.xml"
    # factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista+sqwm-adt_a60 (1).xml"
    # factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista+sqwm-adt_a60 (2).xml"
    #factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS})

    hl7 = factory.generate(useExValue)
    # saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    assert_equal 'MSH|^~\&|VISTA SQWM|442^HL7.CHEYENNE.MED.VA.GOV:5274^DNS|SQWM|442^VAAUSSQWAPP80:8010^DNS|20040328134602.1234+0600||ADT^A60^ADT_A60|442 744187|T|2.4|||AL|NE', hl7[0].to_s
    assert_equal 'EVN||20140325164408-0400', hl7[1].to_s
    assert_equal 'PID|||7209590^4^M10^USCDC&&L^PI^USCDC^20140325||SQWMGW^ALLERGIC^ONE||19880301|M||2054-5-SLF^^UPC^2054-5^^UPC|100 MAIN STREET^^PORTLAND^OR^76100|||||M|29|||||2186-5-SLF^^ACR^2186-5^^ART', hl7[2].to_s
    assert_equal 'IAM|2|F|GLUTENS|MO|DROWSY|U|168;GMRD(120.82,', hl7[3].to_s
  end

  def test_ADT_A60_ExValue_Race
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='ADT_A60'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista sqwm-adt_a60_race.xml"
    #factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS})

    hl7 = factory.generate(useExValue)
    # saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    assert_equal 'MSH|^~\&|VISTA SQWM|442^HL7.CHEYENNE.MED.VA.GOV:5274^DNS|SQWM|442^VAAUSSQWAPP80:8010^DNS|20040328134602.1234+0600||ADT^A60^ADT_A60|442 744187|T|2.4|||AL|NE', hl7[0].to_s
    assert_equal 'EVN||20140325164408-0400', hl7[1].to_s
    assert_equal 'PID|||7209590^4^M10^USCDC&&L^PI^USCDC^20140325||SQWMGW^ALLERGIC^ONE||19880301|M||2054-5-SLF^^UPC^2054-5^^UPC|100 MAIN STREET^^PORTLAND^OR^76100|||||M|29|||||2186-5-SLF^^ACR^2186-5^^ART', hl7[2].to_s
    assert_equal 'IAM|2|F|GLUTENS|MO|DROWSY|U|168;GMRD(120.82,', hl7[3].to_s
  end


  def test_ORF_Z11_231
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='ORF_Z11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    # factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista+sqwm-adt_a60 (1).xml"
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/ORF_Z11_2_3_1.xml"
    #factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS})

    hl7 = factory.generate(useExValue)
    # saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH|^~\&|VISTA SQWM|442^HL7.CHEYENNE.MED.VA.GOV:5274^DNS|SQWM|442^VAAUSSQWAPP80:8010^DNS|20040328134602.1234+0600||ADT^A60^ADT_A60|442 744187|T|2.4|||AL|NE', hl7[0].to_s
    # assert_equal 'EVN||20140325164408-0400', hl7[1].to_s
    # assert_equal 'PID|||7209590^4^M10^USCDC&&L^PI^USCDC^20140325||SQWMGW^ALLERGIC^ONE||19880301|M||2054-5-SLF^^UPC^2054-5^^UPC|100 MAIN STREET^^PORTLAND^OR^76100|||||M|29|||||2186-5-SLF^^ACR^2186-5^^ART', hl7[2].to_s
    # assert_equal 'IAM|2|F|GLUTENS|MO|DROWSY|U|168;GMRD(120.82,', hl7[3].to_s
  end

  def test_DFT_P11_PY_25
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='DFT_P11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    # factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista+sqwm-adt_a60 (1).xml"
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/DFT_P11_PY_2_5.xml"
    #factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS})

    hl7 = factory.generate(useExValue)
    # saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH|^~\&|VISTA SQWM|442^HL7.CHEYENNE.MED.VA.GOV:5274^DNS|SQWM|442^VAAUSSQWAPP80:8010^DNS|20040328134602.1234+0600||ADT^A60^ADT_A60|442 744187|T|2.4|||AL|NE', hl7[0].to_s
    # assert_equal 'EVN||20140325164408-0400', hl7[1].to_s
    # assert_equal 'PID|||7209590^4^M10^USCDC&&L^PI^USCDC^20140325||SQWMGW^ALLERGIC^ONE||19880301|M||2054-5-SLF^^UPC^2054-5^^UPC|100 MAIN STREET^^PORTLAND^OR^76100|||||M|29|||||2186-5-SLF^^ACR^2186-5^^ART', hl7[2].to_s
    # assert_equal 'IAM|2|F|GLUTENS|MO|DROWSY|U|168;GMRD(120.82,', hl7[3].to_s
  end

end