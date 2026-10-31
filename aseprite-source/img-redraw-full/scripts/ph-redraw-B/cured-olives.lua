-- ph/cured-olives, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: the amphora is the star and the olives are tiny dots on its shoulder; at 16 px it is "a brown jug".
-- Fix (distill to the product): a shallow terracotta dish heaped with five big glossy olives (black, green, purple)
-- and a silver-green olive sprig on top. Olives, not pottery, are the read.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "cured-olives", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local terra = GV.ramp("#d8743a")
local black = GV.ramp("#3a2a4a", { gloss = "#b8a4e0", dot = "#e8dcf8", rim = "#5e4a7a" })
local purple = GV.ramp("#6a2a50", { gloss = "#e09ac0", dot = "#f8d8e8", rim = "#904070" })
local green = GV.ramp("#8aa83a", { gloss = "#e8f0a0", dot = "#f6fad8", rim = "#a8c050" })
local leaf = GV.ramp("#7a9a6a", { rim = "#a8c098" })
-- sprig behind the heap
c:part(c:line({ {20, 16}, {30, 22}, {44, 20} }, 2), "wood", { flat = true, contact = false })
for _, l in ipairs({ { {20, 15}, {14, 12} }, { {26, 19}, {24, 12} }, { {36, 21}, {40, 14} }, { {44, 20}, {50, 17} } }) do
  c:part(c:line(l, 3), leaf, { flat = true, contact = false })
end
-- olives, back to front
for _, o in ipairs({ { 22, 29, black }, { 42, 29, green }, { 32, 26, purple }, { 17, 37, green }, { 32, 35, black }, { 46, 37, purple } }) do
  c:part(c:ellipse(o[1], o[2], 6, 5), o[3], { gloss = { o[1] - 3, o[2] - 3 }, contact = false })
end
-- shallow dish
local dish = c:ellipse(32, 42, 23, 12):cut(c:rect(0, 0, 63, 41))
c:part(dish, terra, { gloss = { 12, 44 } })
c:fill(c:rect(8, 42, 56, 43):clip(dish), "#f6e3c0")
c:ground(32, 56, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
