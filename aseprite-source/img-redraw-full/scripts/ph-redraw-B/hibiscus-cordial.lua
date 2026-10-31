-- ph/hibiscus-cordial, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: a slim bottle with a tiny label is just "a red bottle" at 16 px, the flower (the specific thing) is 6 px.
-- Fix (hierarchy): a big five-petal hibiscus with a long stamen in front of a squat magenta bottle; the flower is the
-- first read, the bottle the second, the crown cap kept as the sibling-distinct detail.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "hibiscus-cordial", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local liquid = GV.ramp("#a81e50", { gloss = "#f6b8cf", dot = "#fde8f0", rim = "#d0407a" })
local petal = GV.ramp("#e8302a", { gloss = "#ffb080", dot = "#ffe0c0", rim = "#ff7a50" })
-- bottle (to the right, behind)
local bottle = c:rrect(28, 24, 54, 55, 8):add(c:rect(37, 10, 45, 26))
c:part(bottle, liquid, { gloss = { 32, 30 } })
c:fill(c:rect(38, 11, 44, 22), "#d8ecf0"); c:fill(c:rect(38, 11, 39, 22), "#fbfdfe")
c:part(c:rect(35, 6, 47, 10):add(c:ascii({ "x.x.x.x.x.x.x" }, 35, 11)), "stone", { gloss = false, cres = 2 })
-- hibiscus in front (lower left)
local cx, cy = 22, 40
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  local px, py = cx + math.cos(a) * 8, cy + math.sin(a) * 8
  c:part(c:ellipse(px, py, 7, 7), petal, { gloss = (i == 4) and { px - 3, py - 3 } or false, contact = false, contour = "#8a1a24" })
end
-- polish 1: a dark vein from the throat into each petal so five petals read, not a red blob
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  c:fill(c:line({ {cx, cy}, {math.floor(cx + math.cos(a) * 9 + 0.5), math.floor(cy + math.sin(a) * 9 + 0.5)} }, 1), "#ae2a2a")
end
c:fill(c:ellipse(cx, cy, 3, 3), "#8a1a24")
c:fill(c:line({ {cx, cy}, {cx + 9, cy - 9} }, 2), "#f2c0d0")
c:fill(c:rect(cx + 9, cy - 11, cx + 11, cy - 9), "#f5cf6a")
c:ground(36, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
