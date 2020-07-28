-- Description: Toggle selection of items on a selected track and edit cursor
-- Version: 1.0.8
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.defer(function() end)
    return
  end
  
  if count_st > 1 then
    reaper.ShowMessageBox("Selected multiple track.", "Wrong track", 0)
    reaper.defer(function() end)
    return
  end
  
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then
    reaper.defer(function() end)
    return
  end
  
  local verror = 0.0001
  local changed = false
  local posc = reaper.GetCursorPosition()
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)

  reaper.Undo_BeginBlock()
  for str in chunk:gmatch("POSITION.-IGUID.-\n") do
    local poss = tonumber(str:match("POSITION (.-)\n"))
    local pose = poss + tonumber(str:match("LENGTH (.-)\n"))
    if posc >= poss - verror and posc < pose - verror then
      local iguid = str:match("IGUID (.-)\n")
      local item = reaper.BR_GetMediaItemByGUID(0, iguid)
      
      if reaper.IsMediaItemSelected(item) then
        reaper.SetMediaItemSelected(item, false)
      else
        reaper.SetMediaItemSelected(item, true)
      end
      changed = true
    elseif posc < poss - verror then
      break
    end
  end
  reaper.Undo_EndBlock("Toggle selection of item on a selected track and edit cursor", 4)
  
  if not changed then
    reaper.defer(function() end)
  end
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
