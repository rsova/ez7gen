require_relative '../profile_parser'

class TypeAwareFieldGenerator
  @@RANGE_INDICATOR = '...'
  @@random = Random.new
  # constructor
  def initialize(pp)
    @pp = pp
  end

  # Generate HL7 EI - entity identifier
  def EI(map)
    # entity identifier (ST)
    attributes = map.clone
    attributes['required'] = 'R'
    ST(attributes)
    # namespace ID (IS)
    # universal ID (ST)
    # universal ID type (ID)
  end

  # single string value
  def ST(map)
    val = map['description']
    puts val

    if(map['description'].include?("SSN"))
      val = "606121126"
      #val = generateLengthBoundId(9)
    else
      len = (map['max_length']!=nil)? map['max_length'].to_i : 1
      #val = generateLengthBoundId((len>5)?5:len) // numeric id up to 5 TODO: string ids?
      val = @@random.rand(10000).to_s
    end
    return val
  end

  # 	private static final MONEY_FORMAT_INDICATORS = ["Balance", "Charges", "Adjustments","Income","Amount","Money"]
  # 	private static final String RANGE_INDICATOR = "..."

  # //	Code Table, Data Type, Segment, Field,
  # //	72 – Insurance plan ID,CE,AUT,AUT.2 Authorizing Payor, Company ID
  # //	72 – Insurance plan ID,CE,IN1,IN1.2 Insurance Plan ID
  # //	88 – Procedure Code,CE,PR1,PR1.3 Procedure Code
  # //	132 – Transaction code,CE,CDM,CDM.1 Primary Key Value – CDM
  # //	132 – Transaction code,CE,FT1,FT1.7 Transaction Code
  # //	132 – Transaction code,CE,LCC,LCC.4 Charge Code
  # //	132 – Transaction code,CE,PRC,PRC.1 Primary Key Value – PRC
  # //	264 – Location department,CE,LCC,LCC.2 Location Department
  # //	264 – Location department,CE,LDP,LDP.2 Location Department
  # //	296 – Primary Language,CE,LAN,LAN.2 Language Code
  # //	361 – Sending/Receiving application,HD,MSH,MSH.3 Sending Application
  # //	361 – Sending/Receiving application,HD,MSH,MSH.5 Receiving Application
  # //	362 – Sending/Receiving facility,HD,MSH,MSH.4 Sending Facility
  # //	362 – Sending/Receiving facility,HD,MSH,MSH.6 Receiving Facility
  # //	471 – Query Name,CE,QID,QID.2 Message Query Name
  # //	471 – Query Name,CE,QPD,QPD.1 Message Query Name
  # //	9999 – For unknown CE data elements,CE,CM2,CM2.2 Scheduled Time Point
  # //	9999 – For unknown CE data elements,CE,CM2,CM2.4 Events Scheduled This Time Point
  # //	9999 – For unknown CE data elements,CE,MFA,MFA.5 Primary Key Value – MFA
  # //	9999 – For unknown CE data elements,CE,OM1,OM1.2 Producer’s Service/Test/Observation ID
  # //	9999 – For unknown CE data elements,CE,OM1,OM1.5 Producer ID

  #Value of coded table returned as as single value
  def getCodedValue(attributes)
    codes = @pp.getCodeTable(attributes['codetable'])
    puts codes
    #Apply rules to find a value and description
    map = applyRules(codes, attributes)
    #Return value only
    return map['value']
  end

  #Values and Description from code table returned as a pair.
  def getCodedMap(attributes)
    codes = @pp.getCodeTable(attributes['codetable'])
    puts codes
    #Apply rules to find a value and description
    map = applyRules(codes, attributes)
  end


  #Handle range values specified by '...' sequence, including empty range
  def applyRules(codes, attributes)
    idx  = @@random.rand(codes.size)
    code = codes[idx]['value']
    description = codes[idx]['description']
    if(code.include?(@@RANGE_INDICATOR))
      ends = code.delete(' ').split('...').map{|it| it}
      if(!ends) # This is indication that codetable does not have any values
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
    puts code + ", " + description
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


  #If field are X,W,B (Not Supported, Withdrawn Fields or Backward Compatible)  returns false.
  # Conditional (C) ?
  # For Optional field (O) makes random choice
  # R - Required returns true
  # def isAutogenerate(map)
  def autoGenerate?(map)
    if(['X','W','B'].include?(map['required']))then return false end
    if(map['required'] =='R') then return true end
    if(map['required'] == 'O') then return [true, false].sample end #random boolean
    # return true
  end

  # Generate HL7 CE (coded element) data type
  def ce(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		CE ce = (CE) map?.fld
# 		if(map.codetable != null){
# 			Map codes = getCodedMap(pp, map)
# 			//identifier (ST) (ST)
# 			ce.getIdentifier().setValue(codes.value)
# 			//text (ST)
# 			ce.getText().setValue(codes.description)
# 			// name of coding system (IS)
# 			// alternate identifier (ST) (ST)
# 			// alternate text (ST)
# 			//name of alternate coding system (IS)
# 		}else{
# 			ce.getIdentifier().setValue(Math.abs(random.nextInt() % 200).toString())
# 		}
# 		println ce
  end

  #Generate HL7 CP (composite price) data type.
  def cp(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		CP cp = (CP) map.fld
# 		//price (MO)
# 		mo(["fld":cp.getComponent(0), "required":"R"])
# 		//price type (ID)
# 		//from value (NM)
# 		//to value (NM)
# 		//range units (CE)
# 		//range type (ID)
  end

  #Generate HL7 CX (extended composite ID with check digit) data type.
  def cx(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		CX cx = (CX) map.fld
# 		//ID (ST)
# 		st(["fld":cx.getID(), description:"Number", required:"R"])
# 		println cx.getID()
# 		//check digit (ST) (ST)
# 		//code identifying the check digit scheme employed (ID)
# 		//assigning authority (HD)
# 		//identifier type code (ID) (ID)
# 		//assigning facility (HD)
# 		//effective date (DT) (DT)
# 		//expiration date (DT)
  end


  #Generate HL7 DLD (discharge location) data type. This type consists of the following components:
  def dld(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		DLD dld = (DLD) map.fld
# 		//discharge location (ID)
# 		id(["fld":dld.getDischargeLocation(), required:"R"])
# 		//effective date (TS)
# 		ts(["fld":dld.getEffectiveDate(), required:"R"])
# 		println dld
  end

  #Generate HHL7 DLN (driver's license number) data type
  def dln(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		DLN dln = (DLN) map.fld
# 		//Driver´s License Number (ST)
# 		dln.getDriverSLicenseNumber().setValue(String.format("%07d", (Math.abs(random.nextInt()))))// 7 Numeric, as for some states in real life
# 		//Issuing State, province, country (IS)
# 		//is(["fld":dln.getIssuingStateProvinceCountry(), "required":"R","codetable":map.codetable])
# 		dln.getIssuingStateProvinceCountry().setValue(allStates.get(Math.abs(random.nextInt()%allStates.size())))

# 		//expiration date (DT)
# 		dt(["fld":dln.getExpirationDate(),"description":"End", "required":"R"])
  end

  #Generates HL7 DR (date/time range) data type.
  def dr(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		DR dr = (DR) map.fld
# 		//range start date/time (TS)
# 		ts(["fld":dr.getComponent(0), "required":"R"])
# 		//range end date/time (TS)
# 		ts(["fld":dr.getComponent(1),"description":"End", "required":"R"])
  end

  # Generates an HL7 DT (date) datatype.
  def dt(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		boolean isFutureEvent = map.description?.contains('End') //so 'Role End Date/Time'

# 		int seed = 52 //seed bounds duration of time to 52 weeks, a year baby...
# 		use(TimeCategory) {
# 			Duration duration = Math.abs(random.nextInt() % seed).toInteger().week
# 			Date evnt = (isFutureEvent)?new Date() + duration:new Date() - duration
# 			//YYYY[MM[DD]]
# 			//String v = evnt.format( 'YYYYMMDD')
# 			String v = evnt.format( 'YYYYMMdd')
# 			((DT)map.fld).setValue(v)
# 		}
  end

  # Generate HL7 EI - entity identifier
  def ei(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		EI ei =(EI)map.fld
# 		ei.getEntityIdentifier().setValue(Math.abs(random.nextInt() % 20 ).toString())
# 		// ei.getNamespaceID().setValue("")
# 		// ei.getUniversalID().setValue("")
# 		// ei.getUniversalIDType().setValue("")
# 		//return (EI) map.fld
  end

  # Generate HL7 ID, usually using value from code table
  def id(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		String val = (map.codetable != null)? getCodedValue(pp, map): Math.abs(random.nextInt() % 200).toString()
# 		((ID) map.fld).setValue(val)
  end

  #Generates HL7 IS (namespace id) data type
  def is(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		String val = (map.codetable != null)? getCodedValue(pp, map): Math.abs(random.nextInt() % 200).toString()
# 		((IS) map.fld).setValue(val)
  end

  #Generates HL7 FC (financial class) data type.
  def fc(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		FC fc = (FC) map.fld

# 		//Financial Class (IS)
# 		is(["fld":fc.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//Effective Date (TS) (TS)
# 		ts(["fld":fc.getComponent(1), "required":"R"])
  end

  #Generates an HL7 FN (familiy name) data type.
  def fn(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		FN fc = (FN) map.fld

# 		//surname (ST)
# 		fc.surname.setValue(lastNames.getAt(Math.abs(random.nextInt()%lastNames.size())));
# 		//own surname prefix (ST)
# 		//own surname (ST)
# 		//surname prefix from partner/spouse (ST)
# 		//surname from partner/spouse (ST)
  end

  #Generates HL7 HD (hierarchic designator) data type
  def hd(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		HD hd = (HD) map.fld
# 		//namespace ID (IS)
# 		is(["fld":hd.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//universal ID (ST)
# 		//universal ID type (ID)
  end

  #Generates HL7 JCC (job code/class) data type.
  def jcc(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		JCC jcc = (JCC) map.fld
# 		//job code (IS)
# 		is(["fld":jcc.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//job class (IS)
# 		is(["fld":jcc.getComponent(1), "required":"R"])

  end

  #Generates HL7 MSG (Message Type) data type.
  def msg(map)
# 		//message type (ID)
# 		//trigger event (ID)
# 		//message structure (ID)

# 		//Message type set while initializing MSH segment, do nothing.
# 		return
  end

  #Generates an HL7 MO (money) data type.
  def mo(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		MO mo = (MO) map.fld
# 		//quantity (NM)
# 		nm("fld":mo.getComponent(0), "description":"Money", "required":"R")
# 		//denomination (ID)
# 		mo.getComponent(1).setValue("USD")
  end

  #Generates an HL7 NM (numeric) data type. A NM contains a single String value.
  def nm(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		NM nm = (NM) map.fld
# 		//money
# 		//if(map.description?.contains("Amount") || map.description?.contains("Money")){//check for specific numeric format Amount

# 		//if(map.description!=null && null!= moneyFormatIndicator.find(map?.description?.contains(it))){//check for specific numeric for money
# 		if(null!= MONEY_FORMAT_INDICATORS.find{map?.description?.contains(it)}){//check for specific numeric for money
# 			nm.setValue(String.format("%.2f",(Math.abs(random.nextDouble())) *1000)) //under $1,000
# 		}else {//quantity (NM)
# 			nm.setValue(Math.abs(random.nextInt() % 20).toString())
# 		}
  end

  #Generates an HL7 OCD (occurence) data type.
  #The code and associated date defining a significant event relating to a bill that may affect payer processing
  def ocd(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		OCD ocd = (OCD) map.fld
# 		//occurrence code (IS)
# 		is(["fld":ocd.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//occurrence date (DT)
# 		dt(["fld":ocd.getComponent(1), "required":"R"])
# 		println ocd
  end

  #Generate an HL7 OSP (occurence span) data type.
  def osp(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		OSP ocp = (OSP) map.fld
# 		//occurrence span code (CE)
# 		ce(["fld":ocp.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//occurrence span start date (DT)
# 		dt(["fld":ocp.getComponent(1), "required":"R"])
# 		//occurrence span stop date (DT)
# 		dt(["fld":ocp.getComponent(2), "description":"End","required":"R"])
  end

  #Generate an HL7 PL (person location) data type.
  def pl(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		PL pl = (PL) map.fld
# 		//point of care (IS)
# 		is(["fld":pl.getComponent(0), "required":"R"])
# 		//room (IS)
# 		is(["fld":pl.getComponent(1), "required":"R"])
# 		//bed (IS)
# 		is(["fld":pl.getComponent(2), "required":"R"])
# 		//facility (HD) (HD)
# 		hd(["fld":pl.getComponent(3), "required":"R"])
# 		//location status (IS)
# 		//person location type (IS)
# 		//building (IS)
# 		is(["fld":pl.getComponent(6), "required":"R"])
# 		//floor (IS)
# 		//Location description (ST)
  end

  #Generate HL7 S PT (processing type) data type.
  def pt(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		//map.maxlen
# 		PT pt = (PT) map.fld
# 		Map mp = map.clone()
# 		mp.fld = pt.getComponent(0)
# 		mp.required = "R"
# 		id(mp)
# 		//processing ID (ID)
# 		//processing mode (ID)
  end

  #Generate HL7 SI (sequence ID) data type. A SI contains a single String value.
  def si(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		SI pt = (SI) map.fld
# 		pt.setValue(generateLengthBoundId((map.max_length)?map.max_length.toInteger():1))
  end

  #Generate HL7 ST (string data) data type. A ST contains a single String value.
  def st(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		ST st = (ST) map.fld
# 		//this one returns empty string if field has not been set
# //		def x  =  st.getValueOrEmpty()//number,-id, code
# //		if(x.isEmpty()){
# 			String val = map.description
# 			println val
# 			//[Continuation Pointer, SSN Number - Patient, Birth Place, Strain, Patient Valuables Location, Observation Sub-Id, References Range, User Defined Access Checks, Allergy Reaction Code, Guarantor SSN, Job Title, UB-82 Locator 2, UB-82 Locator 9, UB-82 Locator 27, UB-82 Locator 45, Covered Days (7), Non-Covered Days (8), UB92 Locator 56 (State), UB92 Locator 57 (National)]

# 			if(val?.contains("SSN")){//if SSN
# 				//val = "606121126"
# 				val = generateLengthBoundId(9)
# 			}else{
# 				int len = (map.max_length)?map.max_length.toInteger():1
# 				val = generateLengthBoundId((len>5)?5:len) // numeric id up to 5 TODO: string ids?

# //			else if(map.max_length < 4 || val.contains("Id")|| val.contains("Days")|| val.contains("Code") || val.contains("Number") ){
# //				val = (Math.abs(random.nextInt()%100))// up to 3 spaces
# //			}else{//use description
# //				//if description does not fit use number
# //				val = (val.length() > map.max_length.toInteger())?(Math.abs(random.nextInt()%100)):val
# 			}
# 			st.setValue(val)
# //		}
  end

  #Generate HL7 TS (time stamp), within number of weeks in the future or past
  def ts(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		TS ts = (TS) map.fld
# 		//for Time Stamp one way to figure out if event is in the future of in the past to look for key words in description
# 		boolean isFutureEvent = map?.description?.contains('End') //so 'Role End Date/Time'
# 		int seed = 52 //seed bounds duration of time to 52 weeks, a year baby...
# 		use(TimeCategory) {
# 			Duration duration = Math.abs(random.nextInt() % seed).toInteger().week
# 			Date evnt = (isFutureEvent)?new Date() + duration:new Date() - duration
# 			//time of an event (TSComponentOne)
# 			ts.getTimeOfAnEvent().setValue(evnt.format("YYYYMMDDHHSS.SSS"))
# 			//degree of precision (ST)
# 		}
# 		println ts
  end

  #Generate an HL7 TN (telephone number) data type. A TN contains a single String value.
  def tn(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		TN tn = (TN) map.fld
# 		tn.setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
  end

  #Generate an HL7 UVC (Value code and amount) data type.
  def uvc(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		UVC uvc = ((UVC)map.fld)
# 		//value code (IS)
# 		is(["fld":uvc.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//value amount (NM)
# 		nm(["fld":uvc.getComponent(1), "required":"R"])
  end

  #Generate an HL7 VID (version identifier) data type.
  def vid(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		VID vid = ((VID)map.fld)
# //		version ID (ID)
# 		id(["fld":vid.getComponent(0), "required":"R", "codetable":map.codetable])

# //		internationalization code (CE)
# //		international version ID (CE)

  end

  #Generate HL7 XAD (extended address)
  def xad(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		XAD xad = (XAD) map.fld
# 		int idx = Math.abs(random.nextInt()%streetNames.size())
# 		//street address (SAD) (SAD)
# 		xad.getStreetAddress().getStreetName().setValue(streetNames.getAt(idx))
# 		//other designation (ST)
# 		//city (ST)
# 		xad.getCity().setValue(cities.getAt(idx))
# 		//state or province (ST)
# 		xad.getStateOrProvince().setValue(states.getAt(idx))
# 		//zip or postal code (ST)
# 		xad.getZipOrPostalCode().setValue(zips.getAt(idx))
# 		//country (ID)
# 		xad.getCountry().setValue(countries.getAt(idx))
# 		//address type (ID)
# 		//other geographic designation (ST)
# 		//county/parish code (IS)
# 		//census tract (IS)
# 		//address representation code (ID)
# 		//address validity range (DR)
  end

  # Generate HL7 XCN (extended composite ID number and name for persons)
  def xcn(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		XCN xcn = (XCN) map.fld
# 		// ID number (ST) (ST)
# 		xcn.getIDNumber().setValue(Math.abs(random.nextInt() % 300).toString())
# 		// family name (FN)
# 		fn(['fld': xcn.getComponent(1),'required':'R'])
# 		//xcn.familyName.surname.value = lastNames.getAt(Math.abs(random.nextInt()%lastNames.size()));
# 		// given name (ST)
# 		//xcn.givenName.value = firstNames.getAt(Math.abs(random.nextInt()%firstNames.size()));
# 		xcn.getComponent(2).setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())))
# 		// second and further given names or initials thereof (ST)
# 		//xcn.secondAndFurtherGivenNamesOrInitialsThereof.value ="J"
# 		xcn.getComponent(3).setValue("ABCDEFGHIJKLMNOPQRSTUVWXYZ".getAt(Math.abs(random.nextInt()%26)))
# 		// suffix (e.g., JR or III) (ST)
# 		// prefix (e.g., DR) (ST)
# 		// degree (e.g., MD) (IS)
# 		// source table (IS)
# 		// assigning authority (HD)
# 		// name type code (ID)
# 		// identifier check digit (ST)
# 		// code identifying the check digit scheme employed (ID)
# 		// identifier type code (IS) (IS)
# 		// assigning facility (HD)
# 		// Name Representation code (ID)
# 		// name context (CE)
# 		// name validity range (DR)
# 		// name assembly order (ID)
# 		//println xcn
  end

  #Generate an HL7 XON (extended composite name and identification number for organizations) data type.
  def xon(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		XON xtn = (XON) map.fld

# 		//organization name (ST)
# 		st(["fld":xtn.getComponent(0), "required":"R", "codetable":map.codetable])
# 		//organization name type code (IS)
# 		//ID number (NM) (NM)
# 		nm(["fld":xtn.getComponent(2), "required":"R"])
# 		//check digit (NM) (ST)
# 		//code identifying the check digit scheme employed (ID)
# 		//assigning authority (HD)
# 		//identifier type code (IS) (IS)
# 		//assigning facility ID (HD)
# 		//Name Representation code (ID)
  end

  #Generate an HL7 XPN (extended person name) data type. This type consists of the following components:
  def xpn(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		XPN xpn = (XPN)map.fld
# 		//family name (FN)
# 		fn(['fld': xpn.getComponent(0),'required':'R'])
# 		//given name (ST)
# 		//xpn.givenName.setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())));
# 		xpn.getComponent(1).setValue(firstNames.getAt(Math.abs(random.nextInt()%firstNames.size())))
# 		//second and further given names or initials thereof (ST)
# 		//xpn.secondAndFurtherGivenNamesOrInitialsThereof.setValue("ABCDEFGHIJKLMNOPQRSTUVWXYZ".getAt(Math.abs(random.nextInt()%26)))
# 		xpn.getComponent(2).setValue("ABCDEFGHIJKLMNOPQRSTUVWXYZ".getAt(Math.abs(random.nextInt()%26)))
# 		//suffix (e.g., JR or III) (ST)
# 		//prefix (e.g., DR) (ST)
# 		//degree (e.g., MD) (IS)
# 		//name type code (ID)
# 		println xpn
  end

  #Generate HL7 XTN (extended telecommunication number)
  def xtn(map)
# 		//check if the field is optional and randomly generate it of skip
# 		if(!isAutogenerate(map)){return}

# 		XTN xtn = (XTN) map.fld
# 		//[(999)] 999-9999 [X99999][C any text] (TN)
# 		tn(["fld":xtn.getComponent(0), 'required':'R'])
# 		//xtn.get9999999X99999CAnyText().setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
# 		// telecommunication use code (ID)
# 		// telecommunication equipment type (ID) (ID)
# 		// Email address (ST)
# 		// Country Code (NM)
# 		// Area/city code (NM)
# 		// Phone number (NM)
# 		// Extension (NM)
# 		// any text (ST)
  end
end