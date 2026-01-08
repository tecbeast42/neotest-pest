local logger = require("neotest.logging")

local M = {}
local separator = "::"

---Normalize a Pest test name to its base form
---Strips "it " prefix, arrow context (describe blocks), and dataset parameters
---@param name string The raw test name from JUnit XML
---@return string The normalized base name
local function normalize_test_name(name)
    local normalized = name

    -- Step 1: Remove "it " prefix (Pest's it() function)
    normalized = string.gsub(normalized, "^it (.*)", "%1")

    -- Step 2: Handle arch preset tests specially
    -- "preset → security" → "security"
    -- "preset → laravel → ignoring..." → "laravel"
    if string.match(normalized, "^preset [→%-]+> ") then
        -- Extract the method after "preset → "
        local after_preset = string.gsub(normalized, "^preset [→%-]+> ", "")
        -- Get just the first method (before any subsequent arrows)
        normalized = string.gsub(after_preset, " [→%-]+> .*$", "")
        normalized = string.gsub(normalized, " → .*$", "")
    else
        -- Step 3: Remove describe block context (arrow patterns) for non-arch tests
        -- Handles: "describe -> test" and "describe → test" (unicode arrow)
        normalized = string.gsub(normalized, " [%-]+> .*$", "")
        normalized = string.gsub(normalized, " → .*$", "")
    end

    -- Step 4: Remove dataset parameters
    -- Handles: "test with 'value'" and "test with \"value\""
    normalized = string.gsub(normalized, " with '.-'$", "")
    normalized = string.gsub(normalized, ' with ".-"$', "")

    -- Step 5: Trim trailing whitespace
    normalized = string.gsub(normalized, "%s+$", "")

    return normalized
end

---Generate multiple ID variants for fuzzy matching
---@param file string The test file path
---@param name string The raw test name
---@return table Array of possible IDs, ordered by specificity
local function generate_id_variants(file, name)
    local variants = {}

    -- Most specific: full normalized name
    local normalized = normalize_test_name(name)
    table.insert(variants, file .. separator .. normalized)

    -- Try just the first part before any arrow (handles multi-level describes)
    local first_part = string.match(name, "^([^%-→]+)")
    if first_part then
        first_part = string.gsub(first_part, "^it (.*)", "%1")
        first_part = string.gsub(first_part, "%s+$", "") -- trim trailing spaces
        if first_part ~= normalized and first_part ~= "" then
            table.insert(variants, file .. separator .. first_part)
        end
    end

    return variants
end

-- Export for testing
M.normalize_test_name = normalize_test_name
M.generate_id_variants = generate_id_variants

---Generate an id which we can use to match Treesitter queries and Pest tests
---@param position neotest.Position The position to return an ID for
---@return string
M.make_test_id = function(position)
    -- Treesitter ID needs to look like 'tests/Unit/ColsHelperTest.php::it returns the proper format'
    -- which means it should include position.path. However, as of PHPUnit 10, position.path
    -- includes the root directory of the project, which breaks the ID matching.
    -- As such, we need to remove the root directory from the path.
    local path = string.sub(position.path, string.len(vim.loop.cwd()) + 2)

    local id = path .. separator .. position.name
    logger.debug("Path to test file:", { position.path })
    logger.debug("Treesitter id:", { id })

    return id
end

---Recursively iterate through a deeply nested table to obtain specified keys
---@param data_table table
---@param key string
---@param output_table table
---@return table
local function iterate_key(data_table, key, output_table)
    if type(data_table) == "table" then
        for k, v in pairs(data_table) do
            if key == k then
                table.insert(output_table, v)
            end
            iterate_key(v, key, output_table)
        end
    end
    return output_table
end

---Extract the failure messages from the tests
---@param tests table,
---@return boolean,table,table
local function errors_or_fails(tests)
    local failed = false
    local errors = {}
    local fails = {}

    iterate_key(tests, "error", errors)
    iterate_key(tests, "failure", fails)

    if #errors > 0 or #fails > 0 then
        failed = true
    end

    return failed, errors, fails
end

local function make_short_output(test_attr, status)
    return string.upper(status) .. " | " .. test_attr.name
end

---Extract line number from error message or stack trace
---@param message string The error/failure message
---@param test_file string The test file path to match
---@return number|nil The line number (0-indexed for neotest) or nil if not found
local function extract_error_line(message, test_file)
    if not message or not test_file then
        return nil
    end

    -- Normalize test_file for matching (remove leading paths)
    local file_pattern = string.gsub(test_file, "^.*/", "")
    file_pattern = string.gsub(file_pattern, "%.", "%%.")

    -- Pattern 1: Direct file:line reference in stack trace
    -- Example: "tests/Feature/UserTest.php:39"
    for line in string.gmatch(message, test_file .. ":(%d+)") do
        return tonumber(line) - 1 -- Convert to 0-indexed
    end

    -- Pattern 2: Match just filename:line
    for line in string.gmatch(message, file_pattern .. ":(%d+)") do
        return tonumber(line) - 1 -- Convert to 0-indexed
    end

    -- Pattern 3: PHPUnit/Pest stack trace format
    -- Look for first occurrence of any .php:line in test file
    for file, line in string.gmatch(message, "([^\n:]+%.php):(%d+)") do
        if string.find(file, file_pattern) then
            return tonumber(line) - 1 -- Convert to 0-indexed
        end
    end

    return nil
end

-- Export for testing
M.extract_error_line = extract_error_line

---Make the outputs for a given test
---@param test table
---@param output_file string
---@return string, table
local function make_outputs(test, output_file)
    logger.debug("Pre-output test:", test)
    local test_attr = test["_attr"] or test[1]["_attr"]

    -- Use normalization to handle Pest v4 describe blocks and arrow patterns
    local name = normalize_test_name(test_attr.name)

    -- Extract just the file path from test_attr.file (Pest includes "file::testname" format)
    local file_path = string.gsub(test_attr.file, "(.*)" .. separator .. ".*", "%1")
    -- If no :: was found, use the original file attribute
    if file_path == test_attr.file then
        file_path = test_attr.file
    end

    -- Build test ID: file::normalized_name
    local test_id = file_path .. separator .. name
    logger.debug("Pest id:", { test_id })
    logger.debug("Original name:", { test_attr.name })
    logger.debug("Normalized name:", { name })

    local test_output = {
        status = "passed",
        short = make_short_output(test_attr, "passed"),
        output_file = output_file,
    }

    local test_failed, errors, fails = errors_or_fails(test)

    if test_failed then
        logger.debug("test_failed:", { test_failed, errors, fails })
        test_output.status = "failed"

        if #errors > 0 then
            local message = errors[1][1]
            local line = extract_error_line(message, test_attr.file)
            test_output.short = make_short_output(test_attr, "error") .. "\n\n" .. message
            test_output.errors = {
                {
                    message = message,
                    line = line,
                },
            }
        elseif #fails > 0 then
            local message = fails[1][1]
            local line = extract_error_line(message, test_attr.file)
            test_output.short = make_short_output(test_attr, "failed") .. "\n\n" .. message
            test_output.errors = {
                {
                    message = message,
                    line = line,
                }
            }
        end
    end

    if test['skipped'] then
        test_output.status = "skipped"
        test_output.short = make_short_output(test_attr, "skipped")
    end

    logger.debug("test_output:", test_output)

    return test_id, test_output
end

---Iterate through test results and create a table of test IDs and outputs
---@param tests table
---@param output_file string
---@param output_table table
---@return table
local function iterate_test_outputs(tests, output_file, output_table)
    for i = 1, #tests, 1 do
        if #tests[i] == 0 then
            local test_id, test_output = make_outputs(tests[i], output_file)
            output_table[test_id] = test_output
        else
            iterate_test_outputs(tests[i], output_file, output_table)
        end
    end
    return output_table
end

---Get the test results from the parsed xml with optional fallback matching
---@param parsed_xml_output table
---@param output_file string
---@param discovered_ids? table Optional set of discovered IDs for fallback matching
---@return neotest.Result[]
M.get_test_results = function(parsed_xml_output, output_file, discovered_ids)
    local tests = iterate_key(parsed_xml_output, "testcase", {})
    local results = iterate_test_outputs(tests, output_file, {})

    -- If discovered_ids provided, try fallback matching for unmatched results
    if discovered_ids and type(discovered_ids) == "table" then
        local to_remap = {}

        -- Find results that don't match any discovered ID
        for id, result in pairs(results) do
            if not discovered_ids[id] then
                table.insert(to_remap, { id = id, result = result })
            end
        end

        -- Try to match unmatched results using ID variants
        for _, item in ipairs(to_remap) do
            -- Extract file and name from the ID
            local file, name = string.match(item.id, "(.+)" .. separator .. "(.+)")
            if file and name then
                -- Generate variants for this result
                local variants = generate_id_variants(file, name)
                for _, variant in ipairs(variants) do
                    if discovered_ids[variant] and not results[variant] then
                        -- Found a match - remap the result
                        results[variant] = item.result
                        results[item.id] = nil
                        logger.debug("Matched via variant:", { original = item.id, matched = variant })
                        break
                    end
                end
            end
        end
    end

    return results
end

return M
