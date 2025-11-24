---@class CaseDial
local M = {}

local config = require("case-dial.config")
local dial = require("case-dial.dial")

M.dial_normal = dial.dial_normal
M.dial_visual = dial.dial_visual

---Setup the plugin with user configuration
---@param opts CaseDialConfig|nil User configuration options
function M.setup(opts)
  if not config.setup(opts) then
    return
  end

  -- Setup keymap if configured
  if config.keymap then
    vim.keymap.set("n", config.keymap, function()
      M.dial_normal()
    end, { desc = "Dial case (normal mode)" })

    vim.keymap.set("v", config.keymap, function()
      -- Exit visual mode first to update '< and '> marks
      local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      vim.api.nvim_feedkeys(esc, "nx", false)
      M.dial_visual()
    end, { desc = "Dial case (visual mode)" })
  end
end

return M
