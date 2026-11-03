-- ico-trophy (final, Opus). Polished gold loving-cup: tulip bowl with a rolled rim (dark inside, lit far wall),
-- two slim ear handles, a slender stem with a round knop, flared foot, on a stepped walnut plinth with a brass plate.
-- Material: per-pixel ellipsoid light on the bowl with polished-metal reflection bands (dark horizon band, bright
-- specular streak, warm bounce on the right edge), a raised bead ring, pillow-bevelled handles, walnut with grain
-- and a lit top arris, engraved plate, AO where the stem meets bowl and foot, ground shadow under the plinth.
-- quirk: a four-leaf clover is poking up out of the cup.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = R.new("ico-trophy")
local GOLD = { "#6e3a1e", "#a35a1c", "#d48c20", "#f2b62e", "#ffdc66", "#fff2b4" }
local WAL  = { "#341f26", "#52302a", "#734632", "#93603e", "#b27e52", "#d0a070" }
local LEAF = { "#21593f", "#3f9150", "#7cc35a", "#c4e07a" }
local gt, wt = { r = { name = "gold" } }, { r = { name = "walnut" } }

c:groundShadow(32, 54, 15, 1.5)
local CX = 31.5

---------------------------------------------------------------- plinth (stepped walnut block)
local top = c:rect(21, 42, 42, 44)
local blk = c:rect(19, 45, 44, 53)
local pl = top:copy():add(blk)
local pn = {}
pl:each(function(x, y)
  local x0, x1 = (y <= 44) and 21 or 19, (y <= 44) and 42 or 44
  local t = max(-.9, min(.9, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1)) * 0.55
  local ny = (y == 42 or y == 45) and -0.8 or (y == 44 or y == 53) and 0.5 or 0
  pn[K(x, y)] = { R.norm(t, ny, 1) }
end)
local pidx = R.shade(c, pl, pn, WAL, { amb = 0.1, wrap = 0.3, tok = wt })
-- grain on the front faces + AO under the top step
pl:each(function(x, y)
  local h = X.hash(floor(x / 3), y, 21)
  if y >= 47 and y <= 52 and (y + floor(x / 7)) % 3 == 0 and X.hash(x, y, 4) > 0.3 then R.step(c, pidx, WAL, x, y, -1, wt) end
  if y == 45 and x >= 21 and x <= 42 then R.step(c, pidx, WAL, x, y, -1, wt) end
end)
-- brass plate with engraved line
local plate = c:rect(26, 47, 37, 50)
plate:each(function(x, y)
  local col = GOLD[4]
  if y == 47 then col = GOLD[5] elseif y == 50 then col = GOLD[2] end
  if x == 26 then col = GOLD[5] elseif x == 37 then col = GOLD[2] end
  if y == 48 and x >= 28 and x <= 35 and x ~= 31 then col = GOLD[2] end
  if y == 49 and x >= 28 and x <= 35 then col = GOLD[5] end
  c:put(x, y, col, gt)
end)
c:put(26, 47, GOLD[6], gt)

---------------------------------------------------------------- foot, stem, knop
local foot = c:poly{ { 24, 41 }, { 39, 41 }, { 36, 38 }, { 27, 38 } }
local stem = c:rect(30, 30, 33, 37)
local knop = c:ellipse(CX, 33.5, 3, 2)
local base = foot:copy():add(stem):add(knop)
local bn = {}
base:each(function(x, y)
  local t = max(-.95, min(.95, (x + 0.5 - (CX + 0.5)) / 4.5))
  if knop:has(x, y) then local ny = (y - 33.5) / 2.6 bn[K(x, y)] = { R.norm(t, ny, sqrt(max(0.05, 1 - t * t))) }
  elseif foot:has(x, y) then bn[K(x, y)] = { R.norm(t * 0.5, -0.6, 0.7) }
  else bn[K(x, y)] = { R.norm(t * 1.6, 0, 1) } end
end)
local bbias = {}
base:each(function(x, y) if y == 41 or y == 30 or y == 37 then bbias[K(x, y)] = -1 end end)
local bidx = R.shade(c, base, bn, GOLD, { amb = 0.08, wrap = 0.2, tok = gt, bias = bbias })
R.sepLine(c, foot, stem, GOLD[2], gt)

---------------------------------------------------------------- handles (behind the bowl edge)
local function ear(cx, cy, side)
  local m = c:ellipse(cx, cy, 5, 6.5):cut(c:ellipse(cx, cy, 2.2, 3.7))
  return m
end
local hl = ear(18, 19.5, -1)
local hr = ear(45, 19.5, 1)
local hands = hl:copy():add(hr)
local hn = X.pillow(hands, 1.6)
local hidx = R.shade(c, hands, hn, GOLD, { amb = 0.1, wrap = 0.22, tok = gt })

---------------------------------------------------------------- bowl
local bowl = HP.mask()
local function bw(y)                       -- half width per row: tulip, rounded bottom
  if y < 12 then return nil end
  if y <= 22 then return 11.6 - (y - 12) * 0.12 end
  local t = (y - 22) / 8.5
  if t > 1 then return nil end
  return (11.6 - 1.2) * sqrt(max(0, 1 - t * t)) + (t > 0.8 and 1.2 or 0.3)
end
for y = 11, 31 do local h = bw(y) if h then for x = floor(CX - h + .5), floor(CX + h - .5) do bowl:set(x, y) end end end
local nb = {}
bowl:each(function(x, y)
  local h = bw(y)
  local t = max(-.97, min(.97, (x + 0.5 - CX) / (h + 0.4)))
  local ny = y > 22 and ((y - 22) / 9) * 0.9 or -0.05
  nb[K(x, y)] = { R.norm(t, ny, sqrt(max(0.05, 1 - t * t))) }
end)
local v = X.light(nb, { amb = 0.1, wrap = 0.2 })
-- polished reflection: dark horizon band just right of centre, bright bounce near the right edge
local bias = {}
bowl:each(function(x, y) local k = K(x, y) local nx = nb[k][1]
  if nx > 0.12 and nx < 0.42 then bias[k] = -1 end
  if nx > 0.62 and nx < 0.8 and y < 26 then bias[k] = 1 end
end)
local idx = X.tone(c, bowl, v, GOLD, { cuts = R.CUTS, bias = bias, tok = gt })
-- rolled rim: bright top lip, dark mouth inside, inner far wall lit on the right
local mouth = c:ellipse(CX, 12, 10.6, 2.2)
mouth:each(function(x, y)
  if bowl:has(x, y) or y < 12 then
    local col = (x < CX + 3) and GOLD[1] or GOLD[2]
    if y >= 13 and x > CX + 3 then col = GOLD[3] end
    c:put(x, y, col, gt)
  end
end)
local lip = mouth:grow(1):cut(mouth)
lip:each(function(x, y) if y <= 14 then
  local col = (x < CX - 4) and GOLD[6] or (x < CX + 5 and GOLD[5] or GOLD[4])
  if y >= 13 then col = (x < CX) and GOLD[5] or GOLD[3] end
  c:put(x, y, col, gt) bowl:set(x, y) end end)
-- raised bead ring around the lower bowl
for x = 0, 63 do if bowl:has(x, 24) then
  R.step(c, idx, GOLD, x, 24, -2, gt)
  if bowl:has(x, 23) then R.step(c, idx, GOLD, x, 23, 1, gt) end
end end
-- specular streak down the lit flank + one cream sparkle
for y = 16, 22 do c:put(floor(CX - 6.5), y, y == 17 and R.CREAM or GOLD[6], gt) end
c:put(floor(CX - 5.5), 17, GOLD[6], gt)
-- AO where the stem meets the bowl, handles sit behind the bowl
R.sepLine(c, hands, bowl, GOLD[1], gt)
stem:each(function(x, y) if y <= 31 then c:put(x, y, GOLD[1], gt) end end)

---------------------------------------------------------------- quirk: four-leaf clover poking out of the cup
local ct = { r = { name = "clover" } }
local CL = { d = LEAF[1], s = LEAF[2], b = LEAF[3], h = LEAF[4] }
R.map(c, {
  ".hb...bs.",
  "hbbb.bbbd",
  ".bbbsbbd.",
  "...sss...",
  ".hbbsbbs.",
  "hbbs.bbsd",
  ".bs..ssd.",
  "....s....",
  "...s.....",
}, 33, 5, CL, ct)

R.save(c, "ico-trophy")
