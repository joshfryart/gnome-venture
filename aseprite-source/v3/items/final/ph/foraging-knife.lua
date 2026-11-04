-- foraging-knife (B3, Opus single pass). A slim mushroom knife on the diagonal: hooked steel blade (edge bevel on the
-- inner curve, bright edge line, specular streak, darker spine, lanyard-free), brass bolster with a lit ring, turned
-- walnut handle with grain lines and two brass rivets, and the classic boar-bristle cleaning brush at the butt.
-- quirk: a tiny brown mushroom cap is still speared on the hook tip.
local NAME = "foraging-knife"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi = math.floor, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new(NAME)

local STEEL = { "#2a3150", "#444663", "#6b6f8c", "#9a9db4", "#c8cad8", "#eef0f6" }
local WOOD  = { "#3d2420", "#5a3428", "#7d4c33", "#a2683f", "#c48b57", "#e2b67e" }
local BRASS = { "#5e3420", "#8f4a1f", "#c27a22", "#e8a62c", "#f8d266", "#fff0b0" }
local BRIS  = { "#5a3e30", "#8a6a4e", "#c0a07a", "#e6d2a8" }
local CAP   = { "#4a2422", "#74382a", "#a05a34", "#c8844a", "#e8b27a" }

-- brush: ferrule + bristles out of the butt (drawn first so the handle overlaps)
local btok = { r = { name = "bristle" } }
for i = -2, 2 do
  local len = 4 - (abs(i) == 2 and 1 or 0)
  for s = 1, len do
    local x = 10 - s + (i > 0 and i or 0)
    local y = 54 + s + (i < 0 and -i or 0)
    local col = BRIS[(i + s) % 2 == 0 and 3 or 2]
    if s == len then col = BRIS[4] end
    if i == 2 then col = BRIS[1] end
    c:put(x, y, col, btok)
  end
end
local fm, fn = A.stem(c, { { 13, 51 }, { 12, 52 }, { 11.5, 52.5 }, { 10.5, 53.5 } }, function() return 2.6 end, BRASS, { tok = { r = { name = "ferrule" } } })

-- handle: walnut, slight swell
local htok = { r = { name = "handle" } }
local hm, hn, HT, HS, hidx = A.stem(c, { { 13, 51 }, { 17, 47 }, { 22, 42 }, { 27, 37 } },
  function(t) return 2.3 + 0.5 * sin(pi * min(1, t * 1.1)) end, WOOD, { tok = htok })
-- grain: long lines along the handle, broken by hash
hm:each(function(x, y) local k = K(x, y) local s, t = HS[k], HT[k]
  local band = floor((s + 1) * 3.2)
  if t > 0.06 and t < 0.94 and (band == 2 or band == 4) and X.hash(x, y, 7) > 0.35 then
    c:put(x, y, WOOD[max(1, (hidx[k] or 3) - 1)], htok) end
end)
-- rivets
for _, t in ipairs{ 0.32, 0.7 } do
  local x, y = A.bez({ { 13, 51 }, { 17, 47 }, { 22, 42 }, { 27, 37 } }, t)
  x, y = floor(x + .5), floor(y + .5)
  c:put(x, y, BRASS[5], htok) c:put(x + 1, y + 1, BRASS[2], htok)
end
-- ambient: darken handle ring next to the bolster/ferrule
hm:each(function(x, y) local k = K(x, y) if HT[k] > 0.93 or HT[k] < 0.05 then c:put(x, y, WOOD[max(1, (hidx[k] or 3) - 2)], htok) end end)

-- bolster
local btk = { r = { name = "bolster" } }
local bm, bn, BT, BS, bidx = A.stem(c, { { 27, 37 }, { 28, 36 }, { 29, 35 }, { 30.5, 33.5 } }, function() return 3.1 end, BRASS, { tok = btk })
bm:each(function(x, y) local k = K(x, y) if BT[k] > 0.4 and BT[k] < 0.62 and BS[k] < 0.2 then c:put(x, y, BRASS[6], btk) end end)

-- blade: hooked, inner (upper-left) edge sharpened
local ktok = { r = { name = "blade" } }
local bp = { { 30.5, 33.5 }, { 40, 25 }, { 50, 20 }, { 48, 11 } }
local km, kn, KT, KS = A.tube(bp, function(t) if t > 0.99 then return 0.4 end return 3.9 * (1 - t ^ 1.4) ^ 0.7 + 0.5 end)
km:cut(bm)
km:each(function(x, y) local k = K(x, y) local s, t = KS[k], KT[k]
  local i
  if s < -0.62 then i = 6                 -- honed edge
  elseif s < -0.2 then i = 5              -- edge bevel
  elseif s < 0.55 then i = 4 -- flat face
  else i = 2 end                          -- spine (shade side)
  if s > 0.85 then i = 1 end
  if i == 4 and X.hash(x, y, 3) > 0.86 then i = 3 end -- faint forge scratches
  if t > 0.88 and i < 5 then i = max(2, i - 1) end
  c:put(x, y, STEEL[i], ktok)
end)
-- bevel line (the grind): 1 px darker seam between bevel and face
km:each(function(x, y) local k = K(x, y) local s = KS[k]
  if s >= -0.2 and s < -0.06 and KT[k] > 0.05 and KT[k] < 0.85 then c:put(x, y, STEEL[3], ktok) end end)
-- specular streak on the face
for i = 0, 18 do local t = 0.18 + i * 0.012 local x, y = A.bez(bp, t)
  local xi, yi = floor(x + 0.5), floor(y + 0.5)
  if km:has(xi, yi) then c:put(xi, yi, STEEL[6], ktok) end end
-- ambient at the bolster: first blade row darker
km:each(function(x, y) if KT[K(x, y)] < 0.03 then c:put(x, y, STEEL[2], ktok) end end)

-- quirk: tiny mushroom cap speared on the hook tip
local ctok = { r = { name = "cap" } }
local cm, cn = A.oval(50.5, 10.5, 2.6, 1.5, -0.25, 0.7)
local cidx = A.shade(c, cm, cn, CAP, { cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = ctok })
c:put(49, 10, CAP[5], ctok)
for _, q in ipairs{ { 49, 12 }, { 50, 12 }, { 51, 12 } } do if not cm:has(q[1], q[2]) then c:put(q[1], q[2], "#e8d6b0", ctok) end end
c:put(51, 12, "#b89a78", ctok)

A.save(c, NAME)
