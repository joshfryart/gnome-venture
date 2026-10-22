local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local wings = c:ellipse(21, 31, 11, 7):add(c:ellipse(43, 31, 11, 7))
local abd = c:ellipse(32, 41, 11.5, 10.5)
local sting = c:poly({ {30, 50}, {35, 50}, {33, 54}, {32, 54} })
local head = c:ellipse(32, 26, 9, 8)
local ant = c:line({ {29, 19}, {27, 15}, {24, 12} }, 2):add(c:line({ {35, 19}, {37, 15}, {40, 12} }, 2))
local clubs = c:rrect(21, 9, 24, 12, 1):add(c:rrect(40, 9, 43, 12, 1))

local p = c:build{
  { "wings", wings, GV.ramp("#e6f1ec") },
  { "sting", sting, GV.ramp("#3e2f66"), { flat = true } },
  { "abd",   abd,   "gold" },
  { "ant",   ant,   GV.ramp("#3e2f66"), { flat = true } },
  { "clubs", clubs, GV.ramp("#3e2f66"), { flat = true } },
  { "head",  head,  "gold" },
}
-- curved dark stripes on the abdomen
for _, y in ipairs({ 37, 43, 48 }) do
  local band = c:ellipse(32, y - 6, 16, 8):cut(c:ellipse(32, y - 9, 16, 8)):clip(abd:shrink(1))
  c:fill(band, "#291d4a")
end
-- face patch
c:fill(c:ellipse(32, 29.5, 4, 2.5), "#f8eed2")
c:paint({ "u...u", ".uuu." }, 30, 29, { u = "umber" })
c:eye(25, 22, true); c:eye(36, 22, true)

local t = c:save(O .. "aseprite/ico/ico-bee.aseprite", O .. "png/ico/ico-bee.png")
print(GV.report(t))
