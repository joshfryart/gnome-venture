local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 49, 21, 7)
local top = c:ellipse(31.5, 47, 16, 4)
local stalkR = GV.ramp("#58a03e")
local bases = { 25, 28, 31, 34, 37 }
local tops  = { 14, 22, 31, 40, 48 }
local tys   = { 24, 19, 16, 19, 24 }
local stalks = c:mask()
for i = 1, 5 do
  local bx, tx, ty = bases[i], tops[i], tys[i]
  local mx = math.floor((bx + tx) / 2 + (tx - bx) * 0.15)
  stalks:add(c:line({ { bx, 47 }, { mx, math.floor((47 + ty) / 2) + 2 }, { tx, ty + 4 } }, 2))
end
local parts = {
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false } },
  { "stalks", stalks, stalkR, { flat = true } },
}
for i = 1, 5 do
  parts[#parts + 1] = { "ear" .. i, c:ellipse(tops[i] + 0.5, tys[i], 2.5, 5), "moss", { gloss = false } }
end
local p = c:build(parts)
for i = 1, 5 do
  local x, y = tops[i], tys[i]
  c:px(x - 1, y - 3, "#c8d77a"); c:px(x - 1, y - 2, "#c8d77a")
  -- grain kernel notches
  c:px(x + 1, y - 1, "#4a8a3e"); c:px(x, y + 2, "#4a8a3e")
end
local t = c:save(O .. "aseprite/ph/stage-grain-3.aseprite", O .. "png/ph/stage-grain-3.png")
print(GV.report(t))
