local dap = require("dap")
dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", -- Mason 安装路径
        args = { "--port", "${port}" },
    },
}
-- C++ 调试配置
dap.configurations.cpp = {
    {
        name = "File Build and Launch",
        type = "codelldb",
        request = "launch",
        program = function()
            local src = vim.fn.expand("%:p")
            -- 自动编译当前目录下的 main.cpp
            local output = vim.fn.input(
                "🔧 Output executable path: ",
                vim.fn.getcwd() .. "/",
                "file"
            )

            -- 编译命令（你可以按需替换）
            local compile_cmd = "g++ -fverbose-asm  -fomit-frame-pointer -g -std=c++2a -O2 "
                .. " -W -Wall -Werror -Wextra -Wno-unused-parameter -lpthread -lbenchmark -fcoroutines "
                .. src
                .. " -o "
                .. output
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
        stopOnEntry = true,
        args = {},
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
            local compile_cmd = "cmake --build build --config Release"
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
        stopOnEntry = true,
        args = {},
    },
    {
        name = "Proj Launch Debug",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = true,
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
    },
}
-- dap.adapters.gdb = {
--     type = "executable",
--     command = "/usr/bin/gdb",
--     args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
-- }
--
-- dap.configurations.c = {
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
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
