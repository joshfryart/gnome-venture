-- mulberry (final, Opus single pass). One slim, elongated black-purple mulberry hanging on a short green
-- peduncle, built from ~30 glossy drupelets (each its own sphere blended with the body cylinder, AO where they
-- nest, a lilac glint each, cool bounce on the shade side), plus one heart-shaped serrated mulberry leaf with
-- midrib and veins behind it. quirk: a tiny cream silkworm is munching the leaf tip.
local NAME = "mulberry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#225a40", "#2f7848", "#47974e", "#6cb656", "#9fd26e" }
local BER = { "#1c0f2c", "#2f173d", "#4a2156", "#6a2f72", "#8f4892", "#b77ab6" }
local GLINT, BOUNCE = "#e9cdea", "#5d5aa0"
local STEM = { "#3d5a34", "#5f8a45", "#8cb65e", "#c0dc8a" }
local WORM = { "#8a7a6e", "#c6b59a", "#e9dcc0", "#fff4d6" }

-- leaf (behind): heart base at the peduncle, acuminate tip down-right
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS, llen = A.leaf(38, 14, 50, 8, 59, 17, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 7.0 * sin(pi * min(1, 0.2 + t * 0.85)) ^ 0.7 * (1 - 0.3 * t))
end, { per = 3.3, depth = 0.2, fold = 0.32 })
-- cordate notch at the base
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.07 and abs(LS[k]) < 0.35 then lm.s[k] = nil end end)

-- berry geometry: axis from top T0 to bottom T1, half width profile
local T0x, T0y, T1x, T1y = 35, 22, 28, 53
local ax, ay = T1x - T0x, T1y - T0y
local alen = sqrt(ax * ax + ay * ay) ax, ay = ax / alen, ay / alen
local px, py = -ay, ax if px + py < 0 then px, py = -px, -py end
local function hw(t) return 1.2 + 6.4 * sin(pi * min(1, 0.12 + t * 0.86)) ^ 0.55 end
local body = HP.mask()
local drupes = {}
local rows = 9
for i = 0, rows - 1 do
  local t = i / (rows - 1)
  local w = hw(t)
  local off = (i % 2 == 0) and 0 or 1.85
  for j = -3, 3 do
    local s = j * 3.7 + off
    if abs(s) <= w - 1.2 then
      local cx = T0x + ax * (t * alen) + px * s
      local cy = T0y + ay * (t * alen) + py * s
      local r = 2.25 - 0.35 * (abs(s) / (w + 0.1)) - (t > 0.9 and 0.4 or 0)
      drupes[#drupes + 1] = { cx, cy, r, s / (w + 1), t }
    end
  end
end
-- body-light field (cylinder across the axis) for blending
for _, d in ipairs(drupes) do
  for y = floor(d[2] - 3), floor(d[2] + 3) do for x = floor(d[1] - 3), floor(d[1] + 3) do
    if (x - d[1]) ^ 2 + (y - d[2]) ^ 2 <= (d[3] + 0.3) ^ 2 then body:set(x, y) end end end
end
local bodyV = {}
do
  local nn = {}
  body:each(function(x, y)
    local rx, ry = x - T0x, y - T0y
    local t = max(0, min(1, (rx * ax + ry * ay) / alen))
    local s = (rx * px + ry * py) / (hw(t) + 1.5)
    s = max(-0.95, min(0.95, s))
    local along = (t - 0.5) * 0.5
    nn[K(x, y)] = { px * s + ax * along, py * s + ay * along, sqrt(1 - s * s) }
  end)
  bodyV = X.light(nn, { amb = 0.04, wrap = 0.15 })
end

-- leaf shading: AO + contact shadow where the berry and stem sit over it
local lbias = {}
X.ao(lbias, lm, body, 1, -1) A.cast(lbias, lm, body, 1, 2, -1)
A.toneN(c, lm, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
A.veins(c, lm, LT, LS, llen, LEAF, ltok, { per = 5.2, skip = lbias, rib = "#c4e490" })
-- quirk: munched notch at the leaf tip edge + silkworm
for _, q in ipairs{ { 58, 19 }, { 58, 20 }, { 57, 20 }, { 59, 19 } } do lm.s[K(q[1], q[2])] = nil c.pix[q[2] * 64 + q[1]] = nil c.own[q[2] * 64 + q[1]] = nil end
local wtok = { r = { name = "worm" } }
local wseg = { { 54.5, 17.0, 1.25 }, { 52.8, 15.8, 1.35 }, { 51.0, 15.2, 1.35 }, { 49.2, 15.1, 1.2 }, { 47.6, 15.4, 1.0 } }
local wm = HP.mask()
for _, s in ipairs(wseg) do
  for y = floor(s[2] - 2), floor(s[2] + 2) do for x = floor(s[1] - 2), floor(s[1] + 2) do
    if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 <= (s[3] + 0.35) ^ 2 then wm:set(x, y) end end end
end
-- leaf shadow under the worm
wm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not wm:has(x, y) then c:put(x, y, LEAF[2], ltok) end end)
local wn = X.pillow(wm, 1.5)
X.tone(c, wm, X.light(wn, { amb = 0.2, wrap = 0.3 }), WORM, { cuts = { 0.35, 0.6, 0.82 }, tok = wtok })
-- segment creases
for _, q in ipairs{ { 52, 16 }, { 50, 15 }, { 53, 16 } } do if wm:has(q[1], q[2]) then c:put(q[1], q[2], WORM[2], wtok) end end
-- head at the munched tip: ink eye
c:put(55, 17, WORM[3], wtok) c:put(55, 16, A.INK, wtok)

-- peduncle: berry top up to the twig node, leaf petiole joins
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 35, 23 }, { 35, 18 }, { 36, 14 }, { 38, 11 } }, function(t) return 1.25 - 0.25 * t end)
sm:cut(body)
X.ao(lbias, lm, sm, 1, -1)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- petiole into the leaf base
A.line(c, { { 37, 13 }, { 39, 15 } }, STEM[2], stok)
-- cut twig end (pale scar)
c:put(38, 10, STEM[4], stok) c:put(39, 10, STEM[3], stok)
-- calyx: four tiny sepals hugging the top drupelets
for _, q in ipairs{ { 33, 22, 2 }, { 34, 21, 3 }, { 36, 21, 3 }, { 37, 22, 1 } } do c:put(q[1], q[2], STEM[q[3]], stok) end

-- drupelets: back (edge) first, front (centre) last; top rows first
table.sort(drupes, function(a, b)
  local da, db = abs(a[4]), abs(b[4])
  if abs(da - db) > 0.15 then return da > db end
  return a[5] < b[5]
end)
local done = HP.mask()
local bestG, bgx, bgy = -1
for i, d in ipairs(drupes) do
  local tok = { r = { name = "drupe" .. i } }
  local bias = {}
  local m = HP.mask()
  for y = floor(d[2] - 3), floor(d[2] + 3) do for x = floor(d[1] - 3), floor(d[1] + 3) do
    if (x - d[1]) ^ 2 + (y - d[2]) ^ 2 <= (d[3] + 0.3) ^ 2 then m:set(x, y) end end end
  local _, idx, n = A.ball(c, d[1], d[2], d[3], BER, { body = bodyV, mix = 0.5, tok = tok, cuts = { 0.14, 0.28, 0.44, 0.62, 0.82 } })
  -- crease: shade-side rim pixel row toward lower-right that touches other drupes
  m:edge():each(function(x, y)
    local dx, dy = x - d[1], y - d[2]
    if dx + dy > 0.8 * d[3] then c:put(x, y, BER[(idx[K(x, y)] or 3) <= 3 and 1 or 2], tok) end
  end)
  -- cool bounce on the far shade side of the whole berry
  if d[4] > 0.45 then
    local bx, by = floor(d[1] + d[3] * 0.6 + .5), floor(d[2] + d[3] * 0.2 + .5)
    if m:has(bx, by) then c:put(bx, by, BOUNCE, tok) end
  end
  -- glint per drupelet, lit side
  local gx, gy = floor(d[1] - 0.9 + .5), floor(d[2] - 0.9 + .5)
  local bv = bodyV[K(gx, gy)] or 0
  if bv > 0.42 and m:has(gx, gy) then c:put(gx, gy, BER[6], tok)
    if bv > bestG then bestG, bgx, bgy = bv, gx, gy end end
  done:add(m)
end
-- one big cream glint on the brightest drupelet + 1 lilac sparkle
if bgx then c:put(bgx, bgy, A.CREAM) c:put(bgx + 1, bgy, GLINT) c:put(bgx, bgy + 1, GLINT) end

A.save2(c, NAME)
