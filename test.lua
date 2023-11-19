
test = function ()
  logger_display_left_bottom = false
  current_task = uiConfigUnion(fileNames)
  -- log(findOne('友情书签'))
  -- openHUD('刷新次数: 1/1000\n神秘: 5*50 (0.17777%) \n誓约: 5*5 (0.66%)\n友情: 15*5 (66%)', '刷标签')
  -- log(findOne({'未记载的故事', '管理队伍', '国服返回箭头'})) 
  -- sendCloudMessage()
  -- ssleep(10)
  print(table.unpack({1,2,{123,11},4}))
  exit()
end
if not disable_test then test() end