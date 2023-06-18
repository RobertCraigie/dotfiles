local M = {}

M.contains = function(list, x)
  for _, v in pairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

M.lines = function(str)
  return vim.split(str, "\n", true)
end

M.to_set = function(tbl)
  local set = {}
  for _, l in ipairs(tbl) do
    set[l] = true
  end
  return set
end

return M
