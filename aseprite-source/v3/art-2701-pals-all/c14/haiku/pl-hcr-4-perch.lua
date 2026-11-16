-- Whirl Pincer (pl-hcr-4), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-hcr-4-perch" }
local function R(v) return math.floor(v + 0.5) end
local arms = HP.mask()
for k = 0, 3 do
  local a = 0.6 + k * math.pi / 2
  local tx, ty = R(18 + 12 * math.cos(a)), R(18 + 12 * math.sin(a))
  arms:add(c:line({{18, 18}, {tx, ty}}, 3))
  arms:add(c:ellipse(tx, ty, 2, 2))
end
c:part(arms, "ember", {})
c:part(c:ellipse(18, 18, 6, 6), "gold", {})
c:eyeSmall(15, 16)
c:eyeSmall(20, 16)
c:px(17, 20, "#2b1c26")
c:px(18, 20, "#2b1c26")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-4-perch.aseprite", png = out .. "pl-hcr-4-perch.png" }
