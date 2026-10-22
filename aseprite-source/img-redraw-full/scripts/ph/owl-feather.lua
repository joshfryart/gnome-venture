local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- feather axis from base (15,53) to tip (50,9)
local ax, ay, bx, by = 15, 53, 50, 9
local dx, dy = bx - ax, by - ay
local L = math.sqrt(dx * dx + dy * dy)
local ux, uy = dx / L, dy / L
local nx, ny = -uy, ux          -- points to the upper-left side? (0.79,0.62) -> right/down
local function P(t, s) return { ax + dx * t + nx * s, ay + dy * t + ny * s } end
local function hw(t)            -- half width profile
  if t < 0.12 then return 0 end
  local k = (t - 0.12) / 0.88
  return 11 * math.sin(math.pi * k ^ 0.75) ^ 0.8 + 0.6
end
local right, left = { P(0.12, 0) }, { P(0.12, 0) }
for i = 1, 24 do
  local t = 0.12 + 0.88 * i / 24
  right[#right + 1] = P(t, hw(t) * 0.95)
  left[#left + 1] = P(t, -hw(t))
end
right[#right + 1] = P(1.0, 0); left[#left + 1] = P(1.0, 0)
-- close along axis
local function closepoly(side)
  local pts = {}
  for _, p in ipairs(side) do pts[#pts + 1] = p end
  return pts
end
local rmask = c:poly(closepoly(right))
local lmask = c:poly(closepoly(left))
-- V notch on the right vane edge (splits the barbs)
local np = P(0.70, 0)
rmask:cut(c:poly({ P(0.64, 13), P(0.69, 4), P(0.73, 13) }))
-- small split on the left too, lower down
lmask:cut(c:poly({ P(0.36, -10.5), P(0.40, -6), P(0.42, -10.5) }))
lmask:cut(rmask)

local p = c:build{
  { "right", rmask, GV.ramp("#c9a96e"), {} },
  { "left",  lmask, GV.ramp("#f1ece0"), { light = rmask:copy():add(lmask) } },
}

-- dark cross bars (owl barring), angled like barbs (sweeping back toward base)
local vane = rmask:copy():add(lmask)
local bar = GV.ramp("#7a4a1f")
for _, t in ipairs({ 0.34, 0.50, 0.64, 0.80 }) do
  local wv = hw(t) + 1
  local m = c:line({ P(t - 0.07, -wv), P(t, 0), P(t - 0.07, wv) }, 2):clip(vane)
  c:fill(m, bar.base)
end

-- quill
local q = c:line({ { 13, 56 }, P(0.12, 0), P(0.55, 0), P(0.97, 0) }, 2)
c:part(q, GV.ramp("#7a4a1f"), { flat = true })
-- quill end, pale
c:part(c:rect(11, 55, 13, 57), GV.ramp("#f1ece0"), { flat = true })
-- dark tip
c:fill(c:poly({ P(0.90, -2.2), P(1.03, 0), P(0.90, 2.2) }):clip(vane), "#3d2a1c")

local t = c:save(O .. "aseprite/ph/owl-feather.aseprite", O .. "png/ph/owl-feather.png")
print(GV.report(t))
