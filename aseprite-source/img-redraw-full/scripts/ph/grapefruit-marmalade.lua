-- ph/grapefruit-marmalade (Pantry marmalade): small cooper's barrel tub with bulging staves and two iron hoops, pink-gold marmalade top, lid leaning behind
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "grapefruit-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local body = c:poly({ {14, 25}, {51, 25}, {53, 32}, {54, 40}, {53, 48}, {51, 55}, {14, 55}, {12, 48}, {11, 40}, {12, 32} })
local hoops = c:rect(0, 29, 63, 32):add(c:rect(0, 46, 63, 49)):clip(body)
local lid = c:poly({ {37, 9}, {56, 14}, {54, 21}, {35, 16} })
c:build{
  { "lid",   lid, "#c9a96e", { gloss = false } },
  { "barrel", body, "soil", { gloss = false } },
  { "rimtop", c:ellipse(32, 25, 19, 4), "#b07a45", { gloss = false } },
  { "marm",  c:ellipse(32, 25, 16, 3), "#f08a70", { gloss = false, contact = false, flat = true } },
  { "hoops", hoops, "#5b6470", { gloss = false } },
  { "label", c:ellipse(32, 39, 9, 5), "cream", { gloss = false, contact = false } },
}
for _, x in ipairs({ 18, 24, 40, 46 }) do                -- staves (bowed with the bulge)
  for y = 28, 54 do
    local dx = (x < 32 and -1 or 1) * ((y >= 35 and y <= 45) and 1 or 0)
    local cur = c:get(x + dx, y)
    if cur == "#9a6b3f" or cur == "#c98a4a" or cur == "#b0623a" then c:px(x + dx, y, "#7a4a1f") end
  end
end
for _, h in ipairs({ 29, 46 }) do c:fill(c:rect(13, h, 52, h):clip(body), "#8b8f96"); c:px(20, h + 2, "#c9c5bc"); c:px(44, h + 2, "#c9c5bc") end
for _, s in ipairs({ {22, 24}, {27, 26}, {35, 24}, {41, 26}, {31, 23} }) do c:px(s[1], s[2], "#f6b8cf"); c:px(s[1] + 1, s[2], "#f6b8cf") end
c:fill(c:rect(24, 23, 29, 23), "#ffc27a")                -- glossy marmalade surface
for _, g in ipairs({ {40, 12}, {46, 14}, {51, 16}, {42, 16}, {48, 18} }) do c:px(g[1], g[2], "#9a6b3f"); c:px(g[1] + 1, g[2], "#9a6b3f") end
-- label (burnt mark): grapefruit half wheel with spokes
c:paint({
  "rrrrrrrrr",
  "rpypypypr",
  ".rpyyypr.",
  "..rpyypr.",
  "...rrr...",
}, 28, 37, { r = "#c8561c", p = "#f08a70", y = "#f6b8cf" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
