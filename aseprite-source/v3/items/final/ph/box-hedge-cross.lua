-- box-hedge-cross (final pass, Opus aB10_1). A plus-shaped clipped boxwood junction seen in 3/4 view: four slim
-- arms with rounded clipped ends, lit top faces receding into the far arm, front faces falling into shade, deep AO in
-- the two front inner corners where the side arms meet the near arm, leaf-cluster bumps, waxy glints, woody stems at
-- the base, ground shadow under the near arm.
-- quirk: a little red-capped toadstool has popped up in the front-left inner corner.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local NAME = "box-hedge-cross"
local c = A.new(NAME)
local F, H, OY = 0.55, 10, 22
local function rr(x, z, x0, x1, z0, z1, r)
  if x < x0 or x > x1 or z < z0 or z > z1 then return false end
  local cx = x < x0 + r and x0 + r or (x > x1 - r and x1 - r or x)
  local cz = z < z0 + r and z0 + r or (z > z1 - r and z1 - r or z)
  return (x - cx)^2 + (z - cz)^2 <= r * r
end
local function S(x, z)
  return rr(x, z, 26, 38, 0, 50, 3) or rr(x, z, 8, 56, 19, 31, 3) or rr(x, z, 22, 42, 15, 35, 0)
end
-- ground shadow under the near arm and side arms
c:groundShadow(32, OY + 50 * F + 1, 8, 1)
local m, face, Z = A.prism(S, 6, 58, 0, 50, H, F, OY)
A.ragged(m, face, Z, 7, 0.3)
local idx, tok = A.foliage(c, m, face, { seed = 7, Z = Z, ground = true, glints = 6 })
A.twigs(c, m, idx, 7, tok)
-- quirk: toadstool in the front-left inner corner (ground at plan x~23, z~33)
local tx, ty = 19, math.floor(OY + 33 * F) - 3
A.map(c, {
  ".hRR.",
  "hcRRr",
  "RRrrd",
  ".sSs.",
  "..Ss.",
}, tx, ty, { h = "#ff8a5c", c = A.CREAM, R = "#e8493b", r = "#b52e3f", d = "#6e2038", s = "#efe0c0", S = "#c9b48e" })
A.save(c, NAME)
