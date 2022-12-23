--[[

██╗░░░██╗███████╗██████╗░░██████╗██╗███████╗██╗░░░██╗
██║░░░██║██╔════╝██╔══██╗██╔════╝██║██╔════╝╚██╗░██╔╝
╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░██║█████╗░░░╚████╔╝░
░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██║██╔══╝░░░░╚██╔╝░░
░░╚██╔╝░░███████╗██║░░██║██████╔╝██║██║░░░░░░░░██║░░░
░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░░░░░░░╚═╝░░░

████████╗███████╗░█████╗░██╗░░██╗███╗░░██╗░█████╗░██╗░░░░░░█████╗░░██████╗░██╗███████╗░██████╗
╚══██╔══╝██╔════╝██╔══██╗██║░░██║████╗░██║██╔══██╗██║░░░░░██╔══██╗██╔════╝░██║██╔════╝██╔════╝
░░░██║░░░█████╗░░██║░░╚═╝███████║██╔██╗██║██║░░██║██║░░░░░██║░░██║██║░░██╗░██║█████╗░░╚█████╗░
░░░██║░░░██╔══╝░░██║░░██╗██╔══██║██║╚████║██║░░██║██║░░░░░██║░░██║██║░░╚██╗██║██╔══╝░░░╚═══██╗
░░░██║░░░███████╗╚█████╔╝██║░░██║██║░╚███║╚█████╔╝███████╗╚█████╔╝╚██████╔╝██║███████╗██████╔╝
░░░╚═╝░░░╚══════╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░╚══════╝░╚════╝░░╚═════╝░╚═╝╚══════╝╚═════╝░ July, 2020


Written by:
	Mememoxzine

Contacts:
	Mememoxzine#9290
	discord.gg/6EvghDCzhh

Date written:
	23/12/2022 9:52 GMT+7

]]

local config = {
	DEBUG_MODE = false
}

local _yieldPrioritise = {
	new = function()
		local __self = {
			SetPriorities = {},
			NonYieldFunctions = {},
			_searchForNonYielding = function(self, referenceFunc) -- Search for functions that won't yield
				local yielding = true

				for i, func in pairs(self.NonYieldFunctions) do
					if func == referenceFunc then
						yielding = false
					end
				end

				return yielding
			end,
			AccordPriorities = function(self, priority, func, yielding) -- Accord each functions to their specified priorities
				assert(priority, "[1] YieldPriority is not set!")
				assert(func, "[2] Function is not set!")
				assert(type(self) == "table", "[3] 'self' cannot be found, please call the method :AccordPriorities instead")
				
				if not self.SetPriorities[priority] then
					self.SetPriorities[priority] = func
				else
					local prev = self.SetPriorities[priority]

					if type(prev) == "table" then
						self.SetPriorities[priority][#self.SetPriorities[priority] + 1] = func
					elseif type(prev) == "function" then
						self.SetPriorities[priority] = {
							prev,
							func
						}
					end
					
					print(self.SetPriorities[priority])
				end

				if (not yielding) == false then
					self.NonYieldFunctions[#self.NonYieldFunctions + 1] = func
				end
			end,
			StartPriorities = function(self)
				assert(type(self) == "table", "[3] 'self' cannot be found, please call the method :StartPriorities instead")
				
				for global_i, _ in pairs(self.SetPriorities) do
					local priorities = self.SetPriorities[global_i]

					if type(priorities) == "table" then
						for i, _function in pairs(priorities) do
							local isNonYielding = self:_searchForNonYielding(_function)
							
							if isNonYielding then
								task.spawn(function()
									_function()
								end)
							else
								_function()
							end
						end
					elseif type(priorities) == "function" then
						local isNonYielding = self:_searchForNonYielding(priorities)
						
						if isNonYielding then
							task.spawn(function()
								priorities()
							end)
						else
							priorities()
						end
					end
				end
			end,
		}

		return __self
	end
}

return _yieldPrioritise
