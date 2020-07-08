-- Description: Move edit cursor to previous item in a selected track
-- Version: 1.0.3
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st ~= 1 then return end
  
  local track = reaper.GetSelectedTrack(0, 0)
  local posc = reaper.GetCursorPosition()
  local posp
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  
  for posstr in chunk:gmatch("POSITION (.-)\n") do
    local pos = tonumber(posstr)
    if pos < posc then
      posp = pos
    else
      break
    end
  end
  
  if posp ~= nil then
    reaper.SetEditCurPos(posp, true, false)
    reaper.SetCursorContext(1, nil)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
