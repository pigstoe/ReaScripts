-- Description: Control track selection range to upward
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.Main_OnCommand(40505, 0) -- Track: Select last touched track
  elseif count_st == 1 then
    reaper.Main_OnCommand(40288, 0) -- Track: Go to previous track (leaving other tracks selected)
  else
    local trackc = reaper.GetLastTouchedTrack()
    local idxc = reaper.CSurf_TrackToID(trackc, false)
    local track0 = reaper.GetSelectedTrack(0, count_st - 1)
    local idx0 = reaper.CSurf_TrackToID(track0, false)
    if idxc < idx0 then
      reaper.Main_OnCommand(40288, 0)
    else
      reaper.SetTrackSelected(trackc, false)
      reaper.Main_OnCommand(40288, 0)
    end
  end
  
  reaper.SetCursorContext(0, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.defer(function() end)
reaper.PreventUIRefresh(-1)
