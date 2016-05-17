# require "minitest/autorun"
require 'test/unit'
require_relative "../lib/ez7gen/message_factory"
require_relative "../lib/ez7gen/version"

class MessageFactoryAdmTest < Test::Unit::TestCase


  # alias :orig_run :run
  # def run(*args,&blk)
  #   10.times { orig_run(*args,&blk) }
  # end

  # set to true to write messages to a file
  @@PERSIST = true

  @@VS =
      [
          # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml"}]},
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4HL7_N.xml"}]},
          {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]


  # helper message to persist the
  def saveMsg(event, hl7, ver)
    if(defined?(@@PERSIST) && @@PERSIST) then
      # File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
      File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%Y%m%d%H%M%S%L')}.txt", hl7);
    end
  end


# Admission Messages with Z segment
  def test_msh_vaz_24
    # ver='vaz2.4'
    ver='VAZ2.4.HL7'
    event='ADT_A01'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # # MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    # puts "\n------------------------------------\n"
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1}).generate1()
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7

    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

  # def test_vaz24_adt_20
  #   # ver='vaz2.4'
  #   ver='VAZ2.4.HL7'
  #   event='ADT_A20'
  #   # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml"}]},
  #
  #   vs = @@VS.clone()
  #   vs[0][:profiles][1][:path] = "../test/test-config/schema/2.4/VAZ2.4HL7_N.xml"
  #
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: vs}).generate()
  #   # MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   saveMsg(event, hl7, ver)
  #   puts hl7
  #   puts "\n------------------------------------\n"
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
  #   saveMsg(Ez7gen::VERSION+event, hl7, ver)
  #   puts hl7
  #
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end

# Admission Messages
# 1	  ADT_A01 	ADT_A04; ADT_A08; ADT_A13 	MSH;EVN;PID;PD1;ROL;NK1;PV1;PV2;DB1;OBX;AL1;DG1;DRG;PR1;GT1;IN1;IN2;IN3;ACC;UB1;UB2;PDA
  def test_ADT_01
    ver= '2.4.HL7'
    event='ADT_A01'
    loadFactor = 1
    # # hl7 = MessageFactory.new.generate(ver, event, loadFactor)
    # hl7 =MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: loadFactor}).generate()
    # puts hl7
    # saveMsg(event, hl7, ver)

    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 2	  ADT_A02		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;OBX;PDA
  def test_ADT_02
    ver= '2.4.HL7'
    event='ADT_A02'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

  # 3 	ADT_A03		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;DG1;DRG;PR1;OBX;PDA
  def test_ADT_03
    ver= '2.4.HL7'
    event='ADT_A03'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 4	  ADT_A05	  ADT_A14; ADT_A28; ADT_A31	  MSH;EVN;PID;PD1;ROL;NK1;PV1;PV2;DB1;OBX;AL1;DG1;DRG;PR1;GT1;IN1;IN2;IN3;ACC;UB1;UB2
  def test_ADT_05
    ver= '2.4.HL7'
    event='ADT_A05'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 5	  ADT_A06	  ADT_A07	                    MSH;EVN;PID;PD1;ROL;MRG;NK1;PV1;PV2;DB1;OBX;AL1;DG1;DRG;PR1;GT1;IN1;IN2;IN3;ACC;UB1;UB2
  def test_ADT_06
    ver= '2.4.HL7'
    event='ADT_A06'
    # 'MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~MRG~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]'

    #     hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 6	  ADT_A09	  ADT_A10; ADY_A11; ADT_A12 	MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX;DG1
  def test_ADT_A09
    ver= '2.4.HL7'
    event='ADT_A09'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end


# 7	  ADT_A15		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;OBX;DG1
  def test_ADT_A15
    ver= '2.4.HL7'
    event='ADT_A15'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 8	  ADT_A16		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;OBX;DG1;DRG
  def test_ADT_A16
    ver= '2.4.HL7'
    event='ADT_A16'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 9 	ADT_A17		                            MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX
  def test_ADT_A17 # Fixed an issue with required repeating segments
    # <MessageStructure name='ADT_A17'  definition='MSH~EVN~PID~[~PD1~]~PV1~[~PV2~]~[~{~DB1~}~]~[~{~OBX~}~]~PID~[~PD1~]~PV1~[~PV2~]~[~{~DB1~}~]~[~{~OBX~}~]' />
    ver= '2.4.HL7'
    event='ADT_A17'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 10	ADT_A18		                            MSH;EVN;PID;PD1;MGR;PV1
  def test_ADT_A18
    ver= '2.4.HL7'
    event='ADT_A18'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 11	ADT_A20		                            MSH;EVN;NPU
  def test_ADT_A20
    ver= '2.4.HL7'
    event='ADT_A20'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 12	ADT_A21	  ADT_A22; ADT_A23; ADT_A25:ADT_A26; ADT_A27; ADT_A29; ADT_A32; ADT_A33 	MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX
  def test_ADT_A21
    ver= '2.4.HL7'
    event='ADT_A21'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # def test_ADT_A22
  #   ver= '2.4.HL7'
  #   event='ADT_A22'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A23
  #   ver= '2.4.HL7'
  #   event='ADT_A23'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A25
  #   ver= '2.4.HL7'
  #   event='ADT_A25'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A26
  #   ver= '2.4.HL7'
  #   event='ADT_A26'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A27
  #   ver= '2.4.HL7'
  #   event='ADT_A27'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A29
  #   ver= '2.4.HL7'
  #   event='ADT_A29'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A32
  #   ver= '2.4.HL7'
  #   event='ADT_A32'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
  #
  # def test_ADT_A33
  #   ver= '2.4.HL7'
  #   event='ADT_A33'
  #   hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
  #   File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
  #   puts hl7
  #   # # assert(hl7 != nil)
  #   # refute_nil(hl7)
  # end
# 13	ADT_A24		                            MSH;EVN;PID;PD1;PV1;DB1
  def test_ADT_A24
    ver= '2.4.HL7'
    event='ADT_A24'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 14	ADT_A30	  ADT_A34; ADT_A35; ADT_A36; ADT_A46; ADT_A47; ADT_A48; ADT_A49 	MSH;EVN;PID;PD1;MRG
  def test_ADT_A30
    ver= '2.4.HL7'
    event='ADT_A30'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

# 15	ADT_A37		                            MSH;EVN;PID;PD1;PV1;DB1
  def test_ADT_A37
    ver= '2.4.HL7'
    event='ADT_A37'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end
# 16	ADT_A38		                            MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX;DG1;DRG
  def test_ADT_A38
    ver= '2.4.HL7'
    event='ADT_A38'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 17	ADT_A39	  ADT_A40; ADT_A41; ADT_A42	  MSH;EVN;PID;PD1;MRG;PV1
  def test_ADT_A39
    #failed
    ver= '2.4.HL7'
    event='ADT_A39'
    loadFactor = 1
    # <MessageStructure name='ADT_A39' definition='MSH~EVN~{~PID~[~PD1~]~MRG~[~PV1~]~}' />
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: loadFactor}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    # puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 18	ADT_A43	  ADT_A44 	                  MSH;EVN;PID;PD1;MRG
  def test_ADT_A43
    #failed
    ver= '2.4.HL7'
    event='ADT_A43'
    # <MessageStructure name='ADT_A43' definition='MSH~EVN~{~PID~[~PD1~]~MRG~}' />
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 19	ADT_A45		                            MSH;EVN;PID;PD1;MRG;PV1
  def test_ADT_A45
    #failed
    ver= '2.4.HL7'
    event='ADT_A45'
    loadFactor=1 # build all segments
    # <MessageStructure name='ADT_A45' definition='MSH~EVN~PID~[~PD1~]~{~MRG~PV1~}' />
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate(ver, event, loadFactor)
    # hl7 =MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: loadFactor}).generate()

    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 20	ADT_A50	  ADT_A51	                    MSH;EVN;PID;PD1;MRG;PV1
  def test_ADT_A50
    ver= '2.4.HL7'
    event='ADT_A50'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 21	ADT_A52	  ADT_A53; ADT_A55 	          MSH;EVN;PID;PD1;PV1;PV2
  def test_ADT_A52
    ver= '2.4.HL7'
    event='ADT_A52'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 22	ADT_A54		                            MSH;EVN;PID;PD1;ROL;PV1;PV2
  def test_ADT_A54
    ver= '2.4.HL7'
    event='ADT_A54'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 23	ADT_A60		                            MSH;EVN;PID;PV1;PV2;IAM
  def test_ADT_A60
    ver= '2.4.HL7'
    event='ADT_A60'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 24	ADT_A61	  ADT_A62	                    MSH;EVN;PID;PD1;ROL;PV1;PV2
  def test_ADT_A61
    ver= '2.4.HL7'
    event='ADT_A61'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 25	QBP_Q21	  QBP_Q22; QBP_Q23; QBP_Q24	  MSH;QPD;RCP;DSC
  def test_QBP_Q21
    ver= '2.4.HL7'
    event='QBP_Q21'
    loadFactor = 1
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate(ver, event, 1)
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: loadFactor}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 26	RSP_K21		                            MSH;MSA;ERR;QAK;QPD;PID;PD1;DSC
  def test_RSP_K21
    #failed
    ver= '2.4.HL7'
    event='RSP_K21'
    # <MessageStructure name='RSP_K21' definition='MSH~MSA~[~ERR~]~QAK~QPD~[~PID~[~PD1~]~]~[~DSC~]' />
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 28	RSP_K22		                            MSH;MSA;ERR;QAK;QPD;PID;PD1;QRI;DSC
  def test_RSP_K22
    #failed
    ver= '2.4.HL7'
    event='RSP_K22'
    # <MessageStructure name='RSP_K22' definition='MSH~MSA~[~ERR~]~QAK~QPD~{~[~PID~[~PD1~]~[~QRI~]~]~}~[~DSC~]' />
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 30	RSP_K23		                            MSH;MSA;ERR;QAK;QPD;PID;DSC
  def test_RSP_K23
    ver= '2.4.HL7'
    event='RSP_K23'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

  # 32	RSP_K24		                            MSH;MSA;ERR;QAK;QPD;PID;DSC
  def test_RSP_K24
    ver= '2.4.HL7'
    event='RSP_K24'
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate()
    # saveMsg(event, hl7, ver)
    # puts hl7
    puts "\n------------------------------------\n"
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS}).generate1()
    saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
  end

end