---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiUDPSocket'

-- Create kind of "class"
local multiUDPSocket = {}
multiUDPSocket.__index = multiUDPSocket

multiUDPSocket.styleForUI = 'None' -- Optional parameter to set UI style
multiUDPSocket.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiUDPSocket.styleForUI = theme
  Script.notifyEvent("MultiUDPSocket_OnNewStatusCSKStyle", multiUDPSocket.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiUDPSocketInstanceNo int Number of instance
---@return table[] self Instance of multiUDPSocket
function multiUDPSocket.create(multiUDPSocketInstanceNo)

  local self = {}
  setmetatable(self, multiUDPSocket)

  -- Standard helper functions
  self.helperFuncs = require('Communication/MultiUDPSocket/helper/funcs')

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Check if DataPersistent module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  self.multiUDPSocketInstanceNo = multiUDPSocketInstanceNo
  self.multiUDPSocketInstanceNoString = tostring(self.multiUDPSocketInstanceNo)

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Is current camera selected via UI (see "setSelectedCam")

  -- Default values for Persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiUDPSocket_Parameter' .. self.multiUDPSocketInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  self.currentBindStatus = false -- Status if socket is binded
  self.dataToTransmit = '' -- Preset data to transmit

  self.availableInterfaces = {}
  self.availableInterfaces = Engine.getEnumValues("EthernetInterfaces") -- Available ethernet interfaces on device
  table.insert(self.availableInterfaces, 1, 'ALL')
  self.interfaceList = self.helperFuncs.createStringListBySimpleTable(self.availableInterfaces) -- List of available ethernet interfaces

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  self.parameters.registeredEvent = ''
  self.parameters.processingFile = 'CSK_MultiUDPSocket_Processing'

  self.parameters.ip = '255.255.255.255' -- IP to transmit to, 255.255.255.255 for broadcast
  self.parameters.port = 23 -- Port to bind UDP
  self.parameters.bindStatus = false -- Should the module try to bind UDP
  self.parameters.interface = self.availableInterfaces[multiUDPSocketInstanceNo] -- Interface to use UDPSocket connection
  self.parameters.packFormat = '' -- Format to pack data to send as binary content, like '>I2', leave empty if not needed

  -- Manual receive function parameters
  self.parameters.receiveQueueSize = 0 -- Receive queue size. Set to 0 to disable the queue and receiving from the receive()-function, which also increases performance if only receiving over OnReceive-event.
  self.parameters.receiveTimeout = 0 -- Timeout in ms to wait for manual UDP receivements. 0 is default and means directly return
  self.parameters.receiveDiscardIfFull = false -- Set to true to discard the newest item which is currently added instead of discarding the oldest element for manual UDP receivements.
  self.parameters.receiveWarnOverruns = true -- Set to false to disable warning on overruns when using the receive()-function. Default is true.

  -- List of events to register to and forward content to TCP/IP server
  self.parameters.forwardEvents = {}

  -- Parameters to give to the processing script
  self.multiUDPSocketProcessingParams = Container.create()
  self.multiUDPSocketProcessingParams:add('multiUDPSocketInstanceNumber', multiUDPSocketInstanceNo, "INT")
  self.multiUDPSocketProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")

  self.multiUDPSocketProcessingParams:add('bindStatus', self.parameters.bindStatus, "BOOL")
  self.multiUDPSocketProcessingParams:add('interface', self.parameters.interface, "STRING")
  self.multiUDPSocketProcessingParams:add('ip', self.parameters.ip, "STRING")
  self.multiUDPSocketProcessingParams:add('port', self.parameters.port, "INT")
  self.multiUDPSocketProcessingParams:add('receiveQueueSize', self.parameters.receiveQueueSize, "INT")
  self.multiUDPSocketProcessingParams:add('receiveTimeout', self.parameters.receiveTimeout, "INT")
  self.multiUDPSocketProcessingParams:add('receiveDiscardIfFull', self.parameters.receiveDiscardIfFull, "BOOL")
  self.multiUDPSocketProcessingParams:add('receiveWarnOverruns', self.parameters.receiveWarnOverruns, "BOOL")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiUDPSocketProcessingParams)

  return self
end

--[[
-- Function to do something
--@multiUDPSocket:doSomething()
function multiUDPSocket:doSomething()
  self.object:doSomething()
end

-- Function to do something else
--@multiUDPSocket:doSomethingElse()
function multiUDPSocket:doSomethingElse()
  self:doSomething() --> access internal function
end
]]

return multiUDPSocket

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************