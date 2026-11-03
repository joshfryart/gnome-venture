-- ico-palette (final, Opus). A kidney-shaped painter's palette in honey wood with a thumb notch and a bevelled
-- thumb hole, five glossy paint blobs around the rim, and a slim brush lying across it (wood handle, steel
-- ferrule, bristles dipped in red).
-- Material: per-pixel bevel on the board, long grain streaks following the board, hole wall lit on the far side,
-- domed paint blobs with a cream specular each and a contact shadow on the wood; ferrule with bevel and bright
-- edge; bristle splits; contact shadow of the brush on the board.
-- quirk: the purple blob is dripping a slow bead of paint off the bottom edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, sin, cos, max, min, abs, sqrt, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.sqrt, math.pi
local c = A.new("ico-palette")
local WOOD = { "#4a2a26", "#74432f", "#9c633c", "#c08650", "#dcaa6c", "#f1cf94" }
local HAND = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local STEEL = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local PAINT = {
  { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" },     -- ember
  { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" },     -- gold
  { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" },     -- moss
  { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" },     -- sea
  { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" },     -- dusk
}
local wtok, htok, stok = A.tok("board"), A.tok("handle"), A.tok("steel")
local CX, CY, ANG = 31, 31, -0.14

-- board: tilted ellipse minus a thumb notch, with a thumb hole
local board = select(1, G.oval(CX, CY, 23, 16, ANG))
local notch = c:ellipse(9.5, 37.5, 5.2, 4.6)
board:cut(notch)
local hole = c:ellipse(16.5, 30, 2.6, 2.6)
board:cut(hole)
local bn = X.pillow(board, 3)
local bias = {}
-- blobs and brush cast shadows on the board (computed before toning)
local blobs = { { 23, 22.5, 3.4 }, { 32, 20, 3.4 }, { 41, 19.5, 3.3 }, { 49, 24, 3.2 }, { 26, 42, 3.2 } }
local blobMasks = {}
for i, b in ipairs(blobs) do
  local m = c:ellipse(b[1], b[2], b[3], b[3] * 0.85)
  blobMasks[i] = m
  G.cast(bias, board, m, 1, 1, -1)
  G.cast(bias, board, m, 2, 1, -1)
end
-- brush geometry: handle end lower right (off the board), bristle tip toward the centre
local HX0 = 0
local hm, hn = G.tube({ { 57, 51 }, { 53, 47.3 }, { 49, 43.6 }, { 45, 40 } }, function(t) return 1.7 - t * 0.3 end)
local fm, fn = G.tube({ { 45.6, 40.6 }, { 44, 39.1 }, { 42.5, 37.7 }, { 41, 36.3 } }, function(t) return 2.3 end)
local brm, brn = G.tube({ { 41.4, 36.7 }, { 39, 34.4 }, { 36.5, 32 }, { 33.5, 29 } }, function(t) return 2.6 * (1 - t) ^ 0.6 + 0.4 end)
local brush = HP.mask():add(hm):add(fm):add(brm)
G.cast(bias, board, brush, 1, 2, -1)
G.cast(bias, board, brush, 2, 3, -1)
-- hole wall: near side (upper-left inside) dark, far side lit
local hb = hole:grow(1)
hb:each(function(x, y) if board:has(x, y) then
  local k = K(x, y)
  bias[k] = (bias[k] or 0) + ((x + y < 16.5 + 30) and -2 or 1)
end end)
local bidx = A.shade(c, board, bn, WOOD, { tok = wtok, bias = bias, amb = 0.1, wrap = 0.3 })
-- grain streaks along the board's long axis
local ux, uy = cos(ANG), sin(ANG)
board:shrink(2):each(function(x, y)
  local a = (x - CX) * ux + (y - CY) * uy
  local b = -(x - CX) * uy + (y - CY) * ux
  local band = floor(b / 2.6 + 0.5 * sin(a * 0.25))
  local f = (b / 2.6 + 0.5 * sin(a * 0.25)) - band
  if f < 0.16 and X.hash(floor(a / 6), band, 3) > 0.45 then A.step(c, bidx, WOOD, x, y, -1, wtok) end
end)
-- paint blobs (domed, 4 tones + cream specular)
for i, b in ipairs(blobs) do
  local m = blobMasks[i]
  local n = X.sphere(b[1] - 0.6, b[2] - 0.6, b[3], m)
  A.shade(c, m, n, PAINT[i], { tok = A.tok("paint" .. i), cuts = { 0.2, 0.45, 0.78 } })
  c:put(floor(b[1] - 1), floor(b[2] - 1), A.CREAM, A.tok("paint" .. i))
end
-- quirk: drip from the purple blob running off the bottom edge
local P5 = PAINT[5]
local dt = A.tok("paint5")
local bx = 26
local ybot
for y = 40, 60 do if board:has(bx, y) then ybot = y end end
for y = 43, ybot do if not blobMasks[5]:has(bx, y) then c:put(bx, y, P5[3], dt) c:put(bx + 1, y, P5[2], dt) end end
for y = ybot + 1, ybot + 1 do c:put(bx, y, P5[3], dt) c:put(bx + 1, y, P5[2], dt) end
A.map(c, { "hgg.", "ggGd", ".Gd." }, bx - 1, ybot + 2, { h = P5[4], g = P5[3], G = P5[2], d = P5[1] }, dt)

-- brush: handle (wood cylinder), ferrule (steel), bristles (red tip)
local hidx = A.shade(c, hm, hn, HAND, { tok = htok, cuts = { 0.22, 0.5, 0.8 } })
A.shade(c, fm, fn, STEEL, { tok = stok, cuts = { 0.22, 0.5, 0.8 } })
-- ferrule crimp rings: dark line at both ends, bright edge
for _, s in ipairs{ 0, 1 } do
  fm:each(function(x, y)
    local d = (x - 45.6) * 0.72 + (y - 40.6) * 0.69
    if s == 0 and d > -0.7 then c:put(x, y, STEEL[1], stok) end
  end)
end
local BR = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local BRS = { "#5a3a30", "#8a6048", "#b88a5e", "#e2bb84" }
local bt = A.tok("bristle")
local bv = X.light(brn, { amb = 0.08, wrap = 0.25 })
brm:each(function(x, y)
  local k = K(x, y)
  local d = (x - 41.4) * -0.72 + (y - 36.7) * -0.69     -- distance along toward the tip
  local i = bv[k] < 0.25 and 1 or bv[k] < 0.5 and 2 or bv[k] < 0.8 and 3 or 4
  local ramp = d > 2.2 and BR or BRS
  c:put(x, y, ramp[i], bt)
end)
-- bristle splits
c:put(39, 34, BRS[1], bt) c:put(37, 32, BR[2], bt) c:put(36, 30, BR[4], bt)
-- separation: ferrule against bristles
c:put(41, 37, STEEL[1], stok) c:put(44, 38, STEEL[4], stok)
-- handle end cap highlight and pop on the board
c:put(56, 50, HAND[4], htok)
c:put(13, 25, WOOD[6], wtok) c:put(14, 25, WOOD[6], wtok)
A.save(c, "ico-palette")
