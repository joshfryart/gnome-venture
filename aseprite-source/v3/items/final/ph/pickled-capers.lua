-- pickled-capers (C34, Opus single pass). Small round-bellied apothecary flask: sphere-lit glass belly on a slim neck,
-- glass lip ring, porous cork (grain pores, paler top face), twisted twine wound twice round the neck with a hanging end.
-- Inside: olive brine three-quarters up the belly, packed with tiny caper buds (sphere-lit, one glint each, air between),
-- meniscus row, darker AO in the gaps. Glass window highlight, cool bounce lower right.
-- quirk: a single fat caper berry on its stalk dangles from the twine end like a charm.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("pickled-capers")
local CX, CY, R = 32, 39, 12.5
local BRINE = { "#24402a", "#3a5a2e", "#5a7a34", "#7e9a44", "#a8bc62", "#d2dc94" }
local CAP = { "#16281c", "#26421f", "#3e6428", "#5e8a34", "#8ab248", "#c4d878" }
local CORK = { "#51302b", "#7a4a33", "#a8703f", "#c8925a", "#e0b27a", "#f2d0a0" }
local TW = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local BERRY = { "#1e3a24", "#2f5a2c", "#4a8234", "#6eaa44", "#a2cc66", "#d4ec9a" }

c:groundShadow(CX - .5, CY + R + 1, 10, 1)
-- belly (sphere) + neck + lip
local belly = A.rell(CX, CY, 1, 0, R, R)
local bnorm = X.sphere(CX - .5, CY - .5, R, belly)
local neck, nn, NNX = A.lathe(CX, 19, 28, function(y) if y <= 20 then return 5.5 end return 4 end)
local body = belly:copy():add(neck)
local n = {} for k, v in pairs(nn) do n[k] = v end for k, v in pairs(bnorm) do n[k] = v end
local inner = belly:shrink(1):add(neck:copy():clip(HP.rect(0, 21, 63, 63)):shrink(1))
local NX = {} inner:each(function(x, y) local k = K(x, y) NX[k] = n[k][1] end)
local LEVEL = 33
local air, brine = HP.mask(), HP.mask()
inner:each(function(x, y) if y < LEVEL then air:set(x, y) else brine:set(x, y) end end)
local function sub(m) local t = {} m:each(function(x, y) t[K(x, y)] = n[K(x, y)] end) return t end
A.tone(c, air, sub(air), A.GLASS, { amb = .4, wrap = .5 })

-- capers: hex-packed buds with jitter
local caps = HP.mask()
local list = {}
local row = 0
for y = LEVEL + 2, CY + R - 1, 4 do
  row = row + 1
  for x = CX - R + (row % 2) * 2, CX + R, 4 do
    local jx, jy = floor(X.hash(x, y) * 2), floor(X.hash(y, x, 2) * 2) - 1
    local r = 1.4 + X.hash(x, y, 5) * .5
    local m = A.rell(x + jx + .5, y + jy + .5, 1, 0, r, r)
    if m:copy():cut(brine):count() == 0 then list[#list + 1] = { x + jx, y + jy, r, m } caps:add(m) end
  end
end
local bb = {} X.ao(bb, brine, caps, 1, -1)
A.tone(c, brine:copy():cut(caps), sub(brine), BRINE, { amb = .3, wrap = .45, bias = bb })
for x = CX - R, CX + R do if brine:has(x, LEVEL) and not caps:has(x, LEVEL) then c:put(x, LEVEL, BRINE[6]) end end
for _, q in ipairs(list) do
  local cn = X.sphere(q[1] + .5, q[2] + .5, q[3], q[4])
  local idx = A.tone(c, q[4], cn, CAP, { amb = .1, wrap = .2 })
  local hx, hy = floor(q[1]), floor(q[2])
  if q[4]:has(hx, hy) then c:put(hx, hy, CAP[6]) end
end
A.glass(c, body:copy():clip(HP.rect(0, 21, 63, 63)), inner, n, NX, {
  ys = 21, hiRow = function(y) return y > CY - R + 2 and y < CY + 3 end })
-- extra curved window highlight on the belly + sparkle-ish glint
for _, p in ipairs{ { -8, -6 }, { -9, -4 }, { -9, -3 }, { -7, -7 } } do
  local x, y = CX + p[1], CY + p[2]
  if inner:has(x, y) then c:put(x, y, A.mix(c:get(x, y), "#f4fbff", .7)) end
end
c:put(CX - 6, CY - 8, A.SPEC)
-- lip ring brighter top
for x = CX - 5, CX + 4 do if body:has(x, 19) then c:put(x, 19, x < CX + 1 and A.GLASS[6] or A.GLASS[4]) end end

-- cork (rows 12..19) slightly wider at the top, pores
local cm, cn2 = A.lathe(CX, 12, 18, function(y) if y <= 13 then return 4.5 end return 4 end)
local bias = {} cm:each(function(x, y) if y == 18 then bias[K(x, y)] = -1 end end)
local idx = A.tone(c, cm, cn2, CORK, { amb = .1, wrap = .3, bias = bias })
cm:each(function(x, y)
  if y > 12 and X.hash(x, y, 9) > .72 then c:put(x, y, CORK[max(1, (idx[K(x, y)] or 3) - 2)]) end
end)
for x = CX - 4, CX + 3 do c:put(x, 12, x < CX and CORK[6] or CORK[5]) end
c:put(CX - 1, 12, CORK[4])

-- twine: two twisted turns round the neck (rows 23..24), knot on the right, hanging end
for y = 23, 24 do
  for x = CX - 5, CX + 4 do
    local t = (x + y) % 3
    c:put(x, y, x > CX + 1 and TW[t == 0 and 1 or 2] or TW[t == 0 and 2 or (t == 1 and 3 or 4)])
  end
end
c:put(CX + 5, 23, TW[2]) c:put(CX + 5, 24, TW[1]) c:put(CX + 6, 24, TW[2])
local hang = HP.line({ { CX + 6, 25 }, { CX + 8, 28 }, { CX + 10, 30 }, { CX + 13, 32 } }, 1)
hang:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and TW[3] or TW[2]) end)
local short = HP.line({ { CX + 6, 25 }, { CX + 6, 28 }, { CX + 7, 30 } }, 1)
short:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and TW[2] or TW[1]) end)

-- quirk: caper berry on its stalk, hung from the long twine end
for _, p in ipairs{ { CX + 14, 33 }, { CX + 15, 34 } } do c:put(p[1], p[2], "#5b9a52") end
local bm = A.rell(CX + 16.5, 38, .26, .97, 3.4, 2.4)
local bnn = X.pillow(bm, 2)
local bidx = A.tone(c, bm, bnn, BERRY, { amb = .1, wrap = .3 })
bm:each(function(x, y) -- pale stripes
  if (x - CX) % 2 == 1 and y > 36 and y < 41 and (bidx[K(x, y)] or 0) >= 3 then c:put(x, y, BERRY[min(6, bidx[K(x, y)] + 1)]) end
end)
c:put(CX + 15, 36, A.SPEC)
A.fin(c, "pickled-capers")
