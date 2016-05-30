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
    field = [ #Patient Identifier List : CX
    {:Name=>"ID", :Usage=>"R", :Datatype=>"ST", :Length=>"60", :Pos=>0},
    {:Name=>"code identifying the check digit scheme employed", :Usage=>"R", :Datatype=>"ID", :Length=>"3", :Table=>"0061", :Pos=>2},
    {:Name=>"assigning authority", :Usage=>"R", :Datatype=>"HD", :Length=>"8", :Pos=>3,
      :subComponents=>[
          {:Name=>"namespace ID", :Usage=>"R", :Datatype=>"IS", :Length=>"5", :Table=>"0363", :Pos=>0},
          {:Name=>"universal ID type", :Usage=>"R", :Datatype=>"ID", :Length=>"1", :Table=>"0301", :Pos=>2}]},
    {:Name=>"identifier type code (ID)", :Usage=>"R", :Datatype=>"ID", :Length=>"2", :Table=>"0203", :Pos=>4}
    ]


    dt_partials = []
    pid.each{|f|
      if(f[:componets])

      elsif(f[:subComponents])
        subs = []
        f[:subComponents].each{|s|
          subs[s[:Pos].to_i] = prepare_attrs(s)
        }
        dt_partials[f[:Pos].to_i] = subs.join('&')

      else
      dt_partials[f[:Pos].to_i] = prepare_attrs(f)
      end
    }
    puts dt_partials.join('^')

    # AETNA18^^M11^CANON&&UUID^VA-EDI^CANYT
    # "834^^ISO^CANYT&&^PI"
  end

  def prepare_attrs(f)
    map = {}
    # if (f[:Pos])
    #   map[:pos]= f[:Pos].to_i
    # end

    if (f[:Length])
      map[:max_length]= f[:Length]
    end

    if (f[:Table])
      map[:codetable]= f[:Table].sub(/^0+/, '')
    end

    if (f[:descripion])
      map[:descripion] = f[:Name]
    end

    dt = f[:Datatype]
    @fldGenerator.method(dt).call(map, true)
  end

end