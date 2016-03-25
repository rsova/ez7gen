# require "minitest/autorun"
require 'test/unit'
require "benchmark"
require_relative '../lib/ez7gen/profile_parser'

class ProfileParserTest < Test::Unit::TestCase
  include Utils
	
	def setup
		vs =
				[
						{:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml"}]},
						{:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
				]
    @attrs = {std: '2.4', version: '2.4.HL7', event: 'ADT_A01', version_store: vs}
    # @parser = ProfileParser.new(attributes)

  end
	def teardown
    @attrs = nil
  end

	def test_init_base
    parser = ProfileParser.new(@attrs)
		assert(parser !=nil)

    xml = parser.instance_variable_get('@xml')
    assert_equal('2.4.HL7', xml.Export.Document.attributes[:name])

    # assert_equal(2, parser.)
		# assert(hl7 != nil)
		# refute_nil(hl7)
  end

  def test_init_custom
    @attrs[:version] = 'VAZ2.4.HL7'
    parser = ProfileParser.new(@attrs)
    assert(parser !=nil)
    # get access to private field
    xml = parser.instance_variable_get('@xml')
    assert_equal('VAZ2.4.HL7', xml.Export.Document.attributes[:name])
    # assert(hl7 != nil)
    # refute_nil(hl7)
  end


  def test_getMessageDefinition
    parser = ProfileParser.new(@attrs)
    expected = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
		assert_equal(expected, parser.get_message_definition())
	end

	def test_getMessageStructure_ADT_01
    parser = ProfileParser.new(@attrs)
    assert_equal('ADT_A01', parser.get_message_structure('ADT_A01'))
  end

	def test_getMessageStructure_ADT_04
    parser = ProfileParser.new(@attrs)
    assert_equal('ADT_A01', parser.get_message_structure('ADT_A04'))
	end

	def test_getSegmentStructure
    parser = ProfileParser.new(@attrs)
    al1 =  parser.get_segment_structure('[~{~AL1~}~]')
		puts al1
		assert_equal 6, al1.size
		assert_equal('Set ID - AL1', al1.first['description'.to_sym])
	end

   def test_processSegments
    parser = ProfileParser.new(@attrs)
    struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    results = parser.process_segments(struct)
    puts results
    assert_equal(2, results.size())

    profile_idx = 0
    segments_idx = 1
    #refactored, results returned as collection of arrays instead of map

    assert_equal(21, results[segments_idx].size())
    assert_equal('[~PD1~]', results[segments_idx][0])
	 end


		def test_processSegments_RSP_K22_group
      parser = ProfileParser.new(@attrs)
      struct = 'MSH~MSA~[~ERR~]~QAK~QPD~{~[~PID~[~PD1~]~[~QRI~]~]~}~[~DSC~]'
      profile, encodedSegments = parser.process_segments(struct)
      # p profile
      # p encodedSegments
			assert_equal(7, profile.size())
			assert_equal(6, encodedSegments.size()) # to groups

			assert_equal(3, encodedSegments[3].size())
      assert_equal('Array', encodedSegments[3].class.name)
		end

		def test_processSegments_not_optional_group
      # <MessageStructure name='ADT_A45' definition='MSH~EVN~PID~[~PD1~]~{~MRG~PV1~}' />
      parser = ProfileParser.new(@attrs)
      struct = "MSH~[~{~ROL~}~]~[~PD1~]~{~MRG~PV1~}"
      results = parser.process_segments(struct)
      p results
      assert_equal(2, results.size())

      profile_idx = 0
      segments_idx = 1
      #refactored, results returned as collection of arrays instead of map

      assert_equal(3, results[segments_idx].size())
      assert_equal('[~{~ROL~}~]', results[segments_idx][0])
    end



	def test_codeTable
    parser = ProfileParser.new(@attrs)
    attributes = parser.get_code_table("62")
    p attributes[0].class
    p attributes.size
    #p attributes

    # assert_equal(3, attributes.size)
    puts attributes
    assert_equal('1', attributes[0][:position])
    assert_equal('02', attributes[1][:value])
    assert_equal('Census management', attributes[2][:description])
	 end

	def test_codeTable_Added
    parser = ProfileParser.new(@attrs)
		attributes = parser.get_code_table('296')
		p attributes[0].class
		p attributes.size
		# assert (attributes[0][:position] =='1' && attributes[0][:value] =='EN')
	end

   def test_codeTable_NoVals
     parser = ProfileParser.new(@attrs)
   		attributes = parser.get_code_table("-296")
   		p attributes[0].class
			p attributes.size
			assert (attributes[0][:position] =='1' && attributes[0][:value] =='...')
	 end

	def test_codeTable_blank
    parser = ProfileParser.new(@attrs)
		attributes = parser.get_code_table("")
		p attributes
		print attributes.empty?
  end

	def test_codeTable_special_ch
    parser = ProfileParser.new(@attrs)
		attributes = parser.get_code_table("417")
		# p attributes.*[:description]
    actual = attributes.collect{|a| a[:description]}
    # p actual
    assert actual.include?("Carcinoma-unspecified type")
    assert_false actual.include?('Degeneration &amp; necrosise')
		assert_equal 12, attributes.size
	end

  def test_getSegments
    parser = ProfileParser.new(@attrs)
    results =  parser.get_segments
    profile_idx = 0
    segments_idx = 1
    #refactored, results returned as collection of arrays instead of map
    assert_equal(21, results[profile_idx].size())
    assert_equal('[~PD1~]', results[segments_idx][0])
  end

   def test_getSegments_vaz
		 puts Benchmark.measure("segments"){
       @attrs[:version] = 'VAZ2.4.HL7'
       parser = ProfileParser.new(@attrs)
       # parser = ProfileParser.new({version:'vaz2.4', event:'ADT_A01'})
       results =  parser.get_segments
       puts results
     }
		 # assert_equal(21, results[:@encodedSegments].size())
		 # assert_equal('[~PD1~]', results[:@encodedSegments][0])
	 end

	def test_lookupMessageTypes_vaz24
    @attrs[:version] = 'VAZ2.4.HL7'
    parser = ProfileParser.new(@attrs)
    # parser = ProfileParser.new({version: 'vaz2.4', event: 'ADT_A01'})
		results =  parser.lookup_message_types('')
		puts results
		assert_equal 2, results.size

    results =  parser.lookup_message_types('ADT_|QBP_|RSP_')
    puts results
    assert_equal 1, results.size
  end

  def test_lookupMessageTypes_24_all

    @attrs.delete(:event)# no events passed to lookup all event types
    # {std: version[:std], version: p[:doc], version_store: versions}
    parser = ProfileParser.new(@attrs)
    results =  parser.lookup_message_types()
    assert_equal 390, results.size

    # puts results
    results =  parser.lookup_message_types(nil)
    assert_equal 390, results.size
    # puts results
  end

	def test_lookupMessageTypes_24_ADT
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
		# parser = ProfileParser.new({version:'2.4'})
    results =  parser.lookup_message_types('ADT_A')
    # puts results
    assert_equal 57, results.size

  end

	def test_lookupMessageTypes_24_QBP
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
  # parser = ProfileParser.new({version:'2.4'})
    results =  parser.lookup_message_types('QBP_Q2')
    # puts results
    assert_equal 5, results.size
  end

	def test_lookupMessageTypes_24_RSP_K2
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
		# parser = ProfileParser.new({version:'2.4'})
    results =  parser.lookup_message_types('RSP_K2')
    # puts results
    assert_equal 5, results.size
  end

	def test_lookupMessageTypes_24_RSP_Admissions
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
    # parser = ProfileParser.new({version:'2.4'})
    # if(message.starts_with('ADT_')||message.starts_with('QBP_')||message.starts_with('RSP_'))
    results =  parser.lookup_message_types('ADT_A|QBP_Q2|RSP_K2')
    puts results[0]
    assert_equal 67, results.size
    assert_equal({:name=>'ADT_A01', :code=>'ADT/ACK - Admit / visit notification'}, results[0])
  end

  def test_is_group_true_encoded
    parser = ProfileParser.new(@attrs)
    isCheck, tokens =  parser.is_group?("{~3~}")
   assert_true isCheck
   assert_equal(['3'], tokens)
  end

  def test_is_group_true_all_required
    parser = ProfileParser.new(@attrs)
    isCheck, tokens =  parser.is_group?("{~MRG~PV1~}")
    assert_true isCheck
    assert_equal(["MRG", "PV1"], tokens)
  end

  def test_is_group_false
    parser = ProfileParser.new(@attrs)
    isCheck, tokens =  parser.is_group?("{~MRG~}")
    assert_true !isCheck
    assert_equal(['MRG'], tokens)
  end

  def test_is_group_resolved
    parser = ProfileParser.new(@attrs)
    tokens =[]
    isCheck, tokens =  parser.is_group?("{~25~}")
    p tokens
    assert_true isCheck && parser.is_group_resolved?(tokens)  # check for case of all groups resolved
    assert_equal(['25'], tokens)

    isCheck, tokens =  parser.is_group?("{~25~[~17~]~}")
    p tokens
    assert_true isCheck && parser.is_group_resolved?(tokens) # check for case of all groups resolved
    assert_equal(['25','17'], tokens)

    isCheck, tokens =  parser.is_group?("{~25~[~OBX~]~}")
    p tokens
    assert_false isCheck && parser.is_group_resolved?(tokens) # check for case of all groups resolved
    assert_equal(['25','OBX'], tokens)

    # isCheck, tokens =  parser.is_group?("{~ORC~OBR~11~12~13~15~{~25~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}")
    isCheck, tokens =  parser.is_group?("~ORC~OBR~11~12~13~15~{~25~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~")
    p tokens
    assert_false isCheck && parser.is_group_resolved?(tokens) # check for case of all groups resolved
    assert_equal(["ORC", "OBR", "11", "12", "13", "15", "25", "FT1", "CTI", "BLG"], tokens)

	end


  def test_init_with_versions
   # vs =
   #     [
   #         {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml"}]},
   #         {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
   #     ]
   # pps =  ProfileParserStub.new({std: '2.4.', version: '2.4.HL7', version_store: vs})
    pps = ProfileParser.new(@attrs)
    results =  pps.lookup_message_types('QBP_Q2')
   # puts results
   assert_equal 5, results.size

  end

  # use test configurations for lookup methods to run throug different scenarios
  class ProfileParserStub < ProfileParser

    # def initialize(args)
    # #   args.each do |k,v|
    # #     instance_variable_set("@#{k}", v) unless v.nil?
    # # end
    # #
    #   super.initialize(args)
    # end

    def self.get_schema_location
      '../test/test-config/schema/'
    end

  end

  # use of a stab to point to location of test resources
	def test_lookup_versions
		versions = ProfileParserStub.lookup_versions()
    assert_equal 2, versions.size

		coll=[]
		versions.each{ |version|
			ver_attrs={}
      # standard
			ver_attrs[:std] = version[:std]
      #versions
      ver_attrs[:versions] = version[:profiles].inject([]){|col,p| col << {name: p[:doc], code: p[:name], desc: (p[:std])? 'Base': p[:description]}}

      #events
      # version[:profiles].each{|p|

      #   parser = ProfileParserStub.new({std: version[:std], version: p[:doc], version_store: versions})
      #   events = parser.lookup_message_types('ADT_A|QBP_Q2|RSP_K2')#@@ADM_FILTER
      #   e_map[p[:name]]= events
      # }

			evn_attrs = version[:profiles].inject({}){|h,p|
				h.merge({p[:name] => ProfileParserStub.new({std: version[:std], version: p[:doc], version_store: versions}).lookup_message_types('ADT_A|QBP_Q2|RSP_K2')})
			}
      ver_attrs[:events] = evn_attrs

      # add map with versions and events for each standard to the array
			coll << ver_attrs
    }

    versions_to_client = {standards: coll}
    puts versions_to_client
	end


  def test_processSegments_pharm
    # first pass
    # 1) look for repeading groups
    # 2) brake them into subgroups - arrays
    # second pass
    # 3) go over and find optional groups
    # 4) brake them into subgroups - arrays
    #
    # arr
    # e
    # arr [e,arr[e,e,e],arr[e,e,e],e, e,]
    # seg : "[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]"

    # to do
    #   resolve {} complex groups
    #   within {} complex groups finish encoding
    #   handle complex [] groups
    #   handle groups need to handle arrays of subgroups
    #   refactor!!!


    parser = ProfileParser.new(@attrs)
    struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
    # struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    results = parser.process(struct)
    puts results
    assert_equal(2, results.size())

    profile_idx = 0
    segments_idx = 1
    #refactored, results returned as collection of arrays instead of map

    # assert_equal(21, results[segments_idx].size())
    # assert_equal('[~PD1~]', results[segments_idx][0])
  end

end
