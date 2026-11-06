-- garden-vegetable-soup (final pass, Opus single pass). A shallow glazed blue stoneware bowl on a small unglazed foot,
-- brimming with tomato-vegetable broth: carrot coins, peas, a potato cube, celery slices and a parsley leaf; a slim
-- wooden spoon leans out to the right.
-- Material: bowl = per-pixel sphere light on a 6-tone cobalt glaze, cream painted band, glossy rim with one specular,
-- cool bounce lower-right, dark inner wall where it meets the broth (AO); broth = 6-tone warm orange with oil glints;
-- spoon = wood grain + pale end; ground shadow (it stands).
-- quirk (food): a curl of steam rises from the broth in a little spiral.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("garden-vegetable-soup")
local GLAZE = { "#1f2457", "#2d3c88", "#3f5cb6", "#5b84d6", "#8db4ec", "#d0e6fb" }
local INNER = { "#7c6a84", "#a898a6", "#d8c8bc", "#f2e6d2" }
local BROTH = { "#6e2234", "#a8382e", "#d45a2a", "#ef8235", "#fbab4c", "#ffd88a" }
local CAR   = { "#a83a22", "#e2672a", "#ff9b44", "#ffcf7a" }
local PEA   = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#d69b62", "#e8b982", "#f6d8ae" }
local FOOT  = { "#5e3a2e", "#8a5638", "#b57850", "#d9a070" }
local CX, CY = 31.5, 31

c:groundShadow(32, 53, 13, 1.5)
-- foot ring (unglazed clay)
local foot = HP.rrect(22, 47, 41, 51, 1)
local ftok = { r = { name = "foot" } }
do local fn = {} foot:each(function(x, y) local s = max(-0.95, min(0.95, (x - CX) / 10.5)) fn[K(x, y)] = { s, 0.2, sqrt(1 - s * s) } end)
  A.shade(c, foot, fn, FOOT, { tok = ftok, cuts = { 0.3, 0.55, 0.8 } }) end
for x = 22, 41 do c:put(x, 47, FOOT[1], ftok) end -- AO under the bowl

-- bowl body: lower half of a wide ellipse
local bowl = HP.ellipse(CX, CY, 22, 17)
bowl:clip(HP.rect(0, CY, 63, 63))
local btok = { r = { name = "bowl" } }
local bn = A.body(bowl, CX - 2, CY - 6, 23, 4, 0.7)
local bbias = {}
local bidx = A.shade(c, bowl, bn, GLAZE, { tok = btok, amb = 0.08, wrap = 0.3, bias = bbias })
-- painted cream band following the curve, with petal dots
bowl:each(function(x, y)
  local u = (x - CX) / 22
  local yb = CY + 5 + floor(2.2 * (1 - u * u) + 0.5)
  if y == yb or y == yb + 1 then
    local i = bidx[K(x, y)] or 3
    c:put(x, y, i >= 4 and INNER[4] or (i >= 3 and INNER[3] or INNER[2]), btok)
  end
end)
for _, dx in ipairs{ -15, -9, -3, 3, 9, 15 } do
  local x = floor(CX + dx) local u = dx / 22 local y = CY + 9 + floor(2.6 * (1 - u * u) + 0.5)
  c:put(x, y, dx < 4 and "#f5809f" or "#c94f84", btok) c:put(x + 1, y, dx < 4 and "#c94f84" or "#7d2c5e", btok)
end
-- cool bounce on the shade side
local rim = X.rim(bn)
bowl:edge():each(function(x, y) if rim[K(x, y)] > 0.55 and x > CX + 8 and y > CY + 4 then c:put(x, y, "#5f9ad0", btok) end end)
-- glossy glaze: specular streak on the upper-left belly
for _, p in ipairs{ { 14, 36 }, { 15, 37 }, { 16, 38 }, { 17, 39 } } do c:put(p[1], p[2], GLAZE[6], btok) end
c:put(14, 35, A.CREAM)

-- rim ring (top of the bowl wall) + inner wall + broth
local rimO = HP.ellipse(CX, CY, 22, 6)
local rimI = HP.ellipse(CX, CY + 0.5, 19.5, 4.5)
local ring = rimO:copy():cut(rimI)
local rtok = { r = { name = "rim" } }
ring:each(function(x, y)
  local front = y >= CY
  local lit = (x < CX - 6 and y <= CY + 1) or (y < CY - 3)
  c:put(x, y, front and (x < CX and GLAZE[5] or GLAZE[4]) or (lit and GLAZE[6] or GLAZE[5]), rtok)
end)
-- rim lip: the outer edge row on the front reads darker (thickness)
rimO:edge():each(function(x, y) if y > CY + 2 then c:put(x, y, GLAZE[3], rtok) end end)
-- inner wall (far side, above the broth): pale glaze in shadow
local itok = { r = { name = "inner" } }
local broth = HP.ellipse(CX, CY + 1.5, 18.5, 3.5)
rimI:each(function(x, y) if not broth:has(x, y) then c:put(x, y, y < CY - 2 and INNER[2] or INNER[1], itok) end end)
-- broth surface: flat-ish, lit from upper-left; darker toward the far wall (AO)
local stok = { r = { name = "broth" } }
broth:each(function(x, y)
  local d = (x - CX) / 18.5 + (y - CY - 1.5) / 3.5 * 0.6
  local i = d < -0.55 and 5 or (d < 0.1 and 4 or (d < 0.6 and 3 or 2))
  if y <= CY - 1 then i = i - 1 end
  c:put(x, y, BROTH[max(1, i)], stok)
end)
broth:edge():each(function(x, y) if y <= CY + 1 then c:put(x, y, BROTH[1], stok) end end)

-- vegetables floating in the broth
local function coin(x, y)
  c:put(x, y, CAR[3]) c:put(x + 1, y, CAR[2]) c:put(x + 2, y, CAR[2])
  c:put(x, y + 1, CAR[2]) c:put(x + 1, y + 1, CAR[4]) c:put(x + 2, y + 1, CAR[1])
end
coin(18, 31) coin(30, 33) coin(38, 30)
for _, p in ipairs{ { 24, 30 }, { 35, 32 }, { 43, 32 }, { 27, 34 } } do
  c:put(p[1], p[2], PEA[4]) c:put(p[1] + 1, p[2], PEA[3]) c:put(p[1], p[2] + 1, PEA[3]) c:put(p[1] + 1, p[2] + 1, PEA[1]) end
-- potato cube
c:put(22, 32, "#fff1c4") c:put(23, 32, "#f2d38a") c:put(22, 33, "#e8c070") c:put(23, 33, "#b98a4a")
-- celery crescents
c:put(33, 29, "#c4e07a") c:put(34, 29, "#9dd06c") c:put(35, 30, "#6ab455")
c:put(14, 33, "#c4e07a") c:put(15, 33, "#6ab455")
-- parsley leaf
c:put(27, 29, "#7cc35a") c:put(28, 29, "#3f9150") c:put(28, 28, "#c4e07a") c:put(29, 30, "#24544a")
-- oil glints
c:put(20, 34, BROTH[6]) c:put(41, 34, BROTH[6]) c:put(25, 35, BROTH[6])

-- wooden spoon leaning out to the right (bowl of the spoon is under the broth)
local sm, sn, sT, sS, sidx = A.stem(c, { { 40, 32 }, { 44, 26 }, { 48, 19 }, { 51, 12 } },
  function(t) if t > 0.9 then return 1.3 + (t - 0.9) * 6 end return 1.3 end, WOOD, { amb = 0.12, wrap = 0.3, tok = { r = { name = "spoon" } } })
sm:each(function(x, y) local k = K(x, y)
  if sT[k] > 0.15 and sT[k] < 0.92 and abs(sS[k]) < 0.35 and floor(sT[k] * 30) % 4 == 1 then c:put(x, y, WOOD[2]) end
end)
c:put(51, 11, WOOD[6]) c:put(52, 11, WOOD[5]) -- pale end grain
-- AO where the spoon enters the broth
c:put(40, 32, BROTH[1]) c:put(41, 32, BROTH[1]) c:put(40, 33, BROTH[2])

-- quirk: a spiral curl of steam
local STEAM = { "#d9e8f2", "#ffffff" }
local steam = {
  "..aa..",
  ".a..a.",
  ".a.ba.",
  "..ab..",
  "...a..",
  "..a...",
  ".a....",
  ".a....",
  "..a...",
}
local pal = { a = "#e4f6ff", b = "#a9c6e0" }
A.map(c, steam, 22, 15, pal)
A.map(c, { "a", "a" }, 23, 15, { a = "#fff4d6" })
A.save(c, "garden-vegetable-soup")
