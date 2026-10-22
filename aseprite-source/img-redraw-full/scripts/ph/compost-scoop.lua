local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- short slanted handle, rounded butt at the lower right
local handle = c:line({ {39, 33}, {47, 53} }, 6):add(c:ellipse(47.5, 53.5, 3, 3))
-- gold ferrule band where handle meets the blade
local ferrule = c:line({ {36, 36}, {44, 33} }, 3)
-- leaf-shaped scoop blade: pointed left tip, round right belly
local blade = c:poly({ {8, 22}, {13, 30}, {21, 37}, {30, 40}, {37, 38}, {42, 32}, {43, 25},
                       {39, 17}, {32, 12}, {25, 10}, {18, 12}, {12, 17} })
blade:add(c:ellipse(32, 26, 11, 13))

local p = c:build{
  { "handle",  handle,  GV.ramp("#b6814d", { rim = "#d9a660" }) },
  { "ferrule", ferrule, GV.ramp("#d0862a"), { flat = true } },
  { "blade",   blade,   GV.ramp("#8c4a1a", { gloss = "#ecc58a", deep = "#5e2f1e" }), { gloss = { 17, 20 } } },
}
-- hollow of the bowl, heaped with dark compost
local hollow = blade:shrink(5):cut(c:rect(0, 0, 63, 21))
c:fill(hollow, "#6e3818")
c:fill(hollow:copy():cut(hollow:shift(0, 1)), "#5e2f1e")       -- top lip shadow line
for _, x in ipairs{ 19, 28, 36 } do
  for y = 0, 63 do
    if hollow:has(x, y) and hollow:has(x, y - 2) and hollow:has(x, y + 2) then c:px(x, y, "#3d2a1c") end
  end
end
c:px(24, 27, "#9a6b3f"); c:px(32, 29, "#9a6b3f"); c:px(31, 24, "#9a6b3f")
c:ground(32, 57, 17, 3.5, "#6a4528")

local t = c:save(D .. "img-redraw-full/aseprite/ph/compost-scoop.aseprite",
                 D .. "img-redraw-full/png/ph/compost-scoop.png")
print(GV.report(t))
