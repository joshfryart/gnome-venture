local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- star polygon
local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
  end
  return c:poly(pts)
end

local cover = c:rrect(14, 8, 52, 55, 4)
local p = c:build{
  { "cover", cover, "water", { light = cover } },
  { "spine", c:rrect(10, 8, 17, 55, 2), "#44281c" },
  { "label", c:rrect(23, 15, 47, 30, 3), "#f4f0e0", { pale = true } },
  { "star",  star(42, 47, 7, 3), "gold", { gloss = { 40, 44 } } },
}
-- mist lines on label
c:paint({
  "..uu....uu....uu..",
  "uu..uuuu..uuuu..uu",
}, 27, 20, { u = "#4a2c1a" })
c:paint({
  "..uu....uu..",
  "uu..uuuu..uu",
}, 27, 25, { u = "#4a2c1a" })
-- cover wave (cream, 1 px)
c:paint({
  "..cc....cc....cc.",
  "cc..cccc..cccc..c",
}, 22, 37, { c = "#c8ecdc" })
c:seam({ { 20, 16 }, { 20, 52 } })
c:button(19, 10)
local t = c:save(O .. "aseprite/ph/guide-nwe.aseprite", O .. "png/ph/guide-nwe.png")
print(GV.report(t))
