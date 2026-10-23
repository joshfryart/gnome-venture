-- banner-market: Town Square header, 240x60 grid -> 480x120 (2x nearest). Part E: opaque, no border, cap 24.
-- Hem stitch (thread gold 2 on / 1 off) along the top and bottom edge: banners only.
-- Families: water (sky), stone 300 (far roofs), soil 300/500 (cobbles), wood (stalls), red + cream (awnings), gold, leaf.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local c = X.canvas{ mode = "scene", w = 240, h = 60, out = 2 }
local RED = X.ramp("red", { gloss = "#f2793a", dot = "#f2793a", bounce = "#ae2a2a" })
local CREAM = X.ramp("cream", { rim = "#f1ece0", bounce = "#d8c49a", deep = "#d8c49a" })
local GOLD = X.ramp("gold", { base = "#f5cf6a", rim = "#f5cf6a", shade = "#e8a317", bounce = "#e8a317", deep = "#e8a317", gloss = "#f1ece0", dot = "#f1ece0" })
local WOOD = X.ramp("wood", { gloss = "#d9a660", dot = "#d9a660", bounce = "#8a4f2a", deep = "#4a2c1a" })
local LEAF = X.ramp("leaf", { bounce = "#2f6a3a" })

X.layer(c, "sky")
S.sky(c, { 0, 9, 19, 60, 60 }) -- three bands; the palest band sits below the roofs

X.layer(c, "far")
-- far rooftops: flat pale stone, no outline
local roofs = c:mask()
for _, h in ipairs({ { -4, 30, 18 }, { 16, 26, 14 }, { 34, 31, 20 }, { 66, 25, 16 }, { 150, 27, 18 }, { 172, 24, 14 }, { 192, 30, 20 }, { 216, 26, 18 } }) do
  local x, top, w = h[1], h[2], h[3]
  roofs:poly({ { x, top + 6 }, { x + w / 2, top }, { x + w + 1, top + 6 } }):rect(x + 1, top + 6, x + w - 1, 44)
end
c:fill(roofs, "#c9c5bc")

X.layer(c, "ground")
c:fill(c:rect(0, 44, c.W - 1, c.H - 1), "#c9a96e")
-- cobbles: staggered rows of short umber-free joints
for row = 0, 4 do
  local y = 46 + row * 3
  for x = (row % 2) * 4, c.W - 1, 8 do c:paint({ "xxxxx" }, x, y, { x = "#ac7440" }) ; c:px(x + 6, y - 1, "#ac7440") end
end
X.ramp("#c9a96e") -- soil 300 ramp: shade #ac7440

X.layer(c, "objects")
-- stalls: posts, counter, striped awning. stripes share one crescent (light = whole awning), one outline round it
local function awning(x0, x1, y0, y1, colA, colB, sw)
  local m = c:poly({ { x0 + 3, y0 }, { x1 - 2, y0 }, { x1 + 2, y1 - 1 }, { x0 - 2, y1 - 1 } })
  for x = x0 - 1, x1 + 1 do if ((x - x0) % sw) >= 1 and ((x - x0) % sw) <= sw - 2 then m:rect(x, y1 - 1, x, y1 + (((x - x0) % sw) >= 2 and ((x - x0) % sw) <= sw - 3 and 1 or 0)) end end
  local stripe = 0
  for x = x0 - 2, x1 + 2, sw do
    local s = c:rect(x, y0, x + sw - 1, y1 + 1):clip(m)
    c:part(s, stripe % 2 == 0 and colA or colB, { light = m, outline = false, gloss = false, contact = false, cres = 2, deep = 0 })
    stripe = stripe + 1
  end
  c:outline(m)
  return m
end
local function stall(x0, x1, top, colA, colB)
  c:build{
    { "postL", c:rect(x0 + 2, top, x0 + 4, 52), WOOD, { gloss = false, cres = 2, deep = 1 } },
    { "postR", c:rect(x1 - 4, top, x1 - 2, 52), WOOD, { gloss = false, cres = 2, deep = 1 } },
  }
  awning(x0 - 3, x1 + 3, top - 4, top + 6, colA, colB, 6)
  c:part(c:rect(x0, 41, x1, 53), WOOD, { gloss = false, cres = 3, deep = 1 })
  c:paint({ string.rep("x", x1 - x0 - 3) }, x0 + 2, 47, { x = "#8a4f2a" }) -- plank joint
end
stall(20, 62, 26, GOLD, CREAM)
stall(178, 222, 25, GOLD, CREAM)
stall(88, 152, 20, RED, CREAM)
-- centre produce: apples, squash, cabbages in a row on the counter
for i, x in ipairs({ 92, 98, 104 }) do c:part(c:ellipse(x, 38, 3, 3), RED, { cres = 2, deep = 1 }) end
c:part(c:ellipse(101, 34, 3, 3), RED, { cres = 2, deep = 1 })
c:part(c:ellipse(118, 37, 7, 4), GOLD, { cres = 3, deep = 1 })
for _, x in ipairs({ 134, 145 }) do c:part(c:ellipse(x, 37, 5, 4), LEAF, { cres = 2, deep = 1, gloss = false }) end
-- left stall: grain sacks (a real seam and button: they are sewn)
local sack1 = c:rrect(26, 32, 36, 41, 3):add(c:rect(29, 30, 33, 32))
local sack2 = c:rrect(42, 33, 52, 41, 3):add(c:rect(45, 31, 49, 33))
c:part(sack1, CREAM, { cres = 3, deep = 1, gloss = false }); c:part(sack2, CREAM, { cres = 3, deep = 1, gloss = false })
-- right stall: loaves and a honey pot
for _, x in ipairs({ 186, 198 }) do c:part(c:ellipse(x, 38, 6, 3), WOOD, { cres = 2, deep = 1 }) end
c:part(c:rrect(208, 32, 216, 41, 2), GOLD, { cres = 3, deep = 1 })

X.layer(c, "detail")
c:seam({ { 34, 34 }, { 34, 40 } }); c:seam({ { 50, 35 }, { 50, 40 } }) -- side seams of the sewn sacks
c:paint({ "xxxxx" }, 29, 31, { x = "#8a4f2a" }); c:paint({ "xxxxx" }, 45, 32, { x = "#8a4f2a" }) -- neck ties
c:paint({ "x.x.x" }, 185, 37, { x = "#d9a660" }); c:paint({ "x.x.x" }, 197, 37, { x = "#d9a660" })
c:fill(c:rect(208, 31, 216, 32), "#8a4f2a") -- pot lid
for _, x in ipairs({ 92, 98, 104, 101 }) do c:px(x, x == 101 and 30 or 34, "#2f6a3a") end -- apple stalks
-- bunting across the top: cloth flags, flat
local cols = { "#dd3a2a", "#f5cf6a", "#f1ece0" }
for i = 0, 23 do
  local x = i * 10 + 2
  local y = 4 + math.floor(2.5 * math.sin((x / 240) * math.pi) + 0.5)
  c:fill(c:poly({ { x, y }, { x + 7, y }, { x + 3.5, y + 6 } }), cols[i % 3 + 1])
  c:paint({ "xxxxxxxxxx" }, x - 1, y - 1, { x = "#8a4f2a" })
end

X.layer(c, "fx")
-- hem stitch top and bottom
c:seam({ { 0, 1 }, { c.W - 1, 1 } }, { free = true })
c:seam({ { 0, c.H - 2 }, { c.W - 1, c.H - 2 } }, { free = true })

X.save(c, "banner-market", "scenes", { w = 480, h = 120, cap = 24 })
