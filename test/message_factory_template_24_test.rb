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
    if(defined?(@@PERSIST) && @@PERSIST) then
      # File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
      File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%Y%m%d%H%M%S%L')}.txt", hl7);
    end
  end

  #  ADT_A60, QBP_Q11(3), RTB_K13 (2), DFT_P03, ACK_P03, ORU_R01(2)

  def test_ADT_A60_no_ExValue
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='ADT_A60'
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/vista sqwm-adt_a60.xml"
    hl7 = factory.generate() #     useExValue = false by default
    saveMsg(Ez7gen::VERSION+event, hl7, ver)

    puts hl7
    assert_equal 'MSH', hl7[0].e0
    assert_equal 'EVN', hl7[1].e0
    assert_equal 'PID', hl7[2].e0
    assert_equal 'IAM', hl7[3].e0

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
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
    saveMsg(Ez7gen::VERSION+event, hl7, ver)

    puts hl7
    assert_equal 'MSH|^~\&|VISTA SQWM|442^HL7.CHEYENNE.MED.VA.GOV:5274^DNS|SQWM|442^VAAUSSQWAPP80:8010^DNS|20040328134602.1234+0600||ADT^A60^ADT_A60|442 744187|T|2.4|||AL|NE', hl7[0].to_s
    assert_equal 'EVN||20140325164408-0400', hl7[1].to_s
    assert_equal 'PID|||7209590^4^M10^USCDC&&L^PI^USCDC^20140325||SQWMGW^ALLERGIC^ONE||19880301|M||2054-5-SLF^^UPC^2054-5^^UPC|100 MAIN STREET^^PORTLAND^OR^76100|||||M|29|||||2186-5-SLF^^ACR^2186-5^^ART', hl7[2].to_s
    assert_equal 'IAM|2|F|GLUTENS|MO|DROWSY|U|168;GMRD(120.82,', hl7[3].to_s

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
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

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
  end

  def test_QBP_Q11_diagnosis
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='QBP_Q11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/mhvsm_standardhl7lib_diagnosis_query_qbp_q11-qbp_q11.xml"

    hl7 = factory.generate(useExValue)
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    assert_equal hl7[0].to_s, 'MSH|^~\&|MHV SM|200MHS^SYS.MHV.MED.VA.GOV^DNS|MHV VISTA|991^SLC4.FO-BAYPINES.MED.VA.GOV^DNS|20140320145617||QBP^Q11^QBP_Q11|500000000000011828|T|2.4'
    assert_equal hl7[1].to_s, 'QPD|Q11^SMDIAGNOSES^HL70471|B350C65E-B069-11E3-9CA9-50569E013100|SMDiagnoses^pain^757.01'
    assert_equal hl7[2].to_s, 'RCP|I'

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
  end

  def test_QBP_Q11_patient_eclass
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='QBP_Q11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/mhvsm_standardhl7lib_patient_eclass_query_qbp_q11-qbp_q11.xml"

    hl7 = factory.generate(useExValue)
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    assert_equal hl7[0].to_s, 'MSH|^~\&|MHV SM|200MHS^SYS.MHV.MED.VA.GOV^DNS|MHV VISTA|991^SLC4.FO-BAYPINES.MED.VA.GOV^DNS|20140320145617||QBP^Q11^QBP_Q11|500000000000011828|T|2.4'
    assert_equal hl7[1].to_s, 'QPD|Q11^SMPATIENTECLASS^HL70471|B350C65E-B069-11E3-9CA9-50569E013100|SMPatientEClass^1012662214V507576^3489'
    assert_equal hl7[2].to_s, 'RCP|I'

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)

  end

  def test_QBP_Q11_patient_problems
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='QBP_Q11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/mhvsm_standardhl7lib_patient_problems_query_qbp_q11-qbp_q11.xml"

    hl7 = factory.generate(useExValue)
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    assert_equal hl7[0].to_s, 'MSH|^~\&|MHV SM|200MHS^SYS.MHV.MED.VA.GOV^DNS|MHV VISTA|991^SLC4.FO-BAYPINES.MED.VA.GOV^DNS|20140320145617||QBP^Q11^QBP_Q11|500000000000011828|T|2.4'
    assert_equal hl7[1].to_s, 'QPD|Q11^PATIENT PROBLEMS^HL70471|B350C65E-B069-11E3-9CA9-50569E013100|SMPatientProblems^1012662214V507576'
    assert_equal hl7[2].to_s, 'RCP|I'

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)

  end

  # RTB_K13
  def test_RTB_K13_dss_units
    # ver='vaz2.4'
    # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='QBP_Q11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/mhvsm_standardhl7lib_dss_units_response_rtb_k13-rtb_k13-rtb_k13.xml"

    hl7 = factory.generate(useExValue)
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7

    assert_equal hl7[0].to_s, 'MSH|^~\&|MHV VISTA|991^SLC4.FO-BAYPINES.MED.VA.GOV^DNS|MHV SM|200MHS^SYS.MHV.MED.VA.GOV^DNS|20140320155617-0500||RTB^K13^RTB_K13|99146086191|T|2.4'
    assert_equal hl7[1].to_s, 'MSA|AA|500000000000011828|INVALID DATA LINK'
    assert_equal hl7[2].to_s, 'QAK|B350C65E-B069-11E3-9CA9-50569E013100|OK|Q13^SMDSSUNITS^HL70471|4|4|0'
    assert_equal hl7[3].to_s, 'QPD|Q13^SMDSSUNITS^HL70471|B350C65E-B069-11E3-9CA9-50569E013100|SMDSSUnitsByProviderAndClinic^3878^59788'
    assert_equal hl7[4].to_s, 'RDF|6|Location IEN^NM^10936'
    assert_equal hl7[5].to_s, 'RDT|10936|SLC4 TEST LAB|67|SM DENTAL HISTORICAL SLC4|0|N'

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)

  end

  def test_RTB_K13_procedures
        # ver='vaz2.4'
        # view xml as grid http://xmlgrid.net/
    ver='VAZ2.4.HL7'
    event='QBP_Q11'
    useExValue = true
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    # switch template path to test dir
    factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4/mhvsm_standardhl7lib_ecs_procedures_response_rtb_k13-rtb_k13-rtb_k13.xml"

    hl7 = factory.generate(useExValue)
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    assert_equal hl7[0].to_s, 'MSH|^~\&|MHV VISTA|991^SLC4.FO-BAYPINES.MED.VA.GOV^DNS|MHV SM|200MHS^SYS.MHV.MED.VA.GOV^DNS|20140320155617-0500||RTB^K13^RTB_K13|99146086191|T|2.4'
    assert_equal hl7[1].to_s, 'MSA|AA|500000000000011828|INVALID DATA LINK'
    assert_equal hl7[2].to_s, 'QAK|B350C65E-B069-11E3-9CA9-50569E013100|OK|Q13^SMECSPROCEDURES^HL70471|4|4|0'
    assert_equal hl7[3].to_s, 'QPD|Q13^SMECSPROCEDURES^HL70471|B350C65E-B069-11E3-9CA9-50569E013100|SMECSProcedures^10936^66'
    assert_equal hl7[4].to_s, 'RDF|4|ECProcIEN^ST^30'
    assert_equal hl7[5].to_s, 'RDT|3708;EC(725,|SECURE MSGEVAL NONMD|SECURE MSGEVAL MD|MD USE ONLY'

    puts "---- #{event} using tables ---"
    hl7 = factory.generate(false)
    puts hl7
    saveMsg(Ez7gen::VERSION+event, hl7, ver)

  end
  # RTB_K13 (2),
  # DFT_P03
  # ACK_P03
  # ORU_R01(2)


  # MFN_M01, QBP_Q13(dss units,ecs procedures), RSP_K11 (patient eligibility,diagnosis,problems)


end