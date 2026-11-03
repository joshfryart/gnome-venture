-- carob (first draft, Sonnet). quirk: one pod is snapped, showing seeds in the pulp
local NAME = "carob"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local CR = { "#2a1410", "#4a2418", "#6e3a22", "#8e5430", "#b0743e", "#d09a5c" }
local m, T = H.sweep({ {8, 52}, {14, 24}, {40, 20}, {52, 10} }, function(t) return 4.2 - t * 1.2 end)
local n = {}
X.tone(c, m, X.light(X.pillow(m, 3.5), { amb = 0.08, wrap = 0.25 }), CR, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
-- bumps for seeds
m:each(function(x, y) if T[B.K(x, y)] and floor(T[B.K(x, y)] * 14) % 2 == 0 and (x + y) % 5 == 0 then c:px(x, y, CR[3]) end end)
-- stem
B.ln(c, 8, 52, 6, 57, CR[2]) B.ln(c, 9, 52, 7, 57, CR[1])
-- cut section at tip? snapped gap
local gap = c:poly{ {10, 36}, {20, 34}, {19, 37}, {11, 40} }
-- second pod piece lower right
local m2, T2 = H.sweep({ {26, 58}, {38, 52}, {48, 52}, {58, 46} }, function(t) return 3.6 - t end)
X.tone(c, m2, X.light(X.pillow(m2, 3), { amb = 0.08, wrap = 0.25 }), CR, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
-- broken end showing pulp + seeds
c:fillMask(B.ell(27, 57, 2, 3.4, 0), "#d8b070")
c:px(27, 56, "#4a2418") c:px(27, 58, "#4a2418") c:px(26, 57, "#f0d8a0")
D.chip(c, 14, 50, 1.6, 1.2, CR, 0.5)
-- glint
c:px(15, 30, "#f0c88a") c:px(16, 29, "#f0c88a") c:px(42, 50, "#f0c88a")
D.fin()
