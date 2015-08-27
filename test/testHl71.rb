require 'ruby-hl7'
require 'active_record'
# require 'support/testdb' => true


# Method to parse a single file of HL7 messages
# The method dynamically calls an inner method depending on which segment the line of text belongs to.
def parse_file(hl7_file)
  desired_text = ''
  File.open hl7_file, "rb" do |messages|
    while message = messages.gets
      require_relative 'support/testdb'
      msg = HL7::Message.new message.chomp # remove trailing line ending
      seg_name = msg[0].e0
      # puts msg
      # puts msg[0].e0
      if seg_name == 'MSH' then
        $msh09 = msg[0].message_control_id
        # puts $msh09
      end
      if seg_name == 'PID' then
        $pid18 = msg[0].account_number
        $pid03 = msg[0].e3
        $pid02 = msg[0].e2
        $pid04 = msg[0].e4
      end
      #this is where the segment is passed as the method name
      send("do_something_with_#{seg_name}",msg)
      end
    end
  end

#we don't need the BHS method other than to allow it to find a method for it.
#bhs is really the file header, not the hl7 message header (that's the msh)
def do_something_with_BHS(msg)
  # puts "My " << msg[0].e0 << " looks like this: " << msg.to_s
end

#the message header will collect all of the values for that message and keep the $msh09 global variable (which holds the msh id)
def do_something_with_MSH(msg)
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  # require_relative 'support/testdb'
  # load('support/testdb')
  # autoload(:ActiveRecord, "support/testdb.rb")
  msh = Hl7Msh.new
  while m_inc > 0 do
    m_inc = m_inc - 1
    v1 = m_ary[0] + "_" + m_inc.to_s + "="
    v1 = v1.downcase
    msh.send(v1,m_ary[m_inc])
    #puts m_inc
  end
  msh.msh_9_id = $msh09
  msh.save
  # puts "saved!"
end

#the PID is the Patient ID segment.  For this, we need to keep and store the elements of the pid for the rest of the parts of the hl7 (eg- OBR)
def do_something_with_PID(msg)
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  pid = Hl7Pid.new
  while m_inc > 0 do
    m_inc = m_inc - 1
    v1 = m_ary[0] + "_" + m_inc.to_s + "="
    v1 = v1.downcase
    pid.send(v1,m_ary[m_inc])
    #puts m_inc
  end
  pid.msh_9_id = $msh09
  pid.pid18_patacct = $pid18
  pid.pid3_mrn = $pid03
  pid.pid2_DOB = $pid02
  pid.pid4_ssn = $pid04
  pid.save
  # puts "saved!"
end

# the nte must hold onto the message id and the patient id fields to maintain cardinality in the db
# as well, it has to have a sequence number because of the possible many to one records that roll up to that patient.
def do_something_with_NTE(msg)
  nte_nbr = msg[0].e1
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  nte = Hl7Nte.new
  while m_inc > 0 do
    m_inc = m_inc - 1
    v1 = m_ary[0] + "_n_" + m_inc.to_s + "="
    v1 = v1.downcase
    nte.send(v1,m_ary[m_inc])
    #puts m_inc
  end
  nte.msh_9_id = $msh09
  nte.pid18_patacct = $pid18
  nte.pid3_mrn = $pid03
  nte.pid2_DOB = $pid02
  nte.pid4_ssn = $pid04
  nte.nte_n_nbr_set = nte_nbr
  nte.save
  # puts "saved!"
end

# the nte must hold onto the message id and the patient id fields to maintain cardinality in the db
# as well, it has to have a sequence number because of the possible many to one records that roll up to that patient.
def do_something_with_OBX(msg)
  obx_nbr = msg[0].e1
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  obx = Hl7Obx.new
  while m_inc > 0 do
    m_inc = m_inc - 1
    v1 = m_ary[0] + "_n_" + m_inc.to_s + "="
    v1 = v1.downcase
    obx.send(v1,m_ary[m_inc])
    #puts m_inc
  end
  obx.msh_9_id = $msh09
  obx.pid18_patacct = $pid18
  obx.pid3_mrn = $pid03
  obx.pid2_DOB = $pid02
  obx.pid4_ssn = $pid04
  obx.obx_n_nbr_set = obx_nbr
  obx.save
  # puts "saved!"
end

# the nte must hold onto the message id and the patient id fields to maintain cardinality in the db
# as well, it has to have a sequence number because of the possible many to one records that roll up to that patient.
def do_something_with_OBR(msg)
  obr_nbr = msg[0].e1
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  obr = Hl7Obr.new
  while m_inc > 0 do
    m_inc = m_inc - 1
    v1 = m_ary[0] + "_n_" + m_inc.to_s + "="
    v1 = v1.downcase
    obr.send(v1,m_ary[m_inc])
    #puts m_inc
  end
  obr.msh_9_id = $msh09
  obr.pid18_patacct = $pid18
  obr.pid3_mrn = $pid03
  obr.pid2_DOB = $pid02
  obr.pid4_ssn = $pid04
  obr.obr_n_nbr_set = obr_nbr
  obr.save
  # puts "saved!"
end

#pv1 holds additional patient information (almost like an appendix to the PID segment)
# the pv1 must also hold onto the message id and the patient id fields to maintain cardinality in the db
def do_something_with_PV1(msg)
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  pv1 = Hl7Pv1.new
  while m_inc > 0 do
    m_inc = m_inc - 1
    v1 = m_ary[0] + "_" + m_inc.to_s + "="
    v1 = v1.downcase
    pv1.send(v1,m_ary[m_inc])
    #puts m_inc
  end
  pv1.msh_9_id = $msh09
  pv1.pid18_patacct = $pid18
  pv1.pid3_mrn = $pid03
  pv1.pid2_DOB = $pid02
  pv1.pid4_ssn = $pid04
  pv1.save
  # puts "saved!"
end

# the orc must hold onto the message id and the patient id fields to maintain cardinality in the db
def do_something_with_ORC(msg)
  msg_s = msg.to_s
  m_ary = msg_s.split('|')
  m_inc = m_ary.length
  orc = Hl7OrcRe.new
  orc.orc_1 = msg[0].e0
  orc.orc_2 = msg[0].e1
  orc.orc_3 = msg[0].e2
  orc.re_1 = msg[0].e3
  orc.re_2 = msg[0].e4
  orc.msh_9_id = $msh09
  orc.pid18_patacct = $pid18
  orc.pid3_mrn = $pid03
  orc.pid2_DOB = $pid02
  orc.pid4_ssn = $pid04
  orc.save
  # puts "saved!"
end

parse_file('test.hl7')
---------------------------------------------------------------------------

require 'active_record'
require 'activerecord-sqlserver-adapter'

# TODO: remove the ActiveRecord connection from here and change the methods to point to classes without the numeric digit behind it (eg. - Hl7Nte2)
ActiveRecord::Base.establish_connection(
    :adapter => 'sqlserver',
    :host => '@localhost',
    :port => '1433',
    :database => 'hl7'
)

class Hl7Msh < ActiveRecord::Base
  self.table_name = 'HL7_MSH'
  alias_attribute :msh_0, :MSH_0
  alias_attribute :msh_1, :MSH_1
  alias_attribute :msh_2, :MSH_2
  alias_attribute :msh_3, :MSH_3
  alias_attribute :msh_4, :MSH_4
  alias_attribute :msh_5, :MSH_5
  alias_attribute :msh_6, :MSH_6
  alias_attribute :msh_7, :MSH_7
  alias_attribute :msh_8, :MSH_8
  alias_attribute :msh_9, :MSH_9
  alias_attribute :msh_10, :MSH_10
  alias_attribute :msh_11, :MSH_11
  alias_attribute :msh_9_id, :MSH_9_ID

  def self.select_msh_rec
    t = Hl7Msh.arel_table
    where(t[:msh_9_id].not_eq(''))
  end

end



class Hl7Nte < ActiveRecord::Base
  self.table_name = 'HL7_NTE_N'
  alias_attribute :pid18_patacct, :PID18_PATACCT
  alias_attribute :pid3_mrn, :PID3_MRN
  alias_attribute :pid2_DOB, :PID2_DOB
  alias_attribute :pid4_ssn, :PID4_SSN
  alias_attribute :nte_n_0, :NTE_N_0
  alias_attribute :nte_n_1, :NTE_N_1
  alias_attribute :nte_n_2, :NTE_N_2
  alias_attribute :nte_n_3, :NTE_N_3
  alias_attribute :nte_n_nbr_set, :NTE_N_NBR_SET
  alias_attribute :msh_9_id, :MSH_9_ID

end



class Hl7Obr < ActiveRecord::Base
  self.table_name = 'HL7_OBR_N'
  alias_attribute :pid18_patacct, :PID18_PATACCT
  alias_attribute :pid3_mrn, :PID3_MRN
  alias_attribute :pid2_DOB, :PID2_DOB
  alias_attribute :pid4_ssn, :PID4_SSN
  alias_attribute :obr_n_0, :OBR_N_0
  alias_attribute :obr_n_1, :OBR_N_1
  alias_attribute :obr_n_2, :OBR_N_2
  alias_attribute :obr_n_3, :OBR_N_3
  alias_attribute :obr_n_4, :OBR_N_4
  alias_attribute :obr_n_5, :OBR_N_5
  alias_attribute :obr_n_6, :OBR_N_6
  alias_attribute :obr_n_7, :OBR_N_7
  alias_attribute :obr_n_8, :OBR_N_8
  alias_attribute :obr_n_9, :OBR_N_9
  alias_attribute :obr_n_10, :OBR_N_10
  alias_attribute :obr_n_11, :OBR_N_11
  alias_attribute :obr_n_12, :OBR_N_12
  alias_attribute :obr_n_13, :OBR_N_13
  alias_attribute :obr_n_14, :OBR_N_14
  alias_attribute :obr_n_15, :OBR_N_15
  alias_attribute :obr_n_16, :OBR_N_16
  alias_attribute :obr_n_17, :OBR_N_17
  alias_attribute :obr_n_18, :OBR_N_18
  alias_attribute :obr_n_19, :OBR_N_19
  alias_attribute :obr_n_20, :OBR_N_20
  alias_attribute :obr_n_21, :OBR_N_21
  alias_attribute :obr_n_22, :OBR_N_22
  alias_attribute :obr_n_23, :OBR_N_23
  alias_attribute :obr_n_24, :OBR_N_24
  alias_attribute :obr_n_25, :OBR_N_25
  alias_attribute :obr_n_nbr_set, :OBR_N_NBR_SET
  alias_attribute :msh_9_id, :MSH_9_ID

end



class Hl7Obx < ActiveRecord::Base
  self.table_name = 'HL7_OBX_N'
  alias_attribute :pid18_patacct, :PID18_PATACCT
  alias_attribute :pid3_mrn, :PID3_MRN
  alias_attribute :pid2_DOB, :PID2_DOB
  alias_attribute :pid4_ssn, :PID4_SSN
  alias_attribute :obx_n_0, :OBX_N_0
  alias_attribute :obx_n_1, :OBX_N_1
  alias_attribute :obx_n_2, :OBX_N_2
  alias_attribute :obx_n_3, :OBX_N_3
  alias_attribute :obx_n_4, :OBX_N_4
  alias_attribute :obx_n_5, :OBX_N_5
  alias_attribute :obx_n_6, :OBX_N_6
  alias_attribute :obx_n_7, :OBX_N_7
  alias_attribute :obx_n_8, :OBX_N_8
  alias_attribute :obx_n_nbr_set, :OBX_N_NBR_SET
  alias_attribute :msh_9_id, :MSH_9_ID

end

class Hl7OrcRe < ActiveRecord::Base
  self.table_name = 'HL7_ORC_RE'
  alias_attribute :pid18_patacct, :PID18_PATACCT
  alias_attribute :pid3_mrn, :PID3_MRN
  alias_attribute :pid2_DOB, :PID2_DOB
  alias_attribute :pid4_ssn, :PID4_SSN
  alias_attribute :orc_0, :ORC_0
  alias_attribute :orc_1, :ORC_1
  alias_attribute :orc_2, :ORC_2
  alias_attribute :re_1, :RE_1
  alias_attribute :re_2, :RE_2
  alias_attribute :msh_9_id, :MSH_9_ID

end


class Hl7Pid < ActiveRecord::Base
  self.table_name = 'HL7_PID'
  alias_attribute :pid18_patacct, :PID18_PATACCT
  alias_attribute :pid3_mrn, :PID3_MRN
  alias_attribute :pid2_DOB, :PID2_DOB
  alias_attribute :pid4_ssn, :PID4_SSN
  alias_attribute :pid_0, :PID_0
  alias_attribute :pid_1, :PID_1
  alias_attribute :pid_2, :PID_2
  alias_attribute :pid_3, :PID_3
  alias_attribute :pid_4, :PID_4
  alias_attribute :pid_5, :PID_5
  alias_attribute :pid_6, :PID_6
  alias_attribute :pid_7, :PID_7
  alias_attribute :pid_8, :PID_8
  alias_attribute :pid_9, :PID_9
  alias_attribute :pid_10, :PID_10
  alias_attribute :pid_11, :PID_11
  alias_attribute :pid_12, :PID_12
  alias_attribute :pid_13, :PID_13
  alias_attribute :pid_14, :PID_14
  alias_attribute :pid_15, :PID_15
  alias_attribute :pid_16, :PID_16
  alias_attribute :pid_17, :PID_17
  alias_attribute :pid_18, :PID_18
  alias_attribute :pid_19, :PID_19
  alias_attribute :msh_9_id, :MSH_9_ID

end



class Hl7Pv1 < ActiveRecord::Base
  self.table_name = 'HL7_PV1'
  alias_attribute :pid18_patacct, :PID18_PATACCT
  alias_attribute :pid3_mrn, :PID3_MRN
  alias_attribute :pid2_DOB, :PID2_DOB
  alias_attribute :pid4_ssn, :PID4_SSN
  alias_attribute :pv1_0, :PV1_0
  alias_attribute :pv1_1, :PV1_1
  alias_attribute :pv1_2, :PV1_2
  alias_attribute :pv1_3, :PV1_3
  alias_attribute :pv1_4, :PV1_4
  alias_attribute :pv1_5, :PV1_5
  alias_attribute :pv1_6, :PV1_6
  alias_attribute :pv1_7, :PV1_7
  alias_attribute :pv1_8, :PV1_8
  alias_attribute :pv1_9, :PV1_9
  alias_attribute :pv1_10, :PV1_10
  alias_attribute :pv1_11, :PV1_11
  alias_attribute :pv1_12, :PV1_12
  alias_attribute :pv1_13, :PV1_13
  alias_attribute :pv1_14, :PV1_14
  alias_attribute :pv1_15, :PV1_15
  alias_attribute :pv1_16, :PV1_16
  alias_attribute :pv1_17, :PV1_17
  alias_attribute :pv1_18, :PV1_18
  alias_attribute :pv1_19, :PV1_19
  alias_attribute :msh_9_id, :MSH_9_ID

end