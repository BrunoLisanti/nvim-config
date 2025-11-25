function NormalizePath(path)
	return path:gsub("\\", '/')
end

function Cwd()
	local current_buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(current_buf)
	local path = vim.fn.expand('%:p:h')

	if buf_name:match("^term://") and path:match("^term://") then
		return nil
	end

	return NormalizePath(path)
end

function GetPath(path)
	local script_path = debug.getinfo(1).source:match("@?(.*/)") or ""
	return script_path .. path
end

function GetBufferDir()
	local path = Cwd()
	if path then
		return path
	end

	local current_buffer_dir = vim.fn.expand('%:p:h')
	local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(current_buffer_dir) .. ' rev-parse --show-toplevel')[1]

	if vim.v.shell_error == 0 and git_root then
		return git_root
	end

	return current_buffer_dir
end

function GetTelescopeDir()
	local path = Cwd()
	if path == nil then
		path = vim.fn.expand('%:p:h')
	end

	local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(path) .. ' rev-parse --show-toplevel')
			[1]
	if vim.v.shell_error == 0 and git_root then
		return git_root
	end

	return path
end

function IsWindows()
	return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end 

function IsLinux()
	return vim.fn.has('win32') == 0 and vim.fn.has('win64') == 0
end 
