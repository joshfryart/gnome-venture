local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handle = c:line({ {15, 53}, {37, 15} }, 4):add(c:ellipse(15, 53, 2.5, 2.5))
local blade = c:poly({ {32, 9}, {55, 9}, {52, 22}, {34, 22} }):add(c:rrect(32, 8, 55, 12, 2))
local collar = c:rrect(33, 18, 42, 23, 1)

local p = c:build{
  { "handle", handle, GV.ramp("#b6814d") },
  { "blade",  blade,  "gold" },
  { "collar", collar, GV.ramp("#f5cf6a"), { gloss = false } },
}

-- grip wrap: three short bands across the handle near the foot
for _, q in ipairs({ {17, 50}, {19, 46}, {21, 42} }) do
  local band = c:line({ {q[1] - 4, q[2] - 2}, {q[1] + 4, q[2] + 2} }, 2):clip(handle)
  c:fill(band, "#8a4f2a")
end

-- blade rivets and seam along the lower edge
c:paint({ "rr", "rr" }, 44, 14, { r = "#7a3a14" })
c:paint({ "rr", "rr" }, 49, 13, { r = "#7a3a14" })
c:seam({ {36, 20}, {51, 20} })
-- masterwork star on collar
c:px(37, 20, GV.R.gold.deep); c:px(38, 20, GV.R.gold.deep)

local t = c:save(O .. "aseprite/ph/masterwork-wheel-hoe.aseprite", O .. "png/ph/masterwork-wheel-hoe.png")
print(GV.report(t))
