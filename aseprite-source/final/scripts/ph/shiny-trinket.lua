local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function oct(cx, cy, r)
  local pts = {}
  for i = 0, 7 do
    local a = math.pi / 8 + i * math.pi / 4
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return pts
end

-- bail ring on top
local bail = c:ellipse(31.5, 10.5, 6, 5.5):cut(c:ellipse(31.5, 10.5, 2.5, 2))
bail:add(c:rect(30, 14, 33, 17))
-- gold cup under gem
local cup = c:poly({ {19,36}, {45,36}, {39,55}, {25,55} })
-- gem octagon
local gemPts = oct(32, 30, 14.5)
local gem = c:poly(gemPts)

local p = c:build{
  { "bail", bail, "gold" },
  { "cup",  cup,  "gold" },
  { "gem",  gem,  GV.ramp("#7a5cc0"), { gloss = { 24, 21 } } },
}
-- facets: inner octagon + spokes
local inner = oct(32, 30, 7)
local fl = c:mask()
for i = 1, 8 do
  local a, b = inner[i], inner[i % 8 + 1]
  fl:add(c:line({ { math.floor(a[1] + 0.5), math.floor(a[2] + 0.5) }, { math.floor(b[1] + 0.5), math.floor(b[2] + 0.5) } }, 1))
  local o = gemPts[i]
  fl:add(c:line({ { math.floor(a[1] + 0.5), math.floor(a[2] + 0.5) }, { math.floor(o[1] * 0.93 + 32 * 0.07 + 0.5), math.floor(o[2] * 0.93 + 30 * 0.07 + 0.5) } }, 1))
end
fl:clip(gem:shrink(1))
-- keep the gloss clear
fl:cut(c:ellipse(24, 21, 3, 3))
c:fill(fl, "#4e3a8a")
-- bright table facet (upper-left)
c:fill(c:poly({ {27,24}, {32,23}, {29,28} }):clip(gem), "#a894dc")
-- cup rim seam
c:seam({ {22, 45}, {42, 45} })
-- claws gripping the gem edge
for _, cl in ipairs({ {17,33}, {30,41}, {44,33} }) do
  local m = c:rrect(cl[1], cl[2], cl[1] + 3, cl[2] + 5, 1)
  c:part(m, GV.ramp("#f5cf6a"), { flat = true })
end
-- twinkle stars
for _, s in ipairs({ {9,15}, {50,11}, {52,43} }) do
  local st = c:ascii({ "..g..", "..g..", "ggggg", "..g..", "..g.." }, s[1], s[2])
  c:part(st, GV.ramp("#f5cf6a"), { flat = true })
  c:px(s[1] + 2, s[2] + 2, "#fff1c8")
end

local t = c:save(O .. "aseprite/ph/shiny-trinket.aseprite", O .. "png/ph/shiny-trinket.png")
print(GV.report(t))
