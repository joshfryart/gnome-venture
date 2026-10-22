-- Gnome Venture social share card (1200x630), Stitched Toy scene.
-- Drawn on a 240x126 grid, written at 5x nearest-neighbour.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local W, H = 240, 126
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 5 }
local floor, cos, sin, rad = math.floor, math.cos, math.sin, math.rad

-- palette (Part A moss / soil / gold / cream families + Part D outline tones)
local UMB, OL1, OL2 = "#2a1a10", "#74462a", "#4a2c1a"
local GOLD, GOLDS, HOLE = "#f5cf6a", "#e8a317", "#8a4a1c"
local CREAM, CREAM2, CREAMS = "#f1ece0", "#fff3c8", "#d8c49a"
local MOSS8, MOSS6, MOSS4, MOSS2 = "#2f5a2a", "#4f9a45", "#7ab55c", "#a4b86a"
local DEEPG = "#1f3f3a"
local WOOD = GV.R.wood

---------------------------------------------------------------- background
c:bands(nil, { "#5ea24a", "#559845", "#4c8c40", "#43803b", "#3a7336", "#326731", "#2b5a2c" },
  { dir = "radial", cx = 20, cy = -40, r = 250 })
-- felt hem along the top edge
c:seam({ { 0, 2 }, { W - 1, 2 } }, { free = true, gap = nil })
-- wooden floor strip along the bottom, with a hem stitch
for x = 0, W - 1 do
  c:px(x, 121, UMB)
  c:px(x, 122, WOOD.rim)
  for y = 123, 125 do c:px(x, y, y == 125 and WOOD.shade or WOOD.base) end
end
c:seam({ { 0, 124 }, { W - 1, 124 } }, { free = true })

---------------------------------------------------------------- fonts
-- big title font: cap height 12 (rows 0..11), x-height 8 (rows 4..11)
local BIG = {
  G = { 0, {
    "....######.",
    "..###....##",
    ".###......#",
    "###........",
    "###........",
    "###...#####",
    "###.....###",
    "###.....###",
    "###.....###",
    ".###....###",
    "..###..####",
    "...#####.##" } },
  V = { 0, {
    "#####..#####",
    ".###.....##.",
    ".###.....##.",
    "..###...##..",
    "..###...##..",
    "..###...##..",
    "...###.##...",
    "...###.##...",
    "....####....",
    "....####....",
    ".....##.....",
    ".....##....." } },
  n = { 4, {
    "###.####..",
    ".####..###",
    ".###...###",
    ".###...###",
    ".###...###",
    ".###...###",
    ".###...###",
    "#####.####" } },
  o = { 4, {
    "..#####..",
    ".###..###",
    "###....###",
    "###....###",
    "###....###",
    "###....###",
    ".###..###",
    "..#####.." } },
  m = { 4, {
    "###.####.####.",
    ".####.####.###",
    ".###..###..###",
    ".###..###..###",
    ".###..###..###",
    ".###..###..###",
    ".###..###..###",
    "#####.###.####" } },
  e = { 4, {
    "..#####..",
    ".###...##",
    "###....##",
    "#########",
    "###......",
    "###......",
    ".###...##",
    "..######." } },
  t = { 1, {
    ".##....",
    ".###...",
    ".###...",
    "#######",
    ".###...",
    ".###...",
    ".###...",
    ".###...",
    ".###..#",
    ".###.##",
    "..####." } },
  u = { 4, {
    "####..####",
    ".###...###",
    ".###...###",
    ".###...###",
    ".###...###",
    ".###...###",
    ".###..####",
    "..####.###" } },
  r = { 4, {
    "###.####",
    ".#####.#",
    ".###....",
    ".###....",
    ".###....",
    ".###....",
    ".###....",
    "#####..." } },
}
-- small font: cap height 7 (rows 0..6), x-height 5 (rows 2..6), descenders to row 8
local SM = {
  A = { 0, { ".##.", "#..#", "#..#", "####", "#..#", "#..#", "#..#" } },
  C = { 0, { ".###", "#...", "#...", "#...", "#...", "#...", ".###" } },
  E = { 0, { "####", "#...", "#...", "###.", "#...", "#...", "####" } },
  F = { 0, { "####", "#...", "#...", "###.", "#...", "#...", "#..." } },
  G = { 0, { ".###", "#...", "#...", "#.##", "#..#", "#..#", ".###" } },
  a = { 2, { ".##.", "...#", ".###", "#..#", ".###" } },
  b = { 0, { "#...", "#...", "###.", "#..#", "#..#", "#..#", "###." } },
  c = { 2, { ".##", "#..", "#..", "#..", ".##" } },
  d = { 0, { "...#", "...#", ".###", "#..#", "#..#", "#..#", ".###" } },
  e = { 2, { ".##.", "#..#", "####", "#...", ".###" } },
  f = { 0, { ".##", "#..", "###", "#..", "#..", "#..", "#.." } },
  g = { 2, { ".###", "#..#", "#..#", "#..#", ".###", "...#", ".##." } },
  i = { 0, { "#", ".", "#", "#", "#", "#", "#" } },
  k = { 0, { "#...", "#...", "#..#", "#.#.", "##..", "#.#.", "#..#" } },
  l = { 0, { "#", "#", "#", "#", "#", "#", "#" } },
  m = { 2, { "####.", "#.#.#", "#.#.#", "#.#.#", "#.#.#" } },
  n = { 2, { "###.", "#..#", "#..#", "#..#", "#..#" } },
  o = { 2, { ".##.", "#..#", "#..#", "#..#", ".##." } },
  p = { 2, { "###.", "#..#", "#..#", "#..#", "###.", "#...", "#..." } },
  r = { 2, { "#.##", "##..", "#...", "#...", "#..." } },
  s = { 2, { ".###", "#...", ".##.", "...#", "###." } },
  t = { 0, { "#..", "#..", "###", "#..", "#..", "#..", ".##" } },
  u = { 2, { "#..#", "#..#", "#..#", "#..#", ".###" } },
  v = { 2, { "#.#", "#.#", "#.#", "#.#", ".#." } },
  w = { 2, { "#...#", "#...#", "#.#.#", "#.#.#", ".#.#." } },
  x = { 2, { "#..#", "#..#", ".##.", "#..#", "#..#" } },
  y = { 2, { "#..#", "#..#", "#..#", "#..#", ".###", "...#", ".##." } },
  ["1"] = { 0, { ".#.", "##.", ".#.", ".#.", ".#.", ".#.", "###" } },
  ["4"] = { 0, { "#..#", "#..#", "#..#", "####", "...#", "...#", "...#" } },
  [","] = { 6, { ".#", "#." } },
  ["."] = { 6, { "#" } },
  ["~"] = { 3, { "##", "##" } }, -- middle dot
}
-- returns a mask of the text and its width
local function text(font, str, x0, y0, sp, space)
  local m, x = c:mask(), x0
  for i = 1, #str do
    local ch = str:sub(i, i)
    if ch == " " then x = x + space
    else
      local g = font[ch] or error("no glyph " .. ch)
      local w = 0
      for j, row in ipairs(g[2]) do
        w = math.max(w, #row)
        for k = 1, #row do if row:sub(k, k) == "#" then m:set(x + k - 1, y0 + g[1] + j - 1) end end
      end
      x = x + w + sp
    end
  end
  return m, x - x0 - sp
end
local function width(font, str, sp, space) local _, w = text(font, str, -500, -500, sp, space) return w end

---------------------------------------------------------------- cards (screenshots of the game)
-- a card is drawn flat in its own grid, then turned and stamped onto the scene
local function newCard(w, h)
  local L = { w = w, h = h, p = {} }
  function L.px(x, y, col) if x >= 0 and y >= 0 and x < w and y < h then L.p[y * w + x] = col end end
  function L.rect(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do L.px(x, y, col) end end end
  function L.rrect(x0, y0, x1, y1, col) -- 1 px cut corners
    for y = y0, y1 do for x = x0, x1 do
      if not ((x == x0 or x == x1) and (y == y0 or y == y1)) then L.px(x, y, col) end
    end end
  end
  function L.box(x0, y0, x1, y1, fill, edge, shade) -- framed panel: lit top-left edge, shaded lower-right
    L.rrect(x0, y0, x1, y1, edge)
    L.rect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill)
    if shade then for x = x0 + 1, x1 - 1 do L.px(x, y1 - 1, shade) end for y = y0 + 1, y1 - 1 do L.px(x1 - 1, y, shade) end end
  end
  local seed = w * 7 + h
  local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  function L.words(x0, y, len, col) -- a line of fake small print: words of 2..5 px, 1 px gaps
    local x = x0
    while x < x0 + len do
      local n = 2 + rnd(4)
      for i = 0, n - 1 do if x + i < x0 + len then L.px(x + i, y, col) end end
      x = x + n + 1
    end
  end
  function L.seam(x0, x1, y, shadeFrom) -- thread-gold dashed seam, 2 on / 1 off
    for x = x0, x1 do if (x - x0) % 3 < 2 then L.px(x, y, (shadeFrom and x >= shadeFrom) and GOLDS or GOLD) end end
  end
  function L.frame() -- 2 px wood frame: rim on the lit top-left, shade and deep on the lower right
    for y = 0, h - 1 do for x = 0, w - 1 do
      local e = math.min(x, y, w - 1 - x, h - 1 - y)
      if e < 2 then
        local col = WOOD.base
        if x < 2 or y < 2 then col = (e == 0) and WOOD.rim or WOOD.base end
        if x >= w - 2 or y >= h - 2 then col = (e == 0) and WOOD.deep or WOOD.shade end
        L.px(x, y, col)
      end
    end end
    -- enamel gloss comma on the lit corner of the frame
    L.px(3, 0, WOOD.gloss); L.px(4, 0, WOOD.gloss); L.px(5, 0, WOOD.gloss); L.px(0, 3, WOOD.gloss); L.px(0, 4, WOOD.gloss)
    L.px(1, 1, WOOD.dot)
  end
  return L
end

local cardMask = c:mask()
local function stamp(L, cx, cy, deg)
  local a = rad(deg)
  local ca, sa = cos(a), sin(a)
  local r = math.ceil(math.sqrt(L.w * L.w + L.h * L.h) / 2) + 1
  local m, map = c:mask(), {}
  for y = floor(cy - r), floor(cy + r) do for x = floor(cx - r), floor(cx + r) do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u = floor(ca * dx + sa * dy + L.w / 2)
    local v = floor(-sa * dx + ca * dy + L.h / 2)
    if u >= 0 and v >= 0 and u < L.w and v < L.h and L.p[v * L.w + u] then
      m:set(x, y); map[#map + 1] = { x, y, L.p[v * L.w + u] }
    end
  end end
  -- hard drop shadow onto the felt background only
  m:shift(2, 3):cut(m):cut(cardMask):each(function(x, y) if y < 121 then c:px(x, y, DEEPG) end end)
  for _, p in ipairs(map) do c:px(p[1], p[2], p[3]) end
  c:outline(m, { ol = 1, olx = 1 })
  cardMask:add(m:grow(2))
  return m
end

-- shared header for game screens
local function header(L, y1)
  L.rect(2, 2, L.w - 3, y1, MOSS8)
  L.words(4, 4, 14, CREAM)        -- "Gnome Venture"
  L.words(4, 6, 10, MOSS2)        -- player name
  L.words(16, 6, L.w - 21, GOLD)  -- petals
  L.seam(2, L.w - 3, y1 + 1, L.w - 10) -- stitched join under the header
  L.rect(2, y1 + 2, L.w - 3, y1 + 5, "#3f7a38")
  L.rect(4, y1 + 3, 11, y1 + 3, GOLD); L.px(3, y1 + 3, GOLDS)   -- energy bar
  L.words(14, y1 + 3, L.w - 18, CREAM)
  L.rect(2, y1 + 6, L.w - 3, L.h - 3, CREAM)
end

-- left card: the garden patch
local A = newCard(34, 62)
A.frame(); header(A, 8)
A.words(4, 17, 8, "#c9a96e")                    -- "No messages yet"
A.rect(2, 19, 31, 19, CREAMS)
A.rect(4, 21, 22, 22, OL2)                      -- "Fernhollow Patch" heading
A.words(4, 25, 26, "#9a6b3f"); A.words(4, 27, 22, "#9a6b3f")
A.words(4, 30, 24, "#7a9a5a")
-- the plot: wood rim, moss field, rows of seedlings
A.box(3, 33, 30, 58, MOSS6, "#7a4a1f", "#3f7a38")
for i, col in ipairs({ "#e46a9b", "#a9d6ea", "#f5cf6a", "#dd3a2a" }) do A.rect(4 + i * 4, 35, 6 + i * 4, 36, col) end
for y = 39, 55, 2 do for x = 7, 25, 2 do
  if not (y > 51 and x > 21) then A.px(x, y, ((x + y) % 4 == 0) and MOSS2 or "#2f6a3a") end
end end
A.px(13, 43, GOLD); A.px(19, 47, "#dd3a2a")

-- middle card: the region map and an encounter
local B = newCard(42, 68)
B.frame()
B.rect(2, 2, 39, 65, CREAM)
local rings = { "#e46a9b", "#f5cf6a", "#f08a24", MOSS4, "#e46a9b", "#f5cf6a", "#c9c5bc" }
for y = 2, 24 do for x = 2, 28 do
  local d = math.sqrt((x - 14.5) ^ 2 + (y - 9.5) ^ 2)
  local i = floor(d / 2) + 1
  if d < 14 then B.px(x, y, (i % 2 == 0) and CREAM or rings[math.min(#rings, i)]) end
end end
B.rect(13, 8, 16, 11, "#7a9a5a"); B.px(14, 9, UMB); B.px(15, 10, UMB) -- you are here
for i, col in ipairs({ MOSS2, "#f5cf6a", "#f08a24", "#dd3a2a", "#7a5cc0" }) do
  local y = 2 + (i - 1) * 4
  B.rect(30, y, 32, y + 2, col); B.rect(34, y, 38, y, OL2); B.px(34, y + 2, "#c9a96e"); B.px(35, y + 2, "#c9a96e")
end
B.rect(2, 26, 39, 26, CREAMS)
B.box(3, 28, 38, 32, "#eef3d8", MOSS6)          -- "Latest" strip
B.words(5, 30, 30, OL2)
-- the encounter panel: a hollow log hums with wild bees
B.box(3, 34, 38, 54, CREAM2, CREAMS)
B.rect(5, 36, 6, 37, GOLD); B.px(6, 37, UMB)    -- bee
B.words(8, 36, 28, UMB); B.words(5, 38, 20, UMB)
B.words(5, 41, 12, "#c9a96e")
for i, len in ipairs({ 18, 15, 11 }) do         -- three choice buttons
  local y = 43 + (i - 1) * 4
  B.rrect(5, y, 5 + len, y + 2, MOSS8)
  B.words(7, y + 1, len - 3, CREAM)
  B.words(8 + len, y + 1, 36 - (8 + len), "#c9a96e")
end
B.seam(3, 38, 56, 30)
B.box(3, 58, 38, 64, CREAM2, CREAMS)            -- journal
B.rect(15, 60, 26, 60, UMB); B.words(5, 62, 30, "#9a6b3f")

-- right card: the satchel and recipes
local Cd = newCard(48, 70)
Cd.frame(); header(Cd, 9)
Cd.rrect(36, 4, 44, 7, "#3f7a38"); Cd.rect(38, 5, 42, 6, CREAM)  -- menu button
Cd.words(4, 18, 12, "#c9a96e")
-- "Your Satchel" with its bag
Cd.rect(4, 21, 7, 24, "#9a6b3f"); Cd.rect(5, 20, 6, 20, "#7a4a1f"); Cd.px(5, 22, GOLD)
Cd.rect(9, 22, 26, 23, OL2)
Cd.rect(2, 26, 45, 26, OL2)
-- tabs
local tx = 4
for i, len in ipairs({ 8, 9, 9 }) do
  local fill = (i == 2) and "#7a4a1f" or CREAM2
  Cd.rrect(tx, 28, tx + len, 31, CREAMS); Cd.rect(tx + 1, 29, tx + len - 1, 30, fill)
  Cd.px(tx + 2, 29, (i == 3) and "#dd3a2a" or (i == 2 and GOLD or "#9a6b3f"))
  Cd.words(tx + 4, 30, len - 5, (i == 2) and CREAM or OL2)
  tx = tx + len + 2
end
Cd.words(4, 34, 18, "#9a6b3f")
tx = 4
for i, len in ipairs({ 10, 12, 10 }) do
  Cd.rrect(tx, 36, tx + len, 39, (i == 1) and "#7a4a1f" or CREAMS)
  Cd.rect(tx + 1, 37, tx + len - 1, 38, (i == 1) and "#9a6b3f" or CREAM2)
  Cd.words(tx + 2, 38, len - 3, (i == 1) and CREAM or OL2)
  tx = tx + len + 2
end
Cd.words(4, 42, 38, "#9a6b3f"); Cd.words(4, 44, 30, "#9a6b3f")
-- two recipe cards: berry tart and carrot cake
for i = 0, 1 do
  local x0 = 3 + i * 22
  Cd.box(x0, 47, x0 + 20, 66, "#eef3d8", MOSS6)
  if i == 0 then
    Cd.rect(x0 + 2, 50, x0 + 6, 52, "#d9a660"); Cd.rect(x0 + 3, 49, x0 + 5, 49, "#b04a6a"); Cd.px(x0 + 4, 50, "#dd3a2a")
  else
    Cd.rect(x0 + 2, 49, x0 + 6, 52, "#f08a24"); Cd.rect(x0 + 2, 49, x0 + 6, 49, CREAM); Cd.px(x0 + 4, 48, MOSS6)
  end
  Cd.rect(x0 + 8, 49, x0 + 17, 49, UMB); Cd.words(x0 + 8, 51, 10, "#9a6b3f"); Cd.words(x0 + 2, 54, 16, "#9a6b3f")
  for b = 0, 2 do
    local bx = x0 + 2 + b * 6
    if b < 2 then Cd.rrect(bx, 57, bx + 4, 60, MOSS8); Cd.px(bx + 2, 58, CREAM); Cd.px(bx + 2, 59, CREAM)
    else Cd.rrect(bx, 57, bx + 4, 60, CREAMS); Cd.rect(bx + 1, 58, bx + 3, 59, CREAM2); Cd.px(bx + 2, 58, OL2) end
  end
  Cd.px(x0 + 2, 63, GOLD); Cd.words(x0 + 4, 63, 8, "#9a6b3f")
end

stamp(A, 160, 68, 9)
stamp(B, 184, 57, 0)
stamp(Cd, 210, 68, -6)

---------------------------------------------------------------- lettering
-- title: cream felt letters, shaded on the lower right, three-tone outline
local function title(str, x, y)
  local m, w = text(BIG, str, x, y, 1, 4)
  m:each(function(px, py)
    local col = CREAM
    if not m:has(px + 1, py + 1) and (m:has(px - 1, py - 1) or not m:has(px, py + 1) or not m:has(px + 1, py)) then col = CREAMS end
    if not m:has(px - 1, py) or not m:has(px, py - 1) then col = CREAM2 end
    if not m:has(px + 1, py) and not m:has(px, py + 1) then col = CREAMS end
    c:px(px, py, col)
  end)
  c:outline(m, { ol = 1, olx = 1 })
  return m, w
end
title("Gnome", 13, 13)
local _, tw = title("Venture", 13, 30)
c:seam({ { 13, 46 }, { 13 + tw, 46 } }, { free = true })  -- a stitched underline

-- small print with a hard 1 px drop shadow
local function say(str, x, y, col, shadow)
  local m = text(SM, str, x, y, 1, 3)
  m:shift(1, 1):cut(m):each(function(px, py) c:px(px, py, shadow or DEEPG) end)
  c:fill(m, col)
  return m
end
say("A cosy garden game", 13, 50, CREAM2, UMB)
say("you play in your browser", 13, 59, CREAM2, UMB)
local by = { 71, 80, 89 }
for i, s in ipairs({ "Grow real crops in living soil", "Cook, craft and trade", "Explore 14 regions" }) do
  c:button(13, by[i] + 2)
  say(s, 20, by[i], "#e6eea0")
end

-- the pill: a cream felt label, edge-stitched
local pill = c:rrect(11, 103, 113, 118, 3)
c:part(pill, "cream", { cres = 3, deep = 1, gloss = { 13, 105 } })
c:stitch(pill)
local label = "Free ~ gnomeventure.ca"
local lw = width(SM, label, 1, 3)
local lm = text(SM, label, 62 - floor(lw / 2), 107, 1, 3)
c:fill(lm, MOSS8)

local t = c:save(D .. "extras-pixel/aseprite/share-card.aseprite", D .. "extras-pixel/png/share-card.png")
print(GV.report(t))
print("bullet1 ends at x=" .. (20 + width(SM, "Grow real crops in living soil", 1, 3)) .. " label w=" .. lw)
