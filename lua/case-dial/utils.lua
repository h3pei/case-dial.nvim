local M = {}

--- Check log level and display notification
---@param message string Notification message
---@param level number Log level (vim.log.levels.*)
local function notify(message, level)
  vim.notify(message, level, { title = "case-dial.nvim" })
end

--- Display INFO level notification
---@param message string Notification message
function M.notify_info(message)
  notify(message, vim.log.levels.INFO)
end

--- Display WARN level notification
---@param message string Notification message
function M.notify_warn(message)
  notify("[warn] " .. message, vim.log.levels.WARN)
end

--- Display ERROR level notification
---@param message string Notification message
function M.notify_error(message)
  notify("[error] " .. message, vim.log.levels.ERROR)
end

return M
