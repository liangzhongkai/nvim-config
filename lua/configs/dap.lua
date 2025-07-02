local dap = require("dap")

-- codelldb
dap.adapters.codelldb = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", -- Mason 安装路径
    -- On windows you may have to uncomment this:
    -- detached = false,
}
-- dap.adapters.codelldb = {
--     type = "server",
--     port = "${port}",
--     executable = {
--         command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", -- Mason 安装路径
--         args = { "--port", "${port}", "--log-dir", "/tmp/codelldb_logs" },
--     },
-- }
-- C++ 调试配置
dap.configurations.cpp = {
    -- {
    --     name = "Launch",
    --     type = "codelldb",
    --     request = "launch",
    --     program = "${workspaceFolder}/" .. vim.fn.expand("%:t:r"),
    --     args = {},
    --     cwd = '${workspaceFolder}',
    --     -- stopOnEntry = true, -- cause coredump in ld-x86_64...so
    -- },
    {
        name = "File Build and Launch",
        type = "codelldb",
        request = "launch",
        program = function()
            -- local src = vim.fn.expand("%:p")
            local src = vim.fn.expand("%:t")
            -- local output = vim.fn.expand("%:t:r")
            -- 自动编译当前目录下的 main.cpp
            local output = vim.fn.input("🔧 executable path: ")
            if output == "" then
                output = vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r")
            end
            local args = vim.fn.input("🔧 c++ version: ")
            -- 编译命令（你可以按需替换）
            local compile_cmd = "g++ -g -O3 -std=c++"
                .. args
                .. "  "
                .. src
                .. " -o "
                .. output
            if args == "" then
                -- 编译命令（你可以按需替换）
                -- compile_cmd = "g++ -g -std=c++2a -O3 "
                --     .. " -W -Wall -Werror -Wextra -Wno-unused-parameter -lpthread -lbenchmark -fcoroutines "
                --     .. src
                --     .. " -o "
                --     .. output
                compile_cmd = "g++ -g -std=c++17 "
                    .. src
                    .. " -o "
                    .. output
            end

            print("[DAP] Compiling with: " .. compile_cmd)
            local result = os.execute(compile_cmd)

            if result ~= 0 then
                vim.notify("[DAP] ❌ 编译失败", vim.log.levels.ERROR)
                return
            else
                vim.notify(
                    "[DAP] ✅ 编译成功，开始调试",
                    vim.log.levels.INFO
                )
            end

            return output
        end,
        cwd = "${workspaceFolder}",
        -- stopOnEntry = true, -- cause coredump in ld-x86_64...so
        args = {},
        -- externalConsole = true,
        -- env = {
        --     ["LD_DEBUG"] = "libs", -- 可选：增强动态链接诊断
        -- },
        -- initCommands = function()
        --     return {
        --         "target create " .. vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r"),
        --         "settings set target.x86-disassembly-flavor intel",--设置汇编格式为Intel
        --         "register read --all", -- 启动时读取所有寄存器[7,9](@ref)
        --     }
        -- end,
    },
    {
        name = "Proj Build and Launch",
        type = "codelldb",
        request = "launch",
        program = function()
            -- 自动编译当前目录下的 main.cpp
            local output = vim.fn.input(
                "🔧 Output executable path: ",
                vim.fn.getcwd() .. "/",
                "file"
            )

            -- 编译命令（你可以按需替换）
            -- local compile_cmd = "cmake -B build -DCMAKE_BUILD_TYPE=Debug cmake --build build --config Debug"
            local compile_cmd = "./dbuild.sh"
            print("[DAP] Compiling with: " .. compile_cmd)
            local result = os.execute(compile_cmd)

            if result ~= 0 then
                vim.notify("[DAP] ❌ 编译失败", vim.log.levels.ERROR)
                return
            else
                vim.notify(
                    "[DAP] ✅ 编译成功，开始调试",
                    vim.log.levels.INFO
                )
            end

            return output
        end,
        cwd = "${workspaceFolder}",
        -- stopOnEntry = true, -- cause coredump in ld-x86_64...so
        args = {},
    },
    {
        name = "Exe Launch Debug",
        type = "codelldb",
        request = "launch",
        program = function()
            local output = vim.fn.input("🔧 Output executable path: ")
            if output == "" then
                output = vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r")
            end
            _dap_last_cpp_program_path = output
            return output
        end,
        cwd = function()
            -- 如果全局变量存在，我们使用它
            local path = _dap_last_cpp_program_path
            if not path then
                -- 如果全局变量不存在，说明program函数还没有被调用，我们提示用户
                path = vim.fn.input("🔧 Output executable path (for cwd): ")
                if path == "" then
                    path = vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r")
                end
                _dap_last_cpp_program_path = path
            end
            -- 提取目录部分
            return vim.fn.fnamemodify(path, ":h")
        end,
        -- cwd = "${workspaceFolder}",
        -- stopOnEntry = true, -- cause coredump in ld-x86_64...so
        args = {},
    },
    {
        name = "Exe Current Launch Debug",
        type = "codelldb",
        request = "launch",
        program = function()
            local output = vim.fn.input("🔧 Output executable path: ")
            if output == "" then
                output = vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r")
            end
            return output
        end,
        cwd = "${workspaceFolder}",
        -- stopOnEntry = true, -- cause coredump in ld-x86_64...so
        args = {},
    },
    {
        name = "Select and attach to process",
        type = "codelldb",
        request = "attach",
        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,
        pid = function()
            local name = vim.fn.input("Executable name (filter): ")
            return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = "${workspaceFolder}",
    },
    {
        name = "Attach to gdbserver :1234",
        type = "codelldb",
        request = "attach",
        target = "localhost:1234",
        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,
        cwd = "${workspaceFolder}",
        -- sourceMap = {
        --     -- 编译路径→本地源码[7](@ref)
        --     ["/build/server/path"] = "${workspaceFolder}/src",
        -- },
    },
}

-- ============================
-- 🧩 DapDisasm 汇编浮窗功能
-- ============================
-- 用于存储汇编窗口和缓冲区的ID
local custom_disasm_win_id = nil
local custom_disasm_buf_id = nil
vim.api.nvim_create_user_command("DapDisasm", function()
    local dap = require("dap")

    local session = dap.session()
    if not session then
        vim.notify("No active debug session", vim.log.levels.WARN)
        return
    end

    local frame = dap.session().current_frame
    if not frame then
        vim.notify("No current frame", vim.log.levels.WARN)
        return
    end

    local addr = frame.instructionPointerReference
        or frame.instructionPointer
        or frame.pc
    if not addr then
        vim.notify("No instruction pointer available", vim.log.levels.WARN)
        return
    end

    session:request("disassemble", {
        memoryReference = addr,
        instructionOffset = -20,
        instructionCount = 50,
        resolveSymbols = true,
    }, function(err, response)
        if err then
            vim.notify(
                "Disassemble request failed: " .. err.message,
                vim.log.levels.ERROR
            )
            return
        end

        local asm_lines = {}
        local current_line = 1 -- fallback: default to first line
        local pc_addr = addr:lower()

        for i, ins in ipairs(response.instructions or {}) do
            local line =
                string.format("0x%s:\t%s", ins.address, ins.instruction)
            table.insert(asm_lines, line)

            if ins.address:lower() == pc_addr then
                current_line = i
            end
        end

        local existing_buf
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if
                vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
                == "DapDisasm"
            then
                existing_buf = b
                break
            end
        end

        local buf
        local asm_win
        local current_win = vim.api.nvim_get_current_win() -- 记录当前窗口，后面切回去

        if existing_buf then
            buf = existing_buf
            -- 找到显示该 buffer 的窗口
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(w) == buf then
                    asm_win = w
                    break
                end
            end
            if not asm_win then
                -- buffer 存在，但没窗口显示，则新开一个竖分窗口
                vim.cmd("vsplit")
                asm_win = vim.api.nvim_get_current_win()
            end

            -- 切到这个窗口，清空内容
            vim.api.nvim_set_current_win(asm_win)
            vim.bo[buf].modifiable = true
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
        else
            -- 新建 buffer 和窗口
            buf = vim.api.nvim_create_buf(false, true)
            vim.cmd("vsplit")
            asm_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(asm_win, buf)
        end

        -- 存储窗口和缓冲区的ID
        custom_disasm_win_id = asm_win
        custom_disasm_buf_id = buf

        -- 写入新汇编内容
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, asm_lines)

        -- 高亮当前行（设置 extmark）
        local ns = vim.api.nvim_create_namespace("DapDisasmHighlight")
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        vim.api.nvim_set_hl(0, "DapPCLine", { bg = "#3c3836" })
        vim.api.nvim_buf_set_extmark(buf, ns, current_line - 1, 0, {
            -- virt_text = { { "← PC", "Comment" } },
            -- virt_text_pos = "eol",
            virt_text = { { "-→  ", "DiagnosticHint" } }, -- 你可以换成 "← PC" 等
            virt_text_pos = "overlay", -- 覆盖显示在该列（而非 eol）
            hl_group = "DapPCLine",
            line_hl_group = "DapPCLine",
            priority = 1000,
        })

        -- 将current_line显示在中间
        vim.api.nvim_win_set_cursor(asm_win, { current_line, 0 })
        vim.cmd("normal! zz")

        -- buffer 选项
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = "asm"
        vim.bo[buf].modifiable = false

        if vim.api.nvim_buf_get_name(buf) == "" then
            vim.api.nvim_buf_set_name(buf, "DapDisasm")
        end

        -- 切回原窗口，保持光标不变
        vim.api.nvim_set_current_win(current_win)
    end)
end, {})
-- 定义一个函数来关闭自定义汇编窗口
dap.close_custom_disasm_window = function()
    vim.notify("close_custom_disasm_window called", vim.log.levels.WARN)
    if
        custom_disasm_win_id and vim.api.nvim_win_is_valid(custom_disasm_win_id)
    then
        vim.api.nvim_win_close(custom_disasm_win_id, true) -- true 表示强制关闭
        custom_disasm_win_id = nil -- 清除存储的ID
        -- 因为 buftype = "nofile" 和 bufhidden = "wipe"，通常缓冲区会随窗口关闭而删除
        -- 但为了确保，也可以尝试删除缓冲区
        if
            custom_disasm_buf_id
            and vim.api.nvim_buf_is_valid(custom_disasm_buf_id)
        then
            vim.api.nvim_buf_delete(custom_disasm_buf_id, {})
            custom_disasm_buf_id = nil
        end
    end
end

-- gdb
-- dap.adapters.gdb = {
--     type = "executable",
--     command = "/usr/bin/gdb",
--     args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
-- }
--
-- dap.configurations.cpp = {
--     {
--         name = "Launch",
--         type = "gdb",
--         request = "launch",
--         program = function()
--             return vim.fn.input(
--                 "Path to executable: ",
--                 vim.fn.getcwd() .. "/",
--                 "file"
--             )
--         end,
--         cwd = "${workspaceFolder}",
--         stopAtBeginningOfMainSubprogram = false,
--     },
--     {
--         name = "Select and attach to process",
--         type = "gdb",
--         request = "attach",
--         program = function()
--             return vim.fn.input(
--                 "Path to executable: ",
--                 vim.fn.getcwd() .. "/",
--                 "file"
--             )
--         end,
--         pid = function()
--             local name = vim.fn.input("Executable name (filter): ")
--             return require("dap.utils").pick_process({ filter = name })
--         end,
--         cwd = "${workspaceFolder}",
--     },
--     {
--         name = "Attach to gdbserver :1234",
--         type = "gdb",
--         request = "attach",
--         target = "localhost:1234",
--         program = function()
--             return vim.fn.input(
--                 "Path to executable: ",
--                 vim.fn.getcwd() .. "/",
--                 "file"
--             )
--         end,
--         cwd = "${workspaceFolder}",
--     },
-- }

-- cpp to c and rust
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
