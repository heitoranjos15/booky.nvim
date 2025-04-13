local M = {}

M.setup = {
  todo_file_path = vim.fn.expand("~/.local/share/booky/todo.md"),
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

M.commands.complete_task = function(opts)
  local todo_file_path = M.setup.todo_file_path
  local file_exists = vim.fn.filereadable(todo_file_path) == 1

  if not file_exists then
    vim.cmd("silent !mkdir -p ~/.local/share/booky")
    vim.cmd("silent !touch " .. todo_file_path)
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local line = vim.api.nvim_get_current_line()

  line = line:gsub("%[%]", "[x]")
  vim.api.nvim_set_current_line(line)
  -- vim.cmd("write") // TODO
  -- Look a way to save in the window returned on create_floating_window
end


M.open_window = function(opts)
  opts = opts or {}
  opts.bufNumber = opts.buffer or 5

  float = create_floating_window({
    relative = "editor",
    width = 80,
    height = 20,
    col = math.floor((vim.o.columns - 80) / 2),
    row = math.floor((vim.o.lines - 20) / 2),
    style = "minimal",
    border = "rounded",
  }, true)

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)

  vim.keymap.set("n", "q", function()
    M.commands.close_window()
  end, { buffer = float.buf })

  vim.keymap.set("n", "<CR>", function()
    print("Complete task")
    M.commands.complete_task()
  end, { buffer = float.buf })
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

-- M.open_split()
M.open_window({})
