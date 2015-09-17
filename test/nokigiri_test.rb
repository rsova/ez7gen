require 'nokogiri'
require "minitest/autorun"
require "benchmark"
require_relative '../lib/ez7gen/profile_parser'

class TestNokigiri < MiniTest::Unit::TestCase


# xml_str = <<EOF
# <root>
#   <THING1:things type="Container">
#     <PART1:Id type="Property">1234</PART1:Id>
#     <PART1:Name type="Property">The Name1</PART1:Name>
#   </THING1:things>
#   <THING2:things type="Container">
#     <PART2:Id type="Property">2234</PART2:Id>
#     <PART2:Name type="Property">The Name2</PART2:Name>
#   </THING2:things>
# </root>
# EOF
  def test_1

  path = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/vaz24.xml')

  doc = Nokogiri::XML(File.open(path))
# 'ORU_Z11'
  doc.xpath('//MessageType').each do |thing|
    puts thing
    puts thing.name
    puts thing['name']
    # puts "Name  = " + thing.at_xpath('name').content
    # puts "Name = " + thing.at_xpath('Name').content
  end

  end
# doc.xpath('//*[@class="red"]')
  def test_2
    path = File.expand_path('/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/vaz2.4.xml')

    doc = Nokogiri::XML(File.open(path))

    el = doc.xpath("//MessageType[@name]")#.attributes['structure'] #[@class="red"]
    p el
  end

  end