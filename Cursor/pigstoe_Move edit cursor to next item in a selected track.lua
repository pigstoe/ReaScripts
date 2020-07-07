-- Description: Move edit cursor to next item in a selected track
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st ~= 1 then return end
  
  local track = reaper.GetSelectedTrack(0, 0)
  local posc = reaper.GetCursorPosition()
  local posn = math.huge
  local posmax = 0
  
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  for iguid in chunk:gmatch("IGUID (.-)\n") do
    local item = reaper.BR_GetMediaItemByGUID(0, iguid)
    local posi = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    if posi > posc then
      posn = math.min(posn, posi)
    end
    posmax = math.max(posmax, posi)
  end
  
  if posn <= posmax then
    reaper.SetEditCurPos(posn, true, false)
    reaper.SetCursorContext(1, nil)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)