local M = {}

M.setup = {
  todo_file_path = vim.fn.expand("~/projects/betty/scout_nfl/TODO.md"),
}

local function create_floating_window(config, enter)
  if enter == nil then
    enter = false
  end

  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local win = vim.api.nvim_open_win(buf, enter or false, config)

  return { buf = buf, win = win }
end

M.commands = {}

M.commands.close_window = function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end

  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

M.open_split = function()
  local todo_file_path = M.setup.todo_file_path
  local file_exists = vim.fn.filereadable(todo_file_path) == 1

  if not file_exists then
    vim.cmd("silent !mkdir -p ~/.local/share/booky")
    vim.cmd("silent !touch " .. todo_file_path)
  end

  vim.cmd("vsplit " .. todo_file_path)
end
