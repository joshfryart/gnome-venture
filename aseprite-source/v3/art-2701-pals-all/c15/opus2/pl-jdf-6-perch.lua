-- Lotus Perch (pl-jdf-6), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- Pointed pink lotus in three layers (deeper back petals, two side petals, a broad front petal with 2x3 pill
-- eyes), deeper pink tips, a gold stamen hint, on a notched lily pad.
-- quirk: a tiny jade dragonfly naps on its head, "z" above.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-6-perch", 36)

local PET  = { "#7d2c5e", "#b8477a", "#e06e98", "#f59ab8", "#ffc4d8", "#ffe8ee" }
local PAD  = { "#1d4a3c", "#2c6c46", "#3f9150", "#64b45c", "#9cd477", "#d0ec9e" }
local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }

local pad = c:ellipse(18, 29, 14, 3.5)
pad:cut(c:poly{ { 25, 29 }, { 34, 26 }, { 34, 28 } })
O.shade(c, pad, PAD, { R = 3, amb = .3, wrap = .4, rim = true })

local function petal(base, tip, W, back)
  local bx, by, tx, ty = base[1], base[2], tip[1], tip[2]
  local pts = { { bx, by }, { bx + (tx - bx) * .35, by + (ty - by) * .35 }, { bx + (tx - bx) * .75, by + (ty - by) * .75 }, { tx, ty } }
  local m, n, T = O.tube(pts, function(t) return math.max(.4, W * (math.sin(math.pi * math.min(1, .12 + .88 * t)) ^ .75)) end)
  local I, Tk = O.shadeN(c, m, n, PET, { amb = .4, wrap = .5, rim = true, sep = PET[2] })
  O.tex(c, I, Tk, PET, function(x, y, i)
    local t = T[K(x, y)] or 0
    if t > .75 then return -1 + (back or 0) end
    return back
  end)
end
petal({ 16, 24 }, { 6, 12 }, 3, -2)
petal({ 20, 24 }, { 30, 12 }, 3, -2)
petal({ 17, 23 }, { 12, 6 }, 3, -2)
petal({ 19, 23 }, { 24, 6 }, 3, -2)
O.flat(c, c:rect(14, 12, 22, 13), "#f5b82e", "stamen") O.dots(c, { { 15, 12 }, { 17, 12 }, { 19, 12 }, { 21, 12 } }, "#ffe38a")
petal({ 16, 27 }, { 4, 18 }, 3.5)
petal({ 20, 27 }, { 32, 18 }, 3.5)
petal({ 18, 29 }, { 18, 10 }, 6.5)

c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
O.dot(c, 12, 21, P.petal.base) O.dot(c, 24, 21, P.petal.base)
O.mark(c, { { 17, 22 }, { 18, 22 } }, P.ink)

-- napping dragonfly on the head
O.flat(c, c:rect(17, 9, 24, 9), JADE[3], "fly") O.dots(c, { { 20, 9 }, { 23, 9 } }, "#f5b82e")
O.flat(c, c:rect(15, 8, 16, 9), JADE[4], "flyh") O.dot(c, 15, 9, P.ink)
O.flat(c, c:rect(18, 7, 22, 7), "#cdf0e6", "w") O.dot(c, 22, 7, "#a6dcd8")

O.done(c, "pl-jdf-6-perch", function(c)
  for _, p in ipairs({ { 12, 2 }, { 13, 2 }, { 14, 2 }, { 13, 3 }, { 12, 4 }, { 13, 4 }, { 14, 4 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], P.ink) end end
end)
