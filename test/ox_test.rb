require 'ox'
require "minitest/autorun"
require_relative "../lib/ez7gen/service/utils"

class TestOx < MiniTest::Unit::TestCase

# class MySax < ::Ox::Sax
#   def initialize()
#     @element_name = []
#   end
#
#   def start_element(name)
#     @element_names << name
#   end
# end
#
# any = MySax.new()
# File.open('any.xml', 'r') do |f|
#   Ox.sax_parse(any, f)
# end
  def test1

  profile = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/vaz2.4.xml')
  doc = Ox.parse(IO.read(profile))# load_file
  # msg_type = @xml.elements["Export/Document/Category/MessageType[@name ='#{@event}']"].attributes["structure"]

  # puts doc.Export.Document.Category.locate("MessageType/@name")
   node = doc.Export.Document.Category.nodes.select{|it| it.attributes[:name] =='ADT_A01' }[0].attributes[:structure]
  #nodes.each{|it| p it.attributes[:name]}
  # node = doc.Export.Document.Category.MessageType.attributes[:returntype] #nodes.select{|it| it.attributes[:name] =='ORU_Z11' }[0].attributes[:structure]
  p node
  node = doc.Export.Document.Category.nodes.select{|it| it.attributes[:name] =='ADT_A01' }[0].attributes[:structure]
  #nodes.each{|it| p it.attributes[:name]}
  p node
  # p nodes[0].attributes[:structure]
  node = doc.Export.Document.Category.MessageType.attributes[:name]
  #nodes.each{|it| p it.attributes[:name]}
  p node
  # p nodes[0].attributes[:structure]
  node = doc.Export.Document.Category.nodes().select{|it| it.attributes[:name] =='ADT_A01' }[0].attributes
  #nodes.each{|it| p it.attributes[:name]}
  p node.size
  p node
  # p nodes[0].attributes[:structure]
  end

  def test_getCodedTable
    profile = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/base24.xml')
    doc = Ox.parse(IO.read(profile))# load_file

    # n = doc.Export.Document.Category.locate('CodeTable').select{|it| it.attributes[:name] == '396' }.first.attributes
    # p n.size
    # p n

    # n = doc.Export.Document.Category.CodeTable.nodes.each{|it| p it.name }
    n = doc.Export.Document.Category.locate('CodeTable').select{|it| it.attributes[:name] == '62' }.first.locate('Enumerate').map{|it| it.attributes}
    p n[0].class
    p n.size
    puts n

  end
  # doc = Ox.parse(%{
  def test3
    profile = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/base24.xml')
    doc = Ox.parse(IO.read(profile))# load_file
    # values = @xml.elements.collect("Export/Document/Category/CodeTable[@name ='#{tableName}']/Enumerate"){|x| x.attributes}
    # node = doc.Export.Document.Category.nodes.select{|it| it.attributes[:name] =='ORU_Z11' }[0].attributes[:structure]
    nodes = doc.Export.Document.Category.locate("MessageType/@name")
    p nodes

    nodes = doc.Export.Document.Category.locate("MessageType").select{|it| it.attributes[:name] =='ORU_Z11' }[0].attributes
    p nodes
  end
  def test_getMessageStructure
    profile = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/base24.xml')
    @xml = Ox.parse(IO.read(profile))# load_file
    @event = 'ADT_A01'
    msg_type =  @xml.Export.Document.Category.nodes.select{|it| it.attributes[:name] == @event}[0].attributes[:structure]
    p msg_type
    structure = @xml.Export.Document.Category.locate('MessageStructure').select{|it| it.attributes[:name] == msg_type }[0].attributes[:definition]
    p structure
  end

  def test_getSegmentStructure
    profile = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/base24.xml')
    @xml = Ox.parse(IO.read(profile))# load_file
    msg_type = 'AL1'
    # values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}

    values = @xml.Export.Document.Category.locate('SegmentStructure').select{|it| it.attributes[:name] == msg_type }.first.SegmentSubStructure.attributes
    p values
  end
end
# doc = Ox.parse(%{
# <?xml?>
# <People>
#   <Person age="58">
#     <given>Peter</given>
#     <surname>Ohler</surname>
#   </Person>
#   <Person>
#     <given>Makie</given>
#     <surname>Ohler</surname>
#   </Person>
# </People>
# })

# puts doc.People.Person.given.text
# doc.People.Person(1).given.text => "Makie"
# doc.People.Person.age => "58"
# xml.locate('Element/foo/^Text').each do |t|
#   @data = Model.new(:attr => t)
#   @data.save
# end
#
# # or if you need to do other stuff with the element first
# xml.locate('Element').each do |elem|
#   # do stuff
#   @data = Model.new(:attr => elem.locate('foo/^Text').first)
#   @data.save
# end