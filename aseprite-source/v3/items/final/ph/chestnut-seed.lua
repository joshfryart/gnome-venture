-- chestnut-seed (final, Opus single pass). One glossy mahogany chestnut (teardrop, flat base, pale stippled hilum,
-- grain streaks, tassel at the tip) on a torn, bristle-toothed chestnut-leaf scrap. A sprout rises from the tip with
-- two long serrated chestnut leaves and a bud. quirk: a little spiny shard of the burr husk rests beside the nut.
local NAME = "chestnut-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local NUT = { "#2e1418", "#4e2020", "#73321f", "#9a4c26", "#c26c34", "#e69a5a" }
local HIL = { "#5e4a3c", "#8a7458", "#b49c78", "#d8c49c" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local BUR = { "#4e5a22", "#728030", "#98a43e", "#bcc456", "#dce07c", "#f4f0a8" }

-- chestnut mask: teardrop, rows 33..50, flat rounded base
local CX, YT, YB = 28, 33, 50
local function hw(y)
  local t = (y - YT) / (YB - YT)
  if t < 0.72 then return 9.4 * sin(pi / 2 * t / 0.72) ^ 0.75 end
  return 9.4 - ((t - 0.72) / 0.28) ^ 2 * 3.2
end
local nut = HP.mask()
for y = YT, YB do local w = hw(y) for x = CX - 11, CX + 11 do if abs(x - CX) <= w then nut:set(x, y) end end end
-- burr shard (quirk): small dome of husk to the right
local bur = c:ellipse(46, 49, 5, 4) bur:clip(c:rect(0, 0, 63, 49))

-- torn leaf scrap under everything
A.leaf(c, 56, 49, 34, 55, 7, 46, { w = 8, pow = 0.5, tear = 0.12, teeth = 3.2, ramp = LEAF, vein = "#c2e48c",
  cool = "#3a6c72", edge = "#d6eaa0", casters = { nut, bur }, period = 4.2, fold = 0.38, seed = 5 })

-- sprout stem from the nut tip, leaves
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 28, 34 }, { 27, 27 }, { 31, 22 }, { 30, 15 } }, function() return 1.05 end)
sm:cut(nut)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local ltok = { r = { name = "sprout" } }
local l1 = A.leaf(c, 31, 18, 37, 10, 48, 9, { w = 3.2, teeth = 2.6, ramp = LEAF, vein = "#c2e48c", cool = "#3a6c72", tok = ltok, fold = 0.45 })
local l2 = A.leaf(c, 29, 22, 22, 15, 13, 16, { w = 2.9, teeth = 2.6, ramp = LEAF, vein = "#c2e48c", cool = "#3a6c72", tok = ltok, fold = 0.45 })
-- terminal bud
local bud = A.rell(30.5, 12.5, 0.1, -1, 2.6, 1.3)
bud:cut(l1)
A.toneN(c, bud, X.pillow(bud, 1.3), LEAF, { tok = ltok, cuts = A.LCUTS, amb = 0.2, wrap = 0.3 })

-- burr shard: spiny husk dome with pale prickles
do
  local tok = { r = { name = "bur" } }
  local n = X.pillow(bur, 2.5)
  local bias = {}
  bur:each(function(x, y) if (x + y * 2) % 3 == 0 then bias[K(x, y)] = 1 end end)
  X.ao(bias, bur, nut, 1, -1)
  X.tone(c, bur, X.light(n, { amb = 0.1, wrap = 0.3 }), BUR, { cuts = A.CUTS6, bias = bias, tok = tok })
  for _, sp in ipairs{ { 42, 46, -1, -1 }, { 45, 45, 0, -1 }, { 48, 45, 1, -1 }, { 51, 47, 1, -1 } } do
    c:put(sp[1] + sp[3], sp[2] + sp[4], BUR[6], tok)
    c:put(sp[1] + 2 * sp[3], sp[2] + 2 * sp[4], BUR[5], tok)
  end
  -- pale velvet lining along the broken bottom edge
  for x = 42, 50 do if bur:has(x, 49) then c:put(x, 49, x % 2 == 0 and "#efe2b8" or "#d8c49c", tok) end end
end

-- the chestnut
do
  local tok = { r = { name = "nut" } }
  local n = X.pillow(nut, 5.5)
  local bias = {}
  X.ao(bias, nut, bur, 1, -1)
  nut:each(function(x, y) local k = K(x, y)
    local w = hw(y)
    local u = (x - CX) / max(w, 1)
    if y > YT + 2 and y < YB - 3 and ((u * 3.1 + 0.55) % 1) < 0.17 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local v = X.light(n, { amb = 0.08, wrap = 0.25 })
  local idx = X.tone(c, nut, v, NUT, { cuts = A.CUTS6, bias = bias, tok = tok })
  -- hilum: pale stippled base, wavy top line
  nut:each(function(x, y)
    local top = YB - 3 + ((x % 4 == 0) and 1 or 0)
    if y >= top then
      local i = (x < CX - 2) and 3 or ((x > CX + 4) and 1 or 2)
      if y == YB then i = max(1, i - 1) end
      if A.X.hash(x, y, 9) > 0.7 then i = min(4, i + 1) end
      c:put(x, y, HIL[i], tok)
    elseif y == top - 1 then c:put(x, y, NUT[1], tok) end
  end)
  -- specular streak + glint
  local sx, sy = A.specAt(nut, n, 40)
  c:put(sx, sy, A.CREAM, tok) c:put(sx, sy + 1, NUT[6], tok) c:put(sx + 1, sy, NUT[6], tok)
  c:put(sx - 1, sy + 3, NUT[6], tok) c:put(sx - 1, sy + 4, NUT[6], tok)
  -- cool reflected light on the lower-right edge
  nut:edge():each(function(x, y) if x > CX + 4 and y > YT + 7 and y < YB - 3 then c:put(x, y, "#6a3a4a", tok) end end)
end
A.save(c, NAME)
