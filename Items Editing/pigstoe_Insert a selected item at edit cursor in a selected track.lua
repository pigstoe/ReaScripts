-- Description: Insert a selected item at edit cursor in a selected track
-- Version: 0.9
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local count_st = reaper.CountSelectedTracks(0)
  if count_st < 1 then
    reaper.defer(function() end)
    return
  elseif count_st > 1 then
    reaper.ShowMessageBox("Selected multiple track.", "Wrong track", 0)
    reaper.defer(function() end)
    return
  end
  
  local track0 = reaper.GetSelectedTrack(0, 0)
  local _, chunk = reaper.GetTrackStateChunk(track0, "", false)
  
  local count_si = 0
  for str in chunk:gmatch("SEL 1") do
    count_si = count_si + 1
  end
  if count_si < 1 then
    reaper.defer(function() end)
    return
  elseif count_si > 1 then
    reaper.ShowMessageBox("Selected multiple item.", "Wrong item", 0)
    reaper.defer(function() end)
    return
  end

  local item0 = reaper.GetSelectedMediaItem(0, 0)
  local pos_item0 = reaper.GetMediaItemInfo_Value(item0, "D_POSITION")
  local len_item0 = reaper.GetMediaItemInfo_Value(item0, "D_LENGTH")
  local poss_n = reaper.GetCursorPosition()
  local pose_n = poss_n + len_item0
  local len_nudge = poss_n - pos_item0
  
  reaper.Undo_BeginBlock()
  reaper.Main_OnCommand(40698, 0) -- Edit: Copy items
  reaper.GetSet_LoopTimeRange2(0, true, false, poss_n, pose_n, false)
  reaper.Main_OnCommand(40201, 0) -- Time selection: Remove contents of time selection (moving later items)
--  reaper.GetSet_LoopTimeRange2(0, true, false, poss_n, pose_n, false)
--  reaper.Main_OnCommand(40200, 0) -- Time selection: Insert empty space at time selection (moving later items)
--  reaper.Main_OnCommand(40020, 0) -- Time selection: Remove time selection and loop points
  reaper.Main_OnCommand(42398, 0) -- Item: Paste items/tracks
  reaper.Undo_EndBlock("Insert a selected item at edit cursor in a selected track", 4)
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
