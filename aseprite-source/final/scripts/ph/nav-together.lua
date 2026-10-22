-- ph/nav-together : sunflower with 12 alternating gold petals on a stem with two leaves
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 24.5

local function petal(a)
  local ca, sa = math.cos(a), math.sin(a)
  local function P(r, w) return { cx + ca * r - sa * w, cy + sa * r + ca * w } end
  return c:poly({ P(5, 0), P(9, -3.6), P(13, -2.8), P(15.5, 0), P(13, 2.8), P(9, 3.6) })
end
local light, dark = c:mask(), c:mask()
for i = 0, 11 do
  local a = (i * 30 - 90) * math.pi / 180
  if i % 2 == 0 then light:add(petal(a)) else dark:add(petal(a)) end
end

local leafL = c:poly({ {31, 49}, {26, 43}, {19, 41}, {16, 42}, {21, 47}, {27, 50} })
local leafR = c:poly({ {34, 44}, {38, 38}, {45, 35}, {48, 36}, {44, 41}, {38, 45} })

c:build{
  { "stem",  c:rect(30, 34, 33, 52), "#4a8a3e", { gloss = false } },
  { "leafL", leafL, "#58a03e", { gloss = false } },
  { "leafR", leafR, "#7ab55c", { gloss = false } },
  { "dark",  dark, "gold", { gloss = false } },
  { "light", light, "#f5cf6a", { gloss = { 22, 13 } } },
  { "disc",  c:ellipse(cx, cy, 7, 7), "#8c4a1a", { gloss = false } },
}
c:fill(c:ellipse(cx + 0.5, cy + 0.5, 4, 4), "#5e2f1e")
-- leaf veins
c:fill(c:line({ {29, 48}, {22, 44} }, 1), "#3a6e30")
c:fill(c:line({ {36, 43}, {43, 38} }, 1), "#4a8a3e")
-- seed dots and disc gloss
c:paint({ "gg", "g." }, 27, 20, { g = "#dcb06a" })
c:px(32, 23, "#8c4a1a"); c:px(30, 26, "#8c4a1a"); c:px(34, 27, "#8c4a1a")

local t = c:save(O .. "aseprite/ph/nav-together.aseprite", O .. "png/ph/nav-together.png")
print(GV.report(t))
