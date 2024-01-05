local hawtkeys = require("hawtkeys")
local keyboardLayouts = require("hawtkeys.keyboards")
local tsSearch = require("hawtkeys.ts")
local utils = require("hawtkeys.utils")
local already_used_keys = {}

---@param key1 string
---@param key2 string
---@param str string
---@return integer
local function mnemonic_score(key1, key2, str)
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
        local sameFingerPenalty = (key1Data.finger == key2Data.finger) and 1
            or 0
        local homerowBonus = (
            key1Data.row == hawtkeys.config.homerow
            and key2Data.row == hawtkeys.config.homerow
        )
                and 1
            or 0
        local powerFinger1Bonus = (
            key1Data.finger == hawtkeys.config.powerFingers[1]
            or key1Data.finger == hawtkeys.config.powerFingers[2]
            or key1Data.finger == hawtkeys.config.powerFingers[3]
            or key1Data.finger == hawtkeys.config.powerFingers[4]
        )
                and 1
            or 0
        local powerFinger2Bonus = (
            key2Data.finger == hawtkeys.config.powerFingers[1]
            or key2Data.finger == hawtkeys.config.powerFingers[2]
            or key2Data.finger == hawtkeys.config.powerFingers[3]
            or key2Data.finger == hawtkeys.config.powerFingers[4]
        )
                and 1
            or 0
        local mnemonicBonus = mnemonic_score(key1, key2, str)
        local score = (
            doubleCharBonus
            + homerowBonus
            + powerFinger1Bonus
            + powerFinger2Bonus
            + mnemonicBonus
        ) - sameFingerPenalty

        return score
    else
        return 0
    end
end

-- Function to generate all possible two-character combinations
---@param str string
---@return string[]
local function generate_combos(str)
    str = str:gsub(hawtkeys.config.leader, "")
    local pairs = {}
    local len = #str
    for i = 1, len - 1 do
        local char1 = str:sub(i, i):lower() -- Convert characters to lowercase
        for j = i + 1, len do
            local char2 = str:sub(j, j):lower() -- Convert characters to lowercase
            table.insert(pairs, char1 .. char2)
        end
    end
    return pairs
end

---@class HawtkeysScoreData
---@field [string] integer

---@param str string
---@return HawtkeysScoreData[]
local function find_matches(str)
    local combinations = generate_combos(str)
    local scores = {}

    for _, combo in ipairs(combinations) do
        local a, b = combo:sub(1, 1), combo:sub(2, 2)
        local score = key_score(a, b, str, hawtkeys.config.keyboardLayout)
        scores[combo] = score
    end

    -- Sort the distances table by value
    local sortedScores = {}
    for combo, score in pairs(scores) do
        table.insert(sortedScores, { combo = combo, score = score })
    end
    table.sort(sortedScores, utils.score_sort)
    if already_used_keys == nil then
        already_used_keys = tsSearch.get_all_keymaps()
    end

    local find_mapping = function(maps, lhs)
        for _, value in ipairs(maps) do
            if utils.sanitise_modifier_keys(value.lhs) == utils.sanitise_modifier_keys(lhs) then
                return { rhs = value.rhs, from_file = value.from_file }
            end
        end
        return false
    end

    for i = #sortedScores, 1, -1 do
        if
            find_mapping(already_used_keys, "<leader>" .. sortedScores[i].combo)
        then
            local mapping = find_mapping(
                already_used_keys,
                "<leader>" .. sortedScores[i].combo
            )
            sortedScores[i].already_mapped = mapping
        end
    end

    return sortedScores
end

local function reset_already_used_keys()
    already_used_keys = nil
end

return {
    ScoreTable = find_matches,
    ResetAlreadyUsedKeys = reset_already_used_keys,
}
