-- Description: Decrease project grid
-- Version: 1.0
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



local _, grid = reaper.GetSetProjectGrid(0, false)

if grid > 0.0078125 then
  reaper.GetSetProjectGrid(0, true, grid * 0.5)
end
