-- ico-id-card (final, Opus). A gnome ID badge on a lanyard: landscape laminated card (rounded bevel, 2 px plastic
-- edge on the bottom and right, glossy laminate glare streaks), teal header band with a punched slot, a steel clip
-- (bevel, bright edge, dark rivet) through the slot and a short woven ribbon strap (diagonal weave). Left: a framed
-- portrait of a gnome (red hat, rounded lit nose with a dark underside, cheeks, cream beard, green tunic) on a sky
-- backdrop with a signature squiggle under it. Right: a bold name bar, two text lines and a holographic oval seal
-- (banded sheen). AO under the header and the clip; contact shadow under the photo.
-- quirk: the gnome's hat is too tall for the photo and pokes out over the frame into the header.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-id-card")
local CRD = { "#7e6e6a", "#ab9c92", "#d2c6b6", "#e8e0d0", "#f6f0e2", "#fffaee" }
local TEA = { "#1c3e5a", "#245c78", "#2f7e98", "#43a0b0", "#6cc4c8", "#a8e6e0" }
local STL = { "#444663", "#74758c", "#aaa9b8", "#cfcfda", "#eeeef4" }
local RIB = { "#35295f", "#5a459e", "#7a62c6", "#9c86e0" }
local ctok, htok, mtok, rtok, ptok = A.tok("card"), A.tok("header"), A.tok("clip"), A.tok("ribbon"), A.tok("photo")

-- card body
local card = HP.rrect(8, 24, 55, 52, 3)
local cidx = A.pill(c, card, 2.5, CRD, { tok = ctok, amb = 0.15, wrap = 0.4, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- header band (teal) on the top of the card
local head = card:copy():clip(HP.rect(0, 24, 63, 29))
local hidx = A.pill(c, head, 2.5, TEA, { tok = htok, amb = 0.15, wrap = 0.4, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
head:each(function(x, y) if (x + y) % 19 == 0 or (x + y) % 19 == 1 and x < 50 then A.step(c, hidx, TEA, x, y, 1, htok) end end)
for x = 9, 54 do if card:has(x, 30) then A.step(c, cidx, CRD, x, 30, -1, ctok) end end
-- plastic edge: 2 px thickness on the bottom and right
card:each(function(x, y)
  if not card:has(x, y + 1) or not card:has(x, y + 2) and y > 40 then c:put(x, y, card:has(x, y + 1) and CRD[3] or CRD[1], ctok) end
  if not card:has(x + 1, y) and y > 29 then c:put(x, y, CRD[2], ctok) end
end)
-- punched slot (left transparent: becomes an ink hole)
for y = 26, 27 do for x = 27, 36 do c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end

-- portrait (origin 12,26; frame 16x15 from row 5; hat pokes out above)
local SK = { "#c98462", "#f0b98d", "#ffe0bd" }
A.map(c, {
  "..........H.....",
  ".........HR.....",
  "........HRR.....",
  ".......HRRr.....",
  "......HRRRr.....",
  "FFFFFHRRRRrrFFFF",
  "FssssHRRRRRrsssF",
  "FsssHRRRRRRrrssF",
  "FssDDDDDDDDDDssF",
  "FsssklkkkkkqsssF",
  "FssskekkkkeqsssF",
  "FssskeknnkeqsssF",
  "FssswkcNNckwsssF",
  "FsswwwwmmwwwwssF",
  "FsswWwwwwwwvvssF",
  "FssswWwwwwwvsssF",
  "FggggwWwwwvggggF",
  "FGggggwwvvgggddF",
  "FGgggggvvgggdddF",
  "FFFFFFFFFFFFFFFF",
}, 12, 26, {
  F = CRD[2], s = "#b9e2f5", H = "#ff8a5c", R = "#e8493b", r = "#b52e3f", D = "#6e2038",
  k = SK[2], l = SK[3], q = SK[1], e = "#2b1c26", n = "#f7c69c", N = "#b06a4e", c = "#f5809f",
  w = "#f2e8d8", W = "#fff4d6", v = "#c8bcb4", m = "#8a5a4e",
  g = "#3f9150", G = "#7cc35a", d = "#24544a",
}, ptok)
-- nose: lit tip pixel, sky lighter at top-left of the photo
c:put(19, 37, "#fff0dc", ptok)
for x = 13, 16 do c:put(x, 32, "#e4f6ff", ptok) end
-- contact shadow under the photo frame and signature squiggle
for x = 13, 28 do A.step(c, cidx, CRD, x, 46, -1, ctok) end
for y = 32, 45 do A.step(c, cidx, CRD, 28, y, -1, ctok) end
A.map(c, {
  ".a...a..a.....",
  "a.a.a.aa.a.aa.",
  "...a......a..a",
}, 13, 48, { a = "#5a459e" }, ctok)

-- text: name bar + two lines
for y = 33, 34 do for x = 31, 47 do c:put(x, y, y == 33 and "#444663" or "#35295f", ctok) end end
for _, L in ipairs{ { 38, 51 }, { 42, 44 } } do for x = 31, L[2] do c:put(x, L[1], STL[2], ctok) c:put(x, L[1] + 1, STL[3], ctok) end end
-- holographic seal (banded sheen)
local seal = A.ell(48, 47, 3.6, 2.8)
local HOLO = { "#c94f84", "#f5809f", "#ffe38a", "#b6f0e0", "#5fc4c8", "#8a6fd0" }
seal:each(function(x, y) c:put(x, y, HOLO[((x - y + 40) // 2) % 6 + 1], ctok) end)
seal:edge():each(function(x, y) if x > 48 or y > 48 then c:put(x, y, "#5a459e", ctok) end end)

-- woven ribbon strap and steel clip
for y = 6, 17 do for x = 29, 34 do
  local i = ((x + y) % 3 == 0) and 4 or (((x - y) % 4 == 0) and 1 or 3)
  if x == 29 then i = 4 elseif x == 34 then i = 2 end
  c:put(x, y, RIB[i], rtok) end end
local clip = HP.rrect(28, 17, 35, 22, 1):add(HP.rect(30, 22, 33, 28))
local kidx = A.pill(c, clip, 1.5, STL, { tok = mtok, amb = 0.15, wrap = 0.4, cuts = { 0.25, 0.45, 0.65, 0.84 } })
c:put(31, 19, STL[1], mtok) c:put(32, 19, STL[1], mtok) c:put(31, 20, STL[2], mtok) c:put(32, 20, STL[2], mtok)
for x = 29, 34 do c:put(x, 18, x < 32 and STL[5] or STL[4], mtok) end
for y = 22, 28 do c:put(30, y, STL[4], mtok) c:put(33, y, STL[2], mtok) end
-- AO under the clip on the header and the ribbon foot
for x = 28, 35 do A.step(c, kidx, STL, x, 22, -1, mtok) end
for x = 34, 35 do for y = 28, 29 do if hidx[K(x, y)] then A.step(c, hidx, TEA, x, y, -2, htok) end end end
-- pop: 2x1 laminate glint on the card's upper-left
c:put(11, 31, CRD[6], ctok) c:put(12, 31, CRD[6], ctok) c:put(10, 26, "#fff4d6", htok)
A.save(c, "ico-id-card")
