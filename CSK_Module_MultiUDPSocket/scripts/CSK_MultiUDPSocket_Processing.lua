---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Communication/MultiUDPSocket/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiUDPSocket'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiUDPSocketInstanceNumber = scriptParams:get('multiUDPSocketInstanceNumber') -- number of this instance
local multiUDPSocketInstanceNumberString = tostring(multiUDPSocketInstanceNumber) -- number of this instance as string

Script.serveEvent("CSK_MultiUDPSocket.OnNewData" .. multiUDPSocketInstanceNumberString, "MultiUDPSocket_OnNewData" .. multiUDPSocketInstanceNumberString, 'binary')
-- Event to forward content from this thread to Controler to show e.g. on UI
Script.serveEvent("CSK_MultiUDPSocket.OnNewValueToForward".. multiUDPSocketInstanceNumberString, "MultiUDPSocket_OnNewValueToForward" .. multiUDPSocketInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiUDPSocket.OnNewValueUpdate" .. multiUDPSocketInstanceNumberString, "MultiUDPSocket_OnNewValueUpdate" .. multiUDPSocketInstanceNumberString, 'int, string, auto, int:?')

local udpHandle = UDPSocket.create() -- Handle of UDP socket

local log = {} -- Log of UDP socket communication

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false

processingParams.bindStatus = scriptParams:get('bindStatus')
processingParams.interface = scriptParams:get('interface')
processingParams.ip = scriptParams:get('ip')
processingParams.port = scriptParams:get('port')
processingParams.receiveQueueSize = scriptParams:get('receiveQueueSize')
processingParams.receiveTimeout = scriptParams:get('receiveTimeout')
processingParams.receiveDiscardIfFull = scriptParams:get('receiveDiscardIfFull')
processingParams.receiveWarnOverruns = scriptParams:get('receiveWarnOverruns')

processingParams.currentBindStatus = false
processingParams.dataToTransmit = ''

processingParams.forwardEvents = {}

--- Function to notify latest log messages, e.g. to show on UI
local function sendLog()
  if #log == 100 then
    table.remove(log, 100)
  end
  local tempLog = ''
  for i=1, #log do
    tempLog = tempLog .. tostring(log[i]) .. '\n'
  end
  if processingParams.activeInUI then
    Script.notifyEvent("MultiUDPSocket_OnNewValueToForward" .. multiUDPSocketInstanceNumberString, 'MultiUDPSocket_OnNewLog', tostring(tempLog))
  end
end

local function handleTransmitData(data)
  _G.logger:fine(nameOfModule .. ": Try to send data on instance No. " .. multiUDPSocketInstanceNumberString)
  local numberOfBytesTransmitted

  if processingParams.currentConnectionStatus ~= nil then
    numberOfBytesTransmitted = udpHandle:transmit(processingParams.ip, processingParams.port, data)

    table.insert(log, 1, DateTime.getTime() .. ' - SENT = ' .. tostring(data) .. ' to ' .. tostring(processingParams.ip) .. ':' .. tostring(processingParams.port))

    sendLog()

    if numberOfBytesTransmitted == 0 then
      _G.logger:warning(nameOfModule .. ": UDP transmit failed")
    else
      _G.logger:fine(nameOfModule .. ": Sent: " .. tostring(data) .. ' to ' .. tostring(processingParams.ip) .. ':' .. tostring(processingParams.port) .. ', size: ' .. tostring(numberOfBytesTransmitted) .. 'Bytes')
    end
  else
    _G.logger:warning(nameOfModule .. ": No UDP connection.")
  end

  return numberOfBytesTransmitted

end
Script.serveFunction("CSK_MultiUDPSocket.transmitData"..multiUDPSocketInstanceNumberString, handleTransmitData, 'binary:1', 'int:1')

--- Function only used to forward the content from events to the served function.
--- This is only needed, as deregistering from the event would internally release the served function and would make it uncallable from external.
---@param data binary Data to transmit
local function tempHandleTransmitData(data)
  handleTransmitData(data)
end

--- Function to receive incoming UDP data
---@param data binary The received data packet
---@param ipAddress string The peer address the data was received from
---@param port int The peer port the data was received from
local function handleOnReceive(data, ipAddress, port)

  _G.logger:fine(nameOfModule .. ": Received data on instance No. " .. multiUDPSocketInstanceNumberString .. ' from ' .. tostring(ipAddress) .. ':' .. tostring(port) .. " = " .. tostring(data))

  -- Forward data to other modules
  Script.notifyEvent("MultiUDPSocket_OnNewData" .. multiUDPSocketInstanceNumberString, data)

  table.insert(log, 1, DateTime.getTime() .. ' - RECV = ' .. tostring(data) .. ' from ' .. tostring(ipAddress) .. ':' .. tostring(port))

  sendLog()

end

local function receive()
  local data, ipAddress, port = udpHandle:receive(processingParams.receiveTimeout)
  if data then

    -- Forward data to other modules
    Script.notifyEvent("MultiUDPSocket_OnNewData" .. multiUDPSocketInstanceNumberString, data)
    table.insert(log, 1, DateTime.getTime() .. ' - RECV = ' .. tostring(data) .. ' from ' .. tostring(ipAddress) .. ':' .. tostring(port))
    sendLog()
  else
    _G.logger:fine(nameOfModule .. ": Received no data on instance No. " .. multiUDPSocketInstanceNumberString)
    table.insert(log, 1, DateTime.getTime() .. ' No data received.')
    sendLog()
  end
end

--- Function to update the UDP socket connection with new setup
local function updateSetup()

  if processingParams.bindStatus then
    udpHandle:setReceiveQueueSize(processingParams.receiveQueueSize, processingParams.receiveDiscardIfFull, processingParams.receiveWarnOverruns)
    udpHandle:setInterface(processingParams.interface)
    local suc = udpHandle:bind(processingParams.port)
    processingParams.currentConnectionStatus = suc
    Script.notifyEvent("MultiUDPSocket_OnNewValueUpdate" .. multiUDPSocketInstanceNumberString, multiUDPSocketInstanceNumber, 'currentBindStatus', suc)
  else
    udpHandle:unbind()
    processingParams.currentConnectionStatus = false
    Script.notifyEvent("MultiUDPSocket_OnNewValueUpdate" .. multiUDPSocketInstanceNumberString, multiUDPSocketInstanceNumber, 'currentBindStatus', false)
  end
end

--- Function to handle updates of processing parameters from Controller
---@param multiUDPSocketNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param value2 auto 2nd value of parameter to update
local function handleOnNewProcessingParameter(multiUDPSocketNo, parameter, value, value2)

  if multiUDPSocketNo == multiUDPSocketInstanceNumber then -- set parameter only in selected script
    if value then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiUDPSocketInstanceNo." .. tostring(multiUDPSocketNo) .. " to value = " .. tostring(value))
    else
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiUDPSocketInstanceNo." .. tostring(multiUDPSocketNo))
    end

    if parameter == 'connect' then
      processingParams.bindStatus = true
      updateSetup()

    elseif parameter == 'disconnect' then
      processingParams.bindStatus = false
      updateSetup()

    elseif parameter == 'transmit' then
      handleTransmitData(value)

    elseif parameter == 'receive' then
      receive()

    elseif parameter == 'addEvent' then
      if processingParams.forwardEvents[value] then
        Script.deregister(processingParams.forwardEvents[value], tempHandleTransmitData)
      end
      processingParams.forwardEvents[value] = value

      local suc = Script.register(value, tempHandleTransmitData)
      _G.logger:fine(nameOfModule .. ": Added event to forward content = " .. value .. " on instance No. " .. multiUDPSocketInstanceNumberString)
      _G.logger:fine(nameOfModule .. ": Success to register to event = " .. tostring(suc) .. " on instance No. " .. multiUDPSocketInstanceNumberString)

    elseif parameter == 'removeEvent' then
      processingParams.forwardEvents[value] = nil
      local suc = Script.deregister(value, tempHandleTransmitData)
      _G.logger:fine(nameOfModule .. ": Deleted event = " .. tostring(value) .. " on instance No. " .. multiUDPSocketInstanceNumberString)
      _G.logger:fine(nameOfModule .. ": Success to deregister of event = " .. tostring(suc) .. " on instance No. " .. multiUDPSocketInstanceNumberString)

    elseif parameter == 'clearAll' then
      for forwardEvent in pairs(processingParams.forwardEvents) do
        processingParams.forwardEvents[forwardEvent] = nil
        Script.deregister(forwardEvent, tempHandleTransmitData)
      end

    else
      processingParams[parameter] = value
      updateSetup()
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiUDPSocket.OnNewProcessingParameter", handleOnNewProcessingParameter)

udpHandle:register('OnReceive', handleOnReceive)
