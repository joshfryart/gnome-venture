local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- rotated ellipse mask (deg clockwise)
local function rell(cx, cy, rx, ry, deg)
  local m, a = c:mask(), math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- S-crease points along the bean long axis
local function crease(cx, cy, ry, deg, amp, flip)
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  local pts = {}
  for i = 0, 10 do
    local t = -0.72 + 1.44 * i / 10
    local v = t * ry
    local u = amp * math.sin(t * math.pi * 1.3) * flip
    pts[#pts + 1] = { math.floor(cx + u * ca - v * sa + 0.5), math.floor(cy + u * sa + v * ca + 0.5) }
  end
  return pts
end

local backR = GV.ramp("#7a3f22")
local frontR = GV.ramp("#9a5a30")
local back = rell(38, 25, 12, 17, 32)
local front = rell(26, 38, 13, 18, -25)
local p = c:build{
  { "back", back, backR },
  { "front", front, frontR },
}
-- creases: dark groove with a lit lip on the upper-left
local bk = crease(38, 25, 17, 32, 2.2, -1)
local fr = crease(26, 38, 18, -25, 2.4, 1)
local gb = c:line(bk, 2):clip(back:copy():cut(front))
local gf = c:line(fr, 2):clip(front)
c:fill(gb, "#2a1a10"); c:fill(gf, "#2a1a10")
c:fill(gf:shift(-1, 0):cut(gf):clip(front:shrink(2)), frontR.rim)
c:fill(gb:shift(-1, 0):cut(gb):clip(back:shrink(2)), backR.rim)

local t = c:save(O .. "aseprite/ph/coffee.aseprite", O .. "png/ph/coffee.png")
print(GV.report(t))
