-- Description: Set volume of selected items or tracks
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function ConvertFloatToDb(float)
  return math.log(float) * 20 / math.log(10)
end

function ConvertDbToFloat(db)
  if db > 12 then
    db = 12
  end
  local scale = math.log(10) * 0.05
  local val = math.exp(db * scale)
  return val
end

function SetItemVolFromUserInput()
  local count = reaper.CountSelectedMediaItems(0)
  
  local item1 = reaper.GetSelectedMediaItem(0, 0)
  local vol1 = reaper.GetMediaItemInfo_Value(item1, "D_VOL")
  local counttake1 = reaper.CountTakes(item1)
  for i = 0, counttake1 - 1 do
    local take = reaper.GetMediaItemTake(item1, i)
    if reaper.TakeIsMIDI(take) then
      reaper.ShowMessageBox("Selected MIDI item.", "Wrong Item", 0)
      reaper.defer(function() end)
      return
    end
  end
  
  for i = 1, count - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
    local counttake = reaper.CountTakes(item)
    for i = 0, counttake - 1 do
      local take = reaper.GetMediaItemTake(item, i)
      local istmidi, inpmidi = reaper.BR_IsTakeMidi(take)
      if reaper.TakeIsMIDI(take) then
        reaper.ShowMessageBox("Selected MIDI item.", "Wrong Item", 0)
        reaper.defer(function() end)
        return
      end
    end
    
    if vol1 ~= "" then
      if vol1 ~= vol then vol1 = "" end
    end
  end
  
  if vol1 ~= "" then
    vol1 = tostring(ConvertFloatToDb(tonumber(vol1)))
  end
  
  local bool, input = reaper.GetUserInputs("Item volume", 1, "Set item(s) volume to", vol1)
  if bool then
    input = ConvertDbToFloat(tonumber(input))
    reaper.Undo_BeginBlock()
    for i = 0, count - 1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      reaper.SetMediaItemInfo_Value(item, "D_VOL", input)
    end
    reaper.Undo_EndBlock("Set volume of selected items", 4)
  else
    reaper.defer(function() end)
  end
end

function SetTrackVolFromUserInput()
  local count = reaper.CountSelectedTracks(0)
  
  local track1 = reaper.GetSelectedTrack(0, 0)
  local vol1 = reaper.GetMediaTrackInfo_Value(track1, "D_VOL")
  
  for i = 1, count - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
    
    if vol1 ~= "" then
      if vol1 ~= vol then vol1 = "" end
    end
  end
  
  if vol1 ~= "" then
    vol1 = tostring(ConvertFloatToDb(tonumber(vol1)))
  end
  
  local bool, input = reaper.GetUserInputs("Track volume", 1, "Set track(s) volume to", vol1)
  if bool then
    input = ConvertDbToFloat(tonumber(input))
    reaper.Undo_BeginBlock()
    for i = 0, count - 1 do
      local track = reaper.GetSelectedTrack(0, i)
      reaper.SetMediaTrackInfo_Value(track, "D_VOL", input)
    end
    reaper.Undo_EndBlock("Set volume of selected tracks", 1)
  else
    reaper.defer(function() end)
  end
end

function Main()
  local count_si = reaper.CountSelectedMediaItems(0)
  local count_st = reaper.CountSelectedTracks(0)
  
  if count_si > 0 then
    SetItemVolFromUserInput()
  elseif count_st > 0 then
    SetTrackVolFromUserInput()
  else
    reaper.defer(function() end)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
