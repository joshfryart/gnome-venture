-- ico-egg (final, Opus). One slim upright hen's egg, narrow crown and fuller base, standing on a 2-tone ground shadow.
-- Material: per-pixel ellipsoid light snapped to a 6-tone warm-tan shell ramp, a faint upper-left -> lower-right
-- falloff, chalky shell pores (sparse 1 px tone steps) and a handful of darker brown speckles, a cool violet
-- reflected light along the lower-right edge, a dark contact row where the base meets the ground, one specular
-- streak + cream glint on the upper-left shoulder.
-- quirk: a single downy feather is still stuck to the shell, low on the right side.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-egg")
local SH = { "#5a2f2e", "#8a4e3a", "#b5764c", "#d69b63", "#edc085", "#fbe2b4" }
local SPEC, BOUNCE = "#fff4d6", "#a7788a"
local CX, CY, B, A0, KK = 31.5, 31, 21.5, 13.6, 0.2
local stok = A.tok("shell")

c:groundShadow(32, CY + B + 1, 13, 2)

local m, n, Q = HP.mask(), {}, {}
for y = floor(CY - B) - 1, floor(CY + B) + 1 do
  local yy = (y - CY) / (B + 0.45)
  local a = A0 * (1 + KK * yy)
  for x = floor(CX - a) - 2, floor(CX + a) + 2 do
    local u = (x - CX) / (a + 0.45)
    local q = u * u + yy * yy
    if q <= 1 then
      m:set(x, y)
      local k = K(x, y)
      local nx, ny, nz = u, yy - 0.12 * u * u, sqrt(max(1 - q, 0.015)) * 1.05
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      n[k] = { nx / l, ny / l, nz / l }
      Q[k] = q
    end
  end
end
local bias = {}
-- contact: the bottom 2 rows near the ground go a step darker
m:each(function(x, y) if y >= CY + B - 1 then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, m, n, SH, { tok = stok, amb = 0.1, wrap = 0.4, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 },
  bias = bias, tilt = { CX, CY, 24, 0.07 } })

-- shell pores: sparse single tone steps (chalky texture), never on the glint zone
m:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  if idx[k] and idx[k] >= 3 and h < 0.028 then A.step(c, idx, SH, x, y, -1, stok)
  elseif idx[k] and idx[k] >= 3 and idx[k] <= 4 and h > 0.985 then A.step(c, idx, SH, x, y, 1, stok) end
end)
-- speckles: darker brown dots, a few 2 px
local SPK = { { 37, 22, 2 }, { 24, 30, 1 }, { 40, 34, 2 }, { 30, 42, 1 }, { 35, 46, 2 }, { 22, 40, 1 }, { 43, 41, 1 }, { 28, 18, 1 }, { 33, 30, 1 } }
for _, s in ipairs(SPK) do
  local x, y = s[1], s[2]
  local k = K(x, y)
  if idx[k] then c:put(x, y, SH[max(1, idx[k] - 2)], stok) end
  if s[3] == 2 and idx[K(x + 1, y)] then c:put(x + 1, y, SH[max(1, idx[K(x + 1, y)] - 1)], stok) end
end
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.7 and y < CY + B - 3 and y > CY - 4 then c:put(x, y, BOUNCE, stok) end end)
-- specular streak + glint on the upper-left shoulder
for _, p in ipairs{ { 24, 16 }, { 25, 15 }, { 23, 17 }, { 22, 18 }, { 22, 19 }, { 21, 20 }, { 21, 21 }, { 23, 18 }, { 24, 17 } } do c:put(p[1], p[2], SH[6], stok) end
c:put(25, 16, SPEC, stok) c:put(24, 16, SPEC, stok) c:put(23, 17, SPEC, stok) c:put(26, 15, SPEC, stok)

-- quirk: a downy feather stuck low on the right side (quill + soft vanes), with a contact shadow on the shell
local FE = { q = "#c79a6a", w = "#fff4d6", v = "#efe4cf", s = "#cfc0b0", d = "#8a4e3a" }
local fmap = {
  "..........w.",
  "........w.vw",
  "......wvwvqv",
  "....w.vwqqs.",
  "..wvwvqqss..",
  ".w.vqq.s.s..",
  "wvqq.s......",
  ".qd.........",
  "d...........",
}
local fx, fy = 35, 34
-- contact shadow one pixel down-right of the feather on the shell
for yy, row in ipairs(fmap) do for xx = 1, #row do
  if row:sub(xx, xx) ~= "." then
    local x, y = fx + xx, fy + yy
    local k = K(x, y)
    if idx[k] then A.step(c, idx, SH, x, y, -1, stok) end
  end end end
A.map(c, fmap, fx, fy, FE)
A.save(c, "ico-egg")
