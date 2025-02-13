--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('Communication.MultiUDPSocket.helper.checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding MultiUDPSocket_Model
-- Check this script regarding MultiUDPSocket_Model parameters and functions
local multiUDPSocket_Model = require('Communication/MultiUDPSocket/MultiUDPSocket_Model')

local multiUDPSocket_Instances = {} -- Handle all instances

-- Load script to communicate with the MultiUDPSocket_Model UI
-- Check / edit this script to see/edit functions which communicate with the UI
local multiUDPSocketController = require('Communication/MultiUDPSocket/MultiUDPSocket_Controller')

if _G.availableAPIs.default and _G.availableAPIs.specific then
  --local setInstanceHandle = require('Communication/MultiUDPSocket/FlowConfig/MultiUDPSocket_FlowConfig')
  table.insert(multiUDPSocket_Instances, multiUDPSocket_Model.create(1))
  multiUDPSocketController.setMultiUDPSocket_Instances_Handle(multiUDPSocket_Instances) -- share handle of instances
  --setInstanceHandle(multiUDPSocket_Instances)
else
  _G.logger:warning("CSK_MultiUDPSocket: Relevant CROWN(s) not available on device. Module is not supported...")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  multiUDPSocketController.setMultiUDPSocket_Model_Handle(multiUDPSocket_Model) -- share handle of model

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable parameterLoadOnReboot of multiUDPSocket_Instances)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this
  --[[
  CSK_MultiUDPSocket.setSelectedInstance(1)
  CSK_MultiUDPSocket.setInterface('ETH1')
  CSK_MultiUDPSocket.setIP('192.168.0.99')
  CSK_MultiUDPSocket.setPort(23)
  CSK_MultiUDPSocket.setConnectionStatus(true)

  CSK_MultiUDPSocket.transmitData(data)
  -- or register to event to forward its data on UDP socket 
  CSK_MultiUDPSocket.addEventToForward('CSK_OtherModule.OnNewData') 
  ]]
  ----------------------------------------------------------------------------------------

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiUDPSocket.setSelectedInstance(1)
  end
  CSK_MultiUDPSocket.pageCalled()

end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************