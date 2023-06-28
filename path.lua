path = {}

-- finish
path.刷书签 = function ()
  wait(function ()
    stap(point.秘密商店)
    if not findOne('cmp_国服主页Rank') then return true end
  end)
  log('进入神秘商店')
  untilAppear('cmp_国服神秘商店立即更新')
  ssleep(1)
  -- 开始挂机刷新书签了
  -- mul_国服神秘商店友情书签
  -- mul_国服神秘商店誓约书签
  local target = {'mul_国服神秘商店神秘奖牌', 'mul_国服神秘商店誓约书签'}
  local refreshCount = 100
  local enoughResources = true
  for i=1,refreshCount do
    for i=1,2 do
      local pos = findOne(target, {rg = {538,8,677,713}})
      if pos then
        local newRg = {1147, pos[2] - 80, 1226, pos[2] + 80}
        untilTap('mul_国服神秘商店购买', {rg = newRg})
        untilTap('cmp_国服神秘商店购买')
      end
      -- 资源是否耗尽
      wait(function ()
        local r1, r2 = findOne({'cmp_国服神秘商店购买资源不足', 'cmp_国服神秘商店立即更新'})
        if r2 == 'cmp_国服神秘商店立即更新' then return true end
        if r2 == 'cmp_国服神秘商店购买资源不足' then enoughResources = false return true end
      end)
      if i == 1 and enoughResources then sswipe({858,578}, {858,150}) end
    end
    if not enoughResources then 
      log('资源耗尽!')
      untilTap('cmp_国服神秘商店取消')
      break
    end
    log('刷新: '..i)
    untilTap('cmp_国服神秘商店立即更新')
    untilTap('cmp_国服神秘商店购买确认')
  end
end

path.回到主页 = function ()
  local t
  wait(function ()
    if findOne('cmp_国服主页Rank') then 
      if not t then t = time() end
      if t and time() - t > 2000 then return true end
      return
    end
    findTap({
      'cmp_国服派遣任务重新进行'
      }, {tapInterval = 0})
    if t then t = time() end
    stap(point.退出)
  end, .6)
end

-- need test
path.竞技场 = function ()
  wait(function ()
    stap(point.竞技场)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return true end
  end)
  untilTap('cmp_国服竞技场')
  untilAppear('cmp_国服竞技场配置防御队')
  log('进入竞技场')
  -- 竞技策略
  -- 个人积分
  local privatePoints = untilAppear('ocr_国服竞技场个人积分', {keyword = {'积分', '积', '分'}})
  privatePoints = getArenaPoints(privatePoints[1].text)
  log(privatePoints)
  -- 交战对手切换
  wait(function ()
    stap({1108,116})
    if findOne('mul_国服竞技场挑战', {rg = {879,146,990,686}}) then ssleep(1) return true end
  end, .5)
  
  -- 刷新对手到达次数
  local refreshCount = 25
  wait(function ()
    -- 识别票数
    local ticketFlat = untilAppear('mul_国服竞技场旗帜位置', {rg = {275,8,1042,67}})
    local tmpV, ticket = untilAppear({'mul_国服竞技场票数0', 'mul_国服竞技场票数1', 'mul_国服竞技场票数2', 
                                      'mul_国服竞技场票数3', 'mul_国服竞技场票数4', 'mul_国服竞技场票数5'}, 
                                      {rg = {ticketFlat[1], 5, ticketFlat[1] + 80 , 60}, sim = 1})
    ticket = getArenaPoints(ticket)
    log('所剩票数: '..ticket)
    if ticket == 0 then
      log('票数耗尽')
      -- 是否使用叶子兑换5张票
      -- 是否使用砖石兑换5张票 暂不支持
      if true then
        wait(function ()
          stap({699,32})
          if findOne('cmp_国服竞技场购买票页面') then return true end
        end)
        local tmp, ticketType = untilAppear({'cmp_国服竞技场叶子购买票', 'cmp_国服竞技场砖石购买票'})
        if ticketType == 'cmp_国服竞技场叶子购买票' then 
          log('购票') 
          untilTap('cmp_国服竞技场购买票')
          -- 金币是否够用
          local tmp, v = untilAppear({'cmp_国服神秘商店购买资源不足', 'cmp_国服竞技场配置防御队'})
          if v == 'cmp_国服神秘商店购买资源不足' then log('资源不足') return true end
        end
        if ticketType == 'cmp_国服竞技场砖石购买票' then log('取消购票') untilTap('cmp_国服竞技场取消购票') return true end
        return
      else
        log('不购票')
        return true
      end
    end
    -- 敌人积分
    local enemyPointsInfo = untilAppear('ocr_国服竞技场敌人积分')
    -- 过滤非敌人积分; 敌人积分转换成数字
    enemyPointsInfo = table.filter(enemyPointsInfo, function (v) 
      if v.text:find('积分') or v.text:find('积') or v.text:find('分') then
        local tmp, isChallenge = untilAppear({'mul_国服竞技场已挑战过对手', 'mul_国服竞技场挑战'}, 
                                              {rg = {886, v.t - 50, 990, v.b + 50}})
        if isChallenge == 'mul_国服竞技场挑战' then
          v.text = getArenaPoints(v.text) 
          return true 
        end
       end 
    end)
    log(enemyPointsInfo)
    -- 最终需要的: 小于个人积分就行
    local finalPointsInfo = table.filter(enemyPointsInfo, function (v) return v.text < privatePoints end)
    -- 没有小于自己的
    -- 要么手动花费金币刷新，要么等待刷新8分钟
    if #finalPointsInfo == 0 then
      if true then
        local result = untilAppear('ocr_国服刷新挑战', {keyword = {'免费', '剩余时间', '时间', '剩余'}})[1]
        untilTap('ocr_国服刷新挑战')
        if result.text:includes({'剩余时间', '剩余', '时间'}) then
          local availableRefreashCount = math.floor(getArenaPoints(untilAppear('ocr_国服竞技场挑战对手剩余刷新次数')[1].text) / 100)
          if refreshCount == availableRefreashCount or availableRefreashCount == 0 then log('对手更换次数已上限!') return true end
        end
        untilTap('cmp_国服竞技场切换对手确定')
        -- 金币是否耗尽
        local tmp, v = untilAppear({'cmp_国服神秘商店购买资源不足', 'cmp_国服竞技场配置防御队'})
        if v == 'cmp_国服神秘商店购买资源不足' then log('资源不足') untilTap('cmp_国服神秘商店取消') return true end
        -- 更新完对手, 开始新的一轮
        return
      else
        log('无低于自己积分')
        return true
      end
    end
    finalPointsInfo = finalPointsInfo[1]
    untilTap('mul_国服竞技场挑战', {rg = {886, finalPointsInfo.t - 50, 990, finalPointsInfo.b + 50}})
    untilTap('cmp_国服竞技场战斗开始')
    path.战斗代理()
  end, .5, nil, true)
  
end

-- need test
path.战斗代理 = function ()
  log('战斗开始')
  -- 开启auto
  untilAppear('cmp_国服Auto')
  wait(function ()
    stap('cmp_国服Auto')
    ssleep(1)
    if findOne(point.国服AUto成功) then return true end
  end)

  -- 等待结束
  -- 每次限定超时战斗为5分钟
  wait(function ()
    -- 部分会有一个结束前置页, 直接点击掉
    stap({615,23})
    -- 竞技场特殊
    findTap('cmp_国服竞技场挑战升级')
    if findTap({'cmp_国服战斗完成竞技场确定', 'cmp_国服战斗完成确定'}) then return true end
  end, game_running_capture_interval, 5 * 60)
  log('战斗代理完成')
end

-- finish
path.免费领养宠物 = function ()
  if not findOne('cmp_国服宠物小屋红点') then log('无宠物领取') return end
  wait(function ()
    stap(point.宠物小屋)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return true end
  end)
  untilTap('cmp_国服宠物领养')
  wait(function ()
    stap('cmp_国服宠物免费领养')
    if not findOne('cmp_国服宠物免费领养') or findOne('cmp_国服宠物背包不足') then return true end
  end)
  -- 免费领取一次
  wait(function ()
    stap({46,462})
    if findOne('cmp_国服宠物领养') then return true end
  end)
end

-- todo 每日成就
path.成就领取 = function ()
  if not findOne({'cmp_国服成就红点', 'cmp_国服成就红点2'}) then return true end
  wait(function ()
    stap(point.成就)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return true end
  end)
  untilAppear('cmp_国服声誉总分下方花')
  local target = {'cmp_国服三姐妹日记', 'cmp_国服记忆之根管理院', 'cmp_国服元老院', 'cmp_国服商人联盟', 'cmp_国服特务幻影队'}
  for i,v in pairs(target) do
    local curTarget
    wait(function ()
      stap(v)
      curTarget = findOne('ocr_国服成就类型')
      if curTarget and v:find(curTarget[1].text) then return true end
    end)
    -- 三姐妹日记比较特殊
    if findOne(v) then
      if v == 'cmp_国服三姐妹日记' then
        local targ = {'cmp_国服每日成就', 'cmp_国服周成就'}
        for i,v in pairs(targ) do
          untilTap('cmp_国服每日每周小红球', {rg = {415,141,946,185}})
          wait(function ()
            stap({574,40})
            if findOne('cmp_国服声誉总分下方花') then return true end
          end)
        end
      else
        wait(function ()
          findTap('cmp_国服成就领取绿色')
          if findOne('cmp_国服成就前往灰色') then return true end
          stap({574,40})
        end)
      end
    end
  end
end

-- finish
path.宠物礼盒 = function ()
  if not findOne('cmp_国服宠物礼盒') then return true end
  wait(function ()
    stap('cmp_国服宠物礼盒')
    if not findOne('cmp_国服宠物礼盒') then return true end
  end)
end

-- finish
path.收取邮件 = function ()
  if not findOne({'cmp_国服邮件', 'cmp_国服邮件2'}) then return true end
  wait(function ()
    stap(point.邮件)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return true end
  end)
  untilAppear('cmp_国服邮件页面')
  wait(function ()
    stap({911,87})
    if findTap('cmp_国服邮件领取确认蓝底') then return true end
  end)
  wait(function ()
    stap({563,85})
    if findOne('cmp_国服邮件页面') then return true end
  end)
  -- 部分无法用全部领取的
  wait(function ()
    if not findTap('cmp_国服邮件领取绿底') then return true end
    untilTap({'cmp_国服邮件收信', 'cmp_国服邮件领取蓝底', 'cmp_国服邮件页面', 'cmp_国服邮件获得奖励Tip'})
    wait(function ()
      stap({563,85})
      if findOne('cmp_国服邮件页面') then return true end
    end)
  end, 1, 5 * 60, nil, true)
end