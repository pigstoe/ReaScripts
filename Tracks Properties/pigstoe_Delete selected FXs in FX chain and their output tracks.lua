-- Description: Delete selected FXs in FX chain and their output tracks
-- Version: 1.0.2
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function GetTrackFromFXChain(fxchain)
  local str = reaper.JS_Window_GetTitle(fxchain)
  local num = tonumber(str:match("Track (%d+)"))
  return reaper.CSurf_TrackFromID(num, false)
end

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
  
  local i, idx = -1, {}
  repeat
    i = reaper.CF_EnumSelectedFX(fxchain, i)
    if i >= 0 then
      idx[#idx + 1] = i
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
    
    local pinidx = 0
    local _, _, count_op = reaper.TrackFX_GetIOSize(track, idx_j)
    for k = 0, count_op - 1 do
      local low, high = reaper.TrackFX_GetPinMappings(track, idx_j, 1, k)
      pinidx = math.max(pinidx, GetPinIdxFromPinValue(low, high))
    end
    
    local count_snd = reaper.GetTrackNumSends(track, 0)
    for k = count_snd - 1, 0, -1 do
      local track_snd = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, k, 1)
      local srcchan = reaper.BR_GetSetTrackSendInfo(track_snd, -1, 0, "I_SRCCHAN", false, 0)
      if srcchan == pinidx - 2 then
        local fdepth_snd = reaper.GetMediaTrackInfo_Value(track_snd, "I_FOLDERDEPTH")
        if fdepth_snd < 0 then
          local tridx_snd = reaper.CSurf_TrackToID(track_snd, false)
          local track_snd_p = reaper.CSurf_TrackFromID(tridx_snd - 1, false)
          local fdepth_snd_p = reaper.GetMediaTrackInfo_Value(track_snd_p, "I_FOLDERDEPTH")
          if fdepth_snd_p == 0 then
            reaper.SetMediaTrackInfo_Value(track_snd_p, "I_FOLDERDEPTH", fdepth_snd)
          end
        end
        reaper.DeleteTrack(track_snd)
      end
    end
    
    reaper.TrackFX_Delete(track, idx_j)
  end
  
  local pinidx_last = 0
  local count_fx = reaper.TrackFX_GetCount(track)
  for j = 0, count_fx - 1 do
    local _, _, count_op = reaper.TrackFX_GetIOSize(track, j)
    for k = 0, count_op - 1 do
      local low, high = reaper.TrackFX_GetPinMappings(track, j, 1, k)
      pinidx_last = math.max(pinidx_last, GetPinIdxFromPinValue(low, high))
    end
  end
  reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", pinidx_last)
  reaper.Undo_EndBlock("Delete selected FXs in FX chain and their output tracks", 1)
end

--reaper.PreventUIRefresh(1)  -- If use this, CF_EnumSelectedFX() works incorrectly.
Main()
--reaper.PreventUIRefresh(-1)
