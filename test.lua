
test = function ()
  current_task = uiConfigUnion(fileNames)
  p = findOne('国服级别光圈')
  if p then point.ocr_国服战斗级别 = {p[1] - 130, p[2] - 100, p[1] + 130, p[2]} p = {p[1], p[2] + 50} end
  print(point.ocr_国服战斗级别)
  print(findOne('国服战斗级别')[1])
  exit()
end
if not disable_test then test() end