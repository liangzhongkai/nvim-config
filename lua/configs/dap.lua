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
            local output = vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r")
            -- local output = vim.fn.input(
            --     "🔧 Output executable path: ",
            --     vim.fn.getcwd() .. "/",
            --     "file"
            -- )

            -- 编译命令（你可以按需替换）
            local compile_cmd = "g++ -g -std=c++2a -O0 "
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
