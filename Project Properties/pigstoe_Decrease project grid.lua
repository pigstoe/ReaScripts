-- Description: Decrease project grid
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local _, grid = reaper.GetSetProjectGrid(0, false)
  
  if grid > 0.0078125 then
    reaper.GetSetProjectGrid(0, true, grid * 0.5)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
