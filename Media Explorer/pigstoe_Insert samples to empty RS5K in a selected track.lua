-- Description: Insert samples to empty RS5K in a selected track
-- Version: 1.0
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
  if count_st ~= 1 then return end
  
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then return end
  
  local count_fx = reaper.TrackFX_GetCount(track)
  local idx = 1
  local idx_last = -1
  
  for i = 0, count_fx - 1 do
    local _, fxname = reaper.BR_TrackFX_GetFXModuleName(track, i, "", 64)
    if fxname == "reasamplomatic.dll" then
      local _, file0 = reaper.TrackFX_GetNamedConfigParm(track, i, "FILE0")
      if file0 == "" then
        reaper.TrackFX_SetNamedConfigParm(track, i, "FILE0", path[idx])
        idx = idx + 1
        idx_last = i
        if idx > count_si then break end
      end
    end
  end
  
  if idx_last >= 0 then
    local open = reaper.TrackFX_GetOpen(track, idx_last)
    if open then
      reaper.TrackFX_SetOpen(track, idx_last, false)
    end
    reaper.TrackFX_SetOpen(track, idx_last, true)
    reaper.BR_Win32_SetFocus(listview)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
