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

end