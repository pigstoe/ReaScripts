-- Description: Set tracks to a color from color table
-- Version: 1.0.1
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count = reaper.CountSelectedTracks(0)
  if count < 1 then
    reaper.defer(function() end)
    return
  end
  
  local color = {}
  color[1] = {105, 72, 72}
  color[2] = {105, 105, 72}
  color[3] = {72, 105, 72}
  color[4] = {72, 105, 105}
  color[5] = {72, 72, 105}
  color[6] = {105, 72, 105}
  
  local track1 = reaper.GetSelectedTrack(0, 0)
  local idx1 = reaper.CSurf_TrackToID(track1, false)

  local s = 1
  if idx1 > 1 then
    local track0 = reaper.CSurf_TrackFromID(idx1 - 1, false)
    local color0 = reaper.GetTrackColor(track0)
    local r, g, b = reaper.ColorFromNative(color0)
    for j = 1, 6 do
      if color[j][1] == r and color[j][2] == g and color[j][3] == b then
        if j < 6 then
          s = j + 1
        end
        break
      end
    end
  end

  reaper.Undo_BeginBlock()
  for i = 0, count - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local cval = reaper.ColorToNative(color[s][1], color[s][2], color[s][3])
    reaper.SetTrackColor(track, cval)
  end
  reaper.Undo_EndBlock("Set tracks to a color from color table", 1)
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
