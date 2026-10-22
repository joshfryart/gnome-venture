local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sagging rope: parabola from (11,17) down to (31.5,30) and back up to (52,17)
local function ry(x) local d = (x - 31.5) / 20.5; return math.floor(29 - 15 * d * d + 0.5) end
local pts = {}
for x = 11, 52, 3 do pts[#pts + 1] = { x, ry(x) } end
pts[#pts + 1] = { 52, ry(52) }
local rope = c:line(pts, 2)
local knots = c:rrect(9, ry(11) - 1, 12, ry(11) + 2, 1):add(c:rrect(51, ry(52) - 1, 54, ry(52) + 2, 1))

-- three pennants hanging from the rope
local function flag(x0, x1, tipx, tipy)
  return c:poly({ { x0, ry(x0) }, { x1 + 1, ry(x1) }, { tipx, tipy } })
end
local L = flag(13, 25, 19, 47)
local M = flag(27, 36, 31.5, 50)
local R = flag(38, 50, 44, 47)

local dusk = GV.ramp("#7b66b4")
c:build{
  { "rope", rope, "#5e2f1e", { flat = true } },
  { "left", L, dusk },
  { "mid", M, "gold" },
  { "right", R, dusk },
  { "knots", knots, "#5e2f1e", { flat = true } },
}

-- top hem shade and gold stitch along each flag top
local function hem(x0, x1)
  local top, sm = {}, {}
  for x = x0, x1 do
    c:px(x, ry(x) + 1, "#3e2f66")
  end
  c:seam({ { x0 + 2, ry(x0 + 2) + 3 }, { x1 - 2, ry(x1 - 2) + 3 } })
end
hem(14, 25); hem(28, 35); hem(38, 49)

local t = c:save(O .. "aseprite/ph/opening-day-bunting.aseprite", O .. "png/ph/opening-day-bunting.png")
print(GV.report(t))
