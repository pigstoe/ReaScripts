-- Description: Toggle selection of notes at edit cursor and pitch cursor
-- Version: 1.0
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local hwnd = reaper.MIDIEditor_GetActive()
  if not hwnd then return end
  
  local mode = reaper.MIDIEditor_GetMode(hwnd)
  if mode ~= 0 then return end
  
  local take = reaper.MIDIEditor_GetTake(hwnd)
  if not take then return end

  local note_row = reaper.MIDIEditor_GetSetting_int(hwnd, "active_note_row")
  local curpos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())
  
  local _, cnt_note = reaper.MIDI_CountEvts(take)
  for i = 0, cnt_note - 1 do
    local _, selected, _, spos, epos, _, pitch, _ = reaper.MIDI_GetNote(take, i)
    if pitch == note_row then
      if curpos >= spos and curpos < epos then
        if selected then
          reaper.MIDI_SetNote(take, i, false, nil, nil, nil, nil, nil, nil, nil)
        else
          reaper.MIDI_SetNote(take, i, true, nil, nil, nil, nil, nil, nil, nil)
        end
      end
    end
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
