-- fountain (B3, Opus single pass). A slim two-tier garden fountain in pale limestone: wide shallow basin with a bevelled
-- lip, moulded foot band and moss creeping at the foot; fluted pillar with collar and capital; small upper bowl and a
-- ball finial throwing a short jet; two clear water veils arc from the upper bowl into the basin (ripple rings, cream
-- glints). Ambient dark rows where stone parts meet, 2-tone ground shadow.
-- quirk: a little green frog sits on the basin lip, watching the water.
local NAME = "fountain"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local STONE = { "#3c3e5a", "#5c5d78", "#83849c", "#a9a8ba", "#cfcdda", "#eeecf2" }
local WATER = { "#24467a", "#2f6ea8", "#3f9cc8", "#6cc8d8", "#a8ecea", "#e4fbf6" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a" }

-- vertical-cylinder tone of a mask between x0..x1 (+ bias)
local function vcyl(m, x0, x1, ramp, tok, bias, amb)
  local n = {}
  m:each(function(x, y) local t = max(-0.95, min(0.95, ((x + 0.5 - x0) / (x1 - x0 + 1)) * 2 - 1))
    n[K(x, y)] = { t, -0.15, sqrt(1 - t * t) } end)
  return A.shade(c, m, n, ramp, { amb = amb or 0.1, wrap = 0.3, tok = tok, bias = bias })
end

c:groundShadow(32, 57, 25, 2)

-- lower basin: bowl body (y 44..55), wider at the lip
local btok = { r = { name = "basin" } }
local body = HP.mask()
for y = 44, 55 do
  local f = (y - 44) / 11
  local hw = 24 - 4.5 * f ^ 1.3
  if y >= 53 then hw = 21 end                -- foot band
  local yy = y
  for x = floor(32 - hw + 0.5), floor(32 + hw - 0.5) do body:set(x, yy) end
end
body:add(c:ellipse(32, 55, 21, 1.5))
local bbias = {}
local bidx = vcyl(body, 8, 56, STONE, btok, bbias)
-- moulding: dark seam under the bowl, lit top of foot band
for x = 11, 53 do c:put(x, 52, STONE[2], btok) end
for x = 12, 44 do c:put(x, 53, STONE[5], btok) end
-- stone pits
body:each(function(x, y) if y < 52 and X.hash(x, y, 5) > 0.93 then c:put(x, y, STONE[max(1, (bidx[K(x, y)] or 3) - 1)], btok) end end)
-- moss creeping at the foot (left)
for _, q in ipairs{ { 12, 54, 2 }, { 13, 54, 3 }, { 14, 55, 2 }, { 13, 55, 1 }, { 15, 54, 2 }, { 12, 53, 3 }, { 16, 55, 2 } } do c:put(q[1], q[2], MOSS[q[3]], btok) end

-- lip (rim ring) and water surface
local ltok = { r = { name = "lip" } }
local lip = c:ellipse(32, 44, 24, 5)
local inner = c:ellipse(32, 44.3, 21, 3.4)
lip:cut(inner)
local ln = X.pillow(lip, 1.6)
local lidx = A.shade(c, lip, ln, STONE, { amb = 0.2, wrap = 0.35, tok = ltok })
lip:each(function(x, y) if y >= 46 then c:put(x, y, STONE[(x < 26) and 5 or 4], ltok) end end) -- front lip face lit
for x = 13, 51 do if lip:has(x, 49) then c:put(x, 49, STONE[3], ltok) end end
local wtok = { r = { name = "water" } }
local wn = {}
inner:each(function(x, y) wn[K(x, y)] = { (x - 32) / 40, -(y - 44) / 10 - 0.25, 1 } end)
for k, v in pairs(wn) do wn[k] = { A.norm(v[1], v[2], v[3]) } end
local widx = {}
inner:each(function(x, y)
  local i = 3
  if y <= 42 then i = 2 end                      -- far water darker (lip shadow)
  if y == 41 then i = 1 end
  if y >= 46 then i = 4 end
  c:put(x, y, WATER[i], wtok)
end)
-- ripple rings where the veils land
for _, cx in ipairs{ 15, 49 } do
  local r = c:ellipse(cx, 45, 3, 1):edge()
  r:each(function(x, y) if inner:has(x, y) then c:put(x, y, WATER[5], wtok) end end)
end
for _, q in ipairs{ { 26, 45 }, { 27, 45 }, { 37, 46 }, { 38, 46 }, { 39, 46 } } do c:put(q[1], q[2], WATER[5], wtok) end

-- pillar (fluted), collar and capital
local ptok = { r = { name = "pillar" } }
local pil = c:rect(30, 28, 34, 42)
local pb = {}
X.ao(pb, pil, c:rect(26, 26, 38, 27), 1, -1)
local pidx = vcyl(pil, 30, 34, STONE, ptok, pb, 0.16)
for y = 30, 40 do c:put(31, y, STONE[3], ptok) c:put(33, y, STONE[3], ptok) end
local col = c:rect(28, 41, 36, 43)
vcyl(col, 28, 36, STONE, ptok, nil, 0.18)
for x = 28, 36 do c:put(x, 41, STONE[x < 32 and 6 or 5], ptok) end
for x = 27, 37 do if inner:has(x, 44) or lip:has(x, 44) then c:put(x, 44, STONE[1], ltok) end end   -- contact shadow at the foot
-- capital
local cap = c:rect(29, 27, 35, 28)
vcyl(cap, 29, 35, STONE, ptok, nil, 0.2)

-- upper bowl
local utok = { r = { name = "ubowl" } }
local ub = HP.mask()
for y = 22, 27 do local f = (y - 22) / 5 local hw = 11 - 6.5 * f ^ 1.2
  for x = floor(32 - hw + 0.5), floor(32 + hw - 0.5) do ub:set(x, y) end end
vcyl(ub, 21, 43, STONE, utok)
for x = 24, 40 do if ub:has(x, 25) then c:put(x, 25, STONE[2], utok) end end   -- under-lip shadow
local ulip = c:ellipse(32, 22, 11, 2.4)
local uin = c:ellipse(32, 22, 9, 1.4)
ulip:cut(uin)
A.shade(c, ulip, X.pillow(ulip, 1.2), STONE, { amb = 0.25, wrap = 0.35, tok = utok })
uin:each(function(x, y) c:put(x, y, y <= 21 and WATER[2] or WATER[4], wtok) end)

-- finial ball + jet
local ftok = { r = { name = "finial" } }
c:fillMask(c:rect(31, 18, 33, 21), STONE[3]) for y = 18, 21 do c:put(31, y, STONE[5], ftok) c:put(33, y, STONE[2], ftok) c:put(32, y, STONE[4], ftok) end
local fb, fbn = A.oval(32, 16, 2.4, 2.4, 0, 1)
A.shade(c, fb, fbn, STONE, { amb = 0.12, wrap = 0.25, tok = ftok })
for y = 9, 13 do c:put(32, y, WATER[y < 11 and 6 or 5], wtok) end
c:put(31, 11, WATER[4], wtok) c:put(33, 11, WATER[4], wtok)
c:put(30, 9, WATER[5], wtok) c:put(34, 9, WATER[5], wtok)

-- veils: water arcs from upper lip down into the basin
local vtok = { r = { name = "veil" } }
for _, side in ipairs{ -1, 1 } do
  local p = { { 32 + side * 10.5, 22.5 }, { 32 + side * 15, 25 }, { 32 + side * 17, 33 }, { 32 + side * 17, 44 } }
  local m, n, T, S = A.tube(p, function(t) return 1.05 - 0.25 * t end)
  m:each(function(x, y) local k = K(x, y)
    local i = (S[k] < 0) and 5 or 3
    if side > 0 then i = (S[k] < 0) and 4 or 3 end
    if (floor(T[k] * 14) % 3 == 0) and S[k] < 0 then i = 6 end  -- falling sparkle streaks
    c:put(x, y, WATER[i], vtok)
  end)
end

-- quirk: frog on the lip (front-left)
local fr = { r = { name = "frog" } }
local FROG = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local fm, fn = A.oval(20, 46, 2.6, 1.9, 0, 0.8)
A.shade(c, fm, fn, FROG, { cuts = { 0.3, 0.55, 0.82 }, tok = fr })
c:put(19, 44, FROG[3], fr) c:put(21, 44, FROG[2], fr)          -- eye bumps
c:put(19, 45, "#2b1c26", fr) c:put(21, 45, "#2b1c26", fr)      -- eyes
c:put(18, 44, FROG[4], fr)
c:put(19, 47, "#f0e8a8", fr) c:put(20, 47, "#f0e8a8", fr)      -- pale throat
c:put(17, 48, FROG[2], fr) c:put(23, 48, FROG[1], fr)          -- feet

-- glint on the upper lip
c:put(24, 21, "#fff4d6")

A.save(c, NAME)
