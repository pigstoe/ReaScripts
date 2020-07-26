-- Description: Move selected tracks to upward in same track depth
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.defer(function() end)
    return
  end
  
  local track1 = reaper.GetSelectedTrack(0, 0)
  local idx1 = reaper.CSurf_TrackToID(track1, false)
  local tdepth1 = reaper.GetTrackDepth(track1)
  local fdepth1 = reaper.GetMediaTrackInfo_Value(track1, "I_FOLDERDEPTH")
  if idx1 < 2 then
    reaper.defer(function() end)
    return
  end
  
  for i = 1, count_st - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local idx = reaper.CSurf_TrackToID(track, false)
    local tdepth = reaper.GetTrackDepth(track)
    local fdepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    if tdepth ~= tdepth1 then
      reaper.ShowMessageBox("Some tracks in different depth.", "Wrong track", 0)
      reaper.defer(function() end)
      return
    end
  end
  
  local idx0 = idx1 - 1
  repeat
    local track0 = reaper.CSurf_TrackFromID(idx0, false)
    local tdepth0 = reaper.GetTrackDepth(track0)
    if tdepth0 == tdepth1 then
      break
    elseif tdepth1 == 1 then
      reaper.defer(function() end)
      return
    end
    idx0 = idx0 - 1
  until idx0 == 1
  
  reaper.Undo_BeginBlock()
  reaper.ReorderSelectedTracks(idx0 - 1, 0)
  reaper.Undo_EndBlock("Move selected tracks to upward in same track depth", 1)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
