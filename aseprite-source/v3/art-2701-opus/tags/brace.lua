-- brace (Opus). Tag "hold" (Brace: guard that lasts). A tall gnome pavise planted in the turf and braced from
-- behind by a stout prop pole, the way you dig in to hold a line: arched top, painted moss-green planks with a raised
-- gold centre ridge, iron corner straps and studs, its foot sunk in the earth with a wedge stone kicked against it.
-- Material: plank seams and grain, bevelled iron, round lit prop pole, turf with grass blades.
-- quirk: a snail has settled on top of the shield, sure it is staying put a good long while.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = O.new("brace")

local GRN  = { "#2a1f4a", "#35295f", "#4a3a86", "#5f4ca8", "#7d68c8", "#a892e6" }
local GOLD = { "#6e3a1a", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local IRON = { "#2f3150", "#444663", "#62647e", "#8a8ba2", "#b8b8c8", "#e6e6ee" }
local POLE = { "#4a2a22", "#6e3f2c", "#94593a", "#b97a4a", "#d89c62", "#f0c48a" }
local TURF = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SOIL = { "#3a2622", "#56372c", "#74503a" }
local STN  = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local SNL  = { "#51302b", "#864c33", "#c98a4a", "#f0c070" }
local SKIN = { "#8a6a40", "#c8a868", "#ecd49a", "#fff0c4" }

-- turf mound
do
  local tok = O.tok("turf")
  local m = O.oval(33, 52, 22, 3.6)
  local soil = O.oval(33, 54, 20, 2.4):cut(m)
  m:each(function(x, y) c:put(x, y, y <= 50 and TURF[3] or (y <= 52 and TURF[2] or TURF[1]), tok) end)
  soil:each(function(x, y) c:put(x, y, SOIL[2], tok) end)
  for _, g in ipairs{ 13, 17, 45, 49, 53 } do
    c:put(g, 48, TURF[3], tok) c:put(g, 47, TURF[4], tok) c:put(g + 1, 48, TURF[2], tok)
  end
end

-- prop pole: from behind the shield's upper right down to the turf on the right
local pm, pn, PT, PS = X.cyl(33, 21, 53, 51, function(t) return 2.1 end)
do
  local tok = O.tok("pole")
  local b = {}
  pm:each(function(x, y) local k = K(x, y) if PT[k] > 0.94 then b[k] = -2 end end)
  local idx = O.shade(c, pm, pn, POLE, { tok = tok, bias = b, amb = 0.12, wrap = 0.3 })
  pm:each(function(x, y) local k = K(x, y)
    if PS[k] < -0.45 and PT[k] > 0.2 and PT[k] < 0.9 then O.set(c, idx, POLE, x, y, 5, tok) end
    if abs(PS[k] - 0.2) < 0.15 and (floor(PT[k] * 40) % 4 == 0) then O.step(c, idx, POLE, x, y, -1, tok) end
  end)
  -- rope lashing where it meets the shield back
  O.map(c, { "ab", "ba", "ab" }, 36, 23, { a = GOLD[4], b = GOLD[2] }, O.tok("lash"))
end

-- pavise: arched top, slight lean back
local SA = 0
local SX, SY = 26, 34
local shield, SU, SV = O.lmask(SX, SY, SA + pi / 2, 30, function(u, v)
  -- u runs down the shield, v across (v<0 = right side because of the rotation); half width 11
  local hw = 11
  if u > 18.5 or abs(v) > hw then return false end
  if u < -12 then
    local r = (u + 12) ^ 2 / 81 + (v / hw) ^ 2
    return r <= 1
  end
  return true
end)
do
  local tok = O.tok("planks")
  local face = shield:shrink(2)
  local rim = shield:copy():cut(face)
  local n = {}
  shield:each(function(x, y) local k = K(x, y)
    -- face is gently convex across, and the arch rolls back at the top
    local s = -SV[k] / 13
    local t = SU[k] < -12 and (SU[k] + 12) / 10 or 0
    n[k] = { O.norm(s * 0.6, t * 0.6, 1) }
  end)
  local b = {}
  face:each(function(x, y) local k = K(x, y)
    local v = SV[k]
    if floor(v + 40) % 5 == 0 and abs(v) > 2 then b[k] = -2 end           -- plank seams
    if O.hash(x, floor(y / 3), 9) > 0.86 then b[k] = (b[k] or 0) - 1 end  -- grain dashes
  end)
  local idx = O.shade(c, face, n, GRN, { tok = tok, bias = b, amb = 0.12, wrap = 0.35 })
  -- iron rim band
  local rn = {} rim:each(function(x, y) rn[K(x, y)] = n[K(x, y)] end)
  local ri = O.shade(c, rim, rn, IRON, { tok = O.tok("rim"), amb = 0.15, wrap = 0.3 })
  -- raised gold centre ridge (the pavise spine)
  local ridge = HP.mask()
  face:each(function(x, y) local k = K(x, y) if abs(SV[k]) <= 1.6 and SU[k] > -19 then ridge:set(x, y) end end)
  local tokR = O.tok("ridge")
  ridge:each(function(x, y) local k = K(x, y)
    local v = SV[k]
    c:put(x, y, v > 0.5 and GOLD[5] or (v > -0.5 and GOLD[4] or GOLD[2]), tokR)
  end)
  -- two iron cross bands (reinforced: built to hold) with studs, and a round boss on the spine
  local tokB = O.tok("bands")
  face:each(function(x, y) local k = K(x, y)
    local u, v = SU[k], SV[k]
    for _, bu in ipairs{ -9, 11 } do
      if u >= bu and u < bu + 3 then
        local i = (u < bu + 1) and 5 or (u < bu + 2 and 4 or 2)
        if v < -6 then i = max(1, i - 1) end
        c:put(x, y, IRON[i], tokB)
      end
    end
  end)
  for _, bu in ipairs{ -8, 12 } do
    for _, bv in ipairs{ -7, 7 } do
      local x, y = SX - bv, SY + bu
      c:put(x, y, IRON[6], tokB) c:put(x + 1, y, IRON[3], tokB)
    end
  end
  local boss, bn = O.oval(SX, SY + 1, 3.5, 3.5)
  O.shade(c, boss, bn, IRON, { tok = O.tok("boss"), amb = 0.05, wrap = 0.15 })
  c:put(SX - 1, SY, IRON[6], O.tok("boss"))
  boss:grow(1):cut(boss):each(function(x, y) if not boss:has(x - 1, y - 1) and face:has(x, y) and x >= SX and y >= SY + 1 then c:put(x, y, GRN[1], tok) end end)
  -- foot sunk in the turf: soil lip in front of the base
  local tokL = O.tok("lip")
  for x = 13, 39 do
    if shield:has(x, 50) then c:put(x, 51, TURF[2], tokL) c:put(x, 52, TURF[1], tokL) end
  end
  for _, x in ipairs{ 14, 19, 27, 33, 38 } do c:put(x, 50, TURF[3], tokL) c:put(x, 49, TURF[4], tokL) end
end

-- wedge stone kicked against the foot (left)
do
  local tok = O.tok("stone")
  local m, n = O.oval(11, 49, 4, 3, -0.2)
  O.shade(c, m, n, STN, { tok = tok, amb = 0.15, cuts = { 0.3, 0.55, 0.8 } })
end

-- quirk: snail on the arch
do
  local tok = O.tok("snail")
  local tx, ty = SX - 4, 13
  -- shell: a clear spiral, sitting on the arch
  O.map(c, {
    "..dddd..",
    ".dbbbbd.",
    "dbhhssbd",
    "dbhsdsbd",
    "dbbsssbd",
    "dbbbbbsd",
    ".ddddd..",
  }, tx, ty - 8, { d = SNL[1], b = SNL[3], h = SNL[4], s = SNL[2] }, tok)
  -- body gliding left, eye stalks up
  O.map(c, {
    "e.e........",
    "k.k........",
    "bbbm.......",
    "bbbbbbbbbbm",
  }, tx - 4, ty - 4, { e = "#2b1c26", k = SKIN[2], b = SKIN[3], m = SKIN[2] }, tok)
  c:put(tx - 3, ty - 2, SKIN[4], tok)
end

O.save(c, "brace")
