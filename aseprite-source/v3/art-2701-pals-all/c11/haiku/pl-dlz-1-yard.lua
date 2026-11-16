-- Scalecrust Tot (pl-dlz-1), yard 64x64. Haiku first pass (c11/haiku).
-- Common, rootwarden, hook knob. "A tiny scale that flakes off every time it laughs."
-- quirk: it is laughing, and a scale flake is leaving its back.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-dlz-1-yard" }

c:groundShadow(32, 57, 16, 3)
c:part(c:ellipse(23, 52, 5, 3), "wood", { band = 1 })
c:part(c:ellipse(41, 52, 5, 3), "wood", { band = 1 })
c:part(c:line({ { 32, 28 }, { 32, 21 }, { 37, 19 } }, 2), "moss", { band = 1 })   -- hook knob
local body = c:ellipse(32, 40, 16, 13)
c:part(body, "moss")
-- scale rows (offset every other row)
for y = 30, 50, 5 do
  for x = 20, 44, 6 do
    local xx = x + ((y // 5) % 2) * 3
    if body:has(xx, y) then c:px(xx, y, "#3f9150") end
  end
end
c:eyeLocked(24, 36) c:eyeLocked(36, 36)
c:cheek(20, 44) c:cheek(42, 44)
-- open laughing mouth
c:px(28, 45, INK) c:px(29, 46, INK) c:px(30, 46, INK) c:px(31, 46, INK)
c:px(32, 46, INK) c:px(33, 46, INK) c:px(34, 46, INK) c:px(35, 45, INK)
-- the flake leaving its back, and a tiny trail
c:part(c:poly{ { 48, 20 }, { 52, 17 }, { 54, 21 }, { 50, 24 } }, "moss", { band = 1, noshade = true })
c:px(57, 13, "#7cc35a") c:px(59, 10, "#7cc35a")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-1-yard.aseprite", png = out .. "pl-dlz-1-yard.png", scale = 1 }
