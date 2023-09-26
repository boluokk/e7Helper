
test = function ()
  logger_display_left_bottom = false
  current_task = uiConfigUnion(fileNames)
  -- log(findOne('友情书签'))
  -- openHUD('刷新次数: 1/1000\n神秘: 5*50 (0.17777%) \n誓约: 5*5 (0.66%)\n友情: 15*5 (66%)', '刷标签')
  -- wait(function ()
  --   sswipe({932,138}, {932,600})
  --   ssleep(1)
  --   return findOne(startCheck)
  -- -- end)
  log(findOne({'国服圣域企鹅巢穴'}))
  local intervalTime = (1 * 60 * 1000) + time()
  wait(function () log("挂机倒计时: "..getTime(intervalTime)) end, 1, 1 * 60)
  exit()
end
if not disable_test then test() end