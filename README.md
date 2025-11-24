# case-dial.nvim

A simple Neovim plugin that cycles through case styles with one keypress.

**One feature. One keymap. Zero config required.**

![case-dial-nvim-demo](https://github.com/user-attachments/assets/6de2e352-a333-4097-976b-831cb173d3f8)

## Installation

```lua
{ "h3pei/case-dial.nvim", opts = {} }
```

That's it. Press `<C-\>` on any word and it just works.

## Usage

```
my_variable → MyVariable → myVariable → MY_VARIABLE → my-variable → my_variable
```

- **Normal mode**: Place cursor on a word and press `<C-\>`
- **Visual mode**: Select text and press `<C-\>`

## Features

- Single keymap to cycle through case styles
- Supports 5 case styles: `snake_case`, `PascalCase`, `camelCase`, `CONSTANT_CASE`, `kebab-case`
- Works in Normal and Visual mode
- No configuration needed (but customizable if you want)

## Configuration (Optional)

Default settings work for most users. Customize only if needed:

```lua
require("case-dial").setup({
  -- Change case order
  cases = { "snake", "camel" },  -- Only these two

  -- Change keymap
  keymap = "<leader>cc",
})
```

### Manual Keymap Setup

Disable default keymap and define your own:

```lua
require("case-dial").setup({
  keymap = false,
})

vim.keymap.set("n", "<leader>cd", function()
  require("case-dial").dial_normal()
end, { desc = "Dial case" })

vim.keymap.set("v", "<leader>cd", function()
  require("case-dial").dial_visual()
end, { desc = "Dial case" })
```
