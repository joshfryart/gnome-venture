local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- fan: upper half-ellipse + triangle to the hinge, scalloped top
local fan = c:poly({ { 10, 18 }, { 55, 18 }, { 55, 24 }, { 34, 48 }, { 30, 48 }, { 10, 24 } })
local bx = { 15.5, 26.5, 37.5, 48.5 }
for i, x in ipairs(bx) do fan:add(c:ellipse(x, 17, 5.5, 6)) end
-- notches between bumps
for i = 1, 3 do
  local nx = (bx[i] + bx[i + 1]) / 2
  fan:cut(c:poly({ { nx - 2, 10 }, { nx + 2, 10 }, { nx + 0.5, 15 }, { nx - 0.5, 15 } }))
end
local ear = c:poly({ { 25, 44 }, { 39, 44 }, { 37, 52 }, { 27, 52 } })
-- moss blob over upper right
local moss = c:ellipse(44, 20, 9, 8)
moss:add(c:ellipse(50, 26, 5, 4)):add(c:ellipse(36, 16, 5, 5)):add(c:ellipse(48, 14, 6, 4))
moss:add(c:ellipse(40, 28, 4, 3))
moss:clip(fan:grow(1))

local p = c:build{
  { "fan", fan, GV.ramp("#7b66b4"), { gloss = { 17, 17 } } },
  { "ear", ear, GV.ramp("#54447f") },
  { "moss", moss, "moss", { gloss = { 38, 15 } } },
}
-- radial ridges (1 px accents), only on bare shell
local ridge = c:mask()
for _, tx in ipairs({ 11, 21, 32, 43, 53 }) do
  ridge:add(c:line({ { 32, 44 }, { tx, 20 } }, 1))
end
ridge:clip(fan:shrink(2)):cut(moss:grow(1)):cut(c:ellipse(18, 18, 3, 2.5))
c:fill(ridge, "#3e2f66")
c:fill(ridge:shift(1, 0):clip(fan:shrink(2)):cut(moss:grow(1)):cut(ridge), "#5a4890")
-- tufts
c:px(41, 18, "#c8d77a"); c:px(47, 23, "#c8d77a"); c:px(37, 23, "#c8d77a")
c:px(45, 13, "#a4b86a"); c:px(50, 21, "#a4b86a")
c:seam({ { 27, 45 }, { 37, 45 } })

local t = c:save(O .. "aseprite/ph/mossy-shell.aseprite", O .. "png/ph/mossy-shell.png")
print(GV.report(t))
