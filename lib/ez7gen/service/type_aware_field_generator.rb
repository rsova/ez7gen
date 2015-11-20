require 'yaml'
require_relative '../profile_parser'

class TypeAwareFieldGenerator
  attr_accessor :yml
  # @@UP_TO_3_DGTS = 1000 # up to 3 digits
  @@REQ_LEN_3_DGTS = 3 #up to 3 digits
  @@RANGE_INDICATOR = '...'
  @@HAT = '^' # Component separator, aka hat
  @@SUB ='&' # Subcomponent separator
  # @@MONEY_FORMAT_INDICATORS = ['Money', 'Balance', 'Charge', 'Adjustment', 'Income', 'Amount', 'Payment','Cost']
  @@MONEY_FORMAT_REGEX = /\bMoney\b|\bBalance\b|\bCharge|\bAdjustment\b|\bIncome\b|\bAmount\b|\bPayment\b|\bCost\b|\bPercentage\b/
  @@INITIALS = ('A'..'Z').to_a
  @@GENERAL_TEXT = 'Notes'

  @@random = Random.new

  # constructor
  def initialize(pp)#/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/properties.yml
    @pp = pp
    # dirname =  File.join(File.dirname(File.expand_path(__FILE__)),'../../resources/properties.yml')
    propertiesFile = File.expand_path('../../resources/properties.yml', __FILE__)
    @yml = YAML.load_file propertiesFile
  end

  #Generate HL7 AD (address) data type.
  def AD(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # match cities, states and zips
    sample  = @yml['address.states'].sample
    idx = @yml['address.states'].index(sample) #index of random element

    val=[]
    #street address (ST) (ST)
    val << @yml['address.streetNames'].sample
    #other designation (ST)
    val <<''
    #city (ST)
    val << @yml['address.cities'].at(idx)
    #state or province (ST)
    val << @yml['address.states'].at(idx)
    #zip or postal code (ST)
    val << @yml['address.zips'].at(idx)
    #country (ID)
    val << @yml['address.countries'].at(idx)
    # address type (ID)
    # ot5 her geographic designation (ST)

    val.join(@@HAT)
  end

  # Authorization information
  def AUI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # authorization number (ST)
    ST(map, true)
    # date (DT)
    # source (ST)
  end

  #Charge time
  def CCD(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

      #<when to charge code (ID)>
      ID(map, force=false)
      # <date/time (TS)>
    end

  #Channel calibration parameters
  def CCP(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <channel calibration sensitivity correction (NM)>
    NM(map,true)
    # <channel calibration baseline (NM)>
    # <channel calibration time skew (NM)>
  end

  # Channel definition
  def CD(map, force=false)
  # check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    #<channel identifier (WVI)>
    WVI(map, force=true)
    #<waveform source (WVS)>
    # <channel sensitivity/units (SCU)>
    #<channel calibration parameters (CCP)>
    # <sampling frequency (NM)>
    # <minimum/maximum data values (NR)>
  end

  # Generate HL7 CE (coded element) data type
  def CE(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    #TODO: Refactor this method
    if (map[:description] == 'Role Action Reason' || map[:description] == 'Species Code' || map[:description] == 'Breed Code' || map[:description] == 'Production Class Code')
      return '' #Per requirement, PID.35 – PID.38
    end

    val = []
    # CE ce = (CE) map?.fld
    codes = getCodedMap(map)
    if(Utils.blank?(codes))
      case map[:description]
        when 'Allergen Code/Mnemonic/Description'
          pair = yml['codes.allergens'].to_a.sample(1).to_h.first # randomly pick a pair
          val<<pair.first
          val<<pair.last

        else
          # TODO: only for elements that don't have look up table set the id randomly
          # if codetable is empty
          val << ((Utils.blank?(map[:codetable])) ? ID(map,true) : '')
      end
    else
      #identifier (ST) (ST)
      val<<codes[:value]
      #text (ST)
      val<<codes[:description]
      #name of coding system (IS)
      #alternate identifier (ST) (ST)
      #alternate text (ST)
      #name of alternate coding system (IS)
    end
    return val.join(@@HAT)
  end

  # Coded element with formatted values
  def CF(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map, force))

    # <identifier (ID)>
    ID(map, true)
    # <formatted text (FT)>
    # <name of coding system (IS)>
    # <alternate identifier (ID)>
    # <alternate formatted text (FT)>
    # <name of alternate coding system (IS)>
  end

  #Composite ID with check digit
  def CK(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map, force))
    # <ID number (NM)>
    NM(map,true)
    # <check digit (NM)>
    # <code identifying the check digit scheme employed (ID)>
    # < assigning authority (HD)>
  end

  #Composite
  def CM(map, force=false)
   #check if the field is optional and randomly generate it of skip
   return '' if(!autoGenerate?(map, force))

   val=[]
   # <penalty type (IS)>
    val=IS(map,true)
   # <penalty amount (NM)>
   val<<NM(map,true)
   val.join(@@HAT)
   end

  # CN	Composite ID number and name
  # "<ID number (ST)> ^ <family name (FN)> ^ <given name (ST)> ^ < second and further given names or initials thereof (ST)> ^ <suffix (e.g., JR or III) (ST)> ^ <prefix (e.g. DR) (ST)> ^ <degree (e.g., MD) (IS)> ^ <source table (IS)> ^ <assigning authority(HD)>
  # Replaced by XCN data type as of v 2.3"

  # CNE	Coded with no exceptions
  def CNE(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map, force))

    # <identifier (ST)> ^ <text (ST)>
    ST(map, true)
    # <name of coding system (IS)>
    # <alternate identifier(ST)>
    # <alternate text (ST)>
    # <name of alternate coding system (IS)>
    # <coding system version ID (ST)>
    # alternate coding system version ID (ST)>
    # <original text (ST)>
  end

  # Composite ID number and name (special DT for NDL)
  def CNN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map, force))

    # ID number (ST) (ST)

    # val << ID(map, true)
    # family name (FN), used for ST
    # val << FN(map, true)
    # given name (ST)
    # val << @yml['person.names.first'].sample
    # second and further given names or initials thereof (ST)
    # val << @@INITIALS.to_a.sample
    # < suffix (e.g., JR or III) (ST)> ^ < prefix (e.g., DR) (ST)>
    # < degree (e.g., MD) (IS)> ^ < source table (IS)>
    PN(map, true)

    # < assigning authority namespace ID (IS)>
    # < assigning authority universal ID (ST)>
    # < assigning authority universal ID type (ID)>
    #  val.join(@@SUB)
  end

  def CP(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map, force))

		#price (MO)
    MO(map,true)
		#price type (ID)
		#from value (NM)
		#to value (NM)
		#range units (CE)
		#range type (ID)
  end

  # Composite quantity with units
  def CQ(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val =[]
    # <quantity (NM)>
    val<<NM(map,true)
    # <units (CE)>
    val<<CE(map,true)
    #    val.join(@@HAT)
  end

  #Channel sensitivity/units
  def CSU(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # < channel sensitivity (NM)>
    NM(map,true)
    # < unit of measure identifier (ST)>
    # < unit of measure description (ST)>
    # < unit of measure coding system (IS)>
    # < alternate unit of measure identifier (ST)>
    # < alternate unit of measure description (ST)>
    # < alternate unit of measure coding system (IS)>
  end

  #Coded with exceptions
  def CWE(map, force=false)
  #check if the field is optional and randomly generate it of skip
  return '' if(!autoGenerate?(map,force))
  # <identifier (ST)>
  # <text (ST)> ^ <name of coding system (IS)> ^ <alternate identifier(ST)> ^ <alternate text (ST)> ^ <name of alternate coding system (IS)> ^ <coding system version ID (ST)> ^ alternate coding system version ID (ST)> ^ <original text (ST)>
  end

  #Generate HL7 CX (extended composite ID with check digit) data type.
  def CX(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		#ID (ST)
		ST(update(map, :description,'Number'),true)
		#check digit (ST) (ST)
		#code identifying the check digit scheme employed (ID)
		#assigning authority (HD)
    #identifier type code (ID) (ID)
		#assigning facility (HD)
		#effective date (DT) (DT)
		#expiration date (DT)
  end

  # Daily deductible
  def DDI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    val=[]
    # < delay days (NM)>
    val=''
    # < amount (NM)>
    val<<NM(map,true)
    # < number of days (NM)>
    val.join(@@HAT)
  end

  # Activation date
  def DIN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # date	< date (TS)>
    TS(map,true)
    # <institution name (CE)>
  end

  #Generate HL7 DLD (discharge location) data type. This type consists of the following components=>
  def DLD(map, force=false)
		#check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    val=[]
		#discharge location (ID)
		val<<ID(map, true)
		#effective date (TS)
		val<<TS(map,true)
		val.join(@@HAT)
  end

  #Generate HHL7 DLN (driver's license number) data type
  def DLN(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val=[]
		# DLN dln = (DLN) map.fld
		#Driver´s License Number (ST)
		val << generateLengthBoundId(10) # 10 vs 7 Numeric, as for some states in real life
		#Issuing State, province, country (IS)
		#is(['fld'=>dln.getIssuingStateProvinceCountry(), 'required'=>'R','codetable'=>map.codetable])
		#dln.getIssuingStateProvinceCountry().setValue(allStates.get(Math.abs(random.nextInt()%allStates.size())))
    # val << @yml['address.states'].sample # pick a state
    # val << @yml['address.states'].sample # pick a state
    val << IS({:codetable =>'333'},true) # pick a state
		#expiration date (DT)
		val << DT(update(map,:description,'End'),true)
    val.join(@@HAT)
  end


  # Delta check
  def DLT(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <range (NR)>
    NR(map,true)
    # <numeric threshold (NM)>
    # <change computation (ST)>
    # <length of time-days (NM)>
  end

  #Generates HL7 DR (date/time range) data type.
  def DR(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val=[]
		#range start date/time (TS)
		val<<TS(map,true)
		#range end date/time (TS)
		val<<TS(update(map,:description,'End'),true)
    val.join(@@HAT)
  end

  #Generates an HL7 DT (date) datatype.
  def DT(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

    # #time of an event (TSComponentOne)
    toDateTime(map).strftime('%Y%m%d') #format('YYYYMMdd.SSS')Date.iso8601

  end

  # Day Type and Number
  def DTN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    val=[]
    # <day type (IS)>
    val<<IS(map,true)
    # <number of days (NM)>
    val<<NM(map,true)
    val.join(@@HAT)
  end

  # Generate HL7 EI - entity identifier
  def EI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # entity identifier (ST)
    ST(map, force)
    # namespace ID (IS)
    # universal ID (ST)
    # universal ID type (ID)
  end

  # Encapsulated data
  def ED(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <source application (HD) >
    HD(map, true)
    # <type of data (ID)>
    # <data subtype (ID)>
    # <encoding (ID)>
    # <data (ST)>
  end

  # Entity identifier
  def EI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <entity identifier (ST)>
    ST(map,true)
    # <namespace ID (IS)>
    # <universal ID (ST)>
    # < universal ID type (ID)>
  end

  # Parent order
  def EIP(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <parent’s placer order number (EI)>
    EI(map,true)
    # <parent’s filler order number (EI)>
  end

  # Error segment
  def ELD(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val = []
    # <segment ID (ST)>
    val<<''
    # <sequence (NM)>
    val<<''
    # <field position (NM)>
    val<<''
    # <code identifying error (CE)>
    val<<CE(map,true)
    val.join(@@HAT)
  end

  #Generates HL7 FC (financial class) data type.
  def FC(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

    val = []
		#Financial Class (IS)
		val << IS(map, true)
		#Effective Date (TS) (TS)
		val << TS(map, true)
    val.join(@@HAT)
  end

  #Generates an HL7 FN (familiy name) data type.
  def FN(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		#surname (ST)
    @yml['person.names.last'].sample
		#own surname prefix (ST)
		#own surname (ST)
		#surname prefix from partner/spouse (ST)
		#surname from partner/spouse (ST)
  end

  # Formatted text data.
  # The FT field is of arbitrary length (up to 64k) and may contain formatting commands enclosed in escape characters.
  def FT(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    ID(map, true)
  end


  #Generates HL7 HD (hierarchic designator) data type
  def HD(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		#namespace ID (IS)
    IS(map, true)
		#universal ID (ST)
		#universal ID type (ID)
  end


  # Generate HL7 ID, usually using value from code table
  def ID(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    
    #value only
    #Case when max_len overrides requirements
    len = Utils.safeLen(map[:max_length],@@REQ_LEN_3_DGTS)
    (!Utils.blank?(map[:codetable]))? getCodedValue(map): generateLengthBoundId(len)
  end

  #Generates HL7 IS (namespace id) data type
  def IS(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    #TODO: same as ID?
    ID(map,true)
  end


  #Generates HL7 JCC (job code/class) data type.
  def JCC(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		val=[]
		#job code (IS)
		# is(['fld'=>jcc.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
    val << IS(map, true)
		#job class (IS)
    val << IS(map, true)
    # is(['fld'=>jcc.getComponent(1), 'required'=>'R'])
    val.join(@@HAT)
  end

  # Location with address information (variant 1)
  def LA1(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val =[]
    # <point of care (IS)>
    val<<IS(map,true)
    # <room (IS) >
    val<<IS({:codetable =>'303'},true)
    # <bed (IS)>
    val<<IS({:codetable =>'304'},true)
    # <facility (HD) >
    val<<HD(map,true)
    # <location status (IS)
    val<<''
    # <patient location type (IS)>
    val<<''
    # <building (IS)>
    val<<IS({:codetable =>'307'},true)
    # <floor (IS)>
    # <address(AD)>
    val.join(@@HAT)
  end

  # Location with address information (variant 2)
  def LA2(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    val =[]
    # <point of care (IS)>
    val<<IS(map,true)
    # <room (IS)
    val<<IS({:codetable =>'303'},true)
    # <bed (IS)>
    val<<IS({:codetable =>'304'},true)
    # <facility (HD) >
    val<<HD(map,true)
    # <location status (IS)
    val<<''
    # <patient location type (IS)>
    val<<''
    # <building (IS)>
    val<<IS({:codetable =>'307'},true)
    # <floor (IS)>
    # < street address (ST)>
    # <other designation (ST)>
    # <city (ST)>
    # <state or province (ST)>
    # <zip or postal code (ST)>
    # <country (ID)>
    # <address type (ID)>
    # <other geographic designation (ST)>
    val.join(@@HAT)
  end

  #MA segment
  def MA(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <sample 1 from channel 1 (NM)>
    NM(map,true)
    # <sample 1 from channel 2 (NM)>
    # <sample 1 from channel 3 (NM)>
    # <sample 2 from channel 1 (NM)>
    # <sample 2 from channel 2 (NM)>
    # <sample 2 from channel 3 (NM)>
  end


  #Generates an HL7 MO (money) data type.
  def MO(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    # val = []
		#quantity (NM)Guarantor Household Annual Income
		# val << NM(update(map,:description,'Money'),true)
		#val << NM(map,true)
		NM(map,true)
		#denomination (ID)
    # val << 'USD' # Per request.
    # return val.join(@@SUB)
  end

  # Charge to practice
  def MOC(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <dollar amount (MO)>
    MO(map,true)
    # <charge code (CE)>
  end

  # Money or percentage
  def MOP(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val=[]
    # <money or percentage indicator (IS)>
    val<<IS({:codetable =>'148'},true)
    # <money or percentage quantity (NM)>
    val<<NM({:description =>'Percentage'},true)
    val.join(@@HAT)
  end

  # MSG segment
  def MSG(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val=[]
    # <message type (ID)>
    val<<IS({:codetable =>'76'},true)
    # <trigger event (ID)>
    val<<IS({:codetable =>'3'},true)
    # <message structure (ID)>
    val<<IS({:codetable =>'354'},true)
    val.join(@@HAT)
  end

  #Generates HL7 MSG (Message Type) data type.
  def MSH(map, force=false)
    #Message type set while initializing MSH segment, do nothing.

    #message type (ID)
    #trigger event (ID)
    #message structure (ID)
  end


  # Numeric Array
  def NA(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <value1 (NM)>
    NM(map,true)
    # <value2 (NM)>
    # <value3 (NM)>
    # <value4 (NM)>
  end

  # Observing practitioner
  def NDL(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <name (CNN)>
    CNN(map,true)
    # <start date/time (TS)>
    # <end date/time (TS)>
    # <point of care (IS)>
    # <room (IS)>
    # <bed (IS)>
    # <facility (HD)>
    # <location status (IS)>
    # <person location type (IS)>
    # <building (IS)>
    # <floor (IS)>
  end


  #Generates an HL7 NM (numeric) data type. A NM contains a single String value.
  def NM(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val = 0
    case map[:description]
      when'Guarantor Household Size','Birth Order'
        val = generateLengthBoundId(1)
      when 'Guarantor Household Annual Income'
        val = '%.2f' % generateLengthBoundId(5)
      when @@MONEY_FORMAT_REGEX
        val = '%.2f' % ID(map,true)
      else
        val = ID(map,true) # general rule for a number
        if (map[:datatype] == 'CP' || map[:datatype] == 'MO') # money
          val = '%.2f' % val
        end
     end
    # #money
    # if (!Utils.blank?(map[:description]) && @@MONEY_FORMAT_INDICATORS.index{|it| map[:description].include?(it)}) #check for specific numeric for money
			# val = '%.2f' % @@random.rand(@@UP_TO_3_DGTS) #under $1,000
    # else #quantity (NM)
    #   val =  @@random.rand(@@UP_TO_3_DGTS).to_s #under 20
    # end
    return val
  end


  #Numeric Range
  def NR(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val=[]
    # Low Value (NM)
    val=NM(map,true)
    # High Value (NM)
    val<<''
    val.join(@@SUB)
  end

  #Generates an HL7 OCD (occurence) data type.
  #The code and associated date defining a significant event relating to a bill that may affect payer processing
  def OCD(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val = []
		#occurrence code (IS)
    val << IS(map, true)
		# is(['fld'=>ocd.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
		#occurrence date (DT)
		#dt(['fld'=>ocd.getComponent(1), 'required'=>'R'])
    val << DT(map, true)
    val.join(@@HAT)
  end

  # Order sequence
  def OSD(map, force=false)
    #check if the field is optional and randomly generate it of skip
  return '' if(!autoGenerate?(map,force))

    # <sequence/results flag (ID)>
    ID(map, force)
    # <placer order number: entity identifier (ST)>
    # <placer order number: namespace ID (IS)>
    # <filler order number: entity identifier (ST)>
    # <filler order number: namespace ID (IS)>
    # <sequence condition value (ST)>
    # <maximum number of repeats (NM)>
    # <placer order number: universal ID (ST)>
    # <placer order number; universal ID type (ID)>
    # <filler order number: universal ID (ST)>
    # <filler order number: universal ID type (ID)>
  end

  #Generate an HL7 OSP (occurence span) data type.
  def OSP(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val = []

		#occurrence span code (CE)
    val << CE(map, true)
		#occurrence span start date (DT)
    val << DT(map,true)
		#occurrence span stop date (DT)
    val << DT(update(map,:description,'End'), true)
    val.join(@@HAT)
  end

  # Pre-certification required
  def PCF(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <pre-certification patient type (IS)>
    val<<IS({:codetable =>'150'},true)
    # <pre-certification required>
    # <pre-certification window>
  end

  # Person identifier
  def PI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <ID number (ST)>
    ST(map,true)
    # <type of ID number>
    # <other qualifying info>
  end

  # Privileges
  def PIP(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <privilege (CE)>
    IS(map,true)
    # <privilege class (CE)>
    # <expiration date (DT)>
    # <activation date (DT)>
    # <facility (EI)>
  end


  #Generate an HL7 PL (person location) data type.
  def PL(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val = []
		#point of care (IS)
    val<<IS({:codetable =>'302'},true)
		#room (IS)
    val<<IS({:codetable =>'303'},true)
		#bed (IS)
    val<<IS({:codetable =>'304'},true)
		#facility (HD) (HD)
		val << HD({:codetable =>'300'}, true)
		#location status (IS)
    val << ''
		#person location type (IS)
    val << ''
		#building (IS)
    val<<IS({:codetable =>'307'},true)
		#floor (IS)
		#Location description (ST)
    val.join(@@HAT)
  end

  # Practitioner ID Numbers
  def PLN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <ID number (ST)>
    ST(map,true)
    # <type of ID number (IS)>
    # <state/other qualifying info (ST)>
    # <expiration date (DT)>
  end


  # Person name
  def PN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val=[]
    # family name (FN)
    val << FN(map, true)
    # given name (ST)
    val << @yml['person.names.first'].sample
    # second and further given names or initials thereof (ST)
    val << @@INITIALS.to_a.sample
    # suffix (e.g., JR or III) (ST)
    # prefix (e.g., DR) (ST)
    # degree (e.g., MD) (IS)
    val.join(@@HAT)
  end

  # Performing person time stamp
  def PPN(map, force=false)
    # check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    val = []
    # <ID number (ST)>
    val << ST(map,true)

    # PN will work for the subset of fields used below
    val << PN(map,true)
    # <family name (FN)>
    # <given name (ST)>
    # <second and further given names or initials thereof (ST)>
    # <suffix (e.g., JR or III) (ST)>
    # <prefix (e.g., DR) (ST)>
    # <degree (e.g., MD) (IS)>
    # <source table (IS)>
    # <assigning authority (HD)>
    # <name type code(ID)>
    # <identifier check digit (ST)>
    # <code identifying the check digit scheme employed (ID )>
    # <identifier type code (IS)>
    # <assigning facility (HD)>
    # < date/time action performed (TS)>
    # <name representation code (ID)>
    # <name context (CE)>
    # <name validity range (DR)>
    # <name assembly order (ID)>

    val.join(@@HAT)
  end

  # Parent result link
  def PRL(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <OBX-3-observation identifier of parent result (CE)>
    CE(map,true)
    # <OBX-4-sub-ID of parent result(ST)>
    # <part of OBX-5 observation result from parent (TX)see discussion>
  end

  #Generate HL7 S PT (processing type) data type.
  def PT(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		#map.maxlen
		# PT pt = (PT) map.fld
		# Map mp = map.clone()
		# mp.fld = pt.getComponent(0)
		# mp.required = 'R'
		ID(map, true)
		#processing ID (ID)
		#processing mode (ID)
  end

  # Processing type
  def PTA(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <processing ID (ID)>
    ID(map, true)
    # <processing mode (ID)>
    # <processing ID (ID)>
  end

  # Query input parameter list
  def OIP(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <segment field name (ST) >
    # <value1 (ST) & value2 (ST) & value3 (ST) ...>
    #Example: |@PID.5.1^EVANS|
    #TBD
    ''
  end

  # QSC	Query selection criteria
  def QSC(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <segment field name(ST)>
    # <relational operator (ID)>
    # <value (ST)> <relational conjunction (ID)>
    # Example: |@PID.5.1^EQ^EVANS|"
    #TBD
    ''
  end

  # RCD	Row column definition
  def RCD(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <segment field name (ST)>
    # <HL7 data type (ID)>
    # <maximum column width (NM)>
    # Example: |@PID.5.1^ST^20|"
    #TBD
    ''
  end

  # Reference range
  def RFR(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <numeric range (NR)>
    NR(map, true)
    # <administrative sex (IS)
    # <age range (NR)>
    # <gestational range (NR)>
    # <species (TX)>
    # <race/subspecies (ST)>
    # <conditions (TX)>
  end

  # Repeat interval
  def RI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <repeat pattern (IS)>
    IS(map,true)
    # <explicit time interval (ST)>
  end

  # Room coverage
  def RMC(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <room type> (IS)
    IS(map,true)
    # <amount type>
    # <coverage amount>
  end

  # Reference pointer
  def PR(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <pointer (ST) >
    ST(map,true)
    # < application ID (HD)>
    # <type of data (ID)>
    # <subtype (ID)>
  end

  # Street address
  #  Appears ONLY in the XAD data type.
  # TODO: Future refactoring, handled in XAD.
  # def SAD(map, force=false)
  #   #check if the field is optional and randomly generate it of skip
  #   return '' if(!autoGenerate?(map,force))
  #
  #   # <street or mailing address (ST)>
  #   # <street name (ST)>
  #   # <dwelling number (ST)>
  # end

  # SCV	Scheduling class value pair
  def SCV(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    val = []
    # <parameter class (IS)>
    val<<''
    # <parameter value (ST)>
    val<<ST(map,true)
    val.join(@@HAT)
  end

  #Generate HL7 SI (sequence ID) data type. A SI contains a single String value.
  def SI(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		#SI pt = (SI) map.fld
		#pt.setValue(generateLengthBoundId((map.max_length)?map.max_length.toInteger():1))
    len = (!Utils.blank?(map[:max_length]))?map[:max_length].to_i : 1
    generateLengthBoundId(len)
  end

  # Structured numeric
  def SN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return ''  if(!autoGenerate?(map,force))
    val = []
    # <comparator (ST)>
    val << ''
    # <num1 (NM)>
    val << NM(map,true)
    # <separator/suffix (ST)>
    # <num2 (NM)>
    val.join(@@HAT)
  end

  # Specialty
  def SPD(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <specialty name (ST)>
    ST(map,true)
    # <governing board (ST)>
    # <eligible or certified (ID)>
    # <date of certification (DT)>
  end

  # Specimen source
  def SPS(map, force=false)
    #check if the field is optional and randomly generate it of skip
  return '' if(!autoGenerate?(map,force))

    #<specimen source name or code (CE)>
    CE(map,true)
    # <additives (TX)>
    # <freetext (TX)>
    # <body site (CE)>
    # <site modifier (CE)>
    # <collection modifier method code (CE)>
    # <specimen role (CE)>
  end

  #Sort order
  def SRT(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <sort-by field (ST)>
    # <sequencing (ID)>
    ID(map,true)
  end

  #Generate HL7 ST (string data) data type. A ST contains a single String value.
  def ST(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # TODO add provider type ln 840 ROL
    case map[:description]
      when 'Guarantor SSN','Insured’s Social Security Number','Medicare health ins Card Number','Military ID Number', 'Contact Person Social Security Number'
        generateLengthBoundId(9)
      when 'Allergy Reaction Code'
        # yml['allergens.yn'].sample()
        yml['codes.allergens'].keys.sample()
      when 'Strain'
        #PID.35 – PID.38 should be always blank, as they deal with animals, not humans.
      when 'AGENT ORANGE EXPOSURE LOCATION'
        #ZEL.29 should be 1 digit integer.
        generateLengthBoundId(1)
      else
        #Case when max_len overrides requirements
        len = Utils.safeLen(map[:max_length],@@REQ_LEN_3_DGTS)
        (!Utils.blank?(map[:codetable]))? getCodedValue(map): generateLengthBoundId(len)
    end

  end

  # An Elementary Data Type  Format: HH[MM[SS[.S[S[S[S]]]]]][+/-ZZZZ]
  # EX: 160140.761
  def TM(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    toDateTime(map).strftime('%H%M%S.%L')
  end

  #Generate an HL7 TN (telephone number) data type. A TN contains a single String value.
  def TN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # TN tn = (TN) map.fld
    # tn.setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
    @yml['address.phones'].sample # pick a phone
  end

  # Timing quantity
  def TQ(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <quantity (CQ)>
    CQ(map,true)
    # <interval (RI)>
    # < duration (ST)>
    # <start date/time (TS)>
    # <end date/time (TS)>
    # <priority (ST)>
    # <condition (ST)>
    # <text (TX)>
    # <conjunction component (ID)>
    # <order sequencing (OSD)>
    # <occurrence duration (CE)>
    # <total occurrences (NM)>
  end

  #Generate HL7 TS (time stamp), within number of weeks in the future or past
  def TS(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

    #time of an event (TSComponentOne)
    toDateTime(map).strftime('%Y%m%d%H%M%S.%L') #format('YYYYMMDDHHSS.SSS')Date.iso8601
  end

  #Generate HL7 TX (text data) data type. A TX contains a single String value.
  def TX(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # @@GENERAL_TEXT
    ID(map,true)
  end

  #Generate an HL7 UVC (Value code and amount) data type.
  def UVC(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))
    val =[]
		# UVC uvc = ((UVC)map.fld)
		#value code (IS)
    val << IS(map, true)
		# is(['fld'=>uvc.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
		#value amount (NM)
		# nm(['fld'=>uvc.getComponent(1), 'required'=>'R'])
    val << NM(map,true)
    val.join(@@HAT)
  end

  # Visiting hours
  def VH(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    val =[]
    # <start day range (ID)>
    val << ID(map,true)
    # <end day range (ID)>
    val << ID(map,true)
    # <start hour range (TM)>
    # <end hour range (TM)>
    val.join(@@HAT)
  end

  #Generate an HL7 VID (version identifier) data type.
  def VID(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		# VID vid = ((VID)map.fld)
    #version ID (ID)
    ID(map, true)
		#id(['fld'=>vid.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])

#		internationalization code (CE)
#		international version ID (CE)
  end

  # Value qualifier
  def VR(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))
    # <first data code value (ST)>
    ST(map,true)
    # <Last data code value (ST)>
  end

  #Channel identifier
  def WVI(map, force=true)
    #check if the field is optional and randomly generate it of skip
    return '' if(!autoGenerate?(map,force))

    # <channel number (NM)>
    NM(map, true)
    # <channel name (ST)>
  end


  # def WVS(map, force=false)
  #   #check if the field is optional and randomly generate it of skip
  #   return '' if(!autoGenerate?(map,force))
  # end

  #Generate HL7 XAD (extended address)
  def XAD(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

    # same as address AD
    AD(map,true)
		#street address (SAD) (SAD)
		#other designation (ST)
		#city (ST)
    #state or province (ST)
    #zip or postal code (ST)
    #country (ID)
		#address type (ID)
		#other geographic designation (ST)
		#county/parish code (IS)
		#census tract (IS)
		#address representation code (ID)
		#address validity range (DR)
  end

  # Generate HL7 XCN (extended composite ID number and name for persons)
  def XCN(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

    val=[]
		# XCN xcn = (XCN) map.fld
		# ID number (ST) (ST)
    val << ID(map, true)
		# xcn.getIDNumber().setValue(Math.abs(random.nextInt() % 300).toString())

    val << PN(map, true)
		# family name (FN)
    # val << FN(map, true)
		# given name (ST)
    # val << @yml['person.names.first'].sample
    # second and further given names or initials thereof (ST)
    # val << @@INITIALS.to_a.sample
		# suffix (e.g., JR or III) (ST)
		# prefix (e.g., DR) (ST)
		# degree (e.g., MD) (IS)

		# source table (IS)
		# assigning authority (HD)
		# name type code (ID)
		# identifier check digit (ST)
		# code identifying the check digit scheme employed (ID)
		# identifier type code (IS) (IS)
		# assigning facility (HD)
		# Name Representation code (ID)
		# name context (CE)
		# name validity range (DR)
		# name assembly order (ID)
    val.join(@@HAT)
  end

  #Generate an HL7 XON (extended composite name and identification number for organizations) data type.
  def XON(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		# XON xtn = (XON) map.fld
    val=[]
		#organization name (ST)
    val << ST(map, true)
		# st(['fld'=>xtn.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
		#organization name type code (IS)
    val << ''
		#ID number (NM) (NM)
    val << NM(map, true)
		#nm(['fld'=>xtn.getComponent(2), 'required'=>'R'])
		#check digit (NM) (ST)
		#code identifying the check digit scheme employed (ID)
		#assigning authority (HD)
		#identifier type code (IS) (IS)
		#assigning facility ID (HD)
		#Name Representation code (ID)
    val.join(@@HAT)
  end

  #Generate an HL7 XPN (extended person name) data type. This type consists of the following components=>
  def XPN(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

    # val=[]
		#family name (FN)
    # val << FN(map, true)
		# fn(['fld'=> xpn.getComponent(0),'required'=>'R'])
		#given name (ST)
    # val << @yml['person.names.first'].sample
    #xpn.givenName.setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())));
    #xpn.getComponent(1).setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())))
    #second and further given names or initials thereof (ST)
    # val << @@INITIALS.to_a.sample
    #xpn.secondAndFurtherGivenNamesOrInitialsThereof.setValue('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.getAt(Math.abs(random.nextInt()%26)))
		#suffix (e.g., JR or III) (ST)
		#prefix (e.g., DR) (ST)
		#degree (e.g., MD) (IS)
    PN(map,true)

		#name type code (ID)
    # val.join(@@HAT)

  end

  #Generate HL7 XTN (extended telecommunication number)
  def XTN(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return '' if(!autoGenerate?(map,force))

		#[(999)] 999-9999 [X99999][C any text] (TN)
		TN(map, true)
    #xtn.get9999999X99999CAnyText().setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
    # telecommunication use code (ID)
    # telecommunication equipment type (ID) (ID)
    # Email address (ST)
    # Country Code (NM)
    # Area/city code (NM)
    # Phone number (NM)
    # Extension (NM)
    # any text (ST)
  end

  # def xx(map, force=false)
  #   #check if the field is optional and randomly generate it of skip
  #   return '' if(!autoGenerate?(map,force))
  # end

  # End of Data Types #

  # Value of coded table returned as as single value
  def getCodedValue(attributes)
  codes = @pp.getCodeTable(attributes[:codetable])
    # puts codes
    #Apply rules to find a value and description
    map = applyRules(codes, attributes)
    #Return value only
    return map[:value]
  end

  # Values and Description from code table returned as a pair.
  def getCodedMap(attributes)
  codes = @pp.getCodeTable(attributes[:codetable])
    # puts codes
    #Apply rules to find a value and description
    #Returns map with code and description
    applyRules(codes, attributes)
  end

  # Handle range values specified by '...' sequence, including empty range
  #TODO refactor candidate
  def applyRules(codes, attributes)
    #safety check, no codes returns an empty map
  return {} if Utils.blank?(codes)

    #index of random element
    idx = Utils.sampleIdx(codes.size)
    code = codes[idx][:value]
    description = codes[idx][:description]

    if (code.include?(@@RANGE_INDICATOR))
      code = handleRanges(code)
    end

    if (code.size > (maxlen = (attributes[:max_length]) ? attributes[:max_length].to_i : code.size))
      #remove all codes wich values violate
    #codes.select! {|it| it[:value].size <= maxlen }
      code, description = handleLength(codes, maxlen)
    end

    # got to have code, get an id, most basic - TODO: verify this.
    # if(Utils.blank?(code))
    #   code, description = ID({},true), ''
    # end
    # return code, description

    # puts code + ', ' + description
    return {:value => code, :description => description}
  end

  def handleLength(codes, maxlen)
  idx = codes.find_index { |it| it[:value].size <= maxlen }

    if (!idx)
      code, description = '', ''
    else
      # puts codes
      code = codes[idx][:value]
      description = codes[idx][:description]
    end
    return code, description
  end

  def handleRanges(code)
    # if (code.include?(@@RANGE_INDICATOR))
  ends = code.delete(' ').split('...').map { |it| it }
      if (ends.empty?) # This is indication that codetable does not have any values
        code = ''
      else #Handle range values, build range and pick random value
        #TODO: need to handle '2 ...' also
        range = ends.first..ends.last
        code = range.to_a.sample
      end
      return code
  end

  # Returns randomly generated Id of required length, of single digit id
  def generateLengthBoundId(maxlen, str=@@random.rand(100000000).to_s)
  idx = maxlen
    if(maxlen > str.size)
      str = str.ljust(maxlen,'0')
      idx = str.size
    end
    #safe fail
    #this handles case when maxlen is less then 1
    idx = [0,idx-1].max
    return str[0..idx]
  end


  # # Returns randomly generated Id of required length, of single digit id
  # def generateLengthBoundId1(map, str=@@random.rand(100000000).to_s)
  #   (!Utils.blank?(map[:codetable]))? getCodedValue(map): @@random.rand(@@UP_TO_3_DGTS).to_s
  #
  #   map[:maxlen]
  # end

  # If field are X,W,B (Not Supported, Withdrawn Fields or Backward Compatible)  returns false.
  # Conditional (C) ?
  # For Optional field (O) makes random choice
  # R - Required returns true
  # def isAutogenerate(map, force=false)
  def autoGenerate?(map, force=false)
    # return true
    return true if(force)  #forced generation, ignore mappings

    #look up in the mapping
    case map[:required]
      when 'X','W','B' then false;
      when 'R' then true;
      when 'O' then [true,false].sample();
      else  false ;
    end
    # if(['X','W','B'].include?(map[:required]))then return false end
    # if(map[:required] =='R') then return true end
    # if(map[:required] == 'O') then return true end #random boolean
  end

  # @return DateTime generated with consideration of description string for dates in the future
  def toDateTime(map)
    #for Time Stamp one way to figure out if event is in the future of in the past to look for key words in description
    isFutureEvent = !Utils.blank?(map[:description])&& map[:description].include?('End') #so 'Role End Date/Time'
    seed = 365 #seed bounds duration of time to a year
    days = @@random.rand(seed)

    if(map[:description]=='Date/Time Of Birth')
      isFutureEvent = false
      years = rand(30..50)
      days = days + 365*years # make a person 30 years old
    end

    (isFutureEvent) ? DateTime.now().next_day(days) : DateTime.now().prev_day(days)
  end

  # convention method to modify REXML::Attributes value
  def update(map, key, value)
    map[key.to_sym]=value
    return map
  end

 end