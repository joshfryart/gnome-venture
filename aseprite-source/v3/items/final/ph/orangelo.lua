-- orangelo (final, Opus aC31_2 single pass). Grapefruit x orange hybrid: a big yellow-orange citrus with a soft short
-- neck (slightly pear-shaped), pitted peel (oil-gland pores lit/shadowed per pixel), waxy bloom, one specular, cool
-- reflected light on the lower right. Short woody stem in a star calyx, one glossy leaf with a winged petiole.
-- quirk: a tiny ladybird is out for a walk on the leaf.
local NAME = "orangelo"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local R = A.OLO

-- body: round base + soft neck
local body = c:ellipse(31, 39, 15, 14)
body:add(c:ellipse(30.5, 29, 9, 6.5))
for y = 24, 36 do for x = 18, 44 do                       -- smooth the shoulder between neck and body
  local w = 9 + (y - 24) * 0.55
  if y >= 27 and abs(x - 30.5) <= w and y <= 33 then body:set(x, y) end
end end
local ns = X.sphere(30.5, 37, 16.5, body)
local np = X.pillow(body, 6)
local n = {}
for k, a in pairs(ns) do local b = np[k] or a
  local x, y, z = a[1] * 0.6 + b[1] * 0.4, a[2] * 0.6 + b[2] * 0.4, a[3] * 0.6 + b[3] * 0.4
  local l = sqrt(x*x + y*y + z*z) n[k] = { x / l, y / l, z / l } end
local bias = {}
local dimple = c:ellipse(30.5, 23.5, 2.5, 1.2)
X.ao(bias, body, dimple, 2, -1)
local tok = { r = { name = "peel" } }
local idx = A.shade(c, body, n, R, { bias = bias, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.05, wrap = 0.2 })
-- peel pores: pit (darker) with a lit lip up-left
body:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if X.hash(x, y, 21) < 0.065 and body:has(x - 1, y - 1) and i >= 2 then
    c:put(x, y, R[i - 1], tok)
    if i <= 5 then c:put(x - 1, y - 1, R[i + 1], tok) end
  end
end)
-- grapefruit blush on the lower left / faint pink cast
body:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 22, y - 46
  if dx*dx + dy*dy < 22 and idx[k] == 4 and X.hash(x, y, 5) < 0.55 then c:put(x, y, "#f29a4a", tok) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.7 then c:put(x, y, "#9c6a78", tok) end end)
body:shrink(1):edge():each(function(x, y) if rim[K(x, y)] > 0.82 and (idx[K(x, y)] or 3) <= 2 then c:put(x, y, "#7a4c62", tok) end end)
-- waxy bloom: pale specks across the lit shoulder, and the one specular
for _, p in ipairs{ { 21, 33 }, { 24, 30 }, { 19, 38 }, { 26, 35 } } do c:put(p[1], p[2], R[6], tok) end
c:put(22, 31, "#fffbe6") c:put(23, 31, "#fffbe6") c:put(22, 32, R[6])

-- stem nub + star calyx
local wtok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 31, 23 }, { 31, 20 }, { 32, 18 }, { 34, 16 } }, function(t) return 1.2 - 0.3 * t end)
A.shade(c, sm, sn, A.WOOD, { cuts = { 0.3, 0.55, 0.8 }, tok = wtok })
c:put(34, 15, A.WOOD[3], wtok) c:put(35, 15, A.WOOD[4], wtok)   -- pale cut end
local CAL = { "#2c4a30", "#4a7a3e", "#78a84c" }
for _, q in ipairs{ { 28, 24, 2 }, { 29, 24, 3 }, { 30, 24, 3 }, { 31, 24, 2 }, { 32, 24, 2 }, { 33, 24, 1 }, { 34, 25, 1 },
  { 27, 25, 1 }, { 30, 25, 2 }, { 32, 25, 1 }, { 29, 23, 3 } } do c:put(q[1], q[2], CAL[q[3]], wtok) end

-- leaf with a winged petiole, springing right from the stem
local lm, LT, LS = A.leaf(c, 33, 17, 44, 7, 57, 12, 5.2, { wing = 0.24, per = 3.6, name = "leaf" })
-- quirk: ladybird on the leaf (red shell, ink spots + head, glint)
local LB = { "#7a1c2c", "#c22a2e", "#ee4a3a", "#ff8a6a" }
c:paint({
  ".hh.",
  "rRRr",
  "RsRR",
  "rRsr",
  ".rr.",
}, 47, 9, { h = "#2b1c26", R = LB[3], r = LB[2], s = "#2b1c26" })
c:put(48, 10, LB[4])

A.save(c, NAME)
