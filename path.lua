path = {}

path.游戏开始 = function ()
  path.游戏首页()
  path.任务队列()
end

-- isBack: 通过按back来回退
path.游戏首页 = function ()
  isBack = true
  if not sAppIsRunning(current_server) or not sAppIsFront(current_server) then 
    isBack = false
    open(server_pkg_name[current_server]) 
  end
  setControlBarPosNew(0, 1)
  local clickTarget = {'cmp_国服签到右下蓝底', 'cmp_国服签到右下蓝底2', 'cmp_国服公告X', 'cmp_国服登录第七史诗'}
  local t
  wait(function ()
    if not longAppearMomentDisAppear('cmp_国服主页Rank', nil, nil, 1) then return 1 end
    if not findTap(clickTarget) then
      if not isBack then 
        stap(point.回退) 
      else
        back()
      end
    end
  end, 1, 7 * 60)
end

path.任务队列 = function ()
  local allTask = {
    '收取邮件', '刷竞技场', '领养宠物', '成就领取',
    '宠物礼盒', '誓约召唤', '圣域收菜'
  }
  local curTaskIndex = sgetNumberConfig("current_task_index", 0)
  for i,v in pairs(allTask) do
    if i > curTaskIndex and current_task[v] then
      path[v]()
      slog(v..'完成')
      path.回到主页()
    end
    setNumberConfig('current_task_index', i)
  end
  console.show()
end

-- finish
path.刷书签 = function (rest)
  rest = rest or 0
  setNumberConfig("is_refresh_book_tag", 1)
  path.游戏首页()
  wait(function ()
    stap(point.秘密商店)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  log('进入神秘商店')
  untilAppear('cmp_国服神秘商店立即更新')
  ssleep(1)
  -- 开始挂机刷新书签了
  -- mul_国服神秘商店友情书签
  -- mul_国服神秘商店誓约书签
  local target = {}
  local g1 = sgetNumberConfig("g1", 0)
  local g2 = sgetNumberConfig("g2", 0)
  local g3 = sgetNumberConfig("g3", 0)
  if current_task['神秘奖牌'] then table.insert(target, 'mul_国服神秘商店神秘奖牌') end 
  if current_task['誓约书签'] then table.insert(target, 'mul_国服神秘商店誓约书签') end
  if current_task['友情书签'] then table.insert(target, 'mul_国服神秘商店友情书签') end
  local refreshCount = current_task['更新次数'] or 334
  local enoughResources = true
  local msg
  for i=1,refreshCount do
    if i > rest then
      for i=1,4 do
      local pos, countTarget = findOne(target, {rg = {538,8,677,713}})
      if pos then
        local newRg = {1147, pos[2] - 80, 1226, pos[2] + 80}
        untilTap('mul_国服神秘商店购买', {rg = newRg})
        untilTap('cmp_国服神秘商店购买')
        -- 统计获得物品次数
        if countTarget == 'mul_国服神秘商店神秘奖牌' then
          g1 = g1 + 1
          setNumberConfig("g1", g1)
        elseif countTarget == 'mul_国服神秘商店誓约书签' then
          g2 = g2 + 1
          setNumberConfig("g2", g2)
        elseif countTarget == 'mul_国服神秘商店友情书签' then
          g3 = g3 + 1
          setNumberConfig("g3", g3)
        end
        -- 等待购买特效消失
        wait(function ()
          if not longAppearMomentDisAppear({'cmp_国服神秘商店立即更新', 'cmp_国服神秘商店购买资源不足'}, nil, nil, 1.5) then return 1 end
        end)
      end
      -- 资源是否耗尽
      wait(function ()
        local r1, r2 = findOne({'cmp_国服神秘商店购买资源不足', 'cmp_国服神秘商店立即更新'}, {sim = 1})
        if r2 == 'cmp_国服神秘商店立即更新' then return 1 end
        if r2 == 'cmp_国服神秘商店购买资源不足' then enoughResources = false return 1 end
      end)
      if i == 2 and enoughResources then sswipe({858,578}, {858,150}) ssleep(.5) end
      end
      msg = '刷新次数: '..i..'(神秘奖牌: '..g1..'*5, 誓约书签: '..g2..'*5, 友情书签: '..g3..'*5)'
      if not enoughResources then 
        log('资源耗尽!')
        slog('资源耗尽!')
        untilTap('cmp_国服神秘商店取消')
        break
      end
      -- 刷新次数: 1 (神秘奖牌: 5*5, 誓约书签: 10*5, 友情书签: 20*5)
      log(msg)
      -- 如果网络不好会导致两次点击, 改成 sim = 1
      untilTap('cmp_国服神秘商店立即更新', {sim = 1})
      untilTap('cmp_国服神秘商店购买确认')
      wait(function () findOne('') end, .1, 1.5)
    end
    setNumberConfig("refresh_book_tag_count", i)
  end
  setNumberConfig("refresh_book_tag_count", 0)
  setNumberConfig("is_refresh_book_tag", 0)
  slog(msg)
  console.show()
end

path.回到主页 = function ()
  local t
  wait(function ()
    if findOne('cmp_国服主页Rank') then 
      if not t then t = time() end
      if t and time() - t > 1000 then return 1 end
      return
    end
    findTap({'cmp_国服派遣任务重新进行'}, {tapInterval = 0})
    if t then t = time() end
    -- stap(point.退出)
    back()
  end, .6)
end

-- finish
path.刷竞技场 = function ()
  wait(function ()
    stap(point.竞技场)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  untilTap('cmp_国服竞技场')
  local r1, r2
  wait(function ()
    stap({386,17})
    r1, r2 = findOne({'cmp_国服竞技场配置防御队', 'cmp_国服竞技场每周结算时间', 'cmp_国服竞技场每周排名奖励'})
    if r1 then return 1 end
  end)
  if r2 == 'cmp_国服竞技场每周结算时间' then
    slog('竞技场每周结算时间退出')
    return
  end
  if r2 == 'cmp_国服竞技场每周排名奖励' then
    slog('竞技场获取每周排名奖励')
    local rankIndex = current_task['竞技场每周奖励'] or 0
    local pos = point.国服竞技场每周奖励[rankIndex]
    wait(function ()
      stap(pos)
      if findOne(point.国服竞技场每周奖励判定[rankIndex]) then return 1 end
    end)
    untilTap('cmp_国服竞技场领取每周奖励')
  end
  log('进入竞技场')
  -- 竞技策略
  -- 个人积分
  local privatePoints = untilAppear('ocr_国服竞技场个人积分', {keyword = {'积分', '积', '分'}})
  privatePoints = getArenaPoints(privatePoints[1].text)
  -- log(privatePoints)
  -- 交战对手切换
  wait(function ()
    stap({1108,116})
    if findOne({'mul_国服竞技场挑战', 'mul_国服竞技场再次挑战', 'mul_国服竞技场已挑战过对手'}, {rg = {879,146,990,686}}) then 
      ssleep(1) return 1 
    end
  end, .5)
  
  -- 刷新对手到达次数
  local refreshCount = current_task['交战剩余次数']
  -- 叶子购买票
  local buyTicket = current_task['叶子买票']
  -- 购买切换挑战对手次数，金币
  local buyChangeCount = true
  wait(function ()
    -- 升级可能会卡在这里, 不在下面 path.战斗代理 里面处理, 会导致其他战斗代理出问题
    wait(function ()
      findTap('cmp_国服竞技场挑战升级')
      stap({323,27})
      if findOne('mul_国服竞技场旗帜位置') then return 1 end
    end)
    -- 识别票数
    local ticketFlat = untilAppear('mul_国服竞技场旗帜位置', {rg = {275,8,1042,67}})
    local tmpV, ticket = untilAppear({'mul_国服竞技场票数0', 'mul_国服竞技场票数1', 'mul_国服竞技场票数2', 
                                      'mul_国服竞技场票数3', 'mul_国服竞技场票数4', 'mul_国服竞技场票数5'}, 
                                      {rg = {ticketFlat[1], 5, ticketFlat[1] + 80 , 60}})
    ticket = getArenaPoints(ticket)
    log('所剩票数: '..ticket)
    if ticket == 0 then
      log('票数耗尽')
      -- 是否使用叶子兑换5张票
      -- 是否使用砖石兑换5张票 暂不支持
      if buyTicket then
        wait(function ()
          stap({699,32})
          if findOne('cmp_国服竞技场购买票页面') then return 1 end
        end)
        local tmp, ticketType = untilAppear({'cmp_国服竞技场叶子购买票', 'cmp_国服竞技场砖石购买票'})
        if ticketType == 'cmp_国服竞技场叶子购买票' then 
          log('购票') 
          untilTap('cmp_国服竞技场购买票')
          -- 金币是否够用
          local tmp, v = untilAppear({'cmp_国服神秘商店购买资源不足', 'cmp_国服竞技场配置防御队'})
          if v == 'cmp_国服神秘商店购买资源不足' then log('资源不足') return 1 end
        end
        if ticketType == 'cmp_国服竞技场砖石购买票' then log('取消购票') untilTap('cmp_国服竞技场取消购票') return 1 end
        return
      else
        log('不购票')
        return 1
      end
    end
    -- 敌人积分
    local enemyPointsInfo = untilAppear('ocr_国服竞技场敌人积分')
    -- 过滤非敌人积分; 敌人积分转换成数字
    enemyPointsInfo = table.filter(enemyPointsInfo, function (v) 
      if v.text:find('积分') or v.text:find('积') or v.text:find('分') then
        local tmp, isChallenge = untilAppear({'mul_国服竞技场已挑战过对手', 'mul_国服竞技场挑战', 
                                              'mul_国服竞技场再次挑战'}, {rg = {886, v.t - 50, 990, v.b + 50}})
        if isChallenge == 'mul_国服竞技场挑战' then v.text = getArenaPoints(v.text) return 1 end
       end 
    end)
    -- log(enemyPointsInfo)
    -- 最终需要的: 小于个人积分就行
    local finalPointsInfo = table.filter(enemyPointsInfo, function (v) return v.text < privatePoints end)
    -- 没有小于自己的
    -- 要么手动花费金币刷新，要么等待刷新8分钟
    if #finalPointsInfo == 0 then
      if buyChangeCount then
        local result = untilAppear('ocr_国服刷新挑战', {keyword = {'免费', '剩余时间', '时间', '剩余'}})[1]
        untilTap('ocr_国服刷新挑战')
        if result.text:includes({'剩余时间', '剩余', '时间'}) then
          local availableRefreashCount = math.floor(getArenaPoints(untilAppear('ocr_国服竞技场挑战对手剩余刷新次数')[1].text) / 100)
          if refreshCount == availableRefreashCount or availableRefreashCount == 0 then 
            log('对手更换次数已上限!') 
            untilTap('cmp_国服竞技场取消更换对手') 
            return 1 
          end
        end
        untilTap('cmp_国服竞技场切换对手确定')
        -- 金币是否耗尽
        local tmp, v = untilAppear({'cmp_国服神秘商店购买资源不足', 'cmp_国服竞技场配置防御队'})
        if v == 'cmp_国服神秘商店购买资源不足' then log('资源不足') untilTap('cmp_国服神秘商店取消') return 1 end
        -- 更新完对手, 开始新的一轮
        return
      else
        log('无低于自己积分')
        return 1
      end
    end
    finalPointsInfo = finalPointsInfo[1]
    untilTap('mul_国服竞技场挑战', {rg = {886, finalPointsInfo.t - 80, 990, finalPointsInfo.b + 80}})
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
    if findOne(point.国服AUto成功) then return 1 end
  end)

  -- 等待结束
  -- 每次限定超时战斗为5分钟
  wait(function ()
    -- 部分会有一个结束前置页, 直接点击掉
    stap({615,23})
    if findTap({'cmp_国服战斗完成竞技场确定', 'cmp_国服战斗完成确定'}, {tapInterval = 1}) then return 1 end
  end, game_running_capture_interval, 10 * 60)
  log('战斗代理完成')
end

-- finish
path.领养宠物 = function ()
  if not findOne('cmp_国服宠物小屋红点') then log('无宠物领取') return end
  wait(function ()
    stap(point.宠物小屋)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  untilTap('cmp_国服宠物领养')
  wait(function ()
    stap('cmp_国服宠物免费领养')
    if not findOne('cmp_国服宠物免费领养') or findOne('cmp_国服宠物背包不足') then return 1 end
  end)
  -- 免费领取一次
  wait(function ()
    stap({34,151})
    if findOne('cmp_国服宠物领养') then return 1 end
  end)
end

-- todo 每周成就
path.成就领取 = function ()
  if not findOne({'cmp_国服成就红点', 'cmp_国服成就红点2'}) then log('无成就领取') return 1 end
  wait(function ()
    stap(point.成就)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  untilAppear('cmp_国服声誉总分下方花')
  local target = {'cmp_国服三姐妹日记', 'cmp_国服记忆之根管理院', 'cmp_国服元老院', 'cmp_国服商人联盟', 'cmp_国服特务幻影队'}
  for i,v in pairs(target) do
    local curTarget
    wait(function ()
      stap(v)
      curTarget = findOne('ocr_国服成就类型')
      if curTarget and v:find(curTarget[1].text) then return 1 end
    end)
    -- 三姐妹日记比较特殊
    if v == 'cmp_国服三姐妹日记' then
      local targ = {'cmp_国服每日成就', 'cmp_国服每周成就'}
      local key = {{'每日', '日'}, {'每周', '周'}}
      for i,v in pairs(targ) do
        if findOne(v) then
          -- 切换到 每日/每周点数
          wait(function ()
            stap(v)
            if findOne('ocr_国服每日每周点数', {keyword = key[i]}) then return 1 end
          end)
          untilTap('mul_国服每日每周小红球', {rg = {415,141,946,185}, sim = .98})
          wait(function ()
            stap({574,40})
            if findOne('cmp_国服声誉总分下方花') then return 1 end
          end)
        end
      end
    else
      wait(function ()
        findTap('cmp_国服成就领取绿色')
        if findOne('cmp_国服成就前往灰色') then log(11) return 1 end
        stap({574,40})
      end)
    end
  end
end

-- finish
path.宠物礼盒 = function ()
  if findOne('cmp_国服宠物礼盒') then untilTap('cmp_国服宠物礼盒') else log('无宠物礼盒') end
end

-- finish
path.收取邮件 = function ()
  if not findOne({'cmp_国服邮件', 'cmp_国服邮件2'}) then log('无邮件') return 1 end
  wait(function ()
    stap(point.邮件)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  untilAppear('cmp_国服邮件页面')
  wait(function ()
    stap({911,87})
    if findTap('cmp_国服邮件领取确认蓝底') then return 1 end
  end)
  wait(function ()
    stap({563,85})
    if findOne('cmp_国服邮件页面') then return 1 end
  end)
  -- 部分无法用全部领取的
  wait(function ()
    if not findTap('cmp_国服邮件领取绿底') then return 1 end
    local tmp, target = untilAppear({'cmp_国服邮件收信', 'cmp_国服邮件领取蓝底', 'cmp_国服邮件获得奖励Tip', 'cmp_国服邮件页面', 'cmp_国服邮件领取英雄确定'})
    if target and target ~= 'cmp_国服邮件页面' then untilTap(target) end
    wait(function ()
      stap({563,85})
      findTap('cmp_国服邮件领取英雄确定')
      if findOne('cmp_国服邮件页面') then return 1 end
    end)
  end, 1, 5 * 60, nil, true)
end

-- finish
path.誓约召唤 = function ()
  if not findOne({'cmp_国服召唤小红点'}) then log('无誓约召唤') return 1 end
  wait(function ()
    stap(point.召唤)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  -- 寻找誓约召唤
  local pos, target
  wait(function ()
    sswipe({1141,588}, {1141,100})
    ssleep(1)
    pos = findOne('ocr_国服召唤类型', {keyword = {'誓约召唤', '誓约'}})
    if pos then return 1 end
  end)
  wait(function ()
    stap({pos[1].l, pos[1].t})
    if findOne('cmp_国服10次召唤') then ssleep(1) return 1 end
  end)
  if findTap('cmp_国服免费1次召唤') then untilTap('cmp_国服召唤确认') end
  wait(function ()
    stap({156,659})
    if findOne('cmp_国服10次召唤', {sim = 1}) then return 1 end
  end)
end

path.圣域收菜 = function ()
  if not findOne({'cmp_国服圣域小红点'}) then log('无需收菜') return 1 end
  wait(function ()
    stap(point.圣域)
    ssleep(1)
    if not findOne('cmp_国服主页Rank') then return 1 end
  end)
  path.圣域生产奖励领取()
  path.圣域精灵之森领取()
end

-- finish
path.圣域生产奖励领取 = function ()
  untilAppear('cmp_国服圣域首页')
  log('欧勒毕斯之心处理')
  findTap('cmp_国服欧勒毕斯之心')
  wait(function ()
    stap({649,58})
    if findOne('cmp_国服圣域首页') then ssleep(.5) return 1 end
  end)
end

path.圣域精灵之森领取 = function ()
  log('精灵之森处理')
  local target = {'cmp_国服圣域企鹅蛋', 'cmp_国服圣域精灵之泉', 'cmp_国服圣域种植地', 'cmp_国服圣域种植地收获'}
  if findTap('cmp_国服圣域精灵之森小红点') then
    -- untilAppear('cmp_建筑升级状态')
    wait(function ()
      stap({104,100})
      if findOne('cmp_国服圣域企鹅巢穴') then return 1 end
    end)
    for i,v in pairs(target) do
      if wait(function () if findTap(v) then return true end end, 0, .5) then
        wait(function ()
          stap({104,100})
          if findOne('cmp_国服圣域企鹅巢穴') then return 1 end
        end)
      end
    end
  end
  path.圣域首页()
end

local number = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
-- todo 
path.圣域指挥总部 = function ()
  log('指挥总部处理')
  local target = '讨伐'
  if findTap('cmp_国服圣域指挥总部小红点') then
    untilAppear('cmp_建筑升级状态')
    wait(function ()
      stap(point.圣域指挥总部任务[target])
      if findOne('ocr_国服圣域指挥总部任务选择', {keyword = {target}}) then return 1 end
    end)
    local dispatchLevel = findOne('ocr_国服派遣任务等级')
    local dispatchLevelSort = {'12', '8', '6', '4', '2', '1', '30'}
    if not dispatchLevel then log('无派遣') return 1 end
    if #dispatchLevel > 1 then
      -- 过滤非派遣等级
      dispatchLevel = table.filter(dispatchLevel, 
                                  function (v) if v.text:includes({'所需时间', '小时', '分', '秒'}) and 
                                  findOne('mul_国服派遣执行', {rg = {890, v.t, 980, v.b + 75}}) then return 1 end end)
      -- 根据设置等级查询优先派遣level
      for i,v in pairs(dispatchLevelSort) do
        local result = table.findv(dispatchLevel, function (val) if val.text:includes({v}) then return 1 end end)
        if result then dispatchLevel = result break end
      end
    end
    untilTap('mul_国服派遣执行', {rg = {890, dispatchLevel.t, 980, dispatchLevel.b + 75}})
    untilAppear('cmp_国服派遣执行任务')
    local needLevel = getArenaPoints(untilAppear('ocr_国服派遣所需等级', {keyword = {'Lw', 'L', 'v', 'w'}})[1].text)
    -- 自己配置英雄名称
  end
end

path.圣域首页 = function ()
  wait(function ()
    if findOne('cmp_国服圣域首页') then ssleep(1) return 1 end
    stap({31,32})
    ssleep(2)
  end)
end