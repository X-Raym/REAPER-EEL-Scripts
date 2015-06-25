--[[
 * ReaScript Name: Set selected items fade-in fade-out length (seconds)
 * Description: A pop up will let you enter value of selected items fade-in and fade-out. -1 is for leaving as it is, 0 is for reset. Express value in seconds. Priority is to let you choose what fades will be set first if they overlaps (items too short). If fades are longer than items, they are adjusted accordingly.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Scripts: Item Fades (various)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 36
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-25-06)
  + Initial Release
 --]]

--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function main(input1, input2, input3) -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_end = item_pos + item_len
    
    -- GET FADES
    if input1 == "/initial" then
      fadein_len = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
    else
      fadein_len = tonumber(answer1)
      if fadein_len ~= nil then 
        fadein_len = math.abs(fadein_len)
        if fadein_len > item_len then fadein_len = item_len end
      end
    end
    
    if input2 == "/initial" then
      fadeout_len = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
    else
      fadeout_len = tonumber(answer2)
      if fadeout_len ~= nil then 
        fadeout_len = math.abs(fadeout_len)
        if item_end - fadeout_len < item_pos then fadeout_len = item_len end
      end
    end
    
    -- SET
    if fadeout_len ~= nil and fadein_len ~= nil then
      if (item_pos + fadein_len) > (item_end - fadeout_len) and input3 == "1" then -- if overlaping
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", 0)
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeout_len)
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", item_len - fadeout_len)
      else
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadein_len)
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeout_len)
      end
    end

  end -- ENDLOOP through selected items
    
  reaper.Undo_EndBlock("Set selected items fade-in fade-out length (seconds)", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then

  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
  
  retval, retvals_csv = reaper.GetUserInputs("Set fades length in seconds", 3, "Fade-in (no change = /initial),Fade-out (no change = /initial), Priority (0 = in, 1 = out)", "0"..",".."0".. ",".."0") 
  
  if retval == true then
      
    -- PARSE THE STRING
    answer1, answer2, answer3 = retvals_csv:match("([^,]+),([^,]+),([^,]+)")
    
    main(answer1, answer2, answer3) -- Execute your main function
  
    reaper.UpdateArrange() -- Update the arrangement (often needed)
  
  end
  
  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)
  
end

--msg_end() -- Display characters in the console to show you the end of the script execution.
