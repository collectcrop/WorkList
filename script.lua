function Initialize()
    baseY = 55
    PaddingY=12
    LineHeight=36
    local date = os.date("%Y-%m-%d")
    local path = SKIN:GetVariable('TaskSavePath') .. "tasks_" .. date .. ".txt"
    print(path)
    local f = io.open(path, "r")
    if f == nil then
        f = io.open(path, "w")
        if f then
            f:write("Tasks for " .. date .. "\n")
            f:write("---------------------\n")
            f:close()
        end
    else
        f:close()
    end
    -- 保存路径到 Rainmeter 变量，供 skin 使用
    SKIN:Bang('!SetVariable', 'TasksFile', path)
end

function Update()
    -- 获取每个任务的 Y 坐标，并存入变量
    taskCount = tonumber(SKIN:GetVariable("TaskCount")) or 0
    for i = 1, taskCount do
        local y = baseY + PaddingY + (i-1) * LineHeight
        SKIN:Bang('!SetVariable', 'Task'..i..'Y', y)
    end
    return 0
end

function GetY(Index)
    y = baseY + PaddingY + (Index - 1) * LineHeight
    return y
end
