require 'test/unit'
require 'ox'
require 'set'
require_relative '../lib/ez7gen/service/2.4/dynamic_field_generator'

class DynamicFieldGeneratorTest < Test::Unit::TestCase

  # 27
  vs =
      [
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]
  attrs = {std: '2.4', version: '2.4.HL7', event: 'ADT_A01', version_store: vs}

  #parse xml once
  @@pp = ProfileParser.new(attrs)

  #helper method
  def lineToHash(line)
    hash = line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
    return Hash[hash.map{|(k,v)| [k.to_sym,v]}]

  end

  def setup
    @fldGenerator = DynamicFieldGenerator.new(@@pp)

  end

  def teardown
    @fieldGenerator = nil
  end

  def test_init
    assert_equal 'Odysseus', @fldGenerator.yml['person.names.first'][0]
  end

  def test_base_types

   dt =  @fldGenerator.DT({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.FT({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.ID({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.IS({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.NM({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.SI({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.ST({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.TM({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.TN({},true)
   p dt
   assert_not_nil dt

   dt =  @fldGenerator.TX({},true)
   p dt
   assert_not_nil dt
  end

  def test_property_types
    dt =  @fldGenerator.FN({},true)
    p dt
    assert_not_nil dt
  end

  # <DataType name='FN' description='familiy name'>
  # <DataSubType piece='1' description='surname' datatype='ST' />
  # <DataSubType piece='2' description='own surname prefix' datatype='ST' />
  # <DataSubType piece='3' description='own surname' datatype='ST' />
  # <DataSubType piece='4' description='surname prefix from partner/spouse' datatype='ST' />
  # <DataSubType piece='5' description='surname from partner/spouse' datatype='ST' />
  # </DataType>


  def test_dynamic_SN
    #2.4
   # <DataType name='SN' description='structured numeric'>
   #  <DataSubType piece='1' description='comparator'datatype='ST' />
   #  <DataSubType piece='2' description='num1' datatype='NM' />
   #  <DataSubType piece='3' description='separator/suffix' datatype='ST' />
   #  <DataSubType piece='4' description='num2' datatype='NM' />
   # </DataType>

    #2.5
    # <DataType name='SN' description='Structured Numeric'>
    # <DataSubType piece='1' description='Comparator' datatype='ST' max_length='2' required='O'/>
    # <DataSubType piece='2' description='Num1' datatype='NM' max_length='15' required='O'/>
    # <DataSubType piece='3' description='Separator/Suffix' datatype='ST' max_length='1' required='O'/>
    # <DataSubType piece='4' description='Num2' datatype='NM' max_length='15' required='O'/>
    # </DataType>
    dt =  @fldGenerator.dynamic('SN',{},true)
    p dt
  end

  def test_dynamic_CE
  # <DataType name='CE' description='coded element'>
  # <DataSubType piece='1' description='identifier (ST)' datatype='ST' />
  # <DataSubType piece='2' description='text' datatype='ST' />
  # <DataSubType piece='3' description='name of coding system' datatype='IS' codetable='396' />
  # <DataSubType piece='4' description='alternate identifier (ST)' datatype='ST' />
  # <DataSubType piece='5' description='alternate text' datatype='ST' />
  # <DataSubType piece='6' description='name of alternate coding system' datatype='IS' codetable='396' />
  # </DataType>
    dt =  @fldGenerator.dynamic('CE',{},true)
    p dt
  end

  def test_dynamic_XPN
    # <DataType name='XPN' description='extended person name'>
    # <DataSubType piece='1' description='family name' datatype='FN' />
    # <DataSubType piece='2' description='given name' datatype='ST' />
    # <DataSubType piece='3' description='second and further given names or initials thereof' datatype='ST' />
    # <DataSubType piece='4' description='suffix (e.g., JR or III)' datatype='ST' />
    # <DataSubType piece='5' description='prefix (e.g., DR)' datatype='ST' />
    # <DataSubType piece='6' description='degree (e.g., MD)' datatype='IS' codetable='360' />
    # <DataSubType piece='7' description='name type code' datatype='ID' codetable='200' />
    # <DataSubType piece='8' description='Name Representation code' datatype='ID' codetable='465' />
    # <DataSubType piece='9' description='name context' datatype='CE' codetable='448' />
    # <DataSubType piece='10' description='name validity range' datatype='DR' />
    # <DataSubType piece='11' description='name assembly order' datatype='ID' codetable='444' />
    # </DataType>
    dt =  @fldGenerator.dynamic('XPN',{},true)
    p dt
  end


  def _test_dynamic_PID
    pid = [
    {:Name=>"Patient Identifier List", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CX", :Length=>"250", :ItemNo=>"00106", :Pos=>2, :components=>[{:Name=>"ID", :Usage=>"R", :Datatype=>"ST", :Length=>"60", :Pos=>0}, {:Name=>"code identifying the check digit scheme employed", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0061", :Pos=>2}, {:Name=>"assigning authority", :Usage=>"R", :Datatype=>"HD", :Length=>"8", :Pos=>3, :subComponents=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"5", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"1", :Table=>"0301", :Pos=>2}]}, {:Name=>"identifier type code (ID)", :Usage=>"R", :Datatype=>"ID", :Length=>"2", :Table=>"0203", :Pos=>4}]},
    {:Name=>"Patient Name", :Usage=>"R", :Min=>"1", :Max=>"*", :Datatype=>"XPN", :Length=>"250", :ItemNo=>"00108", :Pos=>4, :components=>[{:Name=>"family name", :Usage=>"R", :Datatype=>"FN", :Length=>"60", :Pos=>0, :subComponents=>[{:Name=>"surname", :Usage=>"R", :Datatype=>"ST", :Length=>"35", :Pos=>0}]}, {:Name=>"given name", :Usage=>"R", :Datatype=>"ST", :Length=>"25", :Pos=>1}]},
    {:Name=>"Date/Time Of Birth", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :ItemNo=>"00110", :Pos=>6, :components=>[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"20", :Pos=>0}]},
    {:Name=>"Administrative Sex", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"IS", :Length=>"1", :Table=>"0001", :ItemNo=>"00111", :Pos=>7}
  ]

    #Patient Identifier List"
    pil = [
        {:Name=>"Patient Identifier List", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CX", :Length=>"250", :ItemNo=>"00106", :Pos=>2,
          :components=>[
              {:Name=>"ID", :Usage=>"R", :Datatype=>"ST", :Length=>"60", :Pos=>0},
              {:Name=>"code identifying the check digit scheme employed", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0061", :Pos=>2},
              {:Name=>"assigning authority", :Usage=>"R", :Datatype=>"HD", :Length=>"8", :Pos=>3,
               :subComponents=>[
                   {:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"5", :Table=>"0363", :Pos=>0},
                   {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID",  :Table=>"0301", :Pos=>2} #:Length=>"1"
               ]
              },
              {:Name=>"identifier type code (ID)", :Usage=>"R", :Datatype=>"ID", :Length=>"2", :Table=>"0203", :Pos=>4}]}
    ]

    aa = [ {:Name=>"assigning authority", :Usage=>"R", :Datatype=>"HD", :Length=>"8", :Pos=>3,
                       :subComponents=>[
                           {:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"5", :Table=>"0363", :Pos=>0},
                           {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID",  :Table=>"0301", :Pos=>2} #:Length=>"1"
                       ]
           }]

    #CANAB&&ISO&&HC :  CANAB & &ISO & &HC
    #MWB
    #CANON&&UUID: CANON & &UUID
    #CANON&&UUID
    # 12345^4^NPI^CANPE&&GUID^MA^^20140325
    # 12345 <Component Name="ID" Usage="R" Datatype="ST" Length="60"
    # 4     <Component Name="Check digit" Usage="RE" Datatype="ST" Length="1"
    # NPI   Component Name="code identifying the check digit scheme employed" Usage="R" Datatype="ID" Length="3" Table="0061"
    # CANPE&&GUID <Component Name="assigning authority" Usage="R" Datatype="HD" Length="8 : NOTE: length 11
    #  CANPE  <SubComponent Name="namespace ID" Usage="R" Datatype="IS" Length="5" Table="0363"
    #  ''     <SubComponent Name="universal ID" Usage="X" Datatype="ST"> NOTE: blank Usage X
    #  GUID   <SubComponent Name="universal ID type" Usage="R" Datatype="ID" Length="1" Table="0301"

    pn =[{:Name=>"Patient Name", :Usage=>"R", :Min=>"1", :Max=>"*", :Datatype=>"XPN", :Length=>"250", :ItemNo=>"00108", :Pos=>4, :components=>[{:Name=>"family name", :Usage=>"R", :Datatype=>"FN", :Length=>"60", :Pos=>0, :subComponents=>[{:Name=>"surname", :Usage=>"R", :Datatype=>"ST", :Length=>"35", :Pos=>0}]}, {:Name=>"given name", :Usage=>"R", :Datatype=>"ST", :Length=>"25", :Pos=>1}]}]

    # PID with R and RE
   pid_re = [{:Name=>"Patient Identifier List", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CX", :Length=>"250", :ItemNo=>"00106", :Pos=>2, :components=>[{:Name=>"ID", :Usage=>"R", :Datatype=>"ST", :Length=>"60", :Pos=>0}, {:Name=>"Check digit", :Usage=>"RE", :Datatype=>"ST", :Length=>"1", :Pos=>1}, {:Name=>"code identifying the check digit scheme employed", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0061", :Pos=>2}, {:Name=>"assigning authority", :Usage=>"R", :Datatype=>"HD", :Length=>"8", :Pos=>3, :subComponents=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"5", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"1", :Table=>"0301", :Pos=>2}]}, {:Name=>"identifier type code (ID)", :Usage=>"R", :Datatype=>"ID", :Length=>"2", :Table=>"0203", :Pos=>4}, {:Name=>"assigning facility", :Usage=>"RE", :Datatype=>"HD", :Length=>"14", :Pos=>5, :subComponents=>[{:Name=>"namespace ID", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0363", :Pos=>0}]}, {:Name=>"effective date (DT)", :Usage=>"RE", :Datatype=>"DT", :Length=>"8", :Pos=>6}]},
    {:Name=>"Patient Name", :Usage=>"R", :Min=>"1", :Max=>"*", :Datatype=>"XPN", :Length=>"250", :ItemNo=>"00108", :Pos=>4, :components=>[{:Name=>"family name", :Usage=>"R", :Datatype=>"FN", :Length=>"60", :Pos=>0, :subComponents=>[{:Name=>"surname", :Usage=>"R", :Datatype=>"ST", :Length=>"35", :Pos=>0}]}, {:Name=>"given name", :Usage=>"R", :Datatype=>"ST", :Length=>"25", :Pos=>1}, {:Name=>"second and further given names or initials thereof", :Usage=>"RE", :Datatype=>"ST", :Length=>"25", :Pos=>2}]},
    {:Name=>"Date/Time Of Birth", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :ItemNo=>"00110", :Pos=>6, :components=>[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"20", :Pos=>0}]},
    {:Name=>"Administrative Sex", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"IS", :Length=>"1", :Table=>"0001", :ItemNo=>"00111", :Pos=>7},
    {:Name=>"Race", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0005", :ItemNo=>"00113", :Pos=>9, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"10", :Table=>"0005", :Pos=>0}, {:Name=>"name of coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0396", :Pos=>2}, {:Name=>"alternate identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"6", :Pos=>3}, {:Name=>"name of alternate coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"3", :Table=>"0396", :Pos=>5}]},
    {:Name=>"Patient Address", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"XAD", :Length=>"250", :ItemNo=>"00114", :Pos=>10, :components=>[{:Name=>"street address (SAD)", :Usage=>"RE", :Datatype=>"SAD", :Length=>"49", :Pos=>0, :subComponents=>[{:Name=>"street or mailing address", :Usage=>"RE", :Datatype=>"ST", :Length=>"35", :Pos=>0}]}, {:Name=>"city", :Usage=>"RE", :Datatype=>"ST", :Length=>"15", :Pos=>2}, {:Name=>"state or province", :Usage=>"RE", :Datatype=>"ST", :Length=>"5", :Pos=>3}, {:Name=>"zip or postal code", :Usage=>"RE", :Datatype=>"ST", :Length=>"5", :Pos=>4}]},
    {:Name=>"Marital Status", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0002", :ItemNo=>"00119", :Pos=>15, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"1", :Table=>"0002", :Pos=>0}]},
    {:Name=>"Religion", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0006", :ItemNo=>"00120", :Pos=>16, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"2", :Table=>"0006", :Pos=>0}]},
    {:Name=>"Ethnic Group", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0189", :ItemNo=>"00125", :Pos=>21, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"10", :Table=>"0189", :Pos=>0}, {:Name=>"name of coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0396", :Pos=>2}, {:Name=>"alternate identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"6", :Pos=>3}, {:Name=>"name of alternate coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0396", :Pos=>5}]}]


    flds = []
    pid_re.each{|f|
      dt_partials = []
      dt_partials << process_partials(f)
      flds[f[:Pos].to_i] = dt_partials.join('^')
      puts f.to_s
      # puts flds
      puts flds.last
    }
    puts flds.join('|')

    # AETNA18^^M11^CANON&&UUID^VA-EDI^CANYT
    # "834^^ISO^CANYT&&^PI"

    # PID|||607^1^M11^CANMB&&^AN^CANQC^20150615||Harper^Octavius^Stewart||2016-03-25T20:17:16-10:00|F||2106-3^^I9C^497^^ICS|359^^466^150^366|||||W||||||N^^E7^675^^CAS
    # PID|||AETNA18^ ^M11^CANON&&UUID^VA-EDI^CANYT||HL7PFSSZELSURNAME^HL7ZPDFIRSTNAME||199901101410|F||2028-9^^^CST^^MVX|^^BROOKSVILLE^^38221|||||W|REC|||||^^DCL^NDC^^ACR

    # PID|||607    ^1^M11^CANMB&&    ^AN    ^CANQC^20150615||Harper           ^Octavius       ^Stewart||2016-03-25T20:17:16-10:00|F||2106-3^^I9C^497^^ICS|359^^466^150^366    |||||W|   |||||N^^E7^675^^CAS
    # PID|||AETNA18^ ^M11^CANON&&UUID^VA-EDI^CANYT         ||HL7PFSSZELSURNAME^HL7ZPDFIRSTNAME        ||199901101410             |F||2028-9^^^CST^^MVX   |^^BROOKSVILLE^^38221|||||W|REC|||||^^DCL^NDC^^ACR
    #      |9999999^4^M11^CANAB&&x400^PEN   ^AUSHIC^20140325

    # PID|1||211||Farrell^Castor^X|Meyer^Octavius^G|19751028175300.644|||2106-3^White|7061 Iron Blossom Ridge^^Owl^MS^38889-6760^USA||(601)110-8688||||SOU^Christian: Southern Baptist|468|||||620||||||20160320175300.676|N||||562||||
    # PID|||607^1^M11^CANMB&&^AN^CANQC^20150615||Harper^Octavius^Stewart||2016-03-25T20:17:16-10:00|F||2106-3^^I9C^497^^ICS|359^^466^150^366|||||W||||||N^^E7^675^^CAS

  end

  def _test_dynamic_MSH
    msh = [
    {:Name=>"Field Separator", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ST", :Length=>"1", :ItemNo=>"00001", :Pos=>0},
    {:Name=>"Encoding Characters", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ST", :Length=>"4", :ItemNo=>"00002", :Pos=>1},
    {:Name=>"Sending Application", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0361", :ItemNo=>"00003", :Pos=>2, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"120", :Table=>"0363", :Pos=>0}]},
    {:Name=>"Sending Facility", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0362", :ItemNo=>"00004", :Pos=>3, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"3", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID", :Usage=>"R", :Datatype=>"ST", :Length=>"120", :Pos=>1}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0301", :Pos=>2}]},
    {:Name=>"Receiving Application", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0361", :ItemNo=>"00005", :Pos=>4, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"120", :Table=>"0363", :Pos=>0}]},
    {:Name=>"Receiving Facility", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0362", :ItemNo=>"00006", :Pos=>5, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"3", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID", :Usage=>"R", :Datatype=>"ST", :Length=>"120", :Pos=>1}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0301", :Pos=>2}]},
    {:Name=>"Date/Time Of Message", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :Pos=>6, :components=>[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"26", :Pos=>0}]},
    {:Name=>"Message Type", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CM_MSG", :Length=>"15", :Table=>"0076", :ItemNo=>"00009", :Pos=>8, :components=>[{:Name=>"message type", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0076", :Pos=>0}, {:Name=>"trigger event", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0003", :Pos=>1}, {:Name=>"message structure", :Usage=>"R", :Datatype=>"ID", :Length=>"7", :Table=>"0354", :Pos=>2}]},
    {:Name=>"Message Control ID", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ST", :Length=>"20", :ItemNo=>"00010", :Pos=>9},
    {:Name=>"Processing ID", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"PT", :Length=>"7", :ItemNo=>"00011", :Pos=>10, :components=>[{:Name=>"processing ID", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0103", :Pos=>0}]},
    {:Name=>"Version ID", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"VID", :Length=>"60", :Table=>"0104", :ItemNo=>"00012", :Pos=>11, :components=>[{:Name=>"version ID", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0104", :Pos=>0}]},
    {:Name=>"Accept Acknowledgment Type", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ID", :Length=>"2", :Table=>"0155", :ItemNo=>"00015", :Pos=>14},
    {:Name=>"Application Acknowledgment Type", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ID", :Length=>"2", :Table=>"0155", :ItemNo=>"00016", :Pos=>15}
    ]
    # MSH|9|117|CANMB|^861^DNS|CANBC|^477^DNS|2016-01-30T15:36:08-10:00||RTB^P02^MFN_M01|741|P|2.1|||ER|ER
    # MSH|^~\&|VISTA SQWM|442^HL7.CHEYENNE.MED.VA.GOV:5274^DNS|SQWM|442^VAAUSSQWAPP80:8010^DNS|20160520160008.812-0400||ADT^A60^ADT_A60|B9D3F122897A4707|T|2.4|||AL|NE

    flds = []

    msh.each{|f|
      dt_partials = []
      dt_partials << process_partials(f)
      flds[f[:Pos].to_i] = dt_partials.join('^')
    }
    puts flds.join('|')

  end

  def _test_dymamic_ADT_60

    adt_60 = {"MSH"=>[{:Name=>"Field Separator", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ST", :Length=>"1", :ItemNo=>"00001", :Pos=>0}, {:Name=>"Encoding Characters", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ST", :Length=>"4", :ItemNo=>"00002", :Pos=>1}, {:Name=>"Sending Application", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0361", :ItemNo=>"00003", :Pos=>2, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"120", :Table=>"0363", :Pos=>0}]}, {:Name=>"Sending Facility", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0362", :ItemNo=>"00004", :Pos=>3, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"3", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID", :Usage=>"R", :Datatype=>"ST", :Length=>"120", :Pos=>1}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0301", :Pos=>2}]}, {:Name=>"Receiving Application", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0361", :ItemNo=>"00005", :Pos=>4, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"120", :Table=>"0363", :Pos=>0}]}, {:Name=>"Receiving Facility", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"HD", :Length=>"180", :Table=>"0362", :ItemNo=>"00006", :Pos=>5, :components=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"3", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID", :Usage=>"R", :Datatype=>"ST", :Length=>"120", :Pos=>1}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0301", :Pos=>2}]}, {:Name=>"Date/Time Of Message", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :Pos=>6, :components=>[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"26", :Pos=>0}]}, {:Name=>"Message Type", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CM_MSG", :Length=>"15", :Table=>"0076", :ItemNo=>"00009", :Pos=>8, :components=>[{:Name=>"message type", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0076", :Pos=>0}, {:Name=>"trigger event", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0003", :Pos=>1}, {:Name=>"message structure", :Usage=>"R", :Datatype=>"ID", :Length=>"7", :Table=>"0354", :Pos=>2}]}, {:Name=>"Message Control ID", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ST", :Length=>"20", :ItemNo=>"00010", :Pos=>9}, {:Name=>"Processing ID", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"PT", :Length=>"7", :ItemNo=>"00011", :Pos=>10, :components=>[{:Name=>"processing ID", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0103", :Pos=>0}]}, {:Name=>"Version ID", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"VID", :Length=>"60", :Table=>"0104", :ItemNo=>"00012", :Pos=>11, :components=>[{:Name=>"version ID", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0104", :Pos=>0}]}, {:Name=>"Accept Acknowledgment Type", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ID", :Length=>"2", :Table=>"0155", :ItemNo=>"00015", :Pos=>14}, {:Name=>"Application Acknowledgment Type", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"ID", :Length=>"2", :Table=>"0155", :ItemNo=>"00016", :Pos=>15}], "EVN"=>[{:Name=>"Recorded Date/Time", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :ItemNo=>"00100", :Pos=>1, :components=>[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"20", :Pos=>0}]}], "PID"=>[{:Name=>"Patient Identifier List", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CX", :Length=>"250", :ItemNo=>"00106", :Pos=>2, :components=>[{:Name=>"ID", :Usage=>"R", :Datatype=>"ST", :Length=>"60", :Pos=>0}, {:Name=>"Check digit", :Usage=>"RE", :Datatype=>"ST", :Length=>"1", :Pos=>1}, {:Name=>"code identifying the check digit scheme employed", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0061", :Pos=>2}, {:Name=>"assigning authority", :Usage=>"R", :Datatype=>"HD", :Length=>"8", :Pos=>3, :subComponents=>[{:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"5", :Table=>"0363", :Pos=>0}, {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"1", :Table=>"0301", :Pos=>2}]}, {:Name=>"identifier type code (ID)", :Usage=>"R", :Datatype=>"ID", :Length=>"2", :Table=>"0203", :Pos=>4}, {:Name=>"assigning facility", :Usage=>"RE", :Datatype=>"HD", :Length=>"14", :Pos=>5, :subComponents=>[{:Name=>"namespace ID", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0363", :Pos=>0}]}, {:Name=>"effective date (DT)", :Usage=>"RE", :Datatype=>"DT", :Length=>"8", :Pos=>6}]}, {:Name=>"Patient Name", :Usage=>"R", :Min=>"1", :Max=>"*", :Datatype=>"XPN", :Length=>"250", :ItemNo=>"00108", :Pos=>4, :components=>[{:Name=>"family name", :Usage=>"R", :Datatype=>"FN", :Length=>"60", :Pos=>0, :subComponents=>[{:Name=>"surname", :Usage=>"R", :Datatype=>"ST", :Length=>"35", :Pos=>0}]}, {:Name=>"given name", :Usage=>"R", :Datatype=>"ST", :Length=>"25", :Pos=>1}, {:Name=>"second and further given names or initials thereof", :Usage=>"RE", :Datatype=>"ST", :Length=>"25", :Pos=>2}]}, {:Name=>"Date/Time Of Birth", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"TS", :Length=>"26", :ItemNo=>"00110", :Pos=>6, :components=>[{:Name=>"Date/Time", :Usage=>"R", :Datatype=>"NM", :Length=>"20", :Pos=>0}]}, {:Name=>"Administrative Sex", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"IS", :Length=>"1", :Table=>"0001", :ItemNo=>"00111", :Pos=>7}, {:Name=>"Race", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0005", :ItemNo=>"00113", :Pos=>9, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"10", :Table=>"0005", :Pos=>0}, {:Name=>"name of coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0396", :Pos=>2}, {:Name=>"alternate identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"6", :Pos=>3}, {:Name=>"name of alternate coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"3", :Table=>"0396", :Pos=>5}]}, {:Name=>"Patient Address", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"XAD", :Length=>"250", :ItemNo=>"00114", :Pos=>10, :components=>[{:Name=>"street address (SAD)", :Usage=>"RE", :Datatype=>"SAD", :Length=>"49", :Pos=>0, :subComponents=>[{:Name=>"street or mailing address", :Usage=>"RE", :Datatype=>"ST", :Length=>"35", :Pos=>0}]}, {:Name=>"city", :Usage=>"RE", :Datatype=>"ST", :Length=>"15", :Pos=>2}, {:Name=>"state or province", :Usage=>"RE", :Datatype=>"ST", :Length=>"5", :Pos=>3}, {:Name=>"zip or postal code", :Usage=>"RE", :Datatype=>"ST", :Length=>"5", :Pos=>4}]}, {:Name=>"Marital Status", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0002", :ItemNo=>"00119", :Pos=>15, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"1", :Table=>"0002", :Pos=>0}]}, {:Name=>"Religion", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0006", :ItemNo=>"00120", :Pos=>16, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"2", :Table=>"0006", :Pos=>0}]}, {:Name=>"Ethnic Group", :Usage=>"RE", :Min=>"0", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0189", :ItemNo=>"00125", :Pos=>21, :components=>[{:Name=>"identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"10", :Table=>"0189", :Pos=>0}, {:Name=>"name of coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0396", :Pos=>2}, {:Name=>"alternate identifier", :Usage=>"RE", :Datatype=>"ST", :Length=>"6", :Pos=>3}, {:Name=>"name of alternate coding system", :Usage=>"RE", :Datatype=>"IS", :Length=>"6", :Table=>"0396", :Pos=>5}]}], "IAM"=>[{:Name=>"Set ID - IAM", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"SI", :Length=>"4", :ItemNo=>"01612", :Pos=>0}, {:Name=>"Allergen Type Code", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0127", :ItemNo=>"00204", :Pos=>1, :components=>[{:Name=>"identifier", :Usage=>"R", :Datatype=>"ST", :Length=>"3", :Table=>"0127", :Pos=>0}]}, {:Name=>"Allergen Code/Mnemonic/Description", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CE", :Length=>"250", :ItemNo=>"00205", :Pos=>2, :components=>[{:Name=>"identifier", :Usage=>"R", :Datatype=>"ST", :Length=>"60", :Pos=>0}]}, {:Name=>"Allergy Severity Code", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CE", :Length=>"250", :Table=>"0128", :ItemNo=>"00206", :Pos=>3, :components=>[{:Name=>"identifier", :Usage=>"R", :Datatype=>"ST", :Length=>"2", :Table=>"0128", :Pos=>0}]}, {:Name=>"Allergy Reaction Code", :Usage=>"RE", :Min=>"0", :Max=>"*", :Datatype=>"ST", :Length=>"15", :ItemNo=>"00207", :Pos=>4}, {:Name=>"Allergy Action Code", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"CNE", :Length=>"250", :Table=>"0323", :ItemNo=>"01551", :Pos=>5, :components=>[{:Name=>"identifier (ST)", :Usage=>"R", :Datatype=>"ST", :Length=>"3", :Table=>"0323", :Pos=>0}]}, {:Name=>"Allergy Unique Identifier", :Usage=>"R", :Min=>"1", :Max=>"1", :Datatype=>"EI", :Length=>"80", :ItemNo=>"01552", :Pos=>6, :components=>[{:Name=>"entity identifier", :Usage=>"R", :Datatype=>"ST", :Length=>"80", :Pos=>0}]}]}

    segments = adt_60.keys
    flds = []

    segments.each{|s|
      f = adt_60[s]

      dt_partials = []
      dt_partials << process_partials(f)

      # flds[f[:Pos].to_i] = dt_partials.join('^')
      flds << dt_partials.join('|')

      puts f
      puts flds.last
    }

    flds.each_with_index{|f, idx|
      puts segments[idx] + '|' + f
    }

  end


end