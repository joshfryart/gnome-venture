-- ico-dragon (final pass, Opus single pass). Bold icon: a jade dragon's head and neck in profile, facing right. Long
-- slim snout with a flared nostril, heavy brow over a small glinting eye, a lower jaw parted by a dark mouth line and
-- two ivory fangs, swept-back ringed horns, a red ribbed ear frill and spines down the neck. Per-pixel light on tube /
-- ellipsoid fields, 6-tone jade with cool teal depth; scale scallops on the neck, cream belly plates with grooves,
-- AO and seams where head, jaw, frill and neck meet, cool bounce under the jaw.
-- quirk: a little daisy is tucked behind its horn.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA3_5.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-dragon")
local G   = { "#122a3a", "#17473f", "#1f6e4a", "#349654", "#62bd5c", "#ade27a" }
local GF  = { "#10222f", "#143a38", "#1a5644", "#277a4c", "#45a052" }
local BONE = { "#4e3236", "#80584a", "#b08a66", "#d8bc88", "#f0deac", "#fff4d6" }
local FR  = { "#4a1a32", "#86283a", "#c4423a", "#ec7046", "#ffa868" }
local BEL = { "#6a4a3e", "#a8805a", "#d4ae76", "#eed29a", "#fbeac0" }
local tk = function(n) return { r = { name = n } } end
local CC = { 0.2, 0.36, 0.52, 0.68, 0.86 }
local function seam(m, o, hex) m:each(function(x, y)
  if (o:has(x - 1, y) or o:has(x + 1, y) or o:has(x, y - 1) or o:has(x, y + 1)) and not o:has(x, y) then c:put(x, y, hex) end end) end

-- far horn (behind, a tone darker)
local fh, fhn, fhT = T.tube({ { 27, 18 }, { 25, 12 }, { 21, 8 }, { 15, 6 } }, function(t) return 2.6 - 2.0 * t end)
T.shade(c, fh, fhn, { BONE[1], BONE[2], BONE[3], BONE[4], BONE[5] }, { amb = 0.05, wrap = 0.2, tok = tk("fhorn"), cuts = { 0.22, 0.4, 0.6, 0.8 } })

-- ear frill: membrane fan with ribs radiating from its root
local frill = c:poly{ { 18, 23 }, { 9, 16 }, { 11, 21 }, { 5, 24 }, { 9, 28 }, { 5, 33 }, { 11, 33 }, { 9, 38 }, { 19, 32 } }
local frn = X.pillow(frill, 2)
local fidx = T.shade(c, frill, frn, FR, { amb = 0.1, wrap = 0.25, tok = tk("frill"), cuts = { 0.22, 0.42, 0.62, 0.82 } })
for _, tip in ipairs{ { 9, 16 }, { 5, 24 }, { 5, 33 }, { 9, 38 } } do
  T.ln(c, 18, 28, tip[1], tip[2], FR[1], frill, tk("frill"))
  T.ln(c, 18, 27, tip[1] + 1, tip[2], FR[5], frill, tk("frill"))
end

-- neck: S-curve down-left, cut flat at the bottom like a bust
local nk, nkn, nkT, nkS = T.tube({ { 26, 30 }, { 22, 38 }, { 15, 45 }, { 16, 57 } }, function(t) return 6.8 + 1.4 * t end)
nk:cut(c:rect(0, 56, 63, 63))
-- dorsal spines down the back of the neck (painted first, neck covers their roots)
for _, s in ipairs{ { 16, 36, -1 }, { 11, 42, -1 }, { 8, 49, -1 } } do
  local sp = c:poly{ { s[1] + 2, s[2] - 3 }, { s[1] - 4, s[2] }, { s[1] + 2, s[2] + 3 } }
  T.shade(c, sp, X.pillow(sp, 1), FR, { amb = 0.1, wrap = 0.3, tok = tk("spine"), cuts = { 0.22, 0.42, 0.62, 0.82 } })
end
local nb = {}
local nidx = T.shade(c, nk, nkn, G, { amb = 0.05, wrap = 0.2, bias = nb, tok = tk("neck"), cuts = CC })
-- belly plates on the front of the neck (s > 0.35), grooves across
local plates = HP.mask()
nk:each(function(x, y) if nkS[K(x, y)] > 0.3 then plates:set(x, y) end end)
local pidx = T.shade(c, plates, nkn, BEL, { amb = 0.2, wrap = 0.3, tok = tk("plates"), cuts = { 0.15, 0.3, 0.5, 0.72 } })
plates:each(function(x, y) local t = nkT[K(x, y)] if floor(t * 60) % 6 == 0 then c:put(x, y, BEL[1]) end end)
seam(nk:copy():cut(plates), plates, G[2])
-- scale scallops on the neck: staggered 4x3 cells, darker lower rim of each scale
nk:each(function(x, y) local k = K(x, y)
  if plates:has(x, y) then return end
  local row = y // 3
  local cx = (x + (row % 2) * 2) % 4
  local i = nidx[k] or 1
  if (y % 3 == 2) and cx ~= 0 and i >= 3 then T.step(c, nidx, G, x, y, -1, tk("neck")) end
end)

-- lower jaw (under the snout)
local jw, jwn = T.tube({ { 27, 34 }, { 34, 37 }, { 41, 38 }, { 47, 36 } }, function(t) return 3.4 - 1.3 * t end)
local jb = {}
X.ao(jb, jw, nk, 1, -1)
T.shade(c, jw, jwn, G, { amb = 0.03, wrap = 0.15, bias = jb, tok = tk("jaw"), cuts = CC })
local jrim = X.rim(jwn)
jw:edge():each(function(x, y) if jrim[K(x, y)] > 0.6 and x > 30 and not jw:has(x, y + 1) then c:put(x, y, "#2e5a7a") end end)
-- chin plate
for x = 30, 44 do for y = 36, 41 do if jw:has(x, y) and not jw:has(x, y + 1) then c:put(x, y - 1, BEL[3]) c:put(x, y, BEL[2]) end end end

-- cranium + snout
local cr, crn = T.oval(27, 25, 9.6, 8, 0.1)
local sn, snn, snT, snS = T.tube({ { 31, 26 }, { 38, 27 }, { 45, 28.5 }, { 51, 30.5 } }, function(t) return 5.8 - 2.2 * t end)
local tipm, tipn = T.oval(50, 30, 3.4, 3.2, 0.2)
local hm = cr:copy():add(sn):add(tipm)
local hn = {}
for k, v in pairs(snn) do hn[k] = v end
for k, v in pairs(tipn) do hn[k] = v end
for k, v in pairs(crn) do hn[k] = v end
hn = T.blend(hn, X.pillow(hm, 3), 0.45)
local hb = {}
X.ao(hb, hm, jw, 1, -1)
local hidx = T.shade(c, hm, hn, G, { amb = 0.05, wrap = 0.2, bias = hb, tok = tk("head"), cuts = CC })
seam(hm, nk, G[2])
-- mouth line: dark gap along the snout's lower edge over the jaw, curling up at the corner
hm:each(function(x, y) if jw:has(x, y + 1) and not jw:has(x, y) and x > 29 then c:put(x, y, G[1]) end end)
c:put(29, 33, G[1]) c:put(28, 32, G[1])
-- ridge scutes along the top of the snout
for _, x in ipairs{ 38, 42, 46 } do local y
  for yy = 15, 35 do if hm:has(x, yy) then y = yy break end end
  if y then c:put(x, y + 1, G[6]) c:put(x + 1, y + 1, G[5]) c:put(x, y + 2, G[4]) end
end
-- nostril: flared ridge + dark hole
T.map(c, { ".hh.", "hkkd", ".dd." }, 48, 26, { h = G[6], k = T.INK, d = G[2] }, tk("head"))
-- brow ridge + eye
local brow = T.rell(34, 20.8, 0.95, 0.3, 4.4, 1.8)
T.shade(c, brow, X.pillow(brow, 1.5), G, { amb = 0.15, wrap = 0.3, tok = tk("brow"), cuts = CC })
local below = HP.mask() brow:each(function(x, y) if not brow:has(x, y + 1) then below:set(x, y + 1) end end)
below:each(function(x, y) if hm:has(x, y) then c:put(x, y, G[2]) end end)
-- eye: gold iris with an ink slit pupil and a cream glint, lid shadow above
T.map(c, {
  "dddd",
  "gcKg",
  "ggKo",
  ".oo.",
}, 33, 21, { d = G[1], g = "#f5c232", o = "#d98322", K = T.INK, c = T.CREAM }, tk("eye"))
-- glossy snout specular
c:put(37, 24, G[6]) c:put(38, 24, G[6]) c:put(37, 23, T.CREAM)
-- fangs over the jaw
T.map(c, { "ab", "ab", "a." }, 42, 33, { a = BONE[6], b = BONE[4] }, tk("fang"))
T.map(c, { "ab", "a." }, 37, 33, { a = BONE[6], b = BONE[4] }, tk("fang"))

-- near horn: swept back, ring grooves
local hh, hhn, hhT, hhS = T.tube({ { 24, 19 }, { 19, 14 }, { 13, 11 }, { 5, 10 } }, function(t) return 3.2 - 2.5 * t end)
local hhidx = T.shade(c, hh, hhn, BONE, { amb = 0.08, wrap = 0.25, tok = tk("horn"), cuts = CC })
hh:each(function(x, y) local t = hhT[K(x, y)]
  for _, r in ipairs{ 0.18, 0.36, 0.54 } do if abs(t - r) < 0.02 then T.step(c, hhidx, BONE, x, y, -2, tk("horn")) end end end)
seam(hm, hh, G[2])
c:put(15, 11, BONE[6]) c:put(16, 11, BONE[6])

-- quirk: a daisy tucked behind the horn base
T.map(c, {
  ".p.p.",
  "ppppp",
  ".pyp.",
  "ppppd",
  ".d.d.",
}, 30, 14, { p = "#fff4d6", y = "#f5b82e", d = "#c4c0d0" }, tk("daisy"))
c:put(32, 16, "#d98322")
T.save(c, "ico-dragon", "ico")
