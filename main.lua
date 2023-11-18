-- 系统时间
time = systemTime
-- https://gitee.com/boluokk/e7-helper/raw/master/release/ 废弃(被屏蔽了)
-- https://gitcode.net/otato001/e7hepler/-/raw/master/
-- https://gitea.com/boluoii/e7Helper/raw/branch/master/
update_source_arr = {
  'https://gitee.com/boluokk/e7_helper/raw/master/',
  'https://gitea.com/boluoii/e7Helper/raw/branch/master/',
  'https://gitcode.net/otato001/e7hepler/-/raw/master/',
}
update_source = table.remove(update_source_arr, math.random(1, #update_source_arr))
update_source_fallback = table.remove(update_source_arr, math.random(1, #update_source_arr))
click_start_tip = '你的star, 是作者的最大帮助'
-- apk level 限制
is_apk_old = function() return getApkVerInt() < 0 end
apk_old_warning = "怎么还有人用" .. getApkVerInt()
release_date = "11.18 21:58"
release_content = 'NPC竞技场挑战-修复'
-- 获取workPath
root_path = getWorkPath() .. '/'
-- 禁止热更新
hotupdate_disabled = true
-- log 日志显示在左下角
-- true stoat 打印
-- false print 打印
logger_display_left_bottom = true
-- 打印当前执行到哪里了(会输出某个图色名)
detail_log_message = not logger_display_left_bottom
-- 禁用测试
disable_test = true
-- 截图延迟
capture_interval = 0
-- 游戏代理识图间隔
game_running_capture_interval = 3
-- 所有配置文件名称
fileNames = {'config.txt', 'fightConfig.txt', 'bagConfig.txt', 'functionSetting.txt', 'advSetting.txt'}
-- 点击延迟
tap_interval = 0
-- app运行时间
app_is_run = time()
--server pkg name
server_pkg_name = {
  ["国服"] = 'com.zlongame.cn.epicseven',
  ['B服'] = 'com.zlongame.cn.epicseven.bilibili',
  ['国际服'] = 'com.stove.epic7.google',
}
-- 当前服务器
current_server = "国际服"
-- wait 间隔
wait_interval = .3
-- 是否异常退出
is_exception_quit = false
-- UI配置完毕
ui_config_finish = false
-- 已经进入过游戏首页
isBack = false
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
check_game_status_interval = 10 * 1000
-- 检查图色识别时间
getMillisecond = function (secound) return secound * 1000 end
-- 单位秒
check_game_identify_timeout = getMillisecond(15)
-- 其他ssleep间隔
other_ssleep_interval = 1
-- 单任务休息时间
single_task_rest_time = 5
-- 开源说明手册地址
open_resource_doc = 'https://boluokk.github.io/e7Helper/'
-- 全局关卡次数(用来代理的时候提示: 代理中 1/100)
global_stage_count = 0
-- 打印配置信息
print_config_info = false
-- 分辨率 720x1280
-- 或者   1280x720
local disPlayDPI = 320
displaySizeWidth, displaySizeHeight = getDisplaySize()
require("point")
require('path')
require("util")
require("userinterface")
require("test")
-- 异常处理
setEventCallBack()
-- 用户配置是否关闭热更
if not hotupdate_disabled then
  hotupdate_disabled = uiConfigUnion({'advSetting.txt'})['关闭热更']
end
local scriptStatus = sgetNumberConfig("scriptStatus", 0)
-- 热更新开始
if scriptStatus == 0 then
  consoleInit()
  initLocalState()
  slog(click_start_tip, 3)
  slog('最近更新时间: '..release_date)
  slog('最近更新内容: '..release_content or '暂无')
  if not hotupdate_disabled then hotUpdate() end
  sui.show()
else
  setNumberConfig("scriptStatus", 0)
  -- 加载本地配置
  current_task = uiConfigUnion(fileNames)
  local configReTryCount = current_task['重试次数'] or 5
  -- 多次异常关闭脚本
  -- 退出游戏还是重启游戏?
  if exception_count > configReTryCount then 
    slog('连续'..configReTryCount..'次异常退出') 
    setNumberConfig("exception_count", 1) 
    exit() 
  else
    setNumberConfig("exception_count", exception_count + 1)
  end 
  if is_refresh_book_tag == 1 then
    path.刷书签(sgetNumberConfig("refresh_book_tag_count", 0))
  elseif is_refresh_book_tag == 2 then
    path.升3星狗粮()
  else
    path.游戏开始()
  end
end