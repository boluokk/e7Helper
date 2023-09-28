
test = function ()
  logger_display_left_bottom = false
  current_task = uiConfigUnion(fileNames)
  -- log(findOne('友情书签'))
  -- openHUD('刷新次数: 1/1000\n神秘: 5*50 (0.17777%) \n誓约: 5*5 (0.66%)\n友情: 15*5 (66%)', '刷标签')
  log(findOne('国服重复战斗完成'))
  exit()
end
if not disable_test then test() end