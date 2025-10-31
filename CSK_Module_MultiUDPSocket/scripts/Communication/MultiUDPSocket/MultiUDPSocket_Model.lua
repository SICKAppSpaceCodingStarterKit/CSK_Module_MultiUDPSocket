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
  self.activeInUI = false -- Is current instance selected via UI

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
  self.parameters = self.helperFuncs.defaultParameters.getParameters() -- Load default parameters

  -- Instance specific parameters
  self.parameters.interface = self.availableInterfaces[multiUDPSocketInstanceNo] -- Interface to use UDPSocket connection

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

return multiUDPSocket

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************