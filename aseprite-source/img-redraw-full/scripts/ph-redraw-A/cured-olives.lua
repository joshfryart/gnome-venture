-- ph/cured-olives, redraw A (2.2.1 leftovers, Opus medium): terracotta amphora with two big ear handles and a
-- cork, olive-branch band, three big olives (black and green) heaped at its foot.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "cured-olives", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local terra = GV.ramp("#cf7440")
-- ear handles behind the body
-- handles: thick arcs from neck to shoulder; the small gap inside is filled with shade, never a see-through hole (holes read as eyes)
local ears = c:ellipse(21, 21, 6, 8):add(c:ellipse(41, 21, 6, 8))
local gaps = c:ellipse(21, 21, 2, 4):add(c:ellipse(41, 21, 2, 4))
c:part(ears, terra, { gloss = false, cres = 2 })
c:fill(gaps, "#8a4f2a")
local body = c:ellipse(31, 34, 14, 17):add(c:poly({ {24, 46}, {38, 46}, {31, 56} })):add(c:rect(26, 12, 36, 20))
c:part(body, terra, { gloss = { 22, 28 } })
c:part(c:rrect(24, 11, 38, 15, 2), terra, { flat = true })
-- cork
c:part(c:poly({ {27, 11}, {35, 11}, {34, 6}, {28, 6} }), "wood", { flat = true, contact = false })
-- olive branch band: dark band with leaves
c:fill(c:rect(18, 31, 44, 32), "#5e2f1e")
for _, x in ipairs({ 21, 27, 33, 39 }) do c:paint({ ".ll", "lll", "ll." }, x, 28, { l = "#7ab55c" }); c:paint({ "ll.", "lll", ".ll" }, x + 2, 33, { l = "#4a8a3e" }) end
-- olives heaped at the foot
local black = GV.ramp("#3e2f50", { gloss = "#a894dc", dot = "#d8ccf0", rim = "#6a5a8a" })
local green = GV.ramp("#8aa83a", { gloss = "#e0ec9a", dot = "#f4f8d0" })
c:part(c:ellipse(17, 50, 6, 5), green, { gloss = { 14, 47 } })
c:part(c:ellipse(45, 50, 6, 5), black, { gloss = { 42, 47 } })
c:part(c:ellipse(39, 45, 5, 4), green, { gloss = { 37, 43 } })
c:ground(31, 57, 21, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
