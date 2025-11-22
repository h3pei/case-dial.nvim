---@class CaseDialDetector
local M = {}

---@alias CaseType "snake"|"pascal"|"camel"|"constant"|"kebab"|"unknown"

---Check if a string contains only ASCII letters, digits, underscores, and hyphens
---@param str string The string to check
---@return boolean
local function is_valid_identifier(str)
  return str:match("^[a-zA-Z0-9_-]+$") ~= nil
end

---Check if a string has at least two words (based on separators or case changes)
---@param str string The string to check
---@return boolean
local function has_multiple_words(str)
  -- Check for underscore or hyphen separators
  if str:find("_") or str:find("-") then
    return true
  end
  -- Check for camelCase/PascalCase (lowercase followed by uppercase)
  if str:match("[a-z][A-Z]") then
    return true
  end
  -- Check for CONSTANT_CASE with multiple parts
  if str:match("^[A-Z0-9]+$") and #str > 1 then
    -- Single word all caps is not multiple words
    return false
  end
  return false
end

---Detect the case type of a given string
---@param str string The string to analyze
---@return CaseType case_type The detected case type
function M.detect(str)
  if not str or str == "" then
    return "unknown"
  end

  if not is_valid_identifier(str) then
    return "unknown"
  end

  if not has_multiple_words(str) then
    return "unknown"
  end

  -- Check for kebab-case (contains hyphens, all lowercase)
  if str:find("-") and str:match("^[a-z0-9-]+$") then
    return "kebab"
  end

  -- Check for snake_case (contains underscores, all lowercase)
  if str:find("_") and str:match("^[a-z0-9_]+$") then
    return "snake"
  end

  -- Check for CONSTANT_CASE (contains underscores, all uppercase)
  if str:find("_") and str:match("^[A-Z0-9_]+$") then
    return "constant"
  end

  -- Check for PascalCase (starts with uppercase, no separators)
  if str:match("^[A-Z][a-zA-Z0-9]*$") and not str:find("_") and not str:find("-") then
    -- Verify it has multiple words (case changes)
    if str:match("[a-z][A-Z]") or str:match("^[A-Z][a-z]") then
      return "pascal"
    end
  end

  -- Check for camelCase (starts with lowercase, has uppercase, no separators)
  if str:match("^[a-z][a-zA-Z0-9]*$") and not str:find("_") and not str:find("-") then
    if str:match("[a-z][A-Z]") then
      return "camel"
    end
  end

  return "unknown"
end

---Check if a string is a valid target for case conversion
---@param str string The string to check
---@return boolean is_valid True if the string can be converted
function M.is_valid_target(str)
  return M.detect(str) ~= "unknown"
end

return M
