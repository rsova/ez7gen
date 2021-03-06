require 'test/unit'
require_relative "../lib/ez7gen/message_factory"

class MessageFactoryLabTest < Test::Unit::TestCase

  # alias :orig_run :run
  # def run(*args,&blk)
  #   10.times { orig_run(*args,&blk) }
  # end
  #
  # #set to true to write messages to a file
  # @@PERSIST = true

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

  # lab messages
  def test_ORU_R01
    ver= '2.4.HL7'
    event='ORU_R01'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_OUL_R21
    ver= '2.4.HL7'
    event='OUL_R21'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_QRY_R02
    ver= '2.4.HL7'
    event='QRY_R02'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_ORF_R04
    ver= '2.4.HL7'
    event='ORF_R04'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_OML_O21
    ver= '2.4.HL7'
    event='OML_O21'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    saveMsg(event, hl7, ver)
    puts hl7
  end

  def test_ORL_O22
    ver= '2.4.HL7'
    event='ORL_O22'
     # MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~{~[~SAC~[~{~OBX~}~]~]~[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~}~]~]
    #  MSH
    # ~MSA~
    # [~ERR~]
    # ~[~{~NTE~}~]~
    #   [~
    #       [~PID~
    #       {~[~SAC~[~{~OBX~}~]~]
    #       ~[~
    #         {~ORC~
    #         [~OBR~[~{~SAC~}~]~]
    #         ~}
    #       ~]~
    #       }
    #     ~ ]
    #   ~]
       # MSH
     # ~MSA~
     # [~ERR~]
     # ~[~{~NTE~}~]~
     # [~ group starts g1
     #  [
     #    ~PID~ g11
     #    {
     #     ~[ g12 group beg
     #       ~SAC~ g121
     #       [~{~OBX~}~] g122
     #    ~]~ g12 end
     #    ~[
     # ~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~}~]~]

    hl7 = MessageFactory.new({std: '2.4', version: ver, event: event, version_store: @@VS}).generate()
    saveMsg(event, hl7, ver)
    puts hl7
  end
end