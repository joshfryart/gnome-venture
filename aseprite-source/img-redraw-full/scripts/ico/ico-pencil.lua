local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- axis from tip (12,51) up-right; P(t) = (12+t, 51-t); half-width offset (3.5,3.5)
local function P(t) return 12 + t, 51 - t end
local function band(t0, t1, o)
  o = o or 3.5
  local ax, ay = P(t0); local bx, by = P(t1)
  return c:poly({ {ax - o, ay - o}, {bx - o, by - o}, {bx + o, by + o}, {ax + o, ay + o} })
end
local tx, ty = P(0)
local cx9, cy9 = P(9)
local cone = c:poly({ {tx, ty + 1}, {cx9 - 4, cy9 - 4}, {cx9 + 4, cy9 + 4} })
local lx, ly = P(4)
local lead = c:poly({ {tx - 0.5, ty + 1.5}, {lx - 2, ly - 2}, {lx + 2, ly + 2} })
local shaft = band(9, 27)
local ferrule = band(27, 32)
local ex, ey = P(33.5)
local eraser = band(32, 33.5):add(c:ellipse(ex, ey, 4.5, 4.5))
local p = c:build{
  { "cone",    cone,    GV.ramp("#f8eed2") },
  { "lead",    lead,    GV.ramp("#5b6470"), { flat = true } },
  { "shaft",   shaft,   GV.ramp("#e8c547"), { cres = 3, deep = 1 } },
  { "ferrule", ferrule, GV.ramp("#968f96"), { cres = 3, deep = 1, gloss = false } },
  { "eraser",  eraser,  GV.ramp("#d9667f"), { cres = 3, deep = 1 } },
}
-- lit facet stripe on the upper-left of the shaft
local s1x, s1y = P(11); local s2x, s2y = P(25)
c:fill(c:line({ {s1x - 2, s1y - 2}, {s2x - 2, s2y - 2} }, 2):clip(shaft), GV.ramp("#e8c547").rim)
-- ferrule grooves
local fsh = GV.ramp("#968f96").shade
for _, t in ipairs({ 29, 30.5 }) do
  local gx, gy = P(t)
  c:fill(c:line({ {gx - 3, gy - 3}, {gx + 3, gy + 3} }, 1):clip(ferrule), fsh)
end
local t = c:save(O .. "aseprite/ico/ico-pencil.aseprite", O .. "png/ico/ico-pencil.png")
print(GV.report(t))
