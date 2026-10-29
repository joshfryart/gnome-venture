-- season-flake.lua : Cat Fish winter room bits (replace the CSS dots of .cfs-wi in catfish.css).
-- Run: AppRun -b --script season-flake.lua
-- Writes out/cf-season-flake.png (6x6 six-point snowflake) and out/cf-season-flake-small.png (3x3 puff, depth),
-- plus their .aseprite. Drawn at 1x (the room is 320x200), hard pixels, 4 colours, no white:
--   L #c8e8f4 cream-blue (the room's lightest blue), B #9ccfe8 ice base, S #a894dc pale lilac shade,
--   N #54447f violet drop (the leg ramp) on the lower right only, so the flake still reads on the bright
--   sunbeam / pale-blue glass patch while staying a pale speck (not a dark one) on the cream wall and floor.
-- Light from the upper left: arms on the lit side are L, the lower-right arms and hub fall to B and S.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local LEG = { L = "#c8e8f4", B = "#9ccfe8", S = "#a894dc", N = "#54447f" }

local function draw(name, rows)
  local c = GV.canvas{ w = #rows[1], h = #rows, mode = "scene" }
  c:paint(rows, 0, 0, LEG)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(name .. ": " .. GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
end

-- six spokes: up, down, and four tips at about 30 deg off the horizontal; 1 px violet drop to the lower right
draw("cf-season-flake", {
  "..L...",
  "L.LNB.",
  ".LLB.N",
  "L.BSS.",
  ".NSN.N",
  "...N..",
})
-- far flake: a 3x3 puff, lit top-left, lilac below, violet drop on the right and corner
draw("cf-season-flake-small", {
  ".L.",
  "LBN",
  ".SN",
})
