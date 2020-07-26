-- Description: Set pan of selected tracks
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function ConvertFloatToPan(float)
  return float * 100
end

function ConvertPanToFloat(pan)
  if pan <= -100 then
    return -1
  elseif pan >= 100 then
    return 1
  else
    return pan / 100
  end
end

function SetTrackPanFromUserInput()
  local count = reaper.CountSelectedTracks(0)
  
  local track1 = reaper.GetSelectedTrack(0, 0)
  local pan1 = reaper.GetMediaTrackInfo_Value(track1, "D_PAN")
  
  for i = 1, count - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local pan = reaper.GetMediaTrackInfo_Value(track, "D_PAN")
    
    if pan1 ~= "" then
      if pan1 ~= pan then pan1 = "" end
    end
  end
  
  if pan1 ~= "" then
    pan1 = tostring(ConvertFloatToPan(tonumber(pan1)))
  end
  local get, input = reaper.GetUserInputs("Track pan", 1, "Set track(s) pan to", pan1)
  if get then
    input = ConvertPanToFloat(tonumber(input))
    local set = false
    
    reaper.Undo_BeginBlock()
    for i = 0, count - 1 do
      local track = reaper.GetSelectedTrack(0, i)
      local bool = reaper.SetMediaTrackInfo_Value(track, "D_PAN", input)
      if bool then set = true end
    end
    
    if set then
      reaper.Undo_EndBlock("Set pan of selected tracks", 1)
    else
      reaper.defer(function() end)
    end
  else
    reaper.defer(function() end)
  end
end

function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.defer(function() end)
    return
  end
  
  SetTrackPanFromUserInput()
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
