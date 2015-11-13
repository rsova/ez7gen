require "minitest/autorun"
require_relative "../lib/ez7gen/message_factory"

class TestMessageFactory < MiniTest::Unit::TestCase

  def test_msh
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A01")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

  def test_msh_vaz_24
    factory = MessageFactory.new
    hl7 = factory.generate("vaz2.4", "ADT_A01")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

# Admission Messages

# 1	  ADT_A01 	ADT_A04; ADT_A08; ADT_A13 	MSH;EVN;PID;PD1;ROL;NK1;PV1;PV2;DB1;OBX;AL1;DG1;DRG;PR1;GT1;IN1;IN2;IN3;ACC;UB1;UB2;PDA
# 2	  ADT_A02		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;OBX;PDA
# 3 	ADT_A03		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;DG1;DRG;PR1;OBX;PDA
# 4	  ADT_A05	  ADT_A14; ADT_A28; ADT_A31	  MSH;EVN;PID;PD1;ROL;NK1;PV1;PV2;DB1;OBX;AL1;DG1;DRG;PR1;GT1;IN1;IN2;IN3;ACC;UB1;UB2
# 5	  ADT_A06	  ADT_A07	                    MSH;EVN;PID;PD1;ROL;MRG;NK1;PV1;PV2;DB1;OBX;AL1;DG1;DRG;PR1;GT1;IN1;IN2;IN3;ACC;UB1;UB2

# 6	  ADT_A09	  ADT_A10; ADY_A11; ADT_A12 	MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX;DG1
  def test_ADT_A09
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A09")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end
# 7	  ADT_A15		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;OBX;DG1
  def test_ADT_A15
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A15")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

# 8	  ADT_A16		                            MSH;EVN;PID;PD1;ROL;PV1;PV2;DB1;OBX;DG1;DRG
  def test_ADT_A16
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A16")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

# 9 	ADT_A17		                            MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX
  def test_ADT_A17 # Fixed an issue with required repeating segments
    # <MessageStructure name='ADT_A17'  definition='MSH~EVN~PID~[~PD1~]~PV1~[~PV2~]~[~{~DB1~}~]~[~{~OBX~}~]~PID~[~PD1~]~PV1~[~PV2~]~[~{~DB1~}~]~[~{~OBX~}~]' />
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A17")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

# 10	ADT_A18		                            MSH;EVN;PID;PD1;MGR;PV1
  def test_ADT_A18
    factory = MessageFactory.new
    hl7 = factory.generate("2.4", "ADT_A18")
    puts hl7
    # # assert(hl7 != nil)
    # refute_nil(hl7)
  end

# 11	ADT_A20		                            MSH;EVN;NPU
def test_ADT_A20
  factory = MessageFactory.new
  hl7 = factory.generate("2.4", "ADT_A20")
  puts hl7
  # # assert(hl7 != nil)
  # refute_nil(hl7)
end
# 12	ADT_A21	  ADT_A22; ADT_A23; ADT_A25:ADT_A26; ADT_A27; ADT_A29; ADT_A32; ADT_A33 	MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX
# 13	ADT_A24		                            MSH;EVN;PID;PD1;PV1;DB1
# 14	ADT_A30	  ADT_A34; ADT_A35; ADT_A36; ADT_A46; ADT_A47; ADT_A48; ADT_A49 	MSH;EVN;PID;PD1;MRG
# 15	ADT_A37		                            MSH;EVN;PID;PD1;PV1;DB1
# 16	ADT_A38		                            MSH;EVN;PID;PD1;PV1;PV2;DB1;OBX;DG1;DRG
# 17	ADT_A39	  ADT_A40; ADT_A41; ADT_A42	  MSH;EVN;PID;PD1;MRG;PV1
# 18	ADT_A43	  ADT_A44 	                  MSH;EVN;PID;PD1;MRG
# 19	ADT_A45		                            MSH;EVN;PID;PD1;MRG;PV1
# 20	ADT_A50	  ADT_A51	                    MSH;EVN;PID;PD1;MRG;PV1
# 21	ADT_A52	  ADT_A53; ADT_A55 	          MSH;EVN;PID;PD1;PV1;PV2
# 22	ADT_A54		                            MSH;EVN;PID;PD1;ROL;PV1;PV2
# 23	ADT_A60		                            MSH;EVN;PID;PV1;PV2;IAM
# 24	ADT_A61	  ADT_A62	                    MSH;EVN;PID;PD1;ROL;PV1;PV2
# 25	QBP_Q21	  QBP_Q22; QBP_Q23; QBP_Q24	  MSH;QPD;RCP;DSC
# 26	RSP_K21		                            MSH;MSA;ERR;QAK;QPD;PID;PD1;DSC
# 28	RSP_K22		                            MSH;MSA;ERR;QAK;QPD;PID;PD1;QRI;DSC
# 30	RSP_K23		                            MSH;MSA;ERR;QAK;QPD;PID;DSC
# 32	RSP_K24		                            MSH;MSA;ERR;QAK;QPD;PID;DSC

end