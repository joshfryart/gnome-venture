-- ico-petal: the Petals currency icon (replaces ico-coin for 🪙). One cherry-blossom petal, tip down-left, notch top-right.
-- Run (repo root): AppRun -b --script-param root=<repo>/ --script-param out=<outdir>/ --script aseprite-source/final/scripts/ico/ico-petal.lua
local R = app.params["root"]; local O = app.params["out"]
local GV = dofile(R .. "aseprite-source/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local lobe = c:ellipse(36.5, 27.5, 17, 16)
local body = c:mask():add(lobe):add(c:poly({ {12, 56}, {23, 17}, {50, 39} }))
body = body:closed(3)
body:cut(c:poly({ {42, 6}, {56, 10}, {46, 21} }))          -- the petal notch
local petal = GV.ramp("#e46a9b", { gloss = "#f6b8cf", rim = "#f6b8cf" })
c:build{ { "petal", body, petal, { gloss = { 27, 18 } } } }
-- a soft vein from the tip toward the notch
c:fill(c:line({ {19, 48}, {29, 36}, {38, 26} }, 2), "#c44a7e")
c:fill(c:line({ {30, 33}, {33, 29} }, 1), "#f6b8cf")
local t = c:save(O .. "ico-petal.aseprite", O .. "ico-petal.png")
print(GV.report(t))
