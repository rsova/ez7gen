# require "minitest/autorun"
require 'test/unit'
require "benchmark"
require_relative '../lib/ez7gen/profile_parser'

class ProfileParserTest < Test::Unit::TestCase
	
	def setup
		@parser = ProfileParser.new('2.4', 'ADT_A01')
	end
	def teardown
		@parser = nil
	end
	def test_init
		assert(@parser !=nil)
		# assert(hl7 != nil)
		# refute_nil(hl7)
	end


	def test_getMessageDefinition
		expected = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
		assert_equal(expected, @parser.get_message_definition())
	end

	def test_getMessageStructure_ADT_01
		assert_equal('ADT_A01', @parser.get_message_structure('ADT_A01'))
  end

	def test_getMessageStructure_ADT_04
		assert_equal('ADT_A01', @parser.get_message_structure('ADT_A04'))
	end

	def test_getSegmentStructure
		al1 =  @parser.get_segment_structure('[~{~AL1~}~]')
		puts al1
		assert_equal 6, al1.size
		assert_equal('Set ID - AL1', al1.first['description'.to_sym])
	end

   def test_processSegments
   		struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
   		results = @parser.process_segments(struct)
   		assert_equal(2, results.size())

      profile_idx = 0
      segments_idx = 1
      #refactored, results returned as collection of arrays instead of map

      assert_equal(21, results[segments_idx].size())
   		assert_equal('[~PD1~]', results[segments_idx][0])
	 end


		def test_processSegments_RSP_K22_group
			struct = 'MSH~MSA~[~ERR~]~QAK~QPD~{~[~PID~[~PD1~]~[~QRI~]~]~}~[~DSC~]'
      profile, encodedSegments = @parser.process_segments(struct)
      # p profile
      # p encodedSegments
			assert_equal(7, profile.size())
			assert_equal(6, encodedSegments.size()) # to groups

			assert_equal(3, encodedSegments[3].size())
      assert_equal('Array', encodedSegments[3].class.name)
		end

		def test_processSegments_not_optional_group
      # <MessageStructure name='ADT_A45' definition='MSH~EVN~PID~[~PD1~]~{~MRG~PV1~}' />
      struct = "MSH~[~{~ROL~}~]~[~PD1~]~{~MRG~PV1~}"
      results = @parser.process_segments(struct)
      p results
      assert_equal(2, results.size())

      profile_idx = 0
      segments_idx = 1
      #refactored, results returned as collection of arrays instead of map

      assert_equal(3, results[segments_idx].size())
      assert_equal('[~{~ROL~}~]', results[segments_idx][0])
    end



	def test_codeTable
   		attributes = @parser.get_code_table("62")
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
		attributes = @parser.get_code_table('296')
		p attributes[0].class
		p attributes.size
		# assert (attributes[0][:position] =='1' && attributes[0][:value] =='EN')
	end

   def test_codeTable_NoVals
   		attributes = @parser.get_code_table("-296")
   		p attributes[0].class
			p attributes.size
			assert (attributes[0][:position] =='1' && attributes[0][:value] =='...')
	 end

	def test_codeTable_blank
		attributes = @parser.get_code_table("")
		p attributes
		print attributes.empty?
	end

   def test_getSegments
			results =  @parser.get_segments
			profile_idx = 0
			segments_idx = 1
			#refactored, results returned as collection of arrays instead of map
			assert_equal(21, results[profile_idx].size())
			assert_equal('[~PD1~]', results[segments_idx][0])
	 end

   def test_getSegments_vaz
		 puts Benchmark.measure("segments"){
		 @parser = ProfileParser.new('vaz2.4', 'ADT_A01')
		 results =  @parser.get_segments
		 puts results
					}
		 # assert_equal(21, results[:@encodedSegments].size())
		 # assert_equal('[~PD1~]', results[:@encodedSegments][0])
	 end

	def test_lookupMessageTypes_vaz24
		@parser = ProfileParser.new('vaz2.4', 'ADT_A01')
		results =  @parser.lookup_message_types('')
		puts results
		assert_equal 2, results.size

    results =  @parser.lookup_message_types('ADT_|QBP_|RSP_')
    puts results
    assert_equal 1, results.size

  end
  def test_lookupMessageTypes_24_all
    @parser = ProfileParser.new('2.4')
    results =  @parser.lookup_message_types()
    assert_equal 390, results.size

    # puts results
    results =  @parser.lookup_message_types(nil)
    assert_equal 390, results.size
    # puts results
  end

	def test_lookupMessageTypes_24_ADT
		@parser = ProfileParser.new('2.4')
    results =  @parser.lookup_message_types('ADT_A')
    # puts results
    assert_equal 57, results.size

  end

	def test_lookupMessageTypes_24_QBP
		@parser = ProfileParser.new('2.4')
    results =  @parser.lookup_message_types('QBP_Q2')
    # puts results
    assert_equal 5, results.size
  end

	def test_lookupMessageTypes_24_RSP_K2
		@parser = ProfileParser.new('2.4')
    results =  @parser.lookup_message_types('RSP_K2')
    # puts results
    assert_equal 5, results.size
  end

	def test_lookupMessageTypes_24_RSP_Admissions
		@parser = ProfileParser.new('2.4')
    # if(message.starts_with('ADT_')||message.starts_with('QBP_')||message.starts_with('RSP_'))
    results =  @parser.lookup_message_types('ADT_A|QBP_Q2|RSP_K2')
    puts results[0]
    assert_equal 67, results.size
    assert_equal({:name=>'ADT_A01', :code=>'ADT/ACK - Admit / visit notification'}, results[0])
  end

  def test_is_group_true_encoded
   isCheck, tokens =  @parser.is_group?("{~3~}")
   assert_true isCheck
   assert_equal(['3'], tokens)
  end

  def test_is_group_true_all_required
   isCheck, tokens =  @parser.is_group?("{~MRG~PV1~}")
   assert_true isCheck
   assert_equal(["MRG", "PV1"], tokens)
  end

  def test_is_group_false
    isCheck, tokens =  @parser.is_group?("{~MRG~}")
    assert_true !isCheck
    assert_equal(['MRG'], tokens)
	end

  # use test configurations for lookup methods to run throug different scenarios
  class ProfileParserStubx < ProfileParser
    def self.get_schema_location
      '../test/test-config/schema/'
    end
  end

	def test_lookup_versions
		versions =  ProfileParserStubx.lookup_versions()
    assert_equal 2, versions.size
	end

end
