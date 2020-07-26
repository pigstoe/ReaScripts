-- Description: Set Selected tracks to be out from folder track
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.defer(function() end)
    return
  end
  
  local idx_last, fdepth_last = 0, 0
  for i = 0, count_st - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local idx = reaper.CSurf_TrackToID(track, false)
    local tdepth = reaper.GetTrackDepth(track)
    if tdepth == 0 then
      reaper.defer(function() end)
      return
    end
    
    idx_last = idx
    fdepth_last = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
  end
  
  reaper.Undo_BeginBlock()
  if fdepth_last < 0 then
    reaper.ReorderSelectedTracks(idx_last, 0)
  else
    repeat
      idx_last = idx_last + 1
      local track = reaper.CSurf_TrackFromID(idx_last, false)
      local fdepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    until fdepth < 0
    
    reaper.ReorderSelectedTracks(idx_last, 0)
  end
  reaper.Undo_EndBlock("Set selected tracks to get out of folder track", 1)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
