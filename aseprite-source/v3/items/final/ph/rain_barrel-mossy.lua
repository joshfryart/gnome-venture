-- rain_barrel-mossy (artist pass aD11_2). An old bleached cask gone green: moss cushions lit by the same staves they sit on, rusty
-- hoops (the lower one slipped crooked), a cracked stave, drips of moss over the lip, murky pond water with lily pads, ivy climbing the
-- left side, two toadstools at the foot, and a rotten plank lid propped against the right flank.
-- Material: moss is painted per pixel from the stave light so it follows the barrel curve, with lit upper lips and shaded lower lips;
-- rust hoops with pitted rivets; ivy leaves with midribs; frog with a belly, eyes, mouth line; toadstool caps with spots.
-- quirk: the frog on the rim is wearing a lily pad as a hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_2.lua")
local G, X, K = A.G, A.X, A.K
local c = A.new("rain_barrel-mossy")
local cx, yt = 32, 27
local MO = A.MOSS
local RUST = { "#3a1c2a", "#62283a", "#8c3e3c", "#b8583a", "#dc7c44", "#f4a85c" }
local FROG = { "#2a5a2a", "#4a8a30", "#7cc040", "#a8dc50", "#d0f070", "#f4ffb0" }
local clamp = function(v, a, b) return math.max(a, math.min(b, v)) end
local function vn(x, y, s)
  local xi, yi = math.floor(x), math.floor(y)
  local fx, fy = x - xi, y - yi
  fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
  local a, b, c2, d = X.hash(xi, yi, s), X.hash(xi + 1, yi, s), X.hash(xi, yi + 1, s), X.hash(xi + 1, yi + 1, s)
  return (a + (b - a) * fx) + ((c2 + (d - c2) * fx) - (a + (b - a) * fx)) * fy
end
c:groundShadow(cx, 56, 15, 2)
-- leaning plank lid (behind the barrel, right side)
do
  local lm = A.ell(cx + 16, 41, 5, 12, -.28)
  A.lit(c, lm, A.OLD, 2.4, { amb = .1 })
  lm:each(function(x, y)
    if (x == cx + 15 or x == cx + 18) and X.hash(x, y, 3) > .15 then c:px(x, y, A.OLD[2]) end
    if X.hash(x, y, 17) > .93 then c:px(x, y, A.OLD[2]) end
  end)
  for _, p in ipairs{ {cx + 15, 36}, {cx + 15, 38}, {cx + 16, 37} } do c:px(p[1], p[2], A.OLD[1]) end     -- rot hole
  c:px(cx + 14, 33, A.IRON[4]) c:px(cx + 17, 33, A.IRON[4]) c:px(cx + 13, 49, A.IRON[4])                  -- nails
  lm:each(function(x, y) if y < 36 and X.hash(x, y, 9) > .35 + (y - 30) * .06 then c:px(x, y, MO[(X.hash(x, y, 2) > .5) and 5 or 4]) end end)
end
local b = A.cask(c, { cx = cx, yt = yt, yb = 51, wt = 7.5, wb = 6.5, bulge = 3, ry = 6, ryb = 3, nst = 7, lv = 2, ripple = .5,
  wood = A.OLD, water = A.POND, knot = { cx - 3, 44 },
  hoops = { { y = 31, ramp = RUST, rivets = { -5, 2, 6 }, rivetC = RUST[6] },
            { y = 41, ramp = RUST, tilt = .16, rivets = { -5, 1, 5 }, rivetC = RUST[6] } },
  bodyFx = function(c, body, idx, hw, tok)
    local mset = {}
    body:each(function(x, y)
      local w = hw(math.min(y, 51)) + .5
      local u = (x - cx) / w
      local f = vn(x / 3.2, y / 3.2, 5) * .62 + ((y - yt) / 24) * .5 + (u > 0 and u * .12 or 0)
      if y > yt + 3 and f > .88 and X.hash(x, y, 6) > .12 then mset[K(x, y)] = true end
    end)
    for k in pairs(mset) do
      local x, y = k % 1024 - 256, k // 1024 - 256
      local i = idx[k] or 3
      if not mset[K(x, y - 1)] then i = i + 1 end
      if not mset[K(x, y + 1)] then i = i - 1 end
      i = i + ((X.hash(x, y, 8) > .85) and 1 or 0)
      c:put(x, y, MO[clamp(i + 0, 1, 6)], tok)
    end
    -- cracked stave
    for _, p in ipairs{ {cx + 4, 33}, {cx + 4, 34}, {cx + 5, 35}, {cx + 5, 36}, {cx + 4, 37}, {cx + 4, 38}, {cx + 4, 39} } do
      if not mset[K(p[1], p[2])] then c:put(p[1], p[2], A.OLD[1], tok) if not mset[K(p[1] - 1, p[2])] then c:put(p[1] - 1, p[2], A.OLD[5], tok) end end
    end
  end })
-- moss on the end-grain rim + drips over the front lip
b.rim:copy():cut(b.inner):each(function(x, y)
  if X.hash(x, y, 33) > .5 and y > yt - 5 then c:px(x, y, MO[(X.hash(x, y, 34) > .5) and 4 or 3]) end
end)
for _, x in ipairs{ cx - 8, cx - 6, cx - 2, cx + 1, cx + 5, cx + 8 } do
  local ly = yt + math.floor(6 * math.sqrt(1 - ((x - cx) / 9) ^ 2) + .5) + 1
  local len = 1 + math.floor(X.hash(x, 1, 3) * 4)
  for q = 0, len do c:px(x, ly + q, MO[(q == len) and 2 or ((q == 0) and 5 or 4)]) end
  c:px(x + 1, ly, MO[3])
end
-- lily pads on the pond
local function pad(px, py, rx, ry, notch)
  local m = A.ell(px, py, rx, ry, 0)
  A.lit(c, m, MO, 1.2, { amb = .1 })
  c:px(px + 1, py, A.POND[1]) c:px(px + 2, py, A.POND[1]) c:px(px + 3, py - (notch or 0), A.POND[2])
  c:px(px - 1, py - 1, MO[6])
end
pad(cx + 3, yt + 1, 3, 1)
for _, p in ipairs{ {cx - 4, yt + 3}, {cx + 6, yt + 3}, {cx - 1, yt + 4}, {cx + 2, yt + 3} } do c:px(p[1], p[2], MO[5]) end
-- ivy from the foot to the rim on the left
local vine = { {cx - 14, 56}, {cx - 12, 51}, {cx - 13, 45}, {cx - 11, 39}, {cx - 12, 33}, {cx - 10, 29} }
for i = 1, #vine - 1 do A.ln(c, vine[i][1], vine[i][2], vine[i + 1][1], vine[i + 1][2], MO[2]) end
local leaves = { {cx - 14, 52, 0}, {cx - 11, 46, 1}, {cx - 13, 40, 0}, {cx - 10, 34, 1}, {cx - 12, 29, 0} }
for _, L in ipairs(leaves) do
  local lm = A.ell(L[1], L[2], 2.3, 1.7, (L[3] == 0) and -.6 or .6)
  A.lit(c, lm, MO, 1.6, { amb = .12 })
  A.ln(c, L[1] - 1, L[2] + (L[3] == 0 and 1 or -1), L[1] + 1, L[2] + (L[3] == 0 and -1 or 1), MO[2], lm)
  c:px(L[1] - 1, L[2] - 1, MO[6])
end
-- toadstools at the foot
local function toad(tx, ty, r)
  local cap = A.ell(tx, ty - 2, r, r * .7, 0)
  c:fillMask(c:rect(tx - 1, ty - 1, tx, ty + 1), A.OLD[5]) c:px(tx - 1, ty - 1, A.CREAM) c:px(tx, ty + 1, A.OLD[3])
  A.lit(c, cap, A.RED, r * .8, { amb = .1 })
  c:px(tx - 1, ty - 3, A.CREAM) c:px(tx + 1, ty - 2, A.CREAM)
end
toad(cx - 8, 57, 4) toad(cx + 9, 58, 3)
-- frog on the rim wearing a lily-pad hat
local fx, fy = cx - 6, 20
A.lit(c, A.ell(fx, fy, 5, 3.4, 0), FROG, 2.4, { amb = .1 })
c:fillMask(c:rect(fx - 2, fy + 2, fx + 2, fy + 2), FROG[5])                       -- pale belly peeking
A.lit(c, c:ellipse(fx - 3, fy - 3, 1, 1), FROG, 1.4) A.lit(c, c:ellipse(fx + 3, fy - 3, 1, 1), FROG, 1.4)
c:px(fx - 3, fy - 3, A.INK) c:px(fx + 3, fy - 3, A.INK) c:px(fx - 4, fy - 4, A.CREAM) c:px(fx + 2, fy - 4, A.CREAM)
for x = fx - 3, fx + 3 do c:px(x, fy, FROG[1]) end                                -- wide mouth line
c:px(fx - 1, fy - 1, FROG[1]) c:px(fx + 1, fy - 1, FROG[1])                        -- nostril pair
c:px(fx - 5, fy + 3, FROG[3]) c:px(fx - 6, fy + 3, FROG[2]) c:px(fx + 5, fy + 3, FROG[2]) c:px(fx + 6, fy + 3, FROG[1])  -- feet
local hat = A.ell(fx, fy - 6, 3, 1.2, .1)
A.lit(c, hat, A.POND, 1.2, { amb = .1 })
c:px(fx + 1, fy - 6, A.POND[1]) c:px(fx + 2, fy - 6, A.POND[1]) c:px(fx - 2, fy - 6, A.POND[5])
A.fin(c, "rain_barrel-mossy")
