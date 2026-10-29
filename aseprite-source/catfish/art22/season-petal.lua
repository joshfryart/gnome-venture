-- season-petal.lua : Cat Fish spring season sprite, a falling blossom petal (art22).
-- Run: AppRun -b --script season-petal.lua
-- Writes art22/out/cf-season-petal.png + .aseprite (frame A) and cf-season-petal-b.png + .aseprite (frame B,
-- the tumble: the same petal turned a quarter over). 6 x 6 each, drawn at 1x like the cats and yarn frames, to
-- replace the 3 x 3 CSS dots of .cfs-sp in catfish.css (they fall 206 px with a 26 px drift; swap A/B to tumble).
-- Too small for the 1 px #000000 border (it would eat the petal), so the canvas is mode "scene" (no outline pass,
-- no border) and the edge is drawn by hand in the room's petal shade, which reads on the cream wall, the blue
-- wainscot, the sunbeam and the floor.
-- Tones (petal family, Part A + the room cushion): edge #b8466e (cushion shade), curl shade #f29abb (cushion light),
-- base #fbdce6 (pink-white: petal 300 #f6b8cf lifted toward cream), light #f6b8cf (petal 300) as the lit rim,
-- highlight #fff3c8 (pale-subject gloss). Light from the upper left; the lower-right edge curls up and shows the
-- shade band (the "crescent"). Cherry-petal shape: a pointed base end and a wide, slightly notched tip.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

local KEY = { o = "#b8466e", s = "#f29abb", b = "#fbdce6", l = "#f6b8cf", h = "#fff3c8" }

local FRAMES = {
  ["cf-season-petal"] = { -- A: tip to the upper right (notched), base end lower left, curl along the lower right
    "...oo.",
    "..ohbo",
    ".ohbbo",
    "olbbso",
    "olsso.",
    ".ooo..",
  },
  ["cf-season-petal-b"] = { -- B: turned a quarter over, tip to the upper left, curl lower right
    ".oo...",
    "ohbo..",
    "ohbbo.",
    "olbbso",
    ".olsso",
    "..ooo.",
  },
}

local fails = 0
for name, rows in pairs(FRAMES) do
  assert(#rows == 6)
  for _, r in ipairs(rows) do assert(#r == 6, name) end
  local c = GV.canvas{ w = 6, h = 6, mode = "scene" }
  c:paint(rows, 0, 0, KEY)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-18s ", name) .. GV.report(t))
  if t.semi ~= 0 or t.bw ~= 0 then fails = fails + 1 end
end
assert(fails == 0, "check failed")
