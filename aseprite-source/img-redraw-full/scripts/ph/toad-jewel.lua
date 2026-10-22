local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {32,8}, {52,25}, {32,58}, {12,25} })
local P = GV.ramp("petal")
local p = c:build{ { "gem", body, "petal", { gloss = false } } }
local function tint(m, hex, only)
  m:clip(body):each(function(x, y)
    local g = c:get(x, y)
    if not only or g == only[1] or g == only[2] then c:px(x, y, hex) end
  end)
end
-- facets
tint(c:poly({ {32,8}, {12,25}, {25,25} }), "#f6b8cf", { P.base, P.rim })
tint(c:poly({ {40,25}, {52,25}, {32,58} }), "#b8386f", { P.base, P.bounce })
-- facet lines (2 px, deep rose)
local L = "#6b1b2c"
tint(c:line({ {13,24}, {51,24} }, 2), L)
tint(c:line({ {32,9}, {24,24}, {31,56} }, 2), L)
tint(c:line({ {32,9}, {40,24}, {32,56} }, 2), L)
-- enamel gloss on the light facet
c:gloss(c:poly({ {32,8}, {12,25}, {25,25} }):cut(c:rect(0,23,63,63)), "#f6b8cf", { 22, 19 })
local t = c:save(O .. "aseprite/ph/toad-jewel.aseprite", O .. "png/ph/toad-jewel.png")
print(GV.report(t))
