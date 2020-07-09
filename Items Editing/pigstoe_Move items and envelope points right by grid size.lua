-- Description: Move items and envelope points right by grid size
-- Version: 1.0.3
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_si = reaper.CountSelectedMediaItems(0)
  if count_si == 0 then return end
  
  local pos_s = math.huge
  
  for i = 0, count_si - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    if item ~= nil then
      local pos_item = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      pos_s = math.min(pos_s, pos_item)
    end
  end
  
  local len_nudge = reaper.BR_GetNextGridDivision(0)
  reaper.ApplyNudge(0, 0, 0, 1, len_nudge, 0, 0)
  
  local pos_ns = pos_s + len_nudge
  local pos_cur = reaper.BR_GetClosestGridDivision(pos_ns)
  if pos_cur > pos_ns then
    pos_cur = reaper.BR_GetPrevGridDivision(pos_cur)
  end
  reaper.SetEditCurPos(pos_cur, true, false)
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
