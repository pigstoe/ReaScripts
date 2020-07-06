-- Description: Toggle selection of item on a selected track and edit cursor
-- Version: 1.0.3
-- Author: pigstoe
-- Website: http://blog.naver.com/pigstoe83



function Main()
  local track = reaper.GetSelectedTrack(0, 0)
  if track == nil then return end
  
  local _, chunk = reaper.GetTrackStateChunk(track, "", false)
  local i, iguid = 1, {}
  for str in chunk:gmatch("IGUID (.-)\n") do
    iguid[i] = str
    i = i + 1
  end
  
  local count_i = #iguid
  if count_i == 0 then return end
  
  local pos_cur = reaper.GetCursorPosition()
  local verror = 0.000001
  local dis_min = math.huge
  local item_s
  
  for j = 1, count_i do
    local item = reaper.BR_GetMediaItemByGUID(0, iguid[j])
    local pos_s_t = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local len_t = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local pos_e_t = pos_s_t + len_t - verror
  
    if pos_cur >= pos_s_t and pos_cur < pos_e_t then
      item_s = item
      break
    else
      local dis = math.min(math.abs(pos_cur - pos_s_t), math.abs(pos_cur - pos_e_t))
      if dis < dis_min then
        dis_min = dis
        item_s = item
      end
    end
  end
  
  if reaper.IsMediaItemSelected(item_s) then
    reaper.SetMediaItemSelected(item_s, false)
  else
    reaper.SetMediaItemSelected(item_s, true)
  end
  
  reaper.SetCursorContext(1, nil)
end

reaper.PreventUIRefresh(1)
Main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
