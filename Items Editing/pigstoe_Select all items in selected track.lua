-- Description: Toggle selection of items on selected track
-- Version: 1.0.3
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local track = reaper.GetSelectedTrack(0, 0)
  if track == nil then return end
  
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  chunk = chunk:gsub("SEL 0", "SEL 1")
  reaper.SetTrackStateChunk(track, chunk, false)
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
