# require "minitest/autorun"
require 'test/unit'
require_relative "../lib/ez7gen/message_factory"
require_relative "../lib/ez7gen/version"

class MessageFactoryTemplate24CusotmTest < Test::Unit::TestCase


  # alias :orig_run :run
  # def run(*args,&blk)
  #   10.times { orig_run(*args,&blk) }
  # end

  # set to true to write messages to a file
  # @@PERSIST = true

  @@VS =
      [
          # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ24CustomMSH062216.xml"}]},
         # {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]


  # helper message to persist the
  def saveMsg(event, hl7, ver)
    # if(defined?(@@PERSIST) && @@PERSIST) then
    #   # File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
    #   File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%Y%m%d%H%M%S%L')}.txt", hl7);
    # end
  end


  def test_ADT_ZA60
    # ver='vaz2.4'
    ver='VAZ2.4.HL7'
    event='ADT_Z60'
    # factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, use_template: true})
    factory = MessageFactory.new({std: '2.4', version: ver, event:event, version_store: @@VS, loadFactor: 1})
    hl7 = factory.generate()
    # factory.templatePath = "/Users/romansova/RubymineProjects/ez7gen/ez7gen-web/config/templates/2.4/vista sqwm-adt_a60.xml"
    # hl7 = factory.generate_message_from_template()
    # saveMsg(Ez7gen::VERSION+event, hl7, ver)
    puts hl7
    # assert_equal 'MSH', hl7[0].e0
    # assert_equal 'EVN', hl7[1].e0
    # assert_equal 'PID', hl7[2].e0
    # assert_equal 'IAM', hl7[3].e0
  end


end