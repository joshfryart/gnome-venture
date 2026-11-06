-- box-hedge-straight (final pass, Opus aB10_1). A long, low clipped boxwood run in 3/4 view: lit top face, front face
-- falling into shade, rounded clipped edges, leaf-cluster bumps with sunken gaps, waxy glints, woody stems in the
-- dark gaps at the base, ground AO + 2-tone ground shadow.
-- quirk: one rogue shoot the gardener missed sticks up out of the top, two leaves at its tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local NAME = "box-hedge-straight"
local c = A.new(NAME)
c:groundShadow(32, 43, 25, 1)
local function S(x, z)
  if x < 8 or x > 56 or z < 0 or z > 12 then return false end
  -- softly rounded plan corners
  local cx = x < 11 and 11 or (x > 53 and 53 or x)
  local cz = z < 3 and 3 or (z > 9 and 9 or z)
  return (x - cx)^2 + (z - cz)^2 <= 9.5
end
local m, face, Z = A.prism(S, 6, 58, 0, 12, 14, 0.55, 36)
A.roundCorners(m, 3)
A.ragged(m, face, Z, 3, 0.3)
local idx, tok = A.foliage(c, m, face, { seed = 3, Z = Z, ground = true, glints = 5 })
A.twigs(c, m, idx, 3, tok)
-- quirk: rogue shoot
local st = { "#2a6c40", "#3f8a45" }
local stem = { {41, 21}, {41, 20}, {42, 19}, {42, 18}, {42, 17}, {43, 16}, {43, 15} }
for i, p in ipairs(stem) do c:put(p[1], p[2], i < 3 and st[1] or st[2], tok) end
A.map(c, {
  "aa....",
  "abbd..",
  ".bdd.e",
  "....ef",
  "...eef",
}, 38, 12, { a = "#94c862", b = "#62a94c", c = A.GLINT, d = "#3f8a45", e = "#62a94c", f = "#2a6c40" })
c:put(44, 15, "#3f8a45")
A.save(c, NAME)
