local R = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- scalloped disc helper
local function ruffle(cx, cy, rx, ry, n, sr, ph)
  local m = c:ellipse(cx, cy, rx - 1, ry - 1)
  for i = 0, n - 1 do
    local a = ph + i * 2 * math.pi / n
    m:add(c:ellipse(math.floor(cx + math.cos(a) * (rx - sr) + 0.5), math.floor(cy + math.sin(a) * (ry - sr) + 0.5), sr, sr))
  end
  return m
end

local pot  = c:poly({ {21,45}, {44,45}, {40,57}, {25,57} })
local lip  = c:rrect(18, 40, 46, 45, 1)
local soil = c:ellipse(32, 41, 10, 1.5)
local leafL = c:poly({ {7,34}, {12,31}, {18,33}, {23,38}, {24,44}, {17,44}, {10,41}, {8,38} })
local leafR = c:poly({ {57,34}, {52,31}, {46,33}, {41,38}, {40,44}, {47,44}, {53,41}, {56,38} })
-- teeth notches
for _, p in ipairs({ {9,39},{13,42},{8,36} }) do leafL:del(p[1], p[2]) end
for _, p in ipairs({ {55,39},{50,42},{56,36} }) do leafR:del(p[1], p[2]) end
local leaves = leafL:copy(); leaves:add(leafR)

local back  = ruffle(32, 22.5, 24, 16.5, 16, 3, 0.1)
local mid   = ruffle(32, 22, 17, 12, 12, 2.5, 0.35)
local heart = ruffle(32, 21.5, 8, 6.5, 8, 2, 0.0)

local bloomR = GV.ramp("#e46a9b", { shade = "#b4487a", deep = "#7a2c52", bounce = "#c85a88", gloss = "#ffc0d8", rim = "#f39cc0", dot = "#fff1c8" })
local midR   = GV.ramp("#f6b8cf", { shade = "#e48ab0", deep = "#c86a94", bounce = "#e89ab8", gloss = "#fff3c8", rim = "#ffd4e2", dot = "#fff1c8" })
local heartR = GV.ramp("#e46a9b", { shade = "#b4487a", deep = "#9a3a66", bounce = "#c85a88", gloss = "#ffc0d8", rim = "#f39cc0", dot = "#fff1c8" })

local p = c:build{
  { "pot",    pot,    GV.ramp("#b07a45", { shade = "#8a4f2a", deep = "#5e2f1e", rim = "#d9a660" }) },
  { "lip",    lip,    GV.ramp("#d9a660", { shade = "#b07a45", deep = "#8a4f2a", bounce = "#a8582f" }), { gloss = false } },
  { "soil",   soil,   "#7a4a1f", { flat = true } },
  { "leaves", leaves, GV.ramp("#6a9a3a", { shade = "#4a8a3e", rim = "#a4b86a" }), { gloss = false, cres = 2 } },
  { "back",   back,   bloomR, { cres = 3, gloss = { 14, 12 } } },
  { "mid",    mid,    midR,   { light = back, gloss = { 20, 13 } } },
  { "heart",  heart,  heartR, { light = back, gloss = false } },
}

-- umber ruffle curls on the mid petals, curling inward
local U = "#4a2c1a"
local function arc(cx, cy, r, ry, a0, a1)
  for t = 0, 24 do
    local a = a0 + (a1 - a0) * t / 24
    local x = math.floor(cx + math.cos(a) * r + 0.5)
    local y = math.floor(cy + math.sin(a) * ry + 0.5)
    if mid:has(x, y) and not heart:has(x, y) then c:px(x, y, U) end
  end
end
arc(32, 22, 12.5, 8.5, math.rad(150), math.rad(200))
arc(32, 22, 12.5, 8.5, math.rad(225), math.rad(265))
arc(32, 22, 12.5, 8.5, math.rad(285), math.rad(330))
arc(32, 22, 12.5, 8.5, math.rad(350), math.rad(395))
arc(32, 22, 12.5, 8.5, math.rad(60), math.rad(115))
-- back ring curls between outer and mid
local function arcB(r, ry, a0, a1)
  for t = 0, 24 do
    local a = a0 + (a1 - a0) * t / 24
    local x = math.floor(32 + math.cos(a) * r + 0.5)
    local y = math.floor(22.5 + math.sin(a) * ry + 0.5)
    if back:has(x, y) and not mid:has(x, y) then c:px(x, y, "#9a3a66") end
  end
end
arcB(20.5, 14, math.rad(170), math.rad(205))
arcB(20.5, 14, math.rad(240), math.rad(270))
arcB(20.5, 14, math.rad(300), math.rad(330))
arcB(20.5, 14, math.rad(20), math.rad(50))
arcB(20.5, 14, math.rad(130), math.rad(155))

-- stamens
c:paint({ ".gg.", "gGGg", "gGGg", ".gg." }, 30, 20, { g = "#f5cf6a", G = "#e8a317" })
c:px(31, 21, "#fff1c8")

-- leaf veins
c:line({ {9,36}, {21,41} }, 1); c:fill(c:line({ {9,36}, {21,41} }, 1):clip(leaves), "#4a8a3e")
c:fill(c:line({ {55,36}, {43,41} }, 1):clip(leaves), "#4a8a3e")

-- pot lip seam + button
c:seam({ {20,43}, {45,43} })
c:button(30, 41)

c:ground(32.5, 57, 11, 1.5)
local t = c:save(R .. "img-redraw-full/aseprite/ph/itoh-peony.aseprite", R .. "img-redraw-full/png/ph/itoh-peony.png")
print(GV.report(t))
