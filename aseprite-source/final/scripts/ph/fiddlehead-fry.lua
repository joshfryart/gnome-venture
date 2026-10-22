local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function spiral(cx, cy, r0, r1, turns, a0)
  local pts = {}
  local n = math.floor(turns * 28)
  for i = 0, n do
    local t = i / n
    local a = a0 + t * turns * 2 * math.pi
    local r = r0 + (r1 - r0) * t
    pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
  end
  return pts
end

-- plate
local rim  = c:ellipse(31.5, 42, 26, 11)
local well = c:ellipse(31.5, 41, 19, 7)
-- bumpy mound of fiddleheads
local mound = c:ellipse(31, 37, 13, 7)
mound:add(c:ellipse(25, 32, 6, 5)); mound:add(c:ellipse(34, 29, 7, 6)); mound:add(c:ellipse(40, 34, 5, 4.5))
local stray = c:ellipse(49, 43, 3, 3)

local p = c:build{
  { "rim",   rim,   GV.ramp("#d6c9b6") },
  { "well",  well,  GV.ramp("#f4f0e0"), { gloss = false } },
  { "mound", mound, "moss", { gloss = { 22, 33 } } },
  { "stray", stray, "moss", { gloss = false } },
}
-- fern curls
local deep = "#2f5a2a"
local sp = c:line(spiral(32, 33, 1.5, 7.5, 1.55, 0), 2)
sp:clip(mound:shrink(1)); c:fill(sp, deep)
local s2 = c:line(spiral(24, 33, 1, 3.5, 1.0, 3.3), 1); s2:clip(mound:shrink(1)); c:fill(s2, deep)
local s3 = c:line(spiral(49, 43, 0.5, 2, 1.0, 1.0), 1); s3:clip(stray); c:fill(s3, deep)
c:px(48, 41, GV.R.moss.gloss)
c:ground(31.5, 53, 22, 2)

local t = c:save(O .. "aseprite/ph/fiddlehead-fry.aseprite", O .. "png/ph/fiddlehead-fry.png")
print(GV.report(t))
