require 'yaml'
require_relative '../profile_parser'

class TypeAwareFieldGenerator
  attr_accessor :yml

  @@RANGE_INDICATOR = '...'
  @@HAT = '^' # Component separator, aka hat
  @@MONEY_FORMAT_INDICATORS = ['Money', 'Balance', 'Charge', 'Adjustment', 'Income', 'Amount', 'Payment','Cost']

  @@random = Random.new

  # constructor
  def initialize(pp)#/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/properties.yml
    @pp = pp
    # dirname =  File.join(File.dirname(File.expand_path(__FILE__)),'../../resources/properties.yml')
    propertiesFile = File.expand_path('../../resources/properties.yml', __FILE__)
    @yml = YAML.load_file propertiesFile
  end

  # Generate HL7 CE (coded element) data type
  def CE(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return if(!autoGenerate?(map,force))
    val = []
    # CE ce = (CE) map?.fld
    #if(map.codetable != null){
    codes = getCodedMap(map)
    if(Utils.blank?(codes))
      #ce.getIdentifier().setValue(Math.abs(random.nextInt() % 200).toString())
      id = @@random.rand(200)
      val << id
    else
      #identifier (ST) (ST)
      val<<codes['value']
      #text (ST)
      val<<codes['description']
      #name of coding system (IS)
      #alternate identifier (ST) (ST)
      #alternate text (ST)
      #name of alternate coding system (IS)
    end
    return val.join(@@HAT)
  end

  #Generate HL7 CP (composite price) data type.
  def CP(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map, force))
    val = []

		#price (MO)
    MO(map,true)
		#price type (ID)
		#from value (NM)
		#to value (NM)
		#range units (CE)
		#range type (ID)
  end

  #Generate HL7 CX (extended composite ID with check digit) data type.
  def CX(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

		#ID (ST)
		ST(map.update({ 'description'=>'Number'}),true)
		#check digit (ST) (ST)
		#code identifying the check digit scheme employed (ID)
		#assigning authority (HD)
    #identifier type code (ID) (ID)
		#assigning facility (HD)
		#effective date (DT) (DT)
		#expiration date (DT)
  end


  #Generate HL7 DLD (discharge location) data type. This type consists of the following components=>
  def DLD(map, force=false)
		#check if the field is optional and randomly generate it of skip
    return if(!autoGenerate?(map,force))

		 #do both or
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
		return if(!autoGenerate?(map,force))
    val=[]
		# DLN dln = (DLN) map.fld
		#Driver´s License Number (ST)
		val << generateLengthBoundId(7) # 7 Numeric, as for some states in real life
		#Issuing State, province, country (IS)
		#is(['fld'=>dln.getIssuingStateProvinceCountry(), 'required'=>'R','codetable'=>map.codetable])
		#dln.getIssuingStateProvinceCountry().setValue(allStates.get(Math.abs(random.nextInt()%allStates.size())))
    val << @yml['address.states'].sample # pick a state
		#expiration date (DT)
		val << DT(map.update({'description' => 'End'}),true)
    val.join(@@HAT)
  end

  #Generates HL7 DR (date/time range) data type.
  def DR(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))
    val=[]
		#range start date/time (TS)
		val<<TS(map,true)
		#range end date/time (TS)
		val<<TS(map.update({'description'=>'End'}),true)
    val.join(@@HAT)
  end

  #Generates an HL7 DT (date) datatype.
  def DT(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

    # #time of an event (TSComponentOne)
    toDateTime(map).strftime('%Y%m%d') #format('YYYYMMdd.SSS')Date.iso8601

  end

  # Generate HL7 EI - entity identifier
  def EI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return if(!autoGenerate?(map,force))

    # entity identifier (ST)
    ST(map, force)
    # namespace ID (IS)
    # universal ID (ST)
    # universal ID type (ID)
  end

  # Generate HL7 ID, usually using value from code table
  def ID(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))
    #value only
		(!Utils.blank?(map['codetable']))? getCodedValue(map): @@random.rand(200).to_s
  end

  #Generates HL7 IS (namespace id) data type
  def IS(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

		#String val = (map.codetable != null)? getCodedValue(pp, map)=> Math.abs(random.nextInt() % 200).toString()
    (!Utils.blank?(map['codetable']))? getCodedValue(map): @@random.rand(200).to_s
		#((IS) map.fld).setValue(val)
  end

  #Generates HL7 FC (financial class) data type.
  def FC(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

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
		return if(!autoGenerate?(map,force))


		#surname (ST)
    @yml['person.names.last'].sample
		#own surname prefix (ST)
		#own surname (ST)
		#surname prefix from partner/spouse (ST)
		#surname from partner/spouse (ST)
  end

  #Generates HL7 HD (hierarchic designator) data type
  def HD(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

		#namespace ID (IS)
    IS(map, true)
		#universal ID (ST)
		#universal ID type (ID)
  end

  #Generates HL7 JCC (job code/class) data type.
  def JSS(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

		val=[]
		#job code (IS)
		# is(['fld'=>jcc.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
    val << IS(map, true)
		#job class (IS)
    val << IS(map, true)
    # is(['fld'=>jcc.getComponent(1), 'required'=>'R'])
    val.join(@@HAT)
  end

  #Generates HL7 MSG (Message Type) data type.
  def MSH(map, force=false)
# 		#message type (ID)
# 		#trigger event (ID)
# 		#message structure (ID)

# 		#Message type set while initializing MSH segment, do nothing.
# 		return
  end

  #Generates an HL7 MO (money) data type.
  def MO(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))
    val = []
		#quantity (NM)
		val << NM(map.update({'description' =>'Money'}),true)
		#denomination (ID)
		val << 'USD'
    return val.join(@@HAT)
  end

  #Generates an HL7 NM (numeric) data type. A NM contains a single String value.
  def NM(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

		#money
		if (@@MONEY_FORMAT_INDICATORS.index{|it| map['description'].include?(it)}) #check for specific numeric for money
			 '%.2f' % @@random.rand(1000) #under $1,000
		else #quantity (NM)
       @@random.rand(20).to_s #under 20
    end
  end

  #Generates an HL7 OCD (occurence) data type.
  #The code and associated date defining a significant event relating to a bill that may affect payer processing
  def OCD(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))
    val = []
		#occurrence code (IS)
    val << IS(map, true)
		# is(['fld'=>ocd.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
		#occurrence date (DT)
		#dt(['fld'=>ocd.getComponent(1), 'required'=>'R'])
    val << DT(map, true)
    val.join(@@HAT)
  end

  #Generate an HL7 OSP (occurence span) data type.
  def OSP(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))
    val = []

		#occurrence span code (CE)
    val << CE(map, true)
		#occurrence span start date (DT)
    val << DT(map,true)
		#occurrence span stop date (DT)
    val << DT(map.update({'description'=>'End'}), true)
    val.join(@@HAT)
  end

  #Generate an HL7 PL (person location) data type.
  def PL(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))
    val = []
		#point of care (IS)
		val << IS(map, true)
		#room (IS)
		val << IS(map, true)
		#bed (IS)
		val << IS(map, true)
		#facility (HD) (HD)
		val << HD(map, true)
		#location status (IS)
    val << ''
		#person location type (IS)
    val << ''
		#building (IS)
		IS(map, true)
		#floor (IS)
		#Location description (ST)
    val.join(@@HAT)
  end

  #Generate HL7 S PT (processing type) data type.
  def pt(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		#map.maxlen
# 		PT pt = (PT) map.fld
# 		Map mp = map.clone()
# 		mp.fld = pt.getComponent(0)
# 		mp.required = 'R'
# 		id(mp)
# 		#processing ID (ID)
# 		#processing mode (ID)
  end

  #Generate HL7 SI (sequence ID) data type. A SI contains a single String value.
  def si(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		SI pt = (SI) map.fld
# 		pt.setValue(generateLengthBoundId((map.max_length)?map.max_length.toInteger()=>1))
  end

  #Generate HL7 ST (string data) data type. A ST contains a single String value.
  def ST(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return if(!autoGenerate?(map,force))

    if(map['description'].include?('SSN'))
      generateLengthBoundId(9)
    else
      len = (map['max_length']!=nil) ? map['max_length'].to_i : 1
      #val = generateLengthBoundId((len>5)?5=>len) # numeric id up to 5 TODO=> string ids?
      @@random.rand(10000).to_s
    end

    # #			else if(map.max_length < 4 || val.contains('Id')|| val.contains('Days')|| val.contains('Code') || val.contains('Number') ){
    # #				val = (Math.abs(random.nextInt()%100))# up to 3 spaces
    # #			}else{#use description
    # #				#if description does not fit use number
    # #				val = (val.length() > map.max_length.toInteger())?(Math.abs(random.nextInt()%100))=>val
    # 			}

  end

  #Generate HL7 TS (time stamp), within number of weeks in the future or past
  def TS(map, force=false)
		#check if the field is optional and randomly generate it of skip
		return if(!autoGenerate?(map,force))

    #time of an event (TSComponentOne)
    toDateTime(map).strftime('%Y%m%d%H%M%S.%L') #format('YYYYMMDDHHSS.SSS')Date.iso8601
  end

  #Generate an HL7 TN (telephone number) data type. A TN contains a single String value.
  def tn(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		TN tn = (TN) map.fld
# 		tn.setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
  end

  #Generate an HL7 UVC (Value code and amount) data type.
  def uvc(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		UVC uvc = ((UVC)map.fld)
# 		#value code (IS)
# 		is(['fld'=>uvc.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
# 		#value amount (NM)
# 		nm(['fld'=>uvc.getComponent(1), 'required'=>'R'])
  end

  #Generate an HL7 VID (version identifier) data type.
  def vid(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		VID vid = ((VID)map.fld)
# #		version ID (ID)
# 		id(['fld'=>vid.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])

# #		internationalization code (CE)
# #		international version ID (CE)

  end

  #Generate HL7 XAD (extended address)
  def xad(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		XAD xad = (XAD) map.fld
# 		int idx = Math.abs(random.nextInt()%streetNames.size())
# 		#street address (SAD) (SAD)
# 		xad.getStreetAddress().getStreetName().setValue(streetNames.getAt(idx))
# 		#other designation (ST)
# 		#city (ST)
# 		xad.getCity().setValue(cities.getAt(idx))
# 		#state or province (ST)
# 		xad.getStateOrProvince().setValue(states.getAt(idx))
# 		#zip or postal code (ST)
# 		xad.getZipOrPostalCode().setValue(zips.getAt(idx))
# 		#country (ID)
# 		xad.getCountry().setValue(countries.getAt(idx))
# 		#address type (ID)
# 		#other geographic designation (ST)
# 		#county/parish code (IS)
# 		#census tract (IS)
# 		#address representation code (ID)
# 		#address validity range (DR)
  end

  # Generate HL7 XCN (extended composite ID number and name for persons)
  def xcn(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		XCN xcn = (XCN) map.fld
# 		# ID number (ST) (ST)
# 		xcn.getIDNumber().setValue(Math.abs(random.nextInt() % 300).toString())
# 		# family name (FN)
# 		fn(['fld'=> xcn.getComponent(1),'required'=>'R'])
# 		#xcn.familyName.surname.value = lastNames.getAt(Math.abs(random.nextInt()%lastNames.size()));
# 		# given name (ST)
# 		#xcn.givenName.value = firstNames.getAt(Math.abs(random.nextInt()%firstNames.size()));
# 		xcn.getComponent(2).setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())))
# 		# second and further given names or initials thereof (ST)
# 		#xcn.secondAndFurtherGivenNamesOrInitialsThereof.value ='J'
# 		xcn.getComponent(3).setValue('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.getAt(Math.abs(random.nextInt()%26)))
# 		# suffix (e.g., JR or III) (ST)
# 		# prefix (e.g., DR) (ST)
# 		# degree (e.g., MD) (IS)
# 		# source table (IS)
# 		# assigning authority (HD)
# 		# name type code (ID)
# 		# identifier check digit (ST)
# 		# code identifying the check digit scheme employed (ID)
# 		# identifier type code (IS) (IS)
# 		# assigning facility (HD)
# 		# Name Representation code (ID)
# 		# name context (CE)
# 		# name validity range (DR)
# 		# name assembly order (ID)
# 		#println xcn
  end

  #Generate an HL7 XON (extended composite name and identification number for organizations) data type.
  def xon(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		XON xtn = (XON) map.fld

# 		#organization name (ST)
# 		st(['fld'=>xtn.getComponent(0), 'required'=>'R', 'codetable'=>map.codetable])
# 		#organization name type code (IS)
# 		#ID number (NM) (NM)
# 		nm(['fld'=>xtn.getComponent(2), 'required'=>'R'])
# 		#check digit (NM) (ST)
# 		#code identifying the check digit scheme employed (ID)
# 		#assigning authority (HD)
# 		#identifier type code (IS) (IS)
# 		#assigning facility ID (HD)
# 		#Name Representation code (ID)
  end

  #Generate an HL7 XPN (extended person name) data type. This type consists of the following components=>
  def xpn(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		XPN xpn = (XPN)map.fld
# 		#family name (FN)
# 		fn(['fld'=> xpn.getComponent(0),'required'=>'R'])
# 		#given name (ST)
# 		#xpn.givenName.setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())));
# 		xpn.getComponent(1).setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())))
# 		#second and further given names or initials thereof (ST)
# 		#xpn.secondAndFurtherGivenNamesOrInitialsThereof.setValue('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.getAt(Math.abs(random.nextInt()%26)))
# 		xpn.getComponent(2).setValue('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.getAt(Math.abs(random.nextInt()%26)))
# 		#suffix (e.g., JR or III) (ST)
# 		#prefix (e.g., DR) (ST)
# 		#degree (e.g., MD) (IS)
# 		#name type code (ID)
# 		println xpn
  end

  #Generate HL7 XTN (extended telecommunication number)
  def xtn(map, force=false)
# 		#check if the field is optional and randomly generate it of skip
# 		return if(!autoGenerate?(map,force))

# 		XTN xtn = (XTN) map.fld
# 		#[(999)] 999-9999 [X99999][C any text] (TN)
# 		tn(['fld'=>xtn.getComponent(0), 'required'=>'R'])
# 		#xtn.get9999999X99999CAnyText().setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
# 		# telecommunication use code (ID)
# 		# telecommunication equipment type (ID) (ID)
# 		# Email address (ST)
# 		# Country Code (NM)
# 		# Area/city code (NM)
# 		# Phone number (NM)
# 		# Extension (NM)
# 		# any text (ST)
  end

  # 	private static final MONEY_FORMAT_INDICATORS = ['Balance', 'Charges', 'Adjustments','Income','Amount','Money']
  # 	private static final String RANGE_INDICATOR = '...'

  # #	Code Table, Data Type, Segment, Field,
  # #	72 – Insurance plan ID,CE,AUT,AUT.2 Authorizing Payor, Company ID
  # #	72 – Insurance plan ID,CE,IN1,IN1.2 Insurance Plan ID
  # #	88 – Procedure Code,CE,PR1,PR1.3 Procedure Code
  # #	132 – Transaction code,CE,CDM,CDM.1 Primary Key Value – CDM
  # #	132 – Transaction code,CE,FT1,FT1.7 Transaction Code
  # #	132 – Transaction code,CE,LCC,LCC.4 Charge Code
  # #	132 – Transaction code,CE,PRC,PRC.1 Primary Key Value – PRC
  # #	264 – Location department,CE,LCC,LCC.2 Location Department
  # #	264 – Location department,CE,LDP,LDP.2 Location Department
  # #	296 – Primary Language,CE,LAN,LAN.2 Language Code
  # #	361 – Sending/Receiving application,HD,MSH,MSH.3 Sending Application
  # #	361 – Sending/Receiving application,HD,MSH,MSH.5 Receiving Application
  # #	362 – Sending/Receiving facility,HD,MSH,MSH.4 Sending Facility
  # #	362 – Sending/Receiving facility,HD,MSH,MSH.6 Receiving Facility
  # #	471 – Query Name,CE,QID,QID.2 Message Query Name
  # #	471 – Query Name,CE,QPD,QPD.1 Message Query Name
  # #	9999 – For unknown CE data elements,CE,CM2,CM2.2 Scheduled Time Point
  # #	9999 – For unknown CE data elements,CE,CM2,CM2.4 Events Scheduled This Time Point
  # #	9999 – For unknown CE data elements,CE,MFA,MFA.5 Primary Key Value – MFA
  # #	9999 – For unknown CE data elements,CE,OM1,OM1.2 Producer’s Service/Test/Observation ID
  # #	9999 – For unknown CE data elements,CE,OM1,OM1.5 Producer ID

  # Value of coded table returned as as single value
  def getCodedValue(attributes)
    codes = @pp.getCodeTable(attributes['codetable'])
    puts codes
    #Apply rules to find a value and description
    map = applyRules(codes, attributes)
    #Return value only
    return map['value']
  end

  # Values and Description from code table returned as a pair.
  def getCodedMap(attributes)
    codes = @pp.getCodeTable(attributes['codetable'])
    puts codes
    #Apply rules to find a value and description
    #Returns map with code and description
    applyRules(codes, attributes)
  end


  # Handle range values specified by '...' sequence, including empty range
  def applyRules(codes, attributes)

    #safety check, no codes return an empty map
    return {} if Utils.blank?(codes)

    idx  = @@random.rand(codes.size)
    code = codes[idx]['value']
    description = codes[idx]['description']
    if(code.include?(@@RANGE_INDICATOR))
      ends = code.delete(' ').split('...').map{|it| it}
      if(ends.empty?) # This is indication that codetable does not have any values
        code, description = '',''
      else #Handle range values, build range and pick random value
        range = ends[0]..ends[1]
        code = range.to_a.sample()
      end
    elsif(code.size > (maxlen = (attributes['max_length']) ? attributes['max_length'].to_i : code.size))
      #remove all codes wich values violate
      codes.select! {|it| it['value'].size <= maxlen }
      if(!codes)
        code, description = '',''
      else
        puts codes
        idx  = @@random.rand(codes.size)
        code = codes[idx]['value']
        description = codes[idx]['description']
      end
    end
    puts code + ', ' + description
    return {'value'=>code, 'description'=>description}
  end

  # Returns randomly generated Id of required length, of single digit id
  def generateLengthBoundId(maxlen, str=@@random.rand(100000000).to_s)
    idx = maxlen
    if(maxlen > str.size)
      str = str.ljust(maxlen,'0')
      idx = str.size
    end
    return str[0..idx-1]
  end


  # If field are X,W,B (Not Supported, Withdrawn Fields or Backward Compatible)  returns false.
  # Conditional (C) ?
  # For Optional field (O) makes random choice
  # R - Required returns true
  # def isAutogenerate(map, force=false)
  def autoGenerate?(map, force=false)
    if(force)then return true end
    if(['X','W','B'].include?(map['required']))then return false end
    if(map['required'] =='R') then return true end
    if(map['required'] == 'O') then return [true, false].sample end #random boolean
    # return true
  end

  # @return DateTime generated with consideration of description string for dates in the future
  def toDateTime(map)
    #for Time Stamp one way to figure out if event is in the future of in the past to look for key words in description
    isFutureEvent = !Utils.blank?(map['description'])&& map['description'].include?('End') #so 'Role End Date/Time'
    seed = 365 #seed bounds duration of time to a year
    days = @@random.rand(seed)
    (isFutureEvent) ? DateTime.now().next_day(days) : DateTime.now().prev_day(days)
  end
 end