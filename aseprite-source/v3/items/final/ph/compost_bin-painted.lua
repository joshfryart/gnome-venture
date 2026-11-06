-- compost_bin-painted (final, Opus single pass). A lidded compost box on four slim legs, built of upright boards painted
-- in alternating rose, mint and butter (bevelled, grain showing through, chipped corners revealing bare wood), cream
-- trim rails, a hand-painted daisy on the front. The lid stands open on two iron hinges: we see its bare-wood inside with
-- a Z batten; a dome of compost peeks over the rim. AO under the rim and where the lid meets the heap.
-- quirk: a fresh drip of rose paint has run down a board, over the bottom rail, and hangs as a bead.
local NAME = "compost_bin-painted"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)
local WOOD = { "#3e2622", "#5c3a2a", "#7f5434", "#a47244", "#c99a64", "#e8c28e" }
local ROSE = { "#6e2840", "#a23d5e", "#d0587a", "#ee7f9a", "#ffa8bc", "#ffd0dc" }
local MINT = { "#1f4a56", "#2c7174", "#3f9c92", "#5fc4b0", "#94e0c8", "#c8f4e2" }
local BUTR = { "#6a4422", "#a0702e", "#d0a03e", "#f0c654", "#ffe08a", "#fff2c0" }
local TRIM = { "#5a4240", "#8f7a6a", "#c2ae92", "#e2d2b0", "#f4e8cc", "#fff8e4" }
local SOIL = { "#1c1216", "#2e1d1d", "#452a22", "#5e3b29", "#7a5034", "#986842" }
local IRON = { "#2a2a3a", "#444663", "#74758c", "#aaa9b8" }

c:groundShadow(32, 55, 23, 2)

-- open lid (inside face, bare wood, three planks + Z batten)
local lid = A.rect(15, 5, 48, 23)
local ltok = { r = { name = "lid" } }
for i, y0 in ipairs{ 5, 11, 17 } do
  local m = A.rect(15, y0, 48, min(23, y0 + 5))
  A.plank(c, m, WOOD, { R = 1.2, seed = 40 + i, tok = ltok, cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 } })
end
-- painted edge of the lid (rose band on the left and top edges = outside paint wrapping round)
for y = 5, 23 do c:put(15, y, ROSE[3], ltok) end
for x = 15, 48 do c:put(x, 5, ROSE[4], ltok) end
c:put(15, 5, ROSE[5], ltok)
-- Z batten: top bar, bottom bar, diagonal
local bat = A.rect(18, 7, 45, 9):add(A.rect(18, 19, 45, 21)):add(c:line({ { 43, 9 }, { 20, 19 } }, 3))
A.plank(c, bat, WOOD, { R = 1.0, seed = 47, grain = false, tok = { r = { name = "batten" } }, cuts = { 0.08, 0.16, 0.3, 0.5, 0.75 } })
bat:edge():each(function(x, y) if not bat:has(x + 1, y + 1) then c:put(x, y, WOOD[2], { r = { name = "batten" } }) end end)
for _, p in ipairs{ {19, 8}, {44, 8}, {19, 20}, {44, 20} } do c:put(p[1], p[2], IRON[2], ltok) end

-- compost dome peeking over the rim
local heap = A.poly{ {13, 27}, {15, 22}, {20, 19}, {27, 17.5}, {35, 17.5}, {43, 19}, {48, 22}, {50, 27} }
local hb = {}
A.bumpy(c, heap, SOIL, { R = 3, rough = 1.1, seed = 13, bias = hb, name = "heap" })
c:paint({ "ab", "bc" }, 21, 21, { a = "#9dd06c", b = "#3f9150", c = "#24544a" })
c:paint({ "aa", "b." }, 38, 20, { a = "#fff4d6", b = "#d6c8a6" })
c:paint({ "ab" }, 30, 19, { a = "#ffb050", b = "#d04b25" })

-- hinges on the lid foot
for _, hx in ipairs{ 19, 42 } do
  c:paint({ "abba", "cddc" }, hx, 23, { a = IRON[3], b = IRON[4], c = IRON[1], d = IRON[2] })
end

-- upright painted boards
local paints = { ROSE, MINT, BUTR, ROSE, MINT, BUTR, ROSE, MINT }
local boards = {}
for i = 1, 8 do
  local x0 = 12 + (i - 1) * 5
  local m = A.rect(x0, 28, x0 + 4, 49)
  boards[i] = m
  local b = {}
  for x = x0, x0 + 4 do local k = K(x, 28) b[k] = -1 local k2 = K(x, 29) b[k2] = -1 end  -- AO under the top rail
  A.plank(c, m, paints[i], { R = 1.3, dir = "v", seed = 60 + i, bias = b, name = "board" .. i })
end
-- chipped paint: bare wood showing on edges
for _, p in ipairs{ {12, 41, 2}, {16, 33, 1}, {27, 46, 2}, {36, 31, 1}, {46, 44, 2}, {51, 36, 1}, {41, 47, 1} } do
  for j = 0, p[3] - 1 do c:put(p[1], p[2] + j, j == 0 and WOOD[5] or WOOD[4]) end
end

-- trim rails (cream), top rail slightly wider
local top = A.rect(11, 25, 52, 27)
A.plank(c, top, TRIM, { R = 1.2, seed = 71, name = "toprail" })
for x = 11, 52 do c:put(x, 25, TRIM[6], { r = { name = "toprail" } }) end
local bot = A.rect(11, 49, 52, 51)
A.plank(c, bot, TRIM, { R = 1.2, seed = 72, name = "botrail" })

-- legs
for _, lx in ipairs{ 13, 48 } do
  local m = A.rect(lx, 52, lx + 2, 55)
  A.plank(c, m, TRIM, { R = 1, dir = "v", seed = lx, grain = false, name = "leg" .. lx })
  c:put(lx, 52, TRIM[2]) c:put(lx + 1, 52, TRIM[2]) c:put(lx + 2, 52, TRIM[1])
end

-- painted daisy on the front (flat paint, hand-made)
local cx, cy = 32, 38
local petal = { "#fff4d6", "#f0dcb4", "#c9b08e" }
local pm = HP.mask()
for a = 0, 7 do
  local ang = a * math.pi / 4 + 0.2
  local ux, uy = math.cos(ang), math.sin(ang)
  pm:add(A.rell(cx + ux * 4, cy + uy * 4, ux, uy, 2.6, 1.25))
end
local pe = pm:edge()
pm:each(function(x, y)
  local t = petal[1]
  if pe:has(x, y) and (x - cx) + (y - cy) > 1 then t = petal[2] end
  if pe:has(x, y) and (x - cx) + (y - cy) > 6 then t = petal[3] end
  c:put(x, y, t)
end)
c:paint({ ".ab.", "abbc", "bbcd", ".cd." }, cx - 2, cy - 2, { a = "#ffe38a", b = "#f5b82e", c = "#d98322", d = "#8f4a1f" })
c:put(cx - 1, cy - 1, "#fff2c0")
-- leaf strokes
c:paint({ "..ab", ".ab.", "ab.." }, cx + 4, cy + 5, { a = "#3f9150", b = "#7cc35a" })

-- quirk: paint drip down a mint board (2), over the bottom rail, bead hanging below
local dtok = { r = { name = "drip" } }
for y = 42, 51 do c:put(19, y, (y < 49) and ROSE[5] or ROSE[4], dtok) end
c:put(20, 50, ROSE[3], dtok) c:put(20, 51, ROSE[3], dtok)
c:paint({ "ab", "bc", "cd" }, 19, 52, { a = ROSE[6], b = ROSE[4], c = ROSE[3], d = ROSE[2] })

A.save(c, NAME)
