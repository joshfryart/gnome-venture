-- box-hedge (final, Opus aB10). A straight clipped boxwood hedge block in 3/4 view: flat sheared top (bright,
-- leaf-clump texture lit upper-left), rounded clipped edges, front face a step darker with deep cavities, AO at the
-- base, woody stems peeking from the dark bottom, a 2px bark-mulch strip and a ground shadow.
-- A few un-clipped sprigs break the top line. quirk: a little snail is climbing the front face, trail glinting.
local NAME = "box-hedge"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new(NAME)
local BOX = { "#14362f", "#1f5238", "#2d6e40", "#438c47", "#66ad52", "#9ccf68" }
local MULCH = { "#3a2226", "#5a3428", "#7a4a30", "#9a6a42", "#b98a5a" }
local WOOD = { "#4a2c26", "#6e4430" }

c:groundShadow(32, 40, 26, 2)
-- plan: long, shallow-ish block (ground coords), height 16
local plan = c:rrect(8, 26, 55, 37, 2)
A.mulch(c, plan, MULCH, 5)
local all, top, front, Z, idx, tok = A.hedge(c, plan, 16, BOX, { seed = 11, R = 2.5 })
-- un-clipped sprigs on the top line (1-2 px tufts, part of the silhouette)
for _, s in ipairs{ { 14, 1, 5 }, { 15, 2, 6 }, { 27, 1, 6 }, { 38, 2, 5 }, { 39, 1, 6 }, { 49, 1, 5 } } do
  local x = s[1]
  local yt
  for y = 0, 63 do if top:has(x, y) then yt = y break end end
  if yt then for d = 1, s[2] do c:put(x, yt - d, BOX[s[3] - (d - 1)], tok) end end
end
-- a longer stray shoot leaning right
c:put(44, 9, BOX[4], tok) c:put(45, 8, BOX[5], tok) c:put(46, 7, BOX[6], tok) c:put(47, 7, BOX[5], tok) c:put(46, 6, BOX[6], tok)
-- woody stems in the dark base cavities
for _, x in ipairs{ 13, 22, 31, 41, 50 } do
  for y = 0, 63 do
    if front:has(x, y) and Z[K(x, y)] <= 2 and Z[K(x, y)] >= 1 then c:put(x, y, WOOD[Z[K(x, y)] == 1 and 1 or 2], tok) end
  end
end
-- sheared top: a faint lighter shear line across the top face (clipper pass)
for x = 10, 53 do
  local y = 15 + ((x // 9) % 2)
  if top:has(x, y) and A.leafBias(x, y, 11) >= 0 then c:put(x, y, BOX[6], tok) end
end

-- quirk: snail on the front face (shell spiral, horns), slime trail glint behind it
local stok = { r = { name = "snail" } }
A.map(c, 31, 26, {
  "......k.k",
  ".bbb...k.k",
  "bhcgb..ss",
  "bcbgdb.sS",
  "bgggdbsSS",
  "sbddbsSSs",
  ".sssssss.",
}, { k = "#2b1c26", b = "#8a4a2e", h = "#ffd9a0", c = "#e8a860", g = "#c27a40", d = "#6e3a2c",
     s = "#d9c4a8", S = "#a8907c" }, stok)
for _, q in ipairs{ { 28, 33 }, { 26, 34 }, { 24, 34 } } do c:put(q[1], q[2], "#c8f0d8", stok) end

A.save(c, NAME)
