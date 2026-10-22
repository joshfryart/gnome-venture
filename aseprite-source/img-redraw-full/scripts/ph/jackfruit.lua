local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- big slightly oblong, knobbly body
local body = c:ellipse(31.5, 38, 18, 17)
-- knobbly edge: small bumps around the outline
for _, b in ipairs({ {14,32}, {14,42}, {18,51}, {26,55}, {37,55}, {45,51}, {49,43}, {49,33}, {20,24}, {43,24} }) do
  body:add(c:ellipse(b[1], b[2], 1.5, 1.5))
end
local stem = c:rrect(29, 15, 33, 23, 1)
local leaf = c:poly({ {33,18}, {36,12}, {41,8}, {47,6}, {46,11}, {42,16}, {36,19} })
local bodyR = GV.ramp("#a4b86a", { gloss = "#e8eca0", rim = "#c8d77a", shade = "#6a9a3a", deep = "#4a8a3e" })
local p = c:build{
  { "leaf", leaf, "#4a8a3e" },
  { "stem", stem, "wood", { gloss = false } },
  { "body", body, bodyR, { gloss = { 20, 27 } } },
}
c:fill(c:line({ {35,17}, {39,13}, {44,9} }, 1):clip(p.leaf.m), "#2f5a2a")
-- diamond bump lattice, offset rows, skip gloss area
local dia = { ".d.", "ddd", ".d." }
local rows = { {27, {25,31,37}}, {33, {19,25,31,37,43}}, {39, {16,22,28,34,40,46}}, {45, {19,25,31,37,43}}, {51, {25,31,37}} }
for _, r in ipairs(rows) do
  for _, x in ipairs(r[2]) do
    if not (x <= 25 and r[1] <= 33) then
      local cx, cy = x, r[1]
      if body:has(cx - 1, cy) and body:has(cx + 1, cy) and body:has(cx, cy + 1) then
        local col = (cx + cy > 72) and "#2f5a2a" or "#6a9a3a"
        c:paint(dia, cx - 1, cy - 1, { d = col })
        c:px(cx, cy - 1, (cx + cy > 72) and "#6a9a3a" or "#c8d77a")
      end
    end
  end
end
local t = c:save(O .. "aseprite/ph/jackfruit.aseprite", O .. "png/ph/jackfruit.png")
print(GV.report(t))
