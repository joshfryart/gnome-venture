-- lingonberry (Opus artist pass). A slim woody sprig rising lower-left to upper-right; small leathery evergreen
-- leaves (glossy, rolled margin, midrib) alternate up the twig; a hanging cluster of five glossy ruby berries on fine
-- pedicels, each with a sphere light, cool reflected rim, a sharp specular and the dark calyx crown at the blossom end.
-- AO where berries tuck under each other and under the twig.
-- quirk: one late pale-pink bell flower still nods from the tip of the sprig.
local NAME = "lingonberry"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_4.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = D.new(NAME)
local BARK = { "#3a2422", "#5b3a2c", "#7e5434", "#a17444", "#c49a62" }
local LEAF = { "#14352e", "#1d4c38", "#2a6a40", "#3f8a46", "#62aa52", "#9ccc6a" }
local BER  = { "#4a0c22", "#7a1430", "#a81e36", "#d02e3c", "#ec5248", "#ff8c72" }
local PED  = "#7a3a2c"
local BELL = { "#9c4a6e", "#d07898", "#f0a8c0", "#ffd8e4" }
local ltok, btok = D.tok("leaf"), D.tok("bark")

-- twig
local tw = { { 15, 58 }, { 21, 45 }, { 29, 27 }, { 46, 11 } }
local sm, sn, ST = G.tube(tw, function(t) return 1.5 - 0.7 * t end)
local sidx = D.tone(c, sm, sn, BARK, { amb = 0.15, wrap = 0.3, tok = btok })
-- bark: knots / leaf scars every few px
for _, t in ipairs{ 0.18, 0.42, 0.66 } do local x, y = G.bez(tw, t) c:put(floor(x + 0.5), floor(y + 0.5), BARK[1], btok) end
c:put(14, 58, BARK[5], btok) c:put(15, 58, BARK[4], btok)            -- cut end, pale wood

-- leaves: leathery ovals off the twig, alternating
local function leaf(t, ang, L, W)
  local x, y = G.bez(tw, t)
  local ux, uy = math.cos(ang), math.sin(ang)
  local bx, by = x + ux * L, y + uy * L
  local cx, cy = x + ux * L * 0.5 - uy * 1.2, y + uy * L * 0.5 + ux * 1.2
  local m, n, T, S = G.blade(x, y, cx, cy, bx, by, function(tt)
    if tt > 0.97 then return -1 end
    return max(0.4, W * math.sin(math.pi * min(1, tt * 0.92 + 0.1)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  D.tone(c, m, n, LEAF, { amb = 0.12, wrap = 0.3, tok = ltok })
  m:each(function(px, py) local k = K(px, py)
    if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.85 then c:put(px, py, S[k] <= 0 and LEAF[6] or LEAF[2], ltok) end
  end)
  -- rolled (revolute) margin: pale lip on the lit edge
  m:edge():each(function(px, py) local k = K(px, py) if S[k] < -0.6 and T[k] > 0.2 and T[k] < 0.8 then c:put(px, py, LEAF[5], ltok) end end)
  return m
end
local lv = HP.mask()
lv:add(leaf(0.56, -2.6, 9, 2.6))
lv:add(leaf(0.70, -0.35, 9, 2.6))
lv:add(leaf(0.84, -2.2, 8, 2.4))
lv:add(leaf(0.30, -2.9, 8, 2.4))

-- quirk: bell flower at the twig tip
local tx, ty = G.bez(tw, 1)
D.line(c, { { 46, 11 }, { 49, 10 }, { 51, 12 } }, PED, btok)
local bell = c:poly{ { 49, 13 }, { 53, 13 }, { 54, 17 }, { 55, 18 }, { 47, 18 }, { 48, 17 } }
local bn = D.vcylN(bell, 47, 55)
D.tone(c, bell, bn, BELL, { amb = 0.2, wrap = 0.35, tok = D.tok("bell") })
c:put(49, 18, BELL[1], D.tok("bell")) c:put(51, 18, BELL[1], D.tok("bell")) c:put(53, 18, BELL[1], D.tok("bell"))  -- flared petal tips
c:put(51, 19, BELL[2], D.tok("bell"))                                                                                  -- stamen tip

-- berries (drawn back to front), pedicels first
local B = { { 41, 37, 4.3 }, { 31, 40, 4.3 }, { 44, 47, 4.3 }, { 34, 50, 4.4 }, { 25, 50, 3.6 } }
local hub = { 26, 36 }
for _, b in ipairs(B) do D.line(c, { hub, { floor(b[1] - 1), floor(b[2] - b[3] + 0.5) } }, PED, D.tok("ped")) end
local masks = {}
for i, b in ipairs(B) do
  local bias = {}
  local m = c:ellipse(b[1], b[2], b[3], b[3])
  for j = i + 1, #B do local o = c:ellipse(B[j][1], B[j][2], B[j][3], B[j][3]) X.ao(bias, m, o, 1, -1) end
  local bm, bnn, tok = D.berry(c, b[1], b[2], b[3], BER, { bias = bias, rimc = "#8a3a6a" })
  masks[i] = bm
  -- calyx crown at the blossom end (lower right of the face)
  local cx, cy = floor(b[1] + 1.5), floor(b[2] + 1.5)
  c:put(cx, cy, BER[1], tok) c:put(cx + 1, cy, BER[2], tok) c:put(cx, cy + 1, BER[2], tok) c:put(cx - 1, cy, BER[2], tok)
  -- specular: 2px cream + bright halo
  local sx, sy = floor(b[1] - b[3] * 0.45 + 0.5), floor(b[2] - b[3] * 0.45 + 0.5)
  c:put(sx, sy, D.CREAM, tok) c:put(sx + 1, sy, D.CREAM, tok) c:put(sx, sy + 1, BER[6], tok)
end
-- ambient shadow on the twig/leaf above the berries is implied by the pedicel hub: darken the hub knot
c:put(26, 36, BARK[1], btok) c:put(27, 36, BARK[2], btok)
D.save(c, NAME)
