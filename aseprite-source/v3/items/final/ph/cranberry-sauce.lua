-- cranberry-sauce (final, Opus single pass). A log of jellied cranberry sauce standing on a small glazed saucer,
-- still wearing the can's ridges, with one cut slice leaning against its right side.
-- Material: jelly = 6-tone ruby cylinder, lit flat top with a bright cut rim, curved can-ridge grooves (dark cut +
-- lit lip), long glossy specular streak, lit-through glow on the shade side, two tiny bubbles; slice = face with a
-- ring of the can ridge and a dark thickness edge; saucer = 6-tone glazed ceramic with a blue band, dark well wall
-- and a contact shadow under the jelly. Ground shadow (2-tone).
-- quirk: one whole cranberry is stuck in the top of the jelly.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("cranberry-sauce")
local JEL = { "#3a0a24", "#62102e", "#8e1a36", "#bb263d", "#e0454a", "#ff8676" }
local PL  = { "#4c5270", "#7a809e", "#a9b0c6", "#cdd4e2", "#e8ecf0", "#faf8ec" }
local BAND = { "#3e5a9a", "#6a8ac8" }
local SPEC = "#fff1cf"
c:groundShadow(32, 53, 22, 1)

-- saucer
local ptok = { r = { name = "plate" } }
local outer = HP.ellipse(32, 48, 21, 4.5)
local under = outer:shift(0, 2):cut(outer)
under:each(function(x, y) c:put(x, y, outer:shift(0, 1):has(x, y) and PL[2] or PL[1], ptok) end)
outer:each(function(x, y)
  local i = y < 47 and 6 or y < 49 and 5 or 4
  if x > 46 then i = i - 1 end
  c:put(x, y, PL[i], ptok)
end)
local well = HP.ellipse(32, 48, 16, 3)
well:each(function(x, y) c:put(x, y, (y <= 46) and PL[3] or PL[4], ptok) end)
well:edge():each(function(x, y) if y <= 47 then c:put(x, y, PL[2], ptok) end end)
-- blue band on the rim
local band = HP.ellipse(32, 48, 18.5, 3.8):cut(HP.ellipse(32, 48, 17.5, 3.3))
band:each(function(x, y) if outer:has(x, y) and not well:has(x, y) then c:put(x, y, (x < 32 and y < 48) and BAND[2] or BAND[1], ptok) end end)

-- jelly log
local JX, TOPY, BOTY, W = 31, 17, 46, 9
local jtok = { r = { name = "jelly" } }
local side, top = HP.mask(), HP.ellipse(JX, TOPY, W, 2.6)
local n, S = {}, {}
for x = JX - W, JX + W do
  local s = (x - JX) / (W + 0.5)
  local curv = 2.6 * sqrt(max(0, 1 - s*s))
  for y = TOPY, floor(BOTY + curv + 0.5) do
    if not top:has(x, y) then side:set(x, y) end
    n[K(x, y)] = { A.norm(s, 0.08, sqrt(max(0.05, 1 - s*s))) } S[K(x, y)] = s
  end
end
side:cut(top)
-- contact shadow on the saucer
side:shift(2, 1):cut(side):each(function(x, y) if well:has(x, y) or outer:has(x, y) then c:put(x, y, PL[2], ptok) end end)
local bias = {}
side:each(function(x, y) local s = S[K(x, y)]
  if y > BOTY + 2.6 * sqrt(max(0, 1 - s*s)) - 2 then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, side, n, JEL, { tok = jtok, amb = 0.06, wrap = 0.25, bias = bias })
-- lit-through glow on the shade side
side:each(function(x, y) local s = S[K(x, y)]
  if s > 0.4 and s < 0.75 and y > 26 and y < 43 then A.step(c, idx, JEL, x, y, 2, jtok) end end)
-- can ridges
for _, y0 in ipairs{ 24, 31, 38 } do
  side:each(function(x, y) local s = S[K(x, y)]
    local yc = y0 + 2.6 * sqrt(max(0, 1 - s*s))
    if abs(y - yc) < 0.5 then A.step(c, idx, JEL, x, y, -2, jtok)
    elseif abs(y - yc - 1) < 0.5 then A.step(c, idx, JEL, x, y, 1, jtok) end
  end)
end
-- top face: flat, lit, bright cut rim
local tidx = {}
top:each(function(x, y) local dx = x - JX
  local i = dx < -3 and 5 or dx < 4 and 4 or 3
  tidx[K(x, y)] = i c:put(x, y, JEL[i], jtok) end)
top:edge():each(function(x, y) if y <= TOPY or x < JX - 5 then c:put(x, y, JEL[6], jtok) else c:put(x, y, JEL[5], jtok) end end)
-- specular streak, broken by the ridges
for y = 21, 43 do
  local x = JX - 6
  local col = c:get(x, y)
  if col ~= JEL[1] and col ~= JEL[2] then c:put(x, y, JEL[6], jtok) end
end
c:put(JX - 6, 22, SPEC, jtok)
-- bubbles
c:put(JX + 3, 34, JEL[6], jtok) c:put(JX - 2, 42, JEL[5], jtok)

-- slice leaning on the right
local stok = { r = { name = "slice" } }
local sm, sn = A.oval(45, 43, 4.2, 5.8, -0.28, 1)
sm:shift(1, 1):cut(sm):each(function(x, y) c:put(x, y, JEL[1], stok) end)     -- thickness
sm:shift(1, 0):cut(sm):each(function(x, y) c:put(x, y, JEL[2], stok) end)
sm:each(function(x, y) c:put(x, y, JEL[5], stok) end)
sm:edge():each(function(x, y) c:put(x, y, (x + y < 45 + 43 - 2) and JEL[6] or JEL[4], stok) end)
A.oval(45, 43, 2.6, 4.0, -0.28, 1):cut(A.oval(45, 43, 1.8, 3.1, -0.28, 1)):each(function(x, y) c:put(x, y, JEL[4], stok) end)
c:put(44, 40, SPEC, stok) c:put(43, 41, JEL[6], stok)
-- AO on the log behind the slice
sm:grow(1):cut(sm):each(function(x, y) if side:has(x, y) and not sm:shift(1, 1):has(x, y) then A.step(c, idx, JEL, x, y, -1, jtok) end end)

-- quirk: a whole cranberry stuck in the top
local btok = { r = { name = "berry" } }
local bm, bn = A.oval(27, 16, 2.6, 2.4, 0, 1)
A.shade(c, bm, bn, { "#45102e", "#741634", "#a3203b", "#cc2f42", "#ea5a55", "#ff9884" }, { tok = btok })
c:put(26, 15, SPEC, btok)
c:put(25, 18, JEL[2], jtok) c:put(29, 18, JEL[2], jtok)                          -- dent in the jelly
A.save(c, "cranberry-sauce")
