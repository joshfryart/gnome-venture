-- wonder-the-standing-stones.lua : dusk hill, a ring of mossy humming stones; the nearest one drops a seed.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 78

L.sky(c, "dusk", HOR)
L.stars(c, 30, 45, 11)
local moon = c:ellipse(200, 24, 8, 8); moon:cut(c:ellipse(204, 21, 7, 7))
c:fill(moon, "#fff1c8")
L.cloud(c, 60, 56, 16, "#8c6ab8", "#b784b4"); L.cloud(c, 170, 62, 18, "#b784b4", "#e39a86"); L.cloud(c, 120, 48, 11, "#6a4fa8", "#8c6ab8")
-- far hills
c:part(L.below(c, function(x) return 74 + 5 * math.sin(x / 23) + 3 * math.sin(x / 9) end), GV.ramp("#5a4a98"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 3 })
c:part(L.below(c, function(x) return 84 + 4 * math.sin(x / 31 + 2) + 2 * math.sin(x / 11) end), GV.ramp("#4a7a6a"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 3 })
-- near hill with the ring
local hill = L.below(c, function(x) return 92 + 6 * math.sin((x - 20) / 60) * 1 - 0.0 * x end)
c:part(hill, "moss", { gloss = false, rim = false, outline = false, cres = 8, deep = 14 })
-- path of worn earth leading to the ring
c:fill(c:poly({ {112,H-8},{128,H-8},{124,112},{116,112} }), "#c9a96e")
c:fill(c:poly({ {116,H-8},{128,H-8},{125,112},{120,112} }), "#9a6b3f")
-- grass tufts
for i = 0, 40 do
  local x = (i * 53 + 7) % W; local y = 98 + (i * 29) % 30
  if y < H - 8 then c:px(x, y, "#a4b86a"); c:px(x + 1, y - 1, "#c8d77a"); c:px(x + 2, y, "#a4b86a") end
end
-- flowers
for i = 0, 14 do
  local x = (i * 71 + 19) % W; local y = 100 + (i * 37) % 28
  c:px(x, y, (i % 2 == 0) and "#f6b8cf" or "#fff1c8")
end

-- ring of stones (back to front)
local cx, cy, rx, ry = 120, 108, 84, 16
local st = {}
for i = 0, 6 do
  local a = i * (2 * math.pi / 7) + 1.1
  st[#st + 1] = { x = cx + rx * math.cos(a), y = cy + ry * math.sin(a), i = i }
end
table.sort(st, function(a, b) return a.y < b.y end)
local front
local heights = { 22, 26, 20, 28, 24, 23, 27, 21, 25 }
for n, s in ipairs(st) do
  local t = (s.y - (cy - ry)) / (2 * ry) -- 0 back .. 1 front
  local w = math.floor(12 + 12 * t); local h = math.floor(heights[s.i + 1] * (0.8 + 0.8 * t))
  local x0, y1 = math.floor(s.x - w / 2), math.floor(s.y)
  local m = c:poly({ {x0, y1}, {x0 + 1, y1 - h + 5}, {x0 + 3, y1 - h + 1}, {x0 + w - 4, y1 - h}, {x0 + w - 1, y1 - h + 4}, {x0 + w, y1} })
  local isfront = n == #st
  c:ground(s.x, y1, w / 2 + 1, 1.5, "#2f5a2a")
  c:part(m, GV.ramp(({ "#8b8f96", "#7d8590", "#9a9aa2" })[(s.i % 3) + 1]), { cres = 4, deep = 6 })
  -- moss cap + drip
  local cap = m:copy():clip(c:rect(x0 - 1, y1 - h - 1, x0 + w + 1, y1 - h + 3))
  c:fill(cap, "#7ab55c")
  c:px(x0 + 2, y1 - h + 4, "#7ab55c"); c:px(x0 + w - 3, y1 - h + 4, "#6a9a3a")
  c:px(x0 + 3, y1 - h + 1, "#c8d77a")
  -- lichen / crack
  c:px(x0 + 3, y1 - math.floor(h / 2), "#5b6470"); c:px(x0 + 3, y1 - math.floor(h / 2) + 1, "#5b6470")
  c:px(x0 + w - 4, y1 - 4, "#a4b86a"); c:px(x0 + w - 5, y1 - 3, "#a4b86a")
  -- coins on top of some
  if s.i % 2 == 0 and not isfront then c:fill(c:rect(x0 + 3, y1 - h - 2, x0 + 5, y1 - h - 1), "#f5cf6a"); c:px(x0 + 3, y1 - h - 2, "#fff1c8") end
  if isfront then front = { x0 = x0, y1 = y1, w = w, h = h } end
end
-- humming: lavender arcs rising from the stones and from the front stone's hollow
local function arc(x, y, r, col)
  for a = -60, 60, 6 do
    local rad = math.rad(a); local px, py = x + math.floor(r * math.cos(rad) + 0.5), y + math.floor(r * math.sin(rad) + 0.5)
    c:px(px, py, col)
  end
end
-- front stone with a hollow top and a seed dropping
if front then
  local hx, hy = front.x0 + math.floor(front.w / 2), front.y1 - front.h
  c:fill(c:ellipse(hx, hy + 1, 3, 1.4), "#2a1a10")
  c:fill(c:rect(hx - 1, hy + 1, hx + 1, hy + 1), "#5b6470")
  -- seed falling from hollow
  c:part(c:ellipse(hx + 1, hy - 12, 2, 3), GV.ramp("#d9a660"), { flat = true, gloss = false })
  c:px(hx, hy - 13, "#fff1c8")
  c:px(hx + 1, hy - 7, "#f5cf6a"); c:px(hx + 1, hy - 5, "#f5cf6a")
  c:px(hx - 3, hy - 6, "#fff1c8"); c:px(hx + 5, hy - 9, "#fff1c8")
end
for _, a in ipairs({ {38, 78, 5}, {38, 78, 9}, {38, 78, 13}, {206, 80, 5}, {206, 80, 9}, {206, 80, 13}, {120, 40, 6}, {120, 40, 10} }) do
  arc(a[1], a[2], a[3], "#c3b2ea")
end
-- fireflies
for _, f in ipairs({ {40, 100}, {90, 88}, {160, 96}, {200, 110}, {20, 118}, {228, 104} }) do c:px(f[1], f[2], "#fff1c8"); c:px(f[1] + 1, f[2], "#f5cf6a") end
L.finish(c, "wonder-the-standing-stones")
