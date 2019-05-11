module RubyVolt
  class DataType
    class ProcedureCallStatusCode < AppDataType
      hash_codes [1, SuccessStatusCode], # SUCCESS
                 [-1, UserAbortStatusCode], # USER_ABORT
                 [-2, GracefulFailureStatusCode], # GRACEFUL_FAILURE
                 [-3, UnexpectedFailureStatusCode], # UNEXPECTED_FAILURE
                 [-4, ConnectionLostStatusCode] # CONNECTION_LOST
                 

     
    end
  end
end