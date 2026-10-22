local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, r)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and r or r * 0.45
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end

local dish = c:ellipse(31.5, 43, 21, 8)
local inner = c:ellipse(31.5, 40, 17, 4.5)
-- bumpy crumble mound
local mound = c:ellipse(31.5, 40, 16, 13):cut(c:rect(0, 41, 63, 63))
mound:add(c:ellipse(20, 35, 5, 5)):add(c:ellipse(43, 35, 5, 5)):add(c:ellipse(31.5, 29, 6, 5))
mound:add(c:ellipse(25, 30, 4.5, 4)):add(c:ellipse(38, 30, 4.5, 4))
mound:clip(c:rect(0, 0, 63, 41))

c:build{
  { "dish", dish, GV.ramp("#d6c9b6") },
  { "inner", inner, GV.ramp("#f4f0e0"), { gloss = false } },
  { "mound", mound, GV.ramp("#b0bc66"), { light = mound:copy():add(dish) } },
  { "apple", c:ellipse(24, 36, 3.5), GV.ramp("#58a03e") },
  { "pear", c:ellipse(39.5, 34, 4), "moss" },
  { "plum", c:ellipse(31.5, 29, 3), "gold" },
  { "star", star(31.5, 15, 7), "gold" },
}
-- crumble flecks
c:paint({ "c..c" }, 28, 36, { c = "#e2d48a" })
c:paint({ "c...c" }, 21, 30, { c = "#e2d48a" })
c:paint({ "c" }, 44, 37, { c = "#e2d48a" })
c:seam({ {14, 48}, {49, 48} })
local t = c:save(O .. "aseprite/ph/feast-orchard-crumble.aseprite", O .. "png/ph/feast-orchard-crumble.png")
print(GV.report(t))
