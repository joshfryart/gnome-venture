-- ico-toolbox (final pass, Opus). A red pressed-steel toolbox seen a touch from above: low box, overhanging lid with
-- its sloped top showing, slim folding steel handle with a ribbed rubber grip on two brackets, brass hasp latch.
-- Material: per-pixel light (6-tone ember paint, bevelled pressed edges), a vertical reflection band and a bright
-- edge on the lid (painted steel), an embossed rib across the front (dark groove + lit lip), rivets with a lit head,
-- brass latch with a dark keyhole, steel handle cylinder with specular, ribbed rubber grip; dark seam + AO row under
-- the lid overhang, AO where the brackets sit, 2-tone ground shadow.
-- quirk: a yellow tape-measure tongue has escaped from under the lid and dangles down the front, hook and all.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("ico-toolbox")
local RED   = { "#521833", "#88213a", "#bf3134", "#e2483a", "#fb7a56", "#ffb48a" }
local STEEL = { "#383a56", "#5a5d7c", "#7e81a0", "#a7aac2", "#d2d4e4", "#f1f1f8" }
local RUB   = { "#1f2236", "#2f3450", "#454c6c", "#626a8a" }
local BRASS = { "#6a3a1c", "#a3621e", "#d48f24", "#f3b830", "#ffd964", "#fff0a8" }
local TAPE  = { "#b0661c", "#e8a326", "#ffd650", "#fff09a" }
local tok, htok, ltok, ttok = { r = { name = "box" } }, { r = { name = "handle" } }, { r = { name = "latch" } }, { r = { name = "tape" } }

c:groundShadow(32, 53, 24, 2)

-- body
local body = c:rrect(10, 31, 53, 51, 2)
local nb = A.slab(body, 3, 26, 36, 26, 0.3)
local bb = {}
for x = 10, 53 do bb[K(x, 32)] = -1 bb[K(x, 33)] = -1 end             -- AO under the lid overhang
local BCUT = { 0.26, 0.44, 0.62, 0.8, 0.94 }
local bidx = A.shade(c, body, nb, RED, { bias = bb, tok = tok, amb = 0.08, wrap = 0.25, cuts = BCUT })
-- reflection band (painted steel) + embossed rib
body:each(function(x, y)
  if (x == 15 or x == 16) and y > 34 and y < 49 then A.step(c, bidx, RED, x, y, 1, tok) end
  if x > 12 and x < 51 then
    if y == 42 then A.step(c, bidx, RED, x, y, -2, tok) elseif y == 43 then A.step(c, bidx, RED, x, y, 1, tok) end
  end
end)
-- rivets
for _, p in ipairs{ { 13, 36 }, { 49, 36 }, { 13, 47 }, { 49, 47 } } do
  c:put(p[1], p[2], STEEL[6], tok) c:put(p[1] + 1, p[2], STEEL[4], tok)
  c:put(p[1], p[2] + 1, STEEL[3], tok) c:put(p[1] + 1, p[2] + 1, STEEL[2], tok)
end

-- lid: sloped top face + front band (overhangs 1 px)
local ltop = c:poly{ { 13, 19 }, { 50, 19 }, { 54, 23 }, { 9, 23 } }
local lfront = c:rrect(9, 23, 54, 30, 1)
local lid = ltop:copy():add(lfront)
local np = X.pillow(lid, 2)
local nl = {}
for k, a in pairs(np) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if y < 23 then nl[k] = { A.norm(a[1] - 0.05, a[2] - 0.75, a[3]) } else nl[k] = { A.norm(a[1] + (x - 31) / 90, a[2], a[3]) } end
end
local lidx = A.shade(c, lid, nl, RED, { tok = tok, amb = 0.1, wrap = 0.28, cuts = { 0.24, 0.42, 0.58, 0.76, 0.92 } })
-- crisp edge where top face folds into the front: bright pressed edge
for x = 10, 53 do A.step(c, lidx, RED, x, 23, 1, tok) end
for x = 11, 22 do c:put(x, 23, RED[6], tok) end
c:put(12, 23, A.CREAM, tok)
-- seam under the lid (dark line), lid lip shade row
for x = 10, 53 do c:put(x, 31, RED[1], tok) end
for x = 10, 53 do A.step(c, lidx, RED, x, 30, -1, tok) end

-- handle: brackets on the lid top, slim steel bail, ribbed rubber grip
local brk = c:rect(20, 18, 25, 20):add(c:rect(38, 18, 43, 20))
local nbk = X.pillow(brk, 1.5)
A.shade(c, brk, nbk, STEEL, { tok = htok, amb = 0.15 })
for _, x0 in ipairs{ 20, 38 } do
  for x = x0, x0 + 5 do A.step(c, lidx, RED, x, 21, -2, tok) end              -- AO on the lid under the bracket
  c:put(x0 + 2, 19, STEEL[1], htok) c:put(x0 + 3, 19, STEEL[1], htok)         -- pivot hole
end
local bail = { { 22.5, 19 }, { 22.5, 9.5 }, { 41.5, 9.5 }, { 41.5, 19 } }
local hm, hn, HT, HS = A.tube(bail, function(t) return (t > 0.3 and t < 0.7) and 2.1 or 1.35 end)
hm:cut(brk:copy():cut(c:rect(22, 18, 23, 19)):cut(c:rect(40, 18, 41, 19)))
local grip, steel = HP.mask(), HP.mask()
hm:each(function(x, y) if HT[K(x, y)] > 0.3 and HT[K(x, y)] < 0.7 then grip:set(x, y) else steel:set(x, y) end end)
A.shade(c, steel, hn, STEEL, { tok = htok, amb = 0.12 })
local gidx = A.shade(c, grip, hn, RUB, { tok = htok, amb = 0.15, cuts = { 0.3, 0.55, 0.8 } })
grip:each(function(x, y) if x % 2 == 0 then A.step(c, gidx, RUB, x, y, -1, htok) end end)    -- grip ribs
-- steel spec on the bail's lit shoulder
c:put(22, 13, STEEL[6], htok) c:put(22, 14, STEEL[6], htok)

-- brass hasp latch over the seam
local plate = c:rrect(29, 26, 34, 31, 1)
local hasp = c:rrect(30, 31, 33, 36, 1)
local lat = plate:copy():add(hasp)
local nla = X.pillow(lat, 1.6)
local laidx = A.shade(c, lat, nla, BRASS, { tok = ltok, amb = 0.12 })
for x = 29, 34 do A.step(c, laidx, BRASS, x, 31, -2, ltok) end               -- hinge line
c:put(31, 33, BRASS[1], ltok) c:put(32, 33, BRASS[1], ltok) c:put(31, 34, BRASS[1], ltok) -- keyhole
c:put(30, 27, BRASS[6], ltok)
for x = 30, 33 do A.step(c, bidx, RED, x, 37, -1, tok) end                   -- contact under the hasp

-- quirk: tape-measure tongue dangling out from under the lid
local function tx(y) return 45 + floor((y - 31) * 0.12 + 0.5) end
for y = 31, 45 do
  local x = tx(y)
  c:put(x, y, TAPE[4], ttok) c:put(x + 1, y, TAPE[3], ttok) c:put(x + 2, y, TAPE[2], ttok)
  if y % 2 == 0 and y > 31 then c:put(x, y, TAPE[1], ttok) end                -- tick marks
  if y % 4 == 1 and y > 32 then c:put(x + 1, y, TAPE[1], ttok) end            -- long tick
  if body:has(x + 3, y) then A.step(c, bidx, RED, x + 3, y, -2, tok) end      -- shadow on the box
end
c:put(tx(31), 31, TAPE[2], ttok) c:put(tx(31) + 1, 31, TAPE[1], ttok) c:put(tx(31) + 2, 31, TAPE[1], ttok) -- slot shade
-- hook end: bent steel tab
local hx = tx(45)
for i = 0, 3 do c:put(hx + i, 46, i == 0 and STEEL[5] or STEEL[3], ttok) end
c:put(hx + 3, 45, STEEL[4], ttok)

A.save(c, "ico-toolbox")
