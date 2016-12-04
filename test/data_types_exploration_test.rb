require 'test/unit'
require 'ox'
require 'set'

class DataTypesExploration < Test::Unit::TestCase

  dynamic_types = ["DT", "DTN", "FT", "ID", "IS", "JCC", "MO", "MOP", "NM", "NR", "OCD", "PT", "QIP", "RI", "SCV", "SI", "SRT", "ST", "TM", "TN", "TS", "TX", "TXCHALLENGE", "UVC", "VR", "WVI", "WVS"]

  def test_SN
 snipet = "<Export>
 <Document version='2.4'>
  <Category>
   <DataType name='SN' description='structured numeric'>
    <DataSubType piece='1' description='comparator'datatype='ST' />
    <DataSubType piece='2' description='num1' datatype='NM' />
    <DataSubType piece='3' description='separator/suffix' datatype='ST' />
    <DataSubType piece='4' description='num2' datatype='NM' />
   </DataType>
  </Category>
</Document>
</Export>"

   xml = Ox.parse(snipet)
   assert_not_nil (xml)
   name = 'SN'
   # dt = xml.Document.Category.locate('DataType').select{|it| it.attributes[:name] == 'SN' }.first
   dt = xml.Document.Category.locate('DataType').select{|it| it.attributes[:name] == name}.first
   p dt.attributes[:name]
   dts = dt.locate('DataSubType')
   p dts
   values=[]
   dts.each{|it|
     values << it.attributes[:datatype]
   }
   values.join('~')
   # p values
    assert_equal ["ST", "NM", "ST", "NM"], values
  end

  def test_base_types_no_subtypes_dt
    templatePath = File.path('test-config/schema/2.5/2.5.HL7.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    # dt = xml.Export.Document.Category.DataType.locate('DataSubType').select{|it| it.nodes.size == 1}
    dt = xml.Export.Document.Category.locate('DataType').select{|it| it.nodes.size == 1}
    data_types = []
    dt.each{ |it|
      data_types << it.attributes[:name]
      # p it
    }
    assert_equal 11, dt.size
    # base_dt = ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]
    base_dt =  ["DT", "DTM", "FT", "GTS", "ID", "IS", "NM", "SI", "ST", "TM", "TX"]

    assert_equal base_dt, data_types

    dt = xml.Export.Document.Category.locate('DataType')
    # dt
    # p dt.locate('DataSubType/@description')
    # p dt.locate('DataSubType/@datatype').size

    # data_types = []
    dt.each{ |it|
     if (it.locate('DataSubType/@description').size != it.locate('DataSubType/@datatype').size) then p it[:name] end
    }
    # "AD"
    # "DT"
    # "DTM"
    # "FT"
    # "GTS"
    # "ID"
    # "IS"
    # "NM"
    # "SI"
    # "ST"
    # "TM"
    # "TX"

  end


  def test_base_types
    templatePath = File.path('test-config/schema/2.4/2.4.HL7.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    dt = xml.Export.Document.Category.locate('DataType').select{|it| it.nodes.size == 1}
    data_types = []
    dt.each{ |it|
      data_types << it.attributes[:name]
    }
    assert_equal 10, dt.size
    base_dt = ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]
    assert_equal base_dt, data_types

  end

  def test_base_types_2
    base_dt = ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]
    templatePath = File.path('test-config/schema/2.4/2.4.HL7.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    dt = xml.Export.Document.Category.locate('DataType').select{|it| it.nodes.size == 2}
    data_types = []
    cnt=0
    base_dt2 =[]
    dt.each{ |it|
      data_types << it.attributes[:name]
      puts it.attributes[:name]
      puts '+++++'
      t = it.locate('DataSubType/@datatype')
      ct = it.locate('DataSubType/@codetable')
      h = Hash[t.zip(ct)]
      puts h
      # delta = t - base_dt
      if ((t - base_dt).empty?) then puts 'All'; base_dt2 << it.attributes[:name] end
      puts '~~~~~~~~~~~~~~~~~~~~~~~~~~'
    }
    assert_equal 25, dt.size
    assert_equal 17,base_dt2.size
    expected = ["CCD", "CQ", "DIN", "DLD", "DR", "DTN", "EIP", "FC", "JCC", "MO", "MOC", "MOP", "NR", "OCD", "PT", "QIP", "RI", "SCV", "SRT", "TS", "TXCHALLENGE", "UVC", "VR", "WVI", "WVS"]
    assert_equal expected, data_types.sort()
    bdt = (base_dt + base_dt2).sort
    assert_equal 27, bdt.size

    dt.each{ |it|
      data_types << it.attributes[:name]
      t = it.locate('DataSubType/@datatype')
      if ((t - base_dt).empty?) then  bdt << it.attributes[:name] end
    }
    # bdt = (base_dt + base_dt2).sort
    assert_equal 27, bdt.to_set.size

  end

  def test_dynamic_base_dt
    # base_dt = ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]

    templatePath = File.path('test-config/schema/2.4/2.4.HL7.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)

    sub_comp_cnt = 1
    # total = -1
    bdt =[]
    x = []
    while sub_comp_cnt < 20 do
      dt = xml.Export.Document.Category.locate('DataType').select{|it| it.nodes.size == sub_comp_cnt}
      # total = -1
     if( dt.empty?)
       sub_comp_cnt +=1
       next
     end
      st_count = bdt.size
      end_count = -1

      while st_count != end_count do
        st_count = end_count
        dt.each{ |it|
          t = it.attributes[:name]
          st = it.locate('DataSubType/@datatype')
          # if (!st.empty? && (st - bdt).empty?)
          if ((st - bdt).empty?)
            # bdt << t unless bdt.include?(t)
            if(!bdt.include?(t))
              bdt << t
            end
          elsif !x.include?(t)
            x << t
          end

        }
        end_count = bdt.size

      end

      sub_comp_cnt+=1
    end
    p bdt.sort
    p bdt.size

    p x.sort
    p x.size

    unresolved = x - bdt
    p unresolved.sort
    p unresolved.size
    # 81 ["AD", "AUI", "CCD", "CCP", "CE", "CE013602620263", "CF", "CK", "CN", "CNE", "CNN", "CP", "CSU", "CWE", "CX", "DDI", "DLD", "DLN", "DLT", "DR", "DT", "DTN", "ED", "EI", "FC", "FN", "FT", "HD", "ID", "IS", "JCC", "LA1", "LA2", "MA", "MO", "MOP", "MSG", "NA", "NDL", "NM", "NR", "OCD", "OSD", "PCF", "PI", "PL", "PLN", "PN", "PPN", "PT", "PTA", "QIP", "QSC", "RCD", "RFR", "RI", "RMC", "RP", "SAD", "SCV", "SI", "SN", "SPD", "SPS", "SRT", "ST", "TM", "TN", "TS", "TX", "TXCHALLENGE", "UVC", "VH", "VR", "WVI", "WVS", "XAD", "XCN", "XON", "XPN", "XTN"]

    #11 ["CD", "CQ", "DIN", "EIP", "ELD", "MOC", "OSP", "PIP", "PRL", "TQ", "VID"]


  end

  def test_all_datatypes

    templatePath = File.path('test-config/schema/2.4/2.4.HL7.xml')
    xml = Ox.parse(IO.read(templatePath))
    assert_not_nil (xml)
    data_types = []
    dt = xml.Export.Document.Category.locate('DataType')
    dt.each{ |it|
      data_types << it.attributes[:name]
    }
    assert_equal 92, dt.size
    p data_types.sort()
    expected = ["AD", "AUI", "CCD", "CCP", "CD", "CE", "CE013602620263", "CF", "CK", "CN", "CNE", "CNN", "CP", "CQ", "CSU", "CWE", "CX", "DDI", "DIN", "DLD", "DLN", "DLT", "DR", "DT", "DTN", "ED", "EI", "EIP", "ELD", "FC", "FN", "FT", "HD", "ID", "IS", "JCC", "LA1", "LA2", "MA", "MO", "MOC", "MOP", "MSG", "NA", "NDL", "NM", "NR", "OCD", "OSD", "OSP", "PCF", "PI", "PIP", "PL", "PLN", "PN", "PPN", "PRL", "PT", "PTA", "QIP", "QSC", "RCD", "RFR", "RI", "RMC", "RP", "SAD", "SCV", "SI", "SN", "SPD", "SPS", "SRT", "ST", "TM", "TN", "TQ", "TS", "TX", "TXCHALLENGE", "UVC", "VH", "VID", "VR", "WVI", "WVS", "XAD", "XCN", "XON", "XPN", "XTN"]
    assert_equal expected, data_types.sort()
  end

end