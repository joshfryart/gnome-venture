-- Saffron Snip (sp-saffron-snip), perch sprite 36x36. Opus second pass (c05/opus2), hand-built at this size.
-- Bold and few: round saffron-gold body, three-petal lilac crocus cap with three crimson threads, pill eyes,
-- humming "o" mouth; small open scissors (two brass loops, steel blades) in the right hand.
-- quirk: the hum: a plum music note floating at the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-saffron-snip-perch", 36)

local GLD   = { "#5e2e14", "#93501e", "#c97a24", "#eaa431", "#f6c95a", "#fbe49a" }
local PET   = { "#3a2556", "#5a3a82", "#7f5aae", "#a582d0", "#c8aae6", "#e6d6f6" }
local THR   = { "#5a1218", "#9a1e22", "#d23a2a", "#f06a3a" }
local STEEL = { "#3a3e52", "#6a7088", "#a4aabc", "#dde0e8" }
local BRASS = { "#6a3a12", "#b0701e", "#e6aa3a", "#f8d27a" }
local NOTE  = { "#3a2244", "#6a3e78", "#9a6aac" }
local BNC   = "#7a5a8a"

c:groundShadow(17, 32, 8, 1.5)
for _, fx in ipairs({ 14, 20 }) do O.shade(c, c:ellipse(fx, 30.5, 2, 1.2), GLD, { R = 1, amb = .3, sep = GLD[1] }) end
local body = c:ellipse(17, 23.5, 7.5, 7)
O.shade(c, body, GLD, { sphere = { 15, 21, 9 }, amb = .3, wrap = .4, rim = true, bounce = BNC, bmax = 2 })

for _, t in ipairs({ { 16, 12, 13, 3 }, { 17, 11, 17, 2 }, { 18, 12, 21, 3 } }) do
  O.flat(c, c:line({ { t[1], t[2] }, { t[3], t[4] } }, 1), THR[3], "thread")
  O.dot(c, t[3], t[4], THR[4])
end
for i, pe in ipairs({ { { 10, 17 }, { 9, 12 }, { 10, 8 }, { 14, 11 }, { 15, 17 } }, { { 19, 17 }, { 20, 11 }, { 24, 8 }, { 25, 12 }, { 24, 17 } },
                     { { 14, 17 }, { 14, 11 }, { 17, 6 }, { 20, 11 }, { 20, 17 } } }) do
  local m = c:poly(pe)
  local bias = {} if i == 2 then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  O.shade(c, m, PET, { R = 1, bias = bias, amb = .3, wrap = .4, sep = PET[1], rim = true })
end
O.mark(c, { { 17, 10 }, { 17, 12 }, { 17, 14 }, { 11, 12 }, { 23, 12 } }, PET[3])
for x = 11, 23 do if c:get(x, 18) then O.mark(c, { { x, 18 } }, GLD[2]) end end

c:eyeSmall(13, 20) c:eyeSmall(19, 20)
O.dot(c, 11, 24, "#f5809f") O.dot(c, 23, 24, "#f5809f")
O.dots(c, { { 16, 24 }, { 17, 24 }, { 15, 25 }, { 18, 25 }, { 16, 26 }, { 17, 26 } }, P.ink) O.dots(c, { { 16, 25 }, { 17, 25 } }, "#a23a3a")

-- scissors
O.flat(c, c:line({ { 26, 22 }, { 30, 17 } }, 1), STEEL[3], "blade") O.dot(c, 30, 17, STEEL[4])
O.flat(c, c:line({ { 26, 22 }, { 31, 21 } }, 1), STEEL[2], "blade")
for _, L in ipairs({ { 24, 25 }, { 27, 26 } }) do
  local ring = c:ellipse(L[1], L[2], 1.5, 1.5) ring:cut(c:rect(L[1], L[2], L[1], L[2]))
  O.shade(c, ring, BRASS, { R = 1, amb = .4, cuts = { .35, .6, .85 }, sep = BRASS[1] })
end
O.dot(c, 26, 22, STEEL[1])

-- hum note
O.flat(c, c:rect(5, 10, 5, 14), NOTE[2], "note") O.flat(c, c:rect(6, 10, 7, 10), NOTE[2], "note")
O.flat(c, c:rect(3, 14, 4, 15), NOTE[2], "note") O.dot(c, 3, 14, NOTE[3])

O.shift(c, 0, 0)
O.done(c, "sp-saffron-snip-perch")
