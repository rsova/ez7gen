
require 'rexml/document'
include REXML

xmlfile = File.new("../resources/base24.xml")
xmldoc = Document.new(xmlfile)
export = xmldoc.root
puts "Root element : " + export.attributes["generator"]
		# String strtructAttribute = export.Document.Category.MessageType.find{ it.@name == message}.@structure.text()
		# def structure = export.Document.Category.MessageStructure.find{ it.@name == strtructAttribute}.@definition.text()
xmldoc.elements.each("Export/Document/Category/MessageType"){ 
   |e| puts "Message Type" + e.attributes['name']
}
puts xmldoc.elements("Export/Document/Category/MessageType"){ 
   |e| puts "Message Type" + e.attributes['name']
}

