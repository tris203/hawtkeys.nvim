--TODO: Mapp all other keys, including modifiers and symbols
local layout = {
    q = { finger = 1, row = 1, col = 1 },
    w = { finger = 2, row = 1, col = 2 },
    e = { finger = 3, row = 1, col = 3 },
    r = { finger = 4, row = 1, col = 4 },
    t = { finger = 4, row = 1, col = 5 },
    y = { finger = 6, row = 1, col = 6 },
    u = { finger = 6, row = 1, col = 7 },
    i = { finger = 7, row = 1, col = 8 },
    o = { finger = 7, row = 1, col = 9 },
    p = { finger = 8, row = 1, col = 10 },

    a = { finger = 1, row = 2, col = 1 },
    s = { finger = 2, row = 2, col = 2 },
    d = { finger = 3, row = 2, col = 3 },
    f = { finger = 3, row = 2, col = 4 },
    g = { finger = 3, row = 2, col = 5 },
    h = { finger = 6, row = 2, col = 6 },
    j = { finger = 7, row = 2, col = 7 },
    k = { finger = 7, row = 2, col = 8 },
    l = { finger = 8, row = 2, col = 9 },

    z = { finger = 1, row = 3, col = 1 },
    x = { finger = 3, row = 3, col = 2 },
    c = { finger = 3, row = 3, col = 3 },
    v = { finger = 3, row = 3, col = 4 },
    b = { finger = 6, row = 3, col = 5 },
    n = { finger = 6, row = 3, col = 6 },
    m = { finger = 6, row = 3, col = 7 },

    [" "] = { finger = 4, row = 4, col = 6 }, -- Spacebar
}

return {
    layout = layout,
}

------1-2-3-4-5-6-7-8-9-0
---1- q w e r t y u i o p
---2- a s d f g h j k l
---3- z x c v b n m
