-- wonder-panda-bamboo-grove.lua : a bamboo grove, one serious panda holds up a paw with a splinter; cubs munch.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-panda-bamboo-grove"

L.sky(c, "day", 70)
-- misty far hills
c:fill(L.below(c, function(x) return 62 - 6 * math.sin(x / 22 + 1) end), "#b8d4d0")
c:fill(L.below(c, function(x) return 72 - 5 * math.sin(x / 17 + 3) end), "#a4c8b8")
-- ground: mossy floor
local floor = L.below(c, function(x) return 98 + 3 * math.sin(x / 25) end)
c:part(floor, GV.ramp("#7ab55c"), { cres = 6, deep = 9, outline = false, gloss = false })
c:fill(L.below(c, function(x) return 112 + 2 * math.sin(x / 18 + 2) end), "#4f9a45")

-- bamboo stalk helper (flat for far, part for near)
local function stalk(x, w, top, bot, col, near)
  local m = c:rect(x, top, x + w - 1, bot)
  if near then
    c:part(m, GV.ramp(col), { cres = math.max(1, w - 2), deep = w, gloss = false, outline = false, contour = false })
  else
    c:fill(m, col)
  end
  local node = (w >= 3) and "#2f5a2a" or "#4f9a45"
  local ny = top + 8 + (x % 5)
  while ny < bot do
    c:fill(c:rect(x, ny, x + w - 1, ny), node)
    if near and w >= 3 then c:px(x + 1, ny - 1, "#a4b86a") end
    ny = ny + 12 + (x % 4)
  end
end
local function leaves(x, y, col, n)
  for i = 1, n do
    local dx = (i % 2 == 0) and 1 or -1
    for k = 0, 3 do c:px(x + dx * k, y + k // 2 + (i - 1) * 3, col) end
    c:px(x + dx * 4, y + 2 + (i - 1) * 3, col)
  end
end
-- far stalks, pale and thin
for i = 0, 17 do
  local x = 6 + i * 13 + (i % 3) * 2
  stalk(x, 2, 4 + (i % 4) * 5, 100, "#a4b86a", false)
  if i % 2 == 0 then leaves(x + 1, 22 + (i % 5) * 5, "#8fb060", 2) end
end
-- mid stalks
for i = 0, 8 do
  local x = 14 + i * 28 + (i % 2) * 5
  if x < 90 or x > 165 then
    stalk(x, 4, 0, 108, "#9ccb64", true)
    leaves(x + 2, 14 + (i % 3) * 9, "#4f9a45", 3)
  end
end
-- light shafts (hard pale strips on the floor)
for _, x in ipairs({ 36, 100, 176, 214 }) do
  for y = 104, 128 do c:px(x + (y - 104) // 3, y, "#a4b86a"); c:px(x + 1 + (y - 104) // 3, y, "#a4b86a") end
end

-- bamboo shoots poking out of the ground
local function shoot(x, y, h)
  c:part(c:poly({ {x - 3, y + 1}, {x, y - h}, {x + 3, y + 1} }), GV.ramp("#d8c068"), { cres = 2, deep = 3, gloss = false, flat = true })
  c:fill(c:rect(x - 2, y - 3, x + 2, y - 3), "#9a6b3f")
end
for _, s in ipairs({ {28,124,9},{36,127,6},{196,122,8},{206,127,10},{176,128,5},{66,128,6} }) do shoot(s[1], s[2], s[3]) end

local WH, BK = GV.ramp("#f4f0e0", { dot = "#fffaf0", gloss = "#fffaf0", rim = "#fffaf0", shade = "#c5c9d8", deep = "#9a9fb8", bounce = "#d8d4e0" }), GV.ramp("#3a3340", { rim = "#6a6070" })
local function panda_cub(cx, cy, s)
  -- small munching cub: round body, big head, a bamboo stalk to its mouth
  c:part(c:ellipse(cx - 6 * s, cy + 7 * s, 3 * s + 1, 3 * s), BK, { cres = 2, deep = 3, gloss = false })
  c:part(c:ellipse(cx + 6 * s, cy + 7 * s, 3 * s + 1, 3 * s), BK, { cres = 2, deep = 3, gloss = false })
  c:part(c:ellipse(cx, cy + 3 * s, 8 * s, 7 * s), WH, { cres = 3, deep = 5, gloss = false })
  c:part(c:ellipse(cx - 4 * s, cy + 4 * s, 2 * s, 3 * s), BK, { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(cx + 4 * s, cy + 4 * s, 2 * s, 3 * s), BK, { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(cx - 6 * s, cy - 6 * s, 2.5 * s, 2.5 * s), BK, { cres = 1, deep = 2, gloss = false })
  c:part(c:ellipse(cx + 6 * s, cy - 6 * s, 2.5 * s, 2.5 * s), BK, { cres = 1, deep = 2, gloss = false })
  c:part(c:ellipse(cx, cy - 2 * s, 8 * s, 6.5 * s), WH, { cres = 3, deep = 5, gloss = false })
  c:part(c:ellipse(cx - 4 * s, cy - 2 * s, 2.5 * s, 2.5 * s), BK, { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(cx + 4 * s, cy - 2 * s, 2.5 * s, 2.5 * s), BK, { flat = true, gloss = false, outline = false })
  c:eye(cx - 7, cy - 4, true); c:eye(cx + 3, cy - 4, true)
  c:px(cx, cy, "#2a1a10"); c:px(cx - 1, cy, "#2a1a10")
  -- bamboo stalk being munched, held diagonally
  c:part(c:rect(cx - 3, cy + 1, cx + 14, cy + 3), GV.ramp("#7ab55c"), { cres = 1, deep = 2, gloss = false, outline = false, contour = "#2f5a2a" })
  c:px(cx + 6, cy + 1, "#2f5a2a"); c:px(cx + 11, cy + 1, "#2f5a2a")
  c:ground(cx, cy + 11 * s, 9 * s, 2)
end
panda_cub(46, 106, 1)
panda_cub(204, 100, 1)

-- the big serious panda, centre
local PX, PY = 118, 92
-- back legs
c:part(c:ellipse(PX - 15, PY + 24, 9, 6), BK, { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(PX + 15, PY + 24, 9, 6), BK, { cres = 3, deep = 5, gloss = false })
-- body
c:part(c:ellipse(PX, PY + 12, 21, 17), WH, { cres = 5, deep = 8, gloss = false })
-- black shoulder band + left arm resting on knee
c:part(c:ellipse(PX - 17, PY + 8, 6, 11), BK, { cres = 3, deep = 5, gloss = false })
-- right arm raised: holding paw out to the viewer's right
c:part(c:ellipse(PX + 20, PY + 6, 6, 5), BK, { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(PX + 27, PY - 1, 5, 6), BK, { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(PX + 32, PY - 7, 6, 6), BK, { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(PX + 32, PY - 7, 3, 3), GV.ramp("#c97a8a"), { flat = true, gloss = false, outline = false }) -- pad
-- the splinter: a pale wood sliver stuck in the pad, with a glint
c:fill(c:rect(PX + 31, PY - 13, PX + 32, PY - 7), "#e8c887"); c:px(PX + 31, PY - 14, "#e8c887"); c:px(PX + 33, PY - 13, "#9a6b3f"); c:px(PX + 32, PY - 12, "#9a6b3f")
c:px(PX + 36, PY - 15, "#fff1c8"); c:px(PX + 35, PY - 14, "#fff1c8"); c:px(PX + 37, PY - 14, "#fff1c8"); c:px(PX + 36, PY - 13, "#fff1c8")
-- feet pads (front)
c:part(c:ellipse(PX - 9, PY + 27, 7, 4), BK, { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(PX + 9, PY + 27, 7, 4), BK, { cres = 2, deep = 3, gloss = false })
-- ears
c:part(c:ellipse(PX - 14, PY - 21, 5, 5), BK, { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(PX + 14, PY - 21, 5, 5), BK, { cres = 2, deep = 4, gloss = false })
-- head
c:part(c:ellipse(PX, PY - 8, 19, 15), WH, { cres = 5, deep = 8, gloss = false })
-- eye patches (tilted ovals)
c:part(c:ellipse(PX - 9, PY - 9, 5, 6), BK, { flat = true, gloss = false, outline = false })
c:part(c:ellipse(PX + 9, PY - 9, 5, 6), BK, { flat = true, gloss = false, outline = false })
c:eye(PX - 12, PY - 12); c:eye(PX + 6, PY - 12)
-- very serious brows: heavy flat umber lines slanting in
for k = 0, 5 do c:px(PX - 14 + k, PY - 16 + k // 3, "#2a1a10"); c:px(PX + 13 - k, PY - 16 + k // 3, "#2a1a10") end
for k = 0, 4 do c:px(PX - 14 + k, PY - 17 + k // 3, "#2a1a10"); c:px(PX + 13 - k, PY - 17 + k // 3, "#2a1a10") end
-- snout + nose + flat mouth
c:part(c:ellipse(PX, PY - 2, 6, 4), GV.ramp("#e8dcc0"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(PX - 2, PY - 5, PX + 1, PY - 4), "#2a1a10")
c:fill(c:rect(PX - 3, PY + 1, PX + 2, PY + 1), "#2a1a10")
c:ground(PX, PY + 31, 28, 3)

-- a pile of shared bamboo shoots in front (the reward, waiting)
for _, s in ipairs({ {86,126,3},{91,127,3},{96,126,3} }) do c:part(c:rect(s[1], s[2] - 3, s[1] + 3, s[2] + 2), GV.ramp("#7ab55c"), { flat = true, gloss = false, outline = false, contour = "#2f5a2a" }) end
-- foreground leaves/ferns
for _, p in ipairs({ {10,120},{228,118},{150,126},{20,130} }) do
  c:part(c:poly({ {p[1], p[2]}, {p[1] + 5, p[2] - 8}, {p[1] + 8, p[2] + 1} }), GV.ramp("#4f9a45"), { flat = true, gloss = false, outline = false })
  c:part(c:poly({ {p[1] + 6, p[2]}, {p[1] + 12, p[2] - 6}, {p[1] + 14, p[2] + 2} }), GV.ramp("#7ab55c"), { flat = true, gloss = false, outline = false })
end

L.finish(c, SLUG)
