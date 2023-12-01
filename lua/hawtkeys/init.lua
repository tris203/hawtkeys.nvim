M = {}
function M.setup(config)
    M.excludeAlreadyMapped = config.excludeAlreadyMapped or true
    M.leader = config.leader or " "
    M.homerow = config.homerow or 2
    M.powerFingers = config.powerFingers or { 2, 3, 6, 7 }
    M.keyboardLayout = config.keyboardLayout or "qwerty"
    end

return M

