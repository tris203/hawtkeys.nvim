# ⌨️🔥 hawtkeys.nvim

**hawtkeys.nvim** is a nvim plugin for finding and suggesting memorable and easy-to-press keys for your nvim shortcuts.
It takes into consideration keyboard layout, easy-to-press combinations and memorable phrases, and excludes already mapped combinations to provide you with suggested keys for your commands

## 📦 Installation

Installation instructions to follow, but as usual with package managers

```lua
return {
    "tris203/hawtkeys.nvim",
    config = true,
}
```

## ❔Usage

### Searching New Keymaps

There are two interfaces to hawtkeys, the first allows you to Search For Keymaps:

```
:Hawtkeys
```

This will allow you to search key binds as below:

![demo](https://github.com/tris203/hawtkeys.nvim/assets/18444302/5ede9881-34d5-4ef4-a15d-80f2c94b314d)

### Show All Existing Keymaps

```
:HawtkeysAll
```

This will launch a window showing all existing keymaps collected from Neovim bindings and analysis of your config file.

### Showing Duplicate Keymaps

```
HawtkeysDupes
```

It will show potential duplicate keymaps, where you have accidentally set the same key for two different things. This can be useful for tracking down issues with plugins not functioning correctly

## ⚙️ Config

```lua
return {
    leader = " ", -- the key you want to use as the leader, default is space
    homerow = 2, -- the row you want to use as the homerow, default is 2
    powerFingers = { 2, 3, 6, 7 }, -- the fingers you want to use as the powerfingers, default is {2,3,6,7}
    keyboardLayout = "qwerty", -- the keyboard layout you use, default is qwerty
    customMaps = {
        --- EG local map = vim.api
        --- map.nvim_set_keymap('n', '<leader>1', '<cmd>echo 1')
        {
            ["map.nvim_set_keymap"] = { --name of the expression
                modeIndex = "1", -- the position of the mode setting
                lhsIndex = "2", -- the position of the lhs setting
                rhsIndex = "3", -- the position of the rhs setting
                optsIndex = "4", -- the position of the index table
                method = "dot_index_expression", -- if the function name contains a dot
            },
        },
        --- EG local map2 = vim.api.nvim_set_keymap
        ["map2"] = { --name of the function
            modeIndex = 1, --if you use a custom function with a fixed value, eg normRemap, then this can be a fixed mode eg 'n'
            lhsIndex = 2,
            rhsIndex = 3,
            optsIndex = 4,
            method = "function_call",
        },
        -- If you use whichkey.register with an alias eg wk.register
        ["wk.register"] = {
            method = "which_key",
        },
        -- If you use lazy.nvim's keys property to configure keymaps in your plugins
        ["lazy"] = {
            method = "lazy",
        },
    },
    highlights = { -- these are the highlight used in search mode
        HawtkeysMatchGreat = { fg = "green", bold = true },
        HawtkeysMatchGood = { fg = "green"},
        HawtkeysMatchOk = { fg = "yellow" },
        HawtkeysMatchBad = { fg = "red" },
    },
}
```

The default config will get all keymaps using the `vim.api.nvim_set_keymap` and `vim.keymap.set`.

## Keyboard Layouts

Currently supported keyboard layouts are:

- qwerty
- colemak
- colemak-dh

## ✍️ Contributing

Contributions are what makes the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion to improve the plugin, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

If there is something specific you want to work on then, please open an issue/discussion first to avoid duplication of efforts

Outstanding items are currently in the TODO.md file.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Pre-Push Hook

There is a pre-push hook present in `.githooks/pre-push.sh`. This can be symlinked to `.git/hooks/pre-push`.

This will ensure that the same checks that will be run in CI are run when you push.
