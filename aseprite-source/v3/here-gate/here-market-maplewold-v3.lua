-- here-market-maplewold-v3: Maplewold Market, gate view, 480x270 native. Single pass.
-- Readability first: staggered row of front-facing facades (each its own colour + 1px deep edge + violet cast shadow),
-- hazy perspective side walls behind, calm radial cobbles, gate frame with lantern + leaf/mitten bunting.
-- Quirks: syrup pipeline over the rooftops into the fountain, pies steaming on sills, leaning clock tower,
-- pumpkin in a top hat on the stall, double-ended arrow sign over the notice board.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local out = app.params.out or "./"
local NAME = "here-market-maplewold-v3"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, max, min, sin = math.floor, math.max, math.min, math.sin

local function px(x, y, h) if x >= 0 and y >= 0 and x < W and y < H then c:px(x, y, h) end end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function PL(t) return c:poly(t) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function F(m, h) c:fillMask(m, h) return m end
local function tex(m, fn) m:each(function(x, y) local h = fn(x, y) if h then px(x, y, h) end end) return m end
local function hh(x, y, s) return ((floor(x) * 73856093 ~ floor(y) * 19349663 ~ (s or 1) * 83492791) % 1000) / 1000 end

-- texture fns
local function shingle(T, rh, w, oy)
  return function(x, y)
    local r, yy = (y - oy) // rh, (y - oy) % rh
    if yy == rh - 1 then return T.d end
    if (x + r * (w // 2)) % w == 0 then return T.d end
    if yy == 0 then return T.h end
    return T.b
  end
end
local function plankV(T, pw)
  return function(x, y) local k = x % pw if k == 0 then return T.d elseif k == 1 then return T.h end return T.b end
end
local function clap(T)
  return function(x, y) local k = y % 3 if k == 2 then return T.d elseif k == 0 then return T.h end return T.b end
end
local function blocks(T, rh, w)
  return function(x, y)
    local r, yy = y // rh, y % rh
    if yy == 0 or (x + (r % 2) * (w // 2)) % w == 0 then return T.d end
    if yy == 1 then return T.h end
    return T.b
  end
end
local function window(x0, y0, x1, y1, frame, pane, glint)
  F(R(x0, y0, x1, y1), frame)
  F(R(x0 + 1, y0 + 1, x1 - 1, y1 - 1), pane)
  local mx = (x0 + x1) // 2
  F(R(mx, y0 + 1, mx, y1 - 1), frame)
  if y1 - y0 >= 8 then local my = (y0 + y1) // 2 F(R(x0 + 1, my, x1 - 1, my), frame) end
  if glint then px(x0 + 1, y0 + 1, glint) px(x0 + 2, y0 + 1, glint) end
end
local function castShadow(x0, x1, by)
  F(PL{ { x0 + 2, by - 1 }, { x1 + 12, by - 1 }, { x1 + 6, by + 4 }, { x0 + 6, by + 4 } }, "#a48ea0")
  F(R(x0 + 2, by, x1 + 4, by + 1), "#8e7892")
end

local SHADE = "#a48ea0"
local CREAM = "#f8eedc"
local STEAM2 = "#dccfdc"

---------------------------------------------------------------- sky, hills
c:stripes(0, 112, { "#a3a8da", "#b8b4de", "#d4bcd4", "#e8c6c0", "#f2d4ae", "#f6e0b2" })
c:cloud(130, 52, 34, "#fbeedd", "#e6cad0")
c:cloud(300, 40, 40, "#fbeedd", "#e6cad0")
c:cloud(40, 70, 26, "#fbeedd", "#e6cad0")
c:terrain(function(x) return 80 + floor(6 * sin(x / 37) + 4 * sin(x / 13 + 1)) end, "#c4a8c8", 112)
c:terrain(function(x) return 92 + floor(5 * sin(x / 29 + 2) + 3 * sin(x / 11)) end, "#a993bd", 112)

---------------------------------------------------------------- the huge maple behind the hall
do
  local m = E(206, 62, 28, 20):add(E(240, 44, 36, 22)):add(E(276, 60, 30, 20))
    :add(E(222, 80, 26, 12)):add(E(260, 80, 26, 12)):add(E(240, 66, 44, 20))
  -- leafy edge: nibble
  local nib = HP.mask()
  m:edge():each(function(x, y) if hh(x, y, 3) > .55 then nib:set(x, y) end end)
  m:cut(nib)
  F(R(236, 82, 244, 112), "#6e4a3a")
  tex(m, function(x, y)
    local v = (x - 240) / 50 + (y - 60) / 26 + (hh(x // 3, y // 3, 7) - .5) * .7
    if v < -.9 then return "#f6c64e" elseif v < -.2 then return "#ee9236" elseif v < .6 then return "#d4502e" end
    return "#9a3040"
  end)
  c:edgeIn(m, "#7e2838")
end

---------------------------------------------------------------- ground: calm radial cobbles
do
  local rowOf, rowTop, rowH = {}, {}, {}
  local y, k = 108, 0
  while y < H do
    local h = max(2, floor(2 + (y - 108) * 0.08))
    for yy = y, min(H - 1, y + h - 1) do rowOf[yy], rowTop[yy], rowH[yy] = k, y, h end
    y, k = y + h, k + 1
  end
  for y = 108, H - 1 do
    local k, t, h = rowOf[y], rowTop[y], rowH[y]
    local yy = y - t
    local far = y < 134
    local prev
    for x = 0, W - 1 do
      local u = floor((x - 240) * 6.7 / (y - 96) + .5 * (k % 2))
      local col
      if yy == h - 1 and h >= 3 then col = far and "#bba8a8" or "#9e8a92"
      elseif h >= 4 and prev and u ~= prev then col = far and "#bba8a8" or "#a28e96"
      elseif h >= 6 and yy == 0 then col = "#dac6a8"
      else col = far and "#d2bea6" or "#c6ae92" end
      px(x, y, col)
      prev = u
    end
  end
end

---------------------------------------------------------------- hazy perspective side walls (both sides)
do
  local walls = { "#d4b6a6", "#c8b0bc", "#dcc2a4", "#c6aab4" }
  local roofs = { "#a07490", "#8c6e98", "#a6767e", "#8c6e98" }
  local segs = { { 22, 70, 0 }, { 70, 116, 7 }, { 116, 162, -2 }, { 162, 206, 5 } }
  local function col(xm, x)
    local T = 30 + (xm - 22) * 52 / 184
    local B = 180 - (xm - 22) * 68 / 184
    local rb = 10 - (xm - 22) * 6 / 184
    for i, s in ipairs(segs) do
      if xm >= s[1] and xm < s[2] then
        local top = floor(T + s[3])
        local u = (xm - s[1]) / (s[2] - s[1])
        for y = top, floor(B) do
          local h
          if y < top + rb then h = ((y - top) % 3 == 2) and "#7c6084" or roofs[i]
          else
            local v = (y - top - rb) / (B - top - rb)
            h = walls[i]
            if u < .06 or u > .94 then h = "#a88c9a" end
            local inw = (u > .2 and u < .38) or (u > .6 and u < .78)
            local inh = (v > .1 and v < .26) or (v > .4 and v < .56)
            if inw and inh then h = "#9a82a2" end
          end
          px(x, y, h)
        end
      end
    end
  end
  for x = 22, 205 do col(x, x) end
  for x = 275, 458 do col(480 - x, x) end
end

---------------------------------------------------------------- cast shadows (sun upper-left -> right)
castShadow(212, 268, 119)
castShadow(152, 196, 149)
castShadow(284, 332, 149)
castShadow(92, 140, 163)
castShadow(344, 392, 164)
castShadow(24, 80, 173)
castShadow(404, 452, 178)

---------------------------------------------------------------- TOWN HALL (leaning clock tower)
do
  local all = HP.mask()
  local function lx(y) return floor((86 - y) * 0.14) end
  -- tower
  local tower = HP.mask()
  for y = 44, 86 do for x = 231 + lx(y), 249 + lx(y) do tower:set(x, y) end end
  tex(tower, function(x, y)
    local rel = x - lx(y) - 231
    if rel >= 15 then return "#ccb492" end
    return blocks({ b = "#e6d0ac", d = "#c4ae98", h = "#f2e2c2" }, 5, 8)(x - lx(y), y)
  end)
  -- belfry opening
  local bo = HP.mask()
  for y = 68, 78 do for x = 236 + lx(y), 244 + lx(y) do bo:set(x, y) end end
  F(bo, "#4a3a5e")
  -- clock face (octagon) on tower
  local cx, cy = 240 + lx(56), 56
  local face = PL{ { cx - 3, cy - 6 }, { cx + 3, cy - 6 }, { cx + 6, cy - 3 }, { cx + 6, cy + 3 }, { cx + 3, cy + 6 },
    { cx - 3, cy + 6 }, { cx - 6, cy + 3 }, { cx - 6, cy - 3 } }
  c:rim(face, "#b0843e")
  F(face, "#f6ead0")
  for i = 0, 4 do px(cx, cy - i, "#4a3550") end
  for i = 0, 3 do px(cx + i, cy + i // 2, "#4a3550") end
  px(cx - 5, cy, "#b0843e") px(cx + 5, cy, "#b0843e") px(cx, cy + 5, "#b0843e")
  -- spire
  local sp = PL{ { 228 + lx(44), 45 }, { 252 + lx(44), 45 }, { 241 + lx(26), 26 } }
  tex(sp, shingle({ b = "#7a68a0", d = "#584a7c", h = "#9c8ec2" }, 3, 4, 26))
  px(241 + lx(26), 24, "#f0c24a") px(241 + lx(26), 25, "#f0c24a")
  all:add(tower):add(sp)
  -- roof + body
  local roof = PL{ { 207, 87 }, { 216, 74 }, { 264, 74 }, { 273, 87 } }
  local body = R(212, 87, 268, 118)
  tex(body, function(x, y)
    if x >= 263 then return "#d2bc9c" end
    return blocks({ b = "#ead8b4", d = "#c8b29c", h = "#f6e8c8" }, 5, 10)(x, y)
  end)
  tex(roof, shingle({ b = "#7a68a0", d = "#584a7c", h = "#9c8ec2" }, 3, 5, 74))
  -- re-draw tower base over roof
  local tb = HP.mask() for y = 76, 86 do for x = 231 + lx(y), 249 + lx(y) do tb:set(x, y) end end
  tex(tb, function(x, y) if x - lx(y) - 231 >= 15 then return "#ccb492" end return "#e6d0ac" end)
  all:add(roof):add(body)
  -- doorway: stone arch, double door, steps
  local door = R(232, 103, 248, 117):add(E(240, 103, 8, 5):clip(R(232, 96, 248, 103)))
  c:rim(door, "#a88c78")
  F(door, "#6a3a2c")
  tex(door, function(x, y) if x == 240 then return "#4a2a2a" elseif (x - 232) % 4 == 1 then return "#82483a" end end)
  px(238, 110, "#f0c24a") px(242, 110, "#f0c24a")
  F(R(226, 118, 254, 118), "#c8b29c")
  window(215, 93, 226, 107, "#8a6a5a", "#4b4870", "#f4c870")
  window(254, 93, 265, 107, "#8a6a5a", "#4b4870", "#f4c870")
  -- banner-ish gold band under roof
  F(R(212, 87, 268, 88), "#c89a4a")
  c:edgeIn(all, "#5a4668")
end

---------------------------------------------------------------- TAVERN
do
  local roof = PL{ { 149, 121 }, { 174, 103 }, { 199, 121 } }
  local body = R(154, 121, 194, 148)
  tex(body, function(x, y) if x >= 188 then return "#d29c4e" end return "#eabe66" end)
  F(R(154, 121, 155, 148), "#6a4030") F(R(193, 121, 194, 148), "#6a4030")
  F(R(154, 132, 194, 133), "#6a4030") F(R(154, 121, 194, 122), "#6a4030")
  F(c:line({ { 156, 131 }, { 164, 123 } }, 1), "#6a4030") F(c:line({ { 192, 131 }, { 184, 123 } }, 1), "#6a4030")
  tex(roof, shingle({ b = "#4f8a86", d = "#356260", h = "#78b2a8" }, 3, 5, 103))
  window(167, 123, 177, 131, "#6a4030", "#3e3456", "#f4c870")
  -- door
  F(R(163, 135, 175, 148), "#6a4030")
  F(R(165, 137, 173, 148), "#4a2626")
  F(R(169, 137, 169, 148), "#5e3430")
  px(171, 142, "#f0c24a")
  -- window with pie on sill
  window(179, 136, 191, 145, "#6a4030", "#3e3456")
  F(R(178, 146, 192, 147), "#9a6a48")
  c:paint({ "..hhhhh..", ".hbhbhbh.", "bbbbbbbbb", ".ddddddd." }, 181, 142,
    { h = "#f6c06a", b = "#d8903e", d = "#9a5a5a" })
  for _, p in ipairs{ { 184, 139 }, { 185, 138 }, { 184, 137 }, { 188, 139 }, { 187, 138 }, { 188, 137 } } do px(p[1], p[2], CREAM) end
  -- hanging sign with a mug
  F(R(146, 124, 154, 124), "#4a3030")
  local sg = R(145, 127, 153, 135)
  F(sg, "#8a5434")
  c:paint({ "aaa.", "aaab", "aaab", "aaa." }, 147, 129, { a = "#f0c24a", b = "#f0c24a" })
  px(147, 128, CREAM) px(148, 128, CREAM)
  F(R(147, 125, 147, 126), "#4a3030") F(R(151, 125, 151, 126), "#4a3030")
  local all = roof:copy():add(body)
  c:edgeIn(all, "#5a3428")
  c:edgeIn(sg, "#5a3428")
end

---------------------------------------------------------------- MAPLE STALLS (pumpkin in a top hat)
do
  -- posts
  F(R(287, 113, 289, 147), "#7a4a30") F(R(327, 113, 329, 147), "#7a4a30")
  -- counter
  local ctr = R(285, 130, 331, 148)
  tex(ctr, function(x, y) local k = (y - 130) % 4 if k == 3 then return "#8a5434" elseif k == 0 then return "#d49a60" end
    if x >= 325 then return "#9c6640" end return "#b47a48" end)
  -- painted maple leaf on the counter front
  c:paint({ "...a...", ".a.a.a.", ".aaaaa.", "aaaaaaa", ".aaaaa.", "...b...", "...b..." }, 305, 136,
    { a = "#d4443c", b = "#8a3a30" })
  -- syrup bottles
  for i, bx in ipairs{ 291, 296, 301 } do
    F(R(bx, 122, bx + 3, 129), "#d88a2a") F(R(bx + 1, 119, bx + 2, 121), "#d88a2a") px(bx + 1, 118, "#8a5434") px(bx + 2, 118, "#8a5434")
    px(bx, 123, "#f6c45a") px(bx, 124, "#f6c45a") F(R(bx + 3, 125, bx + 3, 129), "#a8601e")
  end
  -- pumpkin with a top hat
  c:paint({
    "...kkkk...",
    "...kkkk...",
    "...kbbk...",
    ".kkkkkkkk.",
    "....gs....",
    ".ohhoroor.",
    "ohhooroorr",
    "ohoooroorr",
    "ooooorooor",
    ".odddddrd.",
  }, 307, 117, { k = "#4e4070", b = "#d4443c", g = "#6a8a3a", s = "#4e6a2e", o = "#ee8a2c", h = "#fbb860", r = "#c4602a", d = "#9a4a2a" })
  -- jars of butter
  for _, bx in ipairs{ 320, 325 } do F(R(bx, 124, bx + 3, 129), "#f2c86a") F(R(bx, 123, bx + 3, 123), "#d4443c") px(bx, 125, CREAM) end
  -- striped awning with scallops
  local aw = PL{ { 283, 113 }, { 290, 103 }, { 326, 103 }, { 333, 113 } }:add(R(283, 113, 333, 114))
  for x = 283, 333, 4 do aw:set(x + 1, 115) aw:set(x + 2, 115) end
  tex(aw, function(x, y) if ((x - 283) // 4) % 2 == 0 then return y <= 104 and "#e46a5a" or "#d4443c" end return "#f4e2c4" end)
  local all = aw:copy():add(ctr):add(R(287, 113, 289, 147)):add(R(327, 113, 329, 147))
  c:edgeIn(aw, "#8a2e30")
  c:edgeIn(ctr, "#6a3a26")
end

---------------------------------------------------------------- PIE BAKERY
do
  local roof = PL{ { 89, 131 }, { 116, 111 }, { 143, 131 } }
  local chim = R(126, 109, 131, 120)
  local body = R(93, 131, 139, 162)
  tex(chim, blocks({ b = "#b85a40", d = "#8a3a30", h = "#d47a58" }, 3, 4))
  tex(body, function(x, y) if x >= 134 then return "#e2c2a6" end return "#f6dec2" end)
  F(R(93, 131, 139, 132), "#8a5638") F(R(93, 131, 94, 162), "#8a5638") F(R(138, 131, 139, 162), "#8a5638")
  F(R(115, 133, 116, 162), "#8a5638")
  tex(roof, shingle({ b = "#d0663e", d = "#9a4232", h = "#ee8e58" }, 3, 5, 111))
  -- gable window (lit)
  window(112, 119, 120, 126, "#8a5638", "#f6c860")
  -- awning over shop window
  local aw = R(95, 135, 113, 137)
  for x = 95, 113, 3 do aw:set(x + 1, 138) end
  tex(aw, function(x, y) return ((x - 95) // 3) % 2 == 0 and "#e47a8a" or "#f8e6d4" end)
  window(96, 139, 112, 151, "#8a5638", "#4a3a5c")
  F(R(95, 152, 113, 153), "#b08060")
  c:paint({ "..hhhhhhh..", ".hbhbhbhbh.", "bbbbbbbbbbb", ".ddddddddd." }, 99, 148,
    { h = "#f6c06a", b = "#d8903e", d = "#9a5a5a" })
  for _, p in ipairs{ { 102, 146 }, { 103, 145 }, { 102, 144 }, { 103, 143 }, { 107, 146 }, { 106, 145 }, { 107, 144 }, { 106, 143 } } do px(p[1], p[2], CREAM) end
  -- door
  local door = R(120, 143, 132, 162):add(E(126, 143, 6, 3):clip(R(120, 139, 132, 143)))
  F(door, "#6a3a3a")
  tex(door, function(x, y) if (x - 120) % 4 == 2 then return "#7e4a46" end end)
  px(130, 152, "#f0c24a")
  -- smoke from chimney
  for _, b in ipairs{ { 130, 104, 3, 2 }, { 134, 99, 3, 2 }, { 139, 95, 2, 2 } } do
    local m = E(b[1], b[2], b[3], b[4]) F(m, CREAM) tex(m, function(x, y) if y == b[2] + b[4] then return STEAM2 end end)
  end
  local all = roof:copy():add(body):add(chim)
  c:edgeIn(all, "#7a3a2c")
end

---------------------------------------------------------------- GENERAL STORE (blue false front)
do
  local ff = R(346, 113, 390, 128)
  local body = R(344, 128, 392, 163)
  local T = { b = "#5d7fb8", d = "#44608e", h = "#7ea0d0" }
  tex(ff, clap(T)) tex(body, clap(T))
  tex(R(386, 116, 390, 163), function(x, y) return y % 3 == 2 and "#3a5280" or "#4c6ca0" end)
  F(R(345, 112, 391, 114), "#e8c05a")
  -- painted maple leaf on the false front
  c:paint({ "...a...", ".a.a.a.", ".aaaaa.", "aaaaaaa", ".aaaaa.", "...b...", "...b..." }, 365, 117,
    { a = "#e8c05a", b = "#b08a3a" })
  -- porch roof + posts
  F(R(341, 134, 395, 137), "#8a5434") F(R(341, 134, 395, 134), "#b47a48")
  F(R(346, 138, 347, 163), "#8a5434") F(R(389, 138, 390, 163), "#8a5434")
  -- door + windows with goods
  F(R(361, 143, 375, 163), "#e8c05a")
  F(R(363, 145, 373, 163), "#3a3048")
  F(R(368, 145, 368, 163), "#4e4260") px(371, 154, "#f0c24a")
  window(349, 142, 358, 154, "#e8c05a", "#3e3a5c")
  window(378, 142, 387, 154, "#e8c05a", "#3e3a5c")
  for _, g in ipairs{ { 351, 152, "#d88a2a" }, { 355, 152, "#d4443c" }, { 380, 152, "#6aa04a" }, { 384, 152, "#d88a2a" } } do
    F(R(g[1], g[2] - 2, g[1] + 1, g[2]), g[3])
  end
  -- barrel by the porch
  local br = R(350, 156, 357, 163)
  tex(br, function(x, y) if y == 158 or y == 161 then return "#5a3a2a" elseif x == 350 then return "#c08050" end return "#9a6038" end)
  local all = ff:copy():add(body):add(R(341, 134, 395, 137))
  c:edgeIn(all, "#2e3e66")
end

---------------------------------------------------------------- SUGAR SHACK (steam cupola)
do
  local roof = PL{ { 21, 141 }, { 52, 123 }, { 83, 141 } }
  local cup = R(46, 112, 58, 124)
  local cr = PL{ { 43, 114 }, { 52, 107 }, { 61, 114 } }
  local body = R(26, 141, 78, 172)
  local T = { b = "#9c5436", d = "#6e3426", h = "#bc7048" }
  tex(body, function(x, y) if x >= 72 then return x % 5 == 0 and "#5e2c22" or "#844430" end return plankV(T, 5)(x, y) end)
  tex(cup, plankV(T, 3))
  F(R(49, 116, 55, 121), "#4a2a30")
  tex(roof, function(x, y) local k = x % 3 if k == 0 then return "#62708e" elseif k == 1 then return "#b4c2da" end return "#8a9ab8" end)
  tex(cr, function(x, y) local k = x % 3 if k == 0 then return "#62708e" elseif k == 1 then return "#b4c2da" end return "#8a9ab8" end)
  -- door + lit window
  F(R(44, 152, 60, 172), "#6e3426")
  F(R(46, 154, 58, 172), "#4a2a30")
  F(c:line({ { 46, 155 }, { 58, 171 } }, 1), "#6a3a38")
  px(56, 162, "#f0c24a")
  window(64, 148, 73, 157, "#5e2c22", "#f6c860")
  -- sap barrel
  local br = R(29, 160, 38, 172)
  tex(br, function(x, y) if y == 163 or y == 169 then return "#5a3a2a" elseif x == 29 then return "#e0a050" end return "#c47a2e" end)
  -- big steam puffs from cupola
  for _, b in ipairs{ { 50, 101, 5, 3 }, { 45, 94, 4, 3 }, { 51, 87, 3, 2 } } do
    local m = E(b[1], b[2], b[3], b[4]) F(m, CREAM) tex(m, function(x, y) if y >= b[2] + b[4] - 1 and x > b[1] - 2 then return STEAM2 end end)
  end
  local all = roof:copy():add(body):add(cup):add(cr)
  c:edgeIn(all, "#5a2a22")
end

---------------------------------------------------------------- HERBALIST (sage walls, plum thatch)
do
  local roof = PL{ { 401, 149 }, { 429, 122 }, { 457, 149 } }
  local body = R(406, 149, 452, 177)
  tex(body, function(x, y) if y >= 172 then return blocks({ b = "#a89cac", d = "#867a90", h = "#c4b8c4" }, 3, 6)(x, y) end
    if x >= 446 then return "#88a470" end return "#a8c08a" end)
  tex(roof, function(x, y)
    if y % 4 == 3 and hh(x, y, 5) > .4 then return "#64406e" end
    local v = hh(x, y // 2, 9)
    if v > .8 then return "#ac80b4" elseif v < .15 then return "#74507e" end
    if x > 440 then return "#7a5084" end
    return "#8a5a92"
  end)
  -- door (arched)
  local door = R(422, 159, 434, 177):add(E(428, 159, 6, 4):clip(R(422, 154, 434, 159)))
  F(door, "#2e4a30")
  tex(door, function(x, y) if (x - 422) % 4 == 1 then return "#3e5a3a" end end)
  px(431, 168, "#f0c24a")
  window(409, 155, 418, 164, "#64406e", "#3e3456", "#f4c870")
  window(439, 155, 448, 164, "#64406e", "#3e3456", "#f4c870")
  -- herb bundles hanging under the eaves
  for i, hx in ipairs{ 412, 418, 440, 446 } do
    px(hx, 150, "#6e4a3a")
    local hc = (i % 2 == 0) and "#9a6ab8" or "#5e9a4a"
    F(R(hx - 1, 151, hx + 1, 153), hc) px(hx, 154, hc)
  end
  -- pots
  for _, pxo in ipairs{ 409, 438 } do
    F(R(pxo, 173, pxo + 5, 177), "#c4602a") F(R(pxo, 173, pxo + 5, 173), "#e08048")
    F(R(pxo + 1, 169, pxo + 1, 172), "#5e9a4a") F(R(pxo + 4, 168, pxo + 4, 172), "#5e9a4a") px(pxo + 2, 168, "#7ab85a") px(pxo + 3, 167, "#7ab85a")
  end
  local all = roof:copy():add(body)
  c:edgeIn(all, "#4a3352")
end

---------------------------------------------------------------- SYRUP PIPELINE over the rooftops into the fountain
do
  local pts = { { 78, 138 }, { 90, 112 }, { 140, 100 }, { 176, 93 }, { 204, 93 }, { 229, 181 } }
  -- supports
  F(R(116, 105, 116, 111), "#5a3428") F(R(174, 94, 174, 102), "#5a3428")
  local m = c:line(pts, 3)
  c:rim(m, "#6e3a2c")
  F(m, "#c4703e")
  F(c:line({ { 90, 111 }, { 140, 99 }, { 176, 92 }, { 204, 92 } }, 1), "#eea268")
  -- joint collars
  for _, p in ipairs{ { 84, 125 }, { 115, 106 }, { 158, 96 }, { 190, 93 }, { 212, 121 }, { 220, 150 } } do
    F(R(p[1] - 1, p[2] - 1, p[1] + 1, p[2] + 1), "#8a4a30")
  end
  -- spout at the shack
  F(R(76, 136, 79, 140), "#8a4a30")
end

---------------------------------------------------------------- MARKET SQUARE FOUNTAIN (runs on syrup)
do
  F(E(246, 222, 32, 5), SHADE)
  local face = PL{ { 212, 200 }, { 264, 200 }, { 264, 216 }, { 258, 220 }, { 218, 220 }, { 212, 216 } }
  tex(face, function(x, y) if x >= 256 then return blocks({ b = "#8e8298", d = "#76708a", h = "#9c92a2" }, 5, 9)(x, y) end
    return blocks({ b = "#aea2b2", d = "#867a90", h = "#c8bcc8" }, 5, 9)(x, y) end)
  local rim = PL{ { 218, 193 }, { 258, 193 }, { 264, 197 }, { 264, 202 }, { 258, 206 }, { 218, 206 }, { 212, 202 }, { 212, 197 } }
  F(rim, "#d8ccd0")
  local pool = PL{ { 221, 196 }, { 255, 196 }, { 259, 199 }, { 259, 201 }, { 255, 204 }, { 221, 204 }, { 217, 201 }, { 217, 199 } }
  tex(pool, function(x, y) if (x + y * 3) % 9 == 0 then return "#f6c45a" end if y >= 203 then return "#b8661e" end return "#e0962e" end)
  -- pillar + upper bowl
  local pil = R(234, 182, 242, 199)
  tex(pil, function(x, y) if x >= 240 then return "#9c92a2" elseif x == 234 then return "#d8ccd0" end return "#bcb0c0" end)
  local bowl = PL{ { 223, 180 }, { 253, 180 }, { 248, 187 }, { 228, 187 } }
  tex(bowl, function(x, y) if y <= 181 then return "#e0962e" elseif x > 246 then return "#9c92a2" end return "#c8bcc8" end)
  -- syrup dribbles
  for _, dx in ipairs{ 225, 251 } do F(R(dx, 182, dx, 195), "#e0962e") px(dx, 184, "#f6c45a") end
  -- leaf finial
  c:paint({ "...a...", ".a.a.a.", ".aaaaa.", "aaaaaaa", ".aaaaa.", "...b...", "...b..." }, 235, 172,
    { a = "#e8762e", b = "#8a3a30" })
  local all = face:copy():add(rim):add(pil):add(bowl)
  c:edgeIn(all, "#5e5470")
  -- syrup pour from the pipe
  F(R(229, 181, 230, 182), "#e0962e")
end

---------------------------------------------------------------- NOTICE BOARD with a sign pointing both ways
do
  F(E(70, 245, 24, 3), SHADE)
  local arrow = PL{ { 43, 191 }, { 50, 185 }, { 50, 188 }, { 78, 188 }, { 78, 185 }, { 85, 191 }, { 78, 197 }, { 78, 194 }, { 50, 194 }, { 50, 197 } }
  F(R(63, 196, 65, 201), "#6a3e28")
  tex(arrow, function(x, y) if y >= 193 then return "#d8a43a" elseif y <= 189 then return "#f8d870" end return "#f0c24a" end)
  c:edgeIn(arrow, "#8a5a24")
  local cap = PL{ { 38, 203 }, { 42, 198 }, { 86, 198 }, { 90, 203 } }
  tex(cap, shingle({ b = "#c4503a", d = "#8a3a30", h = "#e47a58" }, 2, 4, 198))
  F(R(45, 228, 48, 244), "#7a4a30") F(R(80, 228, 83, 244), "#7a4a30")
  F(R(46, 228, 46, 244), "#a06a44") F(R(81, 228, 81, 244), "#a06a44")
  local bd = R(42, 203, 86, 228)
  F(bd, "#8a5434")
  tex(R(44, 205, 84, 226), function(x, y) return hh(x, y, 11) > .85 and "#b07a48" or "#c89058" end)
  local notes = { { 47, 207, 56, 216, "#f4ead4" }, { 59, 206, 68, 213, "#f4dc8a" }, { 71, 208, 80, 218, "#f0c4c0" },
    { 50, 218, 60, 224, "#c4d4ec" }, { 64, 216, 72, 223, "#f4ead4" } }
  for _, n in ipairs(notes) do
    F(R(n[1], n[2], n[3], n[4]), n[5])
    F(R(n[3], n[2] + 1, n[3], n[4]), "#c4a890")
    for yy = n[2] + 3, n[4] - 1, 2 do F(R(n[1] + 2, yy, n[3] - 2, yy), "#a89098") end
    px((n[1] + n[3]) // 2, n[2] + 1, "#d4443c")
  end
  c:paint({ "..a..", "aaaaa", ".aaa.", "..b.." }, 76, 220, { a = "#e8762e", b = "#8a3a30" })
  local all = bd:copy():add(cap):add(R(45, 228, 48, 244)):add(R(80, 228, 83, 244))
  c:edgeIn(all, "#5a3428")
end

---------------------------------------------------------------- ORCHARD PATH: wooden arch gate under an apple tree
do
  F(E(358, 265, 26, 3), SHADE)
  -- path through the arch
  F(PL{ { 340, 264 }, { 366, 264 }, { 360, 228 }, { 346, 228 } }, "#d8b88a")
  -- apple tree canopy behind
  local can = E(339, 210, 15, 9):add(E(367, 210, 15, 9)):add(E(353, 203, 13, 8)):add(E(353, 214, 20, 7))
  F(R(345, 214, 347, 230), "#6e4a3a") F(R(359, 214, 361, 230), "#6e4a3a")
  tex(can, function(x, y)
    local v = (x - 353) / 30 + (y - 208) / 12 + (hh(x // 3, y // 3, 13) - .5) * .8
    if v < -.6 then return "#c4c868" elseif v < .1 then return "#8eaa4a" elseif v < .7 then return "#6a8a3e" end
    return "#4e6a36"
  end)
  for i = 0, 40 do
    local ax, ay = 330 + floor(hh(i, 1, 17) * 46), 200 + floor(hh(i, 2, 17) * 18)
    if can:has(ax, ay) and can:has(ax + 1, ay + 1) and hh(i, 3, 17) > .45 then
      F(R(ax, ay, ax + 1, ay + 1), "#d8403a") px(ax, ay, "#f47a5a")
    end
  end
  c:edgeIn(can, "#3e5a30")
  -- arch
  local arch = E(353, 226, 24, 12):cut(E(353, 226, 17, 8)):clip(R(320, 200, 390, 226))
  local posts = R(331, 222, 335, 264):add(R(371, 222, 375, 264))
  local wood = arch:copy():add(posts)
  tex(wood, function(x, y)
    if x == 331 or x == 371 then return "#c08050" end
    if (y + x // 5) % 6 == 0 then return "#7a4a30" end
    if x >= 374 or x == 335 then return "#7a4a30" end
    return "#9a6038"
  end)
  -- leaf garland on the arch
  for i, p in ipairs{ { 334, 216 }, { 341, 210 }, { 349, 207 }, { 357, 207 }, { 365, 210 }, { 372, 216 } } do
    local cl = ({ "#d4443c", "#ee9236", "#f0c24a" })[(i % 3) + 1]
    F(R(p[1], p[2], p[1] + 1, p[2] + 1), cl)
  end
  -- half-open picket gates
  local gate = HP.mask()
  for x = 337, 349, 3 do gate:add(R(x, 238, x + 1, 262)) end
  for x = 358, 369, 3 do gate:add(R(x, 238, x + 1, 262)) end
  gate:add(R(337, 242, 350, 243)):add(R(357, 242, 370, 243)):add(R(337, 256, 350, 257)):add(R(357, 256, 370, 257))
  tex(gate, function(x, y) if y == 242 or y == 256 then return "#a06a44" end return "#d8a46a" end)
  c:edgeIn(wood, "#5a3826")
  c:edgeIn(gate, "#7a4a30")
  -- grass tufts at post feet
  for _, gx in ipairs{ 328, 330, 377, 379 } do F(R(gx, 261, gx, 264), "#6a8a3e") end
end

---------------------------------------------------------------- GATE FRAME
do
  local woodT = { b = "#7e4c34", d = "#5a3428", h = "#9e6644" }
  local stoneT = { b = "#9c92a2", d = "#766e86", h = "#bab0bc" }
  local function grainV(x, y) if (x + floor(hh(x, y // 9, 21) * 2)) % 6 == 0 then return woodT.d end
    if x % 6 == 2 then return woodT.h end return woodT.b end
  tex(R(0, 0, 19, 150), grainV) F(R(18, 16, 19, 150), woodT.d)
  tex(R(460, 0, 479, 150), grainV) F(R(460, 16, 461, 150), woodT.d)
  tex(R(0, 151, 21, 269), blocks(stoneT, 7, 11)) F(R(20, 151, 21, 269), "#766e86")
  tex(R(458, 151, 479, 269), blocks(stoneT, 7, 11)) F(R(458, 151, 459, 269), "#bab0bc")
  F(R(0, 150, 22, 151), "#5a3428") F(R(457, 150, 479, 151), "#5a3428")
  tex(R(0, 0, 479, 15), function(x, y) if y == 15 then return "#4a2c26" elseif y == 0 then return woodT.d end
    if (y + floor(hh(x // 14, 1, 23) * 4)) % 5 == 0 and hh(x // 3, y, 29) > .2 then return woodT.d end
    if y <= 2 then return woodT.h end return woodT.b end)
  -- braces
  for _, br in ipairs{ { { 20, 16 }, { 42, 16 }, { 20, 38 } }, { { 459, 16 }, { 437, 16 }, { 459, 38 } } } do
    local m = PL(br) F(m, woodT.b) c:edgeIn(m, woodT.d)
  end
  -- pegs
  for _, x in ipairs{ 8, 470, 120, 360 } do F(R(x, 6, x + 1, 7), "#c89a4a") end
  -- bunting: leaves and mittens on a sagging rope
  local function rope(x0, x1, sag)
    local pts = {}
    for x = x0, x1 do local t = (x - x0) / (x1 - x0) local y = 18 + floor(sag * 4 * t * (1 - t)) px(x, y, "#5a3a32") pts[x] = y end
    return pts
  end
  local LEAF = { "...a...", ".a.a.a.", ".aaaaa.", "aaaaaaa", ".aaaaa.", "...b...", "...b..." }
  local MIT = { ".aa...", "aaaa..", "aaaa.a", "aaaaaa", "aaaaa.", "ccccc.", "ccccc." }
  local cols = { "#d4443c", "#ee8a2c", "#f0c24a" }
  local mcols = { "#4a9aa0", "#c84a5a", "#6a7ac0" }
  local function hang(pts, x0, x1, ph)
    local i = ph
    for x = x0 + 8, x1 - 8, 13 do
      local y = pts[x] + 1
      i = i + 1
      if i % 2 == 0 then c:paint(LEAF, x - 3, y, { a = cols[(i // 2) % 3 + 1], b = "#7a3a2c" })
      else c:paint(MIT, x - 3, y, { a = mcols[(i // 2) % 3 + 1], c = CREAM }) end
    end
  end
  local lp = rope(22, 206, 12) hang(lp, 22, 206, 0)
  local rp = rope(274, 458, 12) hang(rp, 274, 458, 1)
  -- hanging lantern
  F(R(100, 16, 100, 25), "#4a3a3a")
  local lan = PL{ { 96, 26 }, { 104, 26 }, { 106, 29 }, { 94, 29 } }
  F(lan, "#4a3a3a")
  local glass = R(96, 30, 104, 41)
  tex(glass, function(x, y) if x == 96 or x == 104 or x == 100 then return "#4a3a3a" end
    if (x == 98 or x == 102) and y > 32 and y < 39 then return "#fbe6a0" end return "#f6c860" end)
  F(R(95, 42, 105, 43), "#4a3a3a") F(R(99, 44, 101, 45), "#4a3a3a")
  F(R(95, 30, 95, 41), "#6a5050") F(R(105, 30, 105, 41), "#6a5050")
end

c:finish{ outline = false }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
