-- fine-mesh-net (aB31_4, Opus single pass). A slim long-handled dip net seen on the diagonal: ash handle from the
-- lower-left with a twisted cord grip and pale end grain, a steel ferrule, a round brass hoop (torus light, bright
-- top edge) and a fine diamond-mesh bag sagging to the lower-right. Mesh: lit as a soft bag, then a 3 px diamond
-- weave (light thread, darker holes); the bag's back wall shows through the hoop as a concave bowl.
-- AO where the bag hangs under the hoop and where the handle enters the ferrule.
-- quirk: a tiny silver minnow has been caught and is flicking about inside the bag.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("fine-mesh-net")
local WOOD  = { "#3e2226", "#5e3328", "#86502f", "#ad713f", "#cf9757", "#ecc386" }
local CORD  = { "#3a1f2e", "#6e2a36", "#a33a3c", "#cf5a44", "#ee8a5a", "#ffbf86" }
local STEEL = { "#2e3048", "#4a4e6c", "#6f7591", "#9aa1b8", "#c6ccdc", "#eef0f6" }
local BRASS = { "#4f2a1e", "#87501f", "#c07f22", "#e5a92e", "#f8d468", "#fff1b8" }
local NET   = { "#2c3f62", "#3f638a", "#5f8fb2", "#8dbdd2", "#bfe2e6", "#ecfaf2" }
local HCX, HCY, HRX, HRY = 40, 19, 12.5, 11

-- bag (behind the hoop): sagging cone from the hoop down to a rounded tip lower-right
local bag = HP.mask()
local bp = { { HCX, HCY + 2 }, { HCX + 3, HCY + 12 }, { HCX + 9, HCY + 21 }, { HCX + 12, HCY + 28 } }
for i = 0, 40 do
  local t = i / 40
  local x, y = A.bez(bp, t)
  local r = 11.2 * (1 - t) ^ 0.8 + 2.6
  bag:add(c:ellipse(x, y, r * 0.95, r))
end
local outerHoop = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  if ((x - HCX) / (HRX + 0.5))^2 + ((y - HCY) / (HRY + 0.5))^2 <= 1 then outerHoop:set(x, y) end end end
bag:cut(outerHoop)
-- keep bag right/below of the hoop only (no lobe to the upper-left)
local trim = HP.mask() bag:each(function(x, y) if y < HCY + 2 and x < HCX + 4 then trim:set(x, y) end end) bag:cut(trim)
local bn = X.pillow(bag, 4)
local bb = {}
X.ao(bb, bag, outerHoop, 2, -1)
local bidx = A.tone(c, bag, bn, NET, { bias = bb, amb = 0.12 })
-- inside of hoop: back wall of the bag, concave (lit lower-right inner wall)
local inner = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  if ((x - HCX) / (HRX - 2.2))^2 + ((y - HCY) / (HRY - 2.2))^2 <= 1 then inner:set(x, y) end end end
local inn = {}
inner:each(function(x, y)
  local dx, dy = (x - HCX) / HRX, (y - HCY) / HRY
  inn[K(x, y)] = { A.norm(-dx * 0.75, -dy * 0.75, 1) }
end)
local ib = {}
inner:each(function(x, y) local dx, dy = (x - HCX) / HRX, (y - HCY) / HRY
  if dx + dy < -0.6 then ib[K(x, y)] = -1 end end)
local iidx = A.tone(c, inner, inn, NET, { bias = ib, cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 } })
-- diamond weave: threads on (x+y)%3==0 and (x-y)%3==0, holes darker
local function weave(m, idx, dHole, dThread)
  m:each(function(x, y)
    local th = ((x + y) % 3 == 0) or ((x - y) % 3 == 0)
    A.step(c, idx, NET, x, y, th and dThread or dHole)
  end)
end
weave(bag, bidx, -1, 1)
weave(inner, iidx, -2, 0)
-- quirk: minnow in the bag (over the weave)
A.map(c, {
  ".abbb.c",
  "aEdbbcc",
  ".dddd.c",
}, 47, 37, { a = STEEL[5], b = STEEL[4], c = STEEL[3], d = STEEL[2], E = A.INK })
c:put(48, 37, STEEL[6])

-- hoop: brass torus ring
local ring = HP.mask()
local rn = {}
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - HCX, y - HCY
  local rho = sqrt((dx / (HRX + 0.5))^2 + (dy / (HRY + 0.5))^2)
  local rin = 1 - 2.3 / HRX
  if rho <= 1 and rho >= rin then
    ring:set(x, y)
    local s = max(-0.95, min(0.95, ((rho - rin) / (1 - rin)) * 2 - 1))
    local l = sqrt(dx*dx + dy*dy) + 1e-6
    rn[K(x, y)] = { A.norm(dx / l * s, dy / l * s, sqrt(1 - s*s)) }
  end
end end
local ridx = A.tone(c, ring, rn, BRASS, { amb = 0.12 })
-- specular streak on the upper-left of the hoop
for _, p in ipairs{ { 31, 11 }, { 32, 10 }, { 33, 9 } } do if ring:has(p[1], p[2]) then c:put(p[1], p[2], BRASS[6]) end end
c:put(32, 10, A.CREAM)

-- handle: ash rod into a steel ferrule at the hoop's lower-left
local hp = { { 9, 56 }, { 16, 47 }, { 23, 38 }, { 31, 28 } }
local hm, hn, HT, HS, hs, HL = A.tube(hp, function(t) return t > 0.82 and 2.0 or 1.55 end, { flat1 = true })
local hb = {}
X.ao(hb, hm, ring, 1, -1)
local fer, grip, wood = HP.mask(), HP.mask(), HP.mask()
hm:each(function(x, y) local t = HT[K(x, y)]
  if t > 0.82 then fer:set(x, y) elseif t < 0.3 then grip:set(x, y) else wood:set(x, y) end end)
local hnW = {} for k, v in pairs(hn) do hnW[k] = v end
local widx = A.tone(c, wood, hn, WOOD, { bias = hb })
-- grain: broken dark line along the shaft, slightly lit-side
wood:each(function(x, y) local k = K(x, y)
  if abs(HS[k] - 0.35) < 0.3 and floor(HT[k] * HL) % 5 ~= 0 then A.step(c, widx, WOOD, x, y, -1) end
  if HT[k] > 0.79 then A.step(c, widx, WOOD, x, y, -2) end   -- AO into the ferrule
end)
-- twisted cord grip
local gidx = A.tone(c, grip, hn, CORD, { bias = hb })
grip:each(function(x, y) local k = K(x, y)
  local u = HT[k] * HL + HS[k] * 2.2
  if u % 3 < 1 then A.step(c, gidx, CORD, x, y, -2) elseif u % 3 < 1.8 then A.step(c, gidx, CORD, x, y, 1) end
  if HT[k] < 0.035 then c:put(x, y, WOOD[6]) end   -- pale end grain at the butt
end)
c:put(9, 56, WOOD[4])
local fidx = A.tone(c, fer, hn, STEEL, { bias = hb })
fer:each(function(x, y) local k = K(x, y)
  if abs(HT[k] - 0.9) < 0.02 then A.step(c, fidx, STEEL, x, y, -2) end      -- crimp ring
  if HS[k] < -0.45 and HT[k] > 0.84 then c:put(x, y, STEEL[6]) end           -- bright edge
end)
A.save(c, "fine-mesh-net")
