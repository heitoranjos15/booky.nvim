local popup = require("plenary.popup")
local Path = require("plenary.path")

local M = {}

M.tasks = {}

M.setup = {
  todo_file_path = vim.fn.expand("~/.local/share/booky/todo.md"),
  tasks_file_path = vim.fn.expand("~/.local/share/booky/tasks.json"),
}

local function create_floating_window(config, enter)
  if enter == nil then
    enter = false
  end

  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local win = vim.api.nvim_open_win(buf, enter or false, config)

  return { buf = buf, win = win }
end

local function create_pop_window(config, enter)
  local height = config.height or 20
  local width = config.width or 80
  if enter == nil then
    enter = false
  end

  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local _,  win = popup.create(buf, {
        title = "Harpoon Commands",
        highlight = "HarpoonWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

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

  Path:new(todo_file_path):write(vim.api.nvim_buf_get_lines(opts.bufNumber, 0, -1, false), "w")
  -- vim.cmd("bufdo! w!")
  -- Look a way to save in the window returned on create_floating_window
end

M.get_tasks = function()
  local tasks_file_path = M.setup.tasks_file_path
  local file_exists = vim.fn.filereadable(tasks_file_path) == 1

  if not file_exists then
    vim.cmd("silent !mkdir -p ~/.local/share/booky")
    vim.cmd("silent !touch " .. tasks_file_path)
  end

  local lines = Path:new(tasks_file_path):readlines()

  for _, line in ipairs(lines) do
    table.insert(M.tasks, vim.fn.json_encode(line))
  end

  local lines = vim.json.decode(Path:new(tasks_file_path):read())

  print("Tasks loaded: " .. #lines)

  return lines
end

M.open_window = function(opts)
  opts = opts or {}
  opts.bufNumber = opts.buffer or 8
  opts.tasks = opts.tasks or {}

  local lines = vim.api.nvim_buf_get_lines(opts.bufNumber, 0, -1, false)

  height = 20
  width = 80

  local float = create_pop_window({
        title = "Harpoon Commands",
        highlight = "HarpoonWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    }, true)

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(float.buf, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(float.buf, "bufhidden", "delete")

  vim.keymap.set("n", "q", function()
    print("Close window")
    M.commands.close_window()
  end, { buffer = float.buf })

  vim.keymap.set("n", "<CR>", function()
    print("Complete task")
    M.commands.complete_task(opts)
  end, { buffer = float.buf })

  vim.keymap.set("n", "<C-s>", function()
    print("Save task")
    vim.cmd("bufdo! w!")
    -- M.commands.close_window()
    -- M.commands.complete_task()
  end, { buffer = float.buf })
end

-- M.open_window = function(opts)
--   opts = opts or {}
--   opts.bufNumber = opts.buffer or 8
--
--   local lines = vim.api.nvim_buf_get_lines(opts.bufNumber, 0, -1, false)
--   local float = create_floating_window({
--     relative = "editor",
--     width = 80,
--     height = 20,
--     col = math.floor((vim.o.columns - 80) / 2),
--     row = math.floor((vim.o.lines - 20) / 2),
--     style = "minimal",
--     border = "rounded",
--   }, true)
--
--   vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
--
--   vim.keymap.set("n", "q", function()
--     M.commands.close_window()
--   end, { buffer = float.buf })
--
--   vim.keymap.set("n", "<CR>", function()
--     print("Complete task")
--     M.commands.complete_task()
--   end, { buffer = float.buf })
-- end

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
M.open_window({
  buffer = 5,
  tasks = M.get_tasks(),
})
