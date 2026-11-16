-- Bromeliad Bolt (rr-bromeliad-bolt), perch sprite 36x36. Opus third pass (c01/opus3), richness pass over opus2:
-- red-blushed leaf tips, a wavy silver scurf band on the urn below the face, a lapped centre seam, root lines,
-- and a frog with real red eyes and pupils.
-- Urn body with the face, five stiff crown leaves (3 px at the base, midrib line), a red heart, the water cup
-- as a two-tone blue lens with one glint. Cross ink brows over the pill eyes, clamped mouth with one tooth.
-- quirk: the thirsty tree frog, here a 4x3 lime blob with two red eye dots on the left leaf tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("rr-bromeliad-bolt-perch", 36)

local GRN  = { "#163a34", "#1f5a3e", "#2f7d44", "#4fa34e", "#86c862", "#c4e690" }
local RED  = { "#4a1428", "#7c1c34", "#b82c3c", "#e04848", "#f47c5c", "#fbb48a" }
local SEA  = { "#1d3f63", "#25628a", "#2f8fae", "#4fbcc4", "#8ee0d4", "#d2f6ea" }
local WOOD = { "#3a2228", "#5e3a2e", "#86563a", "#ad7a4c", "#d0a068", "#ecc890" }

c:groundShadow(18, 32, 10, 1.5)
for _, fx in ipairs({ 13, 23 }) do O.shade(c, c:ellipse(fx, 30, 2.5, 1.2), WOOD, { R = 1, amb = .25 }) end
local function leaf(p, w, ramp, tip)
  local m, n, T, S = O.tube(p, function(t) return w * (1 - t) ^ .8 + .3 end)
  local idx, tok = O.shadeN(c, m, n, ramp, { amb = .05, wrap = .25, sep = ramp[1], rim = true })
  O.tex(c, idx, tok, ramp, function(x, y, i) if math.abs(S[K(x, y)] or 1) < .3 and T[K(x, y)] < .8 then return 1 end end)
  if tip then for k, i in pairs(idx) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    if (T[k] or 0) > tip and c.own[y * c.w + x] == tok then c.pix[y * c.w + x] = RED[math.max(3, math.min(6, i))]:lower() end
  end end
end
leaf({ { 16, 17 }, { 15, 12 }, { 14, 8 }, { 14, 4 } }, 2, GRN, .8)
leaf({ { 20, 17 }, { 21, 12 }, { 23, 8 }, { 24, 5 } }, 2, GRN, .8)
leaf({ { 14, 18 }, { 11, 15 }, { 8, 13 }, { 5, 12 } }, 2, GRN)
leaf({ { 22, 18 }, { 25, 15 }, { 28, 13 }, { 31, 12 } }, 2, GRN)
leaf({ { 16, 17 }, { 14, 15 }, { 12, 14 }, { 10, 13 } }, 1.8, RED)
leaf({ { 20, 17 }, { 22, 15 }, { 24, 14 }, { 26, 13 } }, 1.8, RED)
O.shade(c, c:ellipse(18, 17, 5.5, 2), RED, { R = 1, amb = .2, sep = RED[1] })
for x = 14, 21 do O.dot(c, x, 17, x < 18 and SEA[4] or SEA[2]) O.dot(c, x, 16, SEA[1]) end
O.dot(c, 15, 17, SEA[6])
local body = c:ellipse(18, 24, 9, 6)
body:add(c:rect(12, 19, 24, 21):cut(c:rect(12, 19, 24, 18)))
local bI, bT = O.shade(c, body, GRN, { R = 4, amb = .1, wrap = .3, sep = GRN[1], rim = true, bounce = "#3f7a8a", bmax = 2 })
O.tex(c, bI, bT, GRN, function(x, y, i)
  if x == 18 and y > 19 and y < 26 then return -2 end
  if x == 17 and y > 19 and y < 26 then return 1 end
  if y == 28 + math.floor(math.sin(x * .7) + .5) and i >= 2 then return 1 end
end)
O.dots(c, { { 11, 28 }, { 13, 29 }, { 22, 29 }, { 24, 28 } }, "#a8c8a0")
O.dots(c, { { 12, 19 }, { 14, 19 }, { 15, 19 }, { 20, 19 }, { 22, 19 }, { 23, 19 } }, "#a8c8a0")
-- face
c:eyeSmall(13, 22)
c:eyeSmall(21, 22)
O.dots(c, { { 12, 20 }, { 13, 20 }, { 14, 21 } }, P.ink) O.dots(c, { { 23, 20 }, { 22, 20 }, { 21, 21 } }, P.ink)
O.dots(c, { { 16, 27 }, { 17, 26 }, { 18, 26 }, { 19, 26 }, { 20, 27 } }, P.ink) O.dot(c, 18, 27, "#f4ecd8")
O.dot(c, 11, 26, P.petal.base) O.dot(c, 25, 26, P.petal.base)
-- frog
O.flat(c, c:rect(4, 9, 7, 10), "#8cd84a", "frog") O.dots(c, { { 4, 10 }, { 7, 10 } }, "#5aa83a")
O.dots(c, { { 4, 8 }, { 7, 8 } }, "#e04848") O.dots(c, { { 5, 8 }, { 6, 8 } }, P.ink) O.dot(c, 4, 7, "#f89a80")

O.done(c, "rr-bromeliad-bolt-perch")
