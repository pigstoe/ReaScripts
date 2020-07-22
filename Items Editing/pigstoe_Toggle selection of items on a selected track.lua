-- Description: Toggle selection of items on a selected track
-- Version: 1.0.4
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    return
  elseif count_st > 1 then
    reaper.ShowMessageBox("Selected multiple tracks.", "Wrong track", 0)
  else
    for i = 0, count_st - 1 do
      local track = reaper.GetSelectedTrack(0, i)
      local _, chunk = reaper.GetTrackStateChunk(track, "", false)
      if not chunk:find("SEL 0") then
        local cid = reaper.NamedCommandLookup("_SWS_UNSELONTRACKS")
        reaper.Main_OnCommand(cid, 0)
      else
        chunk = chunk:gsub("SEL 0", "SEL 1")
        reaper.SetTrackStateChunk(track, chunk, false)
      end
    end
  end
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
