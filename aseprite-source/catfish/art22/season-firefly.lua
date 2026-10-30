-- season-firefly.lua : Cat Fish summer firefly for the room's seasonal drift (replaces the .cfs-su CSS dots).
-- Run: AppRun -b --script season-firefly.lua
-- Writes out/cf-season-firefly.png (glow on) and out/cf-season-firefly-b.png (glow off), 5 x 6 each,
-- plus matching .aseprite files. Same footprint in both so the two frames swap in place.
-- Tiny sprite: hand-placed pixels (dusk dark head/thorax, 2 lavender wing pixels raised in a V, a round
-- lantern tail: bright core inside a 1 px yellow-green halo ring, crescent lower right). Hard pixels, no border:
-- the ring is the edge, so it reads on the cream wall, blue wainscot and wood floor. Glow off dims it to olive.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- 5 x 6, drawn at 0,0
local ART = {
  ".w.w.",   -- wings raised in a V (2 px)
  "..h..",   -- head
  ".rbr.",   -- thorax, top of the lantern ring
  "rcCcr",   -- lantern: hot spot upper left of centre
  "rcccr",   -- lantern body
  ".rrR.",   -- ring, deep (R) on the lower right
}
local ON = {
  h = "#291d4a",  -- dusk shade (head)
  b = "#3e2f66",  -- dusk base (thorax)
  w = "#a894dc",  -- dusk gloss (wings)
  C = "#fbfcb4",  -- glow hot spot, warm cream-yellow
  c = "#dcef4e",  -- glow core, yellow
  r = "#94bc2a",  -- 1 px halo ring, yellow-green
  R = "#6e9a24",  -- ring deep / core crescent, greener and darker
}
local OFF = {     -- same silhouette, lantern dimmed to olive (blinks in place)
  h = ON.h, b = ON.b, w = ON.w,
  C = "#a4ac4a",
  c = "#8a963a",
  r = "#66722c",
  R = "#4e5a26",
}

local function draw(pal, name)
  local c = GV.canvas{ w = 5, h = 6, mode = "scene" } -- scene: no auto border
  for y, row in ipairs(ART) do
    for x = 1, #row do
      local ch = row:sub(x, x)
      if pal[ch] then c:px(x - 1, y - 1, pal[ch]) end
    end
  end
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(name .. ": " .. GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
end
draw(ON, "cf-season-firefly")
draw(OFF, "cf-season-firefly-b")
