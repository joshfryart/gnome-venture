-- ico-circus-tent (final pass, Opus). A tall big-top: steep striped cone roof over a narrower striped drum,
-- scalloped valance with one gold hem stitch, an open door with tied-back flaps, pole and pennant on top.
-- Material: per-pixel cone and cylinder light, each stripe on its own 6-tone ramp (red / cream canvas), soft
-- vertical cloth folds, a lit seam where the roof meets the valance, AO under the overhang, dark interior.
-- Stands on a 2-tone ground shadow.
-- quirk: a little mouse peeks out of the doorway.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, asin, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.asin, math.pi
local c = A.new("ico-circus-tent")
local RED = { "#5a1a32", "#8c2238", "#bd2e37", "#e2473a", "#fa7452", "#ffa77a" }
local CRM = { "#5d4660", "#8f7584", "#c2a8a4", "#e6d2b8", "#f8e8c8", "#fff4d6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local tok = A.tok("tent")
local CX = 32

c:groundShadow(CX, 54, 18, 2)

-- angular stripe index from u in -1..1 (front view of a round body)
local NS = 9
local function stripe(u) return floor((asin(max(-1, min(1, u))) + pi / 2) / pi * NS) % 2 end

-- drum (walls): vertical cylinder, top hidden under the valance
local D0, D1, DW = 30, 52, 13.5
local dm, dn, du = HP.mask(), {}, {}
for y = D0, D1 + 2 do
  for x = CX - 16, CX + 16 do
    local u = (x - CX + 0.5) / (DW + 0.5)
    local bottom = D1 + 1.8 * sqrt(max(0, 1 - u * u))
    if abs(u) <= 1 and y <= bottom then
      local k = K(x, y)
      dm:set(x, y) du[k] = u
      dn[k] = { A.norm(u, 0.05, sqrt(max(0.03, 1 - u * u))) }
    end
  end
end
local v = X.light(dn, { amb = 0.05, wrap = 0.2 })
local cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 }
local function ti(val) local i = 1 for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end return i end
dm:each(function(x, y)
  local k = K(x, y)
  local i = ti(v[k])
  -- cloth folds: a darker step at every stripe border and a soft mid-stripe fold
  local s = stripe(du[k])
  if stripe(du[k] - 0.07) ~= s then i = i - 1 end
  if y <= D0 + 3 then i = i - 2 elseif y <= D0 + 5 then i = i - 1 end       -- AO under the overhang
  i = max(1, min(6, i))
  c:put(x, y, (s == 0 and RED or CRM)[i], tok)
end)

-- door: dark interior triangle with tied-back flaps
local door = c:poly{ { CX, 37 }, { CX - 6, 54 }, { CX + 6, 54 } }
door:clip(dm)
door:each(function(x, y) c:put(x, y, y < 41 and "#35295f" or (y < 47 and "#2f2350" or "#3a2a5c"), tok) end)
local fl = c:poly{ { CX, 36 }, { CX - 6, 54 }, { CX - 9, 54 }, { CX - 2, 37 } }
local fr = c:poly{ { CX, 36 }, { CX + 6, 54 }, { CX + 9, 54 }, { CX + 2, 37 } }
fl:clip(dm) fr:clip(dm)
fl:each(function(x, y) local e = not fl:has(x + 1, y) c:put(x, y, e and CRM[6] or CRM[4], tok) end)
fr:each(function(x, y) local e = not fr:has(x - 1, y) c:put(x, y, e and CRM[4] or CRM[3], tok) end)
-- gold tie-backs
for _, q in ipairs{ { CX - 6, 46 }, { CX - 5, 46 }, { CX - 7, 47 } } do c:put(q[1], q[2], GOLD[3], tok) end
for _, q in ipairs{ { CX + 5, 46 }, { CX + 6, 46 }, { CX + 7, 47 } } do c:put(q[1], q[2], GOLD[2], tok) end

-- quirk: a mouse peeking around the right flap at the bottom of the doorway
A.map(c, {
  ".pP...",
  "gGGg..",
  "GwkGg.",
  "GGGGgn",
  ".ggg..",
}, CX + 0, 48, { p = "#f5809f", P = "#c94f84", G = "#aaa9b8", g = "#74758c", w = "#e2e0e6", k = "#2b1c26", n = "#f5809f" }, tok)

-- roof: steep cone, apex at top, base ellipse over the valance
local AP, RB, RW, RT = 11, 29, 18, 3.0
local rm, rn, ru = HP.mask(), {}, {}
for y = AP, RB + 4 do
  for x = CX - 20, CX + 20 do
    -- solve for height h along the cone accounting for the base tilt (front of base hangs lower)
    local h, u = y, 0
    for _ = 1, 5 do
      local w = RW * (min(max(h, AP), RB) - AP) / (RB - AP)
      u = (x - CX + 0.5) / (w + 0.5)
      h = y - RT * sqrt(max(0, 1 - u * u)) * (h - AP) / (RB - AP)
    end
    if abs(u) <= 1 and h >= AP and h <= RB then
      local k = K(x, y)
      rm:set(x, y) ru[k] = { u = u, h = h }
      local slope = RW / (RB - AP)
      rn[k] = { A.norm(u * 1.15, -0.28 * slope, sqrt(max(0.03, 1 - u * u))) }
    end
  end
end
local rv = X.light(rn, { amb = 0.02, wrap = 0.1 })
for k, val in pairs(rv) do rv[k] = val - 0.06 end
rm:each(function(x, y)
  local k = K(x, y)
  local i = ti(rv[k])
  local s = stripe(ru[k].u)
  if stripe(ru[k].u - 0.08) ~= s then i = i - 1 end
  if ru[k].h < AP + 3 then i = i - 1 end
  i = max(1, min(6, i))
  c:put(x, y, (s == 0 and RED or CRM)[i], tok)
end)
-- lit seam lines along the lit roof panel ridges (a hi pixel just left of each border, upper part)
rm:each(function(x, y)
  local k = K(x, y)
  local u = ru[k].u
  if u < -0.3 and stripe(u) ~= stripe(u + 0.06) and ru[k].h > AP + 4 and ru[k].h < RB - 3 then
    c:put(x, y, (stripe(u) == 0 and RED or CRM)[6], tok)
  end
end)

-- valance: scalloped band hanging from the roof edge, alternating red / cream scallops
local VY = RB + 1
local vm = HP.mask()
local NSc = 7
local sw = (2 * RW + 1) / NSc
for i = 0, NSc - 1 do
  local x0 = CX - RW + i * sw
  local xm = x0 + sw / 2
  local lift = RT * sqrt(max(0, 1 - ((xm - CX) / (RW + 0.5)) ^ 2))
  local sc = A.ell(xm - 0.5, VY + lift + 0.5, sw / 2 - 0.2, 2.6)
  sc:each(function(x, y) if y >= VY + lift - 1 then vm:set(x, y) end end)
  sc:each(function(x, y) if y >= VY + lift - 1 then
    local dx = (x + 0.5 - xm) / (sw / 2)
    local R = (i % 2 == 0) and RED or CRM
    local t = 4
    if dx > 0.35 then t = 3 end
    if y >= VY + lift + 2 then t = t - 1 end
    if dx < -0.2 and y <= VY + lift then t = 5 end
    c:put(x, y, R[t], tok)
  end end)
end
-- roof edge seam: dark row where valance meets roof, then the gold hem stitch on the valance top
for x = CX - RW, CX + RW do
  local u = (x - CX + 0.5) / (RW + 0.5)
  local lift = RT * sqrt(max(0, 1 - u * u))
  local y = floor(VY + lift - 1 + 0.5)
  if (x - (CX - RW)) % 3 ~= 2 and abs(u) < 0.92 then c:put(x, y, GOLD[3], tok) end
end

-- pole, finial and pennant
for y = 5, AP + 1 do c:put(CX, y, "#864c33", tok) c:put(CX - 1, y, "#b97a4a", tok) end
c:put(CX - 1, 4, GOLD[4], tok) c:put(CX, 4, GOLD[3], tok)
A.map(c, {
  "hbbbb.",
  "bbbbbs",
  "bbbs..",
}, CX + 1, 5, { h = GOLD[4], b = GOLD[3], s = GOLD[2] }, tok)
A.save(c, "ico-circus-tent")
