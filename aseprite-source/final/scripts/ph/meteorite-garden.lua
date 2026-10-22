local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- plinth: trapezoid, top narrower
local plinth = c:poly({ {20, 40}, {45, 40}, {49, 55}, {16, 55} })
local rock = c:ellipse(32, 28, 14, 14)
local leafA = c:ellipse(33.5, 12, 2.5, 3.5)
local leafB = c:ellipse(40.5, 11, 3.5, 2.5)

local p = c:build{
  { "plinth", plinth, "#8b8f96", { cres = 4 } },
  { "rock", rock, "#c9c5bc", { gloss = { 22, 19 } } },
  { "leafA", leafA, "moss", { flat = true } },
  { "leafB", leafB, "moss", { flat = true } },
}

-- stem out of the top crater
c:paint({ "s.", "s.", "ss" }, 35, 15, { s = "#4a8a3e" })

-- craters: dark dimple, shadowed upper-left inner wall, lit lower-right lip
local function crater(cx, cy, r)
  local d = c:ellipse(cx, cy, r, r)
  c:fill(d, "#8b8f96")
  local inner = d:copy():cut(d:shift(1, 1))
  c:fill(inner, "#5b6470")
  local lip = d:shift(1, 1):cut(d)
  c:fill(lip, "#e6e2da")
end
crater(25.5, 24.5, 2.5)
crater(38.5, 31.5, 2.5)
crater(29, 36, 2)
crater(35, 18, 1.5)

-- plinth lip seam (below the rock)
c:seam({ { 21, 43 }, { 45, 43 } })

-- chips lower left
c:paint({ "dd", ".d" }, 19, 50, { d = "#5b6470" })
c:paint({ "dd" }, 23, 53, { d = "#5b6470" })

local t = c:save(O .. "aseprite/ph/meteorite-garden.aseprite", O .. "png/ph/meteorite-garden.png")
print(GV.report(t))
