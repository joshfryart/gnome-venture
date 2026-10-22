-- test/apple-chutney.lua : re-creation of pilot ph/apple-chutney with gvlib
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.R

-- parts, back to front (name, mask, ramp, opts)
c:build{
  { "glass", c:rrect(14, 21, 49, 45, 4):add(c:rrect(14, 30, 49, 54, 7)):add(c:rect(17, 18, 46, 21)), "glass" },
  { "chut",  c:rrect(17, 25, 46, 45, 3):add(c:rrect(17, 30, 46, 51, 5)), "red", { contour = R.red.deep } },
  { "band",  c:rect(15, 14, 48, 17), "gold", { gloss = false } },
  { "cap",   c:rrect(15, 9, 48, 14, 2), "gold" },
  { "label", c:rect(20, 33, 43, 44), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(20, 25, 43, 25), R.red.rim) -- lit chutney surface (under the lid shadow line)

-- lid join: thread-gold seam on the band
c:seam({ {17, 16}, {46, 16} })

-- apple chunks: diamonds, evenly varied
for _, p in ipairs({ {22,29}, {30,28}, {39,30}, {24,48}, {33,48}, {41,47}, {44,38}, {19,39}, {36,27} }) do
  c:paint({ ".a.", "aaa", ".b." }, p[1]-1, p[2]-1, { a = "#f5cf6a", b = "#c9a96e" })
end

-- label emblem: apple
c:paint({
  "...u.gg.",
  "..rruggg",
  ".rrrrrr.",
  "rOrrrrrr",
  "rOrrrrss",
  "rrrrrrss",
  ".rrrrss.",
  "..rs.s..",
}, 28, 35, { r = R.red.base, s = R.red.shade, O = R.red.dot, u = "umber", g = "#7ab55c" })

local t = c:save(D .. "test/apple-chutney.aseprite", D .. "test/apple-chutney.png")
print(GV.report(t))
