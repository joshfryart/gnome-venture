-- wonder-volcano-spice-gardens.lua : "Terraces of spice on the slopes of a sleepy volcano. The air tingles on your tongue, and the soil is hot to touch."
-- Thing to do: the gardeners trust you with a precious cutting, wrapped in leaf and still warm. Dawn, Southeast Asia (spice islands).
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end
local HOR = 76

L.sky(c, "dawn", HOR)
L.cloud(c, 40, 26, 16, "#f8c890", "#d49ab8"); L.cloud(c, 190, 20, 18, "#f8c890", "#d49ab8"); L.cloud(c, 214, 46, 12, "#fbe0a8", "#f0aa98")
-- sun peeking at the sea line, right
c:fill(c:ellipse(200, HOR, 12, 12):clip(c:rect(0, 0, W, HOR)), "#fbe0a8"); c:fill(c:ellipse(200, HOR, 8, 8):clip(c:rect(0, 0, W, HOR)), "#fff1c8")
-- sea
c:bands(c:rect(0, HOR + 1, W - 1, 104), { "#8fcbd8", "#5aa8c8", "#4a98bc", "#3f8fb0", "#3584a6" }, { dir = "v" })
for _, w in ipairs({ { 10, 82, 12 }, { 30, 90, 10 }, { 160, 84, 14 }, { 190, 92, 10 }, { 210, 98, 12 }, { 14, 98, 9 }, { 120, 100, 8 } }) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#c8ecdc") end
c:fill(c:rect(186, HOR + 2, 212, HOR + 2), "#fbe0a8"); c:fill(c:rect(190, HOR + 5, 208, HOR + 5), "#f8c890")
-- far islands
c:fill(L.below(c, function(x) return HOR - 7 + 4 * math.sin(x / 8) end):clip(c:rect(0, HOR - 10, 24, HOR)), "#7a7ab8")
c:fill(L.below(c, function(x) return HOR - 5 + 3 * math.sin(x / 6 + 2) end):clip(c:rect(176, HOR - 8, 236, HOR)), "#a48ac0")

-- the volcano ----------------------------------------------------------------------------------------------------
local VX = 92
local vol = c:poly({ { 0, 104 }, { 30, 86 }, { 58, 60 }, { 76, 40 }, { 82, 36 }, { 102, 36 }, { 108, 40 }, { 128, 62 }, { 160, 86 }, { 196, 104 } })
c:part(vol, R("#6b5560"), { gloss = false, cres = 9, deep = 14, outline = false })
-- spice terraces: curved bands of green and soil, clipped to the cone
vol:each(function(x, y)
  if y > 50 then
    local d = (x - VX) / 70; if d > 1 then d = 1 elseif d < -1 then d = -1 end
    local v = y - 14 * (1 - d * d)
    local k = math.floor(v / 8)
    local m = v - k * 8
    if y > 62 then
      if m < 5 then c:px(x, y, ((k % 2) == 0) and "#4a8a3e" or "#6a9a3a")
      elseif m < 6 then c:px(x, y, "#7a4a1f") else c:px(x, y, "#9a6b3f") end
      if m < 5 and (x * 3 + k * 5) % 9 == 0 then c:px(x, y, (k % 2 == 0) and "#d6322b" or "#f6b8cf") end
    end
  end
end)
-- upper slope: bare rock, shaded right side
c:fill(vol:copy():clip(c:rect(0, 0, W, 55)):clip(c:poly({ { 92, 30 }, { 140, 30 }, { 140, 70 }, { 96, 70 } })), "#54447f")
c:fill(vol:copy():clip(c:rect(0, 0, W, 55)):clip(c:poly({ { 92, 30 }, { 140, 30 }, { 140, 70 }, { 96, 70 } })):shift(0, 0), "#54447f")
c:fill(vol:copy():clip(c:rect(0, 0, W, 55)):cut(c:poly({ { 92, 30 }, { 140, 30 }, { 140, 70 }, { 96, 70 } })), "#6b5560")
c:fill(vol:copy():clip(c:rect(0, 0, W, 55)):clip(c:rect(0, 0, 70, 55)), "#7b6670")
-- crater: lava glow
c:fill(c:ellipse(92, 38, 11, 3.5), "#2a1a10"); c:fill(c:ellipse(92, 38, 9, 2.5), "#f08a24"); c:fill(c:ellipse(91, 38, 5, 1.5), "#f5cf6a")
-- rim lit
c:fill(c:rect(80, 35, 104, 35), "#a894a0")
-- sleepy smoke, drifting up and to the right
for i, p in ipairs({ { 94, 30, 6 }, { 98, 23, 5 }, { 104, 17, 5 }, { 112, 12, 4 }, { 121, 9, 4 } }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[3] - 1), R("#d8c8d8", { dot = "#fff3c8" }), { gloss = false, outline = false, cres = 2, deep = 3 })
end
-- little hill pair either side
for _, h in ipairs({ { 20, 96, 28, 10 }, { 170, 98, 34, 12 } }) do
  c:part(c:ellipse(h[1], h[2] + 4, h[3], h[4]), R("#4a8a3e"), { gloss = false, outline = false, cres = 4, deep = 6 })
end

-- foreground soil -----------------------------------------------------------------------------------------------------
local ground = L.below(c, function(x) return 100 + 2 * math.sin(x / 16) end)
c:fill(ground, "#7a4a1f")
c:fill(ground:copy():clip(c:rect(0, 0, W, 106)), "#9a6b3f")
-- rows of furrow shading
for y = 112, 132, 7 do c:fill(c:rect(0, y, W - 1, y), "#5e2f1e") end
-- warm glowing cracks and steam
for _, cr in ipairs({ { { 12, 118 }, { 22, 120 }, { 30, 118 } }, { { 90, 126 }, { 104, 128 }, { 114, 126 } }, { { 176, 124 }, { 190, 126 }, { 204, 124 } } }) do
  c:seam(cr, { free = true, on = 3, off = 0, gap = "#f08a24" })
end
for _, s in ipairs({ { 21, 116 }, { 103, 124 }, { 190, 122 } }) do
  for i = 0, 3 do c:px(s[1] + (i % 2), s[2] - i * 3, "#f1ece0"); c:px(s[1] + 1 + (i % 2), s[2] - i * 3 - 1, "#d8c8d8") end
end

-- spice trees on the terraces ----------------------------------------------------------------------------------------------
local function tree(x, y, body, dots, big)
  local r = big and 12 or 9
  c:part(c:rect(x - 1, y - 5, x + 1, y), R("#5e2f1e"), TINY)
  c:part(c:ellipse(x, y - 5 - r * 0.6, r, r * 0.75), R(body), { gloss = false, outline = false, cres = 3, deep = 5 })
  for i, d in ipairs(dots) do c:fill(c:rect(x + d[1], y - 5 - r * 0.6 + d[2], x + d[1] + 1, y - 5 - r * 0.6 + d[2] + 1), d[3]) end
end
tree(20, 112, "#2f5a2a", { { -5, -2, "#f5cf6a" }, { 2, 1, "#f5cf6a" }, { -1, -5, "#d6322b" }, { 5, -3, "#f5cf6a" } }, true)   -- nutmeg
tree(150, 106, "#4a8a3e", { { -4, -3, "#e46a9b" }, { 2, -5, "#e46a9b" }, { 4, 0, "#f6b8cf" }, { -2, 1, "#e46a9b" } }, false)  -- clove
tree(222, 112, "#2f5a2a", { { -5, -2, "#f5cf6a" }, { 2, 1, "#f5cf6a" }, { -1, -5, "#d6322b" }, { 5, -3, "#f5cf6a" } }, true)
-- pepper poles
for _, x in ipairs({ 52, 68, 188 }) do
  c:fill(c:rect(x, 98, x, 110), "#b07a45")
  c:part(c:ellipse(x, 102, 3.5, 6), R("#6a9a3a"), { flat = true, gloss = false, outline = false })
  for _, d in ipairs({ { -1, 100 }, { 1, 104 }, { 0, 107 } }) do c:px(x + d[1], d[2], "#d6322b") end
end

-- gardeners ------------------------------------------------------------------------------------------------------------------
K.gnome(c, 70, 124, { tunic = "#d6322b", hatkind = "bamboo", hat = "#d9a660", look = 1 })
c:part(c:ellipse(60, 120, 5, 4), R("#d9a660"), { gloss = false, outline = false, cres = 2, deep = 3 })
for _, p in ipairs({ { 58, 117 }, { 61, 116 }, { 63, 118 } }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 3), "#a8582f") end -- cinnamon quills
K.gnome(c, 156, 126, { tunic = "#4e8a3e", hatkind = "bamboo", hat = "#e8c880", look = 0 })
K.gnome(c, 120, 122, { tunic = "#e8a317", hatkind = "bamboo", hat = "#d9a660", look = 1 })
-- hero: gnome offering the leaf-wrapped cutting, still warm
K.gnome(c, 196, 129, { tunic = "#7a4a9a", hatkind = "bamboo", hat = "#c9a96e", look = -1 })
c:fill(c:line({ { 191, 119 }, { 183, 117 }, { 178, 114 } }, 2), "#e9b98a")
local pk = c:poly({ { 170, 112 }, { 178, 108 }, { 184, 112 }, { 178, 120 } })
c:part(pk, R("#7ab55c"), { gloss = false, cres = 2, deep = 3 })
c:fill(c:rect(177, 109, 177, 119), "#4a8a3e"); c:seam({ { 172, 113 }, { 182, 113 } }, { on = 2, off = 1 })
c:fill(c:rect(177, 102, 178, 108), "#7ab55c"); c:fill(c:ellipse(175, 103, 2, 1.2), "#a4b86a"); c:fill(c:ellipse(181, 101, 2, 1.2), "#a4b86a")
-- warm steam rising from the cutting
c:px(176, 98, "#f8c890"); c:px(178, 95, "#fbe0a8"); c:px(176, 92, "#f8c890")
-- foreground baskets
for _, b in ipairs({ { 36, 128, "#d6322b" }, { 84, 130, "#f5cf6a" }, { 136, 131, "#a8582f" }, { 224, 128, "#d6322b" } }) do
  c:part(c:ellipse(b[1], b[2], 8, 5), R("#d9a660"), { gloss = false, cres = 3, deep = 4 })
  c:part(c:ellipse(b[1], b[2] - 3, 7, 3), R(b[3]), { flat = true, gloss = false, outline = false })
  c:px(b[1] - 3, b[2] - 4, "#fff1c8")
end
L.finish(c, "wonder-volcano-spice-gardens")
