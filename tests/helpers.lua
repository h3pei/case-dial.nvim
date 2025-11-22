local M = {}

--- Set up a buffer with content and cursor position
---@param content string Buffer content
---@param cursor_pos number[] Cursor position {row, col} (1-indexed row)
---@return number bufnr Buffer number
function M.setup_buffer(content, cursor_pos)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)

  -- Set content
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Set cursor position
  if cursor_pos then
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end

  return bufnr
end

--- Get buffer content as string
---@param bufnr number Buffer number
---@return string content Buffer content
function M.get_buffer_content(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

--- Clean up buffer after test
---@param bufnr number Buffer number
function M.cleanup_buffer(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

--- Get the word at cursor position from buffer
---@param bufnr number Buffer number
---@param row number Row (1-indexed)
---@param start_col number Start column (0-indexed)
---@param end_col number End column (0-indexed, exclusive)
---@return string word The word at the specified position
function M.get_word_at(bufnr, row, start_col, end_col)
  local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
  if #lines == 0 then
    return ""
  end
  return lines[1]:sub(start_col + 1, end_col)
end

return M
