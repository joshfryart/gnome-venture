local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- cloth bundle: rounded sack body, pinched neck, flared gathered top
local body = c:ellipse(31.5, 41, 19, 15):add(c:rrect(13, 30, 50, 55, 8))
local top = c:poly({ {22, 9}, {27, 13}, {32, 8}, {37, 13}, {42, 9}, {45, 20}, {18, 20} })
local almond = c:poly({ {32, 27}, {37, 31}, {39, 37}, {38, 43}, {35, 47}, {32, 48}, {28, 47}, {25, 43}, {24, 37}, {26, 31} })

local p = c:build{
  { "top",  top,  "#f1ece0", { cres = 3 } },
  { "body", body, "#f1ece0", { stitch = { side = "lit" } } },
  { "tie",  c:rrect(17, 19, 46, 22, 1), "#dcb06a", { flat = true, contact = false } },
  { "nut",  almond, "#dcb06a", { cres = 3, gloss = { 28, 33 } } },
}
-- almond cap darker upper part
local cap = almond:copy():clip(c:rect(0, 26, 63, 33))
c:fill(cap, "#a5663a")
c:px(30, 30, "#c98a52"); c:px(29, 31, "#c98a52")
-- kernel grain line
c:paint({ "k", "k", ".", "k", "k" }, 33, 38, { k = "#b8862f" })
-- fold lines on gathered top
c:paint({ "f", "f", ".f" }, 26, 15, { f = "#dcb06a" })
c:paint({ ".f", "f", "f" }, 37, 15, { f = "#dcb06a" })
-- bow knot (gold button at the tie)
c:paint({
  "ll....ll",
  "lll..lll",
  ".llkkll.",
  "lll..lll",
}, 28, 18, { l = "#c9a96e", k = "#8c4a1a" })
c:button(30, 18)
-- sprout stub
c:line({ {32, 26}, {32, 24} }, 2):each(function(x, y) c:px(x, y, "#2e5a2c") end)
c:px(34, 24, "#4a8a3e"); c:px(35, 23, "#4a8a3e")
-- stitch dots
for _, x in ipairs({ 26, 32, 38 }) do
  c:fill(c:rect(x - 1, 51, x, 52), "#8c4a1a")
end
c:ground(31.5, 57, 15, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/almond-seed.aseprite", D .. "img-redraw-full/png/ph/almond-seed.png")
print(GV.report(t))
