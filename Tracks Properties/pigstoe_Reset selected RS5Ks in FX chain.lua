-- Description: Reset selected RS5Ks in FX chain
-- Version: 1.0.2
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
  
  local idx_last = 0
  local i, idx = -1, {}

  repeat
    i = reaper.CF_EnumSelectedFX(fxchain, i)
    if i >= 0 then
      local get, fxname = reaper.BR_TrackFX_GetFXModuleName(track, i, "", 64)
      if get and fxname == "reasamplomatic.dll" then
        idx[#idx + 1] = i
        idx_last = i
      end
    end
  until i == -1

  local count_idx = #idx
  if count_idx < 1 then
    reaper.defer(function() end)
    return
  end
  
  reaper.Undo_BeginBlock()
  for j = count_idx, 1, -1 do
    local idx_j = idx[j]

    local notes = reaper.TrackFX_GetParamNormalized(track, idx_j, 3)
    local notee = reaper.TrackFX_GetParamNormalized(track, idx_j, 4)
    local pinl, pinlh = reaper.TrackFX_GetPinMappings(track, idx_j, 1, 0)
    local pinr, pinrh = reaper.TrackFX_GetPinMappings(track, idx_j, 1, 1)
    reaper.TrackFX_Delete(track, idx_j)
    reaper.TrackFX_AddByName(track, "ReaSamplOmatic5000 (Cockos)", false, -1000 - idx_j)
    reaper.TrackFX_SetParamNormalized(track, idx_j, 2, 0)   -- gain for minimum velocity
    
    reaper.TrackFX_SetParamNormalized(track, idx_j, 3, notes)
    reaper.TrackFX_SetParamNormalized(track, idx_j, 4, notee)
    reaper.TrackFX_SetParamNormalized(track, idx_j, 8, 0) -- max voices
    reaper.TrackFX_SetParamNormalized(track, idx_j, 9, 0) -- attack
    reaper.TrackFX_SetPinMappings(track, idx_j, 1, 0, pinl, pinlh)
    reaper.TrackFX_SetPinMappings(track, idx_j, 1, 1, pinr, pinrh)
  end
  reaper.Undo_EndBlock("Reset selected RS5K in FX chain", 2)
end

--reaper.PreventUIRefresh(1)  -- If use this, CF_EnumSelectedFX() works incorrectly.
Main()
--reaper.PreventUIRefresh(-1)
