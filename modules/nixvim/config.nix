{ ... }:
{
  extraConfigLuaPost = ''
    WhichKeyMarkdown = function()
        local wkl = require("which-key")
        local buf = vim.api.nvim_get_current_buf()
        wkl.add({
            { "<localleader>p", "<cmd>MarkdownPreviewToggle<CR>", buffer = 1, desc = "Preview Markdown" },
        })
    end

    WhichKeyNorg = function()
    	local wkl = require("which-key")
    	local buf = vim.api.nvim_get_current_buf()
        wkl.add({
            { "<localleader>t", group = "+todo" },
            { "<localleader>i", group = "+insert" },
            { "<localleader>l", group = "+list" },
            { "<localleader>m", group = "+mode" },
            { "<localleader>n", group = "+note" },
        })
    end

    WhichKeySQL = function()
    	local wkl = require("which-key")
    	local buf = vim.api.nvim_get_current_buf()
    	local scratch = function()
    		vim.cmd([[
                    vnew
                    set filetype=sql
                    setlocal buftype=nofile
                    setlocal bufhidden=hide
                    setlocal noswapfile
                ]])
    	end
    	local buffer_to_string = function()
    		local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    		return table.concat(content, " ")
    	end
    	local dbt_preview = function(json)
    		local cmd = "vsplit term://dbt show "
    		if json ~= nil then
    			cmd = cmd .. "--output json "
    		end
    		if vim.bo.buftype == "nofile" then
    			cmd = string.format([[%s--inline \"%s\"]], cmd, buffer_to_string():gsub('"', "'"))
    		else
    			cmd = cmd .. "-s %:t:r"
    		end
    		vim.cmd(cmd)
    	end
    	local dbt_json_preview = function()
    		dbt_preview(true)
    	end
    	wkl.add({
            { "<localleader>b", "<cmd>vsplit term://dbt build -s %:t:r<CR>", buffer = buf, desc = "Build SQL" },
            { "<localleader>c", "<cmd>vsplit term://dbt compile -s %:t:r<CR>", buffer = buf, desc = "Compile SQL" },
            { "<localleader>j", dbt_preview, buffer = buf, desc = "JSON Preview SQL Run" },
            { "<localleader>p", dbt_json_preview, buffer = buf, desc = "Preview SQL Run" },
            { "<localleader>r", "<cmd>vsplit term://dbt run -s %:t:r<CR>", buffer = buf, desc = "Run SQL" },
            { "<localleader>s", scratch, buffer = buf, desc = "Scratchpad" },
        })
    end

    -- illuminate
    local function map(key, dir, buffer)
    	vim.keymap.set("n", key, function()
    		require("illuminate")["goto_" .. dir .. "_reference"](false)
    	end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
    end

    map("]]", "next")
    map("[[", "prev")

    vim.api.nvim_create_autocmd("FileType", {
    	callback = function()
    		local buffer = vim.api.nvim_get_current_buf()
    		map("]]", "next", buffer)
    		map("[[", "prev", buffer)
    	end,
    })

    -- lint
    local sqlfluff = require("lint").linters.sqlfluff
    local dbt_root = vim.fs.find("dbt_project.yml", { upward = true, stop = vim.fs.normalize("~"), limit = 1 })
    if #dbt_root ~= 0 then
    	sqlfluff.args = {
    		"lint",
    		"--format=json",
    		"--templater=jinja",
    		"--dialect=bigquery",
    	}
    end
  '';
}
