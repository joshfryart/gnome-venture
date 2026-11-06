-- ico-chicken (final, Opus). A trim russet hen in profile facing right, standing: slim egg-shaped body, upright neck,
-- small head with a three-lobed red comb and wattle, gold beak, upswept dark tail, two slim gold legs.
-- Material: body/neck/head = pillow light snapped to 6 russet tones (cool-violet shade), wing = separate 6-tone panel
-- with layered feather scallops (dark edge + lit lip) and a contact shadow under it, breast feather V marks, tail =
-- three bronze blades with a green sheen and a lit shaft; comb/wattle = 5-tone waxy red with a glint; legs = 3-tone
-- scaled gold with toe claws; AO row where the body sits on the legs; 2-tone ground shadow.
-- quirk: she has just caught a worm, and it is wriggling from her beak.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.pi
local c = A.new("ico-chicken")
local FE   = { "#40203a", "#7a3a2c", "#b05e30", "#d8843a", "#f2ac54", "#ffd890" }
local WING = { "#2e1828", "#55262a", "#80402c", "#a85a32", "#d0803e", "#f0b060" }
local TAIL = { "#1e1626", "#3a2430", "#5c3830", "#7e5434", "#4f8a6a", "#8ac08a" }
local RED  = { "#6e2038", "#b52e3f", "#e8493b", "#ff7a5a", "#ffb08a" }
local LEG  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local BEAK = { "#8f4a1f", "#e8a020", "#ffd65a" }
local WORM = { "#a8486a", "#e07a96", "#ffb0c0" }

c:groundShadow(31, 55, 15, 1.5)

-- tail: three upswept feather blades behind the body
local ttok = A.tok("tail")
local tails = {
  { 21, 35, 9, 31, 8, 17, 3.2 },
  { 22, 33, 13, 24, 14, 11, 3.0 },
  { 24, 32, 19, 22, 22, 13, 2.6 },
}
for _, t in ipairs(tails) do
  local m, n, T, S = A.blade(t[1], t[2], t[3], t[4], t[5], t[6], function(u) return t[7] * sin(pi * min(1, 0.15 + u * 0.9)) ^ 0.7 end, { fold = 0.35 })
  local idx = A.shade(c, m, n, TAIL, { tok = ttok, amb = 0.12, wrap = 0.35, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.15 and T[k] < 0.9 then c:put(x, y, (idx[K(x, y)] or 3) >= 4 and TAIL[6] or TAIL[5], ttok) end end)
end

-- legs (behind the body): 3 px shanks, scale rows, toes
local legtok = A.tok("legs")
local function leg(x, y0, y1, toeR)
  for y = y0, y1 do
    c:put(x, y, LEG[3], legtok) c:put(x + 1, y, LEG[2], legtok) c:put(x + 2, y, LEG[1], legtok)
    if (y - y0) % 3 == 2 then c:put(x, y, LEG[2], legtok) c:put(x + 1, y, LEG[1], legtok) end
  end
  c:put(x, y0 + 1, LEG[4], legtok)
  -- toes: front toe long, back spur short
  for i = 1, toeR do c:put(x + 2 + i, y1, LEG[2], legtok) c:put(x + 2 + i, y1 - 1, LEG[3], legtok) end
  c:put(x + 3 + toeR, y1, LEG[1], legtok)
  c:put(x - 1, y1, LEG[2], legtok) c:put(x - 2, y1, LEG[1], legtok)
end
leg(27, 44, 54, 3)
leg(33, 44, 54, 3)

-- body + neck + head as one rounded mass
local body = A.oval(30, 37, 13, 8.6, -0.18)
body:add(A.stroke({ { 36, 33 }, { 41, 25 }, { 43, 20 } }, 4.6))
body:add(A.ell(44, 19, 5.2, 5))
-- a slim tail root rising into the tail
body:add(HP.poly{ { 18, 33 }, { 21, 30 }, { 25, 32 }, { 21, 37 } })
local btok = A.tok("hen")
local bn = X.pillow(body, 8.5)
local bias = {}
body:each(function(x, y) local k = K(x, y)
  if y >= 45 and x >= 25 and x <= 37 then bias[k] = -1 end   -- AO on the belly where the legs join
end)
local bidx = A.shade(c, body, bn, FE, { tok = btok, bias = bias, amb = 0.1, wrap = 0.35, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- breast feather V marks
for _, p in ipairs{ { 40, 36 }, { 42, 40 }, { 37, 43 } } do
  local x, y = p[1], p[2]
  local k = K(x, y)
  if body:has(x, y) then
    local i = bidx[k] or 3
    c:put(x - 1, y - 1, FE[max(1, i - 1)], btok) c:put(x, y, FE[max(1, i - 1)], btok) c:put(x + 1, y - 1, FE[max(1, i - 1)], btok)
  end
end
-- neck hackle streaks
for _, p in ipairs{ { 40, 25 }, { 42, 27 }, { 39, 29 } } do
  c:put(p[1], p[2], FE[5], btok) c:put(p[1], p[2] + 1, FE[3], btok)
end

-- wing panel with feather scallops
local wm, wn = A.oval(28, 35.5, 9.5, 5, -0.08)
-- contact shadow under the wing on the body
local wtok = A.tok("wing")
wm:shift(1, 2):each(function(x, y) if body:has(x, y) and not wm:has(x, y) then
  local k = K(x, y) c:put(x, y, FE[max(1, (bidx[k] or 3) - 2)], btok) end end)
local widx = A.shade(c, wm, wn, WING, { tok = wtok, amb = 0.25, wrap = 0.4, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 } })
wm:each(function(x, y)
  local d = (36 - x) + 0.14 * (y - 35) ^ 2
  local r = d % 5
  local k = K(x, y)
  if d > 2 then
    if r < 1 then c:put(x, y, WING[max(1, (widx[k] or 3) - 2)], wtok)
    elseif r < 2 and (widx[k] or 3) >= 3 then c:put(x, y, WING[min(6, (widx[k] or 3) + 1)], wtok) end
  end
end)
-- wing top edge lit, bottom edge separated by deep
wm:edge():each(function(x, y) local nn = wn[K(x, y)]
  if nn[2] < -0.45 and x > 22 then c:put(x, y, WING[6], wtok) elseif nn[2] > 0.2 then c:put(x, y, WING[1], wtok) end end)

-- comb: three lobes on the crown
local comb = A.ell(40.5, 13.5, 1.9, 1.9):add(A.ell(43.5, 12, 2.1, 2.3)):add(A.ell(46.5, 13, 1.9, 2.0)):add(c:rect(40, 14, 47, 15))
local ctok = A.tok("comb")
local cn = X.pillow(comb, 1.6)
A.shade(c, comb, cn, RED, { tok = ctok, amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.5, 0.7, 0.9 } })
c:put(42, 11, RED[5], ctok)
-- wattle under the beak
local wat = A.ell(48.5, 25, 1.6, 2.2)
local wn2 = X.sphere(48.5, 25, 2, wat)
A.shade(c, wat, wn2, RED, { tok = ctok, amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.5, 0.7, 0.9 } })
-- beak: short hooked wedge
A.map(c, {
  "hb..",
  "hbbb",
  "bbsd",
  "sd..",
}, 49, 18, { h = BEAK[3], b = BEAK[2], s = BEAK[1], d = "#5e3020" }, A.tok("beak"))
-- eye: ink pill with glint, pale eye-ring behind
c:put(44, 17, FE[6], btok) c:put(44, 18, FE[6], btok)
c:eyeSmall(45, 17)
-- cheek patch
c:put(46, 21, RED[4], ctok) c:put(47, 21, RED[3], ctok)

-- quirk: a pink worm wriggling from the beak tip
A.map(c, {
  "hw..",
  ".wd.",
  ".hw.",
  "..wd",
  "..hw",
  "...d",
}, 51, 21, { h = WORM[3], w = WORM[2], d = WORM[1] }, A.tok("worm"))
A.save(c, "ico-chicken")
