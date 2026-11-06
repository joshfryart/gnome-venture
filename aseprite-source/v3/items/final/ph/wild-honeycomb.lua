-- wild-honeycomb (lean D3o_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-honeycomb" }
-- flower cluster of seven hex cells, wax walls, glossy honey; two capped; honey drips off the bottom. quirk: one stuck bee.
local WAX = { "#8a4f1a", "#b87420", "#dba02e", "#f0c14b", "#f9dc7c", "#fff0b0" }
local HON = { "#a85a10", "#cf7d14", "#ec9d1a", "#f8bb2c", "#ffd54e", "#fff2a8" }
local CAP = { "#a0782e", "#c79a46", "#e0b968", "#f0d594" }
local function hex(cx, cy, r)
  local p = {}
  for i = 0, 5 do local a = pi / 6 + i * pi / 3 p[#p + 1] = { cx + r * cos(a), cy + r * sin(a) } end
  return c:poly(p)
end
local cells = { {32, 31}, {32, 20}, {41.5, 25.5}, {41.5, 36.5}, {32, 42}, {22.5, 36.5}, {22.5, 25.5} }
local all = HP.mask()
local hm = {}
for i, p in ipairs(cells) do hm[i] = hex(p[1], p[2], 6.4) all:add(hm[i]) end
shade(c, all, WAX, 12, { amb = 0.25, wrap = 0.3 })
for i, p in ipairs(cells) do
  local inner = hm[i]:shrink(2)
  if i == 3 or i == 6 then
    shade(c, inner, CAP, 3, { amb = 0.3 })
    c:px(p[1], p[2], CAP[4])
  else
    local n, v = shade(c, inner, HON, 3, { amb = 0.1, wrap = 0.2 })
    c:px(floor(p[1] - 1), floor(p[2] - 1), HON[6])
  end
  -- ink-dark wall line shadow
  hm[i]:edge():each(function(x, y) if x > p[1] and y > p[2] then c:px(x, y, WAX[1]) end end)
end
-- drip
local dm = G.tube({ {36, 46}, {36, 49}, {37, 53}, {37, 56} }, function(t) return 2.0 * (1 - t) ^ 0.6 + 0.8 end)
dm:each(function(x, y) c:px(x, y, HON[3 + ((x < 37) and 1 or 0)]) end)
c:px(36, 55, HON[6]) c:px(37, 57, HON[2]) c:px(38, 57, HON[2])
-- bee (quirk) on upper-left cell edge
c:fillMask(c:ellipse(15, 18, 2, 1), "#3a2a1a") c:px(14, 18, "#f4c430") c:px(16, 18, "#f4c430") c:px(15, 16, "#e0f0ff") c:px(16, 16, "#e0f0ff") c:px(13, 18, "#2b1c26")
G.fin(c, "wild-honeycomb")
