-- Description: Duplicate media item
-- Version: 1.0.3
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_si = reaper.CountSelectedMediaItems(0)
  if count_si == 0 then return end
  
  local pos_s = math.huge
  local pos_e = 0
  
  for i = 1, count_si do
    local item = reaper.GetSelectedMediaItem(0, i - 1)
    if item ~= nil then
      local pos_item = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local len_item = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      pos_s = math.min(pos_s, pos_item)
      pos_e = math.max(pos_e, pos_item + len_item)
    end
  end
  
  local div_s = reaper.BR_GetClosestGridDivision(pos_s)
  if div_s > pos_s then
    div_s = reaper.BR_GetPrevGridDivision(div_s)
  end
  
  local div_e = reaper.BR_GetClosestGridDivision(pos_e) 
  if div_e < pos_e then
    div_e = reaper.BR_GetNextGridDivision(pos_e)
  end
  
  local len_nudge = div_e - div_s
  reaper.ApplyNudge(0, 0, 5, 1, len_nudge , 0, 1)   
  reaper.SetEditCurPos(div_e + len_nudge, true, false)
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
