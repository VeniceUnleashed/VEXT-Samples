-- This simple mod demostrates how to interact with VEXT's integrated SQLite db.
-- Reference available at https://modders.link/wiki/doku.php?id=vext:ref:vu:lib:srv:sql

Events:Subscribe('Extension:Loaded', function()
	-- Check the the output in the server's console.

	-- Create and open a database at Mods/simple-sqlite/mod.db.
	-- If for any reason this cannot be created/opened, Open() fails
    if not SQL:Open() then
        return
    end
 
    -- Create our table.
    local query = [[
        CREATE TABLE IF NOT EXISTS test_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text_value TEXT,
            int_value INTEGER,
            real_value REAL,
            blob_value BLOB,
            some_null_value BLOB,
            not_null_text TEXT NOT NULL
        )
    ]]
 
    if not SQL:Query(query) then
        print('Failed to execute query: ' .. SQL:Error())
        return
    end
 
    -- Insert some test data.
    query = 'INSERT INTO test_table (text_value, int_value, real_value, blob_value, some_null_value, not_null_text) VALUES (?, ?, ?, ?, ?, ?)'
 
    if not SQL:Query(query, 'My Text', 1337, 420.69, SQL:Blob('My Blob'), nil, 'My Not Null Text') then
        print('Failed to execute query: ' .. SQL:Error())
        return
    end
 
    if not SQL:Query(query, 'My Text 2', 13372, 420.692, SQL:Blob('My Blob 2'), nil, 'My Not Null Text 2') then
        print('Failed to execute query: ' .. SQL:Error())
        return
    end
 
    print('Inserted data. Insert ID: ' .. tostring(SQL:LastInsertId()) .. '. Rows affected: ' .. tostring(SQL:AffectedRows()))
 
    -- Test the NOT NULL constraint.
    if not SQL:Query(query, 'My Text', 1337, 420.69, SQL:Blob('My Blob'), nil, nil) then
        -- Error should be "NOT NULL constraint failed: test_table.not_null_text"
        print('Failed to execute query: ' .. SQL:Error())
    end
 
    -- Fetch all rows from the table.
    results = SQL:Query('SELECT * FROM test_table')
 
    if not results then
        print('Failed to execute query: ' .. SQL:Error())
        return
    end
 
    -- Print the fetched rows.
    for _, row in pairs(results) do
        print('Got row:')
        print(row)
    end
end)
