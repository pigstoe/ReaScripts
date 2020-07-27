-- Description: Group selected RS5K samples into one voice one channel
-- Version: 1.0.3
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function GetTrackFromFXChain(fxchain)
  local str = reaper.JS_Window_GetTitle(fxchain)
  local num = tonumber(str:match("Track (%d+)"))
  return reaper.CSurf_TrackFromID(num, false)
end

function Main()
  local fxchain = reaper.CF_GetFocusedFXChain()
  if not fxchain then
    reaper.defer(function() end)
    return
  end
  
  local track = GetTrackFromFXChain(fxchain)
  if not track then
    reaper.defer(function() end)
    return
  end
  
  local pin_l = math.huge
  local pin_r = math.huge
  local note_min = math.huge
  local note_max = 0
  local idx = -1
  local idx_table = {}
  local i = 1

  repeat
    idx = reaper.CF_EnumSelectedFX(fxchain, idx)
    if idx >= 0 then
      local get, fxname = reaper.BR_TrackFX_GetFXModuleName(track, idx, "", 64)
      if not get or fxname ~= "reasamplomatic.dll" then
        reaper.ShowMessageBox("Selected non-RS5K.", "Wrong plugin", 0)
        reaper.TrackFX_SetOpen(track, idx, true)
        reaper.defer(function() end)
        return
      end
      
      idx_table[i] = idx
      i = i + 1
      --local pin_lt = reaper.TrackFX_GetPinMappings(track, idx, 1, 0)  -- (track, fx index, 0:in | 1:out, vst out index)
      --local pin_rt = reaper.TrackFX_GetPinMappings(track, idx, 1, 1)  -- (track, fx index, 0:in | 1:out, vst out index)
      --pin_l = math.min(pin_l, pin_lt)
      --pin_r = math.min(pin_r, pin_rt)
      local note_mint = reaper.TrackFX_GetParamNormalized(track, idx, 3)  -- note range start
      local note_maxt = reaper.TrackFX_GetParamNormalized(track, idx, 4)  -- note range end
      note_min = math.min(note_min, note_mint)
      note_max = math.max(note_max, note_maxt)
    end
  until idx == -1
  
  local count_si = #idx_table
  if count_si < 2 then
    reaper.defer(function() end)
    return
  end
  
  reaper.Undo_BeginBlock()
  for i = 1, count_si do
    --reaper.TrackFX_SetPinMappings(track, idx_table[i], 1, 0, pin_l, 0)  -- L
    --reaper.TrackFX_SetPinMappings(track, idx_table[i], 1, 1, pin_r, 0)  -- R
    reaper.TrackFX_SetParamNormalized(track, idx_table[i], 11, 1)       -- obey note-offs
  end
  
  local idx_newfx = reaper.TrackFX_AddByName(track, "MIDI_Choke", false, -1000 - idx_table[1])
  local note_num = ((note_max - note_min) * 127) / 16
  reaper.TrackFX_SetParamNormalized(track, idx_newfx, 1, note_min)  -- choke note range start
  reaper.TrackFX_SetParamNormalized(track, idx_newfx, 2, note_num)  -- number of choke notes
  reaper.TrackFX_SetParamNormalized(track, idx_newfx, 3, note_min)  -- affected note range start  
  reaper.TrackFX_SetParamNormalized(track, idx_newfx, 4, note_num)  -- number of affected notes
  reaper.TrackFX_SetParamNormalized(track, idx_newfx, 5, 1)         -- action during choke
  reaper.Undo_EndBlock("Group selected RS5K samples into one voice one channel", 2)
end

--reaper.PreventUIRefresh(1)  -- If use this, CF_EnumSelectedFX() works incorrectly.
Main()
--reaper.PreventUIRefresh(-1)
