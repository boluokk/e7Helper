-- 系统时间
time = systemTime
-- apk level 限制
is_apk_old = function() return getApkVerInt() < 0 end
apk_old_warning = "怎么还有人用" .. getApkVerInt()
release_date = "2023.08.04 14:44"
release_content = '修复讨伐龙+后记bug'
-- 获取workPath
root_path = getWorkPath() .. '/'
-- 禁止热更新
hotupdate_disabled = true
-- log 日志显示在左下角
-- true stoat 打印
-- false print 打印
logger_display_left_bottom = true
-- 打印当前执行到哪里了(会输出某个图色名)
detail_log_message = false
-- 禁用测试
disable_test = true
-- 截图延迟
capture_interval = 0
-- 游戏代理识图间隔
game_running_capture_interval = 3
-- 所有配置文件名称
fileNames = {'config.txt', 'fightConfig.txt', 'bagConfig.txt'}
-- 点击延迟
tap_interval = 0
-- app运行时间
app_is_run = time()
--server pkg name
server_pkg_name = {
  ["国服"] = 'com.zlongame.cn.epicseven',
  ['B服'] = 'com.zlongame.cn.epicseven.bilibili', 
}
-- 当前服务器
current_server = "国服"
-- wait 间隔
wait_interval = .7
-- 是否异常退出
is_exception_quit = false
-- UI配置完毕
ui_config_finish = false
-- loggerID
logger_ID = nil
-- 获取状态码
sgetNumberConfig = function (key, defval) return tonumber(getNumberConfig(key, defval)) end
-- 是否是刷书签
is_refresh_book_tag = sgetNumberConfig('is_refresh_book_tag', 0)
-- 当前任务
current_task_index = sgetNumberConfig("current_task_index", 0)
-- 异常退出次数
exception_count = sgetNumberConfig('exception_count', 1)
-- 当前账号任务
current_task = {}
-- 检查游戏状态 10s
check_game_status_interval = 10000
-- 检查图色识别时间
getMillisecond = function (secound) return secound * 1000 end
-- 单位秒
check_game_identify_timeout = getMillisecond(20)
-- 其他ssleep间隔
other_ssleep_interval = 1
-- 单任务休息时间
single_task_rest_time = 5
-- 开源说明手册地址
open_resource_doc = 'https://boluokk.gitee.io/e7-helper'
-- 打印配置信息
print_config_info = false
require("point")
require('path')
require("util")
require("userinterface")
require("test")
-- 其他异常处理 
-- OOM
setStopCallBack(function(error)
  if error then
    log("异常退出")
    setNumberConfig("scriptStatus", 3)
    sStopApp(current_server)
    reScript()
  else
    log('exit')
    slog('exit')
    initLocalState()
    console.show()
  end
end)

-- 分辨率提示
-- DPI 320
-- 分辨率 720x1280
-- 或者   1280x720
local disPlayDPI = getDisplayDpi()
displaySizeWidth, displaySizeHeight = getDisplaySize()
if disPlayDPI ~= 320 or ((displaySizeHeight ~= 1280 and displaySizeHeight > 0) and 
                         (displaySizeHeight ~= 720 and displaySizeHeight > 0)) 
                     or ((displaySizeWidth ~= 720 and displaySizeWidth > 0) and 
                         (displaySizeWidth ~= 1280 and displaySizeWidth > 0)) then
  wait(function ()
    toast("当前分辨率："..displaySizeWidth.."x"..displaySizeHeight.."\tDPI："..disPlayDPI.."\n"..
          "请手动配置成(模拟器或者虚拟机设置中)：\n分辨率: 720x1280或者1280x720 \nDPI：320\n之后重启脚本")
  end, 1, 99999999 * 60)
end

local scriptStatus = sgetNumberConfig("scriptStatus", 0)
-- 热更新开始
if scriptStatus == 0 then
  consoleInit()
  initLocalState()
  slog('<- start time')
  slog('最新更新时间: '..release_date)
  slog('更新内容: '..(release_content or '暂无'))
  if not hotupdate_disabled then hotUpdate() end
  sui.show()
else
  setNumberConfig("scriptStatus", 0)
  -- 多次异常关闭脚本
  -- 退出游戏还是重启游戏?
  if exception_count > 3 then 
    slog('连续3次异常退出') 
    setNumberConfig("exception_count", 1) 
    exit() 
  else
    setNumberConfig("exception_count", exception_count + 1)
  end 
  -- 加载本地配置
  -- current_task = read('config.txt', true)
  current_task = uiConfigUnion(fileNames)
  if is_refresh_book_tag == 1 then
    path.刷书签(sgetNumberConfig("refresh_book_tag_count", 0))
  elseif is_refresh_book_tag == 2 then
    path.升3星狗粮()
  else
    path.游戏开始()
  end
end