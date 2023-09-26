sui = {}
-- ui事件
suie = {}
parentUID = '第七史诗助手 '..release_date..' '..displaySizeWidth..'x'..displaySizeHeight
grindUID = '刷图设置'
bagUID = '背包清理设置'
functionSettingUID = '功能设置页'
AdvSettingUID = '高级设置页'

-- bin: bid、bname
addButton = function (bin, partid)
  partid = partid or parentUID
  ui.addButton(partid, bin, bin)
  ui.setOnClick(bin, 'suie.'..bin..'()')
end
setButton = function (bin, w, h)
  w = w or 100
  h = h or 100
  -- 添加事件函数
  ui.setButton(bin, bin, w, h)
end
newLayout = function (pid)
  pid = pid or parentUID
  ui.newLayout(pid, 720, -2)
end
newRow = function (pid)
  pid = pid or parentUID
  ui.newRow(pid, uuid())
end
addTab = function (pin, pid)
  pid = pid or parentUID
  ui.addTab(pid, pin, pin)
end
addTabView = function (cid)
  ui.addTabView(parentUID,cid)
end
addTextView = function (text, pid)
  pid = pid or parentUID
  ui.addTextView(pid,text,text)
end
addRadioGroup = function (id, data, pid)
  pid = pid or parentUID
  if type(data) ~= 'table' then data = {data} end
  ui.addRadioGroup(pid,id,data,0,-1,70,true)
end
addCheckBox = function (id, selection, pid, defaluValue)
  pid = pid or parentUID
  ui.addCheckBox(pid,id,selection, defaluValue)
end
addEditText = function (id, text, pid)
  pid = pid or parentUID
  ui.addEditText(pid,id,text)
end
saveProfile = function (path)
  ui.saveProfile(root_path..path)  
end
loadProfile = function (path)
  ui.loadProfile(root_path..path)
end
addSpinner = function (id, data, pid)
  pid = pid or parentUID
  data = data or {}
  ui.addSpinner(pid, id ,data)
end
setDisabled = function (id)
  ui.setEnable(id,false)
end
setEnable = function ()
  ui.setEnable(id,true)
end
dismiss = function (id) ui.dismiss(id) end
suie.退出 = exit
suie.启动 = function ()
  -- 是否配置了清理背包(必须配置, 不然会出问题卡死)
  if not sFileExist('bagConfig.txt') then saveProfile('config.txt') log('请配置满背包处理!') suie.清理背包() return end
  if not sFileExist('functionSetting.txt') then saveProfile('config.txt') log('请配置功能设置!') suie.功能设置() return end
  suie.开启前()
  if print_config_info then
    print(current_task)
    exit()
  end
  path.游戏开始()
end
suie.开启前 = function ()
  -- 保存配置
  saveProfile('config.txt')
  -- 读取所有文件数据
  current_task = uiConfigUnion(fileNames)
  ui_config_finish = true
  dismiss(parentUID)
end
suie.刷书签 = function ()
  suie.开启前()
  path.刷书签(sgetNumberConfig("refresh_book_tag_count", 0))
end
suie.使用说明 = function ()
  runIntent({
    ['action'] = 'android.intent.action.VIEW',
    ['uri'] = open_resource_doc
  })
  exit()
end
suie.刷图设置 = function ()
  sui.showNotMainUI(sui.showGrindSetting)
end
suie.刷新UI = function ()
  for i,v in pairs(fileNames) do sdelfile(v) end
  reScript()
end
suie.功能设置 = function ()
  sui.showNotMainUI(sui.showFunctionSetting)
end
suie.高级设置 = function ()
  sui.showNotMainUI(sui.showAdvSetting)
end
suie.功能设置保存 = function ()
  saveProfile('functionSetting.txt')
  suie.功能设置取消()
end
suie.功能设置取消 = function ()
   sui.hiddenNotMainUI(functionSettingUID)
end
suie.高级配置取消 = function ()
  sui.hiddenNotMainUI(AdvSettingUID)
end
suie.高级配置保存 = function ()
  saveProfile('advSetting.txt')
  suie.功能设置取消()
end
suie.刷图配置取消 = function ()
  sui.hiddenNotMainUI(grindUID)
end
suie.刷图配置保存 = function ()
  saveProfile('fightConfig.txt')
  suie.刷图配置取消()
end
suie.清理背包 = function ()
  sui.showNotMainUI(sui.showBagSetting)
end
suie.背包配置取消 = function ()
  sui.hiddenNotMainUI(functionSettingUID)
end
suie.背包配置保存 = function ()
  saveProfile('bagConfig.txt')
  suie.背包配置取消()
end
suie.升3星狗粮 = function ()
  suie.开启前()
  path.升3星狗粮()
end
suie.购买企鹅 = function ()
  suie.开启前()
  path.购买企鹅()
end
-- 主页
sui.show = function ()
  newLayout()
  newRow()
  -- 开源信息
  addTextView('免费开源，有问题(看下方使用说明 or 加群)\n'..
              'QQ群:206490280      '..
              'QQ频道号:24oyp5x92q')
  newRow()
  -- 服务器
  addTextView('服务器: ')
  local servers = ui_option.服务器
  addRadioGroup('服务器', servers)
  newRow()
  -- 日常功能区
  local selections = ui_option.任务
  for i,v in pairs(selections) do
    addCheckBox(v, v)
    if i % 3 == 0 then newRow() end
  end
  newRow()
  addTextView('每隔')
  addEditText('运行间隔时间', '120')
  addTextView('分钟, 循环一次')
  newRow()
  addButton('使用说明')
  addTextView(('|'))
  addButton('启动')
  addButton('退出')
  newRow()
  addButton('刷新UI')
  addTextView(('|'))
  addButton('清理背包')
  addButton('刷图设置')
  newRow()
  addButton('高级设置')
  addTextView(('|'))
  addButton('购买企鹅')
  addButton('功能设置')
  newRow()
  addButton('XXX')
  addTextView('|')
  addButton('刷书签')
  addButton('升3星狗粮')

  ui.setBackground("使用说明","#ffe74032")
  ui.setBackground("购买企鹅","#ff3bceb3")
  ui.setBackground("升3星狗粮","#ff3bceb3")
  ui.setBackground("刷书签","#ff3bceb3")
  ui.show(parentUID, false)

  -- load config
  loadProfile('config.txt')
  wait(function ()
    if ui_config_finish then return true end
  end, .05, nil, true)
end
-- 战斗设置
sui.showGrindSetting = function ()
  newLayout(grindUID)
  -- addButton('刷图测试', grindUID)
  local passAll = ui_option.战斗类型
  for i,v in pairs(passAll) do
    local cur = i..''
    if cur:includes({1,3,5,6}) then
      addCheckBox(v, v, grindUID)
    else
      addCheckBox(v, v, grindUID)
      -- 暂时禁用
      -- todo
      setDisabled(v)
    end
    if i % 4 == 0 then
      newRow(grindUID)
    end
  end
  newRow(grindUID)
  addTextView('补充行动力:', grindUID)
  addRadioGroup('补充行动力类型', ui_option.补充行动力类型, grindUID)
  newRow(grindUID)
  addTextView('讨伐: ', grindUID)
  addSpinner('讨伐类型', ui_option.讨伐关卡类型, grindUID)
  addSpinner('讨伐级别', ui_option.讨伐级别, grindUID)
  addTextView('级', grindUID)
  addEditText('讨伐次数', '100', grindUID)
  addTextView('次', grindUID)
  newRow(grindUID)
  addTextView('迷宫：', grindUID)
  newRow(grindUID)
  addTextView('精灵祭坛：', grindUID)
  addSpinner('精灵祭坛类型', ui_option.精灵祭坛关卡类型, grindUID)
  addSpinner('精灵祭坛级别', ui_option.精灵祭坛级别, grindUID)
  addTextView('级', grindUID)
  addEditText('精灵祭坛次数', '100', grindUID)
  addTextView('次', grindUID)
  newRow(grindUID)
  addTextView('深渊：', grindUID)
  newRow(grindUID)
  newRow(grindUID)
  addTextView('后记：', grindUID)
  addEditText('后记次数', '100', grindUID)
  addTextView('次', grindUID)
  newRow(grindUID)
  addTextView('活动：', grindUID)
  addSpinner('活动级别', ui_option.活动级别, grindUID)
  addTextView('级', grindUID)
  addEditText('活动次数', '100', grindUID)
  addTextView('次', grindUID)
  newRow(grindUID)
  addButton('刷图配置保存', grindUID)
  addButton('刷图配置取消', grindUID)
  ui.show(grindUID, false)
  loadProfile('fightConfig.txt')
end
sui.showNotMainUI = function (fun)
  -- 保存配置
  saveProfile('config.txt')
  dismiss(parentUID)
  fun()
end
sui.hiddenNotMainUI = function (hiddenID)
  dismiss(hiddenID)
  sui.show()
end
-- 背包清理
sui.showBagSetting = function ()
  newLayout(bagUID)
  addTextView('宠物背包', bagUID)
  newRow(bagUID)
  -- 默认: B C D
  for i,v in pairs(ui_option.宠物级别) do
    if v:includes({'B', 'C', 'D'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
  end
  newRow(bagUID)
  addTextView('装备背包', bagUID)
  newRow(bagUID)
  -- 默认：
  for i,v in pairs(ui_option.装备类型) do
    if v:includes({'一般', '高级', '稀有'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
  end
  newRow(bagUID)
  for i,v in pairs(ui_option.装备等级) do
    if v:includes({'28', '42', '57', '71', '72'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
    if i % 4 == 0 then
      newRow(bagUID)
    end
  end
  newRow(bagUID)
  for i,v in pairs(ui_option.装备强化等级) do
    if v:includes({'+0', '9'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
    if i % 4 == 0 then
      newRow(bagUID)
    end
  end
  newRow(bagUID)
  addTextView('神器背包', bagUID)
  newRow(bagUID)
  for i,v in pairs(ui_option.神器星级) do 
    if v:includes({'1', '2', '3'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
    if i % 7 == 0 then
      newRow(bagUID)
    end
  end
  newRow(bagUID)
  for i,v in pairs(ui_option.神器强化) do
    if v:includes({'+0', '10'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
    if i % 4 == 0 then
      newRow(bagUID)
    end
  end
  newRow(bagUID)
  addTextView('英雄等级', bagUID)
  newRow(bagUID)
  for i,v in pairs(ui_option.英雄等级) do 
    if v:includes({'1', '2', '3'}) then
      addCheckBox(v, v, bagUID, true)
    else
      addCheckBox(v, v, bagUID)
    end
    if i % 7 == 0 then
      newRow(bagUID)
    end
  end
  newRow(bagUID)
  addButton('背包配置保存', bagUID)
  addButton('背包配置取消', bagUID)
  ui.show(bagUID, false)
  loadProfile('bagConfig.txt')
end
-- 功能设置
sui.showFunctionSetting = function ()
  newLayout(functionSettingUID)
  addTextView('<刷书签设置>', functionSettingUID)
  newRow(functionSettingUID)
  local tag = ui_option.刷标签类型
  addTextView('书签: ', functionSettingUID)
  for i,v in pairs(tag) do 
    if i == 3 then
      addCheckBox(v, v, functionSettingUID)
    else 
      addCheckBox(v, v, functionSettingUID, true)
    end
  end
  newRow(functionSettingUID)
  -- 红装
  local level = ui_option.红装等级
  addTextView('红装暂停: ', functionSettingUID)
  for i,v in pairs(level) do 
    addCheckBox('红装暂停-'..v, v, functionSettingUID)
  end
  -- 不能修改主题
  newRow(functionSettingUID)
  addTextView('次数:', functionSettingUID)
  addEditText('更新次数', '333', functionSettingUID)
    -- 需要配置及其他功能区
  newRow(functionSettingUID)
  addTextView('<竞技场设置>', functionSettingUID)
  newRow(functionSettingUID)
  addCheckBox('叶子买票', '叶子买票', functionSettingUID, true)
  addTextView('刷新交战次数:', functionSettingUID)
  addEditText('交战次数', '30', functionSettingUID)
  newRow(functionSettingUID)
  addTextView('每周奖励: ', functionSettingUID)
  addRadioGroup('竞技场每周奖励', ui_option.竞技场每周奖励, functionSettingUID)
  newRow(functionSettingUID)
  addTextView('次序: ', functionSettingUID)
  addRadioGroup('竞技场次序', ui_option.竞技场次序, functionSettingUID)
  -- local mission = {'圣域', '探险', '讨伐', '战争'}
  -- addTextView('派遣任务:')
  -- addRadioGroup('派遣任务', mission)
  newRow(functionSettingUID)
  addTextView('<社团设置>', functionSettingUID)
  newRow(functionSettingUID)
  local teamMission = ui_option.社团任务
  for i,v in pairs(teamMission) do
    if i % 4 == 0 then newRow(functionSettingUID) end
    addCheckBox(v, v, functionSettingUID, true)
  end
  newRow(functionSettingUID)
  addTextView('社团捐赠：', functionSettingUID)
  addRadioGroup('社团捐赠类型', ui_option.社团捐赠类型, functionSettingUID)
  newRow(functionSettingUID)
  addTextView('<升级狗粮设置>', functionSettingUID)
  newRow(functionSettingUID)
  addTextView('升3星狗粮:', functionSettingUID)
  addRadioGroup('升3星狗粮类型', ui_option.升2星狗粮类型, functionSettingUID)
  newRow(functionSettingUID)
  addEditText('升3星狗粮个数','100', functionSettingUID)
  addTextView('个', functionSettingUID)
  addTextView('传送前请先锁定!', functionSettingUID)

  newRow(functionSettingUID)
  addButton('功能设置保存', functionSettingUID)
  addButton('功能设置取消', functionSettingUID)


  ui.show(functionSettingUID, false)
  loadProfile('functionSetting.txt')
end
-- 高级设置
sui.showAdvSetting = function ()
  newLayout(AdvSettingUID)
  addTextView('卡死重试次数 ', AdvSettingUID)
  addEditText('重试次数', '5', AdvSettingUID)
  -- newRow(AdvSettingUID)
  -- addTextView('qq消息通知 ', AdvSettingUID)
  -- addEditText('重试次数', '5', AdvSettingUID)
  newRow(AdvSettingUID)
  addButton('高级配置保存', AdvSettingUID)
  addButton('高级配置取消', AdvSettingUID)

  ui.show(AdvSettingUID, false)
end