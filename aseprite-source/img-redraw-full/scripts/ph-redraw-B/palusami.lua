-- ph/palusami, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: a closed green dome on a green leaf read as a hat (green on green, no product visible). Fix (show the
-- product, value contrast): the parcel served open, its taro leaves peeled back in four points around a pool of white
-- coconut cream, on a pale banana-leaf plate. Dark green petals + white centre reads at 16 px.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "palusami", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local banana = GV.ramp("#c8dc80", { gloss = "#f0f8c8" })
local taro = GV.ramp("#2f7040", { gloss = "#a8d890", dot = "#d8f0c0", rim = "#4a9a50" })
local cream = GV.ramp("#f6f0e0", { gloss = "#fff3c8", dot = "#fbfdfe", rim = "#fbf6e8", pale = false })
c:part(c:ellipse(32, 47, 23, 9), banana, { gloss = false, cres = 2 })
c:fill(c:line({ {11, 47}, {53, 47} }, 1), "#9ab84a")
-- peeled-back leaf points (behind), then the parcel body
local pts = c:poly({ {11, 30}, {22, 26}, {24, 34} }):add(c:poly({ {53, 30}, {42, 26}, {40, 34} }))
pts:add(c:poly({ {24, 16}, {32, 22}, {22, 26} })):add(c:poly({ {41, 15}, {42, 26}, {32, 22} }))
c:part(pts, taro, { flat = true, contact = false })
local body = c:ellipse(32, 38, 18, 13)
c:part(body, taro, { gloss = false })
for _, l in ipairs({ { {20, 34}, {26, 46} }, { {44, 34}, {38, 46} }, { {32, 40}, {32, 50} } }) do c:fill(c:line(l, 1):clip(body:shrink(1)), "#1f5030") end
-- cream pool in the open top, a drip over the front
local pool = c:ellipse(32, 31, 12, 6)
c:part(pool, cream, { gloss = { 25, 29 }, contour = "#4a2c1a" })
c:part(c:line({ {37, 36}, {37, 41} }, 3):add(c:ellipse(37, 42, 2, 2)), cream, { flat = true, contact = false, contour = false })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
