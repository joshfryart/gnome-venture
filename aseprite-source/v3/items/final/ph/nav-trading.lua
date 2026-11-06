-- nav-trading (C3, Opus single pass): a slim brass balance on a walnut plinth. The beam tips left: a stack of
-- gold coins outweighs a red-cap mushroom in the right pan. Material: per-pixel tube light on the 3 px post and
-- 2-3 px beam (6-tone brass, bevel, specular streak, dark pivot eye), sphere finial with glint, pans as shallow
-- bowls with dark inner lip and bright rim, twisted cord (alternating tones), coin edges milled, walnut grain +
-- paler end grain, AO under the collar and a contact shadow under each pan's load.
-- quirk: a little paper price tag dangles from the beam on a thread.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_0.lua")
local HP, X, K, tok = A.HP, A.X, A.K, A.tok
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("nav-trading")
local BR = A.BRASS
local WAL = { "#2e1c1c", "#4a2a26", "#6a3c2c", "#8a5236", "#ab6c44", "#cf9462" }
local GOLD = { "#7a3e18", "#b5651d", "#e0962a", "#f5b82e", "#ffd96a", "#fff0b0" }
local CAP = { "#5e1a34", "#962a3a", "#c83c3a", "#e8583c", "#ff8a5c", "#ffc0a0" }
local CORD = { "#8a6a50", "#c8a878" }

-- plinth
local pl = c:poly{ { 21, 52 }, { 43, 52 }, { 46, 57 }, { 18, 57 } }
local pb = {}
pl:each(function(x, y) if y >= 56 then pb[K(x, y)] = -1 end end)
local pidx = A.pil(c, pl, WAL, 1.5, { bias = pb, tok = tok("plinth") })
for x = 21, 43 do c:put(x, 52, WAL[6], tok("plinth")) end
for x = 20, 44 do c:put(x, 54, WAL[3], tok("plinth")) end -- carved groove
pl:each(function(x, y) if y == 55 and X.hash(x, y, 7) > 0.6 then c:put(x, y, WAL[2], tok("plinth")) end
  if y == 53 and X.hash(x, y, 8) > 0.7 then c:put(x, y, WAL[5], tok("plinth")) end end)
c:put(18, 57, WAL[4], tok("plinth")) c:put(19, 56, WAL[5], tok("plinth")) -- end grain corner
-- collar
local col = c:rect(28, 49, 36, 51)
A.vcyl(c, col, BR, 28, 36, { tok = tok("collar") })
for x = 28, 36 do c:put(x, 49, BR[6], tok("collar")) end
for x = 27, 37 do c:put(x, 52, WAL[2], tok("plinth")) end -- AO under collar

-- post
A.cyl(c, 32, 15, 32, 48.5, 1.6, BR, { tok = tok("post") })
for y = 18, 46 do if y % 9 ~= 0 then c:put(31, y, BR[5], tok("post")) end end
c:put(31, 26, A.CREAM, tok("post"))
-- finial
A.sph(c, 32, 12, 2.9, BR, nil, { tok = tok("finial") })
c:put(31, 11, A.CREAM, tok("finial"))
for x = 30, 34 do c:put(x, 15, BR[2], tok("post")) end

-- strings (twisted cord) drawn before pans
local function cord(x0, y0, x1, y1)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do local t = i / n
    c:put(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), CORD[(i % 2) + 1], tok("cord")) end
end
local L, R = { x = 13, y = 24, rim = 38 }, { x = 51, y = 20, rim = 33 }
cord(L.x, L.y, L.x - 5, L.rim - 1) cord(L.x, L.y, L.x + 5, L.rim - 1)
cord(R.x, R.y, R.x - 5, R.rim - 1) cord(R.x, R.y, R.x + 5, R.rim - 1)

-- beam (left end lower)
A.cyl(c, 12, 24, 52, 19.5, 1.3, BR, { tok = tok("beam") })
for i = 0, 38 do local x = 13 + i local y = floor(23.8 - i * 4.5 / 40 + .5) - 1
  if i % 6 ~= 3 then c:put(x, y, BR[5], tok("beam")) end end
A.sph(c, 12, 23.9, 1.6, BR, nil, { tok = tok("endL") })
A.sph(c, 52, 19.5, 1.6, BR, nil, { tok = tok("endR") })
-- pivot boss with dark eye
A.sph(c, 32, 21.6, 2.6, BR, nil, { tok = tok("pivot") })
c:put(32, 22, BR[1], tok("pivot")) c:put(31, 20, BR[6], tok("pivot"))

-- pans
local function pan(p)
  local m = A.ell(p.x, p.rim, 6.5, 4)
  m:each(function(x, y) if y < p.rim then m.s[K(x, y)] = nil end end)
  local n = X.sphere(p.x - .5, p.rim - 2, 6.5, m)
  X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.3 }), BR, { cuts = A.CUTS, tok = tok("pan" .. p.x) })
  -- rim and inner lip
  local lip = A.ell(p.x, p.rim, 6.5, 1.6)
  lip:each(function(x, y) c:put(x, y, (y < p.rim) and BR[2] or BR[4], tok("pan" .. p.x)) end)
  local inner = A.ell(p.x, p.rim, 5.2, 0.9)
  inner:each(function(x, y) c:put(x, y, BR[1], tok("pan" .. p.x)) end)
  for x = p.x - 6, p.x - 3 do if lip:has(x, p.rim) then c:put(x, p.rim, BR[6], tok("pan" .. p.x)) end end
  c:put(p.x - 3, p.rim + 2, A.CREAM, tok("pan" .. p.x))
  return m
end
pan(L) pan(R)

-- coins on left pan (stack of three + one leaning)
local function coin(cx, cy)
  local m = A.ell(cx, cy, 3.6, 1.3)
  local e = A.ell(cx, cy + 1, 3.6, 1.3)
  e:each(function(x, y) if not m:has(x, y) then c:put(x, y, GOLD[2], tok("coin")) end end)
  m:each(function(x, y) c:put(x, y, (x < cx) and GOLD[5] or GOLD[4], tok("coin")) end)
  c:put(floor(cx - 2), floor(cy), GOLD[6], tok("coin"))
  for x = floor(cx) - 2, floor(cx) + 3, 2 do if e:has(x, floor(cy) + 2) and not m:has(x, floor(cy) + 2) then c:put(x, floor(cy) + 2, GOLD[1], tok("coin")) end end
end
for x = L.x - 4, L.x + 4 do c:put(x, L.rim, BR[1]) end -- contact shadow
coin(L.x, L.rim - 1.5) coin(L.x - 0.4, L.rim - 3.5) coin(L.x + 0.6, L.rim - 5.5)
c:put(L.x + 1, L.rim - 6, "#fff4d6")

-- mushroom on right pan
for x = R.x - 2, R.x + 2 do c:put(x, R.rim, BR[1]) end
local stem = c:rect(R.x - 1, R.rim - 4, R.x + 1, R.rim - 1)
A.vcyl(c, stem, { "#a08a78", "#c4ae98", "#dcc8b0", "#ece0c8", "#f8f0dc", "#fff8ea" }, R.x - 1, R.x + 1, { tok = tok("stem") })
local cap = A.ell(R.x, R.rim - 4.5, 4.2, 3.2)
cap:each(function(x, y) if y > R.rim - 4.5 then cap.s[K(x, y)] = nil end end)
local _, _, cidx = A.sph(c, R.x - .3, R.rim - 4.5, 4.2, CAP, cap, { tok = tok("cap") })
for x = R.x - 4, R.x + 4 do if cap:has(x, R.rim - 5) then c:put(x, R.rim - 4, CAP[2], tok("cap")) end end
for x = R.x - 3, R.x + 3 do c:put(x, R.rim - 4, CAP[1], tok("cap")) end
c:put(R.x - 2, R.rim - 7, "#fff4d6", tok("cap")) c:put(R.x + 1, R.rim - 6, "#fff4d6", tok("cap")) c:put(R.x + 3, R.rim - 5, "#f2e6d0", tok("cap"))
c:put(R.x - 1, R.rim - 3, "#a08a78", tok("stem"))

-- quirk: paper price tag on a thread
for y = 21, 24 do c:put(41, y, CORD[(y % 2) + 1], tok("tagthread")) end
A.paint(c, {
  ".pPp",
  "pPkP",
  "pPPq",
  "pRRq",
  ".qqq",
}, 39, 25, { p = "#fff4d6", P = "#f4e4c0", q = "#c8b08c", k = "#6a4a3a", R = "#e8493b" })

A.fin()
