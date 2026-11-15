-- Fourwind Finch (mw-fourwind-finch), perch sprite 36x36. Opus pass, drawn at this size by hand:
-- round rosy finch, slate cap, chestnut wings with one cream bar each, pill eyes, 3px beak.
-- quirk: the compass tail, four slate feathers fanned out to the right, the north one red-tipped.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("fourwind-finch-perch", 36)

local SLATE = { "#26314f", "#384a78", "#506a9e", "#7090c0", "#98b4da", "#c4d8ee" }
local ROSE  = { "#7a3040", "#a84a50", "#d06c60", "#e8907a", "#f6b49a", "#fcd6c0" }
local BRN   = { "#4a2a26", "#6e3c2e", "#94573a", "#b5764a", "#d09864", "#e8bc88" }
local BEAK  = { "#6e4a2a", "#a87838", "#d8a848", "#f0cc70", "#fbe6a4" }
local LEG   = { "#7a4a4a", "#b07468", "#d49a88" }

c:groundShadow(16, 33, 9, 2)

local base = { 20, 24 }
local angs, lens = { -64, -28, 6, 40 }, { 16, 14, 12.5, 10.5 }
local tips = { "#e8493b", "#f5e6c0", "#f5e6c0", "#f5e6c0" }
for i, a in ipairs(angs) do
  local r = math.rad(a)
  local L = lens[i]
  local ex, ey = base[1] + math.cos(r) * L, base[2] + math.sin(r) * L
  local fm, fn, fT = O.tube({ base, { base[1] + math.cos(r) * L * .4, base[2] + math.sin(r) * L * .4 },
    { base[1] + math.cos(r) * L * .7, base[2] + math.sin(r) * L * .7 }, { ex, ey } }, function(t)
    if t > .62 then return math.max(.3, 1.9 * (1 - (t - .62) / .38) ^ .8) end
    return .9 + 1.0 * t / .62 end)
  O.shadeN(c, fm, fn, SLATE, { amb = .3, wrap = .4, sep = SLATE[1] })
  fm:each(function(x, y) if (fT[K(x, y)] or 0) > .8 then O.mark(c, { { x, y } }, tips[i]) end end)
end

for _, x in ipairs({ 13, 18 }) do
  O.dots(c, { { x, 29 }, { x, 30 }, { x, 31 } }, LEG[2])
  O.dots(c, { { x - 1, 32 }, { x, 32 }, { x + 1, 32 } }, LEG[2]) O.dot(c, x - 1, 32, LEG[3])
end

local body = c:ellipse(15.5, 22, 8, 7.5)
local head = c:ellipse(15.5, 13, 6.5, 6)
O.shade(c, body:copy():add(head), ROSE, { sphere = { 14, 17, 11 }, amb = .2, wrap = .35 })
local cap = head:copy():clip(c:rect(0, 0, 35, 10)):add(head:copy():clip(c:poly{ { 8, 11 }, { 11, 10 }, { 20, 10 }, { 23, 11 }, { 23, 8 }, { 8, 8 } }))
O.shade(c, cap, SLATE, { sphere = { 14, 12, 7 }, amb = .3, wrap = .35 })
local belly = c:ellipse(15.5, 26, 4, 2.5):clip(body)
O.shade(c, belly, { ROSE[4], ROSE[5], ROSE[6], "#fde8d8", "#fdf0e0" }, { R = 1, amb = .45 })

local function wing(s)
  local m = function(x) return 15.5 + s * (x - 15.5) end
  local w = c:poly{ { m(9), 18 }, { m(7), 22 }, { m(8), 27 }, { m(10), 28 }, { m(11), 21 } }
  w:clip(body:grow(1))
  O.shade(c, w, BRN, { R = 1, amb = .3, sep = BRN[1] })
  for x = math.floor(math.min(m(7), m(11))), math.ceil(math.max(m(7), m(11))) do
    if w:has(x, 23) then O.mark(c, { { x, 23 } }, "#f5e6c0") end
  end
end
wing(1) wing(-1)

O.dots(c, { {14,16},{15,16},{16,16},{17,16},{15,17},{16,17} }, BEAK[3])
O.dots(c, { {14,16} }, BEAK[5]) O.dots(c, { {17,16},{16,17} }, BEAK[2])
c:eyeSmall(11, 12)
c:eyeSmall(19, 12)
O.dot(c, 10, 16, "#f5809f") O.dot(c, 21, 16, "#f5809f")

O.shift(c, -1, -1)
O.done(c, "fourwind-finch-perch")
