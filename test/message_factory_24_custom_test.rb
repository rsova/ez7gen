# require "minitest/autorun"
require 'test/unit'
require_relative "../lib/ez7gen/message_factory"
require_relative "../lib/ez7gen/version"

class MessageFactoryTemplate24CusotmTest < Test::Unit::TestCase

  alias :orig_run :run
  def run(*args,&blk)
    10.times { orig_run(*args,&blk) }
  end

  # set to true to write messages to a file
  @@PERSIST = true

  @@VS =
      [
          # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ24CustomMSH062216.xml"}]},
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ24_08-03-16.xml"}]},
         # {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]


  # helper message to persist the
  def saveMsg(event, hl7, ver)
    if(defined?(@@PERSIST) && @@PERSIST) then
      # File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
      File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%Y%m%d%H%M%S%L')}.txt", hl7);
    end
  end


  # def test_ADT_ZA60
  #   # ver='vaz2.4'
  #   ver='VAZ2.4.HL7'
  #   event='ADT_Z60'
  #   # factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
  #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1})
  #   hl7 = factory.generate()
  #   # factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/ez7gen-web/config/templates/2.4/vista sqwm-adt_a60.xml"
  #   # hl7 = factory.generate_message_from_template()
  #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
  #   puts hl7
  #   # assert_equal 'MSH', hl7[0].e0
  #   # assert_equal 'EVN', hl7[1].e0
  #   # assert_equal 'PID', hl7[2].e0
  #   # assert_equal 'IAM', hl7[3].e0
  # end

  def test_ACK_P03
    event='ACK_P03'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_ADT_A01
      event='ADT_A01'
      ver='VAZ2.4.HL7'

      factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
      hl7 = factory.generate()
      saveMsg(Ez7gen::VERSION+event, hl7, ver)
      puts hl7
      # assert_equal 'MSH', hl7[0].e0
      # assert_equal 'EVN', hl7[1].e0
      # assert_equal 'PID', hl7[2].e0
      # assert_equal 'IAM', hl7[3].e0
    end

  def test_ADT_A60
    event='ADT_A60'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_ADT_Z60
    event='ADT_Z60'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_DFT_P03
    event='DFT_P03'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

   def test_DFT_X03
    event='DFT_X03'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_DFT_P11
    event='DFT_P11'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_MFN_M01
    event='MFN_M01'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  # Required field MFE.4 is not generated (MFN_X01, MFN_Y01, MFN_M01)
  def test_MFN_X01
    event='MFN_X01'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_MFN_Y01
    event='MFN_Y01'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_OMS_O05
    event='OMS_O05'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_ORF_Z07
    event='ORF_Z07'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_ORF_Z10
    event='ORF_Z10'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_ORF_Z11
    event='ORF_Z11'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

  def test_ORL_O22 # broken
    event='ORL_O22'
    ver='VAZ2.4.HL7'

    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    hl7 = factory.generate()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end

    # def test_ORM_O01
    #   event='ORM_O01'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_R01
    #   event='ORU_R01'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_R01_1
    #   event='ORU_R01_1'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_Z01
    #   event='ORU_Z01'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_Z06 #broken
    #   event='ORU_Z06'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_Z07
    #   event='ORU_Z07'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_Z10
    #   event='ORU_Z10'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_Z11
    #   event='ORU_Z11'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_ORU_Z11_1 # broken
    #   event='ORU_Z11_1'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_QBP_Q11
    #   event='QBP_Q11'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_QBP_Q13
    #   event='QBP_Q13'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_REF_I12
    #   event='REF_I12'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_REF_I13
    #   event='REF_I13'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_REF_I14
    #   event='REF_I14'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RPA_I08
    #   event='RPA_I08'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RQA_I08
    #   event='RQA_I08'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RRI_I12
    #   event='RRI_I12'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RRI_I13
    #   event='RRI_I13'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RRI_I14
    #   event='RRI_I14'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RSP_K11
    #   event='RSP_K11'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RSP_K11_1
    #   event='RSP_K11_1'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RSP_K11_2
    #   event='RSP_K11_2'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RSP_K11_3
    #   event='RSP_K11_3'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end
    #
    # def test_RTB_K13
    #   event='RTB_K13'
    #   ver='VAZ2.4.HL7'
    #
    #   factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}) #loadFactor: 1
    #   hl7 = factory.generate()
    #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
    #   puts hl7
    #   # assert_equal 'MSH', hl7[0].e0
    #   # assert_equal 'EVN', hl7[1].e0
    #   # assert_equal 'PID', hl7[2].e0
    #   # assert_equal 'IAM', hl7[3].e0
    # end


  end