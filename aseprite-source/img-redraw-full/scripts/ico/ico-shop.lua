local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local parts = {
  { "wall", c:rect(13, 26, 50, 55), GV.ramp("#e8d3a2") },
  { "door", c:rrect(26, 37, 37, 55, 2), GV.ramp("#5e2f1e"), { gloss = false } },
}
local whole = c:rect(8, 12, 55, 28)
for i = 0, 3 do
  local x0 = 8 + i * 12
  local m = c:rect(x0, 12, x0 + 11, 22):add(c:ellipse(x0 + 5.5, 22, 6, 5.5):cut(c:rect(0, 0, 63, 21)))
  local col = (i % 2 == 0) and "#d6322b" or "#f8eed2"
  parts[#parts + 1] = { "st" .. i, m, GV.ramp(col), { light = whole } }
end
local p = c:build(parts)
for i = 0, 3 do
  local x0 = 8 + i * 12
  local r = p["st" .. i].r
  c:fill(c:rect(x0, 12, x0 + 11, 14):clip(p["st" .. i].m), r.shade)
end
c:seam({ { 8, 20 }, { 55, 20 } })
local t = c:save(O .. "aseprite/ico/ico-shop.aseprite", O .. "png/ico/ico-shop.png")
print(GV.report(t))
