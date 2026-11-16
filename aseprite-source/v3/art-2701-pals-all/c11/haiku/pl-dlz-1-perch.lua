-- Scalecrust Tot (pl-dlz-1), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Round moss scale-blob, hook knob, laughing grin, one scale flake leaving the back.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-dlz-1-perch" }

c:groundShadow(18, 33, 9, 1)
c:part(c:ellipse(13, 31, 2, 1), "wood", { band = 1 })
c:part(c:ellipse(23, 31, 2, 1), "wood", { band = 1 })
c:part(c:line({ { 18, 17 }, { 18, 14 }, { 21, 13 } }, 2), "moss", { band = 1 })
local body = c:ellipse(18, 24, 9, 7)
c:part(body, "moss")
for y = 21, 27, 3 do
  for x = 12, 24, 4 do
    local xx = x + ((y // 3) % 2) * 2
    if body:has(xx, y) then c:px(xx, y, "#3f9150") end
  end
end
c:eyeSmall(14, 22) c:eyeSmall(20, 22)
c:px(16, 27, INK) c:px(17, 28, INK) c:px(18, 28, INK) c:px(19, 28, INK) c:px(20, 27, INK)
c:part(c:poly{ { 27, 11 }, { 30, 9 }, { 31, 12 }, { 28, 13 } }, "moss", { band = 1, noshade = true })

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-1-perch.aseprite", png = out .. "pl-dlz-1-perch.png", scale = 1 }
