test = function ()

    local ticketFlat = untilAppear('mul_国服竞技场旗帜位置', {rg = {275,8,1042,67}})
    local tmpV, ticket = untilAppear({ 'mul_国服竞技场票数1', 'mul_国服竞技场票数2', 
                                      'mul_国服竞技场票数3', 'mul_国服竞技场票数4', 'mul_国服竞技场票数5'}, 
                                      {rg = {ticketFlat[1], 5, ticketFlat[1] + 80 , 60}, sim = 1})
    ticket = getArenaPoints(ticket)
    log('所剩票数: '..ticket)
    exitScript()
  path.竞技场()
end

if not disable_test then test() end