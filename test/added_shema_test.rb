require 'test/unit'
require 'ox'

class Sample
  attr_accessor :a, :b, :c

  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end
end

class AddedShemaTest < Test::Unit::TestCase

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_xml

    # Create Object
    obj = Sample.new(1, "bee", ['x', :y, 7.0])
    # Now dump the Object to an XML String.
      xml = Ox.dump(obj,nil)
    puts xml

    # Convert the object back into a Sample Object.
     obj2 = Ox.parse_obj(xml)
    # Called before every test method runs. Can be used
    # to set up fixture information.
  end

  def test_build_added_tables_xml
    # file = File.expand_path('codes.txt', __FILE__).to_s
    arr = []

    File.readlines('Additional Tables with values_v1.1.txt').map do |line|
    # File.readlines('codes1.txt').map do |line|
      arr<<line.chomp
      # puts line
    end
    z = []
    arr.each_with_index{|val, idx| if(idx % 2 == 0)then z<< [arr[idx], arr[idx+1] ] end}
    p z
    x =[]
    row = []
    idx = 0
    z.each{|pair|
      # if(pair[0].strip.empty?)
      if(pair[0].gsub(/[[:space:]]/,'').empty?)
        x << row
        idx= idx + 1
        row = []
      else
        row << pair
      end
    }
    p x

    root = Ox::Element.new('Export')
    doc = Ox::Element.new('Document')
    doc[:name]='Codes for coded tables with missing entries'
    root << doc
    cat = Ox::Element.new('Category')
    cat[:name] = '2.4'
    doc << cat

    x.each{|it|

    codeTbl = Ox::Element.new('CodeTable')

    codeTbl[:name] = it.first[0].delete('Table ')
    # drop 2 first elements: table name and fields [Code, Description]
    it.drop(2).each_with_index { |pair,i |
        enum = Ox::Element.new('Enumerate')
        enum[:position] = i + 1
        enum[:value] = pair.first
        enum[:description] = pair.last
        codeTbl << enum
    }
      cat << codeTbl
    }


    xml = Ox.dump(root, nil)
    puts xml


    # doc << top
    #
    # ce = [['E','Employer'], ['G','Guarantor']]
    # ce.each_with_index{|value, index|
    #   mid = Ox::Element.new('Enumarate')
    #   mid[:position] = index
    #   mid[:value] = value[0]
    #   mid[:description] = value[1]
    #   top << mid
    # }


    # doc = Ox::Document.new(:version => '1.0')
    #
    # arr = [00,'Surgical']
    # arr<<[10, 'Medical']
    # arr<<[60, 'Home Nursing Service']
    # arr<<[85,'Psychiatric Contract']
    # arr<<[86, 'Psychiatric']
    # arr<<[95, 'Neurological Contract']
    # arr<<[96, 'Neurological']
    #
    #
    #
    # top = Ox::Element.new('CodeTable')
    # top[:name] = '137'
    # doc << top
    #
    # ce = [['E','Employer'], ['G','Guarantor']]
    # ce.each_with_index{|value, index|
    #   mid = Ox::Element.new('Enumarate')
    #   mid[:position] = index
    #   mid[:value] = value[0]
    #   mid[:description] = value[1]
    #   top << mid
    # }
    #
    # # bot = Ox::Element.new('bottom')
    # # bot[:name] = 'third'
    # # mid << bot
    #
    # xml = Ox.dump(doc, nil)
    # puts xml

  end

    def setup
      # Do nothing
    end

end