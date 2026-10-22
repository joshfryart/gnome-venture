local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function leaf(bx, by, tx, ty, wd)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local mx, my = bx + dx * 0.5, by + dy * 0.5
  return c:poly({ { bx, by }, { mx + nx * wd / 2, my + ny * wd / 2 }, { tx, ty }, { mx - nx * wd / 2, my - ny * wd / 2 } })
end

local mound = c:ellipse(31.5, 50, 19, 7)
local light, dark = "moss", GV.ramp("#4a8a3e")

c:build{
  { "mound", mound, GV.ramp("#7a4a1f"), { gloss = false } },
  { "top", c:ellipse(31.5, 48, 14, 3.5), GV.ramp("#9a6b3f"), { gloss = false } },
  { "leafL", leaf(30, 47, 9, 41, 10), light },
  { "leafR", leaf(33, 47, 54, 41, 10), dark },
  { "leafIL", leaf(30, 47, 13, 29, 9), dark },
  { "leafIR", leaf(33, 47, 50, 29, 9), light },
  { "fruit", c:ellipse(31.5, 30, 9.5, 9.5), GV.ramp("#6a9a3a") },
  { "stem", c:rect(31, 17, 32, 21), GV.ramp("#2f5a2a"), { flat = true } },
}

-- leaf midribs
c:line({ { 27, 46 }, { 13, 42 } }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)
c:line({ { 36, 46 }, { 50, 42 } }, 1):each(function(x, y) c:px(x, y, "#2f5a2a") end)

local t = c:save(O .. "aseprite/ph/stage-fruit-3.aseprite", O .. "png/ph/stage-fruit-3.png")
print(GV.report(t))
