-- WorkList.lua
-- Rainmeter Lua script for reading/writing task states and updating meters
-- Requires: the .ini defines StateFile and TaskCount and TaskNText variables

function Initialize()
  -- 从 skin 变量读取配置
  rawStatePath = SKIN:GetVariable("StateFile") or "#@#state.txt"
  statePath = SKIN:ReplaceVariables(rawStatePath) or rawStatePath
  taskCount = tonumber(SKIN:GetVariable("TaskCount")) or 0
  taskFinished = SKIN:GetVariable("TaskFinished") or 0
  -- 初始化内存状态表（默认为 0）
  states = {}
  for i=1, taskCount do states[i] = 0 end

  -- 读 state 文件（格式示例: 0,1,0）
  local f = io.open(statePath, "r")
  if f then
    local content = f:read("*all")
    f:close()
    if content and #content > 0 then
      local idx = 1
      for token in string.gmatch(content, "([^,%s]+)") do
        if idx <= taskCount then
          local v = tonumber(token)
          states[idx] = (v == 1) and 1 or 0
        end
        idx = idx + 1
      end
    end
  else
    -- 如果没有文件，则创建初始文件（全部 0）
    SaveState()
  end

  -- 初始化每个 meter 的显示
  for i=1, taskCount do
    UpdateMeter(i)
  end
end

-- Update 必须存在（Rainmeter 会调用），我们不需要每次刷新做事，返回 0
function Update()
  return 0
end

-- 切换任务（由 LeftMouseUpAction 调用）
function ToggleTask(i)
  i = tonumber(i)
  if not i or i < 1 or i > taskCount then return end
  if states[i] == 1 then
    states[i] = 0
    taskFinished = taskFinished - 1
  else
    states[i] = 1
    taskFinished = taskFinished + 1
  end
  SKIN:Bang('!SetVariable', 'TaskFinished', taskFinished)
  SKIN:Bang('!UpdateMeter MeterCompleted')
  SaveState()
  UpdateMeter(i)
end

-- 将内存 states 写回文件（逗号分隔）
function SaveState()
  local f, err = io.open(statePath, "w")
  if not f then
    SKIN:Bang('!Log "WorkList.lua: 无法写入 state 文件: ' .. tostring(err) .. '" 3')
    return
  end
  local parts = {}
  for i=1, taskCount do parts[#parts+1] = tostring(states[i]) end
  f:write(table.concat(parts, ","))
  f:close()
end

-- 更新单个 meter（文字与颜色）
function UpdateMeter(i)

  local color = (states[i] == 1) and "0,160,60" or "255,255,255,205"
  local image = (states[i] == 1) and "@Resources/tickBox1" or "@Resources/Box1"
  -- 设置 Text 与 FontColor（注意引号）
  local setColor = '!SetOption MeterTask' .. i .. ' FontColor "' .. color .. '"'
  local setImage = '!SetOption MeterBox' .. i .. ' ImageName "' .. image .. '"'

  SKIN:Bang(setColor)
  SKIN:Bang(setImage)
  SKIN:Bang('!UpdateMeter MeterTask' .. i)
  SKIN:Bang('!Redraw')
end
