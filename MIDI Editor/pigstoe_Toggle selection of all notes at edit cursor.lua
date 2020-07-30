-- Description: Toggle selection of all notes at edit cursor
-- Version: 1.0
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
  
  local posc = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())
  local _, cnt_note = reaper.MIDI_CountEvts(take)
  local sel = true
  local note = {}
  
  for i = 0, cnt_note - 1 do
    local _, selected, _, poss, pose, _, pitch, _ = reaper.MIDI_GetNote(take, i)
    if posc >= poss and posc < pose then
      note[#note + 1] = i
      if not selected then sel = false end
    end
  end
  
  local cnt_note = #note

  reaper.Undo_BeginBlock()
  if sel then
    for j = 1, cnt_note do
      reaper.MIDI_SetNote(take, note[j], false, nil, nil, nil, nil, nil, nil, nil)
    end
  else
    for j = 1, cnt_note do
      reaper.MIDI_SetNote(take, note[j], true, nil, nil, nil, nil, nil, nil, nil)
    end
  end
  reaper.Undo_EndBlock("Toggle selection of notes at edit cursor", 4)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
