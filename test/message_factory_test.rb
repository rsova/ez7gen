require 'test/unit'
require_relative '../lib/ez7gen/message_factory'

class MessageFactoryTest < Test::Unit::TestCase
    # alias :orig_run :run
    # def run(*args,&blk)
    #   4.times { orig_run(*args,&blk) }
    # end

  #set to true to write messages to a file
  @@PERSIST = true

  @@VS =
      [
          # {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4.HL7.xml.bkp"}]},
          {:std=>"2.4", :path=>"../test/test-config/schema/2.4", :profiles=>[{:doc=>"2.4.HL7", :name=>"2.4", :std=>"1", :path=>"../test/test-config/schema/2.4/2.4.HL7.xml"}, {:doc=>"VAZ2.4.HL7", :name=>"VAZ2.4", :description=>"2.4 schema with VA defined tables and Z segments", :base=>"2.4", :path=>"../test/test-config/schema/2.4/VAZ2.4HL7.xml"}]},
          {:std=>"2.5", :path=>"../test/test-config/schema/2.5", :profiles=>[{:doc=>"2.5.HL7", :name=>"2.5", :std=>"1", :path=>"../test/test-config/schema/2.5/2.5.HL7.xml"}, {:doc=>"TEST2.5.HL7", :name=>"TEST2.5", :description=>"2.5 mockup schema for testing", :base=>"2.4", :path=>"../test/test-config/schema/2.5/VAZ2.5.HL7.xml"}]}
      ]


  # helper message to persist the
  def saveMsg(event, hl7, ver)
    if(defined?(@@PERSIST) && @@PERSIST) then
      # File.open("../msg-samples/#{ver}/#{event}.txt", 'a') { |f| f.write(hl7); f.write("\n\n") }
      File.write("../msg-samples/#{ver}/#{event}-#{Time.new.strftime('%H%M%S%L')}.txt", hl7);
    end
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_lookup_template_for_event
    std='2.4'
    ver='VAZ2.4.HL7'
    event='ADT_A60'

    factory = MessageFactory.new({std: std, version: ver, event:event, version_store: @@VS, use_template:true})
    expected = "/Users/romansova/RubymineProjects/ez7gen/ez7gen-web/config/templates/2.4/vista sqwm-adt_a60.xml"
    assert_equal expected, factory.templatePath

    factory = MessageFactory.new({std: std, version: ver, event: event, use_template: false, version_store: @@VS})
    assert_nil factory.templatePath

    factory = MessageFactory.new({std: std, version: ver, event:event, version_store: @@VS})
    assert_nil factory.templatePath

    event='ADT_60'
    factory = MessageFactory.new({std: std, version: ver, event:event, version_store: @@VS})
    assert_nil factory.templatePath

  end

  def test_problem

    # e = "PTR_PCF"
    # e = "RSP_K13"
    # e = 'SRM_S01'
    # e = 'TBR_R08'
    #e = 'RSP_K25'# ORG.10 and STF.20 need to be populated ONLY with the code from table 66, without the description (which is very confusing, in my opinion, since the data type is CE, but the allowed length is only 2).
    # e = 'SQM_S25'# batch 8; ARQ.13.1 – the value needs to come from table 335; APR.5.2 – the value needs to come from table 294
    # e = "TBR_R08" #missing data type in RDT segment
    # e = "PTR_PCF"
    #["PMU_B01", "PMU_B03", "PMU_B04"] #This was reported to you before – STF. Field 20, repetition 1 is larger than segment structure 2.4:STF
    # e = "PMU_B01"
    # e = "MFN_M02"
    # e = "MFN_M05"
    # MFN_M07, MFN_M09 and MFN_M12
    # e = "MFN_M09" # OM1 missing field 18 /, ()
    # e = 'RRA_O18'
    e = 'TBR_R08' # RDT
    ver= '2.4.HL7'
    hl7 = MessageFactory.new({std: '2.4', version: ver, event:e, version_store: @@VS, loadfactor: 1}).generate
    puts hl7

  end

  def test_all
    all_events = ["ACK", "ACK_N02", "ACK_R01", "ADR_A19", "ADT_A01", "ADT_A02", "ADT_A03", "ADT_A04", "ADT_A05", "ADT_A06", "ADT_A07", "ADT_A08", "ADT_A09", "ADT_A10", "ADT_A11", "ADT_A12", "ADT_A13", "ADT_A14", "ADT_A15", "ADT_A16", "ADT_A17", "ADT_A18", "ADT_A20", "ADT_A21", "ADT_A22", "ADT_A23", "ADT_A24", "ADT_A25", "ADT_A26", "ADT_A27", "ADT_A28", "ADT_A29", "ADT_A30", "ADT_A31", "ADT_A32", "ADT_A33", "ADT_A34", "ADT_A35", "ADT_A36", "ADT_A37", "ADT_A38", "ADT_A39", "ADT_A40", "ADT_A41", "ADT_A42", "ADT_A43", "ADT_A44", "ADT_A45", "ADT_A46", "ADT_A47","ADT_A48", "ADT_A49", "ADT_A50", "ADT_A51", "ADT_A52", "ADT_A53", "ADT_A54", "ADT_A55", "ADT_A60", "ADT_A61", "ADT_A62", "BAR_P01", "BAR_P02", "BAR_P05", "BAR_P06", "BAR_P10", "BHS", "CRM_C01", "CRM_C02", "CRM_C03", "CRM_C04", "CRM_C05", "CRM_C06", "CRM_C07", "CRM_C08", "CSU_C09", "CSU_C10", "CSU_C11", "CSU_C12", "DFT_P03", "DFT_P11", "DOC_T12", "DSR_P04", "DSR_Q01", "DSR_Q03", "EAC_U07", "EAN_U09", "EAR_U08", "EDR_R07", "EQQ_Q04", "ERP_R09", "ESR_U02", "ESU_U01", "FHS", "INR_U06", "INU_U05", "LSR_U13", "LSU_U12", "MDM_T01", "MDM_T02", "MDM_T03", "MDM_T04", "MDM_T05", "MDM_T06", "MDM_T07", "MDM_T08", "MDM_T09", "MDM_T10", "MDM_T11", "MFK_M01", "MFK_M02", "MFK_M03", "MFK_M04", "MFK_M05", "MFK_M06", "MFK_M07", "MFN_M01", "MFN_M02", "MFN_M03", "MFN_M04", "MFN_M05", "MFN_M06", "MFN_M07", "MFN_M08", "MFN_M09", "MFN_M10", "MFN_M11", "MFN_M12", "MFQ_M01", "MFQ_M01_2", "MFQ_M02_2", "MFQ_M03_2", "MFQ_M04_2", "MFQ_M05_2", "MFQ_M06_2", "MFR_M01", "MFR_M02", "MFR_M03", "MFR_M04", "MFR_M05", "MFR_M06", "NMD_N02", "NMQ_N01", "NMR_N01", "NUL_K11", "NUL_K13", "NUL_K15", "NUL_K21", "NUL_K22", "NUL_K23", "NUL_K24", "NUL_K25", "NUL_O04", "NUL_O06", "NUL_O08", "NUL_O10", "NUL_O12", "NUL_O14", "NUL_O16", "NUL_O18", "NUL_O20", "NUL_O22", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R04", "NUL_R07", "NUL_R08", "NUL_R09", "NUL_RAR", "NUL_RDR", "NUL_RER", "NUL_RGR", "NUL_ROR", "NUL_V02", "NUL_V03", "NUL_Z74", "NUL_Z82", "NUL_Z86", "NUL_Z88", "NUL_Z90", "OMD_O03", "OMG_O19", "OML_O21", "OMN_O07", "OMP_O09", "OMS_O05", "ORD_O04", "ORF_R04", "ORF_W02", "ORG_O20", "ORL_O22", "ORM_O01", "ORN_O08", "ORP_O10", "ORR_O02", "ORS_O06", "ORU_R01", "ORU_W01", "OSQ_Q06", "OSR_Q06", "OUL_R21", "PEX_P07", "PEX_P08", "PGL_PC6", "PGL_PC7", "PGL_PC8", "PIN_I07", "PMU_B01", "PMU_B02", "PMU_B03", "PMU_B04", "PMU_B05", "PMU_B06", "PPG_PCG", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5", "PTR_PCF", "QBP_Q11", "QBP_Q13", "QBP_Q15", "QBP_Q21", "QBP_Q22", "QBP_Q23", "QBP_Q24", "QBP_Q25", "QBP_Z73", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z81", "QBP_Z85", "QBP_Z87", "QBP_Z89", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QCK_Q02", "QCN_J01", "QRY_A19", "QRY_P04", "QRY_PC4", "QRY_PC9", "QRY_PCE", "QRY_PCK", "QRY_Q01", "QRY_Q02", "QRY_Q26", "QRY_Q27", "QRY_Q28", "QRY_Q29", "QRY_Q30", "QRY_R02", "QRY_T12", "QRY_W01", "QRY_W02", "QSB_Q16", "QSB_Z83", "QSX_J02", "QVR_Q17", "RAR_RAR", "RAS_O17", "RCI_I05", "RCL_I06", "RDE_O11", "RDR_RDR", "RDS_O13", "RDY_K15", "RDY_Z80", "RDY_Z98", "REF_I12", "REF_I13", "REF_I14", "REF_I15", "RER_RER", "RGR_RGR", "RGV_O15", "ROR_ROR", "RPA_I08", "RPA_I09", "RPA_I10", "RPA_I11", "RPI_I01", "RPI_I04", "RPL_I02", "RPR_I03", "RQA_I08", "RQA_I09", "RQA_I10", "RQA_I11", "RQC_I05", "RQC_I06", "RQI_I01", "RQI_I02", "RQI_I03", "RQP_I04", "RQQ_Q09", "RRA_O18", "RRD_O14", "RRE_O12", "RRG_O16", "RRI_I12", "RRI_I13", "RRI_I14", "RRI_I15", "RSP_K11", "RSP_K13", "RSP_K15", "RSP_K21", "RSP_K22", "RSP_K23", "RSP_K24", "RSP_K25", "RSP_Z82", "RSP_Z84", "RSP_Z86", "RSP_Z88", "RSP_Z90", "RTB_K13", "RTB_Knn", "RTB_Q13", "RTB_Z74", "RTB_Z76", "RTB_Z78", "RTB_Z92", "RTB_Z94", "RTB_Z96", "SIU_S12", "SIU_S13", "SIU_S14", "SIU_S15", "SIU_S16", "SIU_S17", "SIU_S18", "SIU_S19", "SIU_S20", "SIU_S21", "SIU_S22", "SIU_S23", "SIU_S24", "SIU_S26", "SPQ_Q08", "SQM_S25", "SQR_S25", "SRM_S01", "SRM_S02", "SRM_S03", "SRM_S04", "SRM_S05", "SRM_S06", "SRM_S07", "SRM_S08", "SRM_S09", "SRM_S10", "SRM_S11", "SRR_S01", "SRR_S02", "SRR_S03", "SRR_S04", "SRR_S05", "SRR_S06", "SRR_S07", "SRR_S08", "SRR_S09", "SRR_S10", "SRR_S11", "SSR_U04", "SSU_U03", "SUR_P09", "TBR_R08", "TCR_U11", "TCU_U10", "UDM_Q05", "VQQ_Q07", "VXQ_V01", "VXR_V03", "VXU_V04", "VXX_V02"]
    #a = ["ACK", "ACK_N02", "ACK_R01", "ADR_A19", "ADT_A01", "ADT_A02", "ADT_A03", "ADT_A04", "ADT_A05", "ADT_A06", "ADT_A07", "ADT_A08", "ADT_A09", "ADT_A10", "ADT_A11", "ADT_A12", "ADT_A13", "ADT_A14", "ADT_A15", "ADT_A16", "ADT_A17", "ADT_A18", "ADT_A20", "ADT_A21", "ADT_A22", "ADT_A23", "ADT_A24", "ADT_A25", "ADT_A26", "ADT_A27", "ADT_A28", "ADT_A29", "ADT_A30", "ADT_A31", "ADT_A32", "ADT_A33", "ADT_A34", "ADT_A35", "ADT_A36", "ADT_A37", "ADT_A38", "ADT_A39", "ADT_A40", "ADT_A41", "ADT_A42", "ADT_A43", "ADT_A44", "ADT_A45", "ADT_A46", "ADT_A47"]#, "ADT_A48", "ADT_A49", "ADT_A50", "ADT_A51", "ADT_A52", "ADT_A53", "ADT_A54", "ADT_A55", "ADT_A60", "ADT_A61", "ADT_A62", "BAR_P01", "BAR_P02", "BAR_P05", "BAR_P06", "BAR_P10", "BHS", "CRM_C01", "CRM_C02", "CRM_C03", "CRM_C04", "CRM_C05", "CRM_C06", "CRM_C07", "CRM_C08", "CSU_C09", "CSU_C10", "CSU_C11", "CSU_C12", "DFT_P03", "DFT_P11", "DOC_T12", "DSR_P04", "DSR_Q01", "DSR_Q03", "EAC_U07", "EAN_U09", "EAR_U08", "EDR_R07", "EQQ_Q04", "ERP_R09", "ESR_U02", "ESU_U01", "FHS", "INR_U06", "INU_U05", "LSR_U13", "LSU_U12", "MDM_T01", "MDM_T02", "MDM_T03", "MDM_T04", "MDM_T05", "MDM_T06", "MDM_T07", "MDM_T08", "MDM_T09", "MDM_T10", "MDM_T11", "MFK_M01", "MFK_M02", "MFK_M03", "MFK_M04", "MFK_M05", "MFK_M06", "MFK_M07", "MFN_M01", "MFN_M02", "MFN_M03", "MFN_M04", "MFN_M05", "MFN_M06", "MFN_M07", "MFN_M08", "MFN_M09", "MFN_M10", "MFN_M11", "MFN_M12", "MFQ_M01", "MFQ_M01_2", "MFQ_M02_2", "MFQ_M03_2", "MFQ_M04_2", "MFQ_M05_2", "MFQ_M06_2", "MFR_M01", "MFR_M02", "MFR_M03", "MFR_M04", "MFR_M05", "MFR_M06", "NMD_N02", "NMQ_N01", "NMR_N01", "NUL_K11", "NUL_K13", "NUL_K15", "NUL_K21", "NUL_K22", "NUL_K23", "NUL_K24", "NUL_K25", "NUL_O04", "NUL_O06", "NUL_O08", "NUL_O10", "NUL_O12", "NUL_O14", "NUL_O16", "NUL_O18", "NUL_O20", "NUL_O22", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R04", "NUL_R07", "NUL_R08", "NUL_R09", "NUL_RAR", "NUL_RDR", "NUL_RER", "NUL_RGR", "NUL_ROR", "NUL_V02", "NUL_V03", "NUL_Z74", "NUL_Z82", "NUL_Z86", "NUL_Z88", "NUL_Z90", "OMD_O03", "OMG_O19", "OML_O21", "OMN_O07", "OMP_O09", "OMS_O05", "ORD_O04", "ORF_R04", "ORF_W02", "ORG_O20", "ORL_O22", "ORM_O01", "ORN_O08", "ORP_O10", "ORR_O02", "ORS_O06", "ORU_R01", "ORU_W01", "OSQ_Q06", "OSR_Q06", "OUL_R21", "PEX_P07", "PEX_P08", "PGL_PC6", "PGL_PC7", "PGL_PC8", "PIN_I07", "PMU_B01", "PMU_B02", "PMU_B03", "PMU_B04", "PMU_B05", "PMU_B06", "PPG_PCG", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5", "PTR_PCF", "QBP_Q11", "QBP_Q13", "QBP_Q15", "QBP_Q21", "QBP_Q22", "QBP_Q23", "QBP_Q24", "QBP_Q25", "QBP_Z73", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z81", "QBP_Z85", "QBP_Z87", "QBP_Z89", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QCK_Q02", "QCN_J01", "QRY_A19", "QRY_P04", "QRY_PC4", "QRY_PC9", "QRY_PCE", "QRY_PCK", "QRY_Q01", "QRY_Q02", "QRY_Q26", "QRY_Q27", "QRY_Q28", "QRY_Q29", "QRY_Q30", "QRY_R02", "QRY_T12", "QRY_W01", "QRY_W02", "QSB_Q16", "QSB_Z83", "QSX_J02", "QVR_Q17", "RAR_RAR", "RAS_O17", "RCI_I05", "RCL_I06", "RDE_O11", "RDR_RDR", "RDS_O13", "RDY_K15", "RDY_Z80", "RDY_Z98", "REF_I12", "REF_I13", "REF_I14", "REF_I15", "RER_RER", "RGR_RGR", "RGV_O15", "ROR_ROR", "RPA_I08", "RPA_I09", "RPA_I10", "RPA_I11", "RPI_I01", "RPI_I04", "RPL_I02", "RPR_I03", "RQA_I08", "RQA_I09", "RQA_I10", "RQA_I11", "RQC_I05", "RQC_I06", "RQI_I01", "RQI_I02", "RQI_I03", "RQP_I04", "RQQ_Q09", "RRA_O18", "RRD_O14", "RRE_O12", "RRG_O16", "RRI_I12", "RRI_I13", "RRI_I14", "RRI_I15", "RSP_K11", "RSP_K13", "RSP_K15", "RSP_K21", "RSP_K22", "RSP_K23", "RSP_K24", "RSP_K25", "RSP_Z82", "RSP_Z84", "RSP_Z86", "RSP_Z88", "RSP_Z90", "RTB_K13", "RTB_Knn", "RTB_Q13", "RTB_Z74", "RTB_Z76", "RTB_Z78", "RTB_Z92", "RTB_Z94", "RTB_Z96", "SIU_S12", "SIU_S13", "SIU_S14", "SIU_S15", "SIU_S16", "SIU_S17", "SIU_S18", "SIU_S19", "SIU_S20", "SIU_S21", "SIU_S22", "SIU_S23", "SIU_S24", "SIU_S26", "SPQ_Q08", "SQM_S25", "SQR_S25", "SRM_S01", "SRM_S02", "SRM_S03", "SRM_S04", "SRM_S05", "SRM_S06", "SRM_S07", "SRM_S08", "SRM_S09", "SRM_S10", "SRM_S11", "SRR_S01", "SRR_S02", "SRR_S03", "SRR_S04", "SRR_S05", "SRR_S06", "SRR_S07", "SRR_S08", "SRR_S09", "SRR_S10", "SRR_S11", "SSR_U04", "SSU_U03", "SUR_P09", "TBR_R08", "TCR_U11", "TCU_U10", "UDM_Q05", "VQQ_Q07", "VXQ_V01", "VXR_V03", "VXU_V04", "VXX_V02"]
    #b = ["ADT_A48", "ADT_A49", "ADT_A50", "ADT_A51", "ADT_A52", "ADT_A53", "ADT_A54", "ADT_A55", "ADT_A60", "ADT_A61", "ADT_A62", "BAR_P01", "BAR_P02", "BAR_P05", "BAR_P06", "BAR_P10", "BHS", "CRM_C01", "CRM_C02", "CRM_C03", "CRM_C04", "CRM_C05", "CRM_C06", "CRM_C07", "CRM_C08"]
    #c = ["CSU_C09", "CSU_C10", "CSU_C11", "CSU_C12", "DFT_P03", "DFT_P11", "DOC_T12", "DSR_P04", "DSR_Q01", "DSR_Q03", "EAC_U07", "EAN_U09", "EAR_U08", "EDR_R07", "EQQ_Q04", "ERP_R09", "ESR_U02", "ESU_U01", "FHS", "INR_U06", "INU_U05", "LSR_U13", "LSU_U12", "MDM_T01", "MDM_T02"]
    # MFQ_M01 - needs requirements;
    #d = ["MDM_T03", "MDM_T04", "MDM_T05", "MDM_T06", "MDM_T07", "MDM_T08", "MDM_T09", "MDM_T10", "MDM_T11", "MFK_M01", "MFK_M02", "MFK_M03", "MFK_M04", "MFK_M05", "MFK_M06", "MFK_M07", "MFN_M01", "MFN_M02", "MFN_M03", "MFN_M04", "MFN_M05", "MFN_M06", "MFN_M07", "MFN_M08", "MFN_M09", "MFN_M10", "MFN_M11", "MFN_M12", "MFQ_M01", "MFQ_M01_2", "MFQ_M02_2", "MFQ_M03_2", "MFQ_M04_2", "MFQ_M05_2", "MFQ_M06_2", "MFR_M01", "MFR_M02", "MFR_M03", "MFR_M04", "MFR_M05", "MFR_M06"]
    # e = ["NMD_N02", "NMQ_N01", "NMR_N01", "NUL_K11", "NUL_K13", "NUL_K15", "NUL_K21", "NUL_K22", "NUL_K23", "NUL_K24", "NUL_K25", "NUL_O04", "NUL_O06", "NUL_O08", "NUL_O10", "NUL_O12", "NUL_O14", "NUL_O16", "NUL_O18", "NUL_O20", "NUL_O22", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R04", "NUL_R07", "NUL_R08", "NUL_R09", "NUL_RAR", "NUL_RDR", "NUL_RER", "NUL_RGR", "NUL_ROR", "NUL_V02", "NUL_V03", "NUL_Z74", "NUL_Z82", "NUL_Z86", "NUL_Z88", "NUL_Z90", "OMD_O03", "OMG_O19"]
    #e1 = ["OML_O21", "OMN_O07", "OMP_O09", "OMS_O05", "ORD_O04", "ORF_R04", "ORF_W02", "ORG_O20", "ORL_O22", "ORM_O01", "ORN_O08", "ORP_O10", "ORR_O02", "ORS_O06", "ORU_R01", "ORU_W01", "OSQ_Q06", "OSR_Q06", "OUL_R21", "PEX_P07", "PEX_P08", "PGL_PC6", "PGL_PC7", "PGL_PC8", "PIN_I07", "PMU_B01", "PMU_B02", "PMU_B03", "PMU_B04", "PMU_B05", "PMU_B06", "PPG_PCG", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5"]
    #g = ["PTR_PCF", "QBP_Q11", "QBP_Q13", "QBP_Q15", "QBP_Q21", "QBP_Q22", "QBP_Q23", "QBP_Q24", "QBP_Q25", "QBP_Z73", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z81", "QBP_Z85", "QBP_Z87", "QBP_Z89", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QCK_Q02", "QCN_J01", "QRY_A19", "QRY_P04", "QRY_PC4", "QRY_PC9", "QRY_PCE", "QRY_PCK", "QRY_Q01", "QRY_Q02", "QRY_Q26", "QRY_Q27", "QRY_Q28", "QRY_Q29", "QRY_Q30", "QRY_R02", "QRY_T12", "QRY_W01", "QRY_W02", "QSB_Q16", "QSB_Z83"]
    #h = ["QSX_J02", "QVR_Q17", "RAR_RAR", "RAS_O17", "RCI_I05", "RCL_I06", "RDE_O11", "RDR_RDR", "RDS_O13", "RDY_K15", "RDY_Z80", "RDY_Z98", "REF_I12", "REF_I13", "REF_I14", "REF_I15", "RER_RER", "RGR_RGR", "RGV_O15", "ROR_ROR", "RPA_I08", "RPA_I09", "RPA_I10", "RPA_I11", "RPI_I01", "RPI_I04", "RPL_I02", "RPR_I03", "RQA_I08", "RQA_I09", "RQA_I10", "RQA_I11", "RQC_I05", "RQC_I06", "RQI_I01", "RQI_I02", "RQI_I03", "RQP_I04", "RQQ_Q09", "RRA_O18", "RRD_O14", "RRE_O12", "RRG_O16"]
    #i = ["RRI_I12", "RRI_I13", "RRI_I14", "RRI_I15", "RSP_K11", "RSP_K13", "RSP_K15", "RSP_K21", "RSP_K22", "RSP_K23", "RSP_K24", "RSP_K25", "RSP_Z82", "RSP_Z84", "RSP_Z86", "RSP_Z88", "RSP_Z90", "RTB_K13", "RTB_Knn", "RTB_Q13", "RTB_Z74", "RTB_Z76", "RTB_Z78", "RTB_Z92", "RTB_Z94", "RTB_Z96", "SIU_S12", "SIU_S13", "SIU_S14", "SIU_S15", "SIU_S16", "SIU_S17", "SIU_S18", "SIU_S19", "SIU_S20", "SIU_S21", "SIU_S22", "SIU_S23", "SIU_S24", "SIU_S26", "SPQ_Q08", "SQM_S25", "SQR_S25"]
    #j = ["SRM_S01", "SRM_S02", "SRM_S03", "SRM_S04", "SRM_S05", "SRM_S06", "SRM_S07", "SRM_S08", "SRM_S09", "SRM_S10", "SRM_S11", "SRR_S01", "SRR_S02", "SRR_S03", "SRR_S04", "SRR_S05", "SRR_S06", "SRR_S07", "SRR_S08", "SRR_S09", "SRR_S10", "SRR_S11", "SSR_U04", "SSU_U03", "SUR_P09", "TBR_R08", "TCR_U11", "TCU_U10", "UDM_Q05", "VQQ_Q07", "VXQ_V01", "VXR_V03", "VXU_V04", "VXX_V02"]
    errors = []#["BAR_P10", "BAR_P06", "BHS", "ERP_R09", "FHS", "MFN_M01", "MFN_M03", "MFN_M08", "MFN_M11", "MFR_M01","MFR_M02","MFR_M03","MFR_M04","MFR_M05","MFR_M06","NMR_N01","NUL_K11","NUL_PC5","NUL_PCA","NUL_PCF", "NUL_PCL", "NUL_R09", "ORM_O01","PGL_PC6","PGL_PC7","PGL_PC8","PPG_PCG"]
    er = ["BAR_P10", "BAR_P06", "BHS", "ERP_R09", "FHS", "MFN_M01", "MFN_M03", "MFN_M08", "MFN_M11", "MFR_M01","MFR_M02","MFR_M03","MFR_M04","MFR_M05","MFR_M06","NMR_N01","NUL_K11","NUL_PC5","NUL_PCA","NUL_PCF", "NUL_PCL", "NUL_R09", "ORM_O01","PGL_PC6","PGL_PC7","PGL_PC8","PPG_PCG"]
    #batch 0 (a)
    # a_err =[]
    # er += a_err
    # #batch 1 (b)
    # b_err =[]
    # er += b_err
    #batch 2 (c)
    # c_err =[]
    # er += c_err
    #batch 3 (d) MFQ_M01 - needs requirements;
    # d_err =[]
    # er += d_err
    #batch 4 (e)
    # e_err = []
    # er += e_err
    #batch 5 (e1)
    e1_err = ["ORR_O02", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5"]
    er += e1_err
    #batch 6 (g)
    g_err =["PTR_PCF", "QBP_Q13", "QBP_Q15", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99"]
    er += g_err
    # batch 7 (h)
    h_err = ["QVR_Q17", "RQQ_Q09"]
    # h_err =  ["RSP_K13", "RTB_K13", "RTB_Q13"] #segment RDF missing second field - fixed
    # h_err = ["RSP_K25"] #This issue was already reported earlier: ORG.10 and STF.20 need to be populated ONLY -fixed
    er += h_err
    # batch 8 (i)
    #i_err = ["SQM_S25"] ## batch 8; ARQ.13.1 – the value needs to come from table 335; APR.5.2 – the value needs to come from table 294 - fixed
    i_err = ["RSP_K11", "SPQ_Q08"] # tools side error
    er += i_err
    #batch 9 (j)
    j_err = ["SUR_P09"] # causes intermediate errors - too complex with repeating groups MSH~{~FAC~{~PSH~PDC~}~PSH~{~FAC~PDC~NTE~}~}
    er += j_err

    #ARQ.13.1 – the value needs to come from table 335
    #APR.5.2 – the value needs to come from table 294

    # batch 2 (c) # to complex
    bl = ["CSU_C09","CSU_C10", "CSU_C11","CSU_C12"]
          # "MFQ_M01_2","MFQ_M02_2","MFQ_M03_2","MFQ_M04_2", "MFQ_M05_2","MFQ_M06_2", per Galina, but not in my 2.4 schema
          # "MFR_M01_2", "MFR_M02_2", "MFR_M03_3", "MFR_M04_2", "MFR_M05_2", "MFR_M06_2"
    bl += ["NMD","NMQ", "NMR","OMD_O03"] #black list, Ensemble issues

    # batch 3 (d)
    bl += ["MFN_M02"] # Unescaped separator(s) (|^~&) found in value 'L&I' for elementary data type 'ST' at segment 5:PRA, field 6, repetition 1, component 1, subcomponent 1.
    bl += ["MFQ_M01_2", "MFQ_M02_2", "MFQ_M03_2", "MFQ_M04_2", "MFQ_M05_2", "MFQ_M06_2"] # black listed redundant messages - all use the same message structure
    # batch 4 (e)
    bl += ["NUL_K11", "NUL_K13", "NUL_K15", "NUL_K21", "NUL_K22", "NUL_K23", "NUL_K24", "NUL_K25", "NUL_O04", "NUL_O06", "NUL_O08", "NUL_O10", "NUL_O12", "NUL_O14", "NUL_O16", "NUL_O18", "NUL_O20", "NUL_O22", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R04", "NUL_R07", "NUL_R08", "NUL_R09", "NUL_RAR", "NUL_RDR", "NUL_RER", "NUL_RGR", "NUL_ROR", "NUL_V02", "NUL_V03", "NUL_Z74", "NUL_Z82", "NUL_Z86", "NUL_Z88", "NUL_Z90"] #batch (e)
    # batch 5 (e1)
    bl += ["ORD_O04"] # too complex with subgroups
    bl += ["PMU_B04"] # fixed others PMU_B04 has html encodded chars
    # fixed ["PMU_B01", "PMU_B03", "PMU_B04"] #This was reported to you before – STF. Field 20, repetition 1 is larger than segment structure 2.4:STF
    # batch 6 (g)
    bl += ["QBP_Z73", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z81","QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QSB_Z83"] #per Galina batch 6
    bl += ["QBP_Z85","QBP_Z87","QBP_Z89"] # added 3 more per Galina

    # batch 7 (h)
    bl += ["RDY_Z98", "RDY_Z80"]
    # batch 8 (i)
    bl += ["RSP_Z82", "RSP_Z84", "RSP_Z86", "RSP_Z88", "RSP_Z90", "RTB_Z74", "RTB_Z76", "RTB_Z78", "RTB_Z92", "RTB_Z94", "RTB_Z96"]
    # j batch (9)
    # bl += []


    #also = ['ACK_N02', 'ACK_R01', 'DFT_P11', 'QRY_P04', 'QRY_Q26', 'QRY_Q27', 'QRY_Q28', 'QRY_Q29', 'QRY_Q30', 'RSP_K13', 'RSP_K15', 'RTB_Knn', 'RTB_Q13']

    #a = ['ACK_N02', 'ACK_R01']
    # c = ['DFT_P11'],
    # g = ['QRY_P04', 'QRY_Q26', 'QRY_Q27', 'QRY_Q28', 'QRY_Q29', 'QRY_Q30'],
    # i =['RSP_K13', 'RSP_K15', 'RTB_Knn', 'RTB_Q13']

    all = all_events - er
    all -= bl
    # errors = ["NUL_PCF", "NUL_PCL", "NUL_R09", "ORM_O01","PGL_PC6","PGL_PC7","PGL_PC8","PPG_PCG"]
    # "ERP_R09" :NameError: undefined method `QIP' for class `TypeAwareFieldGenerator'
    # "MFN_M08" :NoMethodError: undefined method `join' for "992":String
    # "MFN_M11" : NoMethodError: undefined method `join' for "934":String
    # lst = errors.last
    # lst_idx = all.index(lst) + 1
    # events = all - errors
    # events = all[lst_idx ..-1]
    # p events
    ver= '2.4.HL7'
    puts "errors size: #{er.size}"
    puts "known errors : #{er}"
    puts "-----"

    puts "black list size: #{bl.size}"
    puts "black list : #{bl}"
    puts "-----"

    puts "messages size: #{all.size}"
    puts "messages : #{all}"
    puts "-----"

    all.each{|e|
      begin
        puts "\n------------------#{e}------------------\n"
        hl7 = MessageFactory.new({std: '2.4', version: ver, event:e, version_store: @@VS, loadfactor: 1}).generate
        puts hl7
        saveMsg(e+'-'+Ez7gen::VERSION, hl7, ver)
      rescue Exception =>z
        errors << e
      end
    }
    p errors
    puts "errors size: #{errors.size}"
    # ["BHS", "ERP_R09", "FHS", "MFN_M01", "MFN_M03", "MFN_M08", "MFN_M11", "MFR_M01", "MFR_M02", "MFR_M03", "MFR_M04", "MFR_M05", "MFR_M06", "NUL_K11", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R09", "ORM_O01", "ORR_O02", "PGL_PC6", "PGL_PC7", "PGL_PC8", "PPG_PCG", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5", "PTR_PCF", "QBP_Q13", "QBP_Q15", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QVR_Q17", "RQQ_Q09", "RSP_K11", "SPQ_Q08"]
    # 51
    # ["BHS", "ERP_R09", "FHS", "MFN_M01", "MFN_M03", "MFN_M08", "MFN_M11", "MFR_M01", "MFR_M02", "MFR_M03", "MFR_M04", "MFR_M05", "MFR_M06", "NUL_K11", "NUL_PC5", "NUL_PCA", "NUL_PCF", "NUL_PCL", "NUL_R09", "ORM_O01", "ORR_O02", "OSR_Q06", "PGL_PC6", "PGL_PC7", "PGL_PC8", "PPG_PCG", "PPG_PCH", "PPG_PCJ", "PPP_PCB", "PPP_PCC", "PPP_PCD", "PPR_PC1", "PPR_PC2", "PPR_PC3", "PPT_PCL", "PPV_PCA", "PRR_PC5", "PTR_PCF", "QBP_Q13", "QBP_Q15", "QBP_Z75", "QBP_Z77", "QBP_Z79", "QBP_Z91", "QBP_Z93", "QBP_Z95", "QBP_Z97", "QBP_Z99", "QVR_Q17", "RQQ_Q09", "RSP_K11", "SPQ_Q08"]
    # 52

  end


end


