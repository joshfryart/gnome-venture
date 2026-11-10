-- "Something is ready" overlay layers for workshop mockup B. Hard pixels on transparency, native Aseprite API.
-- Each layer is listed (with its x,y and effect) in layout.json.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local floor, sin, pi, abs = math.floor, math.sin, math.pi, math.abs
local INK = "#2b1c26"
local function layer(name, ox, oy, w, h, draw)
  local img = Image(w, h, ColorMode.RGB)
  local function P(x, y, hex)
    x, y = x - ox, y - oy
    if x >= 0 and x < w and y >= 0 and y < h then
      img:drawPixel(x, y, app.pixelColor.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255))
    end
  end
  local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do P(x, y, hex) end end end
  draw(P, R)
  local spr = Sprite(w, h, ColorMode.RGB)
  spr:newCel(spr.layers[1], 1, img, Point(0, 0))
  spr:saveCopyAs(d .. "/" .. name .. ".png")
  spr:close()
end
local function spark(P, R, x, y, big)
  local a = big and 3 or 2
  for i = -a, a do P(x + i, y, "#fce67c"); P(x, y + i, "#fce67c") end
  R(x - 1, y - 1, x + 1, y + 1, "#fff4c0"); P(x, y, "#fffdf0")
  P(x - 1, y - 1, "#fce67c"); P(x + 1, y - 1, "#fce67c"); P(x - 1, y + 1, "#fce67c"); P(x + 1, y + 1, "#fce67c")
end
local function bubble(P, R, cx, cy, r)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local q = (x - cx) ^ 2 + (y - cy) ^ 2
    if q <= r * r + r * .6 then
      local edge = q > (r - 1) * (r - 1) + (r - 1) * .6
      P(x, y, edge and "#2a7a52" or ((x < cx and y < cy) and "#d8fcd0" or "#7ad88c"))
    end
  end end
end

-- cooking: flames leap up both sides of the pot (flicker) + steam puffs (bob)
layer("craft-anim-cooking", 160, 78, 42, 28, function(P, R)
  for x = 162, 199 do
    local side = abs(x - 180.5)
    local h = floor(9 + 5 * sin(x * 1.1) + (side > 12 and (side - 12) * 1.6 or 0) - (side > 17 and (side - 17) * 4 or 0))
    if side <= 12 then h = math.min(h, 8) end
    if h > 0 then
      R(x, 105 - h, x, 105, "#e0622a")
      R(x, 105 - floor(h * .66), x, 105, "#f49a34")
      R(x, 105 - floor(h * .36), x, 105, "#fcd864")
    end
  end
  R(175, 101, 186, 105, "#fff0b0")
  for _, s in ipairs{ { 165, 82 }, { 196, 80 }, { 170, 79 } } do R(s[1], s[2], s[1] + 1, s[2] + 1, "#fcd864") end
end)
layer("craft-anim-cooking2", 168, 60, 26, 18, function(P, R)
  local function puff(x, y, w, h) R(x, y, x + w - 1, y + h - 1, "#d8c0b0"); R(x, y, x + w - 2, y, "#f0e0d0"); R(x + 1, y + h - 1, x + w - 1, y + h - 1, "#b89c90") end
  puff(172, 71, 6, 4); puff(183, 69, 7, 4); puff(177, 64, 6, 4); puff(187, 62, 4, 3); puff(170, 62, 4, 3)
end)

-- pantry: glints on the jars (twinkle)
layer("craft-anim-pantry", 24, 38, 72, 62, function(P, R)
  spark(P, R, 31, 48, true); spark(P, R, 57, 46); spark(P, R, 84, 49, true)
  spark(P, R, 46, 70); spark(P, R, 88, 71, true); spark(P, R, 33, 90, true); spark(P, R, 68, 93); spark(P, R, 82, 88)
end)

-- tools: a mallet coming down on the plank (bob) + flying chips (twinkle)
layer("craft-anim-tools", 300, 44, 26, 30, function(P, R)
  R(311, 55, 315, 72, INK); R(312, 55, 314, 71, "#c48e5a"); R(314, 55, 314, 71, "#a46e44")
  R(302, 45, 324, 56, INK); R(303, 46, 323, 55, "#a46e44"); R(303, 46, 323, 47, "#c48e5a"); R(303, 54, 323, 55, "#643a30")
  R(303, 46, 304, 55, "#c48e5a"); R(308, 46, 308, 55, "#643a30"); R(318, 46, 318, 55, "#643a30")
end)
layer("craft-anim-tools2", 284, 62, 44, 18, function(P, R)
  for _, s in ipairs{ { 287, 70 }, { 292, 64 }, { 322, 66 }, { 325, 73 }, { 298, 67 } } do
    R(s[1], s[2], s[1] + 2, s[2] + 1, "#f8eacc"); P(s[1] + 2, s[2] + 2, "#d8a474"); P(s[1] - 1, s[2] + 1, "#d8a474")
  end
  spark(P, R, 306, 76); spark(P, R, 320, 77)
end)

-- garden: the seedling shoots up and flowers, nodding (sway about its foot)
layer("craft-anim-garden", 414, 34, 26, 33, function(P, R)
  R(425, 44, 428, 66, "#2a5240"); R(426, 44, 427, 66, "#529054"); R(426, 44, 426, 66, "#78b064")
  local function leaf(x0, y0, x1, y1, tip) R(x0, y0, x1, y1, "#2a5240"); R(x0 + 1, y0 + 1, x1 - 1, y1 - 1, "#78b064"); R(x0 + 1, y0 + 1, x1 - 1, y0 + 1, "#a8d080") end
  leaf(416, 56, 425, 60); leaf(428, 51, 437, 55); leaf(418, 47, 425, 51)
  -- flower
  for y = 34, 45 do for x = 421, 432 do
    local q = (x - 426.5) ^ 2 + (y - 39.5) ^ 2
    local notch = (abs(x - 426.5) < 1 and abs(y - 39.5) > 3.6) or (abs(y - 39.5) < 1 and abs(x - 426.5) > 3.6)
    if q <= 30 and not notch then P(x, y, q > 19 and "#a85478" or (y < 38 and "#fac4d4" or "#ec9ab4")) end
  end end
  R(425, 38, 428, 41, "#e0aa2c"); R(425, 38, 428, 39, "#fce67c")
end)

-- potions: bubbles rising off the brew (bob) + the surface flaring (pulse)
layer("craft-anim-potions", 64, 136, 46, 34, function(P, R)
  bubble(P, R, 70, 162, 4); bubble(P, R, 84, 150, 5); bubble(P, R, 99, 160, 3); bubble(P, R, 94, 142, 3); bubble(P, R, 76, 141, 2); bubble(P, R, 104, 148, 2)
end)
layer("craft-anim-potions2", 54, 167, 65, 10, function(P, R)
  for y = 168, 175 do for x = 55, 117 do
    local q = ((x - 86) / 31) ^ 2 + ((y - 171.5) / 3.6) ^ 2
    if q <= 1 then P(x, y, q > .72 and "#58c07a" or (q > .3 and "#a8f0a0" or "#d8fcd0")) end
  end end
  spark(P, R, 70, 171); spark(P, R, 100, 172)
end)

-- building: a fresh brick being set on the pile (bob) + stone chips and dust by the mallet (twinkle)
layer("craft-anim-building", 243, 190, 22, 18, function(P, R)
  R(246, 196, 259, 203, INK); R(247, 197, 258, 202, "#c66648"); R(247, 197, 258, 198, "#e08c62"); R(247, 202, 258, 202, "#a6483a")
  R(250, 191, 251, 193, "#f8eacc"); R(255, 191, 256, 193, "#f8eacc"); R(245, 205, 247, 206, "#f8eacc"); R(258, 205, 260, 206, "#f8eacc")
end)
layer("craft-anim-building2", 268, 166, 40, 22, function(P, R)
  for _, s in ipairs{ { 272, 176 }, { 277, 170 }, { 300, 172 }, { 304, 178 }, { 292, 168 } } do
    R(s[1], s[2], s[1] + 2, s[2] + 2, "#d6cabc"); R(s[1] + 1, s[2] + 2, s[1] + 2, s[2] + 2, "#9a8e90"); P(s[1], s[2], "#f8eacc")
  end
  spark(P, R, 285, 172, true)
end)

-- decor: the shuttle slides across the warp (drift) + wet-paint glints (twinkle)
layer("craft-anim-decor", 354, 178, 16, 6, function(P, R)
  R(356, 179, 367, 183, INK); R(355, 180, 368, 182, INK); P(354, 181, INK); P(369, 181, INK)
  R(356, 180, 367, 182, "#e0aa2c"); R(356, 180, 367, 180, "#fce67c"); R(359, 181, 364, 181, "#a85478")
end)
layer("craft-anim-decor2", 400, 166, 64, 18, function(P, R)
  spark(P, R, 407, 177); spark(P, R, 431, 170); spark(P, R, 447, 174, true); spark(P, R, 459, 179)
end)
