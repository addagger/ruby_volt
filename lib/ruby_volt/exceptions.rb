module RubyVolt
  # Local exceptions
  
  class SocketDialogTimeout < ::Exception
  end
  
  class SendMsgTimeout < SocketDialogTimeout
  end
  
  class ReadTimeout < SocketDialogTimeout
  end

  # Login Message Exceptions
  
  class AuthenticationRejected < ::Exception
  end
  
  class TooManyConnections < ::Exception
  end
  
  class TooLongToTransmitCredentials < ::Exception
  end
  
  class InvalidLoginMessage < ::Exception
  end
  
  class ClientDataInvalid < ::Exception
  end
  
  # Procedure Call Status Codes
  
  class ProcedureCallException < ::Exception
  end
  
  class SuccessStatusCode < ProcedureCallException
  end
  
  class UserAbortStatusCode < ProcedureCallException
  end
  
  class GracefulFailureStatusCode < ProcedureCallException
  end
  
  class UnexpectedFailureStatusCode < ProcedureCallException
  end
  
  class ConnectionLostStatusCode < ProcedureCallException
  end
  
  # Serializable Exceptions
  
  class SerializableException < ::Exception
  end
  
  class EEException < SerializableException
    # This is a generic failure in Volt. Should indicate a failure in the serv- er and not the application code. These should not occur in normal operation.
  end
  
  class SQLException < SerializableException
    # This is the base class for all excep- tions that can occur during normal op- eration. This includes things like con- straint failures (unique, string length, not null) that are caught and handled correct by Volt.
  end
  
  class ConstraintFailureException < SerializableException
    # This is a specialization of SQLExcep- tion for constraint failures during the execution of a stored procedure.
  end
    
end