-- Description: Go to the track after next 4 tracks
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local track = reaper.GetLastTouchedTrack()
  local idx = reaper.CSurf_TrackToID(track, false)
  
  local iter = 5
  local count_tr = reaper.CountTracks(0)
  local iter = math.min(iter, count_tr - idx)
  
  for i = 1, iter do
    reaper.Main_OnCommand(40285, 0) -- Track: go to next track
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.defer(function() end)
reaper.PreventUIRefresh(-1)
