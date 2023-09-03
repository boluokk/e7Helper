
test = function ()
  logger_display_left_bottom = false
  current_task = uiConfigUnion(fileNames)
  local target = {'申请好友取消','紧急任务确认','国服背包空间不足', 
                '国服行动力不足', '国服右下角', '国服右下角活动', 
                '国服战斗失败', '国服战斗问号'} -- 好友申请、紧急任务可能会进来
  log(findOne(target))
  exit()
end
if not disable_test then test() end