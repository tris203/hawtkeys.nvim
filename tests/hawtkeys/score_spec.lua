local hawtkeys = require("hawtkeys")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
local score = require("hawtkeys.score")

describe("mnemonic scoring", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        hawtkeys.setup({
            keyboardLayout = "qwerty",
        })
    end)

    it(
        "should score word initial combinations highly for 'git open'",
        function()
            local results = score.ScoreTable("git open")

            -- Find "go" and "og" in results
            local go_score, og_score
            for _, result in ipairs(results) do
                if result.combo == "go" then
                    go_score = result.score
                end
                if result.combo == "og" then
                    og_score = result.score
                end
            end

            -- Both "go" and "og" should exist and have high scores
            assert.is_not_nil(go_score, "go should be in results")
            assert.is_not_nil(og_score, "og should be in results")
            assert.is_true(go_score > 0, "go should have a positive score")
            assert.is_true(og_score > 0, "og should have a positive score")
        end
    )

    it(
        "should score word initial combinations highly for multi-word commands",
        function()
            local results = score.ScoreTable("find file in project")

            -- Find "ff", "fi", "fp", "if", "ii", "ip", "pf", "pi", "pp" in results
            local found_initials = {}
            for _, result in ipairs(results) do
                if
                    result.combo == "ff"
                    or result.combo == "fi"
                    or result.combo == "fp"
                    or result.combo == "if"
                    or result.combo == "ip"
                    or result.combo == "pf"
                then
                    found_initials[result.combo] = result.score
                end
            end

            -- At least some of these should have high scores
            assert.is_true(
                (found_initials["ff"] and found_initials["ff"] > 0)
                    or (found_initials["fi"] and found_initials["fi"] > 0)
                    or (found_initials["fp"] and found_initials["fp"] > 0),
                "at least one initial combination should have a positive score"
            )
        end
    )

    it("should include all permutations of word initials", function()
        local results = score.ScoreTable("next buffer")

        local nb_score, bn_score
        for _, result in ipairs(results) do
            if result.combo == "nb" then
                nb_score = result.score
            end
            if result.combo == "bn" then
                bn_score = result.score
            end
        end

        -- Both directions should exist
        assert.is_not_nil(nb_score, "nb should be in results")
        assert.is_not_nil(bn_score, "bn should be in results")
    end)
end)
