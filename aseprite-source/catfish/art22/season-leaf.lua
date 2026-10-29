-- season-leaf.lua : Cat Fish autumn room bit (replaces the .cfs-au CSS dots in .cfseason).
-- Run: AppRun -b --script season-leaf.lua    Writes art22/out/cf-season-leaf.png + -b (+ .aseprite).
--   cf-season-leaf.png    a felt maple-ish leaf, stem lower left, tip upper right, 1 px midrib vein.
--   cf-season-leaf-b.png  the tumble frame: the same leaf a quarter turn on (stem upper left, tip lower right).
-- Shown at 1x on the 320 x 200 room (like cf-yarn-*): 9 x 9 file = 7 x 7 art + the 1 px #000000 border.
-- Light stays upper left in both frames (the tone is not rotated with the shape): gloss dot and gold on the
-- upper-left lobe, orange body, red crescent and deep edge at the lower right. Ramp: the brief's gold + red rows.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

local KEY = {
  g = "#fff1c8", -- gold gloss (1 px)
  y = "#f5cf6a", -- gold rim, lit lobe
  o = "#f08a24", -- ember 300, body
  e = "#e0501f", -- ember 400, body turning
  r = "#ae2a2a", -- red shade, crescent
  d = "#6b1b2c", -- red deep, lower-right edge
  v = "#7a3a14", -- gold deep: stem and midrib vein
}

local LEAF = {
  { -- a: stem lower left, tip upper right; lobes either side of the midrib
    "....yy.",
    "..gyyoe",
    ".yyyvoe",
    ".yovoer",
    "..veerd",
    ".v..rd.",
    "v......",
  },
  { -- b: tumbled a quarter turn: stem upper left, tip lower right
    "v......",
    ".v..yy.",
    "..vyoo.",
    ".gyvoe.",
    ".yoovee",
    "..oeerd",
    "...edd.",
  },
}

for n, rows in ipairs(LEAF) do
  for _, r in ipairs(rows) do assert(#r == 7 and #rows == 7) end
  local c = GV.canvas{ w = 9, h = 9, mode = "sticker", margin = 0 }
  c:paint(rows, 1, 1, KEY)
  local name = n == 1 and "cf-season-leaf" or "cf-season-leaf-b"
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(name .. " " .. GV.report(t))
  assert(t.semi == 0)
end
