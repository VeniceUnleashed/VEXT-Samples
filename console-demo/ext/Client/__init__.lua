-- Register the "hello" client-side console command.
-- Requires passing a name, description, and a callback.

-- Registered commands will be available via the client-side console as <modname>.<command>
-- where <modname> is the name of the mod folder and <command> is the provided command name.
-- In this example, the command will be available as "console-demo.hello".

local command = Console:Register('hello', 'Hello world command!', function(args)
	-- This function will get called when a user executes this console command.

	-- It takes a single argument, which is a table of all arguments passed by the user
	-- when executing this command. For example, if a user executes "hello 1 2 3" then
	-- it will be a table containing three values: { '1', '2', '3' }

	-- This function can optionally return a string, which will be printed to the user's
	-- console after execution.

	-- Different characters can be used to emphasize text in the printed output:
	-- Orange bold text: **word**
	-- Blue text: *word*
	-- Yellow text: _word_
	
	return 'Hello **world**!'
end)

-- The "Register" call returns a ConsoleCommand instance
-- (see https://modders.link/wiki/doku.php?id=vext:ref:vu:cls:clt:consolecommand).
-- This can be used to deregister this command at a later time, as illustrated below.
-- Console:Deregister(command)
-- or
-- command:Deregister()
