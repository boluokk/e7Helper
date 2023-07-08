sui = {}
-- ui事件
suie = {}
parentUid = 'E7Helper '.. os.date('%Y-%m-%d %H:%M:%S')
grindUid = '刷图设置'
-- bin: bid、bname
addButton = function (bin, partid)
  partid = partid or parentUid
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
  pid = pid or parentUid
  ui.newLayout(pid, 720, -2)
end
newRow = function (pid)
  pid = pid or parentUid
  ui.newRow(pid, uuid())
end
addTab = function (pin, pid)
  pid = pid or parentUid
  ui.addTab(pid, pin, pin)
end
addTabView = function (cid)
  ui.addTabView(parentUid,cid)
end
addTextView = function (text, pid)
  pid = pid or parentUid
  ui.addTextView(pid,text,text)
end
addRadioGroup = function (id, data, pid)
  pid = pid or parentUid
  if type(data) ~= 'table' then data = {data} end
  ui.addRadioGroup(pid,id,data,0,-1,70,true)
end
addCheckBox = function (id, selection, pid, defaluValue)
  pid = pid or parentUid
  ui.addCheckBox(pid,id,selection, defaluValue)
end
addEditText = function (id, text, pid)
  pid = pid or parentUid
  ui.addEditText(pid,id,text)
end
saveProfile = function (path)
  ui.saveProfile(root_path..path)  
end
loadProfile =function (path)
  ui.loadProfile(root_path..path)
end
dismiss = function (id) ui.dismiss(id) end

suie.取消 = exit
suie.启动 = function ()
  suie.开启前()
  path.游戏开始()
end
suie.转换数据 = function (data)
  local ans = {}
  for i,v in pairs(data) do
    if tonumber(v) then
      ans[i] = tonumber(v)
    elseif v:find('false') then
      ans[i] = false
    elseif v:find('true') then
      ans[i] = true
    else
      ans[i] = v
    end
  end
  return ans
end
suie.开启前 = function ()
  current_task = suie.转换数据(ui.getData())
  -- 保存配置
  saveProfile('config.txt')
  ui_config_finish = true
  dismiss(parentUid)
end
suie.开始刷书签 = function ()
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
  sui.showGrindSetting()
end
suie.刷新UI = function ()
  local fileNames = {'config.txt'}
  for i,v in pairs(fileNames) do sdelfile(v) end
  reScript()
end
-- 刷图
suie.刷图测试 = function ()
  dismiss(grindUid)
end
sui.show = function ()
  newLayout()
  newRow()
  -- 开源信息
  addTextView('此脚本软件完全免费开源, 可用于代替手操, 去除繁琐的大量重复劳动。\nQQ群: 206490280 \nQQ频道号: 24oyp5x92q \n开源地址: https://gitee.com/boluokk/e7-helper \n使用说明书: https://boluokk.gitee.io/e7-helper')
  newRow()
  -- 服务器
  addTextView('服务器: ')
  local servers = {'国服'}
  addRadioGroup('服务器', servers)
  newRow()
  -- 功能区
  local selections = { -- '圣域派遣'
    '收取邮件', '刷竞技场', '领养宠物', '成就领取',
    '宠物礼盒', '誓约召唤', '圣域收菜', '社团开启',
    '社团签到', '社团奖励', '社团捐赠', 
    --'友情体力', '净化深渊',
  }
  for i,v in pairs(selections) do
    addCheckBox(v, v)
    if i % 3 == 0 then newRow() end
  end

  -- 需要配置及其他功能区
  newRow()
  addTextView('竞技场:')
  addCheckBox('叶子买票', '叶子买票')
  addTextView('刷新交战次数:')
  addEditText('交战剩余次数', '30')
  newRow()
  addTextView('竞技场每周奖励: ')
  addRadioGroup('竞技场每周奖励', {'天空石', '神秘奖牌'})
  -- newRow()
  -- local mission = {'圣域', '探险', '讨伐', '战争'}
  -- addTextView('派遣任务:')
  -- addRadioGroup('派遣任务', mission)
  newRow()
  addTextView('社团捐赠：')
  addRadioGroup('社团捐赠类型', {'金币', '勇气证据', '全部'})
  newRow()
  local tag = {
    '神秘奖牌', '誓约书签', '友情书签'
  }
  addTextView('刷书签: ')
  for i,v in pairs(tag) do 
    if i == 3 then
      addCheckBox(v, v, nil)
    else 
      addCheckBox(v, v, nil, true)
    end
  end
  newRow()
  addTextView('次数:')
  addEditText('更新次数', '333')
  addButton('开始刷书签')
  newRow()
  addButton('使用说明')
  addTextView('  |  ')
  addButton('启动')
  addButton('取消')
  newRow()
  addButton('刷新UI')
  addTextView('  |  ')
  addButton('刷图设置')
  addButton('定时(未做)')
  newRow()
  addButton('刷初始(未做)')
  addButton('清理背包(未做)')
  ui.show(parentUid, false)

  -- load config
  loadProfile('config.txt')
  wait(function ()
    if ui_config_finish then return true end
  end, .05, nil, true)
end

sui.showGrindSetting = function ()
  newLayout(grindUid)
  addButton('刷图测试', grindUid)
  ui.show(grindUid, false)
end


