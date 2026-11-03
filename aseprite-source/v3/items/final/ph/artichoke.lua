-- artichoke (final pass, Opus). A slim upright globe artichoke: an egg-shaped bud of overlapping pointed scales in
-- staggered rows (lower rows in front, each tip lit on its rim, ambient shade where the scale behind tucks under it),
-- purple flush rising toward the closed top, silvery waxy bloom on the lit side, two lower bracts flaring out, a thin
-- ridged stem with a fresh cut end (pale end grain, vascular dots).
-- quirk: one round dewdrop sits on a scale, glassy rim + pale core.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local NAME = "artichoke"
local c = A.new(NAME)

local GR   = { "#1b332f", "#28503f", "#3b6f4a", "#578c55", "#7ea866", "#aac884" }
local PURP = { "#2f1d3c", "#4a2a55", "#6b3d6f", "#8f5a8c", "#b07fa8", "#d2a8c6" }
local STEM = { "#2a4a3a", "#3f6a48", "#5f8c58", "#88b070", "#b4d092" }
local BLOOM, CUT, CUTD = "#c9dcc0", "#e4ecb8", "#a8bf7c"

-- bulb: egg, centre x 32, y 8..45
local CX, YT, YC, YB = 32, 8, 28, 45
local function hw(y)
  if y < YC then local t = (YC - y) / (YC - YT + 0.6) return 12.4 * sqrt(max(0, 1 - t ^ 2.1)) * (1 - 0.18 * t ^ 3) end
  local t = (y - YC) / (YB - YC + 0.8) return 12.4 * sqrt(max(0, 1 - t ^ 2.4)) + (t > 0.8 and 0.8 or 0)
end
local bulb = HP.mask()
for y = YT, YB do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do bulb:set(x, y) end end

-- stem: slight lean, ~4 px wide
local stok = { r = { name = "stem" } }
local sm, sn, ST, SS = A.stem(c, { { 32, 43 }, { 32.3, 48 }, { 33, 52 }, { 34, 56 } }, function(t) return 1.75 - 0.15 * t end, STEM,
  { tok = stok, cuts = { 0.22, 0.42, 0.62, 0.82 }, cut = bulb })
-- ridges along the stem
sm:each(function(x, y) local k = K(x, y) if abs(SS[k] + 0.1) < 0.12 and ST[k] > 0.2 then c:put(x, y, STEM[2], stok) end end)
-- AO under the bulb
sm:each(function(x, y) if y <= 47 then c:put(x, y, y <= 46 and STEM[1] or STEM[2], stok) end end)
-- cut end: pale end grain disc, darker ring, two vascular dots
for _, p in ipairs{ { 32, 57, CUTD }, { 33, 57, CUT }, { 34, 57, CUT }, { 35, 57, CUTD }, { 33, 58, CUTD }, { 34, 58, CUTD } } do c:put(p[1], p[2], p[3], stok) end
c:put(34, 57, STEM[3], stok)

-- flaring lower bracts (outer scales opening away from the bud)
local btok = { r = { name = "bract" } }
local function bract(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.98 then return -1 end return max(0.4, w * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.7 * (1 - t * 0.55)) end, { fold = 0.35 })
  m:cut(bulb)
  local idx = A.shade(c, m, n, GR, { tok = btok, amb = 0.1 })
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.7 then c:put(x, y, PURP[max(2, min(5, idx[k]))], btok) end
    if abs(S[k]) < 0.15 and T[k] < 0.75 then c:put(x, y, GR[min(6, idx[k] + 1)], btok) end end)
  return m
end
local bl = bract(27, 43, 21, 42, 16, 36, 3.0)
local br = bract(37, 43, 43, 42, 48, 36, 3.0)

-- scale field. Rows top->bottom; lower rows sit in front. yEdge(row, x) = tip edge (arched, pointed at scale centre)
local ROWS = { 8.6, 12.5, 17, 22, 27.5, 33, 38.5, 43.5 }
local NS = { 2, 3, 4, 4, 4, 4, 4, 4 }   -- scales across the visible half-turn
local function edge(j, x, y)
  local h = max(1, hw(y))
  local u = asin(max(-0.999, min(0.999, (x - CX) / (h + 0.4))))
  local p = (u + pi / 2) / pi * NS[j] + ((j % 2 == 0) and 0.5 or 0)
  local f = p - floor(p)
  local a = abs(f - 0.5) * 2                -- 0 at scale centre, 1 at seam
  local H = 2.6 + j * 0.4
  return ROWS[j] + H * a ^ 1.5, f
end
local n = A.body(bulb, CX - 0.5, YC, 13, 6, 0.65)
local bias, info = {}, {}
bulb:each(function(x, y)
  local k = K(x, y)
  local own, d, e, f = 0, 99, 99, 0.5
  for j = 1, #ROWS do local ye, fj = edge(j, x, y) if ye <= y + 0.0 then own, d, f = j, y - ye, fj end end
  if own > 0 and own < #ROWS then e = edge(own + 1, x, y) - y end
  local b = 0
  if own == 0 then b = 0
  else
    if d < 1 then b = b + (f < 0.5 and 2 or 1) end                                     -- lit tip rim
    if e < 1.2 then b = b - 2 elseif e < 2.3 then b = b - 1 end     -- tucked under the scale in front
    if f > 0.5 and d < 3 then b = b - 0 end
  end
  bias[k] = b
  info[k] = { own, d, e, f }
end)
-- scalloped silhouette: notch the outline between rows so scale tips stand proud
local notch = {}
bulb:edge():each(function(x, y) local I = info[K(x, y)] if I[1] > 1 and I[3] < 1.2 and abs(x - CX) > hw(y) - 1.6 then notch[#notch + 1] = K(x, y) end end)
for _, k in ipairs(notch) do bulb.s[k] = nil end
X.ao(bias, bulb, sm, 1, -1)
local gtok = { r = { name = "bulb" } }
local idx, v = A.shade(c, bulb, n, GR, { bias = bias, tok = gtok, amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
-- purple flush on scale tips: strong on upper rows, only the very tip on lower ones
bulb:each(function(x, y) local k = K(x, y) local I = info[k] local own, d, e, f = I[1], I[2], I[3], I[4]
  local reach = own <= 1 and 9 or (own <= 3 and 2.6 - own * 0.3 or 0.9)
  local nearC = abs(f - 0.5) < (own <= 3 and 0.3 or 0.14)
  if (own == 0) or (d < reach and nearC) then
    c:put(x, y, PURP[max(1, min(6, idx[k] - (own == 0 and 0 or 0)))], gtok)
  end
end)
-- centre crease on each scale (a darker 1 px vein below the tip on the shade half)
bulb:each(function(x, y) local k = K(x, y) local I = info[k]
  if I[1] > 2 and I[2] >= 1 and I[2] < 3.5 and I[3] > 1.5 and abs(I[4] - 0.5) < 0.06 then A.step(c, idx, GR, x, y, -1, gtok) end end)
-- waxy bloom: pale silvery specks on the lit side, off the rims
local inner = bulb:copy():shrink(1)
inner:each(function(x, y) local k = K(x, y) local I = info[k]
  if v[k] > 0.62 and I[1] > 2 and I[3] > 2 and I[2] > 0.9 and X.hash(x, y, 7) > 0.86 and I[2] < 2.6 then c:put(x, y, BLOOM, gtok) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
bulb:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > 26 and y < 42 and (info[k][3] or 9) > 1.2 then c:put(x, y, "#5c7f86", gtok) end end)
-- specular on an upper-left scale
c:put(25, 22, "#e8f2d0", gtok) c:put(26, 22, "#e8f2d0", gtok) c:put(25, 23, GR[6], gtok)

-- quirk: dewdrop on a right-hand scale (3x3, glassy)
local dx, dy = 37, 30
A.map(c, { ".a.", "abc", "bcd" }, dx, dy, { a = "#d8f4ec", b = "#8fc8c0", c = "#f4fff8", d = "#4f8a86" }, gtok)
c:put(dx + 1, dy + 3, GR[1], gtok)  -- tiny contact shadow under the drop

A.save(c, NAME)
