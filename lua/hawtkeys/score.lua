local config = require("hawtkeys.config")
local keyboardLayouts = require("hawtkeys.keyboards")

local function key_score(key1, key2, str, layout)
    local keyboard = keyboardLayouts[layout]

    if keyboard == nil then
        error("Invalid keyboard layout")
    end

    if keyboard[key1] and keyboard[key2] then
        local key1Data = keyboard[key1]
        local key2Data = keyboard[key2]


        -- Double press = + 3, homeRow = + 1 (if both keys are on the home row), powerFinger = + 1 (if one of the keys is pressed with a power finger)
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

-- Function to loop through all two-character combinations and calculate key distance
local function process_string(str)
    local combinations = generate_combos(str)
    local scores = {}

    for _, combo in ipairs(combinations) do
        local a, b = combo:sub(1, 1), combo:sub(2, 2)
        local score = key_score(a, b, str, "qwerty")
        scores[combo] = score
    end

    -- Sort the distances table by value
    local sortedScores = {}
    for combo, score in pairs(scores) do
        table.insert(sortedScores, { combo = combo, score = score })
    end
    table.sort(sortedScores, Score_sort)


    if config.excludeAlreadyMapped then
        local already_used_keys = vim.api.nvim_get_keymap("n")
        --print("Already used keys: " .. vim.inspect(already_used_keys))
        --print("Sorted scores: " .. vim.inspect(sortedScores))

        local find_mapping = function(maps, lhs)
            for _, value in ipairs(maps) do
                if value.lhs == lhs then
                    return true
                end
            end
            return false
        end

        for i = #sortedScores, 1, -1 do
            if find_mapping(already_used_keys, config.leader .. sortedScores[i].combo) then
                table.remove(sortedScores, i)
            end
        end
    end


    return sortedScores
end

function Score_sort(a, b)
    return a.score > b.score
end

local function top5(scores_table)
    local top_list = {}
    for i = 1, 5 do
        table.insert(top_list, scores_table[i])
    end
    return top_list
end

local function highlight_desc(str, combo)
    -- returns str with the first unmarked occurrence of each letter of combo surrounded by []
    local newStr = str:lower()
    local marked = {} -- Keep track of characters already marked
    for i = 1, #combo do
        local char = combo:sub(i, i)
        local pos = marked[char] or 1      -- Start searching from the last marked position or from the beginning
        pos = newStr:find(char, pos, true) -- Find the position of the character
        if pos then
            newStr = newStr:sub(1, pos - 1) .. "[" .. char .. "]" .. newStr:sub(pos + 1)
            marked[char] = pos + 2 -- Mark this character's position
        end
    end
    return newStr
end
local function score(str)
    print("String: " .. str)
    for _, data in ipairs(top5(process_string(str)))
    do
        print("Key: " .. highlight_desc(str, data.combo) .. "(<leader>" .. data.combo .. "), Key score " .. data.score)
    end
    print()
end

return {
    Score = score,
}
