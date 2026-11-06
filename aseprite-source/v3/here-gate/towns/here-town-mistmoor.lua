-- Mistmoor (moor village, drizzly dusk) - gate-view hero-scale town, 480x270 native.
local ROOT = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(ROOT .. "/v3/lib/hp.lua")
local OUT = app.params.out or (ROOT .. "/v3/here-gate/towns/")
local NAME = "here-town-mistmoor"
local W, Hh = 480, 270
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = NAME }
local floor, abs, sin, max, min = math.floor, math.abs, math.sin, math.max, math.min
local VPX, VPY = 240, 112

local function H(x, y, s) local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return v - floor(v) end
local function put(x, y, col) c:put(x, y, col) end
local function rect(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do put(x, y, col) end end end
local function hl(x0, x1, y, col) for x = x0, x1 do put(x, y, col) end end
local function vl(x, y0, y1, col) for y = y0, y1 do put(x, y, col) end end
local function poly(p) return c:poly(p) end
local function hex2(h) h = h:gsub("#", "") return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16) end
local function mix(a, b, t)
  local r1, g1, b1 = hex2(a) local r2, g2, b2 = hex2(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function tint(x, y, col, t)
  if x < 0 or y < 0 or x >= W or y >= Hh then return end
  local cur = c:get(x, y) if type(cur) == "string" then put(x, y, mix(cur, col, t)) end
end
local SHADE = "#3a3352"
local WARM = "#f6c060"
local function shadowBand(x0, x1, y, h, amt) -- cast shadow below a base, leaning lower-right
  for i = 1, h do for x = x0 + i, x1 + i * 2 do tint(x, y + i, SHADE, amt * (1 - (i - 1) / (h + 1))) end end
end
local function glow(cx, cy, r, amt) -- stepped diamond glow (no circles)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = abs(x - cx) + abs(y - cy) * 1.3
    if d <= r then local s = d < r * .4 and amt or (d < r * .7 and amt * .6 or amt * .3) tint(x, y, WARM, s) end
  end end
end
local function R(d, s, b, l, h) return { d = d, s = s, b = b, l = l, h = h } end
local function toward(x, y, t) return floor(x + (VPX - x) * t + .5), floor(y + (VPY - y) * t + .5) end

---------------------------------------------------------------- textures
local function stoneTex(m, r, seed, ch, bw)
  ch, bw = ch or 5, bw or 8
  local bb = { m:bbox() } local ox, oy = bb[1] or 0, bb[2] or 0
  m:each(function(x, y)
    local row = floor((y - oy) / ch) local ry = (y - oy) % ch
    local off = floor(H(row, 3, seed) * bw)
    local bx = floor((x - ox + off) / bw) local rx = (x - ox + off) % bw
    local wv = H(bx, row, seed)
    local w2 = bw - 1 - (wv > .6 and 1 or 0)
    if ry == ch - 1 or rx >= w2 then put(x, y, r.s)
    else
      local col = wv < .28 and r.l or (wv < .86 and r.b or mix(r.b, r.s, .5))
      if ry == 0 and rx <= 1 then col = r.l end
      if ry == ch - 2 and rx == w2 - 1 then col = mix(col, r.s, .5) end
      put(x, y, col)
    end
  end)
end
local function slateTex(m, r, seed)
  local bb = { m:bbox() } local oy = bb[2] or 0
  m:each(function(x, y)
    local row = floor((y - oy) / 4) local ry = (y - oy) % 4
    local off = (row % 2) * 3
    local bx = floor((x + off) / 6) local rx = (x + off) % 6
    local v = H(bx, row, seed)
    local col
    if ry == 3 then col = r.d elseif rx == 0 then col = r.s
    else col = v < .25 and r.l or (v < .85 and r.b or r.s)
      if ry == 0 and rx == 1 and v < .5 then col = r.h end
    end
    if H(x, y, seed + 9) < .025 and ry ~= 3 then col = "#6f8a52" end -- moss
    put(x, y, col)
  end)
end
local function thatchTex(m, r, seed)
  local bb = { m:bbox() } local oy = bb[2] or 0
  m:each(function(x, y)
    local v = H(x, floor((y - oy) / 3), seed)
    local col = v < .2 and r.l or (v < .7 and r.b or r.s)
    if (y - oy) % 9 == 8 then col = r.s end
    if (y - oy) % 9 == 0 and v < .5 then col = r.l end
    put(x, y, col)
  end)
end
local function renderTex(m, r, seed) -- limewash with speckle
  m:each(function(x, y)
    local v = H(x, y, seed)
    put(x, y, v < .08 and r.s or (v < .2 and r.l or r.b))
  end)
end
local function plankTex(m, r, seed, vertical)
  m:each(function(x, y)
    local a, b = x, y if not vertical then a, b = y, x end
    local k = a % 5
    local v = H(floor(a / 5), floor(b / 7), seed)
    local col = k == 4 and r.d or (k == 0 and r.l or (v < .5 and r.b or r.s))
    if k ~= 4 and H(a, b, seed + 3) < .05 then col = r.s end
    put(x, y, col)
  end)
end
local function shadeRight(m, x1, wpx, amt) m:each(function(x, y) if x > x1 - wpx then tint(x, y, SHADE, amt) end end) end
local function shadeBottom(m, y1, hpx, amt) m:each(function(x, y) if y > y1 - hpx then tint(x, y, SHADE, amt) end end) end

local function window(x0, y0, w, h, frame, opt)
  opt = opt or {}
  rect(x0 - 1, y0 - 1, x0 + w, y0 + h, frame)
  for y = y0, y0 + h - 1 do for x = x0, x0 + w - 1 do
    local t = (y - y0) / max(1, h - 1)
    put(x, y, t < .3 and "#fbd88a" or (t < .75 and "#f0b456" or "#d98a44"))
  end end
  local mx = x0 + floor(w / 2)
  vl(mx, y0, y0 + h - 1, frame)
  if h > 8 then hl(x0, x0 + w - 1, y0 + floor(h / 2), frame) end
  if opt.panes then for yy = y0 + 3, y0 + h - 2, 4 do hl(x0, x0 + w - 1, yy, frame) end end
  put(x0 + 1, y0 + 1, "#fff0c2") put(x0 + 2, y0 + 1, "#fff0c2") put(x0 + 1, y0 + 2, "#fff0c2")
  hl(x0 - 2, x0 + w + 1, y0 + h + 1, opt.sill or "#b9b3bd")
  hl(x0 - 2, x0 + w + 1, y0 + h + 2, "#6d6678")
  for i = 1, 4 do for x = x0 - 1, x0 + w do tint(x, y0 + h + 2 + i, WARM, .22 - i * .045) end end
end
local function door(x0, y0, w, h, r, opt)
  rect(x0 - 1, y0 - 1, x0 + w, y0 + h - 1, r.d)
  for y = y0, y0 + h - 1 do for x = x0, x0 + w - 1 do
    local k = (x - x0) % 4
    put(x, y, k == 3 and r.s or (x == x0 and r.l or r.b))
  end end
  rect(x0 + 1, y0 + 2, x0 + w - 2, y0 + 3, "#f4c46a")
  put(x0 + w - 3, y0 + floor(h * .55), "#f2cf6a")
  hl(x0 - 2, x0 + w + 1, y0 + h, "#9c96a2")
end

---------------------------------------------------------------- SKY (drizzly dusk)
c:stripes(0, 112, { "#2f3452", "#3b4064", "#4d5076", "#655f86", "#836f92", "#a57f94", "#c39190", "#d9a68e" },
  { 3, 3, 3, 3, 2.5, 2, 1.5, 1.2 })
-- heavy rain-cloud decks
local function cloudDeck(x0, x1, yb, hgt, seed, body, top, under)
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local bump = floor(hgt * (0.55 + 0.45 * sin(t * 3.14159)) + 4 * sin(x / 14 + seed) + 2 * sin(x / 7 + seed * 2))
    local ytop = yb - bump
    for y = ytop, yb do
      local col = body
      if y <= ytop + 1 then col = top elseif y >= yb - 1 then col = under
      elseif H(x, y, seed) < .06 then col = top end
      put(x, y, col)
    end
  end
end
cloudDeck(10, 170, 34, 16, 1, "#4b4a6a", "#6a6788", "#3d3b58")
cloudDeck(150, 330, 28, 12, 2, "#555273", "#77729a", "#45425f")
cloudDeck(300, 475, 38, 18, 3, "#4b4a6a", "#6d6a8c", "#3d3b58")
cloudDeck(60, 190, 58, 9, 4, "#7a6788", "#9c86a2", "#665673")
cloudDeck(280, 420, 62, 10, 5, "#7a6788", "#a08aa6", "#665673")
c:cloud(196, 70, 44, "#b48c9a", "#93768c")
c:cloud(118, 80, 30, "#c0959a", "#a07e8e")
c:cloud(330, 84, 34, "#c49a9a", "#a68090")
-- low sun glow line under the clouds
for x = 0, W - 1 do tint(x, 95, "#f0c08a", .25) tint(x, 96, "#f0c08a", .25) end

---------------------------------------------------------------- FAR MOOR
c:terrain(function(x) return 92 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end, "#6b6d8c", 112)
c:terrain(function(x) return 100 + 5 * sin(x / 29 + 2) + 2 * sin(x / 9) end, "#5f7064", 112)
-- the Standing Stones hill (centre, at the vanishing point)
local function hillY(x) local d = (x - 240) / 70 return 110 - 34 * math.exp(-d * d * 1.6) - 3 * sin(x / 11) end
local hill = c:terrain(hillY, nil, 112, 140, 340)
hill:each(function(x, y)
  local top = hillY(x)
  local col = "#6a8552"
  local v = H(x, y, 21)
  if y - top < 2 then col = "#8fa86a" elseif v < .12 then col = "#7a5f7a" elseif v < .3 then col = "#5d7849" end
  if x > 250 and y - top > 3 then col = mix(col, SHADE, .18) end
  put(x, y, col)
end)
-- distant dry-stone walls on the moor
for _, w in ipairs({ { 60, 150, 104 }, { 330, 450, 106 } }) do
  for x = w[1], w[2] do local y = w[3] + floor(2 * sin(x / 20)) put(x, y, "#8a879a") put(x, y + 1, "#5a586e") end
end
-- mist band (soft rain haze)
for y = 98, 116 do local a = y < 104 and .14 or (y < 110 and .24 or .16) for x = 0, W - 1 do tint(x, y, "#b2aac4", a) end end

---------------------------------------------------------------- STANDING STONES (s1)
local stones = {}
local SR = R("#3e4256", "#62677e", "#858aa0", "#a6abbc", "#c8ccd8")
for i = 0, 8 do
  local a = i / 9 * 6.2832 + .3
  local sx, sy = 240 + floor(36 * math.cos(a)), 78 + floor(7 * sin(a))
  local front = sin(a)
  stones[#stones + 1] = { x = sx, y = sy, k = front, i = i }
end
table.sort(stones, function(a, b) return a.y < b.y end)
local function stone(cx, base, w, h, seed, opt)
  local m = poly{ { cx - floor(w / 2), base }, { cx - floor(w / 2), base - h + 3 }, { cx - floor(w / 2) + 2, base - h },
    { cx + floor(w / 2) - 1, base - h + 1 }, { cx + floor(w / 2), base - h + 4 }, { cx + floor(w / 2), base } }
  m:each(function(x, y)
    local rel = (x - (cx - w / 2)) / w
    local col = rel < .3 and SR.l or (rel < .72 and SR.b or SR.s)
    if y < base - h + 3 and rel < .6 then col = SR.h end
    if H(x, y, seed) < .1 then col = "#9fb27a" end -- lichen
    if H(x, y, seed + 5) < .06 then col = SR.s end
    put(x, y, col)
  end)
  c:edgeIn(m, SR.d)
  for x = cx - floor(w / 2) + 1, cx + floor(w / 2) + 3 do tint(x, base + 1, SHADE, .45) end
  return m
end
-- back trilithon
stone(226, 74, 8, 19, 31) stone(254, 74, 8, 19, 32)
local lint = c:rect(221, 52, 259, 56)
lint:each(function(x, y) put(x, y, y == 52 and SR.h or (y == 56 and SR.s or (H(x, y, 9) < .15 and SR.l or SR.b))) end)
c:edgeIn(lint, SR.d)
for _, s in ipairs(stones) do
  local sc = 0.75 + (s.y - 71) / 14 * .45
  stone(s.x, s.y + 6, floor(9 * sc), floor(20 * sc), s.i + 40)
end
-- wish ribbons tied on the tallest front stone (the "make a wish" sign)
do
  local fx, fy = 240, 90
  local rib = { "#d8506a", "#f2c14e", "#6fb6d8", "#9a6fc0", "#7ac06a" }
  for i, col in ipairs(rib) do
    local x = fx - 6 + i * 2
    for k = 0, 4 + (i % 3) do put(x + (k > 3 and 1 or 0), fy - 8 + k, col) end
  end
  hl(fx - 5, fx + 5, fy - 9, "#e8d8b0")
end
-- quirk: one stone wears a tiny umbrella
do
  local s = stones[#stones] -- front-most
  local ux, uy = s.x + 9, s.y - 18
  vl(ux, uy, uy + 8, "#4a3a38")
  local can = poly{ { ux - 6, uy + 1 }, { ux - 4, uy - 2 }, { ux, uy - 3 }, { ux + 4, uy - 2 }, { ux + 6, uy + 1 } }
  can:each(function(x, y) put(x, y, x < ux and "#e05a5a" or "#b83e4e") end)
  for x = ux - 6, ux + 6, 3 do put(x, uy + 1, "#7a2a3a") end
  put(ux - 3, uy - 1, "#ff9a8a")
end

---------------------------------------------------------------- GROUND
-- moor grass base
for y = 112, Hh - 1 do for x = 0, W - 1 do
  local v = H(x, y, 50)
  local near = (y - 112) / 158
  local col = mix("#5a7350", "#6a9450", near)
  if v < .1 then col = mix(col, "#86b062", .6) elseif v < .2 then col = mix(col, "#3f5a3c", .4) end
  put(x, y, col)
end end
-- cobbled square in perspective
local plaza = poly{ { 204, 113 }, { 276, 113 }, { 336, 124 }, { 352, 150 }, { 432, 269 }, { 48, 269 }, { 128, 150 }, { 144, 124 } }
plaza:each(function(x, y)
  local dy = y - 104
  local d = 2400 / dy
  local dd = 2400 / (dy * dy)
  local row = floor(d)
  local u = (x - VPX) / dy * 13 + (row % 2) * .5
  local col = floor(u)
  local fr, fu = d - row, u - col
  local thr = min(.45, dd * 1.1)
  local thu = min(.45, 13 / dy * 1.1)
  local v = H(col, row, 60)
  local cc
  if fr < thr or fu < thu then cc = "#575468"
  else
    cc = v < .3 and "#9f9aa8" or (v < .8 and "#86828f" or "#77727f")
    if fr > 1 - thr * 2 then cc = mix(cc, "#575468", .35) end
    if fu > 1 - thu * 2 then cc = mix(cc, "#575468", .25) end
    if fr < thr * 2.5 and fu < thu * 2.5 + .2 and v < .5 and y > 160 then cc = "#c3c0cc" end -- wet sheen
  end
  if y < 150 then cc = mix(cc, "#8a8698", y < 132 and .7 or .45) end
  put(x, y, cc)
end)
c:edgeIn(plaza, "#4e5a48")
-- warm dusk reflection on the wet stone (lit-window streaks)
for y = 200, 269 do for x = 48, 432 do
  if plaza:has(x, y) and H(x, y, 77) < .04 then tint(x, y, WARM, .35) end
end end

-- puddles (flat pills, reflecting the sky)
local function puddle(cx, cy, w)
  local m = c:rrect(cx - w, cy - 3, cx + w, cy + 3, 3)
  m:each(function(x, y)
    local col = y <= cy - 2 and "#8a7aa0" or (y <= cy and "#a8869c" or "#c9a092")
    put(x, y, col)
  end)
  hl(cx - w + 4, cx - w + 9, cy - 1, "#e4c2a8")
  put(cx + w - 6, cy + 1, "#f6dcb8")
  c:edgeIn(m, "#4d4a62")
end
puddle(105, 228, 13) puddle(195, 226, 12) puddle(285, 226, 12) puddle(178, 140, 8)

---------------------------------------------------------------- THE VILLAGE GREEN (green)
local lawn = poly{ { 178, 162 }, { 302, 162 }, { 328, 210 }, { 152, 210 } }
local kerb = lawn:grow(2)
kerb:each(function(x, y) put(x, y, y > 208 and "#6d6878" or "#aaa5b2") end)
lawn:each(function(x, y)
  local u = (x - VPX) / (y - 100)
  local stripe = floor(u * 5 + 10) % 2
  local col = stripe == 0 and "#74ac52" or "#66a04a"
  local v = H(x, y, 70)
  if v < .07 then col = "#8cc464" elseif v < .12 then col = "#56883e" end
  if y > 204 then col = mix(col, SHADE, .2) end
  put(x, y, col)
end)
c:rim(kerb, "#4a4658")
-- flower border along the front kerb
for x = 156, 324, 3 do
  local y = 207 - (H(x, 1, 2) < .5 and 1 or 0)
  local f = ({ "#e86a8a", "#f2d05a", "#ffffe0", "#b07ad8" })[floor(H(x, 2, 3) * 4) + 1]
  if f == "#ffffe0" then f = "#f4ecd0" end
  put(x, y, f) put(x, y + 1, "#3f6e38")
end
-- daisies
for i = 1, 40 do
  local x, y = 170 + floor(H(i, 1, 4) * 140), 166 + floor(H(i, 2, 4) * 38)
  if lawn:has(x, y) then put(x, y, "#f2eedc") end
end
-- bench (left of tree)
do
  local bx, by = 186, 194
  shadowBand(bx, bx + 22, by + 4, 2, .5)
  rect(bx, by, bx + 22, by + 1, "#8a5a3a") hl(bx, bx + 22, by, "#b07a4a")
  rect(bx, by - 6, bx + 22, by - 5, "#8a5a3a") hl(bx, bx + 22, by - 6, "#b07a4a")
  vl(bx + 2, by - 6, by + 4, "#3e2c2a") vl(bx + 20, by - 6, by + 4, "#3e2c2a")
  hl(bx - 1, bx + 23, by + 2, "#4e3428")
end
-- quirk: overflowing rain gauge on a stake
do
  local gx, gy = 290, 196
  vl(gx, gy - 6, gy + 6, "#6a4a32") vl(gx + 1, gy - 6, gy + 6, "#4a3226")
  rect(gx - 2, gy - 16, gx + 3, gy - 6, "#3d4f68")
  rect(gx - 1, gy - 15, gx + 2, gy - 7, "#a8d4ea")
  rect(gx - 1, gy - 11, gx + 2, gy - 7, "#5fa0cc")
  put(gx - 1, gy - 15, "#eef8ff") put(gx - 1, gy - 14, "#eef8ff")
  put(gx + 4, gy - 15, "#7fb8dc") put(gx + 4, gy - 13, "#7fb8dc") put(gx + 5, gy - 11, "#7fb8dc") put(gx - 3, gy - 14, "#7fb8dc")
  for i = 0, 3 do put(gx + 5 + i, gy + 6, "#7fb8dc") end
end
-- quirk / hero: the Umbrella Tree (a post where gnomes hang their umbrellas)
do
  local tx, base = 240, 200
  shadowBand(tx - 18, tx + 18, base, 3, .5)
  rect(tx - 2, 162, tx + 2, base, "#6a4a32")
  vl(tx - 2, 162, base, "#8e6a46") vl(tx + 2, 162, base, "#3e2c24")
  rect(tx - 5, base - 2, tx + 5, base, "#5a4636") hl(tx - 5, tx + 5, base - 2, "#8a7058")
  -- crossbars
  for _, b in ipairs({ { 168, 30 }, { 180, 24 } }) do
    rect(tx - b[2], b[1], tx + b[2], b[1] + 1, "#6a4a32") hl(tx - b[2], tx + b[2], b[1], "#8e6a46")
  end
  -- finial
  rect(tx - 1, 159, tx + 1, 161, "#d8a640")
  local function umb(x, y, w, a, b, closed)
    vl(x, y - 1, y + 2, "#3a2a28")
    if closed then
      local m = poly{ { x - 2, y + 2 }, { x + 2, y + 2 }, { x, y + 14 } }
      m:each(function(px, py) put(px, py, px <= x and a or b) end)
      vl(x, y + 14, y + 16, "#3a2a28") put(x + 1, y + 16, "#3a2a28")
      c:edgeIn(m, mix(b, "#20182a", .4))
    else
      local hy = y + 2
      local m = poly{ { x - w, hy + 7 }, { x - w + 2, hy + 3 }, { x - 3, hy }, { x + 3, hy }, { x + w - 2, hy + 3 }, { x + w, hy + 7 } }
      m:each(function(px, py)
        local seg = floor((px - (x - w)) / (w / 2))
        local col = seg % 2 == 0 and a or b
        if py == hy then col = mix(col, "#fff0d0", .4) end
        put(px, py, col)
      end)
      for px = x - w, x + w do if (px - x) % 4 == 2 then put(px, hy + 7, mix(b, "#20182a", .35)) end end
      vl(x, hy + 1, hy + 11, "#3a2a28") put(x + 1, hy + 11, "#3a2a28") put(x + 2, hy + 10, "#3a2a28")
      c:edgeIn(m, mix(b, "#20182a", .45))
      put(x - w + 3, hy + 3, "#fff2dc")
    end
  end
  umb(tx - 26, 168, 9, "#e05a5a", "#f4d6b8")
  umb(tx + 26, 168, 9, "#4a8ad0", "#f2d05a")
  umb(tx - 12, 169, 0, "#6ab06a", "#3e7a46", true)
  umb(tx + 12, 169, 0, "#b06ad0", "#7a3a9a", true)
  umb(tx - 20, 180, 8, "#f2a640", "#d8506a")
  umb(tx + 20, 180, 8, "#5ac0b0", "#2e7a80")
end

---------------------------------------------------------------- GATE FRAME (moor lychgate: dry stone + oak + slate)
local function buildingSide(x, yt, yb, t, r, seed)
  local ax, ay = toward(x, yt, t) local bx, by = toward(x, yb, t)
  local m = poly{ { x, yt }, { ax, ay }, { bx, by }, { x, yb } }
  stoneTex(m, r, seed, 4, 6)
  m:each(function(px, py) tint(px, py, SHADE, .32) end)
  return m
end

---------------------------------------------------------------- LIBRARY (far left)
do
  local r = R("#5a4a3a", "#8a7656", "#ac9670", "#c6b08a", "#e0cca4")
  local x0, x1, yt, yb = 28, 104, 82, 126
  shadowBand(x0, x1 + 6, yb, 4, .5)
  local side = buildingSide(x1 + 1, yt, yb, .09, r, 11)
  local wall = c:rect(x0, yt, x1, yb)
  stoneTex(wall, r, 12, 5, 9)
  shadeRight(wall, x1, 6, .15) shadeBottom(wall, yb, 3, .15)
  -- slate roof with gable dormer
  local roofR = R("#262c40", "#3d4660", "#4f5a78", "#68769a", "#8e9cc0")
  local roof = poly{ { 22, 82 }, { 110, 82 }, { 100, 60 }, { 32, 60 } }
  slateTex(roof, roofR, 13)
  shadeBottom(roof, 82, 2, .25)
  c:edgeIn(roof, roofR.d)
  local gable = poly{ { 48, 82 }, { 84, 82 }, { 84, 70 }, { 66, 54 }, { 48, 70 } }
  stoneTex(gable, r, 14, 5, 9)
  c:edgeIn(gable, r.d)
  local gr = poly{ { 45, 71 }, { 66, 51 }, { 87, 71 }, { 84, 72 }, { 66, 55 }, { 48, 72 } }
  gr:each(function(x, y) put(x, y, y < 60 and roofR.l or roofR.b) end)
  -- chimney
  local ch = c:rect(88, 50, 96, 64) stoneTex(ch, r, 15, 3, 4) c:edgeIn(ch, r.d)
  rect(87, 48, 97, 50, "#6a6070") rect(89, 45, 91, 47, "#b06a4a") rect(93, 45, 95, 47, "#b06a4a")
  -- chimney smoke (soft, flat)
  for i = 0, 3 do rect(92 + i * 3, 38 - i * 4, 96 + i * 4, 40 - i * 4, "#8e8aa6") end
  -- BIG BOOK SIGN in the gable
  local bk = poly{ { 52, 66 }, { 66, 63 }, { 80, 66 }, { 80, 79 }, { 66, 77 }, { 52, 79 } }
  bk:each(function(x, y) put(x, y, "#a8323e") end)
  local pg = poly{ { 54, 66 }, { 65, 64 }, { 65, 76 }, { 54, 77 } }
  pg:each(function(x, y) put(x, y, (y % 2 == 0 and x > 55) and "#c9b89a" or "#f2e6c8") end)
  local pg2 = poly{ { 67, 64 }, { 78, 66 }, { 78, 77 }, { 67, 76 } }
  pg2:each(function(x, y) put(x, y, (y % 2 == 0 and x < 77) and "#b8a68a" or "#e4d6b8") end)
  vl(66, 63, 77, "#6a1e2a") c:edgeIn(bk, "#5a1622")
  put(72, 77, "#e8c040") put(72, 78, "#e8c040") put(72, 79, "#c89a30") -- ribbon bookmark
  -- tall windows with small panes
  for _, wx in ipairs({ 34, 50, 76, 92 }) do window(wx, 88, 8, 14, "#3e3046", { panes = true }) end
  for _, wx in ipairs({ 34, 92 }) do window(wx, 108, 8, 10, "#3e3046") end
  -- book stacks in the lower windows
  for i, col in ipairs({ "#4a7ab0", "#b0503a", "#5a9a5a" }) do hl(35, 41, 118 - i, col) hl(93, 99, 118 - i, col) end
  -- arched blue door, steps
  door(60, 106, 12, 20, R("#1e2a46", "#2c3c64", "#3e5a90", "#5a7ab0", "#8aa8d8"))
  rect(58, 103, 73, 105, "#c6b08a") hl(58, 73, 103, "#e0cca4")
  hl(56, 76, 126, "#9c96a2")
  -- quirk: book-shaped weathervane... (a reading lamp lit above the door)
  rect(64, 98, 68, 101, "#3e3046") rect(65, 99, 67, 100, "#ffd98a") glow(66, 100, 8, .3)
  c:edgeIn(wall, r.d)
  c:edgeIn(side, mix(r.d, SHADE, .3))
end

---------------------------------------------------------------- NOTICE BOARD (mid left)
do
  local x0, x1, yt, yb = 136, 172, 98, 132
  shadowBand(x0, x1, 140, 2, .45)
  -- posts
  local wood = R("#3e2a22", "#6a4632", "#8a5e40", "#ad7c52", "#cfa070")
  for _, px in ipairs({ 140, 166 }) do local p = c:rect(px, 96, px + 3, 140) plankTex(p, wood, 7, true) c:edgeIn(p, wood.d) end
  -- frame + cork
  local fr = c:rect(x0, yt, x1, yb) fr:each(function(x, y) put(x, y, (x + y) % 5 == 0 and wood.s or wood.b) end)
  c:edgeIn(fr, wood.d)
  local cork = c:rect(x0 + 3, yt + 3, x1 - 3, yb - 3)
  cork:each(function(x, y) local v = H(x, y, 80) put(x, y, v < .2 and "#c89868" or (v < .8 and "#b8865a" or "#9a6c48")) end)
  hl(x0 + 1, x1 - 1, yt + 1, wood.l)
  -- slate cap roof
  local cap = poly{ { 131, 98 }, { 177, 98 }, { 170, 86 }, { 138, 86 } }
  slateTex(cap, R("#262c40", "#3d4660", "#4f5a78", "#68769a", "#8e9cc0"), 81)
  c:edgeIn(cap, "#262c40")
  -- pinned papers (no text: sketches and squiggles)
  local papers = { { 141, 104, 9, 10, "#f2ead6" }, { 153, 103, 8, 8, "#f4d0d8" }, { 163, 105, 6, 9, "#d8ecf4" },
    { 142, 117, 8, 9, "#e8f0c8" }, { 153, 114, 10, 12, "#f6e6b0" }, { 165, 117, 5, 8, "#f2ead6" } }
  for i, p in ipairs(papers) do
    local m = c:rect(p[1], p[2], p[1] + p[3], p[2] + p[4])
    m:each(function(x, y) put(x, y, p[5]) end)
    for yy = p[2] + 3, p[2] + p[4] - 1, 2 do hl(p[1] + 1, p[1] + p[3] - 2 - (yy % 3), yy, "#8a8090") end
    hl(p[1] + 1, p[1] + p[3], p[2] + p[4] + 1, "#7a5638")
    c:edgeIn(m, mix(p[5], "#3a3046", .5))
    put(p[1] + floor(p[3] / 2), p[2], ({ "#e04a4a", "#4a8ad0", "#f2c040" })[i % 3 + 1])
  end
  -- lost-umbrella flyer: a little umbrella sketch on the big yellow sheet
  hl(155, 161, 117, "#d8506a") hl(156, 160, 116, "#d8506a") put(158, 115, "#d8506a") vl(158, 118, 121, "#3a2a28") put(157, 121, "#3a2a28")
  -- a paper flapping loose (quirk)
  local fl = poly{ { 170, 124 }, { 177, 121 }, { 178, 128 }, { 171, 129 } }
  fl:each(function(x, y) put(x, y, "#f2ead6") end) c:edgeIn(fl, "#8a8090")
end

---------------------------------------------------------------- TEAHOUSE: The Drizzle & Crumpet (near left)
do
  local r = R("#7a6670", "#b8a6a8", "#dccac4", "#ece0d8", "#f8f0e6")
  local x0, x1, yt, yb = 24, 102, 178, 224
  shadowBand(x0, x1 + 8, yb, 5, .55)
  local side = buildingSide(x1 + 1, yt, yb, .07, R("#5a4a52", "#8a7a80", "#a8989c", "#c0b2b2", "#d8cccc"), 21)
  local wall = c:rect(x0, yt, x1, yb)
  renderTex(wall, r, 22)
  -- exposed stone plinth
  local pl = c:rect(x0, yb - 6, x1, yb) stoneTex(pl, R("#4a4658", "#6a6678", "#8a8698", "#a6a2b2", "#c4c0cc"), 23, 3, 6)
  shadeRight(wall, x1, 6, .12)
  -- thatch roof with rounded eaves
  local th = R("#5a3e22", "#8a6634", "#b08a4c", "#cca86a", "#e4c88a")
  local roof = poly{ { 18, 180 }, { 108, 180 }, { 104, 168 }, { 94, 154 }, { 34, 154 }, { 24, 168 } }
  thatchTex(roof, th, 24)
  hl(20, 106, 180, th.d) hl(22, 104, 179, th.s)
  c:edgeIn(roof, th.d)
  -- ridge of the thatch with a wavy top
  for x = 36, 92 do put(x, 154 + ((x // 4) % 2), th.h) end
  -- eyebrow dormer
  local eb = poly{ { 52, 170 }, { 58, 162 }, { 72, 162 }, { 78, 170 } }
  thatchTex(eb, th, 25) c:edgeIn(eb, th.d)
  window(60, 165, 10, 4, "#3e3046")
  -- quirk: teapot-shaped chimney pot
  local ck = c:rect(36, 150, 44, 158) stoneTex(ck, R("#4a4658", "#6a6678", "#8a8698", "#a6a2b2", "#c4c0cc"), 26, 3, 5) c:edgeIn(ck, "#3a3648")
  local tp = poly{ { 35, 150 }, { 35, 147 }, { 37, 146 }, { 43, 146 }, { 45, 147 }, { 45, 150 } }
  tp:each(function(x, y) put(x, y, x < 40 and "#4fb0a8" or "#2e8a84") end) c:edgeIn(tp, "#1e5a5a")
  put(46, 147, "#2e8a84") put(47, 146, "#2e8a84") put(48, 145, "#2e8a84") put(33, 147, "#1e5a5a") put(33, 148, "#1e5a5a")
  for i = 0, 2 do rect(48 + i * 3, 141 - i * 3, 50 + i * 4, 142 - i * 3, "#d8d0e0") end
  -- big bay window (lit) with a cake stand silhouette
  local bay = c:rect(30, 188, 58, 210)
  window(31, 189, 26, 18, "#2e5a5a", { sill = "#f0e6dc" })
  vl(44, 189, 206, "#2e5a5a")
  rect(36, 199, 41, 199, "#8a4a5a") vl(38, 196, 203, "#8a4a5a") rect(36, 203, 41, 203, "#8a4a5a") rect(36, 196, 40, 197, "#e88aa0")
  rect(48, 201, 53, 205, "#f6f0e6") rect(48, 200, 53, 200, "#c84a5a")
  -- door (teal) with fanlight
  door(68, 196, 13, 22, R("#163e40", "#245c5c", "#2e8a84", "#4fb0a8", "#8ad8cc"))
  window(70, 190, 9, 3, "#163e40")
  -- small window right
  window(88, 190, 9, 10, "#2e5a5a")
  -- hanging teapot sign on a bracket (the teahouse icon)
  hl(100, 116, 182, "#2e2430") vl(100, 182, 186, "#2e2430") put(101, 183, "#2e2430") put(102, 184, "#2e2430")
  vl(106, 183, 186, "#4a3a3a") vl(114, 183, 186, "#4a3a3a")
  local pot = c:rrect(104, 190, 116, 200, 3)
  pot:each(function(x, y) put(x, y, (x < 108 and y < 195) and "#7fd0c6" or (x > 113 or y > 197) and "#2e8a84" or "#4fb0a8") end)
  local lid = c:rect(108, 187, 112, 189) lid:each(function(x, y) put(x, y, "#2e8a84") end) put(110, 186, "#e8c040")
  local spout = poly{ { 103, 193 }, { 99, 189 }, { 98, 189 }, { 102, 196 } }
  spout:each(function(x, y) put(x, y, "#4fb0a8") end)
  hl(116, 118, 192, "#2e8a84") vl(118, 192, 197, "#2e8a84") hl(116, 118, 197, "#2e8a84")
  for x = 105, 115, 3 do put(x, 196, "#f2e6c8") end -- painted dots
  c:edgeIn(pot, "#1e4a4a") c:edgeIn(lid, "#1e4a4a")
  put(106, 191, "#e8fff8") -- glint
  for i = 0, 2 do put(97 - i, 186 - i * 2, "#e4e0ec") end -- steam
  -- quirk: wellington boots used as planters + umbrella stand by the door
  local function boot(x, col, dk)
    rect(x, 213, x + 4, 222, col) rect(x, 220, x + 7, 222, col) vl(x + 4, 213, 219, dk) hl(x, x + 7, 223, dk)
    put(x + 1, 214, mix(col, "#ffffe0", .4))
    put(x + 1, 211, "#5aa04a") put(x + 2, 210, "#e86a8a") put(x + 3, 211, "#5aa04a") put(x + 2, 212, "#3e7a3a")
  end
  boot(56, "#d84a4a", "#8a2a2a") boot(84, "#f2c040", "#a8801a")
  rect(92, 212, 99, 222, "#5a5a6a") hl(92, 99, 212, "#8a8a9a") vl(99, 212, 222, "#3a3a4a")
  for i, col in ipairs({ "#4a8ad0", "#e05a5a", "#6ab06a" }) do vl(92 + i * 2, 204 - i, 212, col) put(92 + i * 2 - 1, 204 - i, "#3a2a28") end
  c:edgeIn(wall, r.d)
  c:edgeIn(side, "#5a4a52")
end

---------------------------------------------------------------- PUB: the Crooked Kettle (far right)
do
  local r = R("#3a3a4a", "#5a5a6c", "#74748a", "#8e8ea4", "#aeaec2")
  local x0, x1, yt, yb = 364, 452, 86, 124
  shadowBand(x0 - 8, x1, yb, 4, .5)
  local side = buildingSide(x0 - 1, yt, yb, .09, r, 31)
  local wall = c:rect(x0, yt, x1, yb)
  stoneTex(wall, r, 32, 5, 10)
  shadeRight(wall, x1, 8, .15)
  local roofR = R("#20263a", "#343c56", "#46506e", "#5e6a8e", "#8494ba")
  local roof = poly{ { 358, 86 }, { 458, 86 }, { 446, 60 }, { 370, 60 } }
  slateTex(roof, roofR, 33)
  shadeBottom(roof, 86, 2, .25)
  c:edgeIn(roof, roofR.d)
  for _, cx in ipairs({ 376, 438 }) do
    local ch = c:rect(cx, 50, cx + 8, 62) stoneTex(ch, r, cx, 3, 4) c:edgeIn(ch, r.d)
    rect(cx - 1, 48, cx + 9, 50, "#4a4a5a") rect(cx + 1, 45, cx + 3, 47, "#b06a4a") rect(cx + 5, 45, cx + 7, 47, "#b06a4a")
  end
  for i = 0, 3 do rect(440 + i * 2, 38 - i * 4, 444 + i * 3, 40 - i * 4, "#8e8aa6") end
  -- green painted frontage band
  local fasc = c:rect(x0, 86, x1, 90) fasc:each(function(x, y) put(x, y, y == 86 and "#5a9a6a" or "#2e5a3e") end)
  for x = x0 + 2, x1 - 2, 6 do put(x, 88, "#d8b04a") end -- gold studs
  -- dormers
  for _, dx in ipairs({ 392, 418 }) do
    local d = poly{ { dx - 2, 74 }, { dx + 7, 66 }, { dx + 16, 74 } } slateTex(d, roofR, dx) c:edgeIn(d, roofR.d)
    window(dx + 3, 75, 9, 7, "#2e3a3e")
  end
  -- lit windows (big, warm)
  window(372, 96, 16, 12, "#1e3a2a", { panes = true }) window(424, 96, 22, 12, "#1e3a2a", { panes = true })
  -- quirk: quiz-champion trophy on the windowsill (with a feather tucked in)
  rect(432, 101, 436, 104, "#e8b830") rect(433, 105, 435, 106, "#c8901a") hl(431, 437, 107, "#a87010")
  put(431, 102, "#e8b830") put(437, 102, "#e8b830") put(433, 101, "#fff0a0") vl(436, 97, 100, "#a88a6a") put(437, 97, "#c8b090")
  -- door (green) + lantern
  door(400, 102, 14, 22, R("#14301e", "#1e4a2e", "#2e6a42", "#4a8a5a", "#7ab88a"))
  hl(398, 416, 124, "#9c96a2")
  rect(418, 98, 421, 102, "#2e2430") rect(419, 99, 420, 101, "#ffd98a") glow(419, 100, 9, .32)
  -- barrels by the wall
  for i, bx in ipairs({ 446, 438 }) do
    local b = c:rrect(bx - 4, 112 + (i - 1) * 2, bx + 4, 124, 2)
    b:each(function(x, y) put(x, y, (y - 112) % 5 == 0 and "#3e3a40" or (x < bx - 1 and "#a8743e" or "#7e5430")) end)
    c:edgeIn(b, "#3e2a1e")
  end
  -- hanging sign bracket: the Crooked Kettle (tilted copper kettle)
  hl(352, 366, 90, "#2e2430") vl(366, 88, 94, "#2e2430") put(365, 91, "#2e2430") put(364, 92, "#2e2430")
  vl(354, 91, 93, "#4a3a3a") vl(364, 91, 93, "#4a3a3a")
  local bd = c:rect(352, 94, 366, 114)
  bd:each(function(x, y) put(x, y, (x + y) % 7 == 0 and "#1e4a2e" or "#2e6a42") end)
  hl(352, 366, 94, "#4a8a5a") c:edgeIn(bd, "#14301e")
  hl(353, 365, 95, "#d8b04a") hl(353, 365, 113, "#d8b04a")
  local k = poly{ { 355, 107 }, { 356, 102 }, { 359, 100 }, { 363, 101 }, { 364, 106 }, { 362, 109 }, { 357, 110 } }
  k:each(function(x, y) put(x, y, (x < 359 and y < 104) and "#f2a860" or ((x > 361 or y > 107) and "#a85a2a" or "#d8803a")) end)
  c:edgeIn(k, "#5a2a14")
  put(354, 103, "#d8803a") put(353, 102, "#d8803a") put(352, 101, "#a85a2a") -- crooked spout
  hl(358, 362, 98, "#5a2a14") put(357, 99, "#5a2a14") put(363, 99, "#5a2a14") -- handle
  put(357, 103, "#fff0d0")
  c:edgeIn(wall, r.d)
  c:edgeIn(side, "#2a2a3a")
end

---------------------------------------------------------------- SHOPS: seed shop & stall (near right)
do
  local r = R("#4a3e5a", "#6e5e82", "#8a7a9e", "#a898ba", "#c8bad6") -- heather-washed stone
  local x0, x1, yt, yb = 352, 412, 176, 212
  shadowBand(x0 - 6, x1, yb, 4, .55)
  local side = buildingSide(x0 - 1, yt, yb, .06, r, 41)
  local wall = c:rect(x0, yt, x1, yb)
  stoneTex(wall, r, 42, 4, 8)
  shadeRight(wall, x1, 6, .15)
  local roofR = R("#262c40", "#3d4660", "#4f5a78", "#68769a", "#8e9cc0")
  local roof = poly{ { 346, 176 }, { 418, 176 }, { 410, 158 }, { 354, 158 } }
  slateTex(roof, roofR, 43) c:edgeIn(roof, roofR.d)
  -- big sprout sign on the roof (shop icon)
  local sg = c:rect(370, 154, 392, 168)
  sg:each(function(x, y) put(x, y, "#efe2c0") end) c:edgeIn(sg, "#5a4630")
  vl(381, 160, 166, "#3e7a3a")
  local l1 = poly{ { 381, 162 }, { 374, 158 }, { 373, 160 }, { 378, 163 } } l1:each(function(x, y) put(x, y, "#6ab04a") end)
  local l2 = poly{ { 381, 161 }, { 388, 157 }, { 389, 159 }, { 384, 162 } } l2:each(function(x, y) put(x, y, "#4e9a3e") end)
  rect(378, 165, 384, 166, "#8a5a3a")
  -- striped awning
  local aw = poly{ { 354, 184 }, { 410, 184 }, { 414, 192 }, { 350, 192 } }
  aw:each(function(x, y) put(x, y, (floor((x - 350) / 6) % 2 == 0) and "#3e8a4e" or "#efe6cc") end)
  for x = 350, 414 do if (x - 350) % 6 < 3 then put(x, 193, (floor((x - 350) / 6) % 2 == 0) and "#2e6a3a" or "#c8bc9a") end end
  c:edgeIn(aw, "#1e4a2a")
  -- shop window lit, door
  window(358, 196, 22, 10, "#3e2a46")
  for i, col in ipairs({ "#e86a8a", "#f2c040", "#6ab06a", "#4a8ad0", "#b07ad8" }) do rect(357 + i * 4, 203, 359 + i * 4, 205, col) end
  door(388, 194, 12, 18, R("#4a1e2e", "#7a2e44", "#a84a5e", "#c8707e", "#e8a0aa"))
  -- outdoor stall: crates of seed packets and potted seedlings
  local st = c:rect(354, 206, 386, 214)
  plankTex(st, R("#3e2a22", "#6a4632", "#8a5e40", "#ad7c52", "#cfa070"), 44, false) c:edgeIn(st, "#3e2a22")
  for i = 0, 6 do
    local px = 357 + i * 4
    local col = ({ "#e86a8a", "#f2c040", "#6ab06a", "#4a8ad0", "#f29a4a", "#b07ad8", "#e05a5a" })[i + 1]
    rect(px, 202, px + 2, 205, col) put(px + 1, 203, "#f8f0e0")
  end
  for i, px in ipairs({ 392, 400, 408 }) do
    local p = poly{ { px, 206 }, { px + 6, 206 }, { px + 5, 213 }, { px + 1, 213 } }
    p:each(function(x, y) put(x, y, x < px + 3 and "#d0784a" or "#a8582e") end) c:edgeIn(p, "#5a2a14")
    vl(px + 3, 201, 205, "#3e7a3a") put(px + 2, 201, "#6ab04a") put(px + 4, 202, "#6ab04a") put(px + 1, 202, "#86c45a")
  end
  c:edgeIn(wall, r.d) c:edgeIn(side, "#3a2e4a")
end

---------------------------------------------------------------- WILD TRAIL (right edge)
do
  -- path leaving to the right
  local path = poly{ { 400, 230 }, { 476, 200 }, { 476, 214 }, { 430, 232 } }
  path = poly{ { 420, 226 }, { 432, 214 }, { 479, 196 }, { 479, 212 }, { 446, 226 } }
  path:each(function(x, y) local v = H(x, y, 90) put(x, y, v < .2 and "#b89a72" or (v < .85 and "#9c7e5a" or "#7a6044")) end)
  -- heather & gorse banks
  for i = 1, 70 do
    local x, y = 428 + floor(H(i, 1, 91) * 48), 150 + floor(H(i, 2, 91) * 64)
    if not path:has(x, y) then
      local col = H(i, 3, 91) < .5 and "#9a6aa8" or (H(i, 3, 91) < .75 and "#e8c040" or "#4e7a3e")
      put(x, y, col) put(x + 1, y, col) put(x, y + 1, mix(col, SHADE, .4))
    end
  end
  -- rustic arch (rowan wood + ivy)
  local wood = R("#2e2018", "#54382a", "#74503a", "#966c4c", "#b88e66")
  shadowBand(434, 460, 224, 3, .45)
  local lp = c:rect(434, 160, 438, 224) local rp = c:rect(454, 160, 458, 224)
  plankTex(lp, wood, 92, true) plankTex(rp, wood, 93, true)
  local top = poly{ { 430, 160 }, { 434, 150 }, { 446, 144 }, { 458, 150 }, { 462, 160 }, { 458, 162 }, { 446, 152 }, { 434, 162 } }
  top:each(function(x, y) put(x, y, y < 152 and wood.l or wood.b) end)
  c:edgeIn(lp, wood.d) c:edgeIn(rp, wood.d) c:edgeIn(top, wood.d)
  -- ivy and rowan berries on the arch
  for i = 1, 60 do
    local t = H(i, 4, 94)
    local x, y
    if i % 3 == 0 then x, y = 432 + floor(t * 30), 144 + floor(H(i, 5, 94) * 18)
    elseif i % 3 == 1 then x, y = 432 + floor(H(i, 6, 94) * 8), 160 + floor(t * 60)
    else x, y = 452 + floor(H(i, 6, 94) * 8), 160 + floor(t * 60) end
    put(x, y, H(i, 7, 94) < .7 and "#4e9a3e" or "#7ac05a")
    if H(i, 8, 94) < .25 then put(x + 1, y, "#d84a3a") end
  end
  -- signpost with arrow pointing out (leaf + hill icon)
  vl(446, 186, 226, "#5a3e2a") vl(447, 186, 226, "#3e2a1e")
  local ar = poly{ { 440, 186 }, { 456, 186 }, { 461, 191 }, { 456, 196 }, { 440, 196 } }
  ar:each(function(x, y) put(x, y, y < 189 and "#efe2c0" or "#d8c8a0") end) c:edgeIn(ar, "#5a4630")
  local hm = poly{ { 443, 194 }, { 448, 188 }, { 453, 194 } } hm:each(function(x, y) put(x, y, "#5a9a4a") end)
  put(448, 188, "#f2f0e8") put(456, 191, "#5a4630") put(457, 191, "#5a4630")
end

---------------------------------------------------------------- GATE FRAME (drawn last over everything)
do
  local st = R("#34323f", "#55525f", "#73707e", "#8f8c9a", "#adaab6")
  local lp = c:rect(0, 0, 17, Hh - 1) local rp = c:rect(462, 0, W - 1, Hh - 1)
  stoneTex(lp, st, 101, 6, 9) stoneTex(rp, st, 102, 6, 9)
  rp:each(function(x, y) if x > 474 then tint(x, y, SHADE, .3) end end)
  lp:each(function(x, y) if x > 14 then tint(x, y, SHADE, .25) end end)
  c:edgeIn(lp, st.d) c:edgeIn(rp, st.d)
  -- capstones
  for _, x in ipairs({ -2, 460 }) do rect(x, 14, x + 21, 18, st.l) hl(x, x + 21, 14, st.h) hl(x, x + 21, 18, st.d) end
  -- oak beam + slate roof strip (lychgate)
  local beam = c:rect(0, 8, W - 1, 13)
  beam:each(function(x, y) local v = H(floor(x / 7), y, 103) put(x, y, y == 8 and "#a87a52" or (y == 13 and "#3e2a1e" or (v < .3 and "#7a5438" or "#6a4630"))) end)
  local sl = c:rect(0, 0, W - 1, 7) slateTex(sl, R("#20263a", "#343c56", "#46506e", "#5e6a8e", "#8494ba"), 104)
  hl(0, W - 1, 7, "#181c2c")
  -- drips off the slate edge (drizzle)
  for x = 24, 456, 37 do put(x, 15 + (x % 3), "#a8b4d0") put(x, 16 + (x % 3), "#c8d2e8") end
  -- ivy creeping on the pillars
  for i = 1, 90 do
    local side = i % 2
    local x = side == 0 and floor(H(i, 1, 105) * 18) or 462 + floor(H(i, 1, 105) * 18)
    local y = 14 + floor(H(i, 2, 105) ^ 1.6 * 150)
    put(x, y, H(i, 3, 105) < .6 and "#4e8a3e" or "#6aaa4e") put(x + 1, y, "#3a6a32")
  end
  -- bunting (sagging rope)
  local cols = { "#9a6aa8", "#5a9a5a", "#efe2c0", "#c8603a", "#4a7ab0", "#e8c040" }
  local function ropeY(x) local t = (x - 18) / 444 return floor(16 + 18 * 4 * t * (1 - t) + .5) end
  for x = 18, 461 do put(x, ropeY(x), "#3e3236") end
  local n = 0
  for x = 26, 452, 12 do
    n = n + 1
    local y = ropeY(x + 3)
    local col = cols[(n - 1) % #cols + 1]
    local f = poly{ { x, y + 1 }, { x + 7, y + 1 }, { x + 3, y + 8 } }
    f:each(function(px, py) put(px, py, (px < x + 3) and mix(col, "#fff4dc", .2) or col) end)
    c:edgeIn(f, mix(col, "#20182a", .45))
  end
  -- hanging lanterns
  for _, lx in ipairs({ 36, 443 }) do
    vl(lx, 14, 22, "#2e2430")
    rect(lx - 4, 22, lx + 4, 24, "#2e2430")
    rect(lx - 4, 25, lx + 4, 35, "#2e2430")
    rect(lx - 3, 26, lx + 3, 34, "#f0b456")
    rect(lx - 2, 27, lx + 2, 32, "#fbd88a") put(lx - 2, 27, "#fff0c2")
    vl(lx, 26, 34, "#2e2430")
    rect(lx - 5, 36, lx + 5, 37, "#2e2430") put(lx, 38, "#2e2430")
    glow(lx, 30, 20, .28)
    rect(lx - 3, 26, lx + 3, 34, "#f0b456") rect(lx - 2, 27, lx + 2, 32, "#fbd88a") vl(lx, 26, 34, "#2e2430") put(lx - 2, 27, "#fff0c2")
  end
end

---------------------------------------------------------------- RAIN (soft drizzle streaks)
local function inBox(x, y, b) return x >= b[1] and x <= b[3] and y >= b[2] and y <= b[4] end
local calm = { { 380, 228, 479, 269 } }
for i = 1, 520 do
  local x, y = 18 + floor(H(i, 1, 200) * 444), 16 + floor(H(i, 2, 200) * 230)
  local ok = true
  for _, b in ipairs(calm) do if inBox(x, y, b) then ok = false end end
  if ok then
    for k = 0, 2 do tint(x - floor(k / 2), y + k, "#d4daf0", .35) end
  end
end
-- dusk cool wash lower-right corner and warm vignette from lanterns kept subtle
for y = 230, 269 do for x = 380, 461 do tint(x, y, SHADE, .06) end end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

-- layout json
local spots = {
  { "green", "The Village Green", 150, 156, 330, 214 },
  { "tea", "The Drizzle & Crumpet", 18, 146, 118, 224 },
  { "board", "Notice Board", 132, 84, 178, 140 },
  { "library", "Library", 22, 44, 116, 126 },
  { "s1", "Standing Stones", 196, 48, 284, 100 },
  { "s2", "The Crooked Kettle", 352, 44, 456, 124 },
  { "shops", "Shops", 344, 154, 420, 216 },
  { "wild", "Wild Trail", 428, 140, 476, 226 },
}
local stand = { { 60, 252 }, { 150, 246 }, { 240, 246 }, { 330, 246 }, { 240, 128 }, { 316, 128 } }
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2],
    floor((s[3] + s[5]) / 2), floor((s[4] + s[6]) / 2), s[3], s[4], s[5], s[6])
end
local sp = {}
for _, p in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n',
  VPY, table.concat(parts, ","), table.concat(sp, ",")))
f:close()
print("ok " .. NAME)
