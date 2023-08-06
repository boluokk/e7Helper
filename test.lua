
test = function ()
  current_task = uiConfigUnion(fileNames)
  p = findOne('国服战斗级别')
  if p then
    for i=1,#p do
      print(p[i])
    end
  end
  exit()
end
if not disable_test then test() end