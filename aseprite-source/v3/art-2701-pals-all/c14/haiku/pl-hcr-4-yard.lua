-- Whirl Pincer (pl-hcr-4), yard 64x64. Haiku first pass.
-- Thornblade, uncommon. Four pincers spun into a whirl and stuck together.
-- quirk: motion ticks at the four corners.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-hcr-4-yard" }
local function R(v) return math.floor(v + 0.5) end
local cx, cy = 32, 32
local arms = HP.mask()
for k = 0, 3 do
  local a = 0.6 + k * math.pi / 2
  local tx, ty = R(cx + 22 * math.cos(a)), R(cy + 22 * math.sin(a))
  arms:add(c:line({{cx, cy}, {tx, ty}}, 5))
  arms:add(c:ellipse(tx, ty, 4, 4))
end
c:part(arms, "ember", {})
c:part(c:ellipse(cx, cy, 9, 9), "gold", {})
c:eyeLocked(25, 29)
c:eyeLocked(34, 29)
c:paint({ "iii" }, 30, 37, { i = "#2b1c26" })
c:px(4, 4, "#b9e2f5")
c:px(59, 4, "#b9e2f5")
c:px(4, 59, "#b9e2f5")
c:px(59, 59, "#b9e2f5")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-4-yard.aseprite", png = out .. "pl-hcr-4-yard.png" }
