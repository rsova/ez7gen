require 'test/unit'
require_relative "../lib/ez7gen/message_factory"

class MessageFactoryPharmTest < Test::Unit::TestCase
  # alias :orig_run :run
  # def run(*args,&blk)
  #   10.times { orig_run(*args,&blk) }
  # end

# set to true to write messages to a file
#   @@PERSIST = true

  @@VS =
      [
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

  # Pharmacy messages
  def test_OMP_O09
    # definition='MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~FT1~}~]~[~BLG~]~}' />
    ver= '2.4.HL7'
    event='OMP_O09'
    mf = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1})
    hl7 = mf.generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_ORP_O10
    # definition='MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~]~[~{~NTE~}~]~]~}~]' />
    ver= '2.4.HL7'
    event='ORP_O10'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RDE_O11
    # MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~[~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~RXE~{~RXR~}~[~{~RXC~}~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~CTI~}~]~}
    ver= '2.4.HL7'
    event='RDE_O11'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RRE_O12
    # MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXE~{~RXR~}~[~{~RXC~}~]~]~}~]
    ver= '2.4.HL7'
    event='RRE_O12'
    loadFactor = 1
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
    # MSH|^~\&|303|606|303|707|20160420165159.417||RRE^O12^RRE_O12|716|P|2.4|422|795|ER|SU|CZE|ASCII|EN^English|2.3|
    # MSA|CE|461||||100^Segment sequence error
    # ERR|^^^505
    # NTE||O|420|AI^Ancillary Instructions
    # PID|1||118||Larson^Macon^D|Zimmerman^David^T|19721002165159.425|O|||7061 Iron Blossom Ridge^^Owl^MS^38889-6760^USA|||(601)110-8688|EN  ^English|||||3949344900^FL^20160612|967|N^Not Hispanic or Latino|131||6|USA^United States|N^Non Veteran||20160223165159.430||||20150713165159.430|||||
    # NTE|1||896|2R^Secondary Reason
    # NTE|2|||
    # ORC|UF|||359|SC||391^893|171|20151101165159.433||445^Mcgee^Allen^T|775^Calderon^Hilel^R||(662)120-6474|||165|906|541^William^Martin^D||293^^657|5777 Fallen Panda Expressway^^Owl^MS^38889-6760^USA|(470)446-7282||
    # RXE|1|41^typhoid vaccine, parenteral, other than acetone-killed, dried|304.00|891.00|546||||8|||||772^Hardy^Cameron^K||||||N|642||365||161|400|142|734|160|TR|
    # RXR|IA^Intra-arterial|RD^Right Deltoid||PF^Perfuse|
    # RXC|A|400|613.00|447|531|374|936
    # RXC|A|441|157.00|110|581|629|
    # ORC|RF||||SC|||||501^Watkins^Kasimir^T||361^Walker^Leo^F||||297|719|472|338^Ratliff^Zahir^F|2^Patient has been informed of responsibility, and agrees to pay for service|788^^278|7741 Foggy Pond Jetty^^Oatmeal^TN^37166-9572^USA|(731)538-7434|504 Honey Elk Wynd^^Owl^MS^38889-6760^USA|
    # RXE|1|40^rabies vaccine, for intradermal injection|831.00||689||992||4|||||||||||||||257||764|||315|TR|
    # RXR|MM^Mucous Membrane||BT^Buretrol||
    # RXC|B|687|236.00|360|733|530|563
    # RXC|A|275|758.00|334|399|920|791
    #
    #
    # ERROR <Ens>ErrGeneral:
    # Not forwarding message 3292 with message body Id=1617, Doc Identifier=716, SessionId=3292 because of validation failure:
    # ERROR <Ens>ErrGeneral: Invalid value '893' appears in segment 8:ORC, field 7, repetition 1, component 2, subcomponent 1,
    # but does not appear in code table 2.4:335. (alert request ID=241)


  end

  def test_RDS_O13
    # definition='MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~{~AL1~}~]~[~PV1~[~PV2~]~]~]~{~ORC~[~RXO~[~{~NTE~}~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~]~[~RXE~{~RXR~}~[~{~RXC~}~]~]~RXD~{~RXR~}~[~{~RXC~}~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~FT1~}~]~}' />
    ver= '2.4.HL7'
    event='RDS_O13'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RRD_O14
    # 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXD~{~RXR~}~[~{~RXC~}~]~]~}~]'
    ver= '2.4.HL7'
    event='RRD_O14'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RGV_O15
    # 'MSH~[~{~NTE~}~]~[~PID~[~{~NTE~}~]~[~{~AL1~}~]~[~PV1~[~PV2~]~]~]~{~ORC~[~RXO~[~{~NTE~}~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~]~[~RXE~{~RXR~}~[~{~RXC~}~]~]~{~RXG~{~RXR~}~[~{~RXC~}~]~{~[~OBX~]~[~{~NTE~}~]~}~}~}'
    ver= '2.4.HL7'
    event='RGV_O15'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RRG_O16
    # MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXG~{~RXR~}~[~{~RXC~}~]~]~}~]
    ver= '2.4.HL7'
    event='RRG_O16'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RAS_O17
    # MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~{~AL1~}~]~[~PV1~[~PV2~]~]~]~{~ORC~[~RXO~[~{~NTE~}~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~]~[~RXE~{~RXR~}~[~{~RXC~}~]~]~{~RXA~}~RXR~{~[~OBX~[~{~NTE~}~]~]~}~[~{~CTI~}~]~}
    ver= '2.4.HL7'
    event='RAS_O17'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RRA_O18
    ver= '2.4.HL7'
    event='RRA_O18'
    # MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~{~RXA~}~RXR~]~}~]
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadfactor:1}).generate1()
    saveMsg(event, hl7, ver)
    puts hl7
  end

end