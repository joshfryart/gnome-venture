-- celery (final, Opus aB1r1_1). A slim head of four celery stalks gathered into a pale heart and fanning up, each
-- crowned with a short petiole and toothed, lobed leaflets. Material: per-pixel cylinder light (6-tone pale green,
-- cool shade), raised ribs (dark groove + lit lip) running the length of each stalk, AO where back stalks meet front
-- ones, a waxy specular streak on the front stalk, a flat cut base showing pale cross-section with U-shaped strings.
-- Leaves: darker 6-tone green, midribs, dark base where they join.
-- quirk: someone has taken one crunchy bite from the right stalk, and a stringy fibre dangles from it.
local NAME = "celery"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local ST = { "#2c5634", "#467a3e", "#6aa04c", "#94c264", "#bedc88", "#e2f2b4" }
local LF = { "#163a2a", "#1f5430", "#2e7238", "#479240", "#6cb04c", "#a2d06c" }
local CUT = { "#7a9c58", "#a8c47a", "#cfe2a2", "#ecf4cc" }
local FLESH, SPEC = "#eef8cc", "#f8ffe4"

-- stalks: back to front. pts, base half-width, top half-width
local stalks = {
  { { { 29, 54 }, { 27, 43 }, { 22, 33 }, { 17, 24 } }, 2.4, 1.8 },
  { { { 35, 54 }, { 38, 43 }, { 42, 33 }, { 46, 25 } }, 2.4, 1.8 },
  { { { 30, 56 }, { 29, 44 }, { 28, 32 }, { 27, 20 } }, 2.7, 2.0 },
  { { { 34, 56 }, { 35, 44 }, { 37, 32 }, { 38, 22 } }, 2.7, 2.0 },
}
for _, s in ipairs(stalks) do
  s.m, s.n, s.T, s.S, s.samp = A.tube(s[1], function(t) return s[2] + (s[3] - s[2]) * t end)
end
-- bite on the right front stalk
local bite = HP.ellipse(43.4, 37, 2.0, 2.3)
stalks[2].m:cut(bite)

-- leaves first (stalk tops paint over the joins)
local ltok = { r = { name = "leaf" } }
local function crown(tx, ty, ux, uy, sc)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local m = HP.mask()
  local px, py = tx + ux * 3, ty + uy * 3
  m:add(A.tooth(px, py, ux, uy, 7 * sc, 2.6 * sc, 3, 0.4))
  local lx, ly = A.rot(ux, uy, -0.95) local rx, ry = A.rot(ux, uy, 0.95)
  m:add(A.tooth(px - ux, py - uy, lx, ly, 5.5 * sc, 2.2 * sc, 2, 0.4))
  m:add(A.tooth(px - ux, py - uy, rx, ry, 5.5 * sc, 2.2 * sc, 2, 0.4))
  local n = X.pillow(m, 1.6)
  A.toneN(c, m, n, LF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.12, wrap = 0.25 })
  for i = 0, 5 do local x, y = floor(px + ux * i + .5), floor(py + uy * i + .5) if m:has(x, y) then c:put(x, y, i < 2 and LF[3] or LF[5], ltok) end end
  for _, d in ipairs{ { lx, ly }, { rx, ry } } do
    for i = 1, 3 do local x, y = floor(px - ux + d[1] * i + .5), floor(py - uy + d[2] * i + .5) if m:has(x, y) then c:put(x, y, LF[5], ltok) end end
  end
  for i = 0, 3 do local x, y = floor(tx + ux * i + .5), floor(ty + uy * i + .5) c:put(x, y, i < 2 and ST[4] or LF[2], ltok) end
end
crown(17, 24, -0.8, -1, 1.3)
crown(46, 25, 0.8, -1, 1.3)
crown(27, 20, -0.2, -1, 1.35)
crown(38, 22, 0.35, -1, 1.3)

-- stalks with ribs
for i, s in ipairs(stalks) do
  local vis = s.m:copy()
  local bias = {}
  for j = i + 1, #stalks do vis:cut(stalks[j].m) X.ao(bias, s.m, stalks[j].m, 1, -2) end
  local tok = { r = { name = "stalk" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.1, wrap = 0.3 }), ST, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, bias = bias, tok = tok })
  vis:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    local sn, t = s.S[k], s.T[k]
    local cur = idx[k] or 3
    for _, g in ipairs{ -0.42, 0.12, 0.62 } do
      if abs(sn - g) < 0.13 and t > 0.03 then c:put(x, y, ST[max(1, cur - 2)], tok)
      elseif sn < g and sn > g - 0.36 and t > 0.03 and cur >= 3 and cur < 6 and g < 0.5 then c:put(x, y, ST[cur + 1], tok) end
    end
  end)
  s.idx, s.vis, s.tok = idx, vis, tok
end
-- waxy specular streak on the front-left stalk
do local s = stalks[3]
  for _, t in ipairs{ 0.42, 0.45, 0.48, 0.51 } do
    local q = s.samp[floor(t * 160) + 1]
    local x, y = floor(q.x - q.px * q.w * 0.55 + .5), floor(q.y - q.py * q.w * 0.55 + .5)
    if s.vis:has(x, y) then c:put(x, y, t == 0.45 and SPEC or ST[6], s.tok) end
  end
end
-- bite: pale crunchy flesh on the bitten rim, darker inner wall, and a dangling fibre
do local s = stalks[2]
  local r1 = bite:grow(1):clip(s.vis)
  r1:each(function(x, y) c:put(x, y, FLESH, s.tok) end)
  bite:grow(2):clip(s.vis):cut(r1):each(function(x, y) c:put(x, y, ST[5], s.tok) end)
  for _, p in ipairs{ { 42, 40 }, { 43, 41 }, { 43, 42 }, { 44, 43 } } do c:put(p[1], p[2], ST[5], s.tok) end
end
-- cut base: flat pale cross-section ellipse with string dots
local cm = HP.ellipse(32, 56, 5.6, 1.6)
local ctok = { r = { name = "cut" } }
cm:each(function(x, y) c:put(x, y, (y > 56 or x > 35) and CUT[2] or CUT[3], ctok) end)
for _, p in ipairs{ { 28, 56 }, { 31, 55 }, { 34, 56 }, { 36, 55 } } do c:put(p[1], p[2], CUT[1], ctok) end
c:put(29, 55, CUT[4], ctok) c:put(30, 55, CUT[4], ctok)
A.save(c, NAME)
