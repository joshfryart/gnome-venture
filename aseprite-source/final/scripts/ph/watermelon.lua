-- ph/watermelon : round striped green melon, short stem, curled leaf tilted right
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"

local rind = c:ellipse(32, 37, 16, 15)
local stem = c:line({ {32, 23}, {32, 16}, {31, 14} }, 3)
local leaf = c:poly({
  {33, 18}, {35, 14}, {38, 10}, {42, 7}, {46, 7}, {45, 10}, {43, 14}, {39, 17}, {35, 19},
})

c:build{
  { "stem", stem, "#4a8a3e", { flat = true } },
  { "rind", rind, "#7ab55c", { gloss = false, cres = 5 } },
}

-- jagged meridian stripes
local stripes = c:mask()
for _, k in ipairs({ -0.62, 0, 0.62 }) do
  local pts = {}
  for y = 22, 52, 2 do
    local dy = y - 37
    local hw = math.sqrt(math.max(0, 256 - dy * dy * 256 / 225))
    local j = ((y / 2) % 2 == 0) and 1 or -1
    pts[#pts + 1] = { 32 + k * hw + j * 0.7, y }
  end
  stripes:add(c:line(pts, 2))
end
stripes:clip(rind:shrink(1))
stripes:each(function(x, y)
  local s = (x - 32) + (y - 37)
  c:px(x, y, s > 8 and "#24481f" or "#2f5a2a")
end)
c:gloss(rind, GV.ramp("#7ab55c"), {24, 28})

c:part(leaf, "#4a8a3e")
c:fill(c:line({ {35, 17}, {39, 13}, {43, 9} }, 1), GV.R.moss.deep)

c:ground(32, 54, 15, 2.5)
local t = c:save(O .. "aseprite/ph/watermelon.aseprite", O .. "png/ph/watermelon.png")
print(GV.report(t))
