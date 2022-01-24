local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
-- constants
RED_PILL = 1
BLUE_PILL = 2
-- globals
NEO_ZOOM_DID_INIT = false
CUR_MODE = nil
PROJ_ROOT = nil
USER_ROOT = ''

local M = {}

local function init()
  CUR_MODE = RED_PILL
  -- NOTE: Both `~`, `-`, `..` works with `vim.cmd`
  PROJ_ROOT = vim.fn.getcwd()
end

local function execute_mode_behaviour()
  if CUR_MODE == RED_PILL then
    vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))
  else -- CUR_MODE == BLUE_PILL
    if USER_ROOT ~= '' then
      vim.api.nvim_set_current_dir(USER_ROOT)
    else
      vim.api.nvim_set_current_dir(PROJ_ROOT)
    end
  end
end

local function apply_change()
  M.execute()
  print(vim.fn.getcwd())
end
---------------------------------------------------------------------------------------------------
function M.execute()
  if not NEO_ZOOM_DID_INIT then
    init()
    NEO_ZOOM_DID_INIT = true
  end
  -- NOTE: Don't use `string.find` to compare type, since empty string `''` will always match
  -- NOTE: Don't use `vim.opt.filetype`, since everyone set it locally.
  if vim.bo.buftype ~= "terminal" -- TODO: should be customizable
    and vim.bo.filetype ~= "dashboard"
    and vim.bo.filetype ~= "NvimTree"
    and vim.bo.filetype ~= "FTerm" then
    execute_mode_behaviour()
  end
end

function M.change_mode()
  if CUR_MODE == BLUE_PILL then
    CUR_MODE = RED_PILL
  elseif CUR_MODE == RED_PILL then
    CUR_MODE = BLUE_PILL
  end
  apply_change()
end

function M.change_project_root()
  USER_ROOT = vim.fn.input('Set Project Root: ')
  CUR_MODE = BLUE_PILL
  if USER_ROOT ~= '' then -- reset
    vim.api.nvim_set_current_dir(USER_ROOT)
  else
    vim.api.nvim_set_current_dir(PROJ_ROOT)
  end
  apply_change()
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoRoot lua require('neo-root').execute()
    command! NeoRootSwitchMode lua require('neo-root').change_mode()
    command! NeoRootChange lua require('neo-root').change_project_root()
  ]]
end

setup_vim_commands()

return M
