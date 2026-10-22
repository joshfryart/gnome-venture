local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function leaf(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local px, py = -dy / L * w / 2, dx / L * w / 2
  local function at(f, s) return { bx + dx * f + px * s, by + dy * f + py * s } end
  return c:poly({ at(0, 0), at(0.25, 0.8), at(0.55, 1), at(0.85, 0.6), at(1.05, 0),
                  at(0.85, -0.6), at(0.55, -1), at(0.25, -0.8) })
end

local mound = c:ellipse(31.5, 46, 19, 6)
local top = c:ellipse(31.5, 44.5, 15, 3.5)
local stake = c:rrect(41, 13, 43, 46, 1)
local vine = c:line({ {30, 45}, {31, 41}, {33, 36}, {35, 31}, {37, 27}, {39, 22}, {40, 18}, {41, 15} }, 2)
local l1 = leaf(31, 40, 19, 36, 7)
local l2 = leaf(34, 32, 47, 28, 7)
local l3 = leaf(38, 23, 27, 18, 7)

c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false } },
  { "stake", stake, GV.ramp("#8a4f2a"), { gloss = false } },
  { "vine", vine, GV.ramp("#58a03e"), { flat = true } },
  { "l1", l1, GV.ramp("#7ab55c") },
  { "l2", l2, GV.ramp("#58a03e") },
  { "l3", l3, GV.ramp("#7ab55c") },
}
-- leaf midribs
c:fill(c:line({ {30, 39}, {22, 37} }, 1), "#4a8a3e")
c:fill(c:line({ {36, 31}, {45, 29} }, 1), "#2f5a2a")
c:fill(c:line({ {37, 22}, {29, 19} }, 1), "#4a8a3e")
-- twine ties
c:paint({ "ggg", "eee" }, 41, 20, { g = "#f5cf6a", e = "#e8a317" })
c:paint({ "ggg", "eee" }, 41, 35, { g = "#f5cf6a", e = "#e8a317" })
local t = c:save(O .. "aseprite/ph/stage-legume-3.aseprite", O .. "png/ph/stage-legume-3.png")
print(GV.report(t))
