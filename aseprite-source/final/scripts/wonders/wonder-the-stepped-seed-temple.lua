-- wonder-the-stepped-seed-temple.lua : CA zone 2. Terraces climb a hillside in steps, each carved with a riddle; a small door waits at the top.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

-- sky: warm morning, hazy mountains
L.sky(c, "day", 62)
L.cloud(c, 40, 22, 16); L.cloud(c, 190, 14, 18); L.cloud(c, 120, 36, 12)
local m1 = L.below(c, function(x) return 56 + 6 * math.sin(x / 17) + 4 * math.sin(x / 7) end)
c:fill(m1, "#8fb8c8")
local m2 = L.below(c, function(x) return 66 + 5 * math.sin(x / 13 + 2) + 3 * math.sin(x / 5) end)
c:fill(m2, "#7aa6a0")
-- the green hillside behind the temple
local hill = L.below(c, function(x) return 70 + 20 * (1 - math.exp(-((x - 130) / 70) ^ 2)) * -1 + 24 end)
hill = L.below(c, function(x) return 90 - 40 * math.exp(-((x - 128) / 80) ^ 2) end)
c:part(hill, GV.ramp("#4a8a3e"), { cres = 5, deep = 9, gloss = false, outline = false })
-- trees dotting the slope
for _, t in ipairs({ {30,92},{52,86},{70,82},{188,84},{208,88},{224,94},{16,98} }) do
  c:part(c:ellipse(t[1], t[2], 7, 6), GV.ramp("#2f7a3a"), { cres = 3, deep = 5, gloss = false })
end

-- the stepped terraces ----------------------------------------------------------------------------
local STONE = GV.ramp("#c9c5bc", { rim = "#f2ecda" })
local GLYPH = "#5b6470"
local tiers = {}
for k = 0, 4 do
  local y0 = 52 + k * 11 -- top of tier
  local x0, x1 = 128 - 24 - k * 15, 128 + 24 + k * 15
  local y1 = y0 + 14
  c:part(c:rect(x0, y0, x1, y1), STONE, { cres = 4, deep = 7, gloss = false })
  -- grassy lip on the terrace
  c:part(c:rect(x0 + 1, y0, x1 - 1, y0 + 2), GV.ramp("#7ab55c"), { outline = false, gloss = false, cres = 2, deep = 3, contour = false })
  -- carved riddle band: spiral / key / diamond cycle
  local y = y0 + 6
  local cx = x0 + 6
  local n = 0
  while cx < x1 - 8 do
    if k >= 0 and not (cx > 120 and cx < 136) then
      local g = n % 3
      if g == 0 then c:paint({ "ggggg", "g...g", "g.g.g", "g...." }, cx, y, { g = GLYPH })
      elseif g == 1 then c:paint({ "..g..", ".g.g.", "g...g", ".g.g.", "..g.." }, cx, y - 1, { g = GLYPH })
      else c:paint({ "gg.gg", "g...g", "ggggg", "..g.." }, cx, y, { g = GLYPH }) end
    end
    cx = cx + 11; n = n + 1
  end
  tiers[#tiers + 1] = { x0 = x0, x1 = x1, y0 = y0, y1 = y1 }
end
-- central stairs (lighter), one strip per tier
for _, t in ipairs(tiers) do
  c:part(c:rect(118, t.y0 + 1, 138, t.y1 + 1), GV.ramp("#e2dccb", { rim = "#fff3c8" }), { cres = 3, deep = 5, gloss = false, contour = "#74462a" })
  for yy = t.y0 + 4, t.y1, 4 do c:fill(c:rect(119, yy, 137, yy), "#c9c5bc") end
end
-- top shrine: small block with the door and a seed carving above it
local top = tiers[1]
c:part(c:rect(108, 40, 148, top.y0 + 1), STONE, { cres = 4, deep = 7, gloss = false })
c:part(c:poly({ {104,41},{128,30},{152,41} }), GV.ramp("#a8582f"), { cres = 4, deep = 7 })
c:part(c:rect(106, 40, 150, 42), GV.ramp("#8b8f96"), { cres = 2, gloss = false })
-- door (arched, wood), snug and closed, with a gold keystone seed
local door = c:rect(121, 48, 135, top.y0 + 1); door:add(c:ellipse(128, 49, 7, 4))
c:part(door, GV.ramp("#7a4a1f"), { cres = 3, deep = 5, gloss = false, contour = "#2a1a10" })
c:fill(c:rect(128, 47, 128, top.y0), "#4a2c1a")
c:px(124, 55, "#f5cf6a"); c:px(132, 55, "#f5cf6a"); c:button(126, 52)
c:part(c:ellipse(128, 44, 2.5, 3), GV.ramp("#e8a317"), { flat = true })

-- jungle foreground ---------------------------------------------------------------------------------
local grass = L.below(c, function(x) return 112 + 4 * math.sin(x / 11) end)
grass:cut(c:rect(105, 0, 151, H)) -- leave the path clear
c:part(grass, GV.ramp("#6a9a3a"), { cres = 5, deep = 8, gloss = false })
-- path
local path = c:poly({ {112,H},{118,114},{138,114},{146,H} })
c:part(path, GV.ramp("#c9a96e"), { cres = 4, deep = 7, gloss = false })
for _, p in ipairs({ {124,124},{134,128},{128,119} }) do c:part(c:ellipse(p[1], p[2], 2, 1), GV.ramp("#8b8f96"), { flat = true, gloss = false }) end
-- big leaves left and right
local function leaf(x, y, rx, ry, col)
  c:part(c:ellipse(x, y, rx, ry), GV.ramp(col), { cres = 3, deep = 5, gloss = false })
  c:seam({ {x - rx + 2, y}, {x + rx - 2, y} }, { free = true, on = 1, off = 0, gap = nil })
end
local function plant(x, y, s)
  for i, a in ipairs({ -1, 0, 1 }) do
    c:part(c:ellipse(x + a * 8 * s, y - 6 * s - (a == 0 and 4 or 0), 4 * s + 1, 8 * s), GV.ramp(i == 2 and "#4a8a3e" or "#2f7a3a"), { cres = 3, deep = 5, gloss = false })
  end
end
plant(18, 124, 1.3); plant(40, 128, 1); plant(206, 126, 1.3); plant(226, 122, 1)
-- flowers
for _, f in ipairs({ {58,120,"#e46a9b"},{70,126,"#f6b8cf"},{84,122,"#f08a24"},{160,122,"#e46a9b"},{176,127,"#f08a24"},{190,120,"#f6b8cf"} }) do
  c:fill(c:rect(f[1], f[2], f[1], f[2] + 3), "#4a8a3e")
  c:part(c:ellipse(f[1], f[2] - 1, 2, 2), GV.ramp(f[3]), { flat = true, gloss = false })
  c:px(f[1], f[2] - 1, "#fff1c8")
end
-- a stone frog guardian on the lowest step, chibi
local tx, ty = 62, 90
c:part(c:ellipse(tx, ty, 8, 6), GV.ramp("#8b8f96"), { cres = 4, deep = 6, gloss = false })
c:part(c:ellipse(tx - 4, ty - 6, 3, 3), GV.ramp("#8b8f96"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(tx + 4, ty - 6, 3, 3), GV.ramp("#8b8f96"), { cres = 2, deep = 3, gloss = false })
c:eye(tx - 6, ty - 8); c:eye(tx + 2, ty - 8)
c:seam({ {tx - 4, ty + 1}, {tx + 4, ty + 1} }, { free = true, on = 1, off = 0 })
for _, mx in ipairs({ tx - 5, tx + 2 }) do c:px(mx, ty - 3, "#7ab55c"); c:px(mx + 1, ty - 3, "#7ab55c") end
c:ground(tx, ty + 7, 9, 1.5)
-- macaw perched on the third terrace edge, right
local bx, by = 186, 66
c:limb({ {bx - 2, by + 6}, {bx - 6, by + 16}, {bx - 10, by + 22} }, 2)       -- tail
c:part(c:ellipse(bx - 6, by + 17, 2, 6), GV.ramp("#3f8fb0"), { flat = true, gloss = false })
c:part(c:ellipse(bx, by + 4, 6, 8), GV.ramp("#d6322b"), { cres = 3, deep = 5 })
c:part(c:ellipse(bx + 3, by + 5, 3, 5), GV.ramp("#f5cf6a"), { flat = true, gloss = false })
c:part(c:ellipse(bx, by - 8, 7, 6), GV.ramp("#d6322b"), { cres = 3, deep = 5 })
c:eye(bx - 5, by - 10); c:part(c:poly({ {bx - 8, by - 6}, {bx - 11, by - 3}, {bx - 6, by - 3} }), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:fill(c:rect(bx - 3, by + 11, bx - 3, by + 14), "#b07a45")

L.finish(c, "wonder-the-stepped-seed-temple")
