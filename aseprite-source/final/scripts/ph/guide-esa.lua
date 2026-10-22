local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- 5-point star polygon
local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return c:poly(pts)
end

-- page block peeking at the right/bottom edge (book thickness)
local pages = c:rrect(18, 11, 52, 56, 3)
local cover = c:rrect(14, 8, 50, 54, 4)
local spine = c:rrect(10, 8, 18, 56, 2)
local label = c:rrect(23, 15, 45, 30, 3)
local st = star(35.5, 44.5, 8, 4)

local p = c:build{
  { "pages", pages, "cream", { gloss = false } },
  { "cover", cover, "#3f93b2", { stitch = { side = "lit" } } },
  { "spine", spine, GV.ramp("#2f6290"), { gloss = { 12, 17 } } },
  { "label", label, "#f4f0e0", { pale = true, gloss = { 25, 17 } } },
  { "star", st, "gold", { cres = 3 } },
}
-- page lines on the block edge
for y = 20, 52, 4 do c:px(51, y, GV.R.cream.shade) end
-- label marks (no readable text)
c:fill(c:rect(27, 21, 41, 22), GV.C.ol3)
c:fill(c:rect(27, 25, 36, 26), GV.C.ol3)
-- spine bands
c:fill(c:rect(11, 46, 17, 47), GV.R.gold.base)
c:fill(c:rect(11, 50, 17, 50), GV.R.gold.shade)
-- seam down the spine edge
c:seam({ { 16, 16 }, { 16, 54 } })
c:button(12, 11)

local t = c:save(O .. "aseprite/ph/guide-esa.aseprite", O .. "png/ph/guide-esa.png")
print(GV.report(t))
