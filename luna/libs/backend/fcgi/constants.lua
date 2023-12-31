local C = {}

C.FCGI_VERSION_1 = 1

-- Values for type of FCGI_Header
C.FCGI_BEGIN_REQUEST = 1
C.FCGI_ABORT_REQUEST = 2
C.FCGI_END_REQUEST = 3
C.FCGI_PARAMS = 4
C.FCGI_STDIN = 5
C.FCGI_STDOUT = 6
C.FCGI_STDERR = 7
C.FCGI_DATA = 8
C.FCGI_GET_VALUES = 9
C.FCGI_GET_VALUES_RESULT = 10
C.FCGI_UNKNOWN_TYPE = 11
C.FCGI_MAXTYPE = C.FCGI_UNKNOWN_TYPE

-- Mask for flags of BeginRequest
C.FCGI_KEEP_CONN = 1

-- Values for role component of BeginRequest
C.FCGI_RESPONDER = 1
C.FCGI_AUTHORIZER = 2
C.FCGI_FILTER = 3

-- Values for protocolStatus component of EndRequestBody
C.FCGI_REQUEST_COMPLETE = 0
C.FCGI_CANT_MPX_CONN = 1
C.FCGI_OVERLOADED = 2
C.FCGI_UNKNOWN_ROLL = 3

-- Variable names
C.FCGI_MAX_CONNS = "FCGI_MAX_CONNS"
C.FCGI_MAX_REQS = "FCGI_MAX_REQS"
C.FCI_MPX_CONNS = "FCGI_MPX_CONNS"

return C