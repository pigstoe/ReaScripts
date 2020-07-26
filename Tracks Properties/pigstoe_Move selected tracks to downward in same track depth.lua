-- Description: Move selected tracks to downward in same track depth
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.defer(function() end)
    return
  end
  
  local count_tr = reaper.CountTracks()
  local track1 = reaper.GetSelectedTrack(0, count_st - 1)
  local idx1 = reaper.CSurf_TrackToID(track1, false)
  local tdepth1 = reaper.GetTrackDepth(track1)
  local fdepth1 = reaper.GetMediaTrackInfo_Value(track1, "I_FOLDERDEPTH")
  if idx1 >= count_tr then
    reaper.defer(function() end)
    return
  end
  
  for i = 0, count_st - 2 do
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
  
  local idx2 = idx1 + 1
  repeat
    local track2 = reaper.CSurf_TrackFromID(idx2, false)
    local tdepth2 = reaper.GetTrackDepth(track2)
    local fdepth2 = reaper.GetMediaTrackInfo_Value(track2, "I_FOLDERDEPTH")
    if tdepth2 == tdepth1 then
      if fdepth2 <= 0 then break end
    elseif tdepth1 == 1 then
      reaper.defer(function() end)
      return
    elseif fdepth2 < 0 then
      break
    end
    idx2 = idx2 + 1
  until idx2 == count_tr
  
  reaper.Undo_BeginBlock()
  if tdepth1 == 0 then
    reaper.ReorderSelectedTracks(idx2, 0)
  else
    reaper.ReorderSelectedTracks(idx2, 2)
  end
  reaper.Undo_EndBlock("Move selected tracks to downward in same track depth", 1)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
