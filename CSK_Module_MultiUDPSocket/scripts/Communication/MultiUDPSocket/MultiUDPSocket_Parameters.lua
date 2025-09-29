---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiUDPSocketParameters = {}

  multiUDPSocketParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiUDPSocketParameters.registeredEvent = ''
  multiUDPSocketParameters.processingFile = 'CSK_MultiUDPSocket_Processing'

  multiUDPSocketParameters.ip = '255.255.255.255' -- IP to transmit to, 255.255.255.255 for broadcast
  multiUDPSocketParameters.port = 23 -- Port to bind UDP
  multiUDPSocketParameters.bindStatus = false -- Should the module try to bind UDP
  multiUDPSocketParameters.interface = '' -- Interface to use UDPSocket connection -- Interface to use for HTTP client (must be set individually)
  multiUDPSocketParameters.packFormat = '' -- Format to pack data to send as binary content, like '>I2', leave empty if not needed

  -- Manual receive function parameters
  multiUDPSocketParameters.receiveQueueSize = 0 -- Receive queue size. Set to 0 to disable the queue and receiving from the receive()-function, which also increases performance if only receiving over OnReceive-event.
  multiUDPSocketParameters.receiveTimeout = 0 -- Timeout in ms to wait for manual UDP receivements. 0 is default and means directly return
  multiUDPSocketParameters.receiveDiscardIfFull = false -- Set to true to discard the newest item which is currently added instead of discarding the oldest element for manual UDP receivements.
  multiUDPSocketParameters.receiveWarnOverruns = true -- Set to false to disable warning on overruns when using the receive()-function. Default is true.

  -- List of events to register to and forward content via UDP
  multiUDPSocketParameters.forwardEvents = {}

  return multiUDPSocketParameters
end
functions.getParameters = getParameters

return functions