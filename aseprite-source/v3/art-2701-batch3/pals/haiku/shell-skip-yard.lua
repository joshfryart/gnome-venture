-- Shell Skip (ss-shell-skip), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Wayfinder, common. A ribbed gold shell with a pink hermit body and stubby legs peeking out.
-- quirk: a pearl stuck on the top of its shell.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("shell-skip-yard", 64)

local SHELL = { "#51302b", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fbe6a8" }
local PET   = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

c:groundShadow(32, 57, 17, 3)

-- legs (behind the body)
local legs = c:line({ { 22, 46 }, { 15, 52 } }, 1.6)
legs:add(c:line({ { 42, 46 }, { 49, 52 } }, 1.6))
legs:add(c:line({ { 24, 49 }, { 20, 55 } }, 1.4))
legs:add(c:line({ { 40, 49 }, { 44, 55 } }, 1.4))
O.shade(c, legs, PET, { R = 1, amb = .3, sep = PET[1] })

-- ribbed shell dome, flat base at y 39
local shell = c:ellipse(32, 30, 19, 15)
shell:cut(c:rect(0, 40, 63, 63))
O.shade(c, shell, SHELL, { sphere = { 28, 26, 17 }, amb = .2, wrap = .3, sep = SHELL[1] })
local ribs = {}
for _, a in ipairs({ -160, -130, -100, -70, -40, -20 }) do
  for r = 7, 17 do
    ribs[#ribs + 1] = { math.floor(32 + r * math.cos(math.rad(a)) + .5), math.floor(39 + r * math.sin(math.rad(a)) + .5) }
  end
end
O.mark(c, ribs, SHELL[2])
-- spiral ring on the shell side
O.dots(c, { { 40, 30 }, { 41, 30 }, { 42, 31 }, { 41, 32 } }, SHELL[2])

-- quirk: pearl on the top
O.dots(c, { { 25, 8 }, { 26, 8 }, { 25, 9 }, { 26, 9 } }, "#fff4d6")

-- hermit body with a designed nose and face
local body = c:ellipse(32, 44, 11, 6)
O.shade(c, body, PET, { R = 2, amb = .3, sep = PET[1] })
c:eyeLocked(25, 41)
c:eyeLocked(37, 41)
c:cheek(22, 46) c:cheek(39, 46)
O.dots(c, { { 31, 44 }, { 32, 44 } }, PET[1])
O.dots(c, { { 30, 47 }, { 31, 48 }, { 32, 48 }, { 33, 47 } }, P.ink)

O.done(c, "shell-skip-yard")
