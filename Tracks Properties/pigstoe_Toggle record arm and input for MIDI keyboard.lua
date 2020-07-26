-- Description: Toggle record arm and input for MIDI keyboard
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  track = reaper.GetSelectedTrack(0, 0)
  if not track then
    reaper.defer(function() end)
    return
  end
  
  local recarm = reaper.GetMediaTrackInfo_Value(track, "I_RECARM")
  
  reaper.Undo_BeginBlock()
  if recarm == 0 then
    reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 1)
    reaper.SetMediaTrackInfo_Value(track, "I_RECINPUT", 6112)
  else
    reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 0)
    reaper.SetMediaTrackInfo_Value(track, "I_RECINPUT", 0)
  end
  reaper.Undo_EndBlock("Toggle record arm and input for MIDI keyboard", 1)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
