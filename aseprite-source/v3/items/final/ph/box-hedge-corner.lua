-- box-hedge-corner (final, Opus aB10). An L-shaped clipped boxwood corner in 3/4 view: one arm runs right, the other
-- runs down toward the viewer. Sheared top faces lit upper-left with leaf-clump texture, rounded clipped edges,
-- darker front faces with cavities, AO in the inside bend where the right arm's face tucks behind the near arm,
-- woody stems at the base, a bark-mulch strip and ground shadow along both runs.
-- quirk: a tiny bird's nest with one sky-blue egg is tucked into the top of the near arm.
local NAME = "box-hedge-corner"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new(NAME)
local BOX = { "#14362f", "#1f5238", "#2d6e40", "#438c47", "#66ad52", "#9ccf68" }
local MULCH = { "#3a2226", "#5a3428", "#7a4a30", "#9a6a42", "#b98a5a" }
local WOOD = { "#4a2c26", "#6e4430" }

c:groundShadow(39, 36, 17, 1.5)
c:groundShadow(15, 53, 9, 1.5)
local plan = c:rrect(8, 22, 55, 32, 2):add(c:rrect(8, 22, 19, 50, 2))
local Hh = 12
A.mulch(c, plan, MULCH, 9)
local all, top, front, Z, idx, tok = A.hedge(c, plan, Hh, BOX, { seed = 23, R = 2.5 })
-- inside-bend AO: the right arm's front face next to the near arm, and the near arm's top just beside it
front:each(function(x, y) if x >= 20 and x <= 22 then local i = idx[K(x, y)]
  c:put(x, y, BOX[math.max(1, i - (x == 20 and 2 or 1))], tok) end end)
-- sprigs on the top line
for _, s in ipairs{ { 24, 1, 6 }, { 33, 2, 5 }, { 34, 1, 6 }, { 47, 1, 5 }, { 11, 1, 6 } } do
  local x, yt = s[1]
  for y = 0, 63 do if top:has(x, y) then yt = y break end end
  if yt then for d = 1, s[2] do c:put(x, yt - d, BOX[s[3] - (d - 1)], tok) end end
end
-- woody stems at the base
for _, x in ipairs{ 26, 35, 44, 52, 11, 16 } do
  for y = 0, 63 do local z = Z[K(x, y)]
    if front:has(x, y) and z and z >= 1 and z <= 2 then c:put(x, y, WOOD[z == 1 and 1 or 2], tok) end end
end

-- quirk: bird's nest with a sky-blue egg on the near arm
local ntok = { r = { name = "nest" } }
A.map(c, 9, 20, {
  "..hgWgh...",
  ".gdEeedg..",
  "hgdeEsedgh",
  "gdddeedddg",
  ".gGdgdGdg.",
  "..ddDdDd..",
}, { h = "#e8c58a", g = "#c49a5e", G = "#a07444", d = "#7a5034", D = "#4e3028",
     W = "#fff4d6", E = "#bfe8f6", e = "#7fc0e2", s = "#4f8cc4" }, ntok)
-- contact shadow under the nest
for x = 11, 18 do local y = 26 if top:has(x, y) then c:put(x, y, BOX[2], tok) end end

A.save(c, NAME)
