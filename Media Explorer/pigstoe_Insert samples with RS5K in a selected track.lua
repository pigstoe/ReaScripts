-- Description: Insert samples with RS5K in a selected track
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local title = reaper.JS_Localize("Media Explorer", "common")
  local hwnd = reaper.JS_Window_Find(title, true)
  if not hwnd then return end
  
  local container = reaper.JS_Window_FindChildByID(hwnd, 0)
  local listview = reaper.JS_Window_FindChildByID(container, 1000)
  local count_si, idx_si = reaper.JS_ListView_ListAllSelItems(listview)
  if count_si == 0 then return end
  
  local combo = reaper.JS_Window_FindChildByID(hwnd, 1002)
  local edit = reaper.JS_Window_FindChildByID(combo, 1001)
  local dir = reaper.JS_Window_GetTitle(edit, "", 1024)
  
  local path = {}
  local count_si = 0
  
  for idx in string.gmatch(idx_si, "[^,]+") do
    local filetype = reaper.JS_ListView_GetItemText(listview, tonumber(idx), 3)
    if filetype == "wav" then
      local filename = reaper.JS_ListView_GetItemText(listview, tonumber(idx), 0)
      count_si = count_si + 1
      path[count_si] = dir .. "\\" .. filename
    end
  end
  
  local count_st = reaper.CountSelectedTracks(0)
  if count_st > 1 then return end
  
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then
    local idx = reaper.CSurf_NumTracks(0, false) + 1
    reaper.InsertTrackAtIndex(idx, false)
    
    track = reaper.CSurf_TrackFromID(idx, false)
    reaper.SetTrackSelected(track, true)
  end
  
  local count_fx = reaper.TrackFX_GetCount(track)
  local note = 47 / 127
  local idx_last = 0
  
  for i = 0, count_fx - 1 do
    local _, fxname = reaper.BR_TrackFX_GetFXModuleName(track, i, "", 64)
    if fxname == "reasamplomatic.dll" then
      local notes = reaper.TrackFX_GetParamNormalized(track, i, 3)
      local notee = reaper.TrackFX_GetParamNormalized(track, i, 4)
      note = math.max(math.max(notes, notee), note)
      
      idx_last = i
    end
  end
  note = note + 1 / 127
  
  local count_path = #path
  for i = 1, count_path do
    if note > 79 / 127 then break end                       -- maximum number of output pins is 64 monos (32 stereos).
    local idx = reaper.TrackFX_AddByName(track, "ReaSamplOmatic5000 (Cockos)", false, -1)
    reaper.TrackFX_SetNamedConfigParm(track, idx, "FILE0", path[i])
    reaper.TrackFX_SetParamNormalized(track, idx, 2, 0)     -- gain for minimum velocity
    reaper.TrackFX_SetParamNormalized(track, idx, 3, note)  -- note range start
    reaper.TrackFX_SetParamNormalized(track, idx, 4, note)  -- note range end
    reaper.TrackFX_SetParamNormalized(track, idx, 8, 0)     -- max voices
    reaper.TrackFX_SetParamNormalized(track, idx, 9, 0)     -- attack
    
    note = note + 1 / 127
    idx_last = idx
  end
  
  if idx_last >= 0 then
    reaper.TrackFX_SetOpen(track, idx_last, true)
    reaper.BR_Win32_SetFocus(listview)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
