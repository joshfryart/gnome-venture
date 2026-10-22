local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered bar polygon from (x0,y0) width w0 to (x1,y1) width w1
local function taper(x0, y0, x1, y1, w0, w1)
  local dx, dy = x1 - x0, y1 - y0
  local l = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / l, dx / l
  return c:poly({
    { x0 + nx * w0 / 2, y0 + ny * w0 / 2 }, { x1 + nx * w1 / 2, y1 + ny * w1 / 2 },
    { x1 - nx * w1 / 2, y1 - ny * w1 / 2 }, { x0 - nx * w0 / 2, y0 - ny * w0 / 2 } })
end

local PX, PY = 32, 34
local wood = "wood"
local blade = GV.ramp("#b6814d", { rim = "#f0d49a" })

local hL = taper(PX, PY, 21, 47, 6, 5)
local hR = taper(PX, PY, 43, 47, 6, 5)
local gL = c:ellipse(20, 49, 4.5, 4.5)
local gR = c:ellipse(43, 49, 4.5, 4.5)
-- blades: wide at the pivot, slight curve, sharp tip
local bL = taper(PX + 1, PY + 1, 24, 22, 7, 5):add(taper(24, 22, 18, 12, 5, 1))
local bR = taper(PX - 1, PY + 1, 40, 22, 7, 5):add(taper(40, 22, 46, 12, 5, 1))

local p = c:build{
  { "hL", hL, wood },
  { "hR", hR, wood },
  { "gL", gL, "#a8582f" },
  { "gR", gR, "#a8582f" },
  { "bR", bR, blade },
  { "bL", bL, blade },
}
-- finger holes in the grips
c:fill(c:ellipse(20, 49, 1.5, 1.5), "#5e2f1e")
c:fill(c:ellipse(43, 49, 1.5, 1.5), "#5e2f1e")
-- pivot rivet
c:fill(c:ellipse(32, 33, 3.5, 3.5), "#5e2f1e")
c:part(c:ellipse(32, 33, 2.5, 2.5), "#a5663a", { flat = true })
c:px(31, 32, "#d9a660")
-- blade shine along the upper-left blade
for i = 0, 6 do
  local x, y = 26 - i, 24 - math.floor(i * 1.6 + 0.5)
  if p.bL.m:has(x, y) then c:px(x, y, "#fff3c8") end
end

local t = c:save(D .. "img-redraw-full/aseprite/ph/garden-snips.aseprite", D .. "img-redraw-full/png/ph/garden-snips.png")
print(GV.report(t))
