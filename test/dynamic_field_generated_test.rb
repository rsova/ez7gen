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
   # <DataType name='SN' description='structured numeric'>
   #  <DataSubType piece='1' description='comparator'datatype='ST' />
   #  <DataSubType piece='2' description='num1' datatype='NM' />
   #  <DataSubType piece='3' description='separator/suffix' datatype='ST' />
   #  <DataSubType piece='4' description='num2' datatype='NM' />
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
  
  def test_dynamic_XPN_with_template
    fail()
  end


  def test_dynamic_PID
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
      dt_partials << break_to_partial(f)
      flds[f[:Pos].to_i] = dt_partials.join('^')
      puts f.to_s
      # puts flds
      puts flds.last
    }
    puts flds.join('|')

    # AETNA18^^M11^CANON&&UUID^VA-EDI^CANYT
    # "834^^ISO^CANYT&&^PI"

    # PID|||607    ^1^M11^CANMB&&    ^AN    ^CANQC^20150615||Harper           ^Octavius       ^Stewart||2016-03-25T20:17:16-10:00|F||2106-3^^I9C^497^^ICS|359^^466^150^366    |||||W|   |||||N^^E7^675^^CAS
    # PID|||AETNA18^ ^M11^CANON&&UUID^VA-EDI^CANYT         ||HL7PFSSZELSURNAME^HL7ZPDFIRSTNAME        ||199901101410             |F||2028-9^^^CST^^MVX   |^^BROOKSVILLE^^38221|||||W|REC|||||^^DCL^NDC^^ACR
    #      |9999999^4^M11^CANAB&&x400^PEN   ^AUSHIC^20140325

  end

  def break_to_partial(item)
    partials = []

    if(item.kind_of? Array)

      item.each{|i|
        coll = i[:subComponents] || i
        partials[i[:Pos].to_i] = break_to_partial(coll).join((i[:subComponents])?'&':'^')
        # puts partials
      }
    else

      coll = item[:components] || item[:subComponents]
      if(coll)
        partials << break_to_partial(coll)
      else
        partials << convert_attributes(item)
      end

    end

    return partials

  end

  def convert_attributes(item)
    attrs = {}

    if (item[:Length])
      attrs[:max_length]= item[:Length]
    end

    if (item[:Table])
      attrs[:codetable]= item[:Table].sub(/^0+/, '')
    end

    if (item[:Name])
      attrs[:description] = item[:Name]
    end

    dt = item[:Datatype]
    @fldGenerator.method(dt).call(attrs, true)
  end

end