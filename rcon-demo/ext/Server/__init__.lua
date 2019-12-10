-- This will register a new "hello" rcon command that will be available for logged in rcon admins.
-- Registering a command requires passing its name, registration flags, and a callback.

-- Available flags:
-- RemoteCommandFlag.None
-- RemoteCommandFlag.RequiresLogin
-- RemoteCommandFlag.DisableOnRanked
-- RemoteCommandFlag.ReadOnlyOnRanked
-- RemoteCommandFlag.DisableAfterStartup
-- RemoteCommandFlag.Hidden

-- Flags can be combined using a bitwise OR operator.
-- Example: RemoteCommandFlag.RequiresLogin | RemoteCommandFlag.DisableAfterStartup

local commandHandle = RCON:RegisterCommand('hello', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
	-- This function will get called when the command gets used and print the message below.
	print('Got "hello" RCON command!')

	-- The first argument is the name of the command (in this case 'hello').
	
	-- The second argument is a table of all the arguments passed to the command.
	-- For example, if an admin executes "hello 1 2 3" then it will be a table containing
	-- three values: { '1', '2', '3' }
	
	-- The third argument is a bool representing whether the user who executed this command
	-- was logged in or not. This is not relevant for this specific command, as the flags 
	-- we used when registering dictate that this can only be executed by logged in users.
	-- However, in cases where you want to register a publicly accessible command, this could
	-- be used to selectively return information based on whether it's being accessed by an 
	-- admin or an unauthorized third party.

	-- The return value of this function needs to be a table of values to send back to the
	-- rcon client. Successful operations are usually prefixed by the "OK" value, as 
	-- illustrated below. You can refer to the BF3 server admin guide for reference of
	-- what other commands return.
	return { 'OK', 'Goodbye!' }
end)

-- The return value is a handle that can be used to deregister it at a later time, as illustrated below.
-- RCON:DeregisterCommand(commandHandle)

-- Using the RCON library we can also execute RCON commands ourselves, as illustrated below.
Events:Subscribe('Engine:Init', function()
	-- We listen for this event here to give the engine an opportunity to finish initializing.

	-- Now we send an RCON command and get back its result and print it.
	local result = RCON:SendCommand('hello')
	print(result)

	-- The "result" variable will be a table of strings. In this case: { 'OK', 'Goodbye!' }
	-- Keep in mind that you can also execute other commands (like "serverInfo") which are
	-- provided by default or registered by other mods.

	-- You can also specify arguments to send with a command by providing them in a table
	-- as a second argument to the function:
	-- RCON:SendCommand('hello', { '1', '2', '3' })
end)
