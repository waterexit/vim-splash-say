M = {
    splash_say = function(file, say)
        if say == nil then
            vim.fn["splash#command"](file)
        else
            local _file = vim.fn["empty"](file) and vim.g['splash#path'] or file
            local content = vim.fn["splash#file_to_content"](_file)
            local result = M.convert_baloon(content, say)
            vim.fn["splash#show"](result)
        end
    end,

    convert_baloon = function(content, say)
        local content_max_width =  math.max(unpack(vim.iter(content):map(function(v) return #v end):totable()))
        local max_say_line_width = (content_max_width - (4 * 2))
        local _say = M._bond_flame_to_say(M._split_stirng(say, max_say_line_width))

        local ret = {}
        for _, v in ipairs(_say) do
            table.insert(ret, v)
        end
        for _, v in ipairs(content) do
            table.insert(ret, v)
        end
        return ret
    end,
    _split_stirng = function(str, len)
        local ret = {}
        local start_pos = 1
        local end_pos = len
        while string.sub(str, start_pos, end_pos) ~= '' do
            local line = string.sub(str, start_pos, end_pos)
            table.insert(ret, line .. (start_pos ~=1 and string.rep(' ', len - #line) or ''))
            start_pos = start_pos + len
            end_pos = end_pos + len
        end
        return ret
    end,
    _bond_flame_to_say = function(say_lines)
        local function create_part_table(lines_num)
            local parts = {}
            if lines_num <= 1 then
                parts[1] = { first = '< ', last = ' >' }
            else
                parts[1] = { first = ' /', last = ' \\' }
                parts[lines_num] = { first = ' \\', last = " /" }
                setmetatable(parts, { __index = function() return { first = "| ", last = " |" } end })
            end
            return parts
        end

        local part = create_part_table(#say_lines)
        local ret = {}
        local bar = '  ' .. string.rep('-', #say_lines[1]) .. ' '
        table.insert(ret, bar)
        for i, value in ipairs(say_lines) do
            table.insert(ret, part[i].first .. value .. part[i].last)
        end
        table.insert(ret, bar)
        return ret
    end
}
vim.api.nvim_create_user_command("SplashSay", function(opt) M.splash_say('', opt.fargs[1]) end, {nargs = 1})

return M
