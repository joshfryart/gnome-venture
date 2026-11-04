-- ico-pick (Opus single pass, aA8_1). Slim mining pick on the diagonal: a curved steel head (sharp point upper-left,
-- flat chisel lower-right) on a thin ash haft running down to the lower-left, leather grip with a twisted wrap.
-- Material: per-pixel tube light on the head (6-tone cool steel), bright bevel edge + specular streak along the crown
-- of the arc, darker socket collar with AO where haft meets head; haft 6-tone wood with grain lines and a pale end
-- grain cap; grip strap in diagonal twist bands.
-- quirk: a little blue ore crystal is stuck on the point.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("ico-pick")

local STEEL = { "#2f3150", "#4d5072", "#737896", "#9aa0ba", "#c4c9db", "#e9ecf4" }
local WOOD  = { "#4a2a26", "#71402e", "#9a5f3a", "#c0844c", "#dca868", "#f0cd92" }
local LEATH = { "#3a1c22", "#5e2c2c", "#86433a", "#ad6448" }
local SPEC = "#fbfcff"

-- haft: lower-left end -> eye
local E = { 38, 20 }
local B = { 13, 55 }
local ux, uy = E[1] - B[1], E[2] - B[2]
local L = sqrt(ux*ux + uy*uy) ux, uy = ux / L, uy / L
local px, py = uy * -1, ux                -- perpendicular
if px + py < 0 then px, py = -px, -py end -- points lower-right
local hm, hn, HT, HS = X.cyl(B[1], B[2], E[1] + ux * 3, E[2] + uy * 3, function(t) return 1.75 end)
local wtok = { r = { name = "wood" } }
local hv = X.light(hn, { amb = 0.1, wrap = 0.3 })
local hb = {}
-- wood grain: long thin darker lines along the haft, broken by hash
hm:each(function(x, y) local k = K(x, y)
  local s = HS[k]
  if abs(s - 0.25) < 0.22 and X.hash(floor(HT[k] * 20), 1, 3) > 0.35 then hb[k] = -1 end
  if abs(s + 0.55) < 0.15 and X.hash(floor(HT[k] * 14), 2, 5) > 0.55 then hb[k] = -1 end
end)
A.paintV(hm, hv, WOOD, { 0.3, 0.5, 0.66, 0.8, 0.93 }, hb, wtok)
-- end grain cap (pale, with a ring)
local cap = A.fmask(B[1] - 3, B[2] - 3, B[1] + 3, B[2] + 3, function(x, y)
  return hm:has(x, y) and HT[K(x, y)] < 0.045 end)
cap:each(function(x, y) c:put(x, y, WOOD[5], wtok) end)
c:put(B[1] - 1, B[2], WOOD[6], wtok) c:put(B[1] + 1, B[2], WOOD[4], wtok)

-- leather grip with a twisted wrap: diagonal bands across the haft
local gm = HP.mask()
hm:each(function(x, y) local t = HT[K(x, y)] if t > 0.08 and t < 0.36 then gm:set(x, y) end end)
local ltok = { r = { name = "leather" } }
local grow = gm:copy()
-- grip slightly thicker than haft
gm:each(function(x, y) local k = K(x, y) if HS[k] > 0.5 then grow:set(x + floor(px + .5), y + floor(py + .5)) end end)
grow:each(function(x, y)
  local rx, ry = x - B[1], y - B[2]
  local along = rx * ux + ry * uy
  local s = (rx * px + ry * py) / 2.2
  local ph = (along + s * 1.6) % 3.2
  local tone = 3
  if s > 0.4 then tone = 2 end
  if s < -0.4 then tone = 4 end
  if ph < 0.9 then tone = max(1, tone - 2) end           -- groove between wraps
  if ph >= 0.9 and ph < 1.7 and s < 0.2 then tone = min(4, tone + 1) end
  c:put(x, y, LEATH[tone], ltok)
end)


-- head: curved arc across the haft top
local function at(a, b) return E[1] + px * a + ux * b, E[2] + py * a + uy * b end
local P0x, P0y = at(-21, -3.5)
local P1x, P1y = at(-10, 4.5)
local P2x, P2y = at(10, 4.5)
local P3x, P3y = at(20, -3)
local pts = { { P0x, P0y }, { P1x, P1y }, { P2x, P2y }, { P3x, P3y } }
local function hw(t)
  if t < 0.5 then return 0.55 + 3.1 * (t / 0.5) ^ 0.8 end          -- tapers to the point
  return 3.65 - 1.55 * ((t - 0.5) / 0.5) ^ 1.3                   -- chisel end stays 2 wide
end
local m, n, T, S, samp = A.tube(pts, hw)
local stok = { r = { name = "steel" } }
-- flatten the cross section a bit (forged bevel faces), then light
for k, nn in pairs(n) do n[k] = { A.norm(nn[1] * 1.25, nn[2] * 1.25, nn[3]) } end
local v = X.light(n, { amb = 0.08, wrap = 0.22 })
local bias = {}
-- AO on the head around the socket
local sock = c:ellipse(E[1] + ux * 1, E[2] + uy * 1, 3.5, 3.5)
X.ao(bias, m, sock, 2, -1)
local idx = A.paintV(m, v, STEEL, { 0.28, 0.46, 0.62, 0.76, 0.9 }, bias, stok)
-- bright bevel edge on the lit (upper/outer) rim of the arc
m:edge():each(function(x, y) local k = K(x, y)
  if S[k] < -0.6 and T[k] > 0.08 and T[k] < 0.92 and (idx[k] or 1) >= 4 then c:put(x, y, STEEL[6], stok) end
  if S[k] > 0.7 and T[k] > 0.15 and T[k] < 0.9 then c:put(x, y, STEEL[1], stok) end
end)
-- flat chisel face: a darker facet line across the end
m:each(function(x, y) local k = K(x, y) if T[k] > 0.965 then c:put(x, y, STEEL[3], stok) end end)
-- specular streak along the crown, one glint
for _, q in ipairs{ 0.3, 0.34, 0.38, 0.42 } do
  local s = samp[floor(q * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5), STEEL[6], stok)
end
do local s = samp[floor(0.36 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5), SPEC, stok) end

-- socket collar: a darker steel band where the haft passes through
local col = A.fmask(E[1] - 6, E[2] - 6, E[1] + 6, E[2] + 6, function(x, y)
  local rx, ry = x - E[1], y - E[2]
  local a, b = rx * px + ry * py, rx * ux + ry * uy
  return abs(a) <= 2.9 and b >= -2.2 and b <= 3.4
end)
local cn = X.pillow(col, 1.6)
local cb = {} col:each(function(x, y) cb[K(x, y)] = -1 end)
A.litN(col, cn, STEEL, { cuts = { 0.3, 0.5, 0.68, 0.84, 0.97 }, bias = cb, tok = stok })
-- collar rivet
c:put(floor(E[1] + ux * 0.5 - px * 1 + .5), floor(E[2] + uy * 0.5 - py * 1 + .5), STEEL[5], stok)
-- haft end grain showing through the top of the collar
local top = A.fmask(E[1] - 6, E[2] - 6, E[1] + 6, E[2] + 6, function(x, y)
  local rx, ry = x - E[1], y - E[2]
  local a, b = rx * px + ry * py, rx * ux + ry * uy
  return abs(a) <= 1.4 and b >= 3.6 and b <= 5.4
end)
top:each(function(x, y) c:put(x, y, WOOD[5], wtok) end)
-- iron wedge line in the end grain
do local x, y = floor(E[1] + ux * 4.4 + .5), floor(E[2] + uy * 4.4 + .5) c:put(x, y, STEEL[2], stok) end
-- AO row on the haft just under the collar
hm:each(function(x, y) local k = K(x, y)
  local b = (x - E[1]) * ux + (y - E[2]) * uy
  if b < -2.2 and b >= -3.6 and not col:has(x, y) then c:put(x, y, WOOD[1], wtok) end end)

-- quirk: a little blue ore crystal stuck on the point
local tx, ty = floor(P0x + .5), floor(P0y + .5)
A.bmp({ ".a.", "abc", "bcd" }, tx - 1, ty + 1, { a = "#b6f0e0", b = "#5fc4c8", c = "#3a86b0", d = "#2a4a7a" })
A.done()
