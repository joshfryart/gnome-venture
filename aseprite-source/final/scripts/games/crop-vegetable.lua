local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- marrow body: fat bulb on the left, tapering a little toward the stem end
local body = c:ellipse(25, 38, 14, 12.5):add(c:ellipse(37, 37, 15, 11)):add(c:ellipse(31, 37.5, 16, 12))
local P = c:build{
  { "body", body, "#4f9a45", { cres = 5, deep = 2, gloss = { 17, 30 } } },
}

-- lengthwise pale stripes, following the curve, skipping gloss
local function stripe(pts, col)
  c:line(pts, 2):clip(body:shrink(2)):each(function(x, y)
    local k = c:key(x, y)
    if c.gl.s[k] then return end
    if c.shd[k] then c:px(x, y, P.body.r.base) else c:px(x, y, col) end
  end)
end
stripe({ { 14, 32 }, { 22, 29 }, { 34, 28 }, { 46, 29 } }, "#8fc06a")
stripe({ { 12, 39 }, { 24, 38 }, { 38, 37 }, { 50, 35 } }, "#8fc06a")
stripe({ { 15, 45 }, { 26, 46 }, { 38, 45 }, { 47, 42 } }, "#8fc06a")

-- curled stem at the upper right
local stem = c:line({ { 47, 29 }, { 49, 25 }, { 51, 22 }, { 54, 20 }, { 57, 21 } }, 3)
c:part(stem, "wood", { gloss = false, cres = 2, deep = 1 })

-- blossom bud at the lower left end
local fl = c:ascii({
  "..y..",
  ".yyy.",
  "yyyyy",
  ".yyy.",
  "..y..",
}, 9, 41)
c:part(fl, "gold", { flat = true, contour = "#4a2c1a" })
c:px(11, 43, "#b8661a")
c:px(11, 42, "#fff1c8")

c:ground(31.5, 52, 19, 1.5)
local t = c:save(O .. "aseprite/games/crop-vegetable.aseprite", O .. "png/games/crop-vegetable.png")
print(GV.report(t))
