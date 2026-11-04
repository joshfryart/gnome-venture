-- _dA3: helper for chunk dA3 first drafts (ico-cog .. ico-duck). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, P = B.H, B.HP, B.X, dofile(DIR .. "/../../../lib/palette.lua")
local D = { B = B, H = H, HP = HP, X = X, P = P }
local floor, sqrt = math.floor, math.sqrt
function D.new(name) D.c = B.new(name) return D.c end
function D.lit(m, ramp, R, o) o = o or {} o.R = R or 2.5 return H.lit(D.c, m, ramp, o) end
D.ell, D.ln, D.poly, D.seam = B.ell, B.ln, B.polyline, B.seam
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
return D
