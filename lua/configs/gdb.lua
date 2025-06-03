-- ============================================================================
-- 文件: lua/config/gdb.lua
-- nvim-gdb 调试器配置 (优化版本 - 修复窗口创建)
-- ============================================================================

local M = {}

-- ============================================================================
-- 基础配置和检查函数
-- ============================================================================

-- 检查是否在调试状态
function M.is_debugging()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        local ft = vim.bo[buf].filetype
        if name:match("gdb://") or ft == "nvimgdb" then
            return true
        end
    end
    return false
end

-- ============================================================================
-- 调试启动和布局设置
-- ============================================================================

-- 启动调试
function M.start_debug()
    local program =
        vim.fn.input("Program to debug: ", vim.fn.getcwd() .. "/", "file")
    if program == "" then
        return
    end

    vim.cmd("GdbStart gdb " .. program)

    -- 延迟设置布局
    vim.defer_fn(function()
        if M.is_debugging() then
            M.setup_debug_layout()
        else
            print("Failed to start debug session")
        end
    end, 2000)
end

-- 设置调试布局 - 修复版本
function M.setup_debug_layout()
    if not M.is_debugging() then
        print("Debug session not active")
        return
    end

    -- 延迟执行布局设置
    vim.defer_fn(function()
        M.create_layout_fixed()
    end, 500)
end

-- 创建调试布局 - 修复版本
function M.create_layout_fixed()
    vim.cmd("wincmd k") -- 确保移动到上方窗口
    vim.cmd("GdbCreateWatch disas")
    vim.cmd("wincmd j") -- 确保移动到下方窗口
    vim.cmd("GdbCreateWatch info stack")
    vim.cmd("GdbCreateWatch info locals")
    vim.cmd("GdbCreateWatch info registers")
    vim.cmd("wincmd k") -- 确保移动到上方窗口
    vim.cmd("wincmd h") -- 确保移动到左方窗口
    print("Use <leader>dR to refresh all info")
end

function M.setup_keymaps()
    local opts = { noremap = true, silent = true }

    vim.keymap.set("n", "<leader>dd", M.start_debug, opts)
end

function M.setup()
    M.setup_keymaps()

    -- 暴露到全局
    _G.gdb_custom = M

    print("GDB configuration loaded successfully!")
end
return M
