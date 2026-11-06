-- hot-cocoa (final, Opus single pass). A tall, slim teal-glazed mug (taller than wide) with a looped handle, a cream
-- band with a little red heart, full of dark cocoa with a pale froth ring and three marshmallow cubes; two steam curls.
-- Material: per-pixel cylinder light on the glaze (6 tones), vertical specular streak + glint, lit rim lip, unglazed
-- clay foot ring, AO where the handle meets the body and under the rim, froth ring and swirl on the cocoa, toasted
-- marshmallow corners. Ground shadow.
-- quirk: one marshmallow is melting and has dribbled over the rim and down the side of the mug.
local NAME = "hot-cocoa"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local MUG = { "#1f3550", "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee0d8", "#d8f6ec" }
local BAND = { "#8a7a80", "#b8a698", "#e0ceb0", "#f6e6c4", "#fff4d6", "#fff4d6" }
local COCOA = { "#2e1a1c", "#4a2a24", "#6b3e2c", "#8c5636", "#b07a4c", "#d8a874" }
local MALLOW = { "#9a7a8c", "#c8aab4", "#ecd4d2", "#fff4d6" }
local CLAY = { "#864c33", "#b97a4a", "#d8a878" }
local STEAM = { "#b8aacc", "#ddd2ea", "#f4eef6" }

c:groundShadow(31, 54, 13, 2)

-- handle (behind body)
local hm = HP.ellipse(41, 37, 6, 8):cut(HP.ellipse(41, 37, 3, 5)):cut(HP.rect(0, 0, 39, 63))
local hb = {}
local body = HP.rect(21, 25, 40, 50):add(HP.rrect(21, 40, 40, 53, 4))
X.ao(hb, hm, body, 2, -1)
local htok = { r = { name = "handle" } }
A.shade(c, hm, X.pillow(hm, 1.6), MUG, { tok = htok, bias = hb, amb = 0.08 })

-- body
local btok = { r = { name = "mug" } }
local bn = A.vcyl(body, 30.5, 10, -0.12, function(y) return y > 50 and (y - 50) * 0.3 or 0 end)
local bbias = {}
body:each(function(x, y) if y <= 26 then bbias[K(x, y)] = -1 end end)    -- AO under the rim lip
local bidx = A.shade(c, body, bn, MUG, { tok = btok, bias = bbias, amb = 0.06, wrap = 0.2 })
-- cream band with a heart
body:each(function(x, y) local k = K(x, y) if y >= 36 and y <= 41 then
  local i = max(1, min(6, (bidx[k] or 3) - 1 + (y == 36 and 0 or 0)))
  c:put(x, y, (y == 36 or y == 41) and MUG[max(1, (bidx[k] or 3) - 1)] or BAND[i], btok) end end)
c:paint({ ".r.r.", "rRRRr", ".RRr.", "..r.." }, 28, 37, { r = "#b52e3f", R = "#e8493b" })
c:put(29, 37, "#e8493b") c:put(29, 38, "#ff8a5c")
-- unglazed clay foot
body:each(function(x, y) if y >= 52 then local i = (bidx[K(x, y)] or 3) c:put(x, y, CLAY[i >= 4 and 3 or (i >= 2 and 2 or 1)], btok) end end)
-- specular streak + glint on the glaze
for y = 28, 34 do c:put(24, y, MUG[6], btok) end for y = 44, 49 do c:put(24, y, MUG[5], btok) end
c:put(24, 30, A.CREAM, btok)
-- glaze drip edge above the foot (glaze thickens: one darker row)
for x = 22, 39 do if body:has(x, 51) then c:put(x, 51, MUG[max(1, (bidx[K(x, 51)] or 3) - 1)], btok) end end
A.sep(c, hm, body, MUG[1], htok)

-- rim and cocoa (top ellipse)
local rimO = HP.ellipse(30.5, 25, 10, 2.6)
local rimI = HP.ellipse(30.5, 25, 8.4, 1.6)
local rtok = { r = { name = "rim" } }
rimO:copy():cut(rimI):each(function(x, y)
  local col = (y > 25) and (x < 28 and MUG[6] or (x < 35 and MUG[5] or MUG[4])) or (x < 26 and MUG[4] or MUG[3])
  c:put(x, y, col, rtok) end)
local ctok = { r = { name = "cocoa" } }
rimI:each(function(x, y)
  local col = COCOA[3]
  if y <= 23 then col = MUG[2]                                   -- far inner wall
  elseif y == 24 then col = (x < 27) and COCOA[2] or COCOA[1]
  else col = (x > 35) and COCOA[2] or COCOA[3] end
  c:put(x, y, col, ctok) end)
-- froth ring + swirl
for _, q in ipairs{ { 23, 25, 5 }, { 24, 26, 5 }, { 25, 26, 4 }, { 36, 26, 4 }, { 37, 25, 4 }, { 31, 25, 6 }, { 32, 25, 5 }, { 33, 26, 4 } } do
  c:put(q[1], q[2], COCOA[q[3]], ctok) end

-- marshmallows: top face, lit front, shade side; separated by a line
local mtok = {}
local function mallow(x0, y0, w, h, i)
  local m = HP.rect(x0, y0, x0 + w - 1, y0 + h - 1)
  local tok = { r = { name = "mallow" .. i } }
  m:each(function(x, y)
    local col = MALLOW[3]
    if y == y0 then col = MALLOW[4] elseif x == x0 + w - 1 then col = MALLOW[2] elseif y == y0 + h - 1 then col = MALLOW[2] end
    c:put(x, y, col, tok) end)
  c:put(x0 + w - 1, y0, MALLOW[3], tok)
  return m, tok
end
local m1, t1 = mallow(24, 21, 4, 4, 1)
local m3, t3 = mallow(34, 21, 4, 4, 3)
local m2, t2 = mallow(29, 19, 5, 5, 2)
-- toasted corners
c:put(27, 24, "#c98a52", t1) c:put(33, 23, "#c98a52", t2) c:put(32, 23, "#e8b982", t2)
A.sep(c, m1, m2, MALLOW[1], t1) A.sep(c, m3, m2, MALLOW[1], t3)
-- cocoa shadow under the mallows
for x = 24, 37 do if rimI:has(x, 25) and not (m1:has(x, 25) or m2:has(x, 25) or m3:has(x, 25)) and (m1:has(x, 24) or m2:has(x, 24) or m3:has(x, 24)) then c:put(x, 25, COCOA[1], ctok) end end

-- quirk: melting marshmallow dribble over the rim (right) and down the mug
local drip = { { 37, 25 }, { 38, 25 }, { 37, 26 }, { 38, 26 }, { 38, 27 }, { 38, 28 }, { 39, 28 }, { 38, 29 }, { 39, 29 }, { 38, 30 }, { 39, 30 },
  { 38, 31 }, { 39, 31 }, { 38, 32 } }
local dtok = { r = { name = "drip" } }
for _, q in ipairs(drip) do c:put(q[1], q[2], q[1] == 39 and MALLOW[2] or MALLOW[3], dtok) end
c:put(37, 25, MALLOW[4], dtok) c:put(38, 27, MALLOW[4], dtok)
c:put(38, 33, MUG[1], btok) c:put(39, 32, MUG[1], btok)  -- contact shadow under the drop

-- steam curls
local stok = { r = { name = "steam" } }
local function curl(x0, ya, yb, ph)
  for y = ya, yb do
    local x = floor(x0 + 1.6 * sin(y * 0.75 + ph) + .5)
    c:put(x, y, STEAM[2], stok) c:put(x + 1, y, STEAM[1], stok)
    if y == ya then c:put(x, y, STEAM[3], stok) end
  end
end
curl(25, 8, 16, 0) curl(35, 10, 16, 0)

A.save(c, NAME)
