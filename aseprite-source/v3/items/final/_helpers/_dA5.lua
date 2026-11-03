-- _dA5: helper for chunk dA5 first drafts (ico-globe .. ico-id-card). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, P = B.H, B.HP, B.X, dofile(DIR .. "/../../../lib/palette.lua")
local D = { B = B, H = H, HP = HP, X = X, P = P }
local floor, sqrt = math.floor, math.sqrt
function D.new(name) D.c = B.new(name) return D.c end
function D.lit(m, ramp, R, o) o = o or {} o.R = R or 2.5 return H.lit(D.c, m, ramp, o) end
D.ell, D.seam = B.ell, B.seam
function D.ln(x0, y0, x1, y1, hex, clip) B.ln(D.c, x0, y0, x1, y1, hex, clip) end
function D.sub(a, b) return a:copy():cut(b) end
function D.isect(a, b) return a:copy():clip(b) end
function D.px(x, y, h) D.c:px(x, y, h) end
function D.fill(m, h) D.c:fillMask(m, h) end
function D.disc(cx, cy, r) return D.ell(cx, cy, r, r) end
function D.ring(cx, cy, ro, ri) return D.sub(D.disc(cx, cy, ro), D.disc(cx, cy, ri)) end
-- pixels of m whose distance to (cx,cy) is in [d0,d1) get hex
function D.radial(m, cx, cy, d0, d1, hex)
  m:each(function(x, y) local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2) if d >= d0 and d < d1 then D.c:px(x, y, hex) end end)
end
-- 6-tone ramps (dark -> light)
D.STEEL = { "#2f3350", "#4d5275", "#74789a", "#9ea2bf", "#c9ccdf", "#f0f1fa" }
D.GOLD  = { "#7a3f1c", "#b0661c", "#d9921f", "#f2bb2e", "#fcd85a", "#fff09a" }
D.RED   = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.BLUE  = { "#1c2e5a", "#2a4a7a", "#3a6aa6", "#4a8acc", "#78b4ea", "#b6dcf6" }
D.GREEN = { "#14382f", "#1f5a44", "#2f8450", "#3fa862", "#6cc880", "#aeeaa0" }
D.CREAM = { "#8a6a5a", "#c9a98a", "#e6cfa8", "#f6e6bf", "#fff0cc", "#fffbe8" }
D.BRN   = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
D.ORG   = { "#8f4a1f", "#c26a24", "#e8872e", "#ff9f3c", "#ffbf5c", "#ffe08a" }
D.PURP  = { "#2e1a45", "#4a2463", "#6b3485", "#8e4fa6", "#b27cc4", "#d6aee0" }
D.INK, D.CR = "#2b1c26", "#fff4d6"
function D.fin() B.fin() end

function D.leaf(ax, ay, bx, by, w, ramp, v) return H.leaf(D.c, ax, ay, bx, by, w, ramp, v) end
-- heart mask centred cx,cy, half-width r
function D.heart(cx, cy, r)
  local m = D.ell(cx - r * .5, cy - r * .3, r * .58, r * .62):add(D.ell(cx + r * .5, cy - r * .3, r * .58, r * .62))
  m:add(D.c:poly({ {cx - r * 1.04, cy - r * .1}, {cx + r * 1.04, cy - r * .1}, {cx, cy + r * 1.0} }))
  return m
end
-- rotate mask about (cx,cy) by ang radians (nearest, inverse map)
function D.rot(m, cx, cy, ang)
  local o, ca, sa = HP.mask(), math.cos(ang), math.sin(ang)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa + cx, -dx * sa + dy * ca + cy
    if m:has(floor(u + .5), floor(v + .5)) then o:set(x, y) end
  end end
  return o
end
function D.poly2(pts) return D.c:poly(pts) end
function D.rect(a, b, c2, d) return D.c:rect(a, b, c2, d) end
return D
