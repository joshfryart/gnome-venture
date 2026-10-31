-- ph/doenjang, redraw A (2.2.1 leftovers, Opus medium): wide low dark-glazed crock, grey slab lid, twisted
-- straw rope across the front with two red chilies and a charcoal lump.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "doenjang", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glaze = GV.ramp("#6a3a22", { gloss = "#d89a68", dot = "#f2c8a0", rim = "#9a5a34" })
local body = c:ellipse(32, 40, 23, 15):cut(c:rect(0, 0, 63, 27)):add(c:rect(13, 28, 51, 32))
c:part(body, glaze, { gloss = { 12, 36 } })
c:part(c:rrect(11, 22, 53, 29, 3), "stone", { gloss = { 14, 23 } })
c:part(c:rrect(26, 18, 38, 23, 2), "stone", { flat = true })
-- straw rope sagging across the front
local rope = c:line({ {11, 33}, {20, 38}, {32, 40}, {44, 38}, {53, 33} }, 3)
c:part(rope, GV.ramp("#e2c46a"), { flat = true, contact = false })
for _, x in ipairs({ 11, 16, 21, 26, 31, 36, 41, 46, 51 }) do
  local y = 36
  for yy = 30, 44 do if rope:has(x, yy) then y = yy; break end end
  c:px(x, y + 1, "#b8941a"); c:px(x + 1, y + 2, "#b8941a")
end
-- two red chilies and a charcoal lump hanging from the rope
c:part(c:line({ {22, 40}, {20, 45}, {22, 51} }, 5), "red", { flat = true, contact = false, contour = "#6b1b2c" })
c:part(c:line({ {41, 40}, {43, 45}, {41, 51} }, 5), "red", { flat = true, contact = false, contour = "#6b1b2c" })
c:px(21, 42, "#ff9158"); c:px(42, 42, "#ff9158")
c:fill(c:rect(22, 38, 24, 39), "#7ab55c"); c:fill(c:rect(41, 38, 43, 39), "#7ab55c")
c:part(c:ellipse(31.5, 43, 3, 2.5), GV.ramp("#3e3a44", { rim = "#6a6670" }), { flat = true, contact = false, contour = false })
c:ground(32, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
