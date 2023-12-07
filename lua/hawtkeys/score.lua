local config = require("hawtkeys")
local keyboardLayouts = require("hawtkeys.keyboards")
local tsSearch = require("hawtkeys.ts")
local utils = require("hawtkeys.utils")

---@param key1 string
---@param key2 string
---@param str string
---@param layout string
---@return integer
local function key_score(key1, key2, str, layout)
    local keyboard = keyboardLayouts[layout]

    if keyboard == nil then
        error("Invalid keyboard layout")
    end

    if keyboard[key1] and keyboard[key2] then
        local key1Data = keyboard[key1]
        local key2Data = keyboard[key2]


        -- The higher the score the better
        local doubleCharBonus = (key1 == key2) and 3 or 0
        local sameFingerPenalty = (key1Data.finger == key2Data.finger) and 1 or 0
        local homerowBonus = (key1Data.row == config.homerow and key2Data.row == config.homerow) and 1 or 0
        local powerFinger1Bonus = (key1Data.finger == config.powerFingers[1] or key1Data.finger == config.powerFingers[2] or key1Data.finger == config.powerFingers[3] or key1Data.finger == config.powerFingers[4]) and
            1 or 0
        local powerFinger2Bonus = (key2Data.finger == config.powerFingers[1] or key2Data.finger == config.powerFingers[2] or key2Data.finger == config.powerFingers[3] or key2Data.finger == config.powerFingers[4]) and
            1 or 0
        local mnemonicBonus = Mnemonic_score(key1, key2, str)
        local score = (doubleCharBonus + homerowBonus + powerFinger1Bonus + powerFinger2Bonus + mnemonicBonus) -
            sameFingerPenalty

        return score
    else
        return 0
    end
end

---@param key1 string
---@param key2 string
---@param str string
---@return integer
function Mnemonic_score(key1, key2, str)
    -- returns a bonus point if the keys are the first letter of a word
    local words = {}
    for word in str:gmatch("%S+") do
        table.insert(words, word)
    end

    local bonus = 0
    for _, word in ipairs(words) do
        if word:sub(1, 1):lower() == key1 or word:sub(1, 1):lower() == key2 then
            bonus = bonus + 1
        end
    end

    --if key1 equals first letter of string then bonus = bonus + 1
    if str:sub(1, 1):lower() == key1 then
        bonus = bonus + 1
    end

    return bonus
end

-- Function to generate all possible two-character combinations
---@param str string
---@return table
local function generate_combos(str)
    str = str:gsub(config.leader, "")
    local pairs = {}
    local len = #str
    for i = 1, len - 1 do
        local char1 = str:sub(i, i):lower()     -- Convert characters to lowercase
        for j = i + 1, len do
            local char2 = str:sub(j, j):lower() -- Convert characters to lowercase
            table.insert(pairs, char1 .. char2)
        end
    end
    return pairs
end

---@param str string
---@return table
local function process_string(str)
    local combinations = generate_combos(str)
    local scores = {}

    for _, combo in ipairs(combinations) do
        local a, b = combo:sub(1, 1), combo:sub(2, 2)
        local score = key_score(a, b, str, config.keyboardLayout)
        scores[combo] = score
    end

    -- Sort the distances table by value
    local sortedScores = {}
    for combo, score in pairs(scores) do
        table.insert(sortedScores, { combo = combo, score = score })
    end
    table.sort(sortedScores, utils.Score_sort)


    local already_used_keys = tsSearch.get_all_keymaps()

    local find_mapping = function(maps, lhs)
        for _, value in ipairs(maps) do
            if value.lhs == lhs then
                return { rhs = value.rhs, from_file = value.from_file }
            end
        end
        return false
    end

    for i = #sortedScores, 1, -1 do
        if find_mapping(already_used_keys, '<leader>' .. sortedScores[i].combo) then
            local mapping = find_mapping(already_used_keys, '<leader>' .. sortedScores[i].combo)
            sortedScores[i].already_mapped = mapping
        end
    end


    return sortedScores
end

---@param str string
---@param combo string
---@return string
local function highlight_desc(str, combo)
    -- returns str with the first unmarked occurrence of each letter of combo surrounded by []
    local newStr = str:lower()
    local marked = {} -- Keep track of characters already marked
    for i = 1, #combo do
        local char = combo:sub(i, i)
        local pos = marked[char] or 1      -- Start searching from the last marked position or from the beginning
        pos = newStr:find(char, pos, true) or 0
        if pos then
            newStr = newStr:sub(1, pos - 1) .. "[" .. char .. "]" .. newStr:sub(pos + 1)
            marked[char] = pos + 2 -- Mark this character's position
        end
    end
    return newStr
end

---@param str string
---@return table
local function scoreTable(str)
    -- local results = utils.top5(process_string(str))
    local results = process_string(str)
    local resultTable = {}
    for _, data in ipairs(results)
    do
        table.insert(resultTable,
            "Key: " ..
            highlight_desc(str, data.combo) ..
            "<leader>" ..
            data.combo ..
            " - Hawt Score: " ..
            data.score)
        if data.already_mapped ~= nil and data.already_mapped.rhs ~= nil and data.already_mapped.from_file ~= nil then
            table.insert(resultTable,
                "Already mapped: " .. tostring(data.already_mapped.rhs))
            table.insert(resultTable,
                "In File" .. (data.already_mapped.from_file))
        end
    end
    return resultTable
end

return {
    ScoreTable = scoreTable,
}
