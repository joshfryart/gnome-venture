local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cx, cy = 31.5, 30
-- outer ring: 5 petal lobes around the centre
local outer = c:mask()
for i = 0, 4 do
  local a = math.rad(-90 + i * 72)
  outer:add(c:ellipse(cx + math.cos(a) * 11, cy + math.sin(a) * 11, 10))
end
outer:add(c:ellipse(cx, cy, 14))
-- mid ring: 5 lobes offset by 36 deg
local mid = c:mask()
for i = 0, 4 do
  local a = math.rad(-54 + i * 72)
  mid:add(c:ellipse(cx + math.cos(a) * 6, cy + math.sin(a) * 6, 6.5))
end
local core = c:ellipse(cx, cy - 1, 4.5)
local stalk = c:rrect(28, 44, 35, 55, 1)

local whole = outer:copy():add(stalk)
local p = c:build{
  { "stalk", stalk, GV.ramp("#a4b86a") },
  { "outer", outer, GV.ramp("#4a8a3e"), { light = whole, gloss = { 18, 20 } } },
  { "mid", mid, GV.ramp("#6a9a3a"), { light = outer, gloss = false } },
  { "core", core, "dusk", { light = outer, gloss = { 29, 27 } } },
}
-- dark gaps between outer lobes (radial notches at lobe joins)
for i = 0, 4 do
  local a = math.rad(-54 + i * 72)
  local x0, y0 = cx + math.cos(a) * 15, cy + math.sin(a) * 15
  local x1, y1 = cx + math.cos(a) * 20, cy + math.sin(a) * 20
  c:fill(c:line({ { math.floor(x0 + .5), math.floor(y0 + .5) }, { math.floor(x1 + .5), math.floor(y1 + .5) } }, 1):clip(outer), "#2f5a2a")
end
-- purple frill tips on two outer lobes
c:fill(c:ellipse(14, 26, 2):clip(outer), "#7b66b4")
c:fill(c:ellipse(49, 38, 2):clip(outer), "#7b66b4")
c:fill(c:ellipse(39, 12, 1.5):clip(outer), "#7b66b4")
local t = c:save(O .. "aseprite/ph/kalette.aseprite", O .. "png/ph/kalette.png")
print(GV.report(t))
