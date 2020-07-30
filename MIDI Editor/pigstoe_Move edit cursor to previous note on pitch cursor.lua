-- Description: Move edit cursor to previous note on pitch cursor
-- Version: 1.0.1
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
  local posc = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())
  local posp
  
  local _, cnt_note = reaper.MIDI_CountEvts(take)
  for i = 0, cnt_note - 1 do
    local _, _, _, poss, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
    if pitch == note_row then
      if poss < posc then
        posp = poss
      else
        break
      end
    end
  end
  
  if posp ~= nil then
    reaper.SetEditCurPos(reaper.MIDI_GetProjTimeFromPPQPos(take, posp), true, false)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.defer(function() end)
reaper.PreventUIRefresh(-1)
