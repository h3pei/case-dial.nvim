---@class CaseDialConfigModule
---@field cases string[]
---@field keymap string|false
---@field config CaseDialConfig?
---@field case_index table<string, integer>
local M = {}

M.config = nil
M.case_index = {}

local utils = require("case-dial.utils")

---@type string[]
local available_cases = require("case-dial.converter").AVAILABLE_CASES

---@class CaseDialConfig
---@field cases string[] Array of case types in order
---@field keymap string|false Keymap to use, or false to disable
local default_config = {
  cases = available_cases,
  keymap = "<C-\\>",
}

---Validate configuration
---@param config CaseDialConfig Configuration to validate
---@return boolean is_valid True if configuration is valid
function M.validate(config)
  for _, case in ipairs(config.cases) do
    if not vim.tbl_contains(available_cases, case) then
      utils.notify_error("Unknown case type: " .. case)
      return false
    end
  end

  if #config.cases < 2 then
    utils.notify_error("At least 2 case types are required")
    return false
  end

  return true
end

---Apply user configuration
---@param opts CaseDialConfig|nil User configuration options
---@return boolean success True if configuration was applied successfully
function M.setup(opts)
  local config = vim.tbl_deep_extend("force", default_config, opts or {})

  local is_valid = M.validate(config)
  if not is_valid then
    return false
  end

  M.config = config

  -- Build case index for O(1) lookup
  M.case_index = {}
  for i, case in ipairs(config.cases) do
    M.case_index[case] = i
  end

  return true
end

-- Allow direct access to config values via metatable
setmetatable(M, {
  __index = function(_, key)
    return M.config[key]
  end,
})

return M
