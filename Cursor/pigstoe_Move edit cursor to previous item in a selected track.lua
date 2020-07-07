-- Description: Move edit cursor to previous item in a selected track
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st ~= 1 then return end
  
  local track = reaper.GetSelectedTrack(0, 0)
  local posc = reaper.GetCursorPosition()
  local posp = 0
  local posmin = math.huge
  
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  for iguid in chunk:gmatch("IGUID (.-)\n") do
    local item = reaper.BR_GetMediaItemByGUID(0, iguid)
    local posi = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    if posi < posc then
      posp = math.max(posp, posi)
    end
    posmin = math.min(posmin, posi)
  end
  
  if posp >= posmin then
    reaper.SetEditCurPos(posp, true, false)
    reaper.SetCursorContext(1, nil)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
