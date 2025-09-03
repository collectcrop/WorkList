function Initialize()

    MaxTasks = tonumber(SKIN:GetVariable('MaxTaskCount')) or 5
    -- 获取日期 (例如 2025-09-03)
    local date = os.date("%Y-%m-%d")
    local path = SKIN:GetVariable('TaskSavePath') .. "tasks_" .. date .. ".txt"

    -- 存到 Rainmeter 变量，方便 INI 引用
    -- SKIN:Bang('!SetVariable', 'TasksFile', path)

    -- 读取任务
    tasks = {}
    local f = io.open(path, "r")
    if f then
        for line in f:lines() do
            -- 跳过文件头
            if not (line:match("^Tasks") or line:match("^%-%-")) and line ~= "" then
                table.insert(tasks, line)
            end
        end
        f:close()
    end
    print("Loaded " .. #tasks .. " tasks.")
    SKIN:Bang('!SetVariable', 'TaskCount', #tasks)
end

function Update()
    for i = 1, MaxTasks do
        if tasks[i] then
            -- 设置任务文字并显示
            SKIN:Bang('!SetVariable', 'Task' .. i .. 'Text', i..'. '..tasks[i])
            SKIN:Bang('!ShowMeter', 'MeterTask' .. i)
            SKIN:Bang('!ShowMeter', 'MeterBox' .. i)
        else
            -- 清空并隐藏
            SKIN:Bang('!SetVariable', 'Task' .. i .. 'Text', '')
            SKIN:Bang('!HideMeter', 'MeterTask' .. i)
            SKIN:Bang('!HideMeter', 'MeterBox' .. i)
        end
    end
    -- 强制刷新 UI
    SKIN:Bang('!Redraw')
    return 0
end
