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
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
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

  def test_RRE_O12
    #1 MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXE~{~RXR~}~[~{~RXC~}~]~]~}~]
    ver= '2.4.HL7'
    event='RRE_O12'
    # loadFactor = 1
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RRD_O14
    #2 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXD~{~RXR~}~[~{~RXC~}~]~]~}~]'
    ver= '2.4.HL7'
    event='RRD_O14'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RRG_O16
    #3 MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXG~{~RXR~}~[~{~RXC~}~]~]~}~]
    ver= '2.4.HL7'
    event='RRG_O16'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end
  
  def test_RRA_O18
    #4 MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~{~RXA~}~RXR~]~}~]
    ver= '2.4.HL7'
    event='RRA_O18'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_ORP_O10
    #5 definition='MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~[~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~]~[~{~NTE~}~]~]~}~]' />
    ver= '2.4.HL7'
    event='ORP_O10'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_OMP_O09
    #6 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~FT1~}~]~[~BLG~]~}' />
    ver= '2.4.HL7'
    event='OMP_O09'
    mf = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS})#loadFactor: 1
    hl7 = mf.generate_message()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RDE_O11
    #7 MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~[~RXO~[~{~NTE~}~]~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~RXE~{~RXR~}~[~{~RXC~}~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~CTI~}~]~}
    ver= '2.4.HL7'
    event='RDE_O11'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RDS_O13
    #8 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~{~AL1~}~]~[~PV1~[~PV2~]~]~]~{~ORC~[~RXO~[~{~NTE~}~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~]~[~RXE~{~RXR~}~[~{~RXC~}~]~]~RXD~{~RXR~}~[~{~RXC~}~]~[~{~OBX~[~{~NTE~}~]~}~]~[~{~FT1~}~]~}
    ver= '2.4.HL7'
    event='RDS_O13'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RGV_O15
    #9 'MSH~[~{~NTE~}~]~[~PID~[~{~NTE~}~]~[~{~AL1~}~]~[~PV1~[~PV2~]~]~]~{~ORC~[~RXO~[~{~NTE~}~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~]~[~RXE~{~RXR~}~[~{~RXC~}~]~]~{~RXG~{~RXR~}~[~{~RXC~}~]~{~[~OBX~]~[~{~NTE~}~]~}~}~}
    ver= '2.4.HL7'
    event='RGV_O15'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_RAS_O17
    #10 MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~{~AL1~}~]~[~PV1~[~PV2~]~]~]~{~ORC~[~RXO~[~{~NTE~}~{~RXR~}~[~{~RXC~}~[~{~NTE~}~]~]~]~]~[~RXE~{~RXR~}~[~{~RXC~}~]~]~{~RXA~}~RXR~{~[~OBX~[~{~NTE~}~]~]~}~[~{~CTI~}~]~}
    ver= '2.4.HL7'
    event='RAS_O17'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate_message()#loadFactor: 1
    saveMsg(event, hl7, ver)
    puts hl7
  end

end