-- nectaplum (final, Opus single pass). A nectarine x plum: an upright egg-shaped stone fruit, plum-violet skin that
-- warms to a nectarine coral blush on the lit shoulder (freckled hard edge between them), a deep suture groove
-- curving down the left third from a cleft at the stalk, short woody stalk with one slim serrated leaf.
-- Material: per-pixel sphere light (6-tone plum, 6-tone coral blush), waxy bloom flecks on the shade side,
-- cool reflected light lower-right, groove with lit lip, AO in the stalk cavity, one cream specular.
-- quirk: a bead of amber nectar has oozed out of the suture and hangs there, glinting.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "nectaplum"
local c = A.new(NAME)
local PLUM  = { "#24123a", "#3f1a58", "#612676", "#86338a", "#a94a98", "#d277b0" }
local BLUSH = { "#4a1a46", "#7a2350", "#b23a58", "#dc5e56", "#f58e62", "#ffc58a" }
local BLOOM, COOL, SPEC = "#a996d2", "#5d55a8", "#fff4d6"
local WOOD = { "#3e2622", "#62402e", "#8c623f", "#b88a58" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local CX, CY = 31, 37

-- leaf + stalk first (fruit paints over their feet)
local wtok = { r = { name = "stalk" } }
local sm = A.stem(c, { { 32, 25 }, { 32, 21 }, { 33, 18 }, { 35, 15 } }, function(t) return 1.3 - 0.25 * t end, WOOD, { tok = wtok })
c:put(35, 14, WOOD[3], wtok) c:put(36, 14, WOOD[4], wtok)      -- pale snapped end grain
local lm = A.leaf(c, 34, 18, 42, 10, 53, 12, 4.2, LEAF, { serr = true, pw = 0.9 })

-- fruit body: egg, slightly narrower at the top, cleft at the stalk
local body = c:ellipse(CX, CY, 12, 14)
body:cut(c:ellipse(CX, CY - 15, 2, 2))
body:each(function(x, y) if y < CY - 6 then local f = (CY - 6 - y) / 8 if abs(x - CX) > 12 - f * 2.4 then body.s[K(x, y)] = nil end end end)
local n = A.body(body, CX - 1, CY, 13.5, 6, 0.65)
-- suture: a curved line, x(y) = CX - 3 + bend
local function sx(y) return CX - 4 + 3.2 * sin((y - (CY - 14)) / 28 * pi) end
local bias = {}
X.ao(bias, body, c:rect(29, 22, 35, 23), 2, -1)
local groove = {}
body:each(function(x, y) local k = K(x, y)
  local d = x - sx(y)
  if y > CY - 14 and y < CY + 11 then
    if d >= -0.5 and d < 0.5 then groove[k] = 1
    elseif d >= 0.5 and d < 1.5 then bias[k] = (bias[k] or 0) - 1        -- shadow right of the groove
    elseif d >= -1.5 and d < -0.5 then bias[k] = (bias[k] or 0) + 1 end  -- lit lip left of it
  end
end)
local v = X.light(n, { amb = 0.05, wrap = 0.22 })
local ftok = { r = { name = "fruit" } }
local idx = X.tone(c, body, v, PLUM, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = ftok })
-- nectarine blush: upper-left lit shoulder, freckled border
body:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - (CX - 4)) / 9, (y - (CY - 5)) / 10
  local r = dx*dx + dy*dy
  local edge = 0.75 + (X.hash(x, y, 7) - 0.5) * 0.5
  if r < edge and not groove[k] then c:put(x, y, BLUSH[idx[k]], ftok) end
  if r >= edge and r < edge + 0.25 and X.hash(x, y, 3) > 0.82 and idx[k] >= 3 then c:put(x, y, BLUSH[max(1, idx[k] - 1)], ftok) end
end)
for k, _ in pairs(groove) do local x, y = k % 1024 - 256, k // 1024 - 256
  c:put(x, y, (y < CY - 4) and BLUSH[max(1, idx[k] - 2)] or PLUM[max(1, idx[k] - 2)], ftok) end
-- waxy bloom flecks on the shade side
body:each(function(x, y) local k = K(x, y)
  if not groove[k] and idx[k] >= 2 and idx[k] <= 4 and x > CX - 2 and X.hash(x, y, 11) > 0.9 then c:put(x, y, idx[k] >= 3 and BLOOM or PLUM[4], ftok) end end)
-- cool reflected light lower-right
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.62 and y > CY - 2 then c:put(x, y, COOL, ftok) end end)
-- stalk cavity: dark cup
for _, q in ipairs{ { 30, 23 }, { 31, 23 }, { 32, 23 }, { 33, 23 }, { 31, 24 }, { 32, 24 } } do c:put(q[1], q[2], PLUM[1], ftok) end
c:put(32, 22, WOOD[1], wtok)
-- specular: 2x1 cream with hi halo
c:put(24, 29, SPEC, ftok) c:put(25, 29, SPEC, ftok) c:put(24, 30, BLUSH[6], ftok) c:put(26, 29, BLUSH[6], ftok) c:put(23, 29, BLUSH[6], ftok)

-- quirk: amber nectar bead hanging off the suture
local bx, by = floor(sx(CY + 4) + 0.5), CY + 4
local AMB = { "#8a3a1a", "#d07a22", "#f5b42e", "#ffe8a0" }
A.map(c, { ".b.", "bcb", "aba", ".a." }, bx - 1, by, { a = AMB[1], b = AMB[2], c = AMB[3] }, { r = { name = "nectar" } })
c:put(bx - 1, by + 1, AMB[4]) c:put(bx, by - 1, AMB[2])
A.save(c, NAME)
