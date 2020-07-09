-- Description: Toggle selection of item on a selected track and edit cursor
-- Version: 1.0.5
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then return end
  
  local verror = 0.000001
  local posc = reaper.GetCursorPosition()
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  for str in chunk:gmatch("POSITION.-IGUID.-\n") do
    local poss = tonumber(str:match("POSITION (.-)\n"))
    local pose = poss + tonumber(str:match("LENGTH (.-)\n"))
    if posc >= poss and posc < pose - verror then
      local iguid = str:match("IGUID (.-)\n")
      local item = reaper.BR_GetMediaItemByGUID(0, iguid)
      if reaper.IsMediaItemSelected(item) then
        reaper.SetMediaItemSelected(item, false)
      else
        reaper.SetMediaItemSelected(item, true)
      end
      break
    end
  end
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
