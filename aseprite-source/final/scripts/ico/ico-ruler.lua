local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local a = math.rad(40)
local ux, uy = math.cos(a), -math.sin(a)      -- along the bar (to upper right)
local nx, ny = -math.sin(a), -math.cos(a)     -- normal toward upper left (lit edge)
local cx, cy, HL, HT = 32, 32, 25, 8
local function P(t, s) return { cx + t * ux + s * nx, cy + t * uy + s * ny } end
local bar = c:poly{ P(-HL, HT), P(HL, HT), P(HL, -HT), P(-HL, -HT) }
bar = bar:shrink(2):grow(2)
local ramp = GV.ramp("#e8c547")
c:part(bar, ramp, { gloss = { 14, 37 } })
-- ticks on the upper-left (lit) edge, long / short alternating
local tick, hi = "#a28158", "#f0d49a"
local ts = { -18, -12, -6, 0, 6, 12, 18 }
for i, t in ipairs(ts) do
  local L = (i % 2 == 1) and 8 or 5
  local p0, p1 = P(t, HT - 2), P(t, HT - 2 - L)
  local m = c:line({ { math.floor(p0[1] + 0.5), math.floor(p0[2] + 0.5) }, { math.floor(p1[1] + 0.5), math.floor(p1[2] + 0.5) } }, 2):clip(bar)
  local h = m:shift(-1, -1):cut(m):clip(bar)
  c:fill(h, hi)
  c:fill(m, tick)
end
local t = c:save(O .. "aseprite/ico/ico-ruler.aseprite", O .. "png/ico/ico-ruler.png")
print(GV.report(t))
