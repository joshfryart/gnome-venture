-- ph/radish-kimchi, redraw A (2.2.1 leftovers, Opus medium): tall onggi with sloped shoulders and a knob lid,
-- a bright red paste run down the front, white radish cubes at the foot.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "radish-kimchi", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glaze = GV.ramp("#8a5428", { gloss = "#e8b07a", dot = "#f8d8b0", rim = "#b07a45" })
local chili = GV.ramp("#d8322a")
local body = c:ellipse(30, 38, 17, 17):add(c:poly({ {22, 14}, {39, 14}, {44, 26}, {16, 26} }))
c:part(body, glaze, { gloss = { 18, 30 } })
c:part(c:rrect(20, 11, 41, 15, 2), glaze, { gloss = false, cres = 2 })
c:part(c:rrect(27, 7, 34, 11, 2), glaze, { flat = true })
-- red paste spilling from under the lid and running down the front
local run = c:rect(21, 15, 40, 18):add(c:line({ {26, 18}, {26, 27} }, 4)):add(c:line({ {33, 18}, {34, 31} }, 4))
run:add(c:ellipse(26.5, 28, 2.5, 2.5)):add(c:ellipse(34.5, 32, 2.5, 3))
c:part(run, chili, { flat = true, contact = false, contour = "#6b1b2c" })
c:px(26, 21, "#ff9158"); c:px(33, 22, "#ff9158")
-- radish cubes (white, red-stained) piled at the foot
local cube = GV.ramp("#f6eee0", { rim = "#fff3c8" })
for _, q in ipairs({ { 37, 47 }, { 44, 48 }, { 40, 42 } }) do
  local m = c:rrect(q[1], q[2], q[1] + 6, q[2] + 6, 1)
  c:part(m, cube, { flat = true })
  c:fill(c:rect(q[1] + 4, q[2] + 1, q[1] + 6, q[2] + 6), "#e0503a")
  c:fill(c:rect(q[1], q[2] + 5, q[1] + 6, q[2] + 6), "#b8452f")
end
c:ground(32, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
