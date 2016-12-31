require 'test/unit'
require 'ox'
require 'set'
require_relative '../../lib/ez7gen/service/2.5/field_generator'


class FieldGenerator25Test < Test::Unit::TestCase

  # 27
  vs =
      [
          # {:std=>"2.4", :path=>"../../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          {:std=>"2.5", :path=>"../../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.5", :path=>"../../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]
  # attrs = {std: '2.4', version: '2.4.HL7', event: 'ADT_A01', version_store: vs}
  attrs = {std: '2.5', version: '2.5.HL7', event: 'ADT_A01', version_store: vs}

  #parse xml once
  @@pp = ProfileParser.new(attrs)

  #helper method
  def lineToHash(line)
    hash = line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h
    return Hash[hash.map{|(k,v)| [k.to_sym,v]}]

  end

  def setup
    @fldGenerator = FieldGenerator.new(@@pp)
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
    dt =  @fldGenerator.dt('SN',{:required => 'R'})
    p dt
    assert_equal 3, dt.count('^')

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
    dt =  @fldGenerator.dt('CE',{:required => 'R'})
    p dt
    # assert_equal 5, dt.count('^')
    assert_equal 0, dt.count('^')
  end

  def test_dynamic_XPN
    # <DataType name='XPN' description='Extended Person Name'>
    # <DataSubType piece='1' description='Family Name' datatype='FN' max_length='194' required='O'/>
    # <DataSubType piece='2' description='Given Name' datatype='ST' max_length='30' required='O'/>
    # <DataSubType piece='3' description='Second and Further Given Names or Initials Thereof' datatype='ST' max_length='30' required='O'/>
    # <DataSubType piece='4' description='Suffix (e.g., JR or III)' datatype='ST' max_length='20' required='O'/>
    # <DataSubType piece='5' description='Prefix (e.g., DR)' datatype='ST' max_length='20' required='O'/>
    # <DataSubType piece='6' description='Degree (e.g., MD)' datatype='IS' codetable='360' max_length='6' required='B'/>
    # <DataSubType piece='7' description='Name Type Code' datatype='ID' codetable='200' max_length='1' required='O'/>
    # <DataSubType piece='8' description='Name Representation Code' datatype='ID' codetable='465' max_length='1' required='O'/>
    # <DataSubType piece='9' description='Name Context' datatype='CE' codetable='448' max_length='483' required='O'/>
    # <DataSubType piece='10' description='Name Validity Range' datatype='DR' max_length='53' required='B'/>
    # <DataSubType piece='11' description='Name Assembly Order' datatype='ID' codetable='444' max_length='1' required='O'/>
    # <DataSubType piece='12' description='Effective Date' datatype='TS' max_length='26' required='O'/>
    # <DataSubType piece='13' description='Expiration Date' datatype='TS' max_length='26' required='O'/>
    # <DataSubType piece='14' description='Professional Suffix' datatype='ST' max_length='199' required='O'/>
    # </DataType>

    dt =  @fldGenerator.dt('XPN',{:required => 'R'})
    p dt
  end

  def test_dynamic_AD

    # <DataType name='AD' description='Address'>
    # <DataSubType piece='1' description='Street Address'  max_length='120' required='O'/>
    # <DataSubType piece='2' description='Other Designation' datatype='ST' max_length='120' required='O'/>
    # <DataSubType piece='3' description='City' datatype='ST' max_length='50' required='O'/>
    # <DataSubType piece='4' description='State or Province' datatype='ST' max_length='50' required='O'/>
    # <DataSubType piece='5' description='Zip or Postal Code' datatype='ST' max_length='12' required='O'/>
    # <DataSubType piece='6' description='Country' datatype='ID' codetable='399' max_length='3' required='O'/>
    # <DataSubType piece='7' description='Address Type' datatype='ID' codetable='190' max_length='3' required='O'/>
    # <DataSubType piece='8' description='Other Geographic Designation' datatype='ST' max_length='50' required='O'/>
    # </DataType>

    dt =  @fldGenerator.dt('AD',{:required => 'R'})
    p dt
  end

  def test_TS
    p  @fldGenerator.dt('TS',{:required => 'R', :max_length=> 50})
  end

  def test_HD
    # <DataType name='HD' description='Hierarchic Designator'>
    # <DataSubType piece='1' description='Namespace ID' datatype='IS' codetable='300' max_length='20' required='O'/>
    # <DataSubType piece='2' description='Universal ID' datatype='ST' max_length='199' required='C'/>
    # <DataSubType piece='3' description='Universal ID Type' datatype='ID' codetable='301' max_length='6' required='C'/>
    # </DataType>
    p  @fldGenerator.dt('HD',{:required => 'R'})
  end

    def test_ED
    # <DataType name='ED' description='Encapsulated Data'>
    # <DataSubType piece='1' description='Source Application' datatype='HD' max_length='227' required='O'/>
    # <DataSubType piece='2' description='Type of Data' datatype='ID' codetable='191' max_length='9' required='R'/>
    # <DataSubType piece='3' description='Data Subtype' datatype='ID' codetable='291' max_length='18' required='O'/>
    # <DataSubType piece='4' description='Encoding' datatype='ID' codetable='299' max_length='6' required='R'/>
    # <DataSubType piece='5' description='Data' datatype='TX' required='R'/>
    # </DataType>

    p  @fldGenerator.dt('ED',{:required => 'R'})
  end

  def test_all
    all = []
    path = File.path('../../test/test-config/schema/2.5/2.5.HL7.xml')
    xml = Ox.parse(IO.read(path))
    assert_not_nil (xml)
    data_types = []
    dts = xml.Export.Document.Category.locate('DataType')

    dts.each{ |it|
      name =it.attributes[:name]
      all << name
      # p "DataType: #{name}"
      dt =  @fldGenerator.dt(name,{:required => 'R'})
      p "DataType #{name} :" + dt
    }
    p all
    p all.size
  end

end