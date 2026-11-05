-- here-stop-inn.lua : Gnome Venture "Hearth Pop" v3 gate-view place, roadside Inn rest stop at lantern-lit evening.
-- 480x270 native, one-point perspective to (240,112). Run with --script-param out=<dir>/
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-inn"
local W, Hh, HOR, VPX = 480, 270, 112, 240
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = NAME }
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min

local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 1442695041) & 0x7fffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
  n = n ~ (n >> 16)
  return (n % 10007) / 10007
end
local function px(x, y, col) c:put(x, y, col) end
local function R(d, s, b, h) return { d = d, s = s, b = b, h = h } end
local rect, poly = function(...) return c:rect(...) end, function(t) return c:poly(t) end

-- paint a mask: base, lit upper-left band, shade lower-right band, texture, own dark edge
local function paint(m, Rm, tex, o)
  o = o or {}
  local sh, lt = o.sh or 3, o.lt or 2
  m:each(function(x, y)
    local col = Rm.b
    if not o.noshade and (not m:has(x + sh, y) or not m:has(x, y + sh)) then col = Rm.s end
    if not o.nohi and (not m:has(x - lt, y) or not m:has(x, y - lt)) then col = Rm.h end
    if tex then local t = tex(x, y) if t then col = Rm[t] or t end end
    px(x, y, col)
  end)
  if not o.noedge then m:edge():each(function(x, y) px(x, y, Rm.d) end) end
  return m
end
-- textures
local function planksH(h, seed, y0)
  return function(x, y)
    if (y - (y0 or 0)) % h == 0 then return "s" end
    local r = hash(x // 9, y // h, seed)
    if hash(x, y, seed) < 0.05 then return "s" end
    if (x + floor(r * 20)) % 23 == 0 then return "d" end
  end
end
local function planksV(w, seed, x0)
  return function(x, y)
    if (x - (x0 or 0)) % w == 0 then return "s" end
    if hash(x, y // 3, seed) < 0.06 then return "s" end
    if hash(x // w, y, seed + 1) < 0.012 then return "d" end
  end
end
local function bricks(bw, bh, seed, x0, y0)
  return function(x, y)
    local row = (y - y0) // bh
    local off = (row % 2) * (bw // 2)
    if (y - y0) % bh == 0 then return "s" end
    if (x - x0 + off) % bw == 0 then return "s" end
    local r = hash((x - x0 + off) // bw, row, seed)
    if r < 0.18 and (y - y0) % bh == 1 then return "h" end
    if r > 0.85 and hash(x, y, seed) < 0.3 then return "s" end
  end
end
local function shingles(rh, sw, seed, y0)
  return function(x, y)
    local row = (y - y0) // rh
    local off = (row % 2) * (sw // 2)
    if (y - y0) % rh == rh - 1 then return "d" end
    if (x + off) % sw == 0 and (y - y0) % rh >= rh - 3 then return "s" end
    if hash((x + off) // sw, row, seed) < 0.15 and (y - y0) % rh == 0 then return "h" end
  end
end
local function speck(seed, a, b)
  return function(x, y)
    local r = hash(x, y, seed)
    if r < (a or 0.05) then return "s" elseif r > 1 - (b or 0.03) then return "h" end
  end
end
local function thatch(seed)
  return function(x, y)
    local r = hash(x, y // 4, seed)
    if (y % 6 == 5) then return "s" end
    if r < 0.2 then return "s" elseif r > 0.88 then return "h" end
  end
end
local function leafy(seed)
  return function(x, y)
    local r = hash(x // 3, y // 2, seed)
    local q = hash(x, y, seed + 9)
    if r < 0.18 then return "s" end
    if r > 0.86 and q < 0.6 then return "h" end
    if q < 0.03 then return "d" end
  end
end

---------------------------------------------------------------- palette
local INK2 = "#2b1c26"
local GLOW = { "#fff0b0", "#ffd66e", "#f7a845", "#d9783a" }
local SKY = { "#1f2448", "#262b55", "#2f3262", "#3a376e", "#4a3d78", "#5d437f", "#744a86", "#8e5288",
              "#a95c86", "#c26a80", "#d97f7a", "#e89a74", "#f2b673" }
local Rframe = R("#2e1a16", "#4e2e22", "#6e4430", "#8c5c3e")
local Rtimber = R("#24140f", "#3a2219", "#553222", "#6e432c")
local Rplaster = R("#7a5848", "#c6a486", "#e4c99c", "#f3dcb0")
local Rplasd = R("#5a4048", "#8e7480", "#a88e8e", "#bca298")
local Rstone = R("#3e3442", "#62586a", "#857a84", "#a69a9c")
local Rroof = R("#4e1c2a", "#73303a", "#9a4440", "#c06650")
local Rbrick = R("#3a2026", "#6a3a36", "#8e5046", "#ae6e58")
local Rdoor = R("#2e1810", "#5a3018", "#7c4422", "#9c5e30")
local Rhoney = R("#4a2a14", "#8a5a2a", "#b07a3e", "#d39a56")
local Rstable = R("#3e1a1a", "#6e3028", "#8e4434", "#aa5e44")
local Rthatch = R("#5a4020", "#94703a", "#c09a52", "#dcbc72")
local Rhut1 = R("#28324e", "#4c5e80", "#6a82a6", "#8aa2c2")
local Rmoss = R("#22381e", "#3c5a2c", "#5a7a3a", "#7c9a4c")
local Rhut2 = R("#5a4434", "#9c8466", "#c4ac86", "#ddc8a0")
local Rplum = R("#341c34", "#56304e", "#7a4a6e", "#9c6688")
local Rteal = R("#173a3a", "#2a6260", "#3f8a86", "#5eaaa2")
local Rwellst = R("#2e3448", "#4e5a72", "#6e7a92", "#909cb0")
local Rpine = R("#162826", "#1f3632", "#29443c", "#355448")
local Rbush = R("#16301e", "#244a2c", "#356240", "#4c8050")
local Rbark = R("#24160f", "#3c2618", "#54361f", "#6e4a2a")
local Riron = R("#1e1a24", "#36303e", "#4e4658", "#6e6676")
local Rbrass = R("#5a3a12", "#9a6a1e", "#cc962e", "#f0c650")
local Rred = R("#4a1418", "#8a2a2a", "#b83c34", "#de6448")
local Rcream = R("#8c7458", "#d8c49c", "#efe0bc", "#fbf0d4")
local Rcopper = R("#4a2416", "#8a4a26", "#b86a32", "#e0904a")
local Rbarrel = R("#3a2010", "#6a3c1c", "#8c5428", "#ac6e38")

---------------------------------------------------------------- sky
local sh = HOR
for y = 0, sh do
  local t = y / sh
  local i = min(#SKY, floor(t * t * 0.4 * #SKY + t * 0.6 * #SKY) + 1)
  for x = 0, W - 1 do px(x, y, SKY[i]) end
end
-- stars (small crosses, cream / pale)
local stars = { {70,24},{118,40},{172,18},{214,34},{268,22},{318,38},{352,16},{402,30},{150,54},{300,58},{96,62},{378,52} }
for i, s in ipairs(stars) do
  px(s[1], s[2], "#fff4d0")
  if i % 3 == 1 then px(s[1]-1, s[2], "#c8bce0") px(s[1]+1, s[2], "#c8bce0") px(s[1], s[2]-1, "#c8bce0") px(s[1], s[2]+1, "#c8bce0") end
end
-- evening clouds lit warm from below
c:cloud(60, 74, 46, "#9a5c8c", "#e08a7a")
c:cloud(330, 70, 58, "#9a5c8c", "#e08a7a")
c:cloud(200, 50, 34, "#6e4a84", "#b4648a")
c:cloud(410, 88, 30, "#b46a88", "#ef9e78")

---------------------------------------------------------------- far scenery
c:terrain(function(x) return 92 + 6 * sin(x / 41) + 3 * sin(x / 13 + 2) end, "#4a3f6e", HOR)
-- far cottage on the hill with one lit window (quirk: someone's still up)
paint(rect(150, 90, 160, 98), R("#2e2848", "#3c3458", "#463c62", "#524670"), nil, { nohi = true, noshade = true })
paint(poly{{148,91},{155,85},{162,91}}, R("#2a2240", "#362c50", "#3e325a", "#4a3c66"), nil, { nohi = true, noshade = true })
px(153, 94, GLOW[2]) px(154, 94, GLOW[2]) px(153, 95, GLOW[3]) px(154, 95, GLOW[3])
c:terrain(function(x) return 101 + 4 * sin(x / 27 + 1) + 2 * sin(x / 9) end, "#3c4a66", HOR)
c:terrain(function(x) return 107 + 2 * sin(x / 19 + 3) end, "#35505a", HOR)
-- distant pine line
for i = 0, 40 do
  local x = 8 + i * 12 + floor(hash(i, 1, 3) * 6)
  local hgt = 8 + floor(hash(i, 2, 3) * 9)
  if abs(x - VPX) > 18 then
    local by = 111
    paint(poly{{x - 4, by}, {x, by - hgt}, {x + 4, by}}, R("#203640", "#284048", "#2e4a50", "#38585a"), nil, { noedge = true, nohi = true })
  end
end

-- v2.5.40 polish pass 4a: atmospheric haze on the far hills and pines (lighter, cooler with distance)
do
  local FARC = { ["#4a3f6e"]=true, ["#3c4a66"]=true, ["#35505a"]=true, ["#203640"]=true, ["#284048"]=true, ["#2e4a50"]=true, ["#38585a"]=true }
  for y = 80, 111 do for x = 0, W - 1 do
    local cur = c:get(x, y)
    if FARC[cur] then
      local p = (y - 80) / 34
      local r = hash(x, y, 300)
      if r < p * 0.75 then px(x, y, (cur == "#4a3f6e") and "#6a5a8c" or ((r < p * 0.3) and "#7a78a0" or "#5a6a88")) end
    end
  end end
end

---------------------------------------------------------------- ground
local function pathL(y) return 232 - 72 * (y - HOR) / 157 end
local function pathR(y) return 248 + 72 * (y - HOR) / 157 end
local pathM = HP.mask()
for y = HOR, Hh - 1 do
  local gcol = (y < 126) and "#4a6446" or ((y < 152) and "#4e6a40" or "#547140")
  for x = 0, W - 1 do px(x, y, gcol) end
  for x = floor(pathL(y) + .5), floor(pathR(y) + .5) do pathM:set(x, y) end
end
-- grass tufts
for y = HOR + 2, Hh - 1 do for x = 0, W - 1 do
  local d = (y - HOR) / 158
  if hash(x, y, 77) < 0.012 + 0.012 * d then
    local hgt = 1 + floor(d * 3)
    for k = 0, hgt do px(x, y - k, "#3e5634") end
    px(x, y - hgt - 1, "#6c8a4c")
    if d > 0.4 then px(x + 1, y - 1, "#3e5634") px(x + 1, y - 2, "#6c8a4c") end
  end
end end
-- path dirt
pathM:each(function(x, y)
  local d = (y - HOR) / 158
  local col = (d < 0.2) and "#8e7262" or "#9e7a58"
  local r = hash(x, y, 31)
  if r < 0.06 then col = "#866448" elseif r > 0.97 then col = "#b48e66" end
  px(x, y, col)
end)
-- wheel ruts converge to the vanishing point
for y = HOR + 4, Hh - 1 do
  local d = (y - HOR) / 157
  for _, bx in ipairs({ 196, 284 }) do
    local x = floor(VPX + (bx - VPX) * d + .5)
    local w = max(1, floor(d * 4))
    for k = 0, w - 1 do px(x + k, y, "#7a5a42") end
    px(x - 1, y, "#b08a64")
  end
end
-- flat pebbles on the path
for y = HOR + 8, Hh - 3, 1 do for x = 150, 330 do
  if pathM:has(x, y) and pathM:has(x + 5, y) and hash(x, y, 5) < 0.0035 * (1 + (y - HOR) / 60) then
    local w = 2 + floor((y - HOR) / 40)
    for k = 0, w do px(x + k, y, "#c09c74") end
    for k = 0, w do px(x + k, y + 1, "#6e5444") end
  end
end end
-- path verge line
for y = HOR, Hh - 1 do px(floor(pathL(y) + .5) - 1, y, "#6e5a3e") px(floor(pathR(y) + .5) + 1, y, "#6e5a3e") end

-- warm light pools (flat, wide)
local function pool(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  m:each(function(x, y)
    if y > HOR then
      if pathM:has(x, y) then px(x, y, "#c29a6a") else
        local cur = c:get(x, y)
        px(x, y, (cur == "#3e5634") and "#5a6a3a" or "#6e7c48")
      end
    end
  end)
end
pool(116, 176, 48, 7)
pool(36, 224, 30, 8)
pool(358, 228, 28, 5)

-- cool-violet ground shadow helper
local function shadow(m)
  m:each(function(x, y) if y > HOR then px(x, y, pathM:has(x, y) and "#6c5664" or "#3c4a44") end end)
end

-- v2.5.40 polish pass 1: ground variety (grass bands, worn dirt, flowers, leaves, pebbles)
local STANDS = { {240,250},{198,210},{282,208},{240,162},{100,256},{345,254} }
local function free(x, y, r)
  for _, s in ipairs(STANDS) do
    local dx, dy = x - s[1], y - s[2]
    if dx * dx + dy * dy < r * r then return false end
  end
  return true
end
local GRASS = { ["#4a6446"]=true, ["#4e6a40"]=true, ["#547140"]=true }
for y = HOR + 2, Hh - 1 do for x = 0, W - 1 do
  if not pathM:has(x, y) and GRASS[c:get(x, y)] then
    local n = sin(x / 17 + y / 9) + sin(x / 7 - y / 11) + sin((x + y) / 23)
    local d = (y - HOR) / 158
    if n > 1.5 then px(x, y, d < 0.15 and "#56704c" or "#5f7d46")
    elseif n < -1.6 then px(x, y, "#43603a")
    elseif n < -1.1 and hash(x, y, 8) < 0.4 then px(x, y, "#43603a") end
  end
end end
-- worn dirt patches where feet go (door, table, board, well, trail)
local function wear(cx, cy, rx, ry, seed)
  c:ellipse(cx, cy, rx, ry):each(function(x, y)
    if y > HOR and not pathM:has(x, y) and free(x, y, 16) then
      local e = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if e < 0.55 or hash(x, y, seed) < (1 - e) * 1.6 then
        px(x, y, hash(x, y, seed + 1) < 0.2 and "#7a6046" or "#8c7454")
      end
    end
  end)
end
wear(116, 178, 26, 4, 140) wear(88, 238, 36, 5, 141) wear(358, 226, 22, 4, 142)
wear(300, 182, 14, 3, 143) wear(404, 222, 18, 3, 144)
-- footpaths from the road to the door, the table, the board and the trail
local function foot(pts, seed)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for k = 0, n do
      local x = floor(a[1] + (b[1] - a[1]) * k / n + .5)
      local y = floor(a[2] + (b[2] - a[2]) * k / n + .5)
      for dx = -1, 1 do if hash(x + dx, y, seed) < 0.75 and free(x + dx, y, 16) and not pathM:has(x + dx, y) then px(x + dx, y, "#8c7454") end end
    end
  end
end
foot({{176,178},{150,176},{128,178}}, 150) foot({{190,224},{150,230},{120,238}}, 151)
foot({{300,200},{332,214},{352,224}}, 152) foot({{322,164},{300,176}}, 153) foot({{340,190},{380,200},{412,210}}, 154)
-- flowers, leaves, pebbles in the grass (never near stand points)
local FL = { "#e05a6a", "#f0d060", "#b49ae0", "#f4e8c0", "#f08aa0" }
for y = HOR + 10, Hh - 2 do for x = 18, W - 20 do
  if not pathM:has(x, y) and GRASS[c:get(x, y)] and free(x, y, 20) then
    local r = hash(x, y, 160)
    if r < 0.0042 then
      local col = FL[1 + floor(hash(x, y, 161) * #FL)]
      px(x, y, col) px(x, y + 1, "#3e5634")
      if hash(x, y, 162) < 0.5 then px(x + 1, y, col) end
    elseif r > 0.9975 then
      px(x, y, "#c0642e") px(x + 1, y, "#d98a3a")
    elseif r > 0.9955 then
      px(x, y, "#a8a0a4") px(x + 1, y, "#8a8290") px(x, y + 1, "#5a4e5c") px(x + 1, y + 1, "#5a4e5c")
    end
  end
end end
-- fallen leaves and grit along the road edge
for y = HOR + 6, Hh - 2 do for x = 100, 400 do
  if pathM:has(x, y) and free(x, y, 18) and hash(x, y, 170) > 0.9972 then
    px(x, y, "#c0642e") px(x + 1, y, "#d98a3a")
  end
end end

---------------------------------------------------------------- back pines behind the homes
for _, t in ipairs({ {270,58,30}, {300,48,40}, {336,56,32}, {372,46,42}, {404,60,28} }) do
  local x, top, hw = t[1], t[2], t[3] // 2
  local m = HP.mask()
  for tier = 0, 3 do
    local ty = top + tier * 14
    m:add(poly{{x - hw * (tier + 2) // 5, ty + 20}, {x, ty}, {x + hw * (tier + 2) // 5, ty + 20}})
  end
  m:clip(rect(0, 0, W - 1, 118))
  paint(m, Rpine, leafy(t[1]))
end
-- back trees behind stable
for _, t in ipairs({ {200,64,26}, {226,72,20} }) do
  local x, top, hw = t[1], t[2], t[3] // 2
  local m = HP.mask()
  for tier = 0, 3 do
    local ty = top + tier * 11
    m:add(poly{{x - hw * (tier + 2) // 5, ty + 16}, {x, ty}, {x + hw * (tier + 2) // 5, ty + 16}})
  end
  m:clip(rect(0, 0, W - 1, 116))
  paint(m, Rpine, leafy(t[1] + 3))
end

---------------------------------------------------------------- stable (far left, beside the inn)
shadow(poly{{176,126},{228,126},{236,131},{182,131}})
local stW = paint(rect(178, 100, 224, 126), Rstable, planksV(5, 11, 178))
paint(poly{{172,102},{190,84},{212,84},{230,102}}, Rthatch, thatch(12), { sh = 2 })
-- open stable door with hay
paint(rect(190, 108, 210, 126), R("#1e1214", "#2a1a1c", "#34201e", "#3e2824"), nil, { nohi = true })
paint(poly{{192,126},{196,116},{204,114},{209,126}}, Rthatch, thatch(13), { sh = 2 })
-- door X brace leaves swung open
paint(rect(180, 108, 189, 126), Rhoney, function(x, y) if (x - 180) == (y - 108) // 2 then return "d" end end)
paint(rect(211, 108, 220, 126), Rhoney, function(x, y) if (220 - x) == (y - 108) // 2 then return "d" end end)
-- saddle draped over a fence rail (quirk-ish detail)
paint(rect(166, 118, 176, 120), Rtimber, nil, { noshade = true })
paint(rect(166, 116, 168, 126), Rtimber) paint(rect(174, 116, 176, 126), Rtimber)
paint(poly{{168,114},{173,114},{174,121},{167,121}}, Rred)

---------------------------------------------------------------- INN (k=do)
shadow(poly{{20,166},{166,160},{176,170},{30,172}})
-- side face receding toward the path
paint(poly{{150,84},{166,94},{166,158},{150,166}}, Rplasd, speck(21, 0.06, 0.02), { nohi = true })
paint(rect(150, 84, 166, 87):clip(poly{{150,84},{166,94},{166,158},{150,166}}), Rtimber)
paint(poly{{150,126},{166,124},{166,127},{150,129}}, Rtimber, nil, { noshade = true })
paint(poly{{156,98},{162,101},{162,112},{156,110}}, R("#8a4a1e", "#d9783a", "#f7a845", "#ffd66e"), nil, { noshade = true })
-- upper storey plaster with timber frame
paint(rect(22, 84, 150, 128), Rplaster, speck(22, 0.05, 0.03))
local tim = HP.mask()
tim:add(rect(22, 84, 150, 87)):add(rect(22, 124, 150, 128))
for _, xx in ipairs({ 22, 56, 104, 146 }) do tim:add(rect(xx, 84, xx + 4, 128)) end
tim:add(c:line({{26,124},{38,88}}, 3)):add(c:line({{142,124},{130,88}}, 3))
paint(tim, Rtimber, planksV(40, 23), { sh = 1 })
-- ground storey stone
paint(rect(22, 129, 150, 166), Rstone, bricks(12, 6, 24, 22, 129))
-- roof (side gable) + front gable dormer
local roof = poly{{12,86},{40,38},{132,38},{160,86}}
paint(roof, Rroof, shingles(6, 8, 25, 38), { sh = 3 })
paint(rect(10, 84, 162, 88), Rtimber, nil, { noshade = true })
-- chimney with puffs
paint(rect(44, 20, 58, 48), Rbrick, bricks(7, 4, 26, 44, 20))
paint(rect(42, 18, 60, 22), Rstone, nil, { noshade = true })
for i, p in ipairs({ {60,12,6,4}, {70,8,8,5}, {84,6,6,4} }) do
  local m = c:rrect(p[1], 14 - i * 2, p[1] + p[3] * 2, 14 - i * 2 + p[4], 2)
  m:clip(rect(0, 14, W - 1, 19))
  paint(m, R("#8a7aa0", "#a898bc", "#c4b6d4", "#ddd0e6"), nil, { noedge = true, noshade = true })
end
-- dormer gable
paint(rect(70, 56, 108, 86), Rplaster, speck(27))
paint(poly{{62,60},{89,30},{116,60},{110,60},{89,38},{68,60}}, Rtimber, nil, { sh = 1 })
paint(poly{{68,60},{89,38},{110,60}}:cut(rect(70, 56, 108, 86)):add(poly{{72,56},{89,40},{106,56}}), Rplaster, speck(28))
-- teapot weathervane on the ridge (quirk)
paint(rect(124, 24, 125, 38), Riron, nil, { noshade = true, nohi = true })
paint(c:rrect(118, 16, 130, 24, 2), Rcopper)
paint(rect(122, 14, 126, 16), Rcopper, nil, { noshade = true })
paint(c:line({{130,20},{135,16}}, 2), Rcopper, nil, { noshade = true, nohi = true })
paint(rect(115, 18, 117, 22), Rcopper, nil, { noshade = true, nohi = true })

-- lit window helper
local function window(x0, y0, x1, y1, cross, box)
  paint(rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), Rtimber, nil, { sh = 1 })
  local g = rect(x0, y0, x1, y1)
  g:each(function(x, y)
    local col = GLOW[2]
    if x - x0 < 3 and y - y0 < 3 then col = GLOW[1] end
    if x1 - x < 3 or y1 - y < 2 then col = GLOW[3] end
    px(x, y, col)
  end)
  local mx, my = (x0 + x1) // 2, (y0 + y1) // 2
  for x = x0, x1 do px(x, my, Rtimber.b) end
  if cross then for y = y0, y1 do px(mx, y, Rtimber.b) end end
  -- warm spill on the wall right under the sill
  paint(rect(x0 - 3, y1 + 3, x1 + 3, y1 + 4), Rtimber, nil, { noshade = true })
  if box then -- flower box
    paint(rect(x0 - 2, y1 + 5, x1 + 2, y1 + 9), Rhoney, planksH(3, 41, y1 + 5))
    for k = x0, x1, 4 do px(k, y1 + 4, "#e05a6a") px(k + 1, y1 + 3, "#f08aa0") px(k + 2, y1 + 4, "#6a9a4a") end
  end
end
window(30, 94, 48, 116, true)
window(118, 94, 136, 116, true, true)
window(80, 64, 98, 78, true)
window(30, 136, 54, 154, true)
window(64, 136, 88, 154, true)
-- hanging sign (tankard icon) from a beam
paint(rect(58, 88, 104, 90), Riron, nil, { noshade = true })
paint(rect(64, 90, 65, 96), Riron, nil, { noshade = true, nohi = true })
paint(rect(96, 90, 97, 96), Riron, nil, { noshade = true, nohi = true })
-- sign shadow on wall
rect(64, 99, 102, 121):each(function(x, y) px(x, y, Rplaster.s) end)
paint(c:rrect(60, 96, 100, 118, 2), Rhoney, planksH(5, 42, 96))
paint(rect(72, 101, 84, 114), Rbrass)
paint(rect(85, 104, 89, 111):cut(rect(85, 106, 87, 109)), Rbrass, nil, { noshade = true })
paint(rect(71, 99, 85, 102), Rcream, nil, { noshade = true })
-- door, half open with warm light
paint(rect(100, 130, 130, 166), Rtimber, nil, { sh = 1 })
local dIn = c:rrect(103, 133, 127, 166, 5)
dIn:each(function(x, y) px(x, y, (x > 122 or y > 162) and GLOW[3] or GLOW[2]) end)
paint(c:rrect(103, 133, 113, 166, 4):cut(rect(112, 133, 113, 140)), Rdoor, planksV(4, 43, 103))
px(110, 150, Rbrass.h) px(110, 151, Rbrass.b)
paint(rect(98, 164, 132, 168), Rstone, nil, { noshade = true })
-- porch lantern
paint(rect(136, 132, 137, 136), Riron, nil, { noshade = true, nohi = true })
paint(rect(133, 137, 141, 148), Riron, function(x, y) if x > 134 and x < 140 and y > 138 and y < 147 then return GLOW[2] end end, { noshade = true })
-- barrels and crate by the door
local function barrel(x0, y0, x1, y1)
  shadow(rect(x0 + 2, y1 - 1, x1 + 4, y1 + 2))
  local m = c:rrect(x0, y0, x1, y1, 3)
  paint(m, Rbarrel, planksV(3, x0, x0))
  for _, hy in ipairs({ y0 + 3, y1 - 3 }) do for x = x0, x1 do if m:has(x, hy) then px(x, hy, Riron.b) end end end
  for x = x0 + 1, x1 - 1 do px(x, y0, Rbarrel.h) end
end
barrel(136, 151, 150, 168)
barrel(152, 154, 164, 169)
-- giant ladle stuck in the barrel (quirk)
paint(c:line({{144,150},{150,136}}, 2), Rcopper, nil, { noshade = true, nohi = true })
paint(c:rrect(148, 130, 154, 136, 2), Rcopper, nil, { noshade = true })
-- crate
shadow(rect(6, 160, 22, 170))
paint(rect(4, 152, 20, 168), Rhoney, function(x, y) if x == 4 + (y - 152) or x == 20 - (y - 152) then return "s" end end)

---------------------------------------------------------------- homes (k=homes), far right tier
-- hut 1: blue plank walls, mossy roof
shadow(poly{{262,132},{324,132},{332,137},{268,137}})
paint(rect(264, 100, 322, 132), Rhut1, planksH(4, 51, 100))
paint(poly{{258,102},{293,70},{328,102}}, Rmoss, leafy(52), { sh = 2 })
paint(rect(256, 100, 330, 103), Rtimber, nil, { noshade = true })
window(270, 108, 282, 120, true)
paint(rect(296, 110, 310, 132), Rdoor, planksV(4, 53, 296))
paint(rect(294, 108, 312, 110), Rtimber, nil, { noshade = true })
px(306, 121, Rbrass.h)
-- mushroom-red door step stone
paint(rect(294, 131, 312, 134), Rstone, nil, { noshade = true })
-- hut 2: cream stone walls, plum roof, chimney
shadow(poly{{336,132},{400,132},{406,137},{342,137}})
paint(rect(338, 98, 398, 132), Rhut2, bricks(10, 5, 54, 338, 98))
paint(rect(380, 70, 390, 90), Rbrick, bricks(5, 4, 55, 380, 70))
paint(poly{{332,100},{368,68},{404,100}}, Rplum, shingles(5, 6, 56, 68), { sh = 2 })
paint(rect(330, 98, 406, 101), Rtimber, nil, { noshade = true })
for i, p in ipairs({ {382,62,6,3}, {388,55,8,4}, {398,49,6,3} }) do
  paint(c:rrect(p[1], p[2], p[1] + p[3], p[2] + p[4], 1), R("#7a6c94", "#9a8cb4", "#b8aace", "#d4c8e2"), nil, { noedge = true, noshade = true })
end
paint(rect(344, 108, 360, 132), Rteal, planksV(4, 57, 344))
paint(rect(342, 106, 362, 108), Rtimber, nil, { noshade = true })
window(372, 108, 390, 120, true, true)
-- clothesline with one odd sock (quirk)
for x = 323, 337 do px(x, 104 + ((x - 323) * (337 - x)) // 30, "#d8c8a8") end
paint(poly{{327,106},{331,106},{331,112},{334,113},{334,115},{327,115}}, Rred, function(x, y) if y == 108 then return "h" end end, { noshade = true })

---------------------------------------------------------------- well (decor, right mid)
shadow(poly{{280,172},{318,172},{324,177},{286,177}})
paint(rect(284, 156, 316, 174), Rwellst, bricks(8, 5, 61, 284, 156))
paint(rect(282, 154, 318, 157), Rwellst, nil, { noshade = true })
paint(rect(286, 138, 289, 154), Rbark) paint(rect(311, 138, 314, 154), Rbark)
paint(poly{{280,141},{300,128},{320,141}}, Rroof, shingles(4, 6, 62, 128), { sh = 2 })
paint(rect(288, 143, 312, 144), Rbark, nil, { noshade = true, nohi = true })
px(299, 145, "#d8c8a8") px(299, 146, "#d8c8a8") px(299, 147, "#d8c8a8")
-- bucket with a sprout growing in it (quirk)
paint(poly{{294,148},{304,148},{303,154},{295,154}}, Rcopper, nil, { noshade = true })
paint(c:line({{299,147},{299,143}}, 1), Rmoss, nil, { noshade = true, nohi = true, noedge = true })
px(297, 142, "#7cb04c") px(298, 143, "#7cb04c") px(300, 143, "#9ccc5c") px(301, 142, "#9ccc5c")

---------------------------------------------------------------- people area (k=people): long table, benches, fire
-- string lights on poles
paint(rect(58, 174, 61, 214), Rbark) paint(rect(156, 174, 159, 214), Rbark)
for x = 61, 156 do
  local t = (x - 61) / 95
  local y = 176 + floor(10 * 4 * t * (1 - t))
  px(x, y, "#3a2a30")
  if (x - 66) % 22 == 0 and x > 62 and x < 154 then
    paint(rect(x - 2, y + 1, x + 2, y + 6), R("#a8541e", "#f0a040", "#ffd66e", "#fff0b0"), nil, { noshade = true })
  end
end
-- back bench
paint(rect(66, 188, 150, 191), Rhoney, nil, { noshade = true })
-- table
shadow(poly{{66,214},{156,214},{164,220},{72,220}})
paint(rect(72, 202, 76, 216), Rtimber) paint(rect(142, 202, 146, 216), Rtimber)
paint(poly{{62,194},{152,194},{158,204},{66,204}}, Rhoney, planksH(3, 71, 194), { sh = 2 })
-- things on the table: mugs, a pie, candle, boot flowerpot (quirk)
for _, mx in ipairs({ 74, 120, 134 }) do
  paint(rect(mx, 189, mx + 4, 195), Rbrass) px(mx + 1, 189, Rcream.h) px(mx + 2, 189, Rcream.h)
end
paint(poly{{86,195},{90,190},{102,190},{106,195}}, Rcopper, function(x, y) if y == 191 and x % 3 == 0 then return "s" end end)
paint(rect(112, 186, 114, 195), Rcream) px(113, 184, GLOW[1]) px(113, 185, GLOW[2])
paint(poly{{140,183},{145,183},{145,191},{151,191},{151,196},{140,196}}, R("#2c1810", "#4e2e1c", "#6a4026", "#88563a"))
px(141, 180, "#e05a6a") px(143, 179, "#f0d060") px(142, 181, "#6a9a4a") px(144, 182, "#6a9a4a") px(142, 182, "#6a9a4a")
-- front bench
shadow(rect(66, 222, 154, 225))
paint(rect(64, 214, 152, 218), Rhoney, planksH(2, 72, 214))
paint(rect(70, 218, 73, 224), Rtimber) paint(rect(142, 218, 145, 224), Rtimber)
-- square stone fire pit with flames
shadow(rect(20, 222, 54, 228))
paint(rect(22, 210, 52, 226), Rstone, bricks(8, 4, 73, 22, 210))
paint(rect(26, 210, 48, 213), R("#24141a", "#2e1a1e", "#3a2224", "#442a2a"), nil, { nohi = true, noshade = true })
paint(poly{{28,211},{31,196},{34,204},{37,188},{41,203},{44,197},{47,211}}, R("#a8341e", "#e0602a", "#f7a845", "#ffe08a"),
  function(x, y) if abs(x - 37) < 3 and y > 200 then return "#fff0b0" end end, { sh = 2 })
for _, sp in ipairs({ {32,184}, {42,180}, {38,176} }) do px(sp[1], sp[2], GLOW[2]) end
-- log seat beside the fire
shadow(rect(14, 232, 34, 234))
paint(c:rrect(8, 226, 32, 232, 2), Rbark, planksH(3, 74, 226))

---------------------------------------------------------------- stop (k=stop): notice board + stamp post
shadow(poly{{332,222},{388,222},{394,227},{338,227}})
paint(rect(338, 196, 341, 224), Rbark) paint(rect(376, 196, 379, 224), Rbark)
paint(poly{{328,180},{358,166},{388,180}}, Rteal, shingles(4, 6, 81, 166), { sh = 2 })
paint(rect(332, 180, 384, 208), Rteal, nil, { sh = 2 })
paint(rect(336, 183, 380, 205), R("#5a3a22", "#8a5e36", "#a87444", "#c08a52"), speck(82, 0.06, 0.02), { nohi = true })
paint(rect(339, 185, 351, 199), Rcream, function(x, y) if (y - 186) % 3 == 0 and x > 340 and x < 350 then return "s" end end)
paint(rect(354, 187, 364, 201), R("#8a5a6a", "#d49aa8", "#f0c0c8", "#fadce0"), function(x, y) if (y - 189) % 3 == 0 and x > 355 and x < 363 then return "s" end end)
paint(rect(367, 184, 377, 194), R("#8a7430", "#d8c060", "#f0dc80", "#faecb0"), nil)
for _, p in ipairs({ {345,185}, {359,187}, {372,184} }) do px(p[1], p[2], Rred.b) end
-- stamp seal icon: red diamond on the board's peak
paint(poly{{358,168},{365,175},{358,182},{351,175}}, Rred)
px(358, 175, Rred.h) px(357, 174, Rred.h)
-- hanging stamp on a cord
for y = 209, 213 do px(384, y, "#d8c8a8") end
paint(rect(381, 214, 387, 216), Rdoor, nil, { noshade = true })
paint(rect(379, 217, 389, 221), Rred)
-- lantern on the post
paint(rect(342, 188, 342, 190), Riron)

---------------------------------------------------------------- wild trail (k=wild), arch of trees on the right edge
-- trail leaving right
local trail = poly{{414,214},{462,196},{462,206},{428,218}}
trail:each(function(x, y) px(x, y, hash(x, y, 91) < 0.08 and "#866448" or "#9a7656") end)
-- trunks
shadow(rect(412, 212, 430, 216))
paint(poly{{416,214},{424,214},{426,140},{420,128},{414,130},{420,142}}, Rbark, planksV(3, 92, 406), { sh = 2 })
paint(poly{{448,206},{456,206},{458,124},{452,128}}, Rbark, planksV(3, 93, 448), { sh = 2 })
-- leafy canopy arch with a gap below
local can = HP.mask()
can:add(c:rrect(410, 104, 440, 140, 10)):add(c:rrect(428, 96, 462, 132, 10)):add(c:rrect(440, 120, 462, 150, 8))
can:add(c:rrect(412, 132, 428, 152, 6))
can:clip(rect(0, 0, 463, Hh - 1))
paint(can, Rbush, leafy(94), { sh = 3 })
-- bush clumps at feet
paint(c:rrect(406, 196, 418, 212, 5), Rbush, leafy(95))
-- signpost with leaf arrow
shadow(rect(436, 206, 448, 209))
paint(rect(438, 166, 441, 208), Rbark)
paint(poly{{426,164},{450,164},{457,170},{450,176},{426,176}}, Rhoney, planksH(4, 96, 164))
paint(poly{{434,170},{440,166},{446,170},{440,174}}, R("#1e4420", "#3a7a34", "#5aa048", "#86c460"), nil, { noshade = true })
px(439, 170, "#1e4420") px(440, 170, "#1e4420") px(441, 170, "#1e4420")
-- a small lantern hung from the branch
for y = 146, 150 do px(424, y, "#3a2a30") end
paint(rect(421, 151, 427, 159), Riron, function(x, y) if x > 421 and x < 427 and y > 152 and y < 158 then return GLOW[2] end end, { noshade = true })

-- v2.5.40 polish pass 2: material cues (cracks, chips, moss, grain, rust, rope, cloth folds)
local function dots(col, t) for _, p in ipairs(t) do px(p[1], p[2], col) end end
local function seg(col, pts) for i = 1, #pts - 1 do
  local a, b = pts[i], pts[i + 1]
  local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
  for k = 0, n do px(floor(a[1] + (b[1] - a[1]) * k / n + .5), floor(a[2] + (b[2] - a[2]) * k / n + .5), col) end
end end
local MOSS, MOSSL, MOSSD = "#5a7a3a", "#7c9a4c", "#3c5a2c"
-- inn plaster: hairline cracks, damp stains below sills, eave shadow
seg("#9a7a66", {{110,92},{112,96},{111,100},{114,104},{113,108}})
seg("#9a7a66", {{140,100},{142,104},{141,108}})
seg("#9a7a66", {{52,118},{54,121},{53,124}})
for _, wx in ipairs({ 30, 38, 46, 120, 130 }) do seg("#b8967c", {{wx, 119},{wx, 123}}) end
for x = 24, 148 do if hash(x, 5, 200) < 0.7 then px(x, 88, Rplaster.s) end end
-- stone courses: chips, cracks, mossy foot on the shady left, mortar glints
for _, p in ipairs({ {28,131},{70,133},{94,150},{146,142},{93,134},{58,158},{26,148},{144,156},{92,162} }) do
  px(p[1], p[2], Rstone.h) px(p[1] + 1, p[2], Rstone.h) px(p[1], p[2] + 1, Rstone.d) px(p[1] + 1, p[2] + 1, Rstone.d)
end
seg(Rstone.d, {{58,141},{60,144},{59,147}}) seg(Rstone.d, {{92,152},{94,155},{93,158}})
for x = 22, 76 do for y = 158, 166 do
  if hash(x, y, 201) < (0.55 - (x - 22) / 110) * (y - 157) / 9 then px(x, y, hash(x, y, 202) < 0.3 and MOSSL or (hash(x, y, 203) < 0.5 and MOSS or MOSSD)) end
end end
for x = 134, 150 do for y = 160, 166 do if hash(x, y, 204) < 0.22 then px(x, y, MOSS) end end end
-- roof: moss on the shady lower-left, a few newer shingles, ridge cap, soot on the chimney
for x = 14, 74 do for y = 60, 86 do
  if roof:has(x, y) and hash(x, y, 205) < 0.28 * (y - 58) / 28 * (1 - (x - 14) / 80) then px(x, y, hash(x, y, 206) < 0.3 and MOSSL or MOSS) end
end end
for _, r in ipairs({ {118,66,124,70},{116,50,121,53},{82,70,88,73},{52,52,57,55} }) do
  for y = r[2], r[4] do for x = r[1], r[3] do px(x, y, (y == r[2]) and "#d47a5c" or "#b45846") end end
  for x = r[1], r[3] do px(x, r[4], "#5a2230") end
end
for x = 40, 132 do px(x, 38, "#d68a68") px(x, 39, "#7a3a3a") end
for x = 45, 57 do if hash(x, 3, 207) < 0.6 then px(x, 21, "#241418") px(x, 22, "#3a2428") end end
-- timber grain, knots and pegs
for _, xx in ipairs({ 22, 56, 104, 146 }) do
  for y = 92, 124, 7 do px(xx + 1, y, "#6e432c") px(xx + 3, y + 3, "#24140f") end
  dots("#14090a", {{xx + 2, 102},{xx + 2, 103}}) dots("#6e432c", {{xx + 1, 101},{xx + 3, 104}})
end
for x = 24, 148, 9 do px(x, 85, "#6e432c") px(x + 3, 86, "#24140f") px(x + 4, 126, "#6e432c") end
-- barrels: rust bloom on hoops, stave glints, drips
for _, b in ipairs({ {136,151,150,168},{152,154,164,169} }) do
  for _, hy in ipairs({ b[2] + 3, b[4] - 3 }) do
    for x = b[1] + 1, b[3] - 1 do if hash(x, hy, 208) < 0.4 then px(x, hy, "#a8542a") end end
  end
  px(b[1] + 2, b[2] + 6, Rbarrel.h) px(b[1] + 2, b[2] + 7, Rbarrel.h) px(b[3] - 3, b[4] - 1, Rbarrel.d)
end
-- crate: nail heads and split
dots(Riron.h, {{6,154},{18,154},{6,166},{18,166}}) seg(Rhoney.s, {{9,158},{11,162}})
-- table: knots, mug rings, plank seams
dots("#6e432c", {{82,198},{104,200},{132,197}}) dots("#4a2a14", {{83,198},{105,200},{133,197}})
for x = 90, 98 do px(x, 199, "#8a5a2a") end
seg("#8a5a2a", {{110,201},{116,201}})
-- stable: loose straw at the eave, hay wisps, door grain
for x = 176, 226, 3 do px(x, 102, Rthatch.h) px(x + 1, 103, Rthatch.b) px(x, 104, Rthatch.s) end
dots(Rthatch.h, {{196,124},{198,125},{203,124},{206,125}})
seg("#6e3028", {{186,112},{186,120}}) seg("#6e3028", {{214,112},{214,122}})
-- saddle: cloth folds and a stitched edge
seg(Rred.d, {{169,115},{171,119}}) seg(Rred.h, {{172,115},{173,118}})
dots("#e8c890", {{168,121},{170,121},{172,121}})
-- huts: nail rows, moss on the blue hut wall foot, shingle glints, step chips
for y = 104, 128, 6 do px(266, y, Rhut1.d) px(320, y, Rhut1.d) end
for x = 264, 292 do for y = 126, 132 do if hash(x, y, 209) < 0.26 * (y - 125) / 7 then px(x, y, MOSS) end end end
for x = 340, 392, 2 do px(x, 124, Rhut2.d) end
seg(Rhut2.d, {{353,116},{355,120},{354,124}}) dots(Rhut2.h, {{372,126},{385,128},{346,100}})
for x = 332, 360 do for y = 80, 98 do if hash(x, y, 210) < 0.1 and abs(y - (68 + (x < 368 and (x - 332) * 0.9 or 0))) > 0 then if c:get(x, y) == Rplum.b then px(x, y, Rplum.h) end end end end
dots(Rstone.h, {{296,132},{305,133},{310,132}})
-- well: wet moss at the foot, cracked stones, rust and verdigris on the bucket, rope coil
for x = 284, 316 do for y = 166, 174 do if hash(x, y, 211) < 0.3 * (y - 165) / 9 then px(x, y, MOSS) end end end
seg(Rwellst.d, {{292,160},{294,163},{293,166}}) seg(Rwellst.d, {{306,158},{307,162}})
dots("#a8542a", {{296,150},{302,152},{303,150}}) dots("#5eaaa2", {{297,148},{301,148}})
for y = 143, 147 do px(300, y, "#a89878") end dots("#a89878", {{297,147},{298,148},{297,149}})
-- board: nail heads, curled paper corners, pinned twine
dots(Riron.h, {{337,184},{379,184},{337,204},{379,204},{340,186},{352,186},{355,188},{365,188}})
dots(Rcream.d, {{350,198},{349,199}}) dots("#f0c0c8", {{364,200},{363,201}})
seg("#d8c8a8", {{353,186},{358,184},{366,186}})
for x = 334, 382 do if hash(x, 3, 212) < 0.2 then px(x, 192, Rteal.s) end end
-- fire pit: soot streaks, chipped stones; log seat bark ridges
for x = 24, 50, 2 do px(x, 214, "#24141a") px(x, 215, "#3a2224") end
dots(Rstone.h, {{26,220},{40,222},{48,216}}) seg(Rstone.d, {{34,218},{35,222}})
for x = 10, 30, 3 do px(x, 228, Rbark.h) px(x + 1, 230, Rbark.d) end
dots("#d8c8a8", {{8,229},{8,230},{9,229}})
-- trail trees: bark ridges, moss on the north (left) trunk face, branch stubs
seg(Rbark.h, {{418,136},{419,160},{420,190}}) seg(Rbark.d, {{423,150},{423,180},{424,205}})
for y = 150, 208 do if hash(417, y, 213) < 0.35 then px(417 + floor((y - 150) / 25), y, MOSS) end end
seg(Rbark.h, {{451,140},{452,170},{452,200}}) seg(Rbark.d, {{455,136},{456,176},{456,200}})
dots(MOSSL, {{451,160},{451,166},{452,188},{450,176}})
-- signpost: grain and nail, pole cracks
dots(Riron.h, {{430,168},{430,172}}) seg(Rbark.d, {{440,180},{440,200}}) seg(Rbark.h, {{439,178},{439,196}})
-- stamp post hanger rope twist
for y = 209, 213 do if y % 2 == 0 then px(384, y, "#a89878") end end
-- porch lantern rust and glass sheen
dots("#a8542a", {{134,138},{140,147},{138,137}}) px(135, 140, GLOW[1])

-- v2.5.40 polish pass 3: lived-in story props (what happens at this stop)
local Rlog = R("#3c2618", "#8a5a2a", "#c89a5a", "#e0b878")
-- 1. firewood stack against the inn foot (left), logs end-on, with a split log on top
shadow(rect(22, 168, 50, 171))
paint(rect(22, 158, 48, 168), Rbark, nil, { noshade = true, nohi = true })
for row = 0, 2 do for i = 0, 4 do
  local cx, cy = 25 + i * 5 + (row % 2) * 2, 160 + row * 3 + (row == 0 and 0 or 1)
  if cx < 47 then
    paint(c:ellipse(cx, cy + 1, 2, 2), Rlog, nil, { noshade = true, nohi = true })
    px(cx, cy + 1, "#a87a3e") px(cx - 1, cy, Rlog.h)
  end
end end
paint(rect(24, 155, 44, 157), Rbark, planksH(2, 220, 155), { noshade = true })
-- 2. broom leaning by the door, bristles at the foot
paint(rect(94, 142, 95, 164), Rhoney, nil, { noshade = true, nohi = true })
paint(poly{{92,162},{97,162},{98,168},{91,168}}, Rthatch, thatch(221), { noshade = true })
px(93, 164, Rthatch.d) px(96, 166, Rthatch.d)
-- 3. green travelling cloak on a peg on the inn side wall (story: guests stay the night)
paint(rect(156, 124, 162, 125), Riron, nil, { noshade = true, nohi = true })
paint(poly{{155,126},{163,126},{164,142},{160,145},{157,142},{154,143}}, R("#16301e", "#2a5a3a", "#3f7a4a", "#5a9a5a"), function(x, y)
  if x == 159 and y > 128 then return "s" end
  if y == 141 and x % 2 == 0 then return "d" end
end, { sh = 2 })
-- 4. mounting block beside the stable door
shadow(poly{{212,138},{228,138},{232,141},{216,141}})
paint(rect(218, 130, 230, 138), Rstone, bricks(6, 4, 222, 218, 130), { sh = 2 })
paint(rect(214, 134, 222, 138), Rstone, nil, { sh = 2 })
px(224, 131, Rstone.h) px(225, 131, Rstone.h)
-- 5. wheelbarrow of hay in front of the stable
shadow(poly{{178,134},{196,134},{200,137},{182,137}})
paint(poly{{178,126},{194,126},{191,133},{181,133}}, Rhoney, planksH(3, 223, 126), { sh = 2 })
for x = 180, 192, 2 do px(x, 124 + (x % 4) // 2, Rthatch.h) px(x + 1, 125, Rthatch.b) end
paint(c:ellipse(185, 134, 2, 2), Riron, nil, { noshade = true })
paint(rect(194, 127, 199, 128), Rhoney, nil, { noshade = true, nohi = true })
-- 6. herb bundles hung to dry under the eave
seg("#d8c8a8", {{141,90},{141,92}}) seg("#d8c8a8", {{145,90},{145,92}})
paint(poly{{139,93},{143,93},{142,99},{140,99}}, R("#2a4a22", "#3f6a34", "#6a9a48", "#8ab85a"), nil, { noshade = true })
paint(poly{{143,93},{147,93},{146,98},{144,98}}, R("#6a2a2a", "#a84a3a", "#d8683a", "#f09a4a"), nil, { noshade = true })
-- 7. pewter mugs on the front bench and a mug left on the log seat
for _, mx in ipairs({ 96, 130 }) do
  paint(rect(mx, 209, mx + 3, 214), Rbrass, nil, { noshade = true }) px(mx, 209, Rcream.h) px(mx + 4, 210, Rbrass.d) px(mx + 4, 212, Rbrass.d)
end
paint(rect(22, 221, 25, 226), Rbrass, nil, { noshade = true }) px(22, 221, Rcream.h)
-- 8. water barrel beside the blue hut, lid ajar, rope and a ladle
shadow(rect(326, 131, 336, 134))
paint(c:rrect(324, 119, 334, 133, 3), Rbarrel, planksV(3, 224, 324))
for _, hy in ipairs({ 122, 130 }) do for x = 324, 334 do px(x, hy, Riron.b) end end
px(324, 119, Rbarrel.h)
for x = 325, 333 do px(x, 120, Rbarrel.d) end for x = 326, 332 do px(x, 121, "#5a7aa0") end
-- 9. stacked sacks of grain by the huts' foot (right of hut 2 door)
shadow(rect(396, 131, 406, 134))
paint(c:ellipse(400, 128, 5, 4), R("#6a5a3a", "#b8a478", "#d8c496", "#efe0b8"), function(x, y) if y == 125 then return "d" end end, { sh = 2 })
paint(c:ellipse(398, 122, 4, 3), R("#6a5a3a", "#b8a478", "#d8c496", "#efe0b8"), nil, { sh = 2 })
px(400, 125, "#a88e66") px(399, 119, "#a88e66")
-- 10. a bootscraper and doormat before the inn door
paint(rect(104, 168, 126, 169), R("#5a3a22", "#a87444", "#c08a52", "#d8a468"), function(x, y) if x % 3 == 0 then return "s" end end, { noshade = true })
paint(rect(92, 168, 98, 170), Riron, nil, { noshade = true })

-- v2.5.40 polish pass 4b: key light top-left, warm glows, rim light, flora variety, foreground flora
local sqrt = math.sqrt
for y = 88, 118 do for x = 190, 410 do
  local cur = c:get(x, y)
  if (cur == Rpine.b or cur == Rpine.s or cur == Rpine.h) and hash(x, y, 301) < (y - 88) / 45 then px(x, y, (cur == Rpine.h) and "#4a6a6e" or "#3a5a62") end
end end
local GC = { ["#56704c"]=true, ["#5f7d46"]=true, ["#43603a"]=true, ["#4a6446"]=true, ["#4e6a40"]=true, ["#547140"]=true,
             ["#8c7454"]=true, ["#7a6046"]=true, ["#3e5634"]=true, ["#6c8a4c"]=true, ["#5a6a3a"]=true, ["#6e7c48"]=true, ["#c29a6a"]=true }
local function glow(m, cA, cB, solid)
  m:each(function(x, y)
    if y > HOR and GC[c:get(x, y)] and free(x, y, 16) then
      if (x + y) % 2 == 0 then px(x, y, cA) elseif solid then px(x, y, cB) end
    end
  end)
end
-- window and door light spilling onto the ground in front of the inn
glow(poly{{30,169},{56,169},{66,177},{36,177}}, "#8a8e4a", "#6e7c48")
glow(poly{{64,169},{90,169},{100,178},{70,178}}, "#8a8e4a", "#6e7c48")
glow(poly{{104,171},{128,171},{146,187},{96,187}}, "#b09c58", "#8a8e4a", true)
-- fire glow on grass
glow(c:ellipse(37, 219, 26, 10), "#9a8444", "#7a7c44", true)
-- warm rim light on the fire-facing edges of the pit and log seat
for x = 22, 30 do px(x, 210, "#e8a060") end for y = 211, 224 do px(22, y, "#c8804e") end
for x = 8, 18 do px(x, 226, "#d8904e") end
-- string lights warm the table top beneath them
for x = 64, 150, 3 do px(x, 195, "#e8b868") end
-- lantern halos in the evening sky (ring dither)
local function halo(cx, cy, r)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    local cur = c:get(x, y)
    if d < r and d > 7 and y > 13 and x > 15 and x < W - 16 and (cur == SKY[1] or cur == SKY[2] or cur == SKY[3] or cur == SKY[4]) then
      if d < r - 5 then px(x, y, "#5a4a7e") elseif (x + y) % 2 == 0 then px(x, y, "#4a4078") end
    end
  end end
end
halo(34, 36, 20) halo(446, 36, 20)
-- rim light along the lit upper-left roof edge, and warm rim on the inn's door-side edges
for x = 14, 40 do px(x, 87 - (x - 12) * 48 // 28 + 0, "#e89a84") end
for y = 134, 164 do px(133, y, "#f0b060") end
for y = 134, 150 do px(104, y, "#f0b060") end
-- berry bush between the inn and the stable
shadow(poly{{172,162},{192,162},{196,166},{176,166}})
paint(c:rrect(172, 148, 190, 163, 6), Rbush, leafy(310))
for _, b in ipairs({ {176,153},{181,157},{185,151},{178,159},{187,158} }) do px(b[1], b[2], "#d8384a") px(b[1], b[2] - 1, "#f08090") end
-- hollyhock stalks beside the well (tall spires, new plant kind)
for _, hx in ipairs({ 272, 276, 279 }) do
  local top = 150 + (hx % 5) * 3
  for y = top, 172 do px(hx, y, "#3c5a2c") end
  for k = 0, 3 do
    local by = top + k * 5
    local col = ({ "#e05a8a", "#f4d0b0", "#b84a8a", "#f08aa0" })[1 + (hx + k) % 4]
    px(hx - 1, by, col) px(hx + 1, by, col) px(hx, by - 1, col) px(hx, by, "#f0d060")
  end
  px(hx - 2, 170, "#5a7a3a") px(hx + 2, 169, "#5a7a3a") px(hx - 1, 171, "#7c9a4c") px(hx + 1, 171, "#7c9a4c")
end
-- foreground frame flora: dark ferns and foxglove at the lower edges (kept off every stand point)
local function fern(bx, by, n, len, seed)
  for i = 1, n do
    local a = -3.14159 * (0.12 + 0.76 * (i - 1) / (n - 1))
    local L = len * (0.7 + 0.3 * hash(i, seed, 320))
    for t = 0, L do
      local x = floor(bx + math.cos(a) * t + .5)
      local y = floor(by + math.sin(a) * t * 0.8 + t * t / (L * 3) + .5)
      px(x, y, (t % 5 == 0) and "#4a7058" or "#264438") px(x, y + 1, "#16282a")
      if t > 3 and t % 3 == 0 then px(x, y - 1, "#29443c") px(x + (a < -1.57 and -1 or 1), y, "#1f3632") end
    end
  end
end
fern(26, 269, 7, 20, 1) fern(52, 269, 5, 14, 2) fern(310, 269, 6, 16, 3) fern(21, 140, 0, 0, 4)
for _, fx in ipairs({ 40, 46, 316 }) do
  for y = 252 + (fx % 7), 268 do px(fx, y, "#2a5a3a") px(fx + 1, y, "#1f3632") end
  for k = 0, 4 do
    local y = 254 + (fx % 7) + k * 3
    px(fx - 1, y, "#9a4a9a") px(fx + 2, y + 1, "#b46ab0") px(fx - 2, y + 1, "#7a3a80")
  end
end

---------------------------------------------------------------- the gate frame (inn timber + lanterns)
local fr = HP.mask():add(rect(0, 0, W - 1, 13)):add(rect(0, 0, 15, Hh - 1)):add(rect(W - 16, 0, W - 1, Hh - 1))
paint(rect(0, 0, 15, Hh - 1), Rframe, planksV(5, 101, 0), { sh = 3 })
paint(rect(W - 16, 0, W - 1, Hh - 1), Rframe, planksV(5, 102, W - 16), { sh = 3 })
paint(rect(0, 0, W - 1, 13), Rframe, planksH(5, 103, 0), { sh = 3 })
-- corner braces
paint(poly{{16,14},{40,14},{16,38}}, Rframe, nil, { sh = 2 })
paint(poly{{463,14},{439,14},{463,38}}, Rframe, nil, { sh = 2 })
-- iron pegs
for _, p in ipairs({ {6,20}, {6,140}, {6,250}, {471,20}, {471,140}, {471,250}, {120,5}, {240,5}, {360,5} }) do
  paint(rect(p[1], p[2], p[1] + 3, p[2] + 3), Riron, nil, { noshade = true })
end
-- ivy along the beam
for i = 0, 44 do
  local x = 20 + i * 10
  local y = 12 + floor(2 * sin(i * 0.9))
  if abs(x - VPX) > 14 then
    paint(poly{{x, y}, {x + 3, y + 3}, {x, y + 6}, {x - 3, y + 3}}, Rbush, nil, { noshade = true })
  end
end
-- hanging lanterns
local function lantern(cx, top, len)
  for y = 14, top - 1 do px(cx, y, (y % 2 == 0) and Riron.b or Riron.h) end
  paint(rect(cx - 6, top, cx + 6, top + 3), Riron, nil, { noshade = true })
  paint(rect(cx - 5, top + 4, cx + 5, top + len), Riron, function(x, y)
    if x > cx - 4 and x < cx + 4 and y > top + 4 and y < top + len - 1 then
      return (x < cx and y < top + 8) and GLOW[1] or ((x > cx + 1 or y > top + len - 3) and GLOW[3] or GLOW[2])
    end
  end, { noshade = true })
  for x = cx - 4, cx + 4 do if x ~= cx - 4 and x ~= cx + 4 then end end
  for y = top + 5, top + len - 2 do px(cx, y, Riron.s) end
  paint(rect(cx - 3, top + len + 1, cx + 3, top + len + 2), Riron, nil, { noshade = true })
end
lantern(34, 26, 16)
lantern(446, 26, 16)
-- charm: a carved acorn-diamond with a little brass bell, hung at the centre
for y = 14, 21 do px(240, y, "#d8c8a8") end
paint(poly{{240,22},{246,28},{240,34},{234,28}}, Rhoney)
px(239, 26, Rhoney.h) px(240, 25, Rhoney.h)
paint(poly{{237,36},{243,36},{245,42},{235,42}}, Rbrass)
px(240, 43, Rbrass.d)

---------------------------------------------------------------- save
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":112,"view":"gate","spots":[]] ..
  [[{"k":"do","name":"Lantern Inn","x":91,"y":95,"box":[10,14,172,176]},]] ..
  [[{"k":"people","name":"Long Table","x":84,"y":205,"box":[4,180,164,234]},]] ..
  [[{"k":"stop","name":"Stamp Board","x":358,"y":195,"box":[326,164,392,227]},]] ..
  [[{"k":"homes","name":"Roadside Huts","x":331,"y":101,"box":[254,46,406,138]},]] ..
  [[{"k":"wild","name":"Wild Trail","x":435,"y":156,"box":[408,94,463,218]}],]] ..
  [["stand":[{"x":240,"y":250},{"x":198,"y":210},{"x":282,"y":208},{"x":240,"y":162},{"x":100,"y":256},{"x":345,"y":254}],]] ..
  [["compass_clear":[380,230,480,270]}]]
local f = io.open(OUT .. NAME .. ".layout.json", "w") f:write(layout .. "\n") f:close()
print("ok " .. NAME)
