--[[
 * ReaScript Name: Solo in place exclusive track under mouse and play
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-06-26)
	+ Initial Release
--]]

function Main()
  solo_state = 2
  track, pos = reaper.BR_TrackAtMouseCursor()
  if track then
    solo = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
    if solo ~= solo_state then
      reaper.PreventUIRefresh(1)
      reaper.SetMediaTrackInfo_Value(track, "I_SOLO", solo_state)
      count_track = reaper.CountTracks(0)
      for i = 0, count_track - 1 do
        tr = reaper.GetTrack(0,i)
        if tr ~= track and reaper.GetMediaTrackInfo_Value(tr, "I_SOLO") ~=0 then
          reaper.SetMediaTrackInfo_Value(tr, "I_SOLO", 0)
        end
      end
      reaper.SetOnlyTrackSelected( track )
      reaper.PreventUIRefresh(-1)
    end
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_PLAY_MOUSECURSOR"),0) -- SWS/BR: Play from mouse cursor position
  end
end

reaper.defer(Main)
