-- Description: Decrease length of selected MIDI items
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_si = reaper.CountSelectedMediaItems(0)
  if count_si < 1 then
    reaper.defer(function() end)
    return
  end
  
  for i = 0, count_si - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetMediaItemTake(item, 0)
    
    local istmidi, inpmidi = reaper.BR_IsTakeMidi(take)
    if not istmidi then
      reaper.ShowMessageBox("Selected wav item.", "Wrong item", 0)
      reaper.defer(function() end)
      return
    end
  end
  
  local _, grid = reaper.GetSetProjectGrid(0, false)
  local len_unit = grid * 4
  
  reaper.Undo_BeginBlock()
  for i = 0, count_si - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local pos0_s = reaper.TimeMap_timeToQN(reaper.GetMediaItemInfo_Value(item, "D_POSITION"))
    local len0 = reaper.TimeMap_timeToQN(reaper.GetMediaItemInfo_Value(item, "D_LENGTH"))
    local pos0_e = pos0_s + len0
    local pos1_e = pos0_e - len_unit
    
    if pos1_e > pos0_s then
      if math.fmod(pos1_e, len_unit) == 0 then
        reaper.MIDI_SetItemExtents(item, pos0_s, pos1_e)
      else
        local mul = math.floor(pos0_e / len_unit)
        reaper.MIDI_SetItemExtents(item, pos0_s, len_unit * mul)
      end
    end
  end
  reaper.Undo_EndBlock("Decrease length of selected MIDI items", 4)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
