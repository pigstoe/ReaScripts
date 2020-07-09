-- Description: Move edit cursor left by a fourth of arrange view width
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local pos_cur = reaper.GetCursorPosition()
  local arr_s_t, arr_e_t = reaper.GetSet_ArrangeView2(0, false, 0, 0)
  local len_unit = (arr_e_t - arr_s_t) * 0.25
  local pos_cur_n = reaper.BR_GetClosestGridDivision(pos_cur - len_unit)
  
  if pos_cur_n < 0 then
    reaper.SetEditCurPos(0, true, false)
  else
    reaper.SetEditCurPos(pos_cur_n, true, false)
  end
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
