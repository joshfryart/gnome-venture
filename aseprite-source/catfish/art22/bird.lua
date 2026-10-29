-- art22/bird.lua : redraw of the window-bird flit frames cf-bird-1..3.png (12 x 10, drawn by code at 2x = 24 x 20,
-- top-left at export (-2, 44), room-layout.json "bird"). Fixes the S4 frames, which were saved in sticker mode
-- and so carried a 1 px #000000 border the static robin of cf-room-window.png lacks (the swap popped).
-- Now saved in scene mode (no border, no halo): the robin sits on sprite px (1,1)..(10,8) = room grid (0,23)..(9,30),
-- the lower pane's glass; row 0, row 9, col 0 and col 11 stay transparent, so nothing lands on the window frame.
--   1 perched  the overlay's ROBIN of cf_room.lua, pixel for pixel (the swap is invisible)
--   2 hop      crouched and airborne: body one row shorter, legs tucked, a sky gap under it, tail cocked up
--   3 wings    near wing fanned up over the back (lit edge top, dark feather tips), feet still on the bar
-- Palette = the overlay robin's 9 colours only. Run: AppRun -b --script bird.lua   Writes out/cf-bird-<n>.png/.aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- same key as cf_room.lua ROBIN_KEY
local KEY = { u = "ol3", r = "#c98a4a", h = "#9a6b3f", s = "#7a4a1f", O = "#f08a24", o = "#e0501f",
              e = "ol3", k = "#e8a317", c = "#e8d0a0" }

local FRAMES = {
  { -- 1 perched: identical to cf_room.lua ROBIN
    "....uuuu..",
    "...urrhhu.",
    "..urhOeOkk",
    "u.uhOOOOu.",
    "ruuhOOoou.",
    ".rhhhOooou",
    "..ushhcccu",
    "...uussuu.",
  },
  { -- 2 hop
    "u...uuuu..",
    "ru.urrhhu.",
    ".rurhOeOkk",
    ".uuhOOOOu.",
    "..uhhOooou",
    "..ushhcccu",
    "...uussuu.",
    "..........",
  },
  { -- 3 wings
    "uu..uuuu..",
    "rhuurrhhu.",
    "srhrhOeOkk",
    "usrhOOOOu.",
    "rushOOoou.",
    ".rhhhOooou",
    "..ushhcccu",
    "...uussuu.",
  },
}

for n, rows in ipairs(FRAMES) do
  assert(#rows == 8)
  for _, r in ipairs(rows) do assert(#r == 10, "frame " .. n .. " row width") end
  local c = GV.canvas{ w = 12, h = 10, mode = "scene", out = 1 }
  c:paint(rows, 1, 1, KEY)
  print("cf-bird-" .. n .. ": " .. GV.report(c:save(OUT .. "cf-bird-" .. n .. ".aseprite", OUT .. "cf-bird-" .. n .. ".png")))
end
