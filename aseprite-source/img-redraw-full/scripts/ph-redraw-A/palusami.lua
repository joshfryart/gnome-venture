-- ph/palusami, redraw A (2.2.1 leftovers, Opus medium): taller dark taro dome (no brim) on a small banana leaf,
-- a lighter veined leaf folded down to a point at the front, a white cream V and a cream pool.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "palusami", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local banana = GV.ramp("#b4d070", { gloss = "#eef6c0" })
local taro = GV.ramp("#2f7040", { gloss = "#a8d890", dot = "#d8f0c0", rim = "#4a9a50" })
local fold = GV.ramp("#6aae4a", { gloss = "#d8f0a0", dot = "#f0f8d8" })
local cream = "#f6f0e0"
c:part(c:ellipse(32, 50, 24, 6), banana, { gloss = false, cres = 2 })
c:fill(c:line({ {10, 50}, {54, 50} }, 1), "#8aa83a")
local dome = c:ellipse(32, 36, 19, 16):cut(c:rect(0, 49, 63, 63))
c:part(dome, taro, { gloss = { 17, 30 } })
-- folded leaf: rounded top coming down to a point at the front
local lf = c:ellipse(32, 29, 15, 10):add(c:poly({ {18, 30}, {46, 30}, {32, 46} }))
c:part(lf, fold, { gloss = { 22, 23 } })
c:fill(c:line({ {32, 21}, {32, 44} }, 1), "#3f7a30")
for _, v in ipairs({ { {32, 27}, {23, 23} }, { {32, 27}, {41, 23} }, { {32, 34}, {24, 31} }, { {32, 34}, {40, 31} } }) do c:fill(c:line(v, 1), "#3f7a30") end
-- cream oozing along the fold edges and dripping from the tip
c:fill(c:line({ {19, 33}, {32, 47} }, 2), cream)
c:fill(c:line({ {45, 33}, {32, 47} }, 2), cream)
c:part(c:ellipse(34, 52, 8, 2), GV.ramp(cream), { flat = true, contact = false })
c:fill(c:rect(32, 47, 33, 50), cream)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
