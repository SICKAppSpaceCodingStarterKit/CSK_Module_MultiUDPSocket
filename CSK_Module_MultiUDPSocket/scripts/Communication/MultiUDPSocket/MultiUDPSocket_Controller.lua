---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiUDPSocket_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiUDPSocket'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiUDPSocket = Timer.create()
tmrMultiUDPSocket:setExpirationTime(100)
tmrMultiUDPSocket:setPeriodic(false)

local eventToForward = '' -- Preset event name to add via UI (see 'addEventToForwardViaUI')
local selectedEventToForward = '' -- Selected event to forward content on UDP socket within UI table

-- Reference to global handle
local multiUDPSocket_Model -- Reference to model handle
local multiUDPSocket_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiUDPSocket/helper/funcs') -- general helper functions

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiUDPSocket.transmitDataNUM", emptyFunction)

Script.serveEvent("CSK_MultiUDPSocket.OnNewDataNUM", "MultiUDPSocket_OnNewDataNUM")
Script.serveEvent("CSK_MultiUDPSocket.OnNewValueToForwardNUM", "MultiUDPSocket_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiUDPSocket.OnNewValueUpdateNUM", "MultiUDPSocket_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusModuleVersion', 'MultiUDPSocket_OnNewStatusModuleVersion')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusCSKStyle', 'MultiUDPSocket_OnNewStatusCSKStyle')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusModuleIsActive', 'MultiUDPSocket_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusConnectionStatus', 'MultiUDPSocket_OnNewStatusConnectionStatus')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusCurrentConnection', 'MultiUDPSocket_OnNewStatusCurrentConnection')

Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusPort', 'MultiUDPSocket_OnNewStatusPort')
Script.serveEvent("CSK_MultiUDPSocket.OnNewInterfaceList", "MultiUDPSocket_OnNewInterfaceList")
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusInterface', 'MultiUDPSocket_OnNewStatusInterface')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusIP', 'MultiUDPSocket_OnNewStatusIP')

Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusReceiveTimeout', 'MultiUDPSocket_OnNewStatusReceiveTimeout')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusQueueSizeReceive', 'MultiUDPSocket_OnNewStatusQueueSizeReceive')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusDiscardIfFull', 'MultiUDPSocket_OnNewStatusDiscardIfFull')
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusWarnOverruns', 'MultiUDPSocket_OnNewStatusWarnOverruns')

Script.serveEvent("CSK_MultiUDPSocket.OnNewDataToTransmit", "MultiUDPSocket_OnNewDataToTransmit")
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusPackFormat', 'MultiUDPSocket_OnNewStatusPackFormat')
Script.serveEvent("CSK_MultiUDPSocket.OnNewLog", "MultiUDPSocket_OnNewLog")
Script.serveEvent("CSK_MultiUDPSocket.OnNewEventToForwardList", "MultiUDPSocket_OnNewEventToForwardList")
Script.serveEvent("CSK_MultiUDPSocket.OnNewEventToForward", "MultiUDPSocket_OnNewEventToForward")

Script.serveEvent("CSK_MultiUDPSocket.OnNewStatusLoadParameterOnReboot", "MultiUDPSocket_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiUDPSocket.OnPersistentDataModuleAvailable", "MultiUDPSocket_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiUDPSocket.OnNewParameterName", "MultiUDPSocket_OnNewParameterName")
Script.serveEvent('CSK_MultiUDPSocket.OnNewStatusFlowConfigPriority', 'MultiUDPSocket_OnNewStatusFlowConfigPriority')

Script.serveEvent("CSK_MultiUDPSocket.OnNewInstanceList", "MultiUDPSocket_OnNewInstanceList")
Script.serveEvent("CSK_MultiUDPSocket.OnNewProcessingParameter", "MultiUDPSocket_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiUDPSocket.OnNewSelectedInstance", "MultiUDPSocket_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiUDPSocket.OnDataLoadedOnReboot", "MultiUDPSocket_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiUDPSocket.OnUserLevelOperatorActive", "MultiUDPSocket_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiUDPSocket.OnUserLevelMaintenanceActive", "MultiUDPSocket_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiUDPSocket.OnUserLevelServiceActive", "MultiUDPSocket_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiUDPSocket.OnUserLevelAdminActive", "MultiUDPSocket_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiUDPSocket_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiUDPSocket_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiUDPSocket_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiUDPSocket_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  print(eventname)
  Script.notifyEvent(eventname, value)
end

--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
local function handleOnNewValueUpdate(instance, parameter, value)
  if parameter == 'currentBindStatus' then
    multiUDPSocket_Instances[instance][parameter] = value
    if instance == selectedInstance then
      Script.notifyEvent("MultiUDPSocket_OnNewStatusCurrentConnection", multiUDPSocket_Instances[selectedInstance].currentBindStatus)
    end
  else
    multiUDPSocket_Instances[instance].parameters[parameter] = value
  end
end

--- Function to get access to the MultiUDPSocket_Model object
---@param handle handle Handle of multiUDPSocket_Model object
local function setMultiUDPSocket_Model_Handle(handle)
  multiUDPSocket_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiUDPSocket_Model_Handle = setMultiUDPSocket_Model_Handle

-- Function to get access to the MultiUDPSocket_Instances
---@param handle handle Handle of multiUDPSocket_Instances object
local function setMultiUDPSocket_Instances_Handle(handle)
  multiUDPSocket_Instances = handle
  if multiUDPSocket_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiUDPSocket_Instances do
    Script.register("CSK_MultiUDPSocket.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
    Script.register("CSK_MultiUDPSocket.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end
end
funcs.setMultiUDPSocket_Instances_Handle = setMultiUDPSocket_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiUDPSocket_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiUDPSocket_OnUserLevelOperatorActive", true)
    Script.notifyEvent("MultiUDPSocket_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiUDPSocket_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiUDPSocket_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiUDPSocket()

  Script.notifyEvent('MultiUDPSocket_OnNewStatusModuleVersion', 'v' .. multiUDPSocket_Model.version)
  Script.notifyEvent('MultiUDPSocket_OnNewStatusCSKStyle', multiUDPSocket_Model.styleForUI)
  Script.notifyEvent("MultiUDPSocket_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    updateUserLevel()

    Script.notifyEvent('MultiUDPSocket_OnNewSelectedInstance', selectedInstance)
    Script.notifyEvent("MultiUDPSocket_OnNewInstanceList", helperFuncs.createStringListBySize(#multiUDPSocket_Instances))

    Script.notifyEvent("MultiUDPSocket_OnNewStatusConnectionStatus", multiUDPSocket_Instances[selectedInstance].parameters.bindStatus)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusCurrentConnection", multiUDPSocket_Instances[selectedInstance].currentBindStatus)

    Script.notifyEvent("MultiUDPSocket_OnNewStatusPort", multiUDPSocket_Instances[selectedInstance].parameters.port)
    Script.notifyEvent("MultiUDPSocket_OnNewInterfaceList", multiUDPSocket_Instances[selectedInstance].interfaceList)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusInterface", multiUDPSocket_Instances[selectedInstance].parameters.interface)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusIP", multiUDPSocket_Instances[selectedInstance].parameters.ip)

    Script.notifyEvent("MultiUDPSocket_OnNewStatusReceiveTimeout", multiUDPSocket_Instances[selectedInstance].parameters.receiveTimeout)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusQueueSizeReceive", multiUDPSocket_Instances[selectedInstance].parameters.receiveQueueSize)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusDiscardIfFull", multiUDPSocket_Instances[selectedInstance].parameters.receiveDiscardIfFull)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusWarnOverruns", multiUDPSocket_Instances[selectedInstance].parameters.receiveWarnOverruns)

    Script.notifyEvent("MultiUDPSocket_OnNewDataToTransmit", multiUDPSocket_Instances[selectedInstance].dataToTransmit)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusPackFormat", multiUDPSocket_Instances[selectedInstance].parameters.packFormat)
    --Script.notifyEvent("MultiUDPSocket_OnNewLog", multiUDPSocket_Instances[selectedInstance].parameters.ip)
    Script.notifyEvent("MultiUDPSocket_OnNewEventToForwardList", multiUDPSocket_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiUDPSocket_Instances[selectedInstance].parameters.forwardEvents))
    Script.notifyEvent("MultiUDPSocket_OnNewEventToForward", '')
    eventToForward = ''

    Script.notifyEvent("MultiUDPSocket_OnNewStatusFlowConfigPriority", multiUDPSocket_Instances[selectedInstance].parameters.flowConfigPriority)
    Script.notifyEvent("MultiUDPSocket_OnNewStatusLoadParameterOnReboot", multiUDPSocket_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiUDPSocket_OnPersistentDataModuleAvailable", multiUDPSocket_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiUDPSocket_OnNewParameterName", multiUDPSocket_Instances[selectedInstance].parametersName)
  end
end
Timer.register(tmrMultiUDPSocket, "OnExpired", handleOnExpiredTmrMultiUDPSocket)

-- ********************* UI Setting / Submit Functions Start ********************

-- Function to register "On Resume" of the multiUDPSocket_Instances UI
local function pageCalled()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel() -- try to hide user specific content asap
  end
  tmrMultiUDPSocket:start()
  return ''
end
Script.serveFunction("CSK_MultiUDPSocket.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  if #multiUDPSocket_Instances >= instance then
    selectedInstance = instance
    _G.logger:fine("New selected instance = " .. tostring(selectedInstance))
    multiUDPSocket_Instances[selectedInstance].activeInUI = true
    Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
    tmrMultiUDPSocket:start()
  else
    _G.logger:warning(nameOfModule .. ": Selected instance does not exist.")
  end
end
Script.serveFunction("CSK_MultiUDPSocket.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  if multiUDPSocket_Instances then
    return #multiUDPSocket_Instances
  else
    return 0
  end
end
Script.serveFunction("CSK_MultiUDPSocket.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiUDPSocket_Instances, multiUDPSocket_Model.create(#multiUDPSocket_Instances+1))
  Script.deregister("CSK_MultiUDPSocket.OnNewValueToForward" .. tostring(#multiUDPSocket_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiUDPSocket.OnNewValueToForward" .. tostring(#multiUDPSocket_Instances) , handleOnNewValueToForward)

  Script.deregister("CSK_MultiUDPSocket.OnNewValueUpdate" .. tostring(#multiUDPSocket_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiUDPSocket.OnNewValueUpdate" .. tostring(#multiUDPSocket_Instances) , handleOnNewValueUpdate)
  setSelectedInstance(#multiUDPSocket_Instances)
end
Script.serveFunction('CSK_MultiUDPSocket.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiUDPSocket_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiUDPSocket_Instances[totalAmount])
    multiUDPSocket_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiUDPSocket()
end
Script.serveFunction('CSK_MultiUDPSocket.resetInstances', resetInstances)

local function selectEventToForwardViaUI(selection)

  if selection == "" then
    selectedEventToForward = ''
    _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is empty")
  else
    local _, pos = string.find(selection, '"EventToForward":"')
    if pos == nil then
      _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is nil")
      selectedEventToForward = ''
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      selectedEventToForward = string.sub(selection, pos+1, endPos-1)
      if ( selectedEventToForward == nil or selectedEventToForward == "" ) then
        _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is empty or nil")
        selectedEventToForward = ''
      else
        _G.logger:fine(nameOfModule .. ": Selected EventToForward: " .. tostring(selectedEventToForward))
        if ( selectedEventToForward ~= "-" ) then
          eventToForward = selectedEventToForward
          Script.notifyEvent("MultiUDPSocket_OnNewEventToForward", eventToForward)
        end
      end
    end
  end
end
Script.serveFunction("CSK_MultiUDPSocket.selectEventToForwardViaUI", selectEventToForwardViaUI)

local function addEventToForward(event)
  if ( event == '' ) then
    _G.logger:info(nameOfModule .. ": EventToForward cannot be added. Is empty")
  else
    multiUDPSocket_Instances[selectedInstance].parameters.forwardEvents[event] = event
    Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'addEvent', event)
    Script.notifyEvent("MultiUDPSocket_OnNewEventToForwardList", multiUDPSocket_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiUDPSocket_Instances[selectedInstance].parameters.forwardEvents))
  end
end
Script.serveFunction("CSK_MultiUDPSocket.addEventToForward", addEventToForward)

local function addEventToForwardViaUI()
  addEventToForward(eventToForward)
end
Script.serveFunction("CSK_MultiUDPSocket.addEventToForwardViaUI", addEventToForwardViaUI)

local function deleteEventToForward(event)
  multiUDPSocket_Instances[selectedInstance].parameters.forwardEvents[event] = nil
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'removeEvent', event)
  Script.notifyEvent("MultiUDPSocket_OnNewEventToForwardList", multiUDPSocket_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiUDPSocket_Instances[selectedInstance].parameters.forwardEvents))
end
Script.serveFunction("CSK_MultiUDPSocket.deleteEventToForward", deleteEventToForward)

local function deleteEventToForwardViaUI()
  if selectedEventToForward ~= '' then
    deleteEventToForward(selectedEventToForward)
  end
end
Script.serveFunction("CSK_MultiUDPSocket.deleteEventToForwardViaUI", deleteEventToForwardViaUI)

local function setEventToForward(value)
  eventToForward = value
  _G.logger:fine(nameOfModule .. ": Set eventToForward = " .. tostring(value))
end
Script.serveFunction("CSK_MultiUDPSocket.setEventToForward", setEventToForward)

local function setPort(port)
  _G.logger:fine(nameOfModule .. ": Set port of instance " .. tostring(selectedInstance) .. " to = " ..  tostring(port))
  multiUDPSocket_Instances[selectedInstance].parameters.port = port
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'port', port)
end
Script.serveFunction('CSK_MultiUDPSocket.setPort', setPort)

local function setIP(ip)
  _G.logger:fine(nameOfModule .. ": Set IP for instance " .. tostring(selectedInstance) .. " to transmit data to = " ..  tostring(ip))
  multiUDPSocket_Instances[selectedInstance].parameters.ip = ip
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'ip', ip)
end
Script.serveFunction('CSK_MultiUDPSocket.setIP', setIP)

local function setInterface(interface)
  _G.logger:fine(nameOfModule .. ": Set interface of instance " .. tostring(selectedInstance) .. " to = " ..  tostring(interface))
  multiUDPSocket_Instances[selectedInstance].parameters.interface = interface
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'interface', interface)
end
Script.serveFunction('CSK_MultiUDPSocket.setInterface', setInterface)

local function setReceiveTimeout(time)
  _G.logger:fine(nameOfModule .. ": Set receive timeout of instance " .. tostring(selectedInstance) .. " to = " ..  tostring(time))
  multiUDPSocket_Instances[selectedInstance].parameters.receiveTimeout = time
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'receiveTimeout', time)
end
Script.serveFunction('CSK_MultiUDPSocket.setReceiveTimeout', setReceiveTimeout)

local function setReceiveQueueSize(size)
  _G.logger:fine(nameOfModule .. ": Set receive queue size of instance " .. tostring(selectedInstance) .. " to = " ..  tostring(size))
  multiUDPSocket_Instances[selectedInstance].parameters.receiveQueueSize = size
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'receiveQueueSize', size)
end
Script.serveFunction('CSK_MultiUDPSocket.setReceiveQueueSize', setReceiveQueueSize)

local function setReceiveDiscardIfFull(status)
  _G.logger:fine(nameOfModule .. ": Set 'receive discard if full' of instance " .. tostring(selectedInstance) .. " to = " ..  tostring(status))
  multiUDPSocket_Instances[selectedInstance].parameters.receiveDiscardIfFull = status
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'receiveDiscardIfFull', status)
end
Script.serveFunction('CSK_MultiUDPSocket.setReceiveDiscardIfFull', setReceiveDiscardIfFull)

local function setReceiveWarnOverruns(status)
  _G.logger:fine(nameOfModule .. ": Set 'receive warn overruns' of instance " .. tostring(selectedInstance) .. " to = " ..  tostring(status))
  multiUDPSocket_Instances[selectedInstance].parameters.receiveWarnOverruns = status
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'receiveWarnOverruns', status)
end
Script.serveFunction('CSK_MultiUDPSocket.setReceiveWarnOverruns', setReceiveWarnOverruns)

local function setConnectionStatus(status)
  multiUDPSocket_Instances[selectedInstance].parameters.bindStatus = status
  _G.logger:fine(nameOfModule .. ": Set connection status = " .. tostring(status))
  if status then
    Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'connect')
  else
    Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'disconnect')
  end
end
Script.serveFunction('CSK_MultiUDPSocket.setConnectionStatus', setConnectionStatus)

local function setDataToTransmit(data)
_G.logger:fine(nameOfModule .. ": Preset data to send = " .. tostring(data))
multiUDPSocket_Instances[selectedInstance].dataToTransmit = data
end
Script.serveFunction('CSK_MultiUDPSocket.setDataToTransmit', setDataToTransmit)

local function setPackFormat(format)
  multiUDPSocket_Instances[selectedInstance].parameters.packFormat = format
end
Script.serveFunction('CSK_MultiUDPSocket.setPackFormat', setPackFormat)

local function transmitData(data)
  if multiUDPSocket_Instances[selectedInstance].parameters.packFormat ~= '' then
    data = string.pack(multiUDPSocket_Instances[selectedInstance].parameters.packFormat, data)
  end
  _G.logger:fine(nameOfModule .. ": Send data = " .. data)
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'transmit', data)
end
Script.serveFunction('CSK_MultiUDPSocket.transmitData', transmitData)

local function transmitDataViaUI()
  transmitData(multiUDPSocket_Instances[selectedInstance].dataToTransmit)
end
Script.serveFunction('CSK_MultiUDPSocket.transmitDataViaUI', transmitDataViaUI)

local function receiveViaUI()
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'receive')
end
Script.serveFunction('CSK_MultiUDPSocket.receiveViaUI', receiveViaUI)

--- Function to update processing parameters within the processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', selectedInstance, 'value', multiUDPSocket_Instances[selectedInstance].parameters.value)
end

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_MultiUDPSocket.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for i = 1, #multiUDPSocket_Instances do
    multiUDPSocket_Instances[i].parameters.registeredEvent = ''
    Script.notifyEvent('MultiUDPSocket_OnNewImageProcessingParameter', i, 'deregisterFromEvent', '')
    Script.notifyEvent('MultiUDPSocket_OnNewStatusRegisteredEvent', '')
  end
end
Script.serveFunction('CSK_MultiUDPSocket.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters(instanceNo)
  if instanceNo <= #multiUDPSocket_Instances then
    return helperFuncs.json.encode(multiUDPSocket_Instances[instanceNo].parameters)
  else
    return ''
  end
end
Script.serveFunction('CSK_MultiUDPSocket.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiUDPSocket_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiUDPSocket.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if multiUDPSocket_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiUDPSocket_Instances[selectedInstance].parameters), multiUDPSocket_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3  then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiUDPSocket_Instances[selectedInstance].parametersName, multiUDPSocket_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiUDPSocket_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiUDPSocket_Instances[selectedInstance].parametersName, multiUDPSocket_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:fine(nameOfModule .. ": Send MultiUDPSocket parameters with name '" .. multiUDPSocket_Instances[selectedInstance].parametersName .. "' to PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData Module not available.")
  end
end
Script.serveFunction("CSK_MultiUDPSocket.sendParameters", sendParameters)

local function loadParameters()
  if multiUDPSocket_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiUDPSocket_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiUDPSocketObject " .. tostring(selectedInstance) .. " from PersistentData module.")
      multiUDPSocket_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)
      updateProcessingParameters()

      tmrMultiUDPSocket:start()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      tmrMultiUDPSocket:start()
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    tmrMultiUDPSocket:start()
    return false
  end
end
Script.serveFunction("CSK_MultiUDPSocket.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiUDPSocket_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:fine("Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("MultiUDPSocket_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_MultiUDPSocket.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  multiUDPSocket_Instances[selectedInstance].parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("MultiUDPSocket_OnNewStatusFlowConfigPriority", multiUDPSocket_Instances[selectedInstance].parameters.flowConfigPriority)
end
Script.serveFunction('CSK_MultiUDPSocket.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
    -- Check if CSK_PersistentData version is > 1.x.x
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      for j = 1, #multiUDPSocket_Instances do
        multiUDPSocket_Instances[j].persistentModuleAvailable = false
      end
    else
      -- Check if CSK_PersistentData version is >= 3.0.0
      if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
        local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
        -- Check for amount if instances to create
        if totalInstances then
          local c = 2
          while c <= totalInstances do
            addInstance()
            c = c+1
          end
        end
      end

      if not multiUDPSocket_Instances then
        return
      end

      for i = 1, #multiUDPSocket_Instances do
        local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

        if parameterName then
          multiUDPSocket_Instances[i].parametersName = parameterName
          multiUDPSocket_Instances[i].parameterLoadOnReboot = loadOnReboot
        end

        if multiUDPSocket_Instances[i].parameterLoadOnReboot then
          setSelectedInstance(i)
          loadParameters()
        end
      end
      Script.notifyEvent('MultiUDPSocket_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()

    for i = 1, #multiUDPSocket_Instances do
      multiUDPSocket_Instances[i].parameters.active = false
      multiUDPSocket_Instances[i].status = 'PORT_NOT_ACTIVE'
      Script.notifyEvent('MultiUDPSocket_OnNewProcessingParameter', i, 'active', false)
    end
    pageCalled()
  end
end
Script.serveFunction('CSK_MultiUDPSocket.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

