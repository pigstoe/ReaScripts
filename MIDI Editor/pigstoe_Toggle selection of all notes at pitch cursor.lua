-- Description: Toggle selection of all notes at pitch cursor
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local hwnd = reaper.MIDIEditor_GetActive()
  if not hwnd then
    reaper.defer(function() end)
    return
  end
  
  local mode = reaper.MIDIEditor_GetMode(hwnd)
  if mode ~= 0 then
    reaper.defer(function() end)
    return
  end
  
  local take = reaper.MIDIEditor_GetTake(hwnd)
  if not take then
    reaper.defer(function() end)
    return
  end
  
  local item = reaper.GetMediaItemTake_Item(take)
  if not item then
    reaper.defer(function() end)
    return
  end
  
  local _, chunk = reaper.GetItemStateChunk(item, "", false)
  local note_row = reaper.MIDIEditor_GetSetting_int(hwnd, "active_note_row")
  note_row = string.format("%x", note_row)

  if chunk:find("E %d+ 90 " .. note_row) then
    chunk = chunk:gsub("E (%d+ 90 " .. note_row ..")", "e %1")
    chunk = chunk:gsub("E (%d+ 80 " .. note_row ..")", "e %1")
  else
    chunk = chunk:gsub("e (%d+ 90 " .. note_row ..")", "E %1")
    chunk = chunk:gsub("e (%d+ 80 " .. note_row ..")", "E %1")
  end
  reaper.Undo_BeginBlock()
  reaper.SetItemStateChunk(item, chunk, false)
  reaper.Undo_EndBlock("Toggle selection of notes at pitch cursor", 4)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
