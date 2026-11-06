-- dragon-topiary (final pass, Opus). A clipped box-hedge dragon on a slim wooden trunk in a terracotta pot.
-- Hedge: tube and blob parts (curled tail, haunch, rising neck, head with snout, two horn tufts, scalloped wing),
-- per-pixel light on a 6-tone leafy green ramp with jittered normals for clipped-leaf texture, deep separation
-- lines and AO where parts overlap. Trunk: wood ramp with grain. Pot: terracotta cylinder with a lip band,
-- AO under the lip, dark soil, 2-tone ground shadow.
-- quirk: the dragon "breathes fire" as a little spray of red and orange blossoms out of its snout.
local NAME = "dragon-topiary"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_2.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = D.new(NAME)
local HEDGE = { "#13372e", "#1e5136", "#2e6d3a", "#4a8e3e", "#74b04a", "#a8d468" }
local WOOD = { "#4a2c26", "#6e4230", "#93603c", "#b97a4a", "#d69c64", "#ecc08a" }
local POT = { "#5a2a24", "#84392c", "#b0523a", "#d0704a", "#e8966a", "#f6be92" }
local SOIL = { "#2e1c1e", "#45291f", "#5e3a28" }
local RED = { "#8e2238", "#d0342e", "#f06a2e", "#ffb84a" }

-- ground shadow under the pot
c:groundShadow(32, 56, 10, 1.2)

-- pot: body (tapered) + lip band
local pot = HP.poly{ { 23, 46 }, { 41, 46 }, { 39, 55 }, { 25, 55 } }
local lip = HP.rrect(21, 43, 43, 46, 1)
pot:cut(lip)
local ptok = D.tok("pot")
local function vcylN(m, x0, x1)
  local n = {}
  local cxp, r = (x0 + x1) / 2, (x1 - x0) / 2 + 0.6
  m:each(function(x, y) local nx = max(-0.95, min(0.95, (x - cxp) / r)) n[K(x, y)] = { nx, -0.05, sqrt(1 - nx * nx) } end)
  return n
end
local pb = {}
X.ao(pb, pot, lip, 1, -1)
D.toneV(c, pot, vcylN(pot, 23, 41), POT, { bias = pb, tok = ptok, amb = 0.1, rim = 0.15 })
local ltok = D.tok("lip")
local ln = vcylN(lip, 21, 43)
lip:each(function(x, y) local k = K(x, y) if y == 43 then ln[k] = { ln[k][1] * 0.6, -0.6, 0.6 } end end)
D.toneV(c, lip, ln, POT, { tok = ltok, amb = 0.12 })
-- soil inside the lip
for x = 23, 41 do c:put(x, 43, (x % 3 == 0) and SOIL[3] or SOIL[2], ltok) end
for x = 25, 39 do c:put(x, 44, SOIL[1], ltok) end
-- a pale glaze line on the pot body
for x = 25, 39 do if x % 2 == 0 then c:put(x, 50, POT[3], ptok) end end

-- trunk
local trunk = HP.rect(31, 39, 33, 43)
local ttok = D.tok("trunk")
trunk:each(function(x, y)
  local i = x == 31 and 5 or (x == 32 and 4 or 2)
  if y == 43 then i = i - 1 end
  if x == 32 and (y == 41 or y == 42) then i = 3 end -- grain
  c:put(x, y, WOOD[i], ttok)
end)

-- hedge parts (back to front)
local parts = {}
local function hedge(m, n, name, seed)
  parts[#parts + 1] = { m = m, n = D.bump(n, 0.55, seed, 2), name = name }
end
-- tail: from the haunch out left and curling up
do local m, n = G.tube({ { 28, 37 }, { 17, 40 }, { 12, 32 }, { 18, 28 } }, function(t) return 3.0 * (1 - t) + 1.3 end) hedge(m, n, "tail", 3) end
-- wing (scalloped leaf triangle behind the neck)
do
  local m = HP.poly{ { 27, 34 }, { 20, 18 }, { 24, 21 }, { 25, 15 }, { 29, 22 }, { 31, 17 }, { 34, 28 } }
  local n = X.pillow(m, 2.5)
  hedge(m, n, "wing", 5)
end
-- haunch
do local m, n = G.oval(31, 35, 7.5, 5, 0, 0.9) hedge(m, n, "haunch", 7) end
-- neck rising to the head
do local m, n = G.tube({ { 33, 34 }, { 38, 28 }, { 36, 22 }, { 40, 16 } }, function(t) return 3.6 - t * 1.2 end) hedge(m, n, "neck", 9) end
-- head + snout
do
  local m, n = G.oval(43, 14, 5, 3.6, 0.2, 0.9)
  local sm, sn = G.oval(49, 16, 3.2, 2.3, 0.3, 0.9)
  sm:cut(m)
  for k, v in pairs(sn) do if sm.s[k] then n[k] = v end end
  m:add(sm)
  hedge(m, n, "head", 13)
end
-- horn tufts
do local m, n = G.tube({ { 41, 11 }, { 39, 9 }, { 38, 9 }, { 37, 8 } }, function(t) return 1.4 * (1 - t) + 0.5 end) hedge(m, n, "horn1", 17) end
do local m, n = G.tube({ { 44, 11 }, { 44, 9 }, { 43, 8 }, { 43, 7 } }, function(t) return 1.2 * (1 - t) + 0.5 end) hedge(m, n, "horn2", 19) end

-- trunk occluded by haunch: paint parts with separation lines against earlier parts
local drawn = HP.mask()
local drawnOwn = {}
for i, p in ipairs(parts) do
  local bias = {}
  -- AO on this part where later parts sit on it, contact shadow cast down-right
  for j = i + 1, #parts do X.ao(bias, p.m, parts[j].m, 1, -1) G.cast(bias, p.m, parts[j].m, 1, 1, -1) end
  local tok = D.tok(p.name)
  local idx = D.toneV(c, p.m, p.n, HEDGE, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3, rim = 0.12 })
  -- clipped-leaf sparkle: tiny pale leaf ends on lit pixels, dark gaps in the shade
  p.m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 31 + i)
    if idx[k] >= 4 and h > 0.86 then c:put(x, y, HEDGE[min(6, idx[k] + 1)], tok)
    elseif idx[k] <= 3 and h < 0.1 then c:put(x, y, HEDGE[max(1, idx[k] - 1)], tok) end end)
  -- separation: earlier part pixels touching this part get the deep tone
  p.m:grow(1):each(function(x, y) if drawn:has(x, y) and not p.m:has(x, y) then c:put(x, y, HEDGE[1], drawnOwn[K(x, y)]) end end)
  p.m:each(function(x, y) drawn:set(x, y) drawnOwn[K(x, y)] = tok end)
end
-- hedge shadow on the trunk top
c:put(31, 41, WOOD[3], ttok) c:put(32, 41, WOOD[2], ttok) c:put(33, 41, WOOD[1], ttok)

-- eye: a red berry with a glint; nostril
c:put(44, 13, RED[1]) c:put(45, 13, RED[2]) c:put(44, 12, D.CREAM)
c:put(51, 15, HEDGE[1])
-- quirk: blossom "fire" from the snout
local fire = { { 54, 16, 3 }, { 55, 15, 2 }, { 55, 17, 2 }, { 56, 16, 2 }, { 55, 16, 4 }, { 58, 14, 2 }, { 58, 15, 4 }, { 57, 14, 3 }, { 59, 14, 3 }, { 58, 13, 3 } }
for _, f in ipairs(fire) do c:put(f[1], f[2], RED[f[3]], D.tok("fire")) end
c:put(53, 16, HEDGE[3])

D.save(c, NAME)
