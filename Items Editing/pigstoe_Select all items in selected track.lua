-- Description: Toggle selection of items on selected track
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local track = reaper.GetSelectedTrack(0, 0)
  if track == nil then return end
  
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  for iguid in chunk:gmatch("IGUID (.-)\n") do
    local item = reaper.BR_GetMediaItemByGUID(0, iguid)
    reaper.SetMediaItemSelected(item, true)
  end
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
