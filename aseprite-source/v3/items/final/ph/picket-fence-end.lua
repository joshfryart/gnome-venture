-- picket-fence-end (final, Opus single pass): the end of a run: five slim painted pickets recede up-left on two rails
-- and stop at a stout square end post (turned 45 degrees) crowned with a turned neck and a painted ball finial. The
-- far rail ends show pale end grain. Material: per-pixel pillow light, grain streaks, paint chip, nail heads, bright
-- arris on the post, sphere-lit finial with one specular and a cool bounce, contact shadow and AO at the feet.
-- quirk: a morning-glory vine has crept up the post and opened one violet trumpet.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin = math.floor, math.sin
local c = A.new("picket-fence-end")
c:groundShadow(30, 47, 23, 5)
A.rail(c, 9, 43, 46, 37, 0.5, { ends = { "l" } })
A.rail(c, 9, 43, 46, 45, 0.5, { ends = { "l" } })
local HGT = 23
for i, cx in ipairs{ 14, 20, 26, 32, 38 } do
  local gy = 52 + floor((cx - 46) / 2)
  A.picket(c, cx, gy, HGT, 0.5, { grain = (i % 2 == 0) and -1 or 1, chip = (i == 3) and { 0, -15 } or nil })
  local y = 37 + floor((cx - 46) / 2) + 1
  A.nail(c, cx, y) A.nail(c, cx, y + 8)
end
local P = A.post(c, 46, 55, 4, 32)
-- turned neck + ball finial
local tok = { r = { name = "finial" } }
for y = P.apex - 3, P.apex do
  c:put(44, y, A.WOOD[5], tok) c:put(45, y, A.WOOD[4], tok) c:put(46, y, A.WOOD[3], tok) c:put(47, y, A.WOOD[2], tok)
end
c:put(45, P.apex - 1, A.WOOD[6], tok)
for x = 44, 47 do c:put(x, P.apex - 3, A.WOOD[1], tok) end   -- AO under the ball
local by = P.apex - 7
local bm = c:ellipse(45.5, by, 3.5, 3.5)
local bn = X.sphere(45.5, by, 3.5, bm)
local v = X.light(bn, { amb = 0.08, wrap = 0.2 })
X.tone(c, bm, v, A.PAINT, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = tok })
c:put(44, by - 2, A.CREAM, tok) c:put(43, by - 1, A.PAINT[6], tok)
c:put(48, by + 2, "#a9a6c8", tok) c:put(49, by + 1, "#a9a6c8", tok)       -- cool bounce
-- quirk: morning-glory vine up the post's right face
local V = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local vt = { r = { name = "vine" } }
for y = 30, 53 do
  local x = 47 + floor(1.4 * sin(y * 0.55) + 0.5)
  c:put(x, y, V[2], vt)
end
A.map(c, { ".lL", "llL", ".d." }, 49, 44, { l = V[3], L = V[4], d = V[1] }, vt)
A.map(c, { "Ll.", "lll", ".d." }, 44, 37, { l = V[3], L = V[4], d = V[1] }, vt)
A.map(c, {
  ".PpP.",
  "PpcpD",
  ".PpD.",
  "..g..",
}, 48, 27, { P = "#8a6fd0", p = "#c9b2f0", c = A.CREAM, D = "#5a459e", g = V[2] }, vt)
A.tuft(c, 37, 49) A.tuft(c, 25, 43) A.tuft(c, 13, 37) A.tuft(c, 48, 55)
A.save(c, "picket-fence-end")
