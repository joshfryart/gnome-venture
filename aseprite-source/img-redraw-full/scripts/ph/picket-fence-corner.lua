local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "rb" }
local cream = GV.ramp("#f8eed2")
local rail = GV.ramp("#8b8f96")
local railH = c:rect(36, 30, 63, 31):add(c:rect(36, 37, 63, 38))
local railV = c:rect(30, 36, 31, 63):add(c:rect(37, 36, 38, 63))
local parts = {
  { "railH", railH, rail, { flat = true } },
  { "railV", railV, rail, { flat = true } },
}
local nails = {}
local shades = {}
for i, x in ipairs({ 40, 47, 54, 61 }) do
  local m = c:rect(x, 25, x + 4, 42):add(c:rect(x + 1, 23, x + 3, 24))
  parts[#parts + 1] = { "ph" .. i, m, cream, { flat = true, rim = false, contact = false } }
  shades[#shades + 1] = c:rect(x + 4, 25, x + 4, 42)
  nails[#nails + 1] = { x + 2, 30 }; nails[#nails + 1] = { x + 2, 37 }
end
for i, y in ipairs({ 40, 47, 54, 61 }) do
  local m = c:rect(25, y, 42, y + 4):add(c:rect(23, y + 1, 24, y + 3))
  parts[#parts + 1] = { "pv" .. i, m, cream, { flat = true, rim = false, contact = false } }
  shades[#shades + 1] = c:rect(25, y + 4, 42, y + 4)
  nails[#nails + 1] = { 30, y + 2 }; nails[#nails + 1] = { 37, y + 2 }
end
parts[#parts + 1] = { "post", c:rect(25, 25, 38, 38), GV.ramp("#d6c9b6") }
parts[#parts + 1] = { "cap", c:rrect(23, 21, 40, 26, 1), cream, { gloss = { 26, 23 } } }
c:build(parts)
for _, m in ipairs(shades) do m:cut(c:rect(23, 23, 40, 40)); c:fill(m, "#d6c9b6") end
for _, n in ipairs(nails) do c:px(n[1], n[2], "#8a4f2a") end
c:fill(c:rect(29, 30, 34, 31), "#b8a890")
local t = c:save(D .. "img-redraw-full/aseprite/ph/picket-fence-corner.aseprite", D .. "img-redraw-full/png/ph/picket-fence-corner.png")
print(GV.report(t))
