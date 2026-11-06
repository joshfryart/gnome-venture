-- ico-gift (final, Opus): a wrapped present in three-quarter view, a box a little taller than wide under an
-- overhanging lid, a gold satin ribbon crossing the top and running down the front and side, a two-loop bow.
-- Material: paper planes (top lit, front mid, side in shade) on a 6-tone red ramp with a printed cream polka dot,
-- a bright bevel on the lid's front edge, a contact shadow under the lid overhang, a dark corner seam; satin ribbon
-- with a sheen streak and twisted loops (dark inside of each loop, lit outer curve), knot with a crease; 2-tone
-- ground shadow. quirk: a pink mouse tail curls out from under the lid on the left.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor, cos, sin = math.sqrt, math.max, math.min, math.abs, math.floor, math.cos, math.sin
local c = A.new("ico-gift")
local RD = { "#561730", "#862338", "#b4313c", "#dc4a40", "#f27757", "#ffa983" }
local GD = { "#683a1c", "#9b5a22", "#cf8524", "#eead30", "#ffd462", "#fff0b4" }
local DOT = { "#ffd9c4", "#f6b49c", "#d77a6e" }  -- dot on top / front / side
local SPEC = "#fffbe8"
local pt, rt = { r = { name = "paper" } }, { r = { name = "ribbon" } }
local SL = 4 / 7   -- depth slope

c:groundShadow(32, 56, 17, 1)

local idx, face = {}, {}
local function plane(m, v, gy, gx, ramp, tok, name)
  local x0, y0 = m:bbox()
  local vv = {}
  m:each(function(x, y) vv[K(x, y)] = v + (gy or 0) * (y - y0) + (gx or 0) * (x - x0) end)
  local id = X.tone(c, m, vv, ramp, { cuts = A.CUTS, tok = tok })
  for k, i in pairs(id) do idx[k] = i face[k] = name end
end

-- body (front + side), then the lid over it
local bodyF = HP.rect(17, 32, 37, 54)
local bodyS = HP.poly{ { 37.5, 28 }, { 44.5, 24 }, { 44.5, 51 }, { 37.5, 55 } }
local lidT = HP.poly{ { 14.5, 26 }, { 39.5, 26 }, { 46.5, 22 }, { 21.5, 22 } }
local lidF = HP.rect(15, 26, 39, 32)
local lidS = HP.poly{ { 39.5, 26 }, { 46.5, 22 }, { 46.5, 29 }, { 39.5, 33 } }
lidF:cut(lidT) lidS:cut(lidT):cut(lidF)
local lid = lidT:copy():add(lidF):add(lidS)
bodyS:cut(bodyF):cut(lid) bodyF:cut(lid)
plane(bodyF, 0.62, -0.006, -0.003, RD, pt, "bf")
plane(bodyS, 0.3, -0.004, 0, RD, pt, "bs")
plane(lidT, 0.9, 0.0, -0.004, RD, pt, "lt")
plane(lidF, 0.7, -0.012, -0.003, RD, pt, "lf")
plane(lidS, 0.34, -0.01, 0, RD, pt, "ls")

-- ribbon bands
local rb = HP.mask()
local bandF = HP.rect(25, 26, 29, 54)                                          -- front, lid + body
local bandS = HP.rect(41, 0, 43, 63)                                           -- side, vertical strip
local bandD = HP.poly{ { 24.5, 26 }, { 29.5, 26 }, { 36.5, 22 }, { 31.5, 22 } } -- top, front-to-back
local bandW = HP.rect(14, 23, 48, 24)                                          -- top, left-to-right (mid depth)
local all = bodyF:copy():add(bodyS):add(lid)
for _, b in ipairs{ bandF, bandS, bandD, bandW } do b:clip(all) rb:add(b) end
-- print polka dots on the paper first (not under the ribbon)
for y = 22, 54 do for x = 12, 51 do
  local k = K(x, y) local f = face[k]
  if f and not rb:has(x, y) then
    local u, v = x, y
    if f == "lt" then u = x - (26 - y) * 1.75 end
    if f == "bs" or f == "ls" then v = y + (x - 38) * SL end
    local fu, fv = floor(u) % 8, floor(v + 0.5) % 8
    local on = ((fv == 1 or fv == 2) and (fu == 2 or fu == 3)) or ((fv == 5 or fv == 6) and (fu == 6 or fu == 7))
    if f == "lt" then on = (floor(y) == 24 or floor(y) == 23) and (floor(u) % 8 == 4) end
    if on then
      local d = (f == "lt") and DOT[1] or (f == "bs" or f == "ls") and DOT[3] or DOT[2]
      c:put(x, y, d, pt)
    end
  end
end end
-- ribbon tones follow their plane
rb:each(function(x, y)
  local f = face[K(x, y)]
  local base = ({ bf = 3, bs = 2, lt = 5, lf = 4, ls = 2 })[f] or 3
  if f == "bf" and y > 46 then base = 3 end
  if f == "bf" or f == "lf" then if x == 25 then base = base + 1 elseif x == 29 then base = base - 1 end end
  if f == "bs" or f == "ls" then if x == 41 then base = base + 1 elseif x == 43 then base = base - 1 end end
  base = max(1, min(6, base))
  c:put(x, y, GD[base], rt) idx[K(x, y)] = base
end)
-- satin sheen streak on the front ribbon
for y = 35, 44 do c:put(26, y, GD[5], rt) end
c:put(26, 36, GD[6], rt) c:put(26, 37, GD[6], rt)
for y = 27, 30 do c:put(26, y, GD[6], rt) end

-- bevels and seams
for x = 15, 39 do local k = K(x, 26) if face[k] == "lf" then c:put(x, 26, rb:has(x, 26) and GD[6] or RD[6], pt) end end -- lit front edge
for x = 15, 39 do if lidF:has(x, 32) then A.step(c, idx, rb:has(x, 32) and GD or RD, x, 32, -1, rb:has(x, 32) and rt or pt) end end
-- contact shadow under the lid overhang (2 rows on the body)
for x = 17, 44 do for _, y in ipairs{ 33, 34 } do
  local yy = y
  if x > 37 then yy = floor(33 - (x - 38) * SL + 0.5) + (y - 33) end
  local k = K(x, yy)
  if face[k] == "bf" or face[k] == "bs" then
    local r = rb:has(x, yy) and GD or RD
    A.step(c, idx, r, x, yy, y == 33 and -2 or -1, rb:has(x, yy) and rt or pt)
  end
end end
-- vertical corner seam: front lit edge column, dark first side column
for y = 35, 54 do if not rb:has(37, y) then A.step(c, idx, RD, 37, y, -1, pt) end end
lidS:each(function(x, y) if not lidS:has(x - 1, y) then A.step(c, idx, RD, x, y, -1, pt) end end)
-- back edges of the lid top catch light
lidT:each(function(x, y) if not lidT:has(x, y - 1) and not rb:has(x, y) then A.step(c, idx, RD, x, y, 1, pt) end end)

-- bow: two satin loops + knot + short tails
local bow = HP.mask()
local function loop(cx, cy, ang, ra, rb2, holeDx)
  local m, n = A.oval(cx, cy, ra, rb2, ang)
  local id = A.shade(c, m, n, GD, { tok = rt, amb = 0.12, wrap = 0.3 })
  -- dark inside of the loop
  local h = A.oval(cx + holeDx, cy + 0.5, ra - 2.4, rb2 - 1.6, ang)
  h:each(function(x, y) if m:has(x, y) then c:put(x, y, (y > cy + 0.5) and GD[1] or GD[2], rt) end end)
  -- twist crease where the loop narrows into the knot
  -- satin glint: the most upper-left pixel one step inside the loop
  local inner, best = m:copy():shrink(1), nil
  inner:each(function(x, y) if not h:has(x, y) and (not best or x + y < best[1] + best[2]) then best = { x, y } end end)
  if best then c:put(best[1], best[2], GD[6], rt) c:put(best[1] + 1, best[2], SPEC, rt) end
  bow:add(m)
  return m, id
end
local tl = A.tube({ { 29, 23 }, { 27, 25 }, { 24, 27 }, { 22, 30 } }, function(t) return 1.5 end)
local tr = A.tube({ { 33, 23 }, { 35, 25 }, { 37, 27 }, { 38, 30 } }, function(t) return 1.5 end)
for _, q in ipairs{ { tl, -1 }, { tr, 1 } } do
  local m = q[1]
  m:each(function(x, y) c:put(x, y, GD[q[2] < 0 and 4 or 3], rt) end)
  m:edge():each(function(x, y) if (q[2] < 0 and y > 27) or q[2] > 0 then A.step(c, idx, GD, x, y, 0, rt) end end)
  bow:add(m)
end
-- V-notched tail ends
for _, q in ipairs{ { 22, 31 }, { 38, 31 } } do
  local x, y = q[1], q[2]
  if lidF:has(x, y) then c:put(x, y, RD[idx[K(x, y)] or 3], pt) end
end
local lm = loop(25, 16, -0.6, 6.2, 3.4, 1.4)
local rm = loop(37, 16, 0.6, 6.2, 3.4, -1.4)
-- knot
local knot = HP.rrect(29, 18, 33, 23, 2)
local kn = A.body(knot, 30.5, 20, 3, 2, 0.8)
A.shade(c, knot, kn, GD, { tok = rt, amb = 0.15, wrap = 0.3 })
for y = 19, 22 do c:put(32, y, GD[2], rt) end   -- crease
c:put(30, 19, GD[6], rt) c:put(30, 20, GD[6], rt)
-- AO where the bow sits on the lid top
local bowAll = bow:copy():add(knot)
lid:each(function(x, y) if not bowAll:has(x, y) and (bowAll:has(x, y - 1) or bowAll:has(x - 1, y)) then
  local r = rb:has(x, y) and GD or RD A.step(c, idx, r, x, y, -2, rb:has(x, y) and rt or pt) end end)
-- satin glints on the loops


-- quirk: a mouse tail curling out from under the lid, bottom-left
local TL = { { 16, 33, "#e8899e" }, { 15, 34, "#e8899e" }, { 14, 35, "#f5a6b6" }, { 13, 36, "#f5a6b6" }, { 12, 37, "#e8899e" },
  { 12, 38, "#e8899e" }, { 13, 39, "#c96a84" }, { 14, 39, "#c96a84" }, { 15, 38, "#e8899e" } }
for _, p in ipairs(TL) do c:put(p[1], p[2], p[3], pt) end
A.save(c, "ico-gift")
