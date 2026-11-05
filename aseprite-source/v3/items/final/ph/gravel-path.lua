-- gravel-path (lean P1b_O2)
local NAME = "gravel-path"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local drawn = HP.mask()
-- lit(mask, normals, ramp, opts): tone with normals; opts.seam = colour for the border where it overlaps earlier art
local function lit(m, n, ramp, o)
  o = o or {}
  local prior = drawn:copy()
  local _, v = G.toneN(c, m, n, ramp, o)
  if o.seam then m:edge():each(function(x, y) if prior:has(x, y) then c:px(x, y, o.seam) end end) end
  drawn:add(m)
  return v
end
local function pil(m, ramp, R, o) return lit(m, X.pillow(m, R), ramp, o) end
local function hx(x, y, s) return X.hash(x, y, s or 1) end
-- isometric stretch of path: timber edging around a bed of mixed bright pebbles; quirk: a weed sprouting between stones and one pale quartz
local W = { "#2e1d12", "#4d3220", "#6f4a2b", "#946438", "#bd8a50", "#e0b476" }
local RAMPS = {
  { "#2c3345", "#445068", "#66769a", "#8fa0be", "#b8c6da", "#e2ebf4" },
  { "#4a3326", "#6c4b36", "#946a48", "#bd9265", "#dcb98a", "#f2dcb4" },
  { "#4a2a3a", "#6d3e4e", "#94566a", "#bd7a88", "#dba2a6", "#f4cfc8" },
  { "#5a5040", "#7c705a", "#a39578", "#c8bc9a", "#e2d8b8", "#f6efd6" },
}
c:groundShadow(32, 52, 27, 3)
local outer = c:poly{ {5, 33}, {32, 20}, {59, 33}, {32, 46} }
local lface = c:poly{ {5, 33}, {32, 46}, {32, 51}, {5, 38} }
local rface = c:poly{ {59, 33}, {32, 46}, {32, 51}, {59, 38} }
lface:each(function(x, y) c:put(x, y, (x % 9 == 0) and W[3] or W[4]) end)
rface:each(function(x, y) c:put(x, y, (x % 9 == 4) and W[1] or W[2]) end)
lface:each(function(x, y) if not lface:has(x, y - 1) or (x % 9 == 0) then c:px(x, y, x % 9 == 0 and W[3] or W[5]) end end)
rface:each(function(x, y) if not rface:has(x, y + 1) then c:px(x, y, W[1]) end end)
local inner = c:poly{ {12, 33}, {32, 23}, {52, 33}, {32, 43} }
local frame = outer:copy():cut(inner)
frame:each(function(x, y)
  local col
  if y < 33 then col = (x < 32) and W[5] or W[4] else col = (x < 32) and W[4] or W[3] end
  if hx(x, y, 4) > 0.86 then col = W[2] end
  c:put(x, y, col)
end)
-- bright top-left lip
frame:edge():each(function(x, y) if y < 34 and x < 33 and not outer:copy():shrink(1):has(x, y) == false then end end)
-- bed
inner:each(function(x, y) c:put(x, y, hx(x, y, 9) > 0.5 and "#2a2433" or "#3a3246") end)
inner:edge():each(function(x, y) if y < 34 then c:px(x, y, "#17131f") end end)
-- pebbles
local pebbles = {}
local safe = inner:copy():shrink(2)
local function place(x, y, rx, ry, ramp)
  for _, p in ipairs(pebbles) do
    if ((x - p[1]) / (rx + p[3] + 0.8)) ^ 2 + ((y - p[2]) / (ry + p[4] + 0.6)) ^ 2 < 1 then return false end
  end
  local m, n = G.oval(x, y, rx, ry, 0, 0.9)
  local ok = true
  m:each(function(px, py) if not safe:has(px, py) then ok = false end end)
  if not ok then return false end
  pebbles[#pebbles + 1] = { x, y, rx, ry }
  lit(m, n, ramp, { amb = 0.1 })
  if hx(x, y, 3) > 0.35 then c:px(floor(x - rx * 0.4), floor(y - ry * 0.5), ramp[6]) end
  return true
end
place(32, 33, 3.4, 2.6, RAMPS[4])   -- quartz
c:px(31, 32, "#fff8f0") c:px(30, 33, "#ffe8f4") c:px(33, 34, "#c8a8c8")
place(21, 32, 2.2, 1.6, RAMPS[1])
for i = 1, 600 do
  local x = 11 + floor(hx(i, 1, 21) * 42)
  local y = 23 + floor(hx(i, 2, 21) * 21)
  local f = floor(hx(i, 3, 21) * 4) + 1
  place(x, y, 1.6 + hx(i, 4, 21) * 1.5, 1.2 + hx(i, 5, 21) * 0.9, RAMPS[f])
end
-- weed
for _, p in ipairs{ {41, 28, "#2f8040"}, {41, 27, "#4da44c"}, {40, 26, "#7cc660"}, {42, 26, "#7cc660"}, {39, 25, "#b0e284"}, {43, 25, "#b0e284"} } do c:px(p[1], p[2], p[3]) end
G.save(c, NAME)
