-- arctic-char (final, Opus). A slim, streamlined char in side view, head left. Per-pixel tube light: dark teal-olive
-- back, silver-green flank, spawning orange-red belly (6-tone each), pale pink spots on the flank, fine scale lattice,
-- a pale lateral line, gill-cover arc with AO behind it, gold-ringed eye with glint, wet specular on the head, cool
-- bounce under the belly. Fins with rays: dorsal, tiny adipose, pectoral, pelvic and anal fins in orange with the
-- char's bright cream leading edge, gently forked tail darkening to the tips.
-- quirk: a single snowflake has landed on the dorsal fin.
local NAME = "arctic-char"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.pi
local c = A.new(NAME)

local BACK  = { "#142a32", "#1f3e44", "#2d5852", "#41735e", "#5f9070", "#86ae86" }
local FLANK = { "#3a4a5e", "#5a6e7c", "#7f9696", "#a8bcb0", "#cbdac8", "#eaf2e0" }
local BELLY = { "#6a1e30", "#a22e2e", "#d24a2c", "#ee6c34", "#fa9450", "#ffbc7c" }
local FIN   = { "#5e1c2e", "#962a2e", "#c8452e", "#e66a3a", "#f69458" }
local TAIL  = { "#1a3038", "#284a4c", "#3c6658", "#58846a", "#7ca282" }
local SPOT, SPOT2 = "#f7b8b0", "#e08c8e"
local EDGE, BOUNCE = "#fff0dc", "#7e5a8e"
local CREAM = A.CREAM

-- body: tube along a gentle arc, snout at left
local pts = { { 9, 35 }, { 20, 31.5 }, { 36, 31.5 }, { 49, 33.5 } }
local function hw(t)
  if t < 0.12 then return 0.8 + 5.2 * (t / 0.12) ^ 0.65 end
  if t < 0.42 then return 6.0 + 1.6 * sin((t - 0.12) / 0.3 * pi / 2) end
  return 2.1 + 5.5 * ((1 - t) / 0.58) ^ 1.15
end
local bm, bn, BT, BS = A.tube(pts, hw)

-- fins (masks), drawn behind the body except the pectoral
local function finPoly(p) return HP.poly(p) end
local dorsal = finPoly{ { 27, 26 }, { 30, 19.5 }, { 33, 19 }, { 36, 21 }, { 38, 25.5 } }
local adip   = finPoly{ { 43, 28.6 }, { 45, 26.4 }, { 46.6, 27 }, { 46.4, 29.6 } }
local pelvic = finPoly{ { 30, 37.5 }, { 33.5, 43.6 }, { 35.6, 43.4 }, { 35.2, 37.5 } }
local anal   = finPoly{ { 39, 36.4 }, { 42.4, 41.6 }, { 44.4, 41.2 }, { 44.2, 35.6 } }
local tail   = finPoly{ { 47.5, 31.2 }, { 53, 25 }, { 57, 23.6 }, { 55, 30 }, { 54, 33.4 }, { 55, 37 }, { 57.2, 43.4 }, { 53, 42 }, { 47.5, 35.8 } }
for _, m in ipairs{ dorsal, adip, pelvic, anal, tail } do m:cut(bm) end
local ftok = { r = { name = "fin" } }
local ttok = { r = { name = "tail" } }
local function shadeFin(m, ramp, tok, rays, root, lead)
  local n = X.pillow(m, 1.6)
  local idx = A.toneN(c, m, n, ramp, { tok = tok, cuts = { 0.24, 0.44, 0.62, 0.8 }, amb = 0.2, wrap = 0.35 })
  m:each(function(x, y) local k = K(x, y)
    local i = idx[k]
    -- rays: lines fanning from the root point
    local ang = math.atan(y - root[2], x - root[1])
    if (floor(ang * rays) % 2) == 0 then i = max(1, i - 1) end
    -- darker at the root (AO where it meets the body)
    local near = bm:has(x + 1, y) or bm:has(x - 1, y) or bm:has(x, y + 1) or bm:has(x, y - 1)
    if near then i = 1 end
    c:put(x, y, ramp[i], tok)
  end)
  if lead then lead(m) end
end
shadeFin(dorsal, TAIL, ftok, 7, { 33, 28 }, function(m)
  m:edge():each(function(x, y) if x <= 30 and y < 26 and not bm:has(x, y + 1) then c:put(x, y, TAIL[5], ftok) end end) end)
shadeFin(adip, TAIL, ftok, 3, { 45, 30 })
local function creamLead(m, xmax)
  m:edge():each(function(x, y) if x <= xmax(y) then c:put(x, y, EDGE, ftok) end end)
end
shadeFin(pelvic, FIN, ftok, 6, { 33, 36 }, function(m) creamLead(m, function(y) return 30 + (y - 37.5) * 0.58 + 0.9 end) end)
shadeFin(anal, FIN, ftok, 6, { 42, 35 }, function(m) creamLead(m, function(y) return 39 + (y - 36.4) * 0.66 + 0.9 end) end)
shadeFin(tail, TAIL, ttok, 9, { 46, 33.5 })
-- tail tips darker, fork notch AO
tail:each(function(x, y) if x >= 55 then c:put(x, y, TAIL[2], ttok) end end)
c:put(54, 33, TAIL[1], ttok) c:put(54, 34, TAIL[1], ttok)

-- body tone: zone by side offset (S<0 = back), light from normals
local btok = { r = { name = "body" } }
local v = X.light(bn, { amb = 0.08, wrap = 0.32 })
local bias = {}
local gill = function(y) return 17.2 + 0.03 * (y - 32) ^ 2 end      -- gill-cover arc x per row
bm:each(function(x, y) local k = K(x, y)
  -- AO behind the gill cover
  local gx = gill(y)
  if x > gx and x <= gx + 1.2 and BS[k] > -0.85 then bias[k] = -1 end
end)
local CUT = { 0.18, 0.34, 0.5, 0.66, 0.84 }
local zone = {}
bm:each(function(x, y) local k = K(x, y)
  local s, t = BS[k], BT[k]
  local i = 1
  for j, q in ipairs(CUT) do if v[k] >= q then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  local wob = 0.06 * sin(t * 30)
  local z = (s < -0.22 + wob) and BACK or ((s < 0.34 + wob * 0.5 or t < 0.1) and FLANK or BELLY)
  if z == BELLY then i = min(6, i + 1) end
  if z == BACK then i = max(1, i - 1) end
  zone[k] = z
  c:put(x, y, z[i], btok)
end)
-- scale lattice: faint 1-tone-darker diagonal dots on back + flank
bm:shrink(1):each(function(x, y) local k = K(x, y)
  if BT[k] > 0.24 and BT[k] < 0.92 and ((x + 2 * y) % 5 == 0) and (y % 2 == 0) and zone[k] ~= BELLY then
    local z = zone[k]
    for i = 6, 1, -1 do if c:get(x, y) == z[i] then c:put(x, y, z[max(1, i - 1)], btok) break end end
  end
end)
-- lateral line
for i = 0, 60 do local t = 0.22 + i / 60 * 0.7
  local x, y = A.bez(pts, t) x, y = floor(x + 0.5), floor(y - hw(t) * 0.05 + 0.5)
  if bm:has(x, y) then c:put(x, y, FLANK[5], btok) end
end
-- pale pink spots on flank and lower back (each with a darker lower-right pixel)
for _, p in ipairs{ { 23, 29 }, { 27, 33 }, { 30, 28 }, { 34, 31 }, { 37, 28 }, { 39, 33 }, { 42, 30 }, { 25, 26 }, { 33, 26 }, { 45, 32 }, { 31, 35 } } do
  if bm:has(p[1], p[2]) and bm:has(p[1] + 1, p[2] + 1) then
    c:put(p[1], p[2], SPOT, btok)
    if (p[1] + p[2]) % 2 == 0 then c:put(p[1] + 1, p[2], SPOT, btok) end
    c:put(p[1] + 1, p[2] + 1, SPOT2, btok)
  end
end
-- cool bounce along the belly edge
bm:edge():each(function(x, y) local k = K(x, y) if BS[k] > 0.8 and BT[k] > 0.16 and BT[k] < 0.75 then c:put(x, y, BOUNCE, btok) end end)

-- head: gill-cover arc, mouth, eye, wet specular
for y = 27, 38 do local x = floor(gill(y) + 0.5)
  if bm:has(x, y) then c:put(x, y, zone[K(x, y)] == BELLY and BELLY[2] or FLANK[1], btok) end
  if bm:has(x - 1, y) and y > 28 and y < 37 then c:put(x - 1, y, FLANK[5], btok) end
end
A.ln(c, 9, 35, 13, 35, BACK[1], btok)   -- mouth line
c:put(14, 34, BACK[2], btok)
A.map(c, { ".gg.", "gppg", "gpcg", ".gg." }, 12, 30, { g = "#d8a83a", p = "#2b1c26", c = CREAM }, btok)
c:put(13, 31, CREAM, btok)
c:put(16, 29, CREAM, btok) c:put(17, 29, CREAM, btok)            -- wet glint on the head
c:put(11, 32, FLANK[6], btok)

-- pectoral fin over the body, behind the gill cover
local pect = finPoly{ { 19, 35.4 }, { 21.5, 40.6 }, { 25, 40.4 }, { 23.4, 35.2 } }
local pn = X.pillow(pect, 1.4)
local pidx = A.toneN(c, pect, pn, FIN, { tok = ftok, cuts = { 0.24, 0.44, 0.62, 0.8 }, amb = 0.2, wrap = 0.35 })
pect:each(function(x, y) if (x + y) % 2 == 0 and x > 20 then c:put(x, y, FIN[max(1, pidx[K(x, y)] - 1)], ftok) end end)
pect:edge():each(function(x, y) if x <= 19 + (y - 35.4) * 0.48 + 1 then c:put(x, y, EDGE, ftok) end end)
-- contact shadow under the pectoral on the body
pect:shift(1, 1):each(function(x, y) if bm:has(x, y) and not pect:has(x, y) then c:put(x, y, BELLY[1], btok) end end)

-- quirk: a snowflake caught on the dorsal fin tip
local qtok = { r = { name = "snow" } }
A.map(c, {
  "..a..",
  ".bab.",
  "aacaa",
  ".bab.",
  "..a..",
}, 31, 15, { a = "#e4f6ff", b = "#8bc4ea", c = CREAM }, qtok)

A.save(c, NAME)
