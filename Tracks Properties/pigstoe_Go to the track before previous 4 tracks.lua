-- Description: Go to the track before previous 4 tracks
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local track = reaper.GetLastTouchedTrack()
  local idx = reaper.CSurf_TrackToID(track, false)
  
  local iter = 5
  if idx - iter < 1 then
    iter = idx - 1
  end
  
  for i = 1, iter do
    reaper.Main_OnCommand(40286, 0) -- Track: Go to previous track
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.defer(function() end)
reaper.PreventUIRefresh(-1)
