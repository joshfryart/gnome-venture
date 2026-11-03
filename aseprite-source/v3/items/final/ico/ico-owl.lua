-- ico-owl (final, Opus). A slim upright tawny owl perched on a cut branch: egg body, two ear tufts, heart-shaped
-- pale facial disc with a dark ruff rim, big gold eyes, small hooked beak, folded wings with scalloped coverts and
-- barred primaries, cream breast with brown chevrons, gold toes with ink claws gripping the branch.
-- Material: per-pixel lit 6-tone feathers, scallop feather rows, branch with grain dashes, a pale ringed end grain
-- and a twig with a veined leaf; AO under the face disc, where wings meet the body and a contact shadow under the feet.
-- quirk: the owl is giving you a slow wink with its right eye.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, sin, cos, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.sqrt
local c = A.new("ico-owl")
local FE   = { "#2f1a26", "#4c2c26", "#6e412c", "#925a35", "#b67a45", "#d7a262" }
local WG   = { "#28161f", "#3f2422", "#5c3527", "#7b4a2f", "#9c653b", "#bd8650" }
local BUFF = { "#9a7052", "#c09670", "#dcb98c", "#efd6a8", "#fbecc8" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffd45a", "#ffeb9a" }
local WOOD = { "#3e2524", "#5a3529", "#7d4c33", "#a06a44", "#c08b5a", "#ddb07a" }
local LEAF = { "#1e4a3e", "#2e6c48", "#45914f", "#6eb45a", "#a6d478" }
local ftok, wtok, btok, gtok, otok = A.tok("fe"), A.tok("wing"), A.tok("buff"), A.tok("gold"), A.tok("wood")

-- branch (behind the feet)
local bp = { { 13, 52 }, { 25, 51.2 }, { 40, 52.6 }, { 52, 50.6 } }
local brm, brn, BT, BS = G.tube(bp, function(t) return 2.3 - t * 0.5 end)
-- twig to the upper right with a leaf
local tw, twn = G.tube({ { 44, 51.5 }, { 48, 49 }, { 51, 47 }, { 54, 44.5 } }, function(t) return 1.2 - t * 0.5 end)
A.shade(c, tw, twn, WOOD, { tok = otok })
local lm, ln, LT, LS = G.blade(54, 44.5, 57.5, 39.5, 55.5, 36.5, function(t) return 2.6 * sin(math.pi * t) ^ 0.8 end, {})
local lidx = A.shade(c, lm, ln, LEAF, { tok = A.tok("leaf") })
lm:each(function(x, y) local k = K(x, y) if abs(LS[k]) < 0.18 and LT[k] < 0.85 then c:put(x, y, LEAF[2], A.tok("leaf")) end end)
local bb = {}
local bidx = A.shade(c, brm, brn, WOOD, { tok = otok, bias = bb })
-- grain dashes
for _, g in ipairs{ { 17, 52, 4 }, { 24, 53, 3 }, { 31, 51, 5 }, { 39, 53, 4 }, { 45, 51, 3 } } do
  for x = g[1], g[1] + g[3] - 1 do if brm:has(x, g[2]) then A.step(c, bidx, WOOD, x, g[2], -2, otok) end end
end
-- cut end grain on the left: pale rings
A.map(c, { ".hh.", "hdhh", "hhdh", "hdhh", ".hh." }, 11, 50, { h = WOOD[6], d = WOOD[4] }, otok)

-- ear tufts
local tufts = HP.mask()
tufts:add(c:poly{ { 20, 23 }, { 21, 12 }, { 28, 19 } })
tufts:add(c:poly{ { 44, 23 }, { 43, 12 }, { 36, 19 } })
local tn = X.pillow(tufts, 2)
A.shade(c, tufts, tn, FE, { tok = ftok })
-- body
local body, bn = G.oval(32, 34, 12.6, 15.6, 0)
local bbias = {}
local bodyIdx = A.shade(c, body, bn, FE, { tok = ftok, bias = bbias, amb = 0.08 })
-- tuft separation from head
tufts:each(function(x, y) if body:has(x, y + 1) and not body:has(x, y) then c:put(x, y, FE[3], ftok) end end)
-- scallop feather rows on head / back (small u-arcs)
body:each(function(x, y)
  local row = floor((y - 18) / 3)
  local xx = (x + (row % 2) * 2) % 4
  if (y - 18) % 3 == 2 and xx == 0 then A.step(c, bodyIdx, FE, x, y, -1, ftok) end
end)
-- wings
local wings = HP.mask()
local wingIdx = {}
for _, w in ipairs{ { 22.5, 38.5, 0.2 }, { 41.5, 38.5, -0.2 } } do
  local m, n = G.oval(w[1], w[2], 4.6, 10.6, w[3])
  local wb = {}
  local idx = A.shade(c, m, n, WG, { tok = wtok, bias = wb, amb = 0.1 })
  for k, v in pairs(idx) do wingIdx[k] = v end
  wings:add(m)
  -- scalloped coverts: arcs in the upper half
  m:each(function(x, y)
    local row = floor((y - 28) / 3)
    local xx = (x + row) % 3
    if y < 41 and (y - 28) % 3 == 2 and xx ~= 1 then A.step(c, wingIdx, WG, x, y, -1, wtok) end
    if y < 41 and (y - 28) % 3 == 0 and xx == 1 then A.step(c, wingIdx, WG, x, y, 1, wtok) end
  end)
  -- barred primaries: pale bars across the lower wing
  for _, by in ipairs{ 43, 46 } do
    m:each(function(x, y) if y == by then A.step(c, wingIdx, WG, x, y, 2, wtok) end end)
  end
  -- inner edge where the wing meets the body: dark line
  m:edge():each(function(x, y)
    local inner = (w[1] < 32) and m:has(x - 1, y) == false and false or nil
    if (w[1] < 32 and not m:has(x + 1, y) and body:has(x + 1, y)) or (w[1] > 32 and not m:has(x - 1, y) and body:has(x - 1, y)) then
      c:put(x, y, WG[1], wtok)
    end
  end)
end
-- breast
local br, brN = G.oval(32, 41, 7.6, 8.6, 0)
br:cut(wings)
local brIdx = A.shade(c, br, brN, BUFF, { tok = btok })
for _, p in ipairs{ { 29, 36 }, { 35, 36 }, { 32, 39 }, { 28, 41 }, { 36, 41 }, { 32, 44 }, { 29, 46 }, { 35, 46 } } do
  if br:has(p[1], p[2]) then
    c:put(p[1] - 1, p[2], FE[4], ftok) c:put(p[1], p[2] + 1, FE[3], ftok) c:put(p[1] + 1, p[2], FE[4], ftok)
  end
end
-- facial disc: heart shape (two lobes), dark ruff rim, AO line under it
local disc = HP.mask()
disc:add(c:ellipse(26.5, 25.5, 6, 5.5)):add(c:ellipse(37.5, 25.5, 6, 5.5))
disc:add(c:poly{ { 26, 29 }, { 38, 29 }, { 32, 34 } })
local dn = X.pillow(disc, 2.5)
local dIdx = A.shade(c, disc, dn, BUFF, { tok = btok, cuts = { 0.12, 0.3, 0.52, 0.74 } })
disc:edge():each(function(x, y) c:put(x, y, FE[2], ftok) end)
-- centre ridge between the lobes
for y = 20, 22 do c:put(31, y, FE[3], ftok) c:put(32, y, FE[3], ftok) end
-- AO under the disc on the breast
disc:shift(0, 1):each(function(x, y) if not disc:has(x, y) and br:has(x, y) then c:put(x, y, BUFF[2], btok) end end)
-- left eye: gold iris, ink pupil, glint
local eye = c:ellipse(26.5, 25.5, 3.6, 3.6)
local en = X.sphere(26, 25, 3.6, eye)
A.shade(c, eye, en, GOLD, { tok = gtok })
eye:edge():each(function(x, y) c:put(x, y, GOLD[1], gtok) end)
c:fillMask(c:ellipse(26.5, 25.5, 1.8, 1.8), A.INK)
c:put(25, 24, A.CREAM) c:put(26, 24, A.CREAM) c:put(25, 25, A.CREAM)
-- right eye: the wink (closed lid arc + lash)
A.map(c, {
  "..kkkk..",
  ".k....k.",
  "k......k",
}, 34, 24, { k = A.INK })
c:put(41, 23, A.INK)
c:put(36, 27, BUFF[5], btok) c:put(37, 27, BUFF[5], btok)
-- beak: hooked, gold
A.map(c, {
  "hGG",
  "GGg",
  ".gd",
  ".d.",
}, 31, 28, { h = GOLD[5], G = GOLD[3], g = GOLD[2], d = GOLD[1] }, gtok)
-- feet: gold toes with ink claws over the branch
for _, fx in ipairs{ 27, 34 } do
  A.map(c, {
    "GGgGG",
    "GgGgg",
    "k.k.k",
  }, fx, 49, { G = GOLD[4], g = GOLD[2], k = A.INK }, gtok)
  -- contact shadow on the branch below the toes
  for x = fx, fx + 4 do if brm:has(x, 52) then c:put(x, 52, WOOD[2], otok) end end
end
-- body underside AO on the branch
for x = 22, 42 do if brm:has(x, 50) and not body:has(x, 50) then c:put(x, 50, WOOD[1], otok) end end
-- body sparkle on the head crown
c:put(27, 17, FE[6], ftok) c:put(28, 17, FE[6], ftok)
A.save(c, "ico-owl")
