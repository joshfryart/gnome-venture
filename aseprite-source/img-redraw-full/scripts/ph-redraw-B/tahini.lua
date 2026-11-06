-- ph/tahini, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: pale tin + pale paper + pale seeds = one cream blob at 16 px; nothing says "sesame". Fix (bolder,
-- colorize): a deep teal wrapper that no other pantry jar uses, one huge cream sesame seed as the emblem, the silver
-- tin kept only as rims, and a pull-ring standing up so the "tin" read survives.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "tahini", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#aab2bc", { rim = "#dfe4ea", gloss = "#f4f6f8", dot = "#fbfdfe" })
local teal = GV.ramp("#1f7a7a", { gloss = "#a8e0d0", dot = "#e0f6ee", rim = "#3fa0a0" })
local sesame = GV.ramp("#f2e2b8", { rim = "#fff3c8", gloss = "#fff3c8", dot = "#fbf6e8" })
c:part(c:rrect(17, 17, 47, 56, 4), tin, { gloss = false })
c:part(c:rect(17, 23, 47, 50), teal, { gloss = { 20, 27 }, contact = false })
-- one big sesame seed, point up, with a ridge
local seed = c:ellipse(32, 40, 8, 8):add(c:poly({ {26, 36}, {38, 36}, {32, 26} }))
c:part(seed, sesame, { gloss = { 28, 35 }, contour = "#2a3c4c", contact = false })
c:fill(c:line({ {32, 30}, {32, 45} }, 1), "#d6b98a")
-- three tiny seeds scattered
for _, s in ipairs({ {21, 28}, {42, 30}, {42, 45} }) do c:paint({ ".s", "ss", "s." }, s[1], s[2], { s = "#f2e2b8" }) end
-- tin lid rim and standing pull-ring
c:fill(c:rect(18, 18, 46, 18), "#dfe4ea")
local ring = c:ellipse(32, 11, 6, 5):cut(c:ellipse(32, 11, 3, 2)):add(c:rect(30, 15, 34, 17))
c:part(ring, tin, { flat = true, contact = false })
c:ground(32, 57, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
