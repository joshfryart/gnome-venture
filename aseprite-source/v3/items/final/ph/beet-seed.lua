-- beet-seed (final pass, Opus). Three real beet "seeds" (corky seed balls: knobbly clusters of fused fruits) on a
-- torn scrap of beet leaf. Seed balls: height field from fused knobs, lit per pixel on a 6-tone cork ramp, dark
-- crevices between knobs, pitted speckle, one lit knob top each, AO + contact shadow on the leaf. Leaf scrap:
-- V-fold light, red midrib and red angled veins (beet leaf cue), ragged torn end, cool reflected edge. The right
-- seed ball has germinated: magenta-red stem (beet seedlings are red), two long strap cotyledons with red
-- midribs, and a first true leaf (glossy spade blade, red midrib) that shows the beet top.
-- quirk: a single dewdrop sits on the leaf scrap (bright rim, pale core, one glint).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local norm = A.norm
local NAME = "beet-seed"
local c = A.new(NAME)
local LF, RB, CK = A.LEAF, A.RIB, A.CORK
local COOL = "#3a6c72"
local STEM = { "#5e1538", "#9a2654", "#cf4a78", "#f088a8" }

-- seed ball: fused knobs -> mask, normals, height, crevice flag
local function seedball(cx, cy, knobs)
  local m, h = HP.mask(), {}
  for y = floor(cy) - 7, floor(cy) + 7 do for x = floor(cx) - 7, floor(cx) + 7 do
    local best, second = -1, -1
    for _, kb in ipairs(knobs) do
      local d2 = (x - cx - kb[1])^2 + (y - cy - kb[2])^2
      local r = kb[3]
      if d2 <= (r + 0.45)^2 then
        local v = sqrt(max(0, (r + 0.45)^2 - d2))
        if v > best then second = best best = v elseif v > second then second = v end
      end
    end
    if best >= 0 then m:set(x, y) h[K(x, y)] = { best, second } end
  end end
  local n, crev = {}, {}
  local function H(x, y) local q = h[K(x, y)] return q and q[1] or 0 end
  m:each(function(x, y)
    local gx = (H(x + 1, y) - H(x - 1, y)) / 2
    local gy = (H(x, y + 1) - H(x, y - 1)) / 2
    n[K(x, y)] = { norm(-gx * 0.9, -gy * 0.9, 1) }
    local q = h[K(x, y)]
    if q[2] >= 0 and abs(q[1] - q[2]) < 0.7 then crev[K(x, y)] = true end
  end)
  return m, n, crev
end
local SB = {
  { 17, 46, { { 0, 0, 2.4 }, { -2.6, 1.0, 1.8 }, { 2.3, 1.4, 1.9 }, { 0.6, -2.4, 1.7 }, { -1.6, -1.8, 1.4 } } },
  { 28, 44, { { 0, 0, 2.3 }, { 2.4, -1.0, 1.9 }, { -2.2, 0.8, 1.8 }, { 0.4, 2.4, 1.6 }, { 1.2, -2.6, 1.3 } } },
  { 39, 39, { { 0, 0, 2.5 }, { -2.5, 1.2, 1.7 }, { 2.4, 1.0, 1.8 }, { -0.4, 2.6, 1.6 }, { 1.8, -2.0, 1.4 } } },
}
for _, s in ipairs(SB) do s.m, s.n, s.crev = seedball(s[1], s[2], s[3]) end

-- leaf scrap: blade on a shallow diagonal, ragged torn end on the right, small petiole stub on the left
local lm, ln, LT, LS = A.blade(8, 53, 28, 49, 53, 41, function(t)
  local u = min(1, t * 0.9 + 0.1)
  return max(0.6, 8.6 * sin(pi * min(1, u * 0.8 + 0.06)) ^ 0.6)
end, { fold = 0.24 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if t > 0.82 + 0.06 * X.hash(floor(s * 4 + 4), 2, 7) - 0.05 * abs(s) then torn[#torn + 1] = k end   -- jagged tear
  if abs(s) > 0.84 and X.hash(floor(x / 2), floor(y / 2), 4) > 0.7 and t > 0.12 then torn[#torn + 1] = k end              -- nibbled margin
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(SB) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
-- dewdrop footprint (cast shadow lower-right)
local DX, DY = 22, 52
local idx = A.tone(c, lm, ln, LF, { bias = bias, amb = 0.12, wrap = 0.3, cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.86 then c:put(x, y, s <= 0 and RB[3] or RB[2]) return end
  for _, vt in ipairs{ 0.2, 0.42, 0.64 } do
    local d = (t - vt) * 48 - abs(s) * 5.5
    if d > -0.5 and d < 0.5 and abs(s) > 0.16 and abs(s) < 0.66 then c:put(x, y, s < 0 and RB[4] or RB[2]) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.8 and LT[k] > 0.08 and LT[k] < 0.8 then c:put(x, y, COOL) end
  if LT[k] > 0.79 and idx[k] and idx[k] >= 3 then c:put(x, y, LF[2]) end   -- torn edge reads as a darker cut
end)
for _, q in ipairs{ { 7, 54, RB[3] }, { 6, 55, RB[2] }, { 5, 56, RB[2] } } do c:put(q[1], q[2], q[3]) end

-- sprout (before the seeds so the seed ball overlaps the stem foot)
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 39, 37 }, { 37, 31 }, { 38, 26 }, { 37, 21 } }, function(t) return 1.05 end)
sm:cut(SB[3].m)
A.tone(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local function strap(ax, ay, qx, qy, bx, by, w)
  local len = sqrt((qx - ax)^2 + (qy - ay)^2) + sqrt((bx - qx)^2 + (by - qy)^2)
  local m, n, T, S = A.blade(ax, ay, qx, qy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  A.tone(c, m, n, LF, { amb = 0.14, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and RB[4] or RB[3]) end end)
  return m
end
local cl = strap(36, 21, 29, 19, 20, 15, 2.1)
local cr = strap(38, 21, 45, 18, 54, 15, 2.1)
-- first true leaf: short red petiole + glossy spade blade with red midrib
local tm, tn, TT, TS = A.blade(37, 20, 38, 15, 40, 7, function(t)
  if t > 0.985 then return -1 end
  if t < 0.3 then return 0.6 end
  local u = (t - 0.3) / 0.7
  return max(0.6, 3.6 * sin(pi * min(1, u * 0.85 + 0.15)) ^ 0.7)
end, { fold = 0.45 })
tm:cut(cl):cut(cr)
local tidx = A.tone(c, tm, tn, LF, { amb = 0.14, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
tm:each(function(x, y) local k = K(x, y)
  if TT[k] < 0.3 then c:put(x, y, TS[k] <= 0 and STEM[3] or STEM[2])
  elseif abs(TS[k]) < 0.18 and TT[k] < 0.9 then c:put(x, y, TS[k] <= 0 and RB[4] or RB[2]) end
end)
c:put(38, 11, LF[6]) c:put(38, 12, LF[6])      -- gloss on the true leaf

-- seed balls last: per-pixel cork light, crevices, pits, lit knob tops; AO where they touch the stem
for i, s in ipairs(SB) do
  local sb = {}
  s.m:each(function(x, y) local k = K(x, y)
    if s.crev[k] then sb[k] = -2 end
    if not s.m:has(x, y + 1) and not s.m:has(x + 1, y) then sb[k] = (sb[k] or 0) - 1 end
  end)
  local si = A.tone(c, s.m, s.n, CK, { bias = sb, amb = 0.1, wrap = 0.25, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  s.m:each(function(x, y) local k = K(x, y)
    if not s.crev[k] and (si[k] or 0) >= 3 and X.hash(x, y, 13 + i) > 0.84 then A.step(c, si, CK, x, y, -2, 1) end   -- cork pits
  end)
end
-- one glint on the front seed ball's top knob
c:put(16, 43, CK[6]) c:put(17, 43, A.CREAM)

-- quirk: dewdrop on the leaf (3x3 glass bead: dark lower rim, pale core, glint)
c:paint({ ".aa.", "abcc", "accd", ".dd." }, DX, DY - 2, { a = "#e6f8f4", b = "#fffbea", c = "#9fe0d4", d = "#4f9a9e" })
c:put(DX + 2, DY + 2, LF[1]) c:put(DX + 3, DY + 1, LF[1]) c:put(DX + 1, DY + 2, LF[2])

A.save(c, NAME)
