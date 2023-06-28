-- 系统时间
time = systemTime
-- 获取workPath
work_path = getWorkPath()
-- 禁止热更新
hotUpdate_disabled = true
-- 截图延迟
capture_interval = 0
-- 游戏代理识图间隔
game_running_capture_interval = 3 
-- 点击延迟
tap_interval = 0
-- app运行时间
app_is_run = time()
--server pkg name
server_pkg_name = {
  ["国服"] = "com.zlongame.cn.epicseven",
}
-- 当前服务器
current_server = "国服"
-- wait 间隔
wait_interval = .3
-- 禁用测试
disable_test = false
-- debug
debug_disabled = true
-- 禁用日志
-- disable_log = true
-- 是否异常退出
is_exception_quit = false
-- UI配置完毕
ui_config_finish = false
-- loggerID
logger_ID = nil
-- 当前任务
current_task_index = 1
-- 当前账号任务
current_task = {}
-- 检查游戏状态 10s
check_game_status_interval = 10000
-- 检查图色识别时间
getMillisecond = function (secound) return secound * 1000 end
check_game_identify_timeout = getMillisecond(180)
-- 其他ssleep间隔
other_ssleep_interval = 1
-- 单任务休息时间
single_task_resttime = 5

require("point")
require("util")
-- 导入验证包
require("userinterface")
-- 测试
require("test")
-- log 日志显示在左下角
logger_display_left_bottom = true

-- 其他异常处理 
-- OOM
-- setStopCallBack(function(error)
--   if error then
--     log("异常退出")
--     setNumberConfig("scriptStatus", 3)
--     sStopApp(current_server)
--     reScript()
--   end
-- end)

-- 分辨率提示
-- DPI 320
-- 分辨率 720x1280
local disPlayDPI = getDisplayDpi()
local displaySizeWidth, displaySizeHeight = getDisplaySize()

if disPlayDPI ~= 320 or (displaySizeHeight ~= 1280 and displaySizeHeight > 0) or (displaySizeWidth ~= 720 and displaySizeWidth > 0) then
  wait(function ()
    toast("当前分辨率：\t宽度："..displaySizeWidth.."\t高度："..displaySizeHeight.."\tDPI："..disPlayDPI.."\n"..
          "请手动配置成(模拟器或者虚拟机设置中)：\t宽度：720\t高度：1280\tDPI：320\n后重启脚本")
  end, 1, 99999999 * 60)
end

local scriptStatus = tonumber(getStringConfig("scriptStatus")) or 0
-- 热更新开始
if scriptStatus == 0 then
  if not hotUpdate_disabled then hotUpdate() end
end
-- 脚本状态码
-- 0：表示ok
-- 1：账号被挤下线
-- 2：断开网络
-- 3：其他
-- 是否网络断开、账号被挤之类异常
if scriptStatus == 0 then 
  -- 重置一些数据
  -- UI.配置() while not ui_config_finish do ssleep(0) end -- 等待UI配置完成
  -- 针对本地是否有对应app
  -- current_server = user_config_info.服务器选择
  -- 是否安装了当前所选择的服务器
  -- tipCheckServer()
  -- resetStatus(true)
else
  setStringConfig("scriptStatus", 0)
  -- if scriptStatus == 1 then -- 认证失效，账号被挤
  --   local endTime = getTimeBase(5 * 60)
  --   wait(function ()
  --     log(getTime(endTime, true).."后重新登录")
  --   end, 1, 5 * 60)
  -- end
  -- -- 如果是网络断开连接，就休息5分钟后再试(尝试是否有网络)
  -- if scriptStatus == 2 then
  --   wait(function ()
  --     local ret,code = httpGet("http://www.baidu.com")
  --     if code == 200 then return true else log("无网络。。") end
  --   end, 5)
  -- end
  -- 加载配置
  -- local validData = read("/当前账号配置.txt", true)
  -- if validData.启动账号 == 1 then
  --   local publicData = read("/多账号设置.txt", true)
  --   local validDataCatPublicData = getPublicConfigData(validData, publicData)
  --   user_config_info = validDataCatPublicData
  -- else
  --   local validDataCatPublicData = getPublicConfigData(validData)
  --   user_config_info = validDataCatPublicData
  -- end
  -- log(user_config_info)
  is_exception_quit = true

end

-- 休息时间(单位分钟)
-- local restWaitTimes = tonumber(user_config_info.任务完成休息时间) * 60
-- local restTimes