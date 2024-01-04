local layout = {
    q = { finger = 1, row = 1, col = 1 },
    w = { finger = 2, row = 1, col = 2 },
    f = { finger = 3, row = 1, col = 3 },
    p = { finger = 4, row = 1, col = 4 },
    g = { finger = 4, row = 1, col = 5 },
    j = { finger = 6, row = 1, col = 6 },
    l = { finger = 6, row = 1, col = 7 },
    u = { finger = 7, row = 1, col = 8 },
    y = { finger = 7, row = 1, col = 9 },

    a = { finger = 1, row = 2, col = 1 },
    r = { finger = 2, row = 2, col = 2 },
    s = { finger = 3, row = 2, col = 3 },
    t = { finger = 3, row = 2, col = 4 },
    d = { finger = 3, row = 2, col = 5 },
    h = { finger = 6, row = 2, col = 6 },
    n = { finger = 7, row = 2, col = 7 },
    e = { finger = 7, row = 2, col = 8 },
    i = { finger = 8, row = 2, col = 9 },
    o = { finger = 8, row = 2, col = 10 },

    z = { finger = 1, row = 3, col = 1 },
    x = { finger = 3, row = 3, col = 2 },
    c = { finger = 3, row = 3, col = 3 },
    v = { finger = 3, row = 3, col = 4 },
    b = { finger = 6, row = 3, col = 5 },
    k = { finger = 6, row = 3, col = 6 },
    m = { finger = 6, row = 3, col = 7 },

    [" "] = { finger = 4, row = 4, col = 6 }, -- Spacebar
}

return {
    layout = layout,
}

-- https://colemak.com/

------1-2-3-4-5-6-7-8-9-0
---1- q w f p g j l u y
---2- a r s t d h n e i o
---3- z x c v b k m
