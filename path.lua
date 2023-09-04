path = {}

path.游戏开始 = function ()
	path.游戏首页()
	path.任务队列()
end

-- isBack: 通过按back来回退
path.游戏首页 = function ()
	current_server = getUIRealValue('服务器', '服务器')
	if not sAppIsRunning(current_server) or not sAppIsFront(current_server) then
		open(server_pkg_name[current_server])
	end
	setControlBarPosNew(0, 1)
	local clickTarget = {'国服签到右下蓝底', '国服签到右下蓝底2', '国服公告X',
											 '国服登录第七史诗', '国服放弃战斗', '国服结束',
											 '国服神秘商店取消'}
	if wait(function ()
		-- 服务器维护中
		if findOne('国服服务器维护中') then return 'exit' end
		if findOne('国服主页Rank') and not longAppearMomentDisAppear('国服主页Rank', nil, nil, 1) then
			isBack = true
			return 1
		end
		if not findTapOnce(clickTarget, {keyword = {'结束'}}) then
			if not isBack then
				stap(point.回退)
			else
				back()
			end
		end
	end, .5, 7 * 60) == 'exit' then
		slog('服务器维护中...')
		exit()
	end
end

path.任务队列 = function ()
	local allTask = table.filter(ui_option.任务, function (v)
		return not v:includes({'社团签到',
		'社团奖励',
		'社团捐赠'})
	end)
	local curTaskIndex = sgetNumberConfig("current_task_index", 0)
	for i,v in pairs(allTask) do
		if i > curTaskIndex and current_task[v] then
			-- 0 表示异常
			-- 1 或者 nil 表示 ok
			-- 2 表示重做
			if path[v]() == 2 then path.游戏首页() path[v]() end
			slog(v)
			setNumberConfig("exception_count", 1)
			path.游戏首页()
		end
		setNumberConfig('current_task_index', i)
	end
end

path.社团开启 = function ()
	wait(function ()
		stap(point.社团)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	wait(function ()
		if findOne('国服左上骑士团') then ssleep(1) return 1 end
		stap({447,47})
	end)
	
	if current_task.社团签到 then path.社团签到() end
	if current_task.社团捐赠 then path.社团捐赠() end
	if current_task.社团奖励 then path.社团奖励() end
	
end

path.社团签到 = function ()
	if findTap('国服骑士团签到') then
		wait(function ()
			stap({509,35})
			if findOne('国服左上骑士团') then return 1 end
		end)
	end
end

path.社团捐赠 = function ()
	wait(function ()
		stap({1090,414})
		if findOne("500|130|FFFFFF,513|121|FFFFFF,520|132|FFFFFF,544|128|FFFFFF,538|137|FFFFFF") then
			return 1
		end
	end)
	-- 金币
	-- 勇气证据
	-- 都捐赠
	local giveType = current_task.社团捐赠类型
	if giveType == 0 then
		findTap('国服金币捐赠')
	elseif giveType == 1 then
		findTap('国服勇气证据捐赠')
	elseif giveType == 2 then
		findTap('国服金币捐赠')
		wait(function ()
			stap({515,40})
			if findOne('国服左上骑士团') then return 1 end
		end)
		findTap('国服勇气证据捐赠')
	end
	wait(function ()
		stap({515,40})
		if findOne('国服左上骑士团') then return 1 end
	end)
end

path.社团奖励 = function ()
	wait(function ()
		stap({1114,698})
		if findOne('国服骑士团每周任务', {sim = 1}) then return 1 end
	end)
	-- 上方小红点处理, 这个识别的...可以公用
	if findTap('国服每日每周小红球', {rg = {437,140,987,212}, sim = .98}) then
		wait(function ()
			stap({600,81})
			if findOne('国服骑士团每周任务', {sim = 1}) then return 1 end
		end)
	end
	-- 中间领取处理
	-- 好似只用滑动一下, 也就是只有两页
	for i=1,2 do
		wait(function ()
			if findTap('国服骑士团任务领取', {rg = {866,255,990,722}}) then
				wait(function ()
					stap({424,30})
					if findOne('国服骑士团每周任务', {sim = 1}) then return 1 end
				end)
			else
				return 1
			end
		end)
		if i == 1 then sswipe({574,674}, {574,287}) ssleep(.5) end
	end
end

-- 会乱购买东西??
-- 添加标签类型识别判定(召唤)
path.刷书签 = function (rest)
	rest = rest or 0
	setNumberConfig("is_refresh_book_tag", 1)
	path.游戏首页()
	local tapPoint1 = point['秘密商店0']
	local tapPoint2 = point['秘密商店1']
	wait(function ()
		stap(tapPoint1)
		stap(tapPoint2)
		ssleep(1)
		if not findOne('国服主页Rank') then return 1 end
	end)
	log('进入神秘商店')
	untilAppear('国服神秘商店立即更新')
	untilAppear('国服神秘商店第一个商品') ssleep(.5)
	-- 开始挂机刷新书签了
	-- 国服神秘商店友情书签
	-- 国服神秘商店誓约书签
	local target = {}
	local g1 = sgetNumberConfig("g1", 0)
	local g2 = sgetNumberConfig("g2", 0)
	local g3 = sgetNumberConfig("g3", 0)
	-- [国服神秘商店神秘奖牌 国服神秘商店誓约书签]  会导致乱买东西?
	if current_task['神秘奖牌'] then table.insert(target, '神秘') end
	if current_task['誓约书签'] then table.insert(target, '书签') end
	if current_task['友情书签'] then table.insert(target, '国服神秘商店友情书签') end
	local refreshCount = current_task['更新次数'] or 334
	local enoughResources = true
	local msg
	local newRg
	local pos, countTarget
	for i=1,refreshCount do
		if i > rest then
			for i=1,4 do
				-- 可能会出现乱买, 相似度不够高?
				-- 第一排神秘会漏掉? todo
			 	pos, countTarget= findOne(target, {rg = {540,70,669,718}})
				if pos then
					newRg = {1147, pos[2] - 80, 1226, pos[2] + 80}
					point.ocr_标签类型 = {660, pos[2] - 80, 760, pos[2] + 80}
					if not wait(function ()
						if findOne('标签类型', {keyword = {'召唤', '神秘', '书签'}}) then
							return 1
						end
					end, .3, 1) then 
						log('标签类型不正确')
					else
						untilTap('国服神秘商店购买', {rg = newRg})
						untilTap('国服神秘商店购买1')
						-- 等待购买特效消失
						wait(function ()
							if not longAppearMomentDisAppear({'国服神秘商店立即更新', '国服神秘商店购买资源不足', '国服一般商店'}, nil, nil, 1.5) then return 1 end
						end)
					end
				end
				-- 资源是否耗尽
				wait(function ()
					local r1, r2 = findOne({'国服神秘商店购买资源不足', '国服神秘商店立即更新', '国服一般商店'}, {sim = 1})
					if r2 == '国服神秘商店立即更新' then
						-- 统计获得物品次数
						if countTarget then
							if countTarget == '神秘' then
								g1 = g1 + 1
								setNumberConfig("g1", g1)
							elseif countTarget == '书签' then
								g2 = g2 + 1
								setNumberConfig("g2", g2)
							elseif countTarget == '国服神秘商店友情书签' then
								g3 = g3 + 1
								setNumberConfig("g3", g3)
							end
						end
						return 1 
					end
					if r2 == '国服神秘商店购买资源不足' or r2 == '国服一般商店' then 
						-- 提示有东西没有买完
						enoughResources = false
						if countTarget then
							local curTagName = countTarget:split('商店')[2]
							slog('金币不足导致, 有物品没有购买成功: '..curTagName)
						end
						return 1 
					end
				end)
				-- 写死判定，可能会connection导致滑动失效
				if i == 2 and enoughResources then
					wait(function ()
						if findOne({'国服神秘商店第二个商品',
												'国服神秘商店第三个商品',
												'国服神秘商店第四个商品'}, {sim = .99}) then
							return 1
						end
						sswipe({858,578}, {858,150})
					end)
				end
			end
			msg = '刷新次数: '..i..'/'..refreshCount..'(神秘奖牌: '..g1..'*50, 誓约书签: '..g2..'*5, 友情书签: '..g3..'*5)'
			if not enoughResources then
				log('资源耗尽!')
				slog('资源耗尽!')
				-- untilTap('国服神秘商店取消')
				path.游戏首页()
				break
			end
			-- 刷新次数: 1 (神秘奖牌: 5*5, 誓约书签: 10*5, 友情书签: 20*5)
			log(msg)
			slog(msg, nil, true)
			if i == refreshCount then
				path.游戏首页()
				break
			end
			-- 如果网络不好会导致两次点击, 改成 sim = 1
			untilTap('国服神秘商店立即更新', {sim = 1})
			untilTap('国服神秘商店购买确认')
			untilAppear('国服神秘商店第一个商品', {sim = .98}) ssleep(.5)
			setNumberConfig("exception_count", 1)
		end
		setNumberConfig("refresh_book_tag_count", i)
	end
	slog(msg, nil, true)
end

path.刷竞技场 = function ()
	local type = current_task.竞技场次序
	if type == 0 then
		path.竞技场玩家()
	elseif type == 1 then
		path.竞技场NPC()
	elseif type == 2 then
		path.竞技场NPC()
		path.游戏首页()
		path.竞技场玩家()
	end
end

path.竞技场玩家 = function ()
	wait(function ()
		stap(point.竞技场)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	untilTap('国服竞技场')
	local r1, r2
	wait(function ()
		stap({386,17})
		r1, r2 = findOne({'国服竞技场配置防御队', 
											'国服竞技场每周结算时间', 
											'国服竞技场每周排名奖励'})
		if r1 then return 1 end
	end)
	if r2 == '国服竞技场每周结算时间' then
		slog('竞技场每周结算时间退出')
		return
	end
	if r2 == '国服竞技场每周排名奖励' then
		slog('竞技场获取每周排名奖励')
		local rankIndex = current_task['竞技场每周奖励'] or 0
		local pos = point.国服竞技场每周奖励[rankIndex + 1]
		wait(function ()
			stap(pos)
			if findOne(point.国服竞技场每周奖励判定[rankIndex + 1]) then return 1 end
		end)
		untilTap({'国服竞技场领取每周奖励', 'cmp_国际服竞技场领取每周奖励'})
	end
	log('进入竞技场')
	-- 竞技策略
	-- 个人积分
	local privatePoints = untilAppear('国服竞技场个人积分', {keyword = {'积分', '积', '分'}})
	privatePoints = getArenaPoints(privatePoints[1].text)
	-- log(privatePoints)
	-- 交战对手切换
	wait(function ()
		stap({1108,116})
		if findOne({'国服竞技场挑战', 
								'国服竞技场再次挑战', 
								'国服竞技场已挑战过对手'}, 
								{rg = {879,146,990,686}}) then
			ssleep(1)
			return 1
		end
	end, .5)
	-- 刷新对手到达次数
	local refreshCount = current_task['交战次数']
	-- 购买切换挑战对手次数，金币
	local buyChangeCount = true
	wait(function ()
		wait(function ()
			findTap('国服竞技场挑战升级')
			stap({323,27})
			if findOne('国服竞技场旗帜位置') then return 1 end
		end)
		-- 敌人积分
		local enemyPointsInfo = untilAppear('国服竞技场敌人积分')
		-- 过滤非敌人积分; 敌人积分转换成数字
		enemyPointsInfo = table.filter(enemyPointsInfo, function (v)
			if v.text:find('积分') or v.text:find('积') or v.text:find('分') then
				local tmp, isChallenge = untilAppear({'国服竞技场已挑战过对手', '国服竞技场挑战',
				'国服竞技场再次挑战'}, {rg = {886, v.t - 50, 990, v.b + 50}})
				if isChallenge == '国服竞技场挑战' then v.text = getArenaPoints(v.text) return 1 end
			end
		end)
		-- log(enemyPointsInfo)
		-- 最终需要的: 小于个人积分就行
		local finalPointsInfo = table.filter(enemyPointsInfo, function (v) return v.text < privatePoints end)
		-- 没有小于自己的
		-- 要么手动花费金币刷新，要么等待刷新8分钟
		if #finalPointsInfo == 0 then
			if buyChangeCount then
				local result = untilAppear('国服刷新挑战', {keyword = {'免费', '剩余时间', '时间', '剩余'}})[1]
				untilTap('国服刷新挑战')
				if result.text:includes({'剩余时间', '剩余', '时间'}) then
					local availableRefreashCount = math.floor(getArenaPoints(untilAppear('国服竞技场挑战对手剩余刷新次数')[1].text) / 100)
					if refreshCount == 0 then
						slog('对手更换次数已上限!')
						untilTap('国服竞技场取消更换对手')
						return 1
					end
				end
				untilTap('国服竞技场切换对手确定')
				refreshCount  = refreshCount - 1
				-- 金币是否耗尽
				local tmp, v = untilAppear({'国服神秘商店购买资源不足', '国服竞技场配置防御队'})
				if v == '国服神秘商店购买资源不足' then log('资源不足') untilTap('国服神秘商店取消') return 1 end
				-- 更新完对手, 开始新的一轮
				return
			else
				log('无低于自己积分')
				return 1
			end
		end
		finalPointsInfo = finalPointsInfo[1]
		untilTap('国服竞技场挑战', {rg = {886, finalPointsInfo.t - 80, 990, finalPointsInfo.b + 80}})
		untilTap('国服竞技场战斗开始')
		if path.竞技场购票() == 1 then
			return 1
		end
		path.战斗代理()
	end, .5, nil, true)
end

path.竞技场NPC = function ()
	wait(function ()
		stap(point.竞技场)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	wait(function ()
		if not findOne('国服竞技场') then
			return 1
		end
		stap({999,339})
	end)
	local p, v
	wait(function ()
		p, v = findOne({'国服JJC左下剑', 
								 '国服竞技场每周排名奖励'})
		if v == '国服JJC左下剑' then
			return 1
		end
		if v == '国服竞技场每周排名奖励' then
			slog('竞技场获取每周排名奖励')
			local rankIndex = current_task['竞技场每周奖励'] or 0
			local pos = point.国服竞技场每周奖励[rankIndex + 1]
			wait(function ()
				stap(pos)
				if findOne(point.国服竞技场每周奖励判定[rankIndex + 1]) then return 1 end
			end)
			untilTap('国服竞技场领取每周奖励')
		end
	end)
	wait(function ()
		if findOne('国服NPC交战对手') then
			return 1
		end
		stap({1048,216})
	end)

	local pos
	local isSwipe = 1
	while 'qq群206490280' do
		wait(function ()
			findTap('国服竞技场挑战升级')
			stap({323,27})
			if findOne('国服竞技场旗帜位置') then ssleep(1) return 1 end
		end)
		pos = findOne('国服NPC挑战', {rg = {855,141,996,721}})
		if not pos and isSwipe == 2 then break end
		if not pos then
			isSwipe = isSwipe + 1
			wait(function ()
				sswipe({846,498}, {846,206})
				ssleep(1.5)
				if findOne('780|683|FFFFFF,774|674|FFFFFF,774|690|FADD32') then
					return 1				
				end
			end)
		else
			-- 开始刷NPC
			wait(function ()
				stap(pos)
				if not findOne('国服JJC左下剑') then return 1 end
			end)
			untilTap('国服竞技场战斗开始')
			-- 购票
			if path.竞技场购票() == 1 then
				break
			end
			path.战斗代理()
			isSwipe = 1
		end
	end
	slog('竞技场NPC完成')
end

path.竞技场购票 = function ()
	-- 叶子购买票
	local buyTicket = current_task['叶子买票']
	local t,v
	wait (function ()
		stap({615,23})
		t, v = findOne({'国服竞技场购买票页面', '国服Auto'})
		if v then
			return 1
		end
	end)
	-- 是否使用叶子兑换5张票
	-- 是否使用砖石兑换5张票 暂不支持
	if v == '国服竞技场购买票页面' and buyTicket then
		local tmp, ticketType = untilAppear({'国服竞技场叶子购买票', 
																					'国服竞技场砖石购买票'})
		if ticketType == '国服竞技场叶子购买票' then
			log('购票')
			untilTap('国服竞技场购买票')
			-- 金币是否够用
			local tmp, v = untilAppear({'国服神秘商店购买资源不足',
																	'国服竞技场下战斗开始'})
			if v == '国服神秘商店购买资源不足' then log('资源不足') return 1 end
		end
		if ticketType == '国服竞技场砖石购买票' then log('取消购票') untilTap('国服竞技场取消购票') return 1 end
		untilTap('国服竞技场战斗开始')	
	end

	if v == '国服竞技场购买票页面' and not buyTicket then
		log('不购票')
		return 1
	end
end

-- isRepeat 是否重试
-- isAgent 是否代理
-- isActivity 是否是活动, 可能不是布尔值,而是范围
path.战斗代理 = function (isRepeat, isAgent, currentCount, isActivity)
	-- 右下角识别范围
	local rightBottomRegion = isActivity and '国服右下角活动' or '国服右下角'
	log('战斗开始')
	-- 开启auto
	if not isRepeat then
		-- untilAppear('国服Auto')
		wait(function ()
			if findOne('国服Auto') then
				return 1
			end
			stap({638,31})
		end)
		wait(function ()
			stap('国服Auto')
			ssleep(1)
			if findOne(point.国服AUto成功) then return 1 end
		end)
	end
	
	
	if isRepeat then
		wait(function ()
			if findOne('国服二倍速') then return 1 end
			ssleep(1)
			stap('国服二倍速')
		end)
	end
	
	-- 等待结束
	-- 每次限定超时战斗为5分钟
	if not isRepeat then
		wait(function ()
			-- 部分会有一个结束前置页, 直接点击掉
			log('代理中.')
			-- NPC对话点击 
			stap({615,23})
			if findTap({'国服战斗完成竞技场确定', 
									'国服战斗完成确定'}, {tapInterval = 1}) then 
				return 1
			end
		end, game_running_capture_interval, 10 * 60)
	else
		local targetKey = {'战斗开始', '确认', '重新进行', '选择队伍'}
		local target = {'申请好友取消','紧急任务确认','国服背包空间不足', 
										'国服行动力不足', '国服右下角', '国服右下角活动', 
										'国服战斗失败', '国服战斗问号'} -- 好友申请、紧急任务可能会进来
		local pos, targetV
		wait(function ()
			if currentCount then
				log('代理中: '..currentCount..'/'..global_stage_count)
			else
				log('代理中..')
			end
			-- 非托管需要手动点击,才能到达结束页面
			if not isAgent then stap({483,15}) end
			if ((isAgent and findOne('国服重复战斗完成', {keyword = {'重复战斗已结束'}})) or
				 not isAgent) and 
				 findOne({'国服右下角', '国服战斗失败'}, {keyword = {'确认', '重新进行'}}) then
				wait(function ()
					pos, targetV = findOne(target, {keyword = targetKey})
					if not pos then return end
					if targetV:includes({'国服背包空间不足', '国服行动力不足', '国服战斗问号'}) then
						-- 保证不在结束页
						if targetV == '国服战斗问号' and findOne('国服战斗结束左上背包') then
							return
						end
						return 1
					end
					if targetV:includes({'国服右下角', '国服战斗失败'}) then
						findTap({'申请好友取消', '紧急任务确认'}) -- 有可能会进入这里
						stap({pos[1].l, pos[1].t})
					end
					if targetV:includes({'好友申请取消', '紧急任务确认'}) then
						stap(pos)
					end
				end)
				return 1
			end
			-- 其他一些处理
			-- if findOne('国服神兽技能', {sim = .9}) then stap({903,664}) end
			if findTap('国服我的通缉名单') then log('点击通缉名单') end
			if findTap('申请好友取消') then log('好友申请取消') end
			if findTap('紧急任务确认') then log('紧急任务确认') end
		end, game_running_capture_interval, 9999 * 10 * 60) -- 不影响
	end
	log('战斗代理完成')
end

path.领养宠物 = function ()
	if not findOne('国服宠物小屋红点') then log('无宠物领取') return end
		wait(function ()
			stap(point.宠物小屋)
					ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
		end)
		untilTap('国服宠物领养')
		if wait(function ()
			stap('国服宠物免费领养')
			if not findOne('国服宠物免费领养') then return 1 end
			if findOne('国服宠物背包不足') then
				path.宠物背包清理()
				return 2
			end
		end) == 2 then
		return 2
	end
	-- 免费领取一次
	wait(function ()
		stap({34,151})
		if findOne('国服宠物领养') then return 1 end
	end)
end

path.成就领取 = function ()
	if not findOne({'国服成就红点', '国服成就红点2'}) then log('无成就领取') return 1 end
	wait(function ()
		stap(point.成就)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	untilAppear('国服声誉总分下方花')
	local target = {'国服三姐妹日记', '国服记忆之根管理院', '国服元老院', '国服商人联盟', '国服特务幻影队'}
	for i,v in pairs(target) do
		local curTarget
		wait(function ()
			stap(v)
			curTarget = findOne('国服成就类型')
			if curTarget and v:find(curTarget[1].text) then return 1 end
		end)
		-- 三姐妹日记比较特殊
		if v == '国服三姐妹日记' then
			local targ = {'国服每日成就', '国服每周成就'}
			local key = {{'每日', '日'}, {'每周', '周'}}
			for i,v in pairs(targ) do
				if findOne(v) then
					-- 切换到 每日/每周点数
					wait(function ()
						stap(v)
						if findOne('国服每日每周点数', {keyword = key[i]}) then return 1 end
					end)
					untilTap('国服每日每周小红球', {rg = {415,141,946,185}, sim = .98})
					wait(function ()
						stap({574,40})
						if findOne('国服声誉总分下方花') then return 1 end
					end)
				end
			end
		else
			wait(function ()
				findTap('国服成就领取绿色')
				if findOne('国服成就前往灰色') then log(11) return 1 end
				stap({574,40})
			end)
		end
	end
end

path.宠物礼盒 = function ()
	if findOne('国服宠物礼盒') then untilTap('国服宠物礼盒') else log('无宠物礼盒') end
end

path.收取邮件 = function ()
	if not findOne({'国服邮件', '国服邮件2'}) then log('无邮件') return 1 end
	wait(function ()
		stap(point.邮件)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	untilAppear({'国服邮件页面', '国际服邮件'})
	wait(function ()
		stap({911,87})
		if findTap('国服邮件领取确认蓝底') then return 1 end
	end)
	wait(function ()
		stap({563,85})
		if findOne('国服邮件页面') then return 1 end
	end)
	-- 部分无法用全部领取的
	-- 可能会有装备需要清理
	wait(function ()
		if not findTap('国服邮件领取绿底') then return 1 end
		local tmp, target = untilAppear({'国服邮件收信', '国服邮件领取蓝底', '国服邮件获得奖励Tip',
		'国服邮件页面', '国服邮件领取英雄确定', '国服背包空间不足'})
		if target and (target ~= '国服邮件页面' and target ~= '国服背包空间不足')  then untilTap(target) end
		if target and target == '国服背包空间不足'  then
			path.背包处理(function () path.跳转('国服邮件页面') end)
		end
		wait(function ()
			stap({563,85})
			findTap('国服邮件领取英雄确定')
			if findOne('国服邮件页面') then ssleep(.5) return 1 end
		end)
	end, 1, 5 * 60, nil, true)
end

path.誓约召唤 = function ()
	if not findOne({'国服召唤小红点'}) then log('无誓约召唤') return 1 end
	wait(function ()
		stap(point.召唤)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	-- 寻找誓约召唤
	local pos, target
	wait(function ()
		sswipe({1141,588}, {1141,100})
		ssleep(1)
		pos = findOne('国服召唤类型', {keyword = {'誓约召唤', '誓约'}})
		if pos then return 1 end
	end)
	wait(function ()
		stap({pos[1].l, pos[1].t})
		if findOne('国服10次召唤') then ssleep(1) return 1 end
	end)
	if findTap('国服免费1次召唤') then untilTap('国服召唤确认') end
	wait(function ()
		stap({156,659})
		if findOne('国服10次召唤') then return 1 end
	end)
end

path.圣域收菜 = function ()
	if not findOne({'国服圣域小红点'}) then log('无需收菜') return 1 end
	wait(function ()
		stap(point.圣域)
			ssleep(1)
		if not findOne('国服主页Rank') then return 1 end
	end)
	path.圣域生产奖励领取()
	path.圣域精灵之森领取()
end

path.圣域生产奖励领取 = function ()
	untilAppear('国服圣域首页')
	log('欧勒毕斯之心处理')
	wait(function ()
		if findTap('国服欧勒毕斯之心') then
			return 1
		end
	end, .1, 1)
	wait(function ()
		stap({649,58})
		if findOne('国服圣域首页') then ssleep(.5) return 1 end
	end)
end

path.圣域精灵之森领取 = function ()
	log('精灵之森处理')
	local target = {'国服圣域企鹅蛋', '国服圣域精灵之泉', '国服圣域种植地', '国服圣域种植地收获'}
	if findTap('国服圣域精灵之森小红点') then
		-- untilAppear('建筑升级状态')
		wait(function ()
			stap({104,100})
			if findOne('国服圣域企鹅巢穴') then return 1 end
		end)
		for i,v in pairs(target) do
			if wait(function () if findTap(v) then return 1 end end, 0, .5) then
				wait(function ()
					stap({104,100})
					if findOne('国服圣域企鹅巢穴') then return 1 end
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
	if findTap('国服圣域指挥总部小红点') then
		untilAppear('建筑升级状态')
		wait(function ()
			stap(point.圣域指挥总部任务[target])
			if findOne('国服圣域指挥总部任务选择', {keyword = {target}}) then return 1 end
		end)
		local dispatchLevel = findOne('国服派遣任务等级')
		local dispatchLevelSort = {'12', '8', '6', '4', '2', '1', '30'}
		if not dispatchLevel then log('无派遣') return 1 end
		if #dispatchLevel > 1 then
			-- 过滤非派遣等级
			dispatchLevel = table.filter(dispatchLevel,
			function (v) if v.text:includes({'所需时间', '小时', '分', '秒'}) and
			findOne('国服派遣执行', {rg = {890, v.t, 980, v.b + 75}}) then return 1 end end)
			-- 根据设置等级查询优先派遣level
			for i,v in pairs(dispatchLevelSort) do
				local result = table.findv(dispatchLevel, function (val) if val.text:includes({v}) then return 1 end end)
				if result then dispatchLevel = result break end
			end
		end
		untilTap('国服派遣执行', {rg = {890, dispatchLevel.t, 980, dispatchLevel.b + 75}})
		untilAppear('国服派遣执行任务')
		local needLevel = getArenaPoints(untilAppear('国服派遣所需等级', {keyword = {'Lw', 'L', 'v', 'w'}})[1].text)
		-- 自己配置英雄名称
	end
end

path.圣域首页 = function ()
	wait(function ()
		if findOne('国服圣域首页') then ssleep(1) return 1 end
		stap({31,32})
		ssleep(2)
	end)
end

path.友情体力 = function ()
	log('购买体力')
	wait(function ()
		stap(point.商店)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	untilAppear('国服一般商店')
end

path.净化深渊 = function ()
	
end

path.战斗选择页 = function ()
	wait(function ()
		stap(point.战斗)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	untilAppear('国服战斗类型页')
	wait(function ()
		stap({280,260})
		if not findOne('国服迷宫主页', {sim = 1}) then return 1 end
	end)
end

-- 刷图
path.刷图开启 = function ()
	-- 图过滤
	log('开启刷图')
	-- 讨伐
	local stageAll = ui_option.战斗类型
	local currentStage = sgetNumberConfig('current_stage', 1)
	for i,v in pairs(stageAll) do
		if current_task[v] and i >= currentStage then
			if v:includes({'讨伐', '迷宫', '精灵祭坛', '深渊'}) then
				path.战斗选择页()
				wait(function ()
					stap(point.战斗模式位置[v])
					if findOne('国服战斗类型', {keyword = cutStringGetBinWord(v)}) then return 1 end
				end)
			end
			if path[v]() ~= 0 then
				slog(v..'完成')
			else
				slog(v..'未完成')
			end
			-- 重置刷图次数
			setNumberConfig("fight_count", 0)
			sgetNumberConfig('current_stage', i)
			path.游戏首页()
		end
	end
end

path.战斗滑图 = function (levelTarget)
		-- 确定滑动到最上层
	wait(function ()
		sswipe({835,100}, {835,3000})
		ssleep(1)
		return findOne('关卡顶部')
	end, 0)
	-- 遍历级别
	local newTextVal
	-- 新值重复次数
	local newTextValReCount = 0
	local curTextVal
	wait(function ()
		wait(function ()
			curTextVal = findOne('国服战斗级别')
			if curTextVal then curTextVal = curTextVal[1].text return 1 end
		end, .05, .3)
		if curTextVal and curTextVal:find(levelTarget) then return 1 end
		if not newTextVal then
			newTextVal = curTextVal
			newTextValReCount = newTextValReCount + 1
		else
			if newTextVal == curTextVal then
				newTextValReCount = newTextValReCount + 1
			else
				newTextVal = curTextVal
				newTextValReCount = 0
			end
			if newTextValReCount == 3 then
				sswipe({835,100}, {835,3000})
				ssleep(1)
				newTextVal = nil
				newTextValReCount = 0
			end
		end
		p = findOne('国服级别光圈')
		if p then p = {p[1], p[2] + 50} stap(p) ssleep(1) end
	end, 0, 5 * 60)

	-- 0 表示此图并未打过
	local selectGroup
	if not wait(function ()
		return wait(function ()
			if findTapOnce('国服短选择队伍', {rg = {988,600,1278,717}}) then
				return wait(function ()
					if not findOne('国服短选择队伍', {rg = {988,600,1278,717}}) then return 1 end
				end, .3, 5)
			end
		end)
	end, .5, 5) then
		log('未开启关卡')
		slog('未开启关卡')
		return 0
	end
end

path.战斗跑图1 = function (typeTarget, levelTarget, fightCount, isActivity)
	-- local p
	-- local key = {'阶段', '祭坛', '区域', '讨伐'}
	-- 关卡
	if typeTarget then
		for i=1,3 do
			if wait(function ()
				if findTap(typeTarget, {rg = point.国服战斗类型区域, sim = .9}) then return 1 end
				swipeEndStop({834,686}, {834,300}, .3)
				ssleep(1)
			end, 1, 5) then
				break
			else
				sswipe({835,300}, {835,2000})
				ssleep(1)
			end
			if i == 3 then slog('关卡可能未到开启时间') return 0 end
		end
	end
	untilAppear('国服短选择队伍', {rg = {988,600,1278,717}})

	if path.战斗滑图(levelTarget) == 0 then
		return 0
	end

	path.通用刷图模式1(fightCount, isActivity, levelTarget)
end

-- 跑图模式1
-- 讨伐 精灵祭坛
-- 834,686 834,147
-- fightCount: 10
path.通用刷图模式1 = function (fightCount, isActivity, levelTarget)
	global_stage_count = fightCount
	local rightBottomRegion = isActivity and '国服右下角活动' or '国服右下角'
	untilAppear(rightBottomRegion, {keyword = {'战斗开始'}})	ssleep(.5)
	-- 这里如果有的话,就处理
	local isAgent = path.托管处理(isActivity)
	local pos, noAct
	if wait(function ()
		pos, noAct = findOne({'国服背包空间不足', '国服行动力不足', rightBottomRegion}, {keyword = {'战斗开始', '选择队伍'}})
		if noAct == '国服行动力不足' then
			slog('行动力不足')
			log('行动力不足!')
			if path.补充体力() == 0 then return 0 end
		end
		if noAct == '国服背包空间不足' then return 1 end
		if noAct == rightBottomRegion then stap({pos[1].l, pos[1].t}) end
		if findOne({'国服二倍速', '国服一倍速'}) then return 1 end
	end) == 0  then
		return 0
	end
	local tmp, noAction
	wait(function ()
		tmp, noAction = findOne({'国服背包空间不足', '国服二倍速', '国服一倍速'})
		if noAction then return 1 end
	end)

	local staticTarget = {'国服背包空间不足', '国服二倍速', '国服行动力不足', '国服一倍速'}

	local currentCount = sgetNumberConfig('fight_count', 1)
	while currentCount <= fightCount do
		if noAction ~= '国服背包空间不足' then
			path.战斗代理(1, isAgent, currentCount, isActivity)
			log('完成次数: '..currentCount)
		end
		local retCode = wait(function ()
			-- 疲劳问题
			wait(function ()
				tmp, noAction = findOne(staticTarget)
				if noAction then return 1 end
			end)
			-- 行动力
			if noAction == '国服行动力不足' then
				slog('行动力不足')
				log('行动力不足!')
				if path.补充体力() == 0 then return 0 end
				-- 需要点击进图
				wait(function ()
					if findOne(staticTarget) then
						return 1
					end
					if findOne(rightBottomRegion, {keyword = '战斗开始'}) then
						stap({1150,659})
					end
				end)
			end
			-- 判定背包类型
			if noAction == '国服背包空间不足' then
				-- 是否是后记：后记比较特殊, 背包清理后会到准备战斗页面
				path.背包处理(function ()
						wait(function ()
							stap({487,18})
							return findOne('国服返回箭头')
						end)
						if levelTarget == '后记' then
							-- 第一次不会到未记载的故事
							local rvb, res = untilAppear({'国服未记载的故事', '国服左上准备战斗'})
							if res == '国服未记载的故事' then
								wait(function ()
									findTapOnce('后记准备战斗')
									return wait(function ()
										if not findOne('后记准备战斗') then return 1 end
									end, .5, 5)
								end)
							end
						else
							local rvb, res = untilAppear({'国服级别光圈', '国服左上准备战斗'})
							if res == '国服级别光圈' then
								path.战斗滑图(levelTarget)
							end
						end
				end)
				-- 再次点击，可能还会出现背包问题
				-- 一二倍数: return 1
				-- 行动、背包空间不足: 直接return 0
				local pos
				local resultCode = wait(function ()
					pos = findOne(rightBottomRegion, {keyword = {'战斗开始', '准备战斗', '选择队伍'}})
					if pos then stap({pos[1].l, pos[1].t}) ssleep(1) end
					tmp, noAction = findOne(staticTarget)
					if noAction == '国服二倍速' or noAction == '国服一倍速' then return 1 end
					if noAction == '国服行动力不足' or noAction == '国服背包空间不足' then return 0 end
				end)
				if resultCode == 1 then return 1 end
				if resultCode == 0 then return end
			end
			return 1
		end, 1, 5 * 60)
		if retCode == 0 then
			return 0
		end
		if retCode == 1 then
			currentCount = currentCount + 1
			setNumberConfig("fight_count", currentCount)
		end
	end
end

path.补充体力 = function ()
	local energyType = current_task.补充行动力类型
	local targetRg = {352,237,935,456}
	local pos
	if energyType == 2 then slog('不补充行动力') return 0 end
	if energyType == 0 then
		if not wait(function ()
			pos = findOne('国服行动力叶子', {rg = targetRg})
			if pos then stap(pos) return 1 end
		end, .1, 3) then
		slog('未能补充行动力')
		return 0
	end
	end
	if energyType == 1 then
		-- 存在叶子
		-- 不存在叶子
		if not wait(function ()
			pos = findOne({'国服行动力叶子', '国服行动力砖石'}, {rg = targetRg})
			if pos then stap(pos) return 1 end
		end) then
		slog('未能补充行动力')
		return 0
		end
	end
	-- 点击确认
	-- 可能有bug, 如果叶子和砖石都没有了
	-- untilTap('国服竞技场购买票')
	if not wait(function ()
		if findTap('国服竞技场购买票') then return 1 end
	end, .1, 8) then
		slog('购买行动力失败')
		return 0
	end
	return 1
end

path.托管处理 = function (isActivity)
	log('托管处理')
	local greenPos
	local isAgent
	-- 活动的位置可能不一样
	local trg = isActivity or {563,528,685,584}
	if not wait(function ()
		greenPos = findOne('国服是否可自动挂机', {rg = trg, sim = .85})
		if greenPos then return 1 end
	end, .1, 1) then
		log('未找到托管')
		slog('未找到托管')
	else
		isAgent = 1
		wait(function ()
			if findOne('国服重复战斗绿色', {rg = trg, sim = .9}) then 
				return 1 
			end
			stap(greenPos)
		end)
	end
	return isAgent
end

-- 跑图模式2
path.通用刷图模式2 = function ()
	print('todo')
end

-- 跑图
path.讨伐 = function ()
	local type = '国服'..getUIRealValue('讨伐关卡类型', '讨伐类型')
	local level = getUIRealValue('讨伐级别', '讨伐级别')
	local fc = current_task.讨伐次数
	return path.战斗跑图1(type, level, fc)
end

path.精灵祭坛 = function ()
	local type = '国服'..getUIRealValue('精灵祭坛关卡类型', '精灵祭坛类型')..'精灵'
	local level = getUIRealValue('精灵祭坛级别', '精灵祭坛级别')
	local fc = current_task.精灵祭坛次数
	return path.战斗跑图1(type, level, fc)
end

path.净化深渊 = function ()
	wait(function ()
		stap(point.战斗)
				ssleep(1)
			if not findOne('国服主页Rank') then return 1 end
	end)
	path.战斗选择页()
	wait(function ()
		stap(point.战斗模式位置['深渊'])
		if findOne('国服战斗类型', {keyword = cutStringGetBinWord('深渊')}) then return 1 end
	end)
	if findTap('国服深渊净化') then
		untilTap('国服深渊净化确认')
	end
end

path.宠物背包清理 = function ()
	wait(function ()
		stap({1160,668})
		if findOne('国服宠物自动补满') then
			return 1
		end
	end)
	
	wait(function ()
		stap('国服宠物自动补满')
		ssleep(1)
		if findOne('国服设置自动填充目标') then return 1 end
	end)
	
	path.过滤背包选择(ui_option.宠物级别, '国服宠物')
	-- 特殊造型
	wait(function ()
		if findOne('国服不包含特点造型宠物') then return 1 end
		stap('国服不包含特点造型宠物')
	end)
	
	wait(function ()
		stap({995,657})
		if not findOne('国服设置自动填充目标') then
			return 1
		end
	end)
	
	-- 可能没有配置
	if not wait(function ()
		if findTap('国服释放宠物') then
			return 1
		end
	end, .5, 5) then
		return
	end
	wait(function ()
		if findTap('国服邮件领取确认蓝底') then
			return 1
		end
	end, .5, 5)
end

path.清理装备背包 = function ()
	wait(function ()
		stap({341,88})
		return findOne('国服背包主页')
	end)
	wait(function ()
		if findOne('国服背包全部') then
			return 1
		end
		stap({186,164})
	end, 1)
	wait(function ()
		if findOne('国服背包装备自动选择') then
			return 1
		end
		stap({1081,157})
	end)
	wait(function ()
		if not findOne('国服背包装备自动选择') then
			return 1
		end
		stap('国服背包装备自动选择')
	end)
	path.过滤背包选择(ui_option.装备类型, '国服')
	path.过滤背包选择(ui_option.装备等级, '国服')
	path.过滤背包选择(ui_option.装备强化等级, '国服')
	
	local weaponType = {
	'185|231|00CB64',
	'185|284|00CB64',
	'185|336|00CB64',
	'185|389|00CB64',
	'185|444|00CB64',
	'186|496|00CB64',
	}
	
	for i,v in pairs(weaponType) do
		local pos = string.split(v, '|')
		pos = {tonumber(pos[1]), tonumber(pos[2])}
		wait(function ()
			if findOne(v) then return 1 end
			stap(pos)
		end)
	end
	
	wait(function ()
		if findOne('国服背包装备自动选择') then
			return 1
		end
		stap({334,90})
	end)
	
	-- 可能没有配置
	if not wait(function ()
		if findTap('国服装备出售') then
			return 1
		end
	end, .5, 5) then
		return
	end
	wait(function ()
		if findTap('国服出售确认') then
			return 1
		end
	end, .5, 5)
end

path.清理英雄背包 = function (count, filterFunc)
	count = count or 1

	wait(function ()
		stap({1019,666})
		if findOne('国服传送英雄') then return 1 end
	end)
	
	wait(function ()
		stap({1081,89})
		ssleep(1)
		if findOne('715|210|44C8FD,715|260|45CBFE,715|312|44C8FD') then
			return 1
		end
	end)
	-- 过滤等级
	if not filterFunc then
		path.过滤背包选择(ui_option.英雄等级, '国服英雄')
	else
		filterFunc()
	end
	
	-- 特殊设置
	local specialSetting = {
		'883|605|00CB64', -- 隐藏收藏英雄
		'883|657|00CB64', -- 隐藏亲密度10
		'587|657|00CB64', -- 隐藏MAX等级
	}
	for i,v in pairs(specialSetting) do
		local pos = string.split(v, '|')
		pos = {tonumber(pos[1]), tonumber(pos[2])}
		wait(function ()
			if findOne(v) then return 1 end
			stap(pos)
		end)
	end
	
	for i=1,count do
		wait(function ()
			stap({548,34})
			if findOne('国服传送英雄') then return 1 end
		end)
		
		if wait(function ()
			if longDisappearMomentTap("1052|242|7E411F", nil, nil, 2) then
				-- 未填满处理
				wait(function ()
					if findTap('国服传送英雄') then
						return 1
					end
				end, .3, 5)
				wait(function ()
					if findTap('国服英雄传送确认') then
						return 1
					end
				end, .3, 5)			
				return 0
			end
			if findOne('714|543|41C2FC') then
				return 1
			end
			stap({1121,273})
		end) == 0 then
			log('无英雄传送')
			slog('无英雄传送')
			return 
		end
		
		wait(function ()
			stap({548,34})
			if findOne('国服传送英雄') then return 1 end
		end)
		
		-- 可能没有配置
		if not wait(function ()
			if findTap('国服传送英雄') then
				return 1
			end
		end, .3, 5) then
			return
		end
		wait(function ()
			if findTap('国服英雄传送确认') then
				return 1
			end
		end, .3, 5)
	end
end

path.清理神器背包 = function ()
	untilAppear('国服背包主页')
	wait(function ()
		if findOne('国服背包全部') then
			return 1
		end
		stap({186,164})
	end, 1)
	wait(function ()
		if findOne('国服背包装备自动选择') then
			return 1
		end
		stap({1081,157})
	end)
	wait(function ()
		if not findOne('国服背包装备自动选择') then
			return 1
		end
		stap('国服背包装备自动选择')
	end)
	path.过滤背包选择(ui_option.神器星级, '国服神器')
	path.过滤背包选择(ui_option.神器强化, '国服神器强化')
	wait(function ()
		if findOne('国服背包装备自动选择') then
			return 1
		end
		stap({332,86})
	end)
	-- 可能没有配置
	if not wait(function ()
		if findTap('国服神器出售') then
			return 1
		end
	end, .5, 5) then
		return
	end
	wait(function ()
		if findTap('国服出售确认') then
			return 1
		end
	end, .5, 5)
end
-- 过滤等级或者类型
-- level：级别table
-- target: 目标前缀
path.过滤背包选择 = function (level, target)
	for i,v in pairs(level) do
		local target = target..v
		if current_task[v] then
			wait(function ()
				if findOne(target) then return 1 end
				stap(target)
			end)
		else
			wait(function ()
				if not findOne(target) then
					return 1
				end
				stap(target)
			end)
		end
	end
end

-- target: 需要选择的
path.过滤背包自定义选择 = function (level, targetName, target)
	if type(target) ~= 'table' then target = {target} end
	for i,v in pairs(level) do
		local targetPos = targetName..v
		if targetPos:includes(target) then
			wait(function ()
				if findOne(targetPos) then return 1 end
				stap(targetPos)
			end)
		else
			wait(function ()
				if not findOne(targetPos) then
					return 1
				end
				stap(targetPos)
			end)
		end
	end
end

path.跳转 = function (target, config)
	wait(function ()
		if not longAppearMomentDisAppear(target, config, nil, 1) then return 1 end
		back()
	end, 2, 5 * 60)
end

-- backFunc: 返回函数
path.背包处理 = function (backFunc)
	-- 识别背包类型
	slog('清理背包空间')
	log('清理背包空间!')
	local bagSpaceType
	local bagKey = {'英雄', '装备', '神器'}
	wait(function ()
		bagSpaceType = findOne('背包满类型', {keyword = bagKey})
		if bagSpaceType then
			bagSpaceType = bagSpaceType[1].text
			return 1
		end
	end)
	-- 进入背包
	untilTap('国服背包空间不足')
	-- 处理背包
	-- print(bagSpaceType)
	if bagSpaceType:includes({'英雄'}) then
		path.清理英雄背包()
	elseif bagSpaceType:includes({'装备'}) then
		path.清理装备背包()
	elseif bagSpaceType:includes({'神器'}) then
		path.清理神器背包()
	end
	backFunc()
end

path.升3星狗粮 = function ()
	path.游戏首页()
	-- 升 + 传送 ?
	setNumberConfig("is_refresh_book_tag", 2)
	local upgradeCount = current_task.升3星狗粮个数
	local type = current_task.升3星狗粮类型
	if type == 0 or type == 2 then
		path.升狗粮_3(upgradeCount)
	end
	if type == 1 or type == 2 then
		path.游戏首页()
		if not path.打开右侧栏('右侧栏英雄') then
			return
		end
		-- 直接清理完3星的
		path.清理英雄背包(1352955539, function ()
			path.过滤背包自定义选择(ui_option.英雄等级, '国服英雄', {3})
		end)
	end
end

path.升狗粮_3 = function (upgradeCount)
	if not path.打开右侧栏('右侧栏英雄') then
		return
	end
	wait(function ()
		if findOne('714|209|45CBFE,716|261|44C8FD,715|312|44C8FD') then
			return 1
		end
		stap({1085,89})
	end)
	-- 过滤等级
	path.过滤背包自定义选择(ui_option.英雄等级, '国服英雄', {2})
	
	-- 特殊设置
	local specialSetting = {
		'883|605|00CB64', -- 隐藏收藏英雄
		'883|657|00CB64', -- 隐藏亲密度10
		-- '587|657|00CB64', -- 隐藏MAX等级
		'590|604|201F1A' -- 关闭缩小画面
	}

	for i,v in pairs(specialSetting) do
		local pos = string.split(v, '|')
		pos = {tonumber(pos[1]), tonumber(pos[2])}
		wait(function ()
			if findOne(v) then return 1 end
			stap(pos)
		end)
	end

	wait(function ()
		if findOne('国服英雄觉醒') then
			return 1
		end
		stap({485,31})
	end)

	-- 还有个资源不足
	local target = {'国服英雄升级企鹅不足', '国服神秘商店购买资源不足', '国服英雄升级银花不足', 
								  '国服英雄升级2', '国服英雄升级3', '国服英雄左上3星'}
	local tkey = {'资源不足', '不足'}
	local curIdx = sgetNumberConfig('upgrade_3x_hero', 0)
	for i=1,upgradeCount do
		if i > curIdx then
			if not wait(function ()
				if not findOne('国服英雄左上3星') then
					return 1
				end
				stap({1063,243})
			end, .1, 5) then
				log('无2星英雄')
				slog('无2星英雄')
				return
			end
			untilTap('国服英雄升级1')
			local t, v
			if wait(function ()
				t, v = findOne(target, {rg = {16,73,385,174}, keyword = tkey})
				if v == '国服英雄左上3星' then
					log('升级2星个数: '..i..'/'..upgradeCount)
					return 1
				end
				if  v == '国服英雄升级企鹅不足' or 
						v == '国服神秘商店购买资源不足' or 
						v == '国服英雄升级银花不足' then
						-- log(v)
						log('资源不足')
						slog('资源不足')
						return 0
				end
				stap({997,664})
				stap(t)
			end) == 0 then
				return
			end
			setNumberConfig("upgrade_3x_hero", i)
		end
	end
end

path.打开右侧栏 = function (pos)
	if not findOne('国服主页Rank') then
		log('未在首页')
		return 
	end
	wait(function ()
		if findOne('国服右侧栏打开') then
			return 1
		end
		stap({1241,32})
	end)
	wait(function ()
		if not findOne('国服右侧栏打开') then
			return 1
		end
		stap(point[pos])
	end)
	return 1
end

path.购买企鹅 = function ()
	path.游戏首页()
	wait(function ()
		stap({247,214})
		return findOne('327|239|5B80C4,316|240|BF898F,335|238|4CEAFF')
	end)
	-- 开始购买
	-- 不再显示点击
	local noTipTap = false
	wait(function ()
		if findOne('612|638|F4A300,680|637|FBA900') then
			log('红叶消耗完')
			slog('红叶消耗完')
			return 1
		end
		if not noTipTap and findTap('814|549|0E4810,833|551|0F4C12,816|562|1CCF5E,830|561|149F35') then
			noTipTap = true
		end
		stap({903,280})
	end, .5, nil, true)
end

path.游戏社区 = function ()
	wait(function ()
		stap(point.活动)
		ssleep(1)
		return not findOne('国服主页Rank')
	end)
	wait(function ()
		
	end)
	-- 浏览帖子 + 点赞
	-- 签到
end

path.后记 = function ()
	wait(function ()
		stap(point.支线故事)
		ssleep(1)
		return not findOne('国服主页Rank')
	end)

	wait(function ()
		stap({1243,415})
		stap({350,28})
		return findTap('后记冒险')
	end)

	wait(function () return findTapOnce('后记准备战斗') end)

	-- longAppearAndTap('国服长选择队伍', nil, nil, 2)
	wait(function ()
		findTapOnce('国服长选择队伍')
		return wait(function ()
			if not findOne('国服长选择队伍') then return 1 end
		end, .5, 5)
	end)

	local fightCount = current_task.后记次数
	return path.通用刷图模式1(fightCount, nil, '后记')
end

path.活动 = function ()
	local fc = current_task.活动次数
	wait(function ()
		stap(point.支线故事)
		ssleep(1)
		return not findOne('国服主页Rank')
	end)
	local e, w
	wait(function ()
		stap({61,187})
		stap({1059,285})
		e, w = findOne({'活动首页', '活动冒险'}, {keyword = '序幕'})
		return w
	end)
	-- 判定是哪一种活动
	if w == '活动冒险' then
		log('活动-默认关卡')
		wait(function ()
			stap({1166,661})
			return findOne('后记准备战斗')
		end)
		wait(function ()
			findTapOnce('后记准备战斗')
			return wait(function ()
			if not findOne('后记准备战斗') then return 1 end
			end, .5, 5)
		end)
		wait(function ()
				findTapOnce('国服长选择队伍')
				return wait(function ()
				if not findOne('国服长选择队伍') then return 1 end
			end, 1, 4)
		end)
		return path.通用刷图模式1(fc, nil, '后记')
	elseif w == '活动首页' then
		log('活动-可选关卡')
		wait(function ()
			stap({994,657})
			return findOne('国服右下角', {keyword = '战斗开始'})
		end)
		local level = getUIRealValue('活动级别', '活动级别')
		return path.战斗跑图1(nil, level, fc, {175,613,357,714})
	end
end