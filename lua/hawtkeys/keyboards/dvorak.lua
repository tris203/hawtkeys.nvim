local layout = {
    ["'"] = { finger = 1, row = 1, col = 1 },
    [","] = { finger = 2, row = 1, col = 2 },
    ["."] = { finger = 3, row = 1, col = 3 },
    p = { finger = 4, row = 1, col = 4 },
    y = { finger = 4, row = 1, col = 5 },
    f = { finger = 6, row = 1, col = 6 },
    g = { finger = 6, row = 1, col = 7 },
    c = { finger = 7, row = 1, col = 8 },
    r = { finger = 8, row = 1, col = 9 },
    l = { finger = 9, row = 1, col = 10 },
    ["/"] = { finger = 8, row = 1, col = 11 },
    ["="] = { finger = 9, row = 1, col = 12 },
    -- ["\\"] = { finger = 9, row = 1, col = 13 },

    a = { finger = 1, row = 2, col = 1 },
    o = { finger = 2, row = 2, col = 2 },
    e = { finger = 3, row = 2, col = 3 },
    u = { finger = 4, row = 2, col = 4 },
    i = { finger = 4, row = 2, col = 5 },
    d = { finger = 6, row = 2, col = 6 },
    h = { finger = 6, row = 2, col = 7 },
    t = { finger = 7, row = 2, col = 8 },
    n = { finger = 8, row = 2, col = 9 },
    s = { finger = 9, row = 2, col = 10 },
    ["-"] = { finger = 9, row = 2, col = 11 },

    [";"] = { finger = 2, row = 3, col = 1 },
    q = { finger = 3, row = 3, col = 2 },
    j = { finger = 4, row = 3, col = 3 },
    k = { finger = 4, row = 3, col = 4 },
    x = { finger = 4, row = 3, col = 5 },
    b = { finger = 6, row = 3, col = 6 },
    m = { finger = 6, row = 3, col = 8 },
    w = { finger = 7, row = 3, col = 9 },
    v = { finger = 8, row = 3, col = 10 },
    z = { finger = 9, row = 3, col = 11 },

    [" "] = { finger = 4, row = 4, col = 6 }, -- Spacebar
}

return {
    layout = layout,
}

------1-2-3-4-5-6-7-8-9-0
---1- ' , . p y f g c r l / = \
---2- a o e u i d h t n -
---3- ; q j k x b m v z
