-- Description: Move edit cursor to next item in a selected track
-- Version: 1.0.4
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    return
  elseif count_st > 1 then
    reaper.ShowMessageBox("Selected multiple track.", "Wrong track", 0)
    return
  end
  
  local track = reaper.GetSelectedTrack(0, 0)
  local posc = reaper.GetCursorPosition()
  local posn
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  
  for posstr in chunk:gmatch("POSITION (.-)\n") do
    local pos = tonumber(posstr)
    if pos > posc then
      posn = pos
      break
    end
  end
  
  if posn ~= nil then
    reaper.SetEditCurPos(posn, true, false)
    reaper.SetCursorContext(1, nil)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.defer(function() end)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
