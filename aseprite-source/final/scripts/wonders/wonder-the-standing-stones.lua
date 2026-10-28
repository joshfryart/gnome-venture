-- wonder-the-standing-stones.lua : mossy stones in a ring on a hill, humming at dusk; the nearest gives up a seed from its hollow top.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local FLAT = { gloss = false, rim = false, bounce = false, outline = false }
L.sky(c, "dusk", 110)
L.stars(c, 30, 40, 11)
-- moon, low right, pale
c:fill(c:ellipse(196, 34, 9, 9), "#f8e8c8"); c:fill(c:ellipse(199, 31, 7, 7):cut(c:rect(0, 0, 0, 0)), "#fff1c8")
L.cloud(c, 60, 52, 18, "#8c6ab8", "#b784b4"); L.cloud(c, 150, 62, 22, "#8c6ab8", "#c98fb0"); L.cloud(c, 226, 54, 12, "#6a4fa8", "#b784b4")
-- far hills, then nearer ones
c:part(c:poly({ {0,100},{0,72},{40,62},{90,74},{140,64},{200,72},{240,64},{240,100} }), GV.ramp("#5a4a98", { shade = "#4a3c84", deep = "#382c6a" }), { gloss = false, rim = false, bounce = false, outline = false, cres = 4 })
c:part(c:poly({ {0,112},{0,82},{50,74},{110,84},{170,76},{240,82},{240,112} }), GV.ramp("#3a6a78", { shade = "#2f5a6a", deep = "#244858" }), { gloss = false, rim = false, bounce = false, outline = false, cres = 4 })
-- a far village chimney and a lit window or two
c:part(c:rect(30, 76, 36, 80), GV.ramp("#4a3c84"), FLAT); c:px(32, 78, "#f5b878"); c:px(34, 78, "#f5b878")
-- main hill with a flattened crown for the ring
local hill = L.below(c, function(x) return 90 + 4 * math.sin(x / 30 + 1) + 0.0007 * (x - 120) ^ 2 end)
c:part(hill, GV.ramp("#5e9a58", { shade = "#487a4a", deep = "#2f5a3e", rim = "#8ac070" }), { cres = 8, deep = 14, gloss = false })
-- grass tufts and wildflowers
for i = 0, 40 do
  local x = (i * 47 + 5) % W; local y = 92 + (i * 29) % 40
  if y > 94 + 4 * math.sin(x / 30 + 1) then
    c:px(x, y, "#a4b86a"); c:px(x + 1, y - 1, "#7ab55c"); c:px(x + 2, y, "#a4b86a")
    if i % 5 == 0 then c:px(x + 1, y - 2, (i % 2 == 0) and "#f6b8cf" or "#fff1c8") end
  end
end
-- worn path winding up from the front-left
c:part(c:poly({ {40,135},{70,112},{98,104},{104,108},{84,118},{74,135} }), GV.ramp("#c9a96e", { shade = "#a8885a", deep = "#7a5e3c" }), { gloss = false, rim = false, outline = false, cres = 4 })

-- the hum: dashed lavender rings spreading across the ground of the circle
local CXr, CYr = 120, 106
for i, r in ipairs({ 40, 62, 84 }) do
  local ring = c:ellipse(CXr, CYr, r, r * 0.24); ring:cut(c:ellipse(CXr, CYr, r - 1.2, r * 0.24 - 0.9))
  local dash = c:mask()
  ring:each(function(x, y) if ((x // 5) + i) % 3 ~= 0 then dash:set(x, y) end end)
  c:fill(dash, (i == 1) and "#e0d0f8" or "#c3b2ea")
end

-- stones: placed around an ellipse, painted back to front
local stones = {}
for k = 0, 8 do
  local th = (k * 40 + 10) * math.pi / 180
  stones[#stones + 1] = { x = CXr + 82 * math.cos(th), y = CYr + 20 * math.sin(th) + 2, k = k }
end
table.sort(stones, function(a, b) return a.y < b.y end)
local STN = { GV.ramp("#8f93a4", { shade = "#6c7088", deep = "#4a4e68", rim = "#b8bcd0" }), GV.ramp("#9a9aa8", { shade = "#767890", deep = "#52546c", rim = "#c0c0d0" }) }
local function stone(s, big)
  local x, yb = math.floor(s.x), math.floor(s.y)
  local t = (yb - 90) / 35
  local h = math.floor(14 + t * 20 + (s.k % 3) * 3 + (big and 8 or 0))
  local w = math.floor(8 + t * 12 + (big and 4 or 0))
  local top = yb - h
  local tl = (s.k % 3) - 1
  local m = c:poly({ {x - w // 2, yb}, {x - w // 2 + 1 + tl, top + w // 3}, {x + w // 2 - 1 + tl, top + w // 3}, {x + w // 2, yb} })
  m:add(c:ellipse(x + tl, top + w // 3, w // 2 - 1, w // 3 + 2))
  c:part(m, STN[(s.k % 2) + 1], { cres = 4, deep = 6, gloss = false })
  -- moss cap with a drip or two
  local cap = m:copy():clip(c:rect(x - w, top - 4, x + w, top + 4 + math.floor(t * 2)))
  c:part(cap, GV.ramp("#7ab55c", { shade = "#4a8a3e", deep = "#2f5a2a", rim = "#a4d27a" }), { flat = false, cres = 2, deep = 3, outline = false, gloss = false, contour = false })
  c:px(x - w // 4, top + 6 + math.floor(t * 2), "#4a8a3e"); c:px(x + w // 4, top + 8 + math.floor(t * 2), "#4a8a3e")
  -- carved spiral / notch line (stitch-gold glow, the hum)
  if w >= 12 then
    c:px(x - 1, yb - h // 2, "#c3b2ea"); c:px(x, yb - h // 2, "#c3b2ea"); c:px(x + 1, yb - h // 2 + 1, "#c3b2ea"); c:px(x + 1, yb - h // 2 + 2, "#c3b2ea"); c:px(x, yb - h // 2 + 3, "#c3b2ea"); c:px(x - 1, yb - h // 2 + 2, "#c3b2ea")
  end
  -- a lucky coin on top
  if s.k % 3 == 1 then c:fill(c:rect(x - 1, top - 3 - (s.k % 3), x + 1, top - 2 - (s.k % 3)), "#e8a317"); c:px(x - 1, top - 3 - (s.k % 3), "#fff1c8") end
  c:ground(x + 1, yb + 1, w // 2 + 3, 2)
  return top, w
end
local nearest = nil
for _, s in ipairs(stones) do if not nearest or s.y > nearest.y then nearest = s end end
for _, s in ipairs(stones) do
  if s ~= nearest then stone(s, false) end
end
-- the nearest stone: big, with a hollow in its top (a little bowl) and a seed dropping out
nearest.x = 120; nearest.y = 126
do
  local x, yb = 120, 126
  local m = c:poly({ {x - 13, yb}, {x - 11, 100}, {x + 10, 100}, {x + 13, yb} })
  m:add(c:ellipse(x, 100, 11, 9))
  c:part(m, STN[1], { cres = 6, deep = 9, gloss = false })
  c:part(m:copy():clip(c:rect(x - 20, 80, x + 20, 100)), GV.ramp("#7ab55c", { shade = "#4a8a3e", deep = "#2f5a2a", rim = "#a4d27a" }), { cres = 2, deep = 3, outline = false, gloss = false, contour = false })
  c:part(c:ellipse(x, 93, 6, 2.5), GV.ramp("#3a3050"), { flat = true, gloss = false })          -- hollow top
  c:px(x - 4, 91, "#c3b2ea")
  -- hum glyph, bigger
  for _, p in ipairs({ {x-2,108},{x-1,107},{x,107},{x+1,108},{x+1,109},{x,110},{x-1,110},{x-2,111},{x-2,112},{x-1,113},{x,113},{x+1,113},{x+2,112} }) do c:px(p[1], p[2], "#c3b2ea") end
  c:px(x - 9, 118, "#a894dc"); c:px(x + 8, 114, "#a894dc")
  -- coin offerings in a row across its shoulder
  for _, cx2 in ipairs({ x - 9, x + 6 }) do c:fill(c:rect(cx2, 95, cx2 + 2, 96), "#e8a317"); c:px(cx2, 95, "#fff1c8") end
  -- the seed, popping up out of the hollow: a falling gold/green seed with a glint, plus motes
  c:part(c:ellipse(x + 1, 80, 2.5, 3.5), GV.ramp("#b8c860", { shade = "#7a9a3a", deep = "#4a6a2a" }), { flat = true, gloss = false })
  c:px(x, 78, "#fff1c8")
  c:fill(c:rect(x + 1, 84, x + 1, 86), "#f5cf6a"); c:px(x - 1, 87, "#fff1c8"); c:px(x + 3, 89, "#f5cf6a")
  c:ground(x, yb + 1, 20, 2)
end
-- humming notes rising: little music-ish curls above the ring
for _, w in ipairs({ {70,70},{98,60},{150,58},{176,68},{54,86},{196,88} }) do
  c:px(w[1], w[2], "#e0d0f8"); c:px(w[1] + 1, w[2] - 1, "#e0d0f8"); c:px(w[1] + 2, w[2] - 1, "#e0d0f8"); c:px(w[1] + 3, w[2], "#c3b2ea")
end
-- fireflies
for _, f in ipairs({ {20,100},{36,92},{206,102},{224,96},{164,114},{82,120},{214,118} }) do c:px(f[1], f[2], "#f5e08a"); c:px(f[1] + 1, f[2], "#f5cf6a") end
-- two round sheep grazing, left foreground
local function sheep(x, y)
  c:limb({ {x - 4, y + 4}, {x - 4, y + 8} }, 2); c:limb({ {x + 3, y + 4}, {x + 3, y + 8} }, 2)
  local wool = c:ellipse(x, y, 8, 5.5); wool:add(c:ellipse(x - 5, y - 4, 4, 3)); wool:add(c:ellipse(x + 2, y - 5, 4, 3))
  c:part(wool, GV.ramp("#f2ecdc", { dot = "#fff3c8", shade = "#c8c0d8" }), { cres = 3, deep = 5, pale = true })
  c:part(c:ellipse(x + 10, y + 1, 5, 4.5), GV.ramp("#5a4a6a", { shade = "#3e3250", deep = "#2a2038" }), { cres = 2, deep = 3, gloss = false })
  c:eye(x + 8, y - 2, true)
  c:ground(x, y + 9, 11, 2)
end
sheep(26, 118); sheep(204, 126)
L.finish(c, "wonder-the-standing-stones")
