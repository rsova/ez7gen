# require "minitest/autorun"
require 'test/unit'
require 'benchmark'
require 'logger'
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

   # def test_processSegments
    # parser = ProfileParser.new(@attrs)
    # struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    # results = parser.process_segments(struct)
    # puts results
    # assert_equal(2, results.size())
    # # "MSH~EVN~PID~0~1~2~PV1~3~4~5~6~7~8~9~11~12~16~17~18~19~20"
    # # ["[~PD1~]", "[~{~ROL~}~]", "[~{~NK1~}~]", "[~PV2~]", "[~{~ROL~}~]", "[~{~DB1~}~]", "[~{~OBX~}~]", "[~{~AL1~}~]", "[~{~DG1~}~]", "[~DRG~]", "[~{~ROL~}~]", ["PR1", "[~{~ROL~}~]"], "[~{~GT1~}~]", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]", ["IN1", "[~IN2~]", "[~{~IN3~}~]", "[~{~ROL~}~]"], "[~ACC~]", "[~UB1~]", "[~UB2~]", "[~PDA~]"]
   #
   #
    # profile_idx = 0
    # segments_idx = 1
    # #refactored, results returned as collection of arrays instead of map
   #
    # assert_equal(21, results[segments_idx].size())
    # assert_equal('[~PD1~]', results[segments_idx][0])
	 # end


		# def test_processSegments_RSP_K22_group
     #  parser = ProfileParser.new(@attrs)
     #  struct = 'MSH~MSA~[~ERR~]~QAK~QPD~{~[~PID~[~PD1~]~[~QRI~]~]~}~[~DSC~]'
     #  profile, encodedSegments = parser.process_segments(struct)
     #  # p profile
     #  # p encodedSegments
		# 	assert_equal(7, profile.size())
		# 	assert_equal(6, encodedSegments.size()) # to groups
    #
		# 	assert_equal(3, encodedSegments[3].size())
     #  assert_equal('Array', encodedSegments[3].class.name)
		# end

    # def test_processSegments_not_optional_group
    #   # <MessageStructure name='ADT_A45' definition='MSH~EVN~PID~[~PD1~]~{~MRG~PV1~}' />
    #   parser = ProfileParser.new(@attrs)
    #   struct = "MSH~[~{~ROL~}~]~[~PD1~]~{~MRG~PV1~}"
    #   results = parser.process_segments(struct)
    #   p results
    #   assert_equal(2, results.size())
    #
    #   profile_idx = 0
    #   segments_idx = 1
    #   #refactored, results returned as collection of arrays instead of map
    #
    #   assert_equal(3, results[segments_idx].size())
    #   assert_equal('[~{~ROL~}~]', results[segments_idx][0])
    # end



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

	def test_codeTable_special_ch_2
    parser = ProfileParser.new(@attrs)
    # now look in val and description - no 'L&amp;I'
		attributes = parser.get_code_table("338")
		# p attributes.*[:description]
    actual = attributes.collect{|a| a[:value]}
    # p actual
    assert_false actual.include?('L&I')#('L&amp;I')
		assert_equal 10, attributes.size
	end

  # def test_getSegments
  #   parser = ProfileParser.new(@attrs)
  #   results =  parser.get_segments
  #   profile_idx = 0
  #   segments_idx = 1
  #   #refactored, results returned as collection of arrays instead of map
  #   assert_equal(21, results[profile_idx].size())
  #   assert_equal('[~PD1~]', results[segments_idx][0])
  # end

   # def test_getSegments_vaz
		#  puts Benchmark.measure("segments"){
    #    @attrs[:version] = 'VAZ2.4.HL7'
    #    parser = ProfileParser.new(@attrs)
    #    # parser = ProfileParser.new({version:'vaz2.4', event:'ADT_A01'})
    #    results =  parser.get_segments
    #    puts results
    #  }
		#  # assert_equal(21, results[:@encodedSegments].size())
		#  # assert_equal('[~PD1~]', results[:@encodedSegments][0])
	 # end

	def test_lookupMessageTypes_vaz24
    @attrs[:version] = 'VAZ2.4.HL7'
    parser = ProfileParser.new(@attrs)
    # parser = ProfileParser.new({version: 'vaz2.4', event: 'ADT_A01'})
		results =  parser.lookup_message_types()
		puts results
		assert_equal 50, results.size

    results =  parser.lookup_message_types({filter: 'ADT_|QBP_|RSP_', group:'Admission'})
    puts results
    assert_equal 11, results.size
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
    filter = {filter: 'ADT_A', group: 'ADT'}
    results =  parser.lookup_message_types(filter)
    # puts results
    assert_equal 57, results.size

  end

	def test_lookupMessageTypes_24_QBP
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
    filter = {filter: 'QBP_Q2', group: 'QBP'}
    # parser = ProfileParser.new({version:'2.4'})
    results =  parser.lookup_message_types(filter)
    # puts results
    assert_equal 5, results.size
  end

	def test_lookupMessageTypes_24_RSP_K2
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
		# parser = ProfileParser.new({version:'2.4'})
    filter = {filter: 'RSP_K2', group: 'RSP'}
    results =  parser.lookup_message_types(filter)
    # puts results
    assert_equal 5, results.size
  end

	def test_lookupMessageTypes_24_Admissions
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
    # parser = ProfileParser.new({version:'2.4'})
    # if(message.starts_with('ADT_')||message.starts_with('QBP_')||message.starts_with('RSP_'))
    # results =  parser.lookup_message_types('ADT_A|QBP_Q2|RSP_K2')
    results =  parser.lookup_message_types(ProfileParser::FILTER_ADM)
    puts results[0]
    assert_equal 66, results.size
    assert_equal({:name=>'ADT_A01', :code=>'ADT/ACK - Admit / visit notification', :group=>'Admissions'}, results[0])
  end


  # def test_is_group_true_encoded
  #   parser = ProfileParser.new(@attrs)
  #   isCheck, tokens =  parser.is_group?("{~3~}")
  #  assert_true isCheck
  #  assert_equal(['3'], tokens)
  # end

  # def test_is_group_true_all_required
  #   parser = ProfileParser.new(@attrs)
  #   isCheck, tokens =  parser.is_group?("{~MRG~PV1~}")
  #   assert_true isCheck
  #   assert_equal(["MRG", "PV1"], tokens)
  # end

  # def test_is_group_false
  #   parser = ProfileParser.new(@attrs)
  #   isCheck, tokens =  parser.is_group?("{~MRG~}")
  #   assert_true !isCheck
  #   assert_equal(['MRG'], tokens)
  # end

  # def test_is_group_resolved
   #  parser = ProfileParser.new(@attrs)
   #  tokens =[]
   #  isCheck, tokens =  parser.is_group?("{~25~}")
   #  p tokens
   #  assert_true isCheck
   #  # assert_true isCheck && parser.is_group_resolved?(tokens)  # check for case of all groups resolved
   #  assert_equal(['25'], tokens)
  #
   #  isCheck, tokens =  parser.is_group?("{~25~[~17~]~}")
   #  p tokens
   #  assert_true isCheck
   #  # assert_true isCheck && parser.is_group_resolved?(tokens) # check for case of all groups resolved
   #  assert_equal(['25','17'], tokens)
  #
   #  isCheck, tokens =  parser.is_group?("{~25~[~OBX~]~}")
   #  p tokens
   #  assert_true isCheck
   #  # assert_false isCheck && parser.is_group_resolved?(tokens) # check for case of all groups resolved
   #  assert_equal(['25','OBX'], tokens)
  #
   #  # isCheck, tokens =  parser.is_group?("{~ORC~OBR~11~12~13~15~{~25~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}")
   #  isCheck, tokens =  parser.is_group?("~ORC~OBR~11~12~13~15~{~25~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~")
   #  p tokens
   #  assert_true isCheck
   #  # assert_false isCheck && parser.is_group_resolved?(tokens) # check for case of all groups resolved
   #  assert_equal(["ORC", "OBR", "11", "12", "13", "15", "25", "FT1", "CTI", "BLG"], tokens)
  #
	# end


  def test_init_with_versions
   # vs =
   #     [
   #         {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
   #         {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
   #     ]
   # pps =  ProfileParserStub.new({std: '2.4.', version: '2.4.HL7', version_store: vs})
    pps = ProfileParser.new(@attrs)
    filter = {filter: 'QBP_Q2', group: 'QBP'}
    results =  pps.lookup_message_types(filter)
   # puts results
   assert_equal 5, results.size

  end

  # use test configurations for lookup methods to run throug different scenarios
  class ProfileParserStub < ProfileParser

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
      filter = ProfileParserStub::FILTER_ADM

			evn_attrs = version[:profiles].inject({}){|h,p|
				h.merge({p[:name] => ProfileParserStub.new({std: version[:std], version: p[:doc], version_store: versions}).lookup_message_types(filter)})
			}
      ver_attrs[:events] = evn_attrs

      # add map with versions and events for each standard to the array
			coll << ver_attrs
    }

    versions_to_client = {standards: coll}
    $log.unknown versions_to_client

  end

  def test_lookup_versions_using_rules

    versions = ProfileParserStub.lookup_versions()
    assert_equal 2, versions.size

    coll=[]
    versions.each{ |version|
      ver_attrs={}
      # standard
      ver_attrs[:std] = version[:std]
      #versions
      ver_attrs[:versions] = version[:profiles].inject([]){|col,p| col << {name: p[:doc], code: p[:name], desc: (p[:std])? 'Base': p[:description]}}


        evn_attrs = version[:profiles].inject({}){|h,p|
          filter_map = nil
          exclusions = ProfileParserStub.getExclusionFilterRule(p[:name], p[:doc])
          h.merge({p[:name] => ProfileParserStub.new({std: version[:std], version: p[:doc], version_store: versions}).lookup_message_types(filter_map, exclusions)})
        }

      # filter = ProfileParserStub.getExclusionFilter(p[:name], p[:doc]);
      # if(p[:name]=='2.4' &&  p[:doc]=='2.4.HL7')
      #   assert_equal 137, filter.size
      # elsif
      # assert_equal 0, filter.size
      # end

      ver_attrs[:events] = evn_attrs

      # add map with versions and events for each standard to the array
      coll << ver_attrs
    }

    versions_to_client = {standards: coll}
    puts versions_to_client
  end


  def test_getExclusionFilter
    std = '2.4'
    version = "2.4.HL7"
    filter = ProfileParserStub.getExclusionFilterRule(std, version);
    puts filter
    assert_equal 137, filter.size
  end

  def test_getExclusionFilter_no_rules_file
    std = '2.4'
    version = "Bla-bla"
    filter = ProfileParserStub.getExclusionFilterRule(std, version);
    puts filter
    assert_equal 0, filter.size
  end

  def test_lookup_message_types_24_Pharm
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
    # 1    OMP_O09    Pharmacy/treatment order message
    # 2    ORP_O10    Pharmacy/treatment order acknowledgement
    # 3    RDE_O11    Pharmacy/treatment encoded order message
    # 4    RRE_O12    Pharmacy/treatment encoded order acknowledgement
    # 5    RDS_O13    Pharmacy dispense message
    # 6    RRD_O14    Pharmacy/treatment dispense acknowledgement
    # 7    RGV_O15    Pharmacy give message
    # 8    RRG_O16    Pharmacy/treatment give acknowledgement
    # 9    RAS_O17    Pharmacy administration message
    # 10  RRA_O18    Pharmacy/treatment administration acknowledgement

    # filter= {filter: 'OMP_|ORP_|RDE_|RRE_|RDS_|RRD_|RGV_|RRG_|RAS_|RRA_', group: 'Pharmacy'}

    results =  parser.lookup_message_types(ProfileParser::FILTER_PH)
    puts results[0]
    assert_equal 10, results.size
    assert_equal({:name=>"OMP_O09", :code=>"OMP - Pharmacy/treatment order", :group=>"Pharmacy"}, results[0])

  end

  def test_lookup_message_types_24_all
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)

    # all
    all = parser.lookup_message_types()
    assert_equal 390, parser.lookup_message_types().size
    msgs = []
    all.each{|it| msgs << it[:name] }
    # p msgs
  #   ["ACK", "ACK_N02", "ACK_R01", "ADR_A19", "ADT_A01", "ADT_A02", "ADT_A03", "ADT_A04", "ADT_A05", "ADT_A06", "ADT_A07", "ADT_A08", "ADT_A09", "ADT_A10", "ADT_A11", "ADT_A12", "ADT_A13", "ADT_A14", "ADT_A15", "ADT_A16", "ADT_A17", "ADT_A18", "ADT_A20", "ADT_A21", "ADT_A22", "ADT_A23", "ADT_A24", "ADT_A25", "ADT_A26", "ADT_A27", "ADT_A28", "ADT_A29", "ADT_A30", "ADT_A31", "ADT_A32", "ADT_A33", "ADT_A34", "ADT_A35", "ADT_A36", "ADT_A37", "ADT_A38", "ADT_A39", "ADT_A40", "ADT_A41", "ADT_A42", "ADT_A43", "ADT_A44", "ADT_A45", "ADT_A46", "ADT_A47", "ADT_A48", "ADT_A49", "ADT_A50", "ADT_A51", "ADT_A52", "ADT_A53", "ADT_A54", "ADT_A55", "ADT_A60", "ADT_A61", "ADT_A62", "BAR_P01", "BAR_P02", "BAR_P05", "BAR_P06", "BAR_P10", "BHS", "CRM_C01", "CRM_C02", "CRM_C03", "CRM_C04", "CRM_C05", "CRM_C06", "CRM_C07", "CRM_C08", "CSU_C09", "CSU_C10", "CSU_C11", "CSU_C12", "DFT_P03", "DFT_P11", "DOC_T12", "DSR_P04", "DSR_Q01", "DSR_Q03", "EAC_U07", "EAN_U09", "EAR_U08", "EDR_R07", "EQQ_Q04", "ERP_R09", "ESR_U02", "ESU_U01", "FHS", "INR_U06", "INU_U05", "LSR_U13", "LSU_U12", "MDM_T01", "MDM_T02", "MDM_T03", "MDM_T04", "MDM_T05", "MDM_T06", "MDM_T07", "MDM_T08", "MDM_T09", "MDM_T10", "MDM_T11", "MFK_M01", "MFK_M02", "MFK_M03", "MFK_M04", "MFK_M05", "MFK_M06", "MFK_M07", "MFN_M01", "MFN_M02", "MFN_M03", "MFN_M04", "MFN_M05", "MFN_M06", "MFN_M07", "MFN_M08", "MFN_M09", "MFN_M10", "MFN_M11", "MFN_M12", "MFQ_M01", "MFQ_M01_2", "MFQ_M02_2", "MFQ_M03_2", "MFQ_M04_2", "MFQ_M05_2", "MFQ_M06_2", "MFR_M01", "MFR_M02", "MFR_M03", "MFR_M04", "MFR_M05", "MFR_M06", "NMD_N02", "NMQ_N01", "NMR_N01", "NUL_K11", "NUL_K13", "NUL_K15", "NUL_K21", "NUL_K22", "NUL_K23", "NUL_K24", "NUL_K25", "NUL_O04", "NUL_O06", "NUL_O08", "NUL_O10", "NUL_O12", "NUL_O14", "NUL_O16", "NUL_O18", "NUL_O20", "NUL_O22", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R04", "NUL_R07", "NUL_R08", "NUL_R09", "NUL_RAR", "NUL_RDR", "NUL_RER", "NUL_RGR", "NUL_ROR", "NUL_V02", "NUL_V03", "NUL_Z74", "NUL_Z82", "NUL_Z86", "NUL_Z88", "NUL_Z90", "OMD_O03", "OMG_O19", "OML_O21", "OMN_O07", "OMP_O09", "OMS_O05", "ORD_O04", "ORF_R04", "ORF_W02", "ORG_O20", "ORL_O22", "ORM_O01", "ORN_O08", "ORP_O10", "ORR_O02", "ORS_O06", "ORU_R01", "ORU_W01", "OSQ_Q06", "OSR_Q06", "OUL_R21", "PEX_P07", "PEX_P08", "PGL_PC6", "PGL_PC7", "PGL_PC8", "PIN_I07", "PMU_B01", "PMU_B02", "PMU_B03", "PMU_B04", "PMU_B05", "PMU_B06", "PPG_PCG", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5", "PTR_PCF", "QBP_Q11", "QBP_Q13", "QBP_Q15", "QBP_Q21", "QBP_Q22", "QBP_Q23", "QBP_Q24", "QBP_Q25", "QBP_Z73", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z81", "QBP_Z85", "QBP_Z87", "QBP_Z89", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QCK_Q02", "QCN_J01", "QRY_A19", "QRY_P04", "QRY_PC4", "QRY_PC9", "QRY_PCE", "QRY_PCK", "QRY_Q01", "QRY_Q02", "QRY_Q26", "QRY_Q27", "QRY_Q28", "QRY_Q29", "QRY_Q30", "QRY_R02", "QRY_T12", "QRY_W01", "QRY_W02", "QSB_Q16", "QSB_Z83", "QSX_J02", "QVR_Q17", "RAR_RAR", "RAS_O17", "RCI_I05", "RCL_I06", "RDE_O11", "RDR_RDR", "RDS_O13", "RDY_K15", "RDY_Z80", "RDY_Z98", "REF_I12", "REF_I13", "REF_I14", "REF_I15", "RER_RER", "RGR_RGR", "RGV_O15", "ROR_ROR", "RPA_I08", "RPA_I09", "RPA_I10", "RPA_I11", "RPI_I01", "RPI_I04", "RPL_I02", "RPR_I03", "RQA_I08", "RQA_I09", "RQA_I10", "RQA_I11", "RQC_I05", "RQC_I06", "RQI_I01", "RQI_I02", "RQI_I03", "RQP_I04", "RQQ_Q09", "RRA_O18", "RRD_O14", "RRE_O12", "RRG_O16", "RRI_I12", "RRI_I13", "RRI_I14", "RRI_I15", "RSP_K11", "RSP_K13", "RSP_K15", "RSP_K21", "RSP_K22", "RSP_K23", "RSP_K24", "RSP_K25", "RSP_Z82", "RSP_Z84", "RSP_Z86", "RSP_Z88", "RSP_Z90", "RTB_K13", "RTB_Knn", "RTB_Q13", "RTB_Z74", "RTB_Z76", "RTB_Z78", "RTB_Z92", "RTB_Z94", "RTB_Z96", "SIU_S12", "SIU_S13", "SIU_S14", "SIU_S15", "SIU_S16", "SIU_S17", "SIU_S18", "SIU_S19", "SIU_S20", "SIU_S21", "SIU_S22", "SIU_S23", "SIU_S24", "SIU_S26", "SPQ_Q08", "SQM_S25", "SQR_S25", "SRM_S01", "SRM_S02", "SRM_S03", "SRM_S04", "SRM_S05", "SRM_S06", "SRM_S07", "SRM_S08", "SRM_S09", "SRM_S10", "SRM_S11", "SRR_S01", "SRR_S02", "SRR_S03", "SRR_S04", "SRR_S05", "SRR_S06", "SRR_S07", "SRR_S08", "SRR_S09", "SRR_S10", "SRR_S11", "SSR_U04", "SSU_U03", "SUR_P09", "TBR_R08", "TCR_U11", "TCU_U10", "UDM_Q05", "VQQ_Q07", "VXQ_V01", "VXR_V03", "VXU_V04", "VXX_V02"]

  end

  def test_lookup_message_groups
    @attrs.delete(:event)# no events passed to lookup all event types
    parser = ProfileParser.new(@attrs)
    results =  parser.lookup_message_groups([ProfileParser::FILTER_PH, ProfileParser::FILTER_ADM])
    puts results
    assert_equal 76, results.size
    assert_equal({:name=>"OMP_O09", :code=>"OMP - Pharmacy/treatment order", :group=>"Pharmacy"}, results[0])
    assert_equal({:name=>"RSP_K24", :code=>"RSP - Allocate identifiers response", :group=>"Admissions"}, results[75])

  end

  def test_get_templates
    parser = ProfileParser.new(@attrs)
    path = "../test/test-config/templates/2.4/"
    # path =  '/Users/romansova/RubymineProjects/ez7gen/test/test-config/templates/2.4'
    #templates = Dir.entries(path).select {|f| f =~/.xml/}.sort
    # templates = Dir.glob("#{path}/*")
    #templates =  Dir[path + '/*.xml'].
    # templates = Dir.glob(path + '/*.xml').select{|f| File(f)}
     templates = parser.get_templates(path)
    puts templates
  end


  def test_lookup_events
    @attrs[:version] = 'VAZ2.4.HL7'
    parser = ProfileParser.new(@attrs)
    lookup_params ={}
    lookup_params[:templates_path] =  File.expand_path("../test-config/templates/#{@attrs[:std]}/", __FILE__)

    results = parser.lookup_events(lookup_params);

  end


    # def test_processSegments_pharm
  #   # first pass
  #   # 1) look for repeading groups
  #   # 2) brake them into subgroups - arrays
  #   # second pass
  #   # 3) go over and find optional groups
  #   # 4) brake them into subgroups - arrays
  #   #
  #   # arr
  #   # e
  #   # arr [e,arr[e,e,e],arr[e,e,e],e, e,]
  #   # seg : "[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]"
  #
  #   # to do
  #   #   resolve {} complex groups
  #   #   within {} complex groups finish encoding
  #   #   handle complex [] groups
  #   #   handle groups need to handle arrays of subgroups
  #   #   refactor!!!
  #
  #
  #   parser = ProfileParser.new(@attrs)
  #   struct = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
  #   # struct = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
  #   results = parser.process(struct)
  #   puts results
  #   assert_equal(2, results.size())
  #
  # end

end
