-- 系统时间
time = systemTime
-- 获取workPath
root_path = getWorkPath() .. '/'
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
detail_log_message = false
-- 是否异常退出
is_exception_quit = false
-- UI配置完毕
ui_config_finish = false
-- loggerID
logger_ID = nil
-- 当前任务
current_task_index = tonumber(getStringConfig("current_task_index")) or 0
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
-- 开源地址
open_resource_doc = 'https://boluokk.gitee.io/e7-helper/'
require("point")
require("util")
-- 导入验证包
require("userinterface")
-- 测试
require("test")
-- log 日志显示在左下角
logger_display_left_bottom = true
console.clearLog()
console.dismiss()

-- 其他异常处理 
-- OOM
setStopCallBack(function(error)
  if error then
    log("异常退出")
    setNumberConfig("scriptStatus", 3)
    sStopApp(current_server)
    reScript()
  else
    setNumberConfig("scriptStatus", "0")
    setStringConfig('current_task_index', 1)
  end
end)

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
  sui.show()
else
  setStringConfig("scriptStatus", "0")
  path.游戏开始()
end