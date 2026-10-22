local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 37, 16, 16)
local stem = c:rrect(30, 15, 33, 23, 1)
local leaf = c:poly({ {33,19}, {38,13}, {45,10}, {48,9}, {46,14}, {41,19}, {35,21} })
c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = false } },
  { "body", body, GV.ramp("#7a5cc0", { shade = "#4e3a8a" }), { gloss = { 24, 28 } } },
}
-- leaf vein
for _, p in ipairs({ {36,18}, {37,17}, {38,17}, {39,16}, {40,16}, {41,15}, {42,14}, {43,13}, {44,13} }) do c:px(p[1], p[2], "#2f5a2a") end
-- scalloped rows of rind bumps
local P = "#a894dc"
local function scallop(x0, x1, y)
  local x = x0
  while x <= x1 do
    for _, d in ipairs({ {0,0}, {1,1}, {2,1}, {3,0} }) do
      local px, py = x + d[1], y + d[2]
      if body:has(px, py) and body:has(px, py + 2) and c:get(px, py) ~= GV.R.gold.gloss then c:px(px, py, P) end
    end
    x = x + 5
  end
end
scallop(19, 44, 32)
scallop(21, 42, 37)
scallop(19, 44, 42)
scallop(24, 40, 47)
local t = c:save(O .. "aseprite/ph/lychee.aseprite", O .. "png/ph/lychee.png")
print(GV.report(t))
