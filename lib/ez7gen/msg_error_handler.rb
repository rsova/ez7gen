require 'ruby-hl7'

class MsgErrorHandler

  ERR_HEAD = "ERROR <Ens>ErrGeneral:"

  def handle(resp)
    # segs = message
    #segs = resp.split("\r")
    resp.chomp!()

    # msg = HL7::Message.new(segs)
    # msg = HL7::Message.parse(message)
    # seg = msg[:ERR]
    if(! resp.include?(ERR_HEAD))
      return nil
    end

    # if there are errors, make response easy on the eye
    resp.gsub!("\\X0D\\\\X0A\\", "\r")
    resp.gsub!("\r+\r", "\r")
    resp.gsub!(ERR_HEAD, "\r"+ERR_HEAD)
    resp.gsub!("\r\r","\r") # remove empty lines

    # get errors for toaster display
    errors = resp.split(ERR_HEAD).reject {|e| e.empty?}
    errors.delete_at(0) # remove part of the message before errors

    return errors

    # puts msg[:ERR].error_location
    # puts msg[:ERR].hl7_error_code
    # puts msg[:ERR].severity
    # puts msg[:ERR].application_error_code
    # puts msg[:ERR].application_error_parameter
    # puts msg[:ERR].diagnostic_information
   # errors = msg[:ERR].user_message
    # puts msg[:ERR].help_desk_contact_point
    # lines = errors.split("ERROR <Ens>ErrGeneral:")
    # errors.split("ERROR #{msg[:ERR].application_error_code}:").reject {|e| e.empty?}
  end

end