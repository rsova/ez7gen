require 'test/unit'
require 'ez7gen/msg_error_handler'

class MsgErrorHandlerTest < Test::Unit::TestCase

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

  def test_success_message
    ok="MSH|^~\&|EnsembleHL7|ISC|404|707|201607162200||ACK^A01|171|P|2.4|234
MSA|AA|171"
    errors = MsgErrorHandler.new().handle(ok)
    assert_nil(errors)
  end


  def test_error_message
    msg = "MSH|^~\&|EnsembleHL7|ISC|404|808|201607162206||ACK^A05|218|P|2.4|936
MSA|AE|218
ERR||||E|<Ens>ErrGeneral|||ERROR <Ens>ErrGeneral: Not forwarding message 9292 with message body Id=4610, Doc Identifier=218, SessionId=9292 because of validation failure: ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 8:DB1.  Field 2, repetition 1 is larger than segment structure 2.4:DB1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ABCDDEFRTYURYRURURUR' appears in segment 8:DB1, field 2, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:334.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 11:DG1.  Field 6, repetition 1 is larger than segment structure 2.4:DG1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'xxxxxxxxxx' appears in segment 11:DG1, field 6, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:52.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 11:DG1.  Field 18, repetition 1 is larger than segment structure 2.4:DG1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ZZZZZZZ' appears in segment 11:DG1, field 18, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:136."
    errors = MsgErrorHandler.new().handle(msg)
    assert_not_nil(errors)
    assert_equal(7, errors.size)
    puts errors
  end
end