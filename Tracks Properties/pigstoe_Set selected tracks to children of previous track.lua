-- Description: Set Selected tracks to children of previous track
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
  if tdepth1 > 0 or idx1 < 2 or fdepth1 == 1 then
    reaper.defer(function() end)
    return
  end
  
  for i = 1, count_st - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local idx = reaper.CSurf_TrackToID(track, false)
    local tdepth = reaper.GetTrackDepth(track)
    local fdepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    if tdepth > 0 or fdepth == 1 then
      reaper.defer(function() end)
      return
    end
  end
  
  local idx0 = idx1 - 1
  local track0 = reaper.CSurf_TrackFromID(idx0, false)
  local tdepth0 = reaper.GetTrackDepth(track0)
  
  reaper.Undo_BeginBlock()
  if tdepth0 == 0 then
    reaper.ReorderSelectedTracks(idx0, 1)
  elseif tdepth0 == 1 then
    reaper.ReorderSelectedTracks(idx0, 2)
  end
  reaper.Undo_EndBlock("Set selected tracks to children of previous track", 1)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
