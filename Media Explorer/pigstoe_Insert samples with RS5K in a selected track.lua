-- Description: Insert samples with RS5K in a selected track
-- Version: 1.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function GetPinIdxFromPinValue(low, high)
  high = math.abs(high)
  low = math.abs(low)
  
  local bin = {}
  local temp
  if high > 0 then
    while high > 0 do
      local rest = math.fmod(high, 2)
      bin[#bin + 1] = math.floor(rest)
      high = (high - rest) / 2
    end
    return 32 + #bin
  else
    while low > 0 do
      local rest = math.fmod(low, 2)
      bin[#bin + 1] = math.floor(rest)
      low = (low - rest) / 2
    end
    return #bin
  end
end

function GetPinValueFromPinIdx(idx)
  if idx >= 1 and idx <= 64 then
    if idx > 32 then
      return 0, 2 ^ (idx - 33)
    else
      return 2 ^ (idx - 1), 0
    end
  else
    return 0, 0
  end
end

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
  
  local track_fx = reaper.GetSelectedTrack(0, 0)
  if not track_fx then
    local tridx_new = reaper.CountTracks(0) + 1
    reaper.InsertTrackAtIndex(tridx_new, false)
    track_fx = reaper.CSurf_TrackFromID(tridx_new, false)
    reaper.SetTrackSelected(track_fx, true)
  end
  local tridx_fx = reaper.CSurf_TrackToID(track_fx, false)
  local tdepth_fx = reaper.GetTrackDepth(track_fx)
  reaper.GetSetMediaTrackInfo_String(track_fx, "P_NAME", "RS5K", true)
  reaper.SetMediaTrackInfo_Value(track_fx, "B_MAINSEND", 0)
  
  local track_lsend = track_fx
  local tridx_lsend = tridx_fx
  local count_snd = reaper.GetTrackNumSends(track_fx, 0)
  for i = 0, count_snd - 1 do
    track_lsend = reaper.BR_GetMediaTrackSendInfo_Track(track_fx, 0, i, 1)
    tridx_lsend = reaper.CSurf_TrackToID(track_lsend, false)
  end
  
  local count_fx = reaper.TrackFX_GetCount(track_fx)
  local note = 47 / 127
  local fxidx_last = 0
  local pinidx_last = 0
  
  for i = 0, count_fx - 1 do
    local count_op = reaper.TrackFX_GetIOSize(track_fx, i)
    for j = 0, count_op do
      local low, high = reaper.TrackFX_GetPinMappings(track_fx, i, 1, j)
      pinidx_last = math.max(pinidx_last, GetPinIdxFromPinValue(low, high))
    end
    
    local _, fxname = reaper.BR_TrackFX_GetFXModuleName(track_fx, i, "", 64)
    if fxname == "reasamplomatic.dll" then
      local notes = reaper.TrackFX_GetParamNormalized(track_fx, i, 3)
      local notee = reaper.TrackFX_GetParamNormalized(track_fx, i, 4)
      note = math.max(math.max(notes, notee), note)
      
      fxidx_last = i
    end
  end
  note = note + 1 / 127
  
  local count_path = #path
  for i = 1, count_path do
    if note > 79 / 127 then break end                           -- maximum number of output pins is 64 monos (32 stereos).
    local fxidx = reaper.TrackFX_AddByName(track_fx, "ReaSamplOmatic5000 (Cockos)", false, -1)
    reaper.TrackFX_SetNamedConfigParm(track_fx, fxidx, "FILE0", path[i])
    reaper.TrackFX_SetParamNormalized(track_fx, fxidx, 2, 0)    -- gain for minimum velocity
    reaper.TrackFX_SetParamNormalized(track_fx, fxidx, 3, note) -- note range start
    reaper.TrackFX_SetParamNormalized(track_fx, fxidx, 4, note) -- note range end
    reaper.TrackFX_SetParamNormalized(track_fx, fxidx, 8, 0)    -- max voices
    reaper.TrackFX_SetParamNormalized(track_fx, fxidx, 9, 0)    -- attack
    
    note = note + 1 / 127
    fxidx_last = fxidx
    
    pinidx_last = pinidx_last + 1
    local pinlow_l, pinhigh_l = GetPinValueFromPinIdx(pinidx_last)
    pinidx_last = pinidx_last + 1
    local pinlow_r, pinhigh_r = GetPinValueFromPinIdx(pinidx_last)
    reaper.TrackFX_SetPinMappings(track_fx, fxidx, 1, 0, pinlow_l, pinhigh_l)
    reaper.TrackFX_SetPinMappings(track_fx, fxidx, 1, 1, pinlow_r, pinhigh_r)
    reaper.SetMediaTrackInfo_Value(track_fx, "I_NCHAN", pinidx_last)

    local fdepth_lsend = reaper.GetMediaTrackInfo_Value(track_lsend, "I_FOLDERDEPTH")
    if fdepth_lsend < 0 then
      reaper.SetMediaTrackInfo_Value(track_lsend, "I_FOLDERDEPTH", 0)
    end
    
    reaper.InsertTrackAtIndex(tridx_lsend, false)
    tridx_lsend = tridx_lsend + 1
    track_lsend = reaper.CSurf_TrackFromID(tridx_lsend, false)
    reaper.SetMediaTrackInfo_Value(track_lsend, "I_FOLDERDEPTH", fdepth_lsend)
    
    local _, name_tr = reaper.TrackFX_GetFXName(track_fx, fxidx, "")
    reaper.GetSetMediaTrackInfo_String(track_lsend, "P_NAME", name_tr, true)
    
    reaper.CreateTrackSend(track_fx, track_lsend)
    reaper.BR_GetSetTrackSendInfo(track_lsend, -1, 0, "I_SRCCHAN", true, pinidx_last - 2)
    reaper.BR_GetSetTrackSendInfo(track_lsend, -1, 0, "I_DSTCHAN", true, 0)
    reaper.BR_GetSetTrackSendInfo(track_lsend, -1, 0, "I_MIDI_SRCCHAN", true, -1)
  end
  
  if fxidx_last >= 0 then
    reaper.TrackFX_SetOpen(track_fx, fxidx_last, true)
    reaper.BR_Win32_SetFocus(listview)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
