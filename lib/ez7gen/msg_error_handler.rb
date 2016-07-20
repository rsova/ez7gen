require 'ruby-hl7'

class MsgErrorHandler

  def handle(message)
    segs = message.split("\n")
    msg = HL7::Message.new(segs)
    seg = msg[:ERR]
    if(! msg[:ERR])
      return nil
    end

    # puts msg[:ERR].error_location
    # puts msg[:ERR].hl7_error_code
    puts msg[:ERR].severity
    puts msg[:ERR].application_error_code
    # puts msg[:ERR].application_error_parameter
    # puts msg[:ERR].diagnostic_information
    errors = msg[:ERR].user_message
    # puts msg[:ERR].help_desk_contact_point
    # lines = errors.split("ERROR <Ens>ErrGeneral:")
    errors.split("ERROR #{msg[:ERR].application_error_code}:").reject {|e| e.empty?}
  end

end