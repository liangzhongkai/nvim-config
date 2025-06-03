return {

    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.treesitter")
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require("configs.lspconfig")
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lspconfig" },
        config = function()
            require("configs.mason-lspconfig")
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.lint")
        end,
    },
    {
        "rshkarin/mason-nvim-lint",
        event = "VeryLazy",
        dependencies = { "nvim-lint" },
        config = function()
            require("configs.mason-lint")
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require("configs.conform")
        end,
    },
    {
        "zapling/mason-conform.nvim",
        event = "VeryLazy",
        dependencies = { "conform.nvim" },
        config = function()
            require("configs.mason-conform")
        end,
    },

    {
        "sakhnik/nvim-gdb",
        event = "VeryLazy",
        config = function()
            require("configs.gdb").setup()
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "mfussenegger/nvim-dap",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            -- require("nvim-dap-virtual-text").setup()
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                display_callback = function(variable, _)
                    if variable.name:match("^%%") then -- 匹配LLDB寄存器格式（如 %rax）
                        return variable.name .. " = " .. variable.value
                    end
                end,
                -- virt_text_pos = 'eol',
            })
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            -- 左侧边栏
                            {
                                id = "scopes",
                                size = 0.3, -- 占左侧高度的30%
                            },
                            {
                                id = "stacks",
                                size = 0.4, -- 占左侧高度的40%
                            },
                            {
                                id = "watches",
                                size = 0.3, -- 占左侧高度的30%
                            },
                        },
                        size = 0.3, -- 左侧边栏占总宽度的30%
                        position = "left", -- 位于左侧
                    },
                    {
                        elements = {
                            -- 底部面板
                            {
                                id = "repl",
                                size = 0.5, -- 占底部高度的50%
                            },
                            {
                                id = "console",
                                size = 0.5, -- 占底部高度的50%
                            },
                        },
                        size = 0.2, -- 底部面板占总高度的20%
                        position = "bottom", -- 位于底部
                    },
                },
            })
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({ reset = true })
            end
            -- 当DAP终止或退出时，自动关闭DAP UI 和 汇编分屏
            local function close_dap_windows()
                dapui.close()
                -- 关闭自定义汇编分屏
                dap.close_custom_disasm_window()
            end
            dap.listeners.before.event_terminated["dapui_config"] =
                close_dap_windows
            dap.listeners.before.event_exited["dapui_config"] =
                close_dap_windows
            -- dap.listeners.before.event_terminated["dapui_config"] = function()
            --     dapui.close()
            -- end
            -- dap.listeners.before.event_exited["dapui_config"] = function()
            --     dapui.close()
            -- end
            dap.listeners.after.event_stopped["show_disasm"] = function()
                vim.cmd("DapDisasm")
            end
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            handlers = {},
        },
    },
    {
        "mfussenegger/nvim-dap",
        config = function()
            require("configs.dap")
        end,
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "codelldb",
            },
        },
    },

    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false, -- 永远不要将此值设置为 "*"！永远不要！
        opts = {
            providers = {
                openai = {
                    endpoint = "https://api.openai.com/v1",
                    model = "gpt-4o",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_completion_tokens = 8192,
                        reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
                    },
                },
            },
        },
        -- 如果您想从源代码构建，请执行 `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- 对于 Windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- 以下依赖项是可选的，
            "echasnovski/mini.pick", -- 用于文件选择器提供者 mini.pick
            "nvim-telescope/telescope.nvim", -- 用于文件选择器提供者 telescope
            "hrsh7th/nvim-cmp", -- avante 命令和提及的自动完成
            "ibhagwan/fzf-lua", -- 用于文件选择器提供者 fzf
            "nvim-tree/nvim-web-devicons", -- 或 echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- 用于 providers='copilot'
            {
                -- 支持图像粘贴
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- 推荐设置
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- Windows 用户必需
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- 如果您有 lazy=true，请确保正确设置
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
}
