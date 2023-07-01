sui = {}
-- ui事件
suie = {}
parentUid = 'E7Helper '.. os.date('%Y-%m-%d %H:%M:%S')

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
addCheckBox = function (id, selection, pid)
  pid = pid or parentUid
  ui.addCheckBox(pid,id,selection)
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

suie.取消 = exit
suie.开始 = function () 
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
  ui.dismiss(parentUid)
end
suie.开始刷书签 = function ()
  suie.开启前()
  path.刷书签()
end
sui.show = function ()
  newLayout()
  newRow()
  -- 服务器
  addTextView('服务器: ')
  local servers = {'国服'}
  addRadioGroup('服务器', servers)
  newRow()
  -- 功能区
  local selections = {
    '收取邮件', '刷竞技场', '领养宠物', '成就领取',
    '宠物礼盒', '誓约召唤', '圣域收菜', -- '圣域派遣'
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
  -- newRow()
  -- local mission = {'圣域', '探险', '讨伐', '战争'}
  -- addTextView('派遣任务:')
  -- addRadioGroup('派遣任务', mission)
  newRow()
  local tag = {
    '神秘奖牌', '誓约书签', '友情书签'
  }
  for i,v in pairs(tag) do addCheckBox(v, v) end
  newRow()
  addTextView('次数:')
  addEditText('更新次数', '333')
  addButton('开始刷书签')
  newRow()
  addButton('取消')
  addButton('开始')
  -- newRow()
  -- addTextView('开源地址:   '..open_resource_url)
  ui.show(parentUid, false)

  -- load config
  loadProfile('config.txt')
  wait(function ()
    if ui_config_finish then return true end
  end, .2, nil, true)
end


