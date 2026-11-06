-- cornbread (ph, Opus single pass): a square-cut slice of cornbread seen in 3/4 view. Domed golden-brown top crust
-- with baked cracks (dark split + lit lip), a thin crust skin and browned base on the yellow crumb, crumb pored and
-- flecked with cornmeal grit, a scalloped bite out of the front-right corner showing the inner crumb, ground shadow.
-- quirk: a pat of butter on top has slumped and one glossy drip has run over the edge and down the front.
local NAME = "cornbread"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = G.new(NAME)
local CRUST = { "#5a2a1c", "#86401f", "#b4632a", "#d68a34", "#efb24e", "#ffd77a" }
local CRUMB = { "#8f5524", "#bd7f2e", "#dea23a", "#f2c451", "#fcdc74", "#fff0a8" }
local BUT = { "#b07a26", "#dcaa3c", "#f4d462", "#fbe68e", "#fff3bc", "#fffbe2" }

c:groundShadow(31, 46, 24, 2)

-- solid: top (rows 19..28, sheared), front 10..44 x 29..45, right side sheared
local FX0, FX1, FY0, FY1, D = 10, 43, 29, 45, 9
local top, front, side = HP.mask(), HP.mask(), HP.mask()
for y = FY0 - D, FY0 - 1 do local o = FY0 - y for x = FX0 + o, FX1 + o do top:set(x, y) end end
for y = FY0, FY1 do for x = FX0, FX1 do front:set(x, y) end end
for x = FX1 + 1, FX1 + D do local o = x - FX1 for y = FY0 - o, FY1 - o do side:set(x, y) end end
-- soft dome: lift the middle of the top's back edge one row
for x = FX0 + D + 6, FX1 + D - 6 do top:set(x, FY0 - D - 1) end
local solid = top:copy():add(front):add(side)

-- bite out of the front-right corner (three scallops)
local bite = HP.mask()
for _, b in ipairs{ { 44, 27, 4.6 }, { 41, 31, 3.4 }, { 48, 23, 3.6 } } do bite:add(c:ellipse(b[1], b[2], b[3], b[3])) end
local biteSolid = bite:copy():clip(solid)
top:cut(bite) front:cut(bite) side:cut(bite)

-- faces
G.toneN(c, top, G.face(top, { -0.05, -0.85, 0.55 }, 3, 1.3), CRUST, { cuts = { 0.3, 0.5, 0.7, 0.9, 0.985 }, amb = 0.05 })
G.toneN(c, front, G.face(front, { 0, 0.05, 1 }, 2, 0.8), CRUMB, { cuts = { 0.14, 0.28, 0.42, 0.58, 0.86 }, amb = 0.12 })
G.toneN(c, side, G.face(side, { 0.85, 0.1, 0.55 }, 2, 0.8), CRUMB, { cuts = { 0.14, 0.26, 0.38, 0.6, 0.85 }, amb = 0.2, wrap = 0.5 })

-- crust skin along the front and side top edges, browned base
front:each(function(x, y)
  if y == FY0 then c:put(x, y, CRUST[4]) elseif y == FY0 + 1 then c:put(x, y, CRUMB[3]) end
  if y == FY1 then c:put(x, y, CRUST[2]) elseif y == FY1 - 1 then c:put(x, y, CRUST[3]) end
end)
side:each(function(x, y) local o = x - FX1
  if y == FY0 - o then c:put(x, y, CRUST[3]) end
  if y == FY1 - o then c:put(x, y, CRUST[1]) elseif y == FY1 - o - 1 then c:put(x, y, CRUST[2]) end
end)
-- ambient row where the side meets the front
for y = FY0 + 1, FY1 - 1 do if side:has(FX1 + 1, y - 1) then c:put(FX1 + 1, y - 1, CRUMB[2]) end end

-- crumb pores (dark pit with a lit grain above-left) and cornmeal grit
local function pores(m, y0, y1, seed, dens)
  m:each(function(x, y)
    if y <= y0 or y >= y1 then return end
    local h = X.hash(x, y, seed)
    if h < dens then
      c:put(x, y, CRUMB[2])
      if m:has(x - 1, y - 1) and y - 1 > y0 then c:put(x - 1, y - 1, CRUMB[6]) end
    elseif h > 0.965 then c:put(x, y, CRUST[4]) end
  end)
end
front:each(function() end)
pores(front, FY0 + 1, FY1 - 1, 7, 0.07)
local sideBody = HP.mask() side:each(function(x, y) local o = x - FX1 if y > FY0 - o + 1 and y < FY1 - o - 1 then sideBody:set(x, y) end end)
sideBody:each(function(x, y) if X.hash(x, y, 3) < 0.09 then c:put(x, y, CRUMB[1]) end end)

-- top cracks: dark split with a lit lip above
local cracks = {
  { { 20, 25 }, { 23, 24 }, { 26, 24 }, { 28, 23 } },
  { { 33, 22 }, { 36, 21 }, { 39, 21 } },
  { { 25, 21 }, { 27, 20 } },
  { { 36, 26 }, { 39, 25 }, { 41, 25 } },
}
for _, cp in ipairs(cracks) do
  G.poly1(cp):each(function(x, y) if top:has(x, y) then
    c:put(x, y, CRUST[2])
    if top:has(x, y - 1) then c:put(x, y - 1, CRUST[6]) end
    if top:has(x, y + 1) then c:put(x, y + 1, CRUST[3]) end
  end end)
end
top:each(function(x, y) if X.hash(x, y, 11) < 0.05 then c:put(x, y, CRUST[3]) end end)

-- bite rim: exposed crumb just inside the scallop edge (darker, pored), crust lip lit
local brim = HP.mask()
for _, m in ipairs{ top, front, side } do m:each(function(x, y)
  if bite:has(x + 1, y) or bite:has(x, y - 1) or bite:has(x + 1, y - 1) then brim:set(x, y) end end) end
brim:each(function(x, y)
  if top:has(x, y) then c:put(x, y, CRUMB[4]) else c:put(x, y, X.hash(x, y, 2) < 0.4 and CRUMB[1] or CRUMB[2]) end end)
-- butter pat (quirk): slumped square with a 2px front, a glossy drip over the crust onto the front face
local BX, BY = 22, 24
local btop, bfront = HP.mask(), HP.mask()
for y = BY - 4, BY do local o = BY - y for x = BX + o, BX + o + 9 do btop:set(x, y) end end
btop:cut(c:rect(BX + 4 + 9, BY - 4, BX + 4 + 9, BY - 4))
for x = BX, BX + 9 do bfront:set(x, BY + 1) end
for x = BX + 1, BX + 8 do bfront:set(x, BY + 2) end
-- melt pool spreading on the crust
local pool = c:ellipse(BX + 5, BY + 2.5, 7, 1.5):cut(btop):cut(bfront):clip(top)
pool:each(function(x, y) c:put(x, y, BUT[2]) end)
G.toneN(c, btop, G.face(btop, { -0.1, -0.85, 0.55 }, 2, 1), BUT, { cuts = { 0.2, 0.35, 0.5, 0.66, 0.86 }, amb = 0.15 })
bfront:each(function(x, y) c:put(x, y, y == BY + 1 and BUT[3] or BUT[2]) end)
-- contact shadow of the pat on the crust
for x = BX + 1, BX + 11 do if top:has(x, BY + 3) and not pool:has(x, BY + 3) then c:put(x, BY + 3, CRUST[3]) end end
for y = BY - 4, BY + 1 do local x = BX + (BY - y) + 11 if top:has(x, y) then c:put(x, y, CRUST[3]) end end
c:put(BX + 3, BY - 3, BUT[6]) c:put(BX + 4, BY - 3, BUT[6])
-- drip: from the pool lip down the front face, ends in a round bead
local DX = BX + 7
local drip = HP.mask()
for y = BY + 3, FY0 + 6 do drip:set(DX, y) drip:set(DX + 1, y) end
drip:add(c:ellipse(DX + 0.5, FY0 + 7.5, 1.5, 1.5))
drip:each(function(x, y)
  local col = BUT[3]
  if x == DX then col = BUT[4] end
  if x == DX + 1 then col = BUT[2] end
  if y == FY0 + 9 or (x == DX + 2) then col = BUT[1] end
  c:put(x, y, col)
end)
c:put(DX, FY0 + 6, BUT[6])
-- wet sheen on the crumb beside the drip
for y = FY0 + 2, FY0 + 5 do if front:has(DX + 2, y) then c:put(DX + 2, y, CRUMB[2]) end end

-- two crumbs fallen by the bite
for _, q in ipairs{ { 52, 45, 1 } } do
  c:put(q[1], q[2], CRUMB[5]) c:put(q[1] + 1, q[2], CRUMB[3])
  if q[3] == 1 then c:put(q[1], q[2] + 1, CRUMB[3]) c:put(q[1] + 1, q[2] + 1, CRUMB[2]) end
end

G.saveTo(c, "ph", NAME)
