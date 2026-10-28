-- lair-den-of-the-great-white-owl.lua : boss lair, NA, night under the aurora. Owl on a snowy crag, owlet eyes in the den below.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-den-of-the-great-white-owl"

L.sky(c, "night", 90)
L.stars(c, 60, 60, 11)
-- aurora curtains (hard bands, sine-bent)
local function aurora(y0, amp, ph, cols, th)
  for x = 0, W - 1 do
    local y = math.floor(y0 + amp * math.sin(x / 22 + ph) + 3 * math.sin(x / 9 + ph * 2))
    local yy = y
    for i, col in ipairs(cols) do
      c:fill(c:rect(x, yy, x, yy + th[i] - 1), col); yy = yy + th[i]
    end
  end
end
aurora(22, 9, 0.3, { "#9af0c0", "#5ac8a0", "#3aa88a", "#2a7a7a", "#26565e" }, { 2, 5, 6, 5, 4 })
aurora(46, 6, 2.1, { "#e8a0d8", "#b784c8", "#7a5ab0", "#4a3a8a" }, { 2, 4, 4, 4 })
-- crescent moon
local moon = c:ellipse(206, 20, 7, 7); moon:cut(c:ellipse(210, 18, 6, 6)); c:fill(moon, "#fff1c8")
-- far hills
local far = L.below(c, function(x) return 84 + 5 * math.sin(x / 31) + 3 * math.sin(x / 13) end)
c:fill(far, "#5a5a98")
local mid = L.below(c, function(x) return 96 + 4 * math.sin(x / 24 + 1) + 2 * math.sin(x / 9) end)
c:fill(mid, "#8c9ac8")
c:fill(mid:copy():clip(c:rect(0, 112, W, H)), "#a8b4d8")
-- far spruces
for _, t in ipairs({ {12,96},{24,98},{40,95},{190,95},{204,97},{222,95},{232,98},{64,98},{170,98} }) do
  local x, y = t[1], t[2]
  c:fill(c:poly({ {x-4,y},{x,y-12},{x+4,y} }), "#3a4a8a"); c:fill(c:poly({ {x-3,y-6},{x,y-14},{x+3,y-6} }), "#46569a")
  c:px(x, y - 14, "#c8d4f0")
end
-- snow foreground
local snow = L.below(c, function(x) return 108 + 3 * math.sin(x / 40) end)
c:fill(snow, "#e8eef8")
c:fill(snow:copy():clip(c:rect(0, 122, W, H)), "#cdd6ec")
for _, s in ipairs({ {20,114,8},{60,120,6},{150,116,9},{200,121,7},{100,125,10},{230,118,5} }) do
  c:fill(c:rect(s[1], s[2], s[1] + s[3], s[2]), "#aab6dc")
end

-- foreground spruces (left and right frames)
local function spruce(x, y, s)
  c:part(c:rect(x - 1, y - 2, x + 1, y + 3), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
  for i = 0, 3 do
    local ty = y - i * 9 * s
    local hw = (14 - i * 3) * s
    c:part(c:poly({ {x - hw, ty}, {x, ty - 13 * s}, {x + hw, ty} }), GV.ramp("#2f6a5a"), { cres = 4, deep = 6, gloss = false })
    c:fill(c:poly({ {x - hw * 0.55, ty - 5 * s}, {x, ty - 13 * s}, {x + hw * 0.55, ty - 5 * s} }):clip(c:rect(0, ty - 13 * s, W, ty - 6 * s)), "#e8eef8")
  end
end
spruce(24, 122, 1); spruce(46, 118, 0.8); spruce(214, 120, 1); spruce(196, 116, 0.75)

-- the crag with the den
local crag = c:poly({ {70,125},{76,96},{88,84},{104,78},{136,78},{152,84},{164,96},{170,125} })
c:part(crag, GV.ramp("#8b8f96"), { cres = 7, deep = 11 })
-- snow cap
c:fill(c:poly({ {86,86},{104,79},{136,79},{154,86},{148,89},{138,86},{126,90},{112,87},{100,90},{92,88} }), "#f1ece0")
c:fill(c:rect(104, 79, 136, 79), "#fff3c8")
-- den hole (arch)
local arch = c:ellipse(120, 108, 14, 12):clip(c:rect(0, 90, W, 108)); arch:add(c:rect(106, 109, 134, 121))
c:fill(arch, "#3e2f66")
local arch2 = c:ellipse(120, 109, 11, 9):clip(c:rect(0, 90, W, 109)); arch2:add(c:rect(109, 110, 131, 121))
c:fill(arch2, "#291d4a")
c:fill(c:rect(104, 122, 136, 122), "#f1ece0")
-- owlet eyes glowing in the den
for _, x in ipairs({ 112, 120, 128 }) do c:eye(x - 1, 110, true) end
-- crack lines
c:seam({ {76,110},{84,106},{90,112} }, { free = true, on = 3, off = 0, gap = "#2a1a10" })
c:seam({ {150,106},{158,110},{162,116} }, { free = true, on = 3, off = 0, gap = "#2a1a10" })

-- the Great White Owl, perched on the crag
local OX, OY = 120, 56
-- wings and tail behind the body
c:part(c:ellipse(OX - 17, OY + 8, 7, 14), GV.ramp("#dfe6f2"), { cres = 4, deep = 6, pale = true })
c:part(c:ellipse(OX + 17, OY + 8, 7, 14), GV.ramp("#dfe6f2"), { cres = 4, deep = 6, pale = true })
c:part(c:ellipse(OX, OY + 10, 17, 20), GV.ramp("#f1ece0", { dot = "#fff3c8" }), { cres = 6, deep = 9, pale = true })
-- chest bars
for i = 0, 2 do
  for _, dx in ipairs({ -9, -3, 3, 9 }) do
    c:px(OX + dx, OY + 10 + i * 5, "#8b8f96"); c:px(OX + dx + 1, OY + 11 + i * 5, "#8b8f96"); c:px(OX + dx - 1, OY + 11 + i * 5, "#8b8f96")
  end
end
-- wing barring
for _, y in ipairs({ OY + 4, OY + 9, OY + 14 }) do
  c:fill(c:rect(OX - 20, y, OX - 15, y), "#8b8f96"); c:fill(c:rect(OX + 15, y, OX + 20, y), "#8b8f96")
end
-- feet
for _, dx in ipairs({ -7, 4 }) do
  c:part(c:rect(OX + dx, OY + 28, OX + dx + 4, OY + 31), GV.ramp("#e8a317"), { flat = true, gloss = false })
end
-- head with ear tufts
c:part(c:poly({ {OX-17,OY-14},{OX-14,OY-26},{OX-8,OY-17} }), GV.ramp("#dfe6f2"), { flat = true, gloss = false, pale = true })
c:part(c:poly({ {OX+17,OY-14},{OX+14,OY-26},{OX+8,OY-17} }), GV.ramp("#dfe6f2"), { flat = true, gloss = false, pale = true })
c:part(c:ellipse(OX, OY - 9, 18, 13), GV.ramp("#f1ece0", { dot = "#fff3c8" }), { cres = 5, deep = 8, pale = true })
-- facial disc rim and heart-shaped brow
c:fill(c:ellipse(OX - 8, OY - 9, 8, 8), "#fff3c8"); c:fill(c:ellipse(OX + 8, OY - 9, 8, 8), "#fff3c8")
-- big golden eyes (gold ring + locked eye)
for _, ex in ipairs({ OX - 8, OX + 8 }) do
  c:part(c:ellipse(ex, OY - 9, 5, 5), GV.ramp("#e8a317"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  c:eye(ex - 2, OY - 11)
end
-- beak
c:part(c:poly({ {OX-2,OY-6},{OX+2,OY-6},{OX,OY} }), GV.ramp("#f08a24"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
-- frosty brows (grumpy but cute)
c:fill(c:rect(OX - 13, OY - 16, OX - 4, OY - 15), "#aab6dc"); c:fill(c:rect(OX + 4, OY - 16, OX + 13, OY - 15), "#aab6dc")
-- frost sparkle crystals
for _, p in ipairs({ {60,70},{176,64},{190,90},{50,92} }) do
  c:px(p[1], p[2], "#e8eef8"); c:px(p[1]-1, p[2], "#9af0c0"); c:px(p[1]+1, p[2], "#9af0c0"); c:px(p[1], p[2]-1, "#9af0c0"); c:px(p[1], p[2]+1, "#9af0c0")
end
-- snow bunny, tiny, watching from the drift
c:part(c:ellipse(186, 126, 4, 3), GV.ramp("#f1ece0"), { flat = true, gloss = false, pale = true })
c:part(c:rect(184, 119, 185, 123), GV.ramp("#f1ece0"), { flat = true, gloss = false, pale = true })
c:part(c:rect(187, 119, 188, 123), GV.ramp("#f1ece0"), { flat = true, gloss = false, pale = true })

L.finish(c, SLUG)
