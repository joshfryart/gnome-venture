-- hat-thornblade (final, Opus single pass). Rigid, slim red spire swept back to a needle point (no droop), on a
-- trim brim whose front edge grows a row of curved thorns. Riveted steel band with a small upright blade badge.
-- Material: per-pixel cone light (6-tone stiffened red felt), a lit ridge seam up the spire, faint nap; steel band
-- with bevel rows, rivets and a specular; blade with bright edge + dark fuller; thorns 3-tone woody with lit tips;
-- brim bevel, AO ring and cast shadow.
-- quirk: a single pink rosebud is tucked into the steel band.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new("hat-thornblade")
local RED   = { "#3e1426", "#6a1e2e", "#9a2a30", "#c83c35", "#e8604a", "#ff9a72" }
local STEEL = { "#2c2f45", "#444663", "#64667e", "#8d8ea3", "#b9b8c8", "#e6e4ec" }
local THORN = { "#2a1c1c", "#3e2a24", "#5a3e30", "#7a5840", "#9c7a58", "#cdb08a" }

local CX, BY, RW, RY = 31, 46, 8.5, 2.0
local pts = { { 31, 47 }, { 31, 33 }, { 36, 21 }, { 46, 10 } }
local cm, cn, CT, CS, samp = A.tube(pts, function(t) return 9.0 * (1 - t) ^ 1.05 + 0.45 end)
A.arcClip(cm, CX, BY, RW + 1, RY)

-- brim
local bias = {}
local tmp = HP.mask()
for y = 40, 58 do for x = 8, 56 do
  local u, v = (x - 31) / 19.45, (y - 49) / 4.45
  if u*u + v*v <= 1 then tmp:set(x, y) end end end
X.ao(bias, tmp, cm, 2, -1)
A.cast(bias, tmp, cm, 3, 2, -1)
local top, under, bidx, btok = A.brim(c, 31, 49, 19, 4, 2, RED, { bias = bias })

-- thorns hanging from the brim's front edge, curving outward from centre
local ttok = { r = { name = "thorn" } }
for _, x0 in ipairs{ 16, 22, 28, 34, 40, 46 } do
  local yb = -1
  for y = 40, 60 do if under:has(x0, y) then yb = y end end
  local dir = x0 < 31 and -1 or 1
  local y = yb + 1
  local rows = { { -1, 1 }, { -1, 1 }, { 0, 1 }, { 0, 0 } }
  for i, r in ipairs(rows) do
    local off = (i >= 3) and dir or 0
    if i == 4 then off = dir * 2 end
    for dx = r[1], r[2] do
      local x = x0 + dx + off
      local tone = (dx == r[1]) and 5 or ((dx == r[2] and r[2] > r[1]) and 2 or 3)
      if i == 1 then tone = max(1, tone - 1) end           -- dark where thorn leaves brim
      if i == 4 then tone = 6 end                           -- lit tip
      c:put(x, y + i - 1, THORN[tone], ttok)
    end
  end
end

-- crown
local ctok = { r = { name = "crown" } }
local cidx = A.shade(c, cm, cn, RED, { tok = ctok })
A.felt(c, cm, cidx, RED, ctok, 13, 0.035)
-- lit ridge seam with a dark groove beside it
cm:each(function(x, y) local k = K(x, y)
  local s, t = CS[k], CT[k]
  if t > 0.05 and t < 0.9 then
    if s > -0.42 and s <= -0.26 then A.step(c, cidx, RED, x, y, 1, ctok)
    elseif s > -0.26 and s <= -0.12 then A.step(c, cidx, RED, x, y, -1, ctok) end
  end
end)
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and CT[k] > 0.1 and CT[k] < 0.6 then c:put(x, y, "#a64a6a", ctok) end end)
c:put(27, 31, RED[6], ctok) c:put(27, 32, RED[6], ctok)

-- steel band: bevel rows, rivets
local bm = A.bandMask(cm, CX, BY, RW + 1, RY, 5)
local stok = { r = { name = "steel" } }
local sidx = A.shade(c, bm, cn, STEEL, { tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 } })
bm:each(function(x, y)
  local a = A.arcY(x, CX, BY, RW + 1, RY)
  local row = floor(a - y + 0.5)
  if row >= 4 then A.step(c, sidx, STEEL, x, y, 1, stok)
  elseif row == 0 then A.step(c, sidx, STEEL, x, y, -1, stok) end
end)
for _, x in ipairs{ 24, 38 } do
  local y = floor(A.arcY(x, CX, BY, RW + 1, RY) - 2 + 0.5)
  c:put(x, y, STEEL[6], stok) c:put(x, y + 1, STEEL[1], stok)
end
c:put(24, floor(A.arcY(24, CX, BY, RW + 1, RY) - 3.5), STEEL[6], stok)

-- blade badge: upright little sword over the band centre
A.map(c, {
  ".h.",
  ".hf",
  "hHf",
  "hHf",
  "hHf",
  "hHf",
}, 31, 34, { h = STEEL[5], H = STEEL[6], f = STEEL[3], g = "#d98322", G = "#ffe38a", w = "#864c33", W = "#b97a4a", d = "#51302b" })
-- crossguard + grip
for i, col in ipairs{ "#d98322", "#ffe38a", "#ffe38a", "#ffe38a", "#d98322" } do c:put(30 + i - 1, 40, col) end
c:put(31, 41, "#51302b") c:put(32, 41, "#b97a4a") c:put(33, 41, "#51302b")
c:put(31, 42, "#51302b") c:put(32, 42, "#864c33") c:put(33, 42, "#51302b")

-- quirk: rosebud tucked in the band, right side
A.map(c, {
  ".pP.",
  "pPHp",
  "dpPd",
  ".LdL",
  "L.L.",
}, 36, 40, { p = "#f5809f", P = "#ffc4d8", H = "#fff4d6", d = "#7d2c5e", L = "#3f9150" })
A.save(c, "hat-thornblade")
