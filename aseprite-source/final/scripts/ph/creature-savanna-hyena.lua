local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local TAN, BRN, CRM = "#dcb06a", "#a5663a", "#f8eed2"
local hx, hy = 32, 25
-- ears poke out diagonally above the mane
local ears = c:ellipse(19, 12, 4.5, 4.5):add(c:ellipse(45, 12, 4.5, 4.5))
-- shaggy mane ring: blobs plus small pointed tufts
local mane = c:mask()
for i = 0, 11 do
  local a = i * math.pi * 2 / 12 + 0.26
  local bx, by = hx + math.cos(a) * 11, hy + math.sin(a) * 10.5
  mane:add(c:ellipse(bx, by, 3.5, 3.5))
  local tx, ty = hx + math.cos(a) * 15, hy + math.sin(a) * 14
  mane:add(c:poly({ {bx - 2, by - 1}, {tx, ty}, {bx + 2, by + 1} }))
end
mane:cut(c:rect(0, 37, 63, 63))
local body = c:ellipse(32, 42, 13.5, 10.5)
local p = c:build{
  { "tail",  c:ellipse(47, 45, 3.5, 3), BRN },
  { "ears",  ears, TAN },
  { "feet",  c:ellipse(23.5, 52, 5, 2.5):add(c:ellipse(40.5, 52, 5, 2.5)), BRN },
  { "body",  body, TAN, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 45, 7.5, 6.5), CRM, { gloss = false } },
  { "mane",  mane, BRN },
  { "head",  c:ellipse(hx, hy, 10.5, 10), TAN },
  { "muzzle", c:ellipse(32, 30.5, 5.5, 4.5), CRM, { gloss = false } },
}
-- inner ears
c:fill(c:ellipse(19, 12, 2, 2), "#f8eed2"); c:fill(c:ellipse(45, 12, 2, 2), "#f8eed2")
c:px(18, 11, "#d9a660")
-- bean spots on the body
local spots = { {20,37,3,3}, {41,39,3,4}, {22,46,3,2}, {38,34,3,2}, {42,47,2,2} }
for _, s in ipairs(spots) do c:spot(c:rrect(s[1], s[2], s[1] + s[3], s[2] + s[4], 1), "#5e2f1e") end
-- face
c:eye(24, 19); c:eye(35, 19)
c:fill(c:ellipse(32, 28, 2.5, 1.5), "#2a1a10")
c:px(31, 27, "#5e2a3a")
c:paint({ "u...u", ".uuu.", "..w.." }, 30, 31, { u = "#4a2c1a", w = "#fff3c8" })
c:ground(32, 54.5, 13, 1.5)
local t = c:save(O .. "aseprite/ph/creature-savanna-hyena.aseprite", O .. "png/ph/creature-savanna-hyena.png")
print(GV.report(t))
