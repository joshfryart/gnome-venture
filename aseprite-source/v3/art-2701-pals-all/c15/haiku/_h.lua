-- c15/haiku helper: a thin wrapper over the v3 lib (hp.lua) for this batch only.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local H = { HP = HP, P = HP.P, out = app.params.out or (dir .. "/") }

function H.canvas(name, size) return HP.canvas{ w = size, h = size, scale = 1, name = name } end

-- wooden perch ledge along the bottom of a 36 px perch sprite
function H.ledge(c) c:part(c:rrect(2, 32, 33, 34, 1), "wood") end

function H.done(c, name)
  c:finish{ outline = true }
  HP.assertClean(c)
  c:save{ aseprite = H.out .. name .. ".aseprite", png = H.out .. name .. ".png", scale = 1 }
end

return H
