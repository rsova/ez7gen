require 'rexml/document'
include REXML

xmlfile = File.new("../resources/base24.xml")
xmldoc = Document.new(xmlfile)

# String strtructAttribute = export.Document.Category.MessageType.find{ it.@name == message}.@structure.text()
# def structure = export.Document.Category.MessageStructure.find{ it.@name == strtructAttribute}.@definition.text()

# Info for the first message type element found
mt = XPath.first(xmldoc, "//MessageType")
# p mt

message = 'ADT_A01'
msg_type = xmldoc.elements["Export/Document/Category/MessageType[@name ='#{message}']"].attributes["structure"]
p msg_type
st = xmldoc.elements["Export/Document/Category/MessageStructure[@name ='#{msg_type}']"].attributes["definition"]
p st