-- Description: Move items and envelope points left by grid size
-- Version: 1.0.4
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_si = reaper.CountSelectedMediaItems(0)
  if count_si < 1 then
    reaper.defer(function() end)
    return
  end
  
  local pos_s = math.huge
  
  for i = 0, count_si - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    if not item then
      local pos_item = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      pos_s = math.min(pos_s, pos_item)
    end
  end
  
  local len_nudge = reaper.BR_GetNextGridDivision(0)
  if pos_s < len_nudge then
    reaper.defer(function() end)
    return
  end

  local pos_cur = reaper.GetCursorPosition()
  
  reaper.Undo_BeginBlock()
  reaper.ApplyNudge(0, 0, 0, 1, -len_nudge , 0, 0)
  reaper.SetEditCurPos(pos_cur - len_nudge, true, false)
  reaper.Undo_EndBlock("Move items and envelope points left by grid size", 4)
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
