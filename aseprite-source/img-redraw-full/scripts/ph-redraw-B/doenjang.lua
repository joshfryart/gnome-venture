-- ph/doenjang, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: dark crock, grey lid, dark rope: the paste (the product) is never seen, and the chilies are specks. Fix
-- (distill + hierarchy): lid off, a domed mound of ochre bean paste with a wooden paddle in it, the straw geumjul rope
-- across the dark crock with ONE big red chili as the colour accent.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "doenjang", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glaze = GV.ramp("#4a2618", { gloss = "#c8865a", dot = "#f2c8a0", rim = "#7a3e24" })
local paste = GV.ramp("#d89a3a", { gloss = "#fbe2a0", dot = "#fff6d8", rim = "#f0b85a" })
-- paddle behind the paste
c:part(c:line({ {43, 8}, {38, 24} }, 3):add(c:rrect(34, 20, 42, 28, 2)), "wood", { flat = true, contact = false })
-- paste mound
local mound = c:ellipse(32, 26, 17, 8):cut(c:rect(0, 30, 63, 63))
c:part(mound, paste, { gloss = { 22, 21 } })
for _, p in ipairs({ {24, 25}, {30, 22}, {37, 26}, {41, 24}, {27, 28}, {34, 28} }) do c:px(p[1], p[2], "#7a4a1f"); c:px(p[1] + 1, p[2], "#8a5a24") end
-- crock: wide and low, thick lip
local body = c:ellipse(32, 41, 23, 15):cut(c:rect(0, 0, 63, 30))
c:part(body, glaze, { gloss = { 13, 37 } })
c:part(c:rrect(11, 28, 53, 33, 2), glaze, { flat = true, contact = false })
-- straw rope across the front with one big chili
local rope = c:line({ {11, 37}, {22, 41}, {32, 42}, {42, 41}, {53, 37} }, 3)
c:part(rope, GV.ramp("#e8cc6a"), { flat = true, contact = false })
for x = 12, 52, 4 do for yy = 34, 46 do if rope:has(x, yy) then c:px(x, yy + 1, "#b8941a"); break end end end
c:part(c:line({ {33, 43}, {35, 48}, {32, 53} }, 6):add(c:ellipse(33, 44, 3, 2)), "red", { flat = true, contact = false, contour = "#6b1b2c" })
c:px(33, 46, "#ff9158"); c:px(33, 47, "#ff9158")
c:fill(c:rect(31, 40, 35, 41), "#4a8a3e")
c:ground(32, 57, 21, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
