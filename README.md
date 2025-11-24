# case-dial.nvim

A Neovim plugin that dials through different case styles for identifiers.

![case-dial-nvim-demo](https://github.com/user-attachments/assets/6de2e352-a333-4097-976b-831cb173d3f8)

## Features

- Dial through case styles with a single keybinding
- Supports 5 case styles:
  - `snake_case`
  - `PascalCase`
  - `camelCase`
  - `CONSTANT_CASE`
  - `kebab-case`
- Works in both Normal and Visual mode
- Customizable case order and keybinding

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "h3pei/case-dial.nvim",
  config = function()
    require("case-dial").setup()
  end,
}
```

## Usage

Press `<C-\>` (Ctrl + \) on a word to dial through case styles.

### Normal Mode

Place your cursor on an identifier and press `<C-\>`:

```
my_variable → MyVariable → myVariable → MY_VARIABLE → my-variable → my_variable
```

### Visual Mode

Select text and press `<C-\>` to convert the selection.

## Configuration

```lua
require("case-dial").setup({
  -- Case types to dial through (in order)
  -- Available cases: "snake", "pascal", "camel", "constant", "kebab"
  cases = {
    "snake",
    "pascal",
    "camel",
    "constant",
    "kebab"
  },

  -- Keymap to trigger case cycling
  -- Set to false to disable default keymap
  keymap = "<C-\\>",
})
```

### Custom Keymap

Override with your preferred keymap:

```lua
require("case-dial").setup({
  keymap = "<leader>cc",
})
```

Or disable default keymap and set your own:

```lua
require("case-dial").setup({
  keymap = false,
})

vim.keymap.set("n", "<leader>cc", function()
  require("case-dial").dial_normal()
end, { desc = "Dial case" })

vim.keymap.set("v", "<leader>cc", function()
  require("case-dial").dial_visual()
end, { desc = "Dial case" })
```

### Subset of Cases

Use only specific case types:

```lua
require("case-dial").setup({
  cases = { "snake", "camel" },  -- Only dial between snake_case and camelCase
})
```
