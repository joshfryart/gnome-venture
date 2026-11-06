-- The Great Treehouse: cut-away tree, 480x270. Rooms fill the layout boxes (here_layouts.json 'treehouse'); a ledge at every one of the 24 perches.
-- Run: /tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script treehouse.lua
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/tree-yard/out/")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "tree-house" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON
local DIRT = S.DIRT
local rect, rr, poly, obj, tex, hash = S.rect, S.rr, S.poly, S.obj, S.tex, S.hash

---------------------------------------------------------------- polish guard: pal perches and the compass corner are a contract.
-- While polish() runs, c:put ignores the 20x12 px above every perch + its strip (x+-10, y-12..y+4) and the compass corner.
local PAL = {{60,60},{120,40},{180,58},{240,36},{300,58},{360,40},{420,62},{40,118},{96,100},{160,104},{220,96},{280,100},{340,98},{400,104},{450,120},{50,176},{110,170},{170,178},{230,172},{290,176},{350,170},{410,178},{70,236},{350,246},{70,202},{96,206}}
local PR, GUARD = {}, false
for _, p in ipairs(PAL) do for y = p[2] - 12, p[2] + 4 do for x = p[1] - 10, p[1] + 10 do PR[y * W + x] = true end end end
for y = 218, H - 1 do for x = 366, W - 1 do PR[y * W + x] = true end end
do
  local rawput = getmetatable(c).__index.put
  c.put = function(self, x, y, hex, o)
    if GUARD and (x < 0 or x >= W or PR[y * W + x]) then return end
    return rawput(self, x, y, hex, o)
  end
end
local function polish(f) GUARD = true; f(); GUARD = false end
local function P(x, y, col) c:put(x, y, col) end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end
local function inkrim(m) c:rim(m, "#2b1c26") end
local GSET = {}
for _, r in ipairs{GREEN, LEAF} do for _, h in ipairs(r) do GSET[h] = true end end
local function isGreen(h) return h and GSET[h] or false end

---------------------------------------------------------------- sky, hills, meadow
c:stripes(0, 236, {"#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8"}, {2, 2, 2, 2, 3})
c:cloud(36, 70, 52, "#f8f0e0", "#d6e6f0"); c:cloud(380, 52, 44, "#f8f0e0", "#d6e6f0"); c:cloud(250, 40, 38, "#f8f0e0", "#d6e6f0")
local function f1(x) return 186 + 14 * sin(x / 52) + 7 * sin(x / 19 + 1) end
local function f2(x) return 206 + 9 * sin(x / 41 + 2) + 5 * sin(x / 13) end
local function f3(x) return 228 + 4 * sin(x / 30) end
c:terrain(f1, "#7e9cc4", 240)
polish(function()   -- far hill: pale ridge, hazy dither under it, a thin tree line (far = lighter and cooler)
  for x = 0, W - 1 do
    local y0 = floor(f1(x) + .5)
    P(x, y0, "#a4bede")
    for d = 1, 3 do if (x + d) % 2 == 0 and (d < 3 or x % 4 == 0) then P(x, y0 + d, "#8eaace") end end
    if hash(x, 3, 31) > .93 then for k = 1, 5 do P(x + k, y0 + 6 + (k % 2), "#8eaace") end end
  end
  for cx = 3, W, 9 do
    local y0 = floor(f1(cx) + .5) - 1
    local rx, ry = 3 + floor(hash(cx, 1, 33) * 3), 2 + floor(hash(cx, 2, 33) * 2)
    local m = c:ellipse(cx, y0, rx, ry); c:fillMask(m, "#7898c0"); c:fillMask(rect(cx - rx, y0 - ry, cx - 1, y0 - ry):clip(m), "#8cacd0")
    c:fillMask(c:rect(cx + 1, y0 + 1, cx + rx, y0 + ry):clip(m), "#6c8cb8")
  end
end)
c:terrain(f2, "#5f9a78", 244)
polish(function()   -- near hill: lit ridge, mown furrows, hedgerows and a few pale fields
  for x = 0, W - 1 do
    local y0 = floor(f2(x) + .5)
    P(x, y0, "#86be9a")
    for d = 1, 3 do if (x + d) % 2 == 0 and (d < 3 or x % 4 == 0) then P(x, y0 + d, "#6eaa86") end end
    if (x + floor(y0 / 2)) % 7 == 0 then for d = 5, 18, 2 do P(x + floor(d / 4), y0 + d, "#6eaa86") end end
  end
  for _, b in ipairs{ {26, 212, 14, 4}, {112, 216, 18, 4}, {204, 211, 12, 3}, {330, 214, 16, 4}, {392, 206, 20, 5}, {452, 212, 14, 4} } do
    local m = c:ellipse(b[1], b[2], b[3], b[4]); c:fillMask(m, "#4c8668")
    c:fillMask(c:rect(b[1] - b[3], b[2] - b[4], b[1] + b[3], b[2] - b[4] + 1):clip(m), "#5f9a78")
    tex(m, function(x, y) if hash(x, y, 34) > .86 then return "#3c7458" end end)
  end
  for _, b in ipairs{ {70, 224, 24}, {252, 222, 18}, {420, 224, 22} } do
    for k = 0, b[3] do for r = 0, 3 do if (k + r) % 2 == 0 then P(b[1] + k - r, b[2] + r, "#7ab492") end end end
  end
end)
c:terrain(f3, GREEN[4], 269)
tex(rect(0, 232, 479, 269), function(x, y) if hash(x, y, 4) > .955 then return GREEN[5] elseif hash(x, y, 9) > .975 then return GREEN[3] end end)
polish(function()   -- ground variety: lit ridge, mown bands, dark clover, dirt scuffs, pebbles, tufts, clover flowers
  for x = 0, W - 1 do
    local y0 = floor(f3(x) + .5)
    P(x, y0, GREEN[5])
    if x % 2 == 0 then P(x, y0 + 1, GREEN[5]) end
    if x % 2 == 1 then P(x, y0 + 2, GREEN[3]) end
  end
  for y = 234, 268 do for x = 0, W - 1 do
    local band = floor((y - 234) / 6)
    if (band % 2 == 1) and ((x + y) % 2 == 0) and hash(x, y, 40) > .3 then P(x, y, GREEN[3]) end
    if (band % 2 == 0) and ((x + y) % 3 == 0) and hash(x, y, 41) > .6 then P(x, y, GREEN[5]) end
  end end
  for _, b in ipairs{ {24, 246, 14, 3}, {138, 260, 12, 3}, {316, 262, 14, 3}, {352, 240, 10, 2} } do   -- bare dirt scuffs
    local m = c:ellipse(b[1], b[2], b[3], b[4]); c:fillMask(m, DIRT[3])
    tex(m, function(x, y) if y < b[2] - 1 then return DIRT[4] elseif y > b[2] + 1 then return DIRT[2] elseif hash(x, y, 42) > .8 then return DIRT[5] end end)
    c:fillMask(m:edge():clip(c:rect(b[1] - b[3], b[2], b[1] + b[3], b[2] + b[4])), DIRT[2])
  end
  for i = 0, 40 do   -- pebbles
    local x, y = 4 + floor(hash(i, 1, 43) * 470), 236 + floor(hash(i, 2, 43) * 30)
    c:fillMask(rect(x, y, x + 1, y), STONE[5]); c:fillMask(rect(x, y + 1, x + 1, y + 1), STONE[3])
  end
  for i = 0, 70 do   -- grass tufts: three blades, three kinds
    local x, y = 2 + floor(hash(i, 3, 44) * 474), 234 + floor(hash(i, 4, 44) * 33)
    local k = i % 3
    P(x, y, GREEN[2]); P(x - 1, y - 1, k == 0 and GREEN[5] or GREEN[4]); P(x + 1, y - 2, GREEN[5]); P(x, y - 2, GREEN[4])
    if k == 1 then P(x + 2, y - 1, LEAF[5]) end
    if k == 2 then P(x - 2, y - 2, LEAF[4]); P(x - 1, y - 3, LEAF[5]) end
  end
  for i = 0, 26 do   -- clover and daisies, white-cream not pure white
    local x, y = 4 + floor(hash(i, 5, 45) * 470), 238 + floor(hash(i, 6, 45) * 28)
    if i % 2 == 0 then P(x, y, "#f8eacc"); P(x - 1, y, "#fff4d6"); P(x + 1, y, "#fff4d6"); P(x, y - 1, "#fff4d6"); P(x, y + 1, "#fff4d6"); P(x, y, "#f5b82e")
    else P(x, y, "#f5809f"); P(x + 1, y, "#cc5c7e"); P(x, y - 1, GREEN[2]) end
  end
end)

---------------------------------------------------------------- canopy (behind everything)
local function blob(cx, cy, rx, ry, ramp)
  local m = c:ellipse(cx, cy, rx, ry)
  c:rim(m, ramp[1])
  tex(m, function(x, y)
    local t = ((x - cx) / rx) * .5 + ((y - cy) / ry) * .8   -- light from the upper left
    local i = t < -.55 and 5 or t < -.1 and 4 or t < .45 and 3 or 2
    if hash(x, y, 5) > .93 then i = min(6, i + 1) end
    return ramp[i]
  end)
end
for _, b in ipairs{ {40, 74, 60, 50}, {120, 44, 66, 38}, {210, 36, 60, 34}, {300, 34, 64, 36}, {392, 46, 70, 40}, {450, 80, 44, 46}, {20, 130, 26, 30}, {200, 80, 48, 34}, {296, 82, 50, 34} } do
  blob(b[1], b[2], b[3], b[4], GREEN)
end
for _, b in ipairs{ {80, 50, 38, 26}, {170, 28, 36, 20}, {262, 24, 34, 18}, {350, 30, 38, 20}, {430, 52, 34, 24}, {250, 64, 30, 18} } do blob(b[1], b[2], b[3], b[4], LEAF) end
polish(function()   -- leaf clusters in 3+ tones, each leaf one step lighter on top / darker under, keeping the blob's own light
  local pos = {}
  for _, r in ipairs{GREEN, LEAF} do for i, h in ipairs(r) do pos[h] = { r, i } end end
  for i = 1, 5200 do
    local x, y = floor(hash(i, 1, 40) * 478), floor(hash(i, 2, 40) * 168)
    local u = pos[c:get(x + 2, y + 1) or ""]
    local kind = floor(hash(i, 9, 40) * 3)
    local okp = u ~= nil
    if okp then for dy = 0, 2 do for dx = 0, 4 do if not isGreen(c:get(x + dx, y + dy)) then okp = false end end end end
    if okp then
      local r, k = u[1], u[2] + (hash(i, 3, 40) > .8 and 1 or hash(i, 4, 40) > .85 and -1 or 0)
      local hi, mid, lo = r[min(6, max(1, k + 1))], r[min(6, max(1, k))], r[min(6, max(1, k - 1))]
      local flip = hash(i, 5, 40) > .5
      if kind == 0 then
        for dx = 1, 3 do P(x + dx, y, hi) end
        for dx = 0, 4 do P(x + dx, y + 1, mid) end
        for dx = 1, 3 do P(x + dx, y + 2, lo) end
        P(flip and x or x + 4, y + 1, lo)
      elseif kind == 1 then   -- diagonal leaf
        for t = 0, 3 do P(flip and x + 3 - t or x + t, y + (t > 1 and 1 or 0), mid); P(flip and x + 4 - t or x + t + 1, y + (t > 1 and 1 or 0), t < 2 and hi or lo) end
      else                    -- small leaf pair
        P(x, y, hi); P(x + 1, y, hi); P(x + 1, y + 1, lo); P(x + 3, y + 1, hi); P(x + 4, y + 1, mid); P(x + 3, y + 2, lo); P(x + 4, y + 2, lo)
      end
    end
  end
end)

---------------------------------------------------------------- trunk, roots, limbs
local trunk = poly{ {196, 74}, {284, 74}, {292, 140}, {300, 214}, {330, 244}, {352, 269}, {128, 269}, {150, 244}, {182, 214}, {188, 140} }
c:rim(trunk, TIMB[1])
tex(trunk, function(x, y)
  local k = floor((x + floor(y / 17) * 3) / 5)
  local t = (x - 188) / 112
  local i = t < .22 and 5 or t < .55 and 4 or 3
  if (k % 4) == 0 then i = i - 1 end
  if hash(x, floor(y / 3), 8) > .94 then i = i - 1 end
  return TIMB[max(1, min(6, i))]
end)
polish(function()   -- bark: plates, cracks, knots, moss on the north (left) side, roots with moss
  local function edgeL(y) for x = 100, 300 do if trunk:has(x, y) then return x end end end
  local function edgeR(y) for x = 400, 100, -1 do if trunk:has(x, y) then return x end end end
  for i = 0, 130 do   -- raised bark plates: lit crown, shadow lip
    local x, y = 150 + floor(hash(i, 1, 50) * 200), 78 + floor(hash(i, 2, 50) * 190)
    local w = 4 + floor(hash(i, 3, 50) * 5)
    local okp = true
    for k = 0, w + 1 do if not trunk:has(x + k, y) or not trunk:has(x + k, y + 2) then okp = false end end
    if okp then
      for k = 0, w - 1 do P(x + k, y, (k < 2 and (x < 230)) and TIMB[6] or TIMB[5]) end
      for k = 1, w do P(x + k, y + 1, TIMB[2]) end
      if hash(i, 4, 50) > .5 then P(x + w, y, TIMB[3]) end
    end
  end
  for i = 0, 36 do   -- cracks, jittering down; the right wall of a groove catches the light
    local x, y = 192 + floor(hash(i, 1, 51) * 108), 80 + floor(hash(i, 2, 51) * 180)
    local len, cx = 8 + floor(hash(i, 3, 51) * 22), x
    for k = 0, len - 1 do
      if trunk:has(cx, y + k) and trunk:has(cx + 1, y + k) then
        P(cx, y + k, TIMB[1]); P(cx + 1, y + k, k % 3 == 2 and TIMB[4] or TIMB[5])
        if k > 3 and k < len - 3 and hash(k, i, 53) > .8 then P(cx - 1, y + k, TIMB[2]) end
      end
      if hash(k, i, 52) > .62 then cx = cx + (hash(k, i, 54) > .5 and 1 or -1) end
    end
  end
  local function knot(cx, cy)
    local m = c:ellipse(cx, cy, 3, 4)
    for ring = 1, 2 do c:rim(c:ellipse(cx, cy, 3 + ring, 4 + ring):cut(c:ellipse(cx, cy, 2 + ring, 3 + ring)), ring == 1 and TIMB[2] or TIMB[3]) end
    c:rim(m, TIMB[1]); c:fillMask(m, TIMB[2]); c:fillMask(c:ellipse(cx + 1, cy + 1, 1, 2), TIMB[1])
    P(cx - 2, cy - 2, TIMB[5]); P(cx - 1, cy - 3, TIMB[5]); P(cx - 2, cy - 1, TIMB[4])
  end
  for _, k in ipairs{ {254, 158}, {222, 140}, {248, 194}, {166, 238}, {316, 232}, {198, 100}, {282, 150} } do knot(k[1], k[2]) end
  for y = 76, 262 do   -- moss, north side: thick on the left rim, thin lichen on the right
    local ex = edgeL(y)
    if ex then
      local n = sin(y / 13 + 1) + sin(y / 5.3) + (hash(y, 1, 55) - .5)
      if n > -.2 then
        local w = floor(3 + n * 2.5)
        for dx = 0, w do
          local tone = (dx == 0 and y % 2 == 0) and GREEN[2] or dx <= w - 2 and GREEN[3] or (hash(dx, y, 56) > .5 and GREEN[4] or TIMB[3])
          if dx == 1 and hash(y, 2, 56) > .6 then tone = LEAF[3] end
          if dx <= 1 and sin(y / 7) > .3 then tone = GREEN[4] end
          P(ex + dx, y, tone)
        end
      end
    end
    local er = edgeR(y)
    if er and y > 150 and hash(y, 7, 57) > .86 then P(er - 1, y, GREEN[3]); P(er - 2, y, LEAF[3]) end
  end
  local function root(p0, p1, p2, w0, w1)   -- curved root: bezier of round stamps, lit on top, mossy
    local m = HP.mask()
    for i = 0, 40 do
      local t = i / 40
      local x = (1 - t)^2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
      local y = (1 - t)^2 * p0[2] + 2 * (1 - t) * t * p1[2] + t * t * p2[2]
      local r = (w0 + (w1 - w0) * t) / 2
      m:add(c:ellipse(floor(x + .5), floor(y + .5), r, r * .9))
    end
    c:rim(m, TIMB[1])
    tex(m, function(x, y)
      if not m:has(x, y - 1) or not m:has(x - 1, y) and not m:has(x, y - 2) then return TIMB[5] end
      if not m:has(x, y + 2) then return TIMB[2] end
      if not m:has(x, y + 1) then return TIMB[3] end
      if not m:has(x + 1, y) then return TIMB[2] end
      return (hash(floor(x / 2), floor(y / 3), 58) > .5) and TIMB[4] or TIMB[3]
    end)
    m:each(function(x, y)
      if not m:has(x, y - 1) then
        local h = hash(x, y, 59)
        if h > .3 then P(x, y, GREEN[3]); if h > .55 then P(x, y + 1, GREEN[2]) end if h > .8 then P(x, y - 1, GREEN[4]); P(x + 1, y, LEAF[3]) end end
      end
    end)
    return m
  end
  root({166, 234}, {136, 244}, {120, 268}, 10, 3)
  root({150, 252}, {144, 264}, {132, 269}, 6, 2)
  root({314, 236}, {338, 244}, {336, 262}, 9, 3)
  root({182, 244}, {170, 258}, {166, 269}, 7, 3)
  root({320, 252}, {324, 262}, {312, 269}, 7, 3)
end)
-- limbs to the side rooms
local function limb(pts, th)
  local m = c:line(pts, th)
  c:rim(m, TIMB[1]); tex(m, function(x, y) return (hash(floor(x / 4), y, 3) > .5 and TIMB[4] or TIMB[3]) end)
end
limb({{200, 176}, {160, 190}, {100, 196}}, 7); limb({{280, 170}, {330, 184}, {390, 188}}, 7)
limb({{200, 120}, {120, 118}, {70, 122}}, 6); limb({{282, 100}, {350, 96}, {420, 100}}, 7)
limb({{236, 78}, {236, 60}}, 8)

---------------------------------------------------------------- rooms (cut-away: open front, lit inside)
local function brick(m, ramp, seed, bw, bh)   -- running-bond stones lit from the top left, dark mortar
  bw, bh = bw or 7, bh or 4
  local x0, y0 = m:bbox()
  tex(m, function(x, y)
    local row = floor((y - y0) / bh); local bx = (x - x0 + (row % 2) * floor(bw / 2))
    local k = floor(bx / bw)
    if (y - y0) % bh == bh - 1 or bx % bw == bw - 1 then return ramp[2] end
    local t = 3 + (hash(k, row, seed) > .55 and 1 or 0) - (hash(k, row, seed + 1) > .85 and 1 or 0)
    if (y - y0) % bh == 0 or bx % bw == 0 then t = t + 1 end
    return ramp[max(1, min(6, t))]
  end)
end
-- material helpers (pass 3): plank grain with nails and knots, flagstone walls with chips, rope, cloth folds
local ROPE = {"#6e5230", "#a88848", "#c8a868", "#e0c888"}
local function grain(x0, y0, x1, y1, ramp, pw, seed)
  local top, bot = y0 + 6, y1 - 12
  for k = floor((x0 + 4) / pw), floor((x1 - 4) / pw) do
    local bx = k * pw
    for i = 0, 1 do   -- long grain streaks, offset per board
      local gx = bx + 2 + floor(hash(k, i, seed) * (pw - 3))
      local gy = top + floor(hash(k, i + 5, seed) * (bot - top) * .6)
      local len = 5 + floor(hash(k, i + 9, seed) * 12)
      for y = gy, min(bot, gy + len) do if gx > x0 + 4 and gx < x1 - 4 then P(gx, y, ramp[3]) end end
      if i == 0 then for y = gy + 1, min(bot, gy + len - 2) do P(gx + 1, y, ramp[5]) end end
    end
    if hash(k, 3, seed) > .62 then   -- a knot with swirling grain
      local kx, ky = bx + 3, top + 6 + floor(hash(k, 4, seed) * (bot - top - 14))
      if kx > x0 + 5 and kx < x1 - 6 then
        c:fillMask(c:ellipse(kx, ky, 1, 2), ramp[2]); P(kx - 1, ky - 1, ramp[5]); P(kx, ky + 1, ramp[1])
        P(kx - 2, ky + 2, ramp[3]); P(kx + 2, ky - 2, ramp[3]); P(kx + 2, ky + 3, ramp[3])
      end
    end
    if bx > x0 + 5 and bx < x1 - 5 then   -- nail heads, one tall, and a dark seam shadow
      P(bx + 2, top, ramp[1]); P(bx + 3, top, ramp[5]); P(bx + 2, bot, ramp[1]); P(bx + 3, bot, ramp[5])
    end
  end
end
local function flagstones(x0, y0, x1, y1, seed)   -- big irregular blocks, chipped corners, hairline cracks, damp moss low down
  local m = rect(x0, y0, x1, y1)
  brick(m, STONE, seed, 11, 6)
  for i = 0, 22 do
    local x, y = x0 + 1 + floor(hash(i, 1, seed + 3) * (x1 - x0 - 3)), y0 + 1 + floor(hash(i, 2, seed + 3) * (y1 - y0 - 3))
    P(x, y, STONE[1]); P(x + 1, y, STONE[2]); P(x - 1, y + 1, STONE[6])   -- chip: dark pit + a bright broken edge
  end
  for i = 0, 5 do
    local x, y = x0 + 4 + floor(hash(i, 4, seed) * (x1 - x0 - 8)), y0 + 2 + floor(hash(i, 5, seed) * (y1 - y0 - 18))
    for k = 0, 6 do P(x + (k // 2) % 2, y + k, STONE[1]) end
  end
  for x = x0, x1 do local h = hash(x, 1, seed + 8); if h > .55 then P(x, y1, GREEN[3]); if h > .8 then P(x, y1 - 1, GREEN[4]); P(x, y1 - 2, LEAF[3]) end end end
  for x = x0, x1, 7 do P(x + floor(hash(x, 2, seed) * 5), y1 - 3, GREEN[2]) end
end
local function room(b, wall, floorR, o)
  o = o or {}
  local x0, y0, x1, y1 = b[1], b[2], b[3], b[4]
  local outer = rect(x0, y0, x1, y1)
  c:rim(outer, TIMB[1])
  S.obj(outer, TIMB, { base = 3 })                      -- timber frame
  local inner = rect(x0 + 4, y0 + 5, x1 - 4, y1 - 5)
  S.planks(inner, wall, { w = o.pw or 7, base = 4, vert = true, seed = o.seed or 1 })
  c:rim(inner, TIMB[1])
  local flo = rect(x0 + 4, y1 - 11, x1 - 4, y1 - 5)     -- floorboards
  S.planks(flo, OAK, { w = 8, base = 3, vert = false, seed = 7 })
  c:fillMask(rect(x0 + 4, y1 - 11, x1 - 4, y1 - 11), OAK[1])
  c:fillMask(rect(x0 - 2, y0 - 3, x1 + 2, y0 + 1), TIMB[5])  -- roof beam
  c:fillMask(rect(x0 - 2, y0 + 1, x1 + 2, y0 + 1), TIMB[2])
  if o.fx then polish(function() o.fx(x0, y0, x1, y1) end) end
  S.glow((x0 + x1) // 2, (y0 + y1) // 2, (x1 - x0) // 2, "#ffd27a", o.glow or .3, {x0 + 4, y0 + 5, x1 - 4, y1 - 5})
  return inner
end
local function lantern(x, y)
  c:fillMask(rect(x, y - 6, x, y - 3), IRON[2])
  local m = rect(x - 2, y - 3, x + 2, y + 2); c:rim(m, IRON[1]); c:fillMask(m, GOLD[5]); c:fillMask(rect(x - 1, y - 1, x + 1, y), GOLD[6])
  S.glow(x, y, 9, "#ffe49a", .4, {x - 9, y - 9, x + 9, y + 9})
end
local function window(x0, y0, x1, y1)
  local m = rect(x0, y0, x1, y1); c:rim(m, TIMB[1]); c:fillMask(m, "#bfe4f6")
  c:fillMask(rect(x0, y0, x1, y0 + 2), "#e4f6ff"); c:fillMask(rect((x0 + x1) // 2, y0, (x0 + x1) // 2, y1), TIMB[3]); c:fillMask(rect(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2), TIMB[3])
end

-- Parlour [92,126,210,196]: sofa, rug, lamp, picture, window
room({92, 126, 210, 196}, CREAM, OAK, { seed = 2, fx = function(a, b, c2, d) grain(a, b, c2, d, CREAM, 7, 81) end })
window(100, 140, 118, 156)
obj(rr(124, 150, 150, 168, 3), PINK, { base = 4 }); obj(rr(120, 160, 128, 178, 2), PINK, { base = 3 }); obj(rr(146, 160, 154, 178, 2), PINK, { base = 3 })  -- sofa
obj(rect(124, 168, 150, 182), PINK, { base = 3 }); obj(rect(126, 182, 130, 184), TIMB, { base = 2 }); obj(rect(144, 182, 148, 184), TIMB, { base = 2 })
obj(rect(158, 176, 196, 183), BARN, { base = 4 })   -- rug
c:fillMask(rect(160, 178, 194, 178), GOLD[5]); c:fillMask(rect(160, 181, 194, 181), GOLD[5])
obj(rect(172, 144, 186, 158), TEAL, { base = 3 }); c:fillMask(rect(174, 146, 184, 156), "#f4d88a")  -- picture
lantern(166, 134)

-- Loft [270,116,390,186]: hay bed, ladder, crates, bunting
room({270, 116, 390, 186}, CREAM, OAK, { seed = 3, pw = 8, fx = function(a, b, c2, d) grain(a, b, c2, d, CREAM, 8, 82) end })
obj(rect(280, 160, 312, 174), "#cc9e40" and GOLD, { base = 4 }); obj(rr(282, 152, 296, 162, 2), ROSE, { base = 4 })  -- bed and pillow
for i = 0, 5 do c:fillMask(rect(316 + i * 4, 126, 316 + i * 4, 172), TIMB[3]) end   -- (rungs drawn below)
obj(rect(316, 126, 318, 174), TIMB, { base = 4 }); obj(rect(334, 126, 336, 174), TIMB, { base = 4 })
for y = 132, 170, 9 do obj(rect(318, y, 334, y + 2), TIMB, { base = 5 }) end   -- ladder
obj(rect(346, 150, 372, 174), OAK, { base = 4 }); obj(rect(350, 138, 368, 150), OAK, { base = 5 }); c:fillMask(rect(346, 160, 372, 160), OAK[2])  -- crates
for i = 0, 6 do local x = 276 + i * 16; local f = poly{{x, 128}, {x + 12, 128}, {x + 6, 138}}; c:rim(f, "#2b1c26"); c:fillMask(f, ({"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8"})[i % 4 + 1]) end
lantern(300, 134)

-- Cellar [196,202,290,264]: barrels, jar shelf, steps
room({196, 202, 290, 264}, STONE, STONE, { seed = 4, glow = .22, fx = function(a, b, c2, d) flagstones(a + 4, b + 5, c2 - 4, d - 12, 83); flagstones(a + 4, d - 10, c2 - 4, d - 6, 87) end })
obj(rr(204, 232, 226, 256, 4), OAK, { base = 3 }); c:fillMask(rect(204, 238, 226, 239), IRON[3]); c:fillMask(rect(204, 250, 226, 251), IRON[3])
obj(rr(230, 238, 250, 256, 4), OAK, { base = 4 }); c:fillMask(rect(230, 243, 250, 244), IRON[3]); c:fillMask(rect(230, 251, 250, 252), IRON[3])
obj(rect(256, 214, 284, 218), TIMB, { base = 4 })
for i = 0, 3 do local x = 258 + i * 7; local j = rect(x, 206, x + 4, 213); c:rim(j, "#2b1c26"); c:fillMask(j, ({"#e8493b", "#f5b82e", "#7cc35a", "#8a6fd0"})[i + 1]); c:fillMask(rect(x, 206, x + 4, 207), CREAM[5]) end
for i = 0, 3 do local x = 258 + i * 7; local j = rect(x, 224, x + 4, 231); c:rim(j, "#2b1c26"); c:fillMask(j, ({"#f5809f", "#5fc4c8", "#f5b82e", "#e8493b"})[i + 1]) end
obj(rect(256, 232, 284, 235), TIMB, { base = 4 }); lantern(264, 246)

-- Puzzle Room [20,202,120,264]: table of jigsaw pieces and a wall of puzzle pictures
room({20, 202, 120, 264}, VIOLET, OAK, { seed = 5, fx = function(a, b, c2, d) grain(a, b, c2, d, VIOLET, 7, 84) end })
local cols = {"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8", "#8a6fd0", "#f5809f"}
for gy = 0, 2 do for gx = 0, 3 do   -- a jigsaw on the wall
  local x, y = 32 + gx * 9, 212 + gy * 9
  c:fillMask(rect(x, y, x + 7, y + 7), cols[(gx + gy * 2) % 6 + 1]); c:fillMask(rect(x, y, x + 7, y), "#fff4d6"); c:fillMask(rect(x + 7, y + 3, x + 8, y + 5), cols[(gx + gy * 2 + 1) % 6 + 1])
end end
c:rim(rect(32, 212, 67, 238), "#2b1c26")
obj(rect(72, 238, 112, 244), OAK, { base = 4 }); obj(rect(76, 244, 80, 256), TIMB, { base = 3 }); obj(rect(104, 244, 108, 256), TIMB, { base = 3 })  -- table
for i = 0, 4 do c:fillMask(rect(76 + i * 7, 233, 80 + i * 7, 237), cols[i % 6 + 1]); c:fillMask(rect(76 + i * 7, 233, 80 + i * 7, 233), "#fff4d6") end
lantern(94, 214)

-- Contest Hall [214,78,268,122]: trophy shelf
room({214, 78, 268, 122}, CREAM, OAK, { seed = 6, pw = 6, fx = function(a, b, c2, d) grain(a, b, c2, d, CREAM, 6, 85) end })
obj(rect(220, 108, 262, 111), TIMB, { base = 4 }); obj(rect(220, 94, 262, 96), TIMB, { base = 4 })
local function cup(x, y, g)
  local bowl = poly{{x, y}, {x + 8, y}, {x + 6, y + 6}, {x + 2, y + 6}}; c:rim(bowl, "#2b1c26"); c:fillMask(bowl, GOLD[g]); c:fillMask(rect(x + 1, y, x + 2, y + 3), GOLD[6])
  c:fillMask(rect(x + 3, y + 6, x + 5, y + 8), GOLD[3]); c:fillMask(rect(x + 1, y + 8, x + 7, y + 9), GOLD[2])
end
cup(224, 99, 4); cup(238, 99, 5); cup(252, 99, 4); cup(226, 85, 5); cup(246, 85, 4)
for i = 0, 2 do local d = S.diamond(228 + i * 14, 105, 3); c:rim(d, "#2b1c26"); c:fillMask(d, ({"#e8493b", "#5fc4c8", "#f5809f"})[i + 1]) end

-- Pal Book nook [412,72,470,130]: bookshelf
room({412, 72, 470, 130}, OAK, OAK, { seed = 8, pw = 5, fx = function(a, b, c2, d) grain(a, b, c2, d, OAK, 5, 86) end })
for shelf = 0, 2 do
  local y = 80 + shelf * 17
  obj(rect(418, y + 13, 464, y + 15), TIMB, { base = 3 })
  local x = 419
  while x < 462 do
    local w = 3 + floor(hash(x, y, 2) * 3); local h = 9 + floor(hash(x, y, 3) * 4)
    c:rim(rect(x, y + 13 - h, x + w, y + 12), "#2b1c26"); c:fillMask(rect(x, y + 13 - h, x + w, y + 12), cols[floor(hash(x, y, 4) * 6) + 1]); c:fillMask(rect(x, y + 13 - h, x, y + 12), "#fff4d6")
    x = x + w + 2
  end
end

-- Cat Fish nook [336,188,420,216]: hammock, rod, bowl
room({336, 188, 420, 216}, TEAL, OAK, { seed = 9, fx = function(a, b, c2, d) grain(a, b, c2, d, TEAL, 7, 88) end })
local ham = poly{{346, 198}, {372, 198}, {366, 206}, {352, 206}}; c:rim(ham, "#2b1c26"); c:fillMask(ham, ROSE[4]); c:fillMask(rect(350, 198, 368, 199), ROSE[5])

---------------------------------------------------------------- polish pass 2: what each room is for
local INK = "#2b1c26"
local function flame(cx, base, h, w)   -- layered tongues: dark orange, orange, yellow core
  for i, t in ipairs{ {cx - w // 2, h * .7, w * .6}, {cx, h, w}, {cx + w // 2, h * .6, w * .6} } do
    local x, hh, ww = t[1], floor(t[2]), floor(t[3])
    local m = poly{ {x - ww // 2, base}, {x - ww // 3, base - hh * .5}, {x + (i - 2), base - hh}, {x + ww // 3, base - hh * .5}, {x + ww // 2, base} }
    c:fillMask(m, "#d8482e"); c:fillMask(m:shrink(1), "#f58a30"); c:fillMask(m:shrink(2), "#fcd458")
    if hh > 6 then c:fillMask(m:shrink(3), "#fff0b0") end
  end
end
local function rosette(cx, cy, r, ribbon, mid)
  for _, d in ipairs{ -2, 2 } do
    local t = poly{ {cx + d - 2, cy + 1}, {cx + d + 2, cy + 1}, {cx + d * 2 + 2, cy + r + 4}, {cx + d * 2 - 1, cy + r + 2}, {cx + d * 2 - 3, cy + r + 4} }
    c:rim(t, INK); c:fillMask(t, ribbon[3])
  end
  local m = c:ellipse(cx, cy, r, r); c:rim(m, INK); c:fillMask(m, ribbon[4])
  c:fillMask(m:shrink(1), ribbon[3])   -- pleated ring
  for a = 0, 11 do local ang = a * .5236; P(floor(cx + (r - 1) * math.cos(ang) + .5), floor(cy + (r - 1) * math.sin(ang) + .5), a % 2 == 0 and ribbon[5] or ribbon[2]) end
  c:fillMask(c:ellipse(cx, cy, max(1, r - 3), max(1, r - 3)), mid); P(cx - 1, cy - 1, GOLD[6])
end
polish(function()
  ---------------------------------------------------------- Parlour: hearth, armchair, rug
  local br = rect(192, 131, 205, 148); c:rim(br, INK); brick(br, STONE, 61)
  local mantel = rect(187, 147, 206, 150); c:rim(mantel, INK); S.obj(mantel, TIMB, { base = 4, lit = 1, shade = 1 })
  local sur = rect(189, 151, 206, 185); c:rim(sur, INK); brick(sur, STONE, 62)
  local fb = rr(194, 160, 203, 185, 4); fb:clip(rect(194, 160, 203, 185)); c:rim(fb, INK); c:fillMask(fb, IRON[1])
  c:fillMask(fb:shrink(1):clip(rect(194, 166, 203, 185)), BARN[1]); c:fillMask(fb:shrink(2):clip(rect(194, 172, 203, 185)), BARN[3])
  for lx = 0, 8 do c:fillMask(rect(194 + lx, 180, 194 + lx, 180), hash(lx, 1, 63) > .5 and "#f58a30" or "#d8482e") end
  flame(199, 181, 14, 7)
  local log1 = rect(194, 181, 203, 184); c:rim(log1, INK); c:fillMask(log1, TIMB[3]); c:fillMask(rect(194, 181, 203, 181), BARN[5]); c:fillMask(rect(195, 183, 202, 184), TIMB[1])
  c:fillMask(rect(194, 182, 195, 183), TIMB[5])
  c:fillMask(rect(187, 185, 206, 186), STONE[5]); c:fillMask(rect(187, 187, 206, 187), STONE[2])   -- hearth slab
  c:fillMask(rect(189, 150, 206, 150), STONE[5])
  -- armchair: tufting, piping, cushion seam, roll arms
  for _, b in ipairs{ {131, 156}, {137, 156}, {143, 156}, {134, 161}, {140, 161} } do P(b[1], b[2], PINK[2]); P(b[1] - 1, b[2] - 1, PINK[6]) end
  c:fillMask(rect(129, 165, 145, 165), PINK[2]); c:fillMask(rect(129, 164, 145, 164), PINK[5])
  c:fillMask(rect(128, 172, 146, 172), PINK[2]); c:fillMask(rect(128, 173, 146, 173), PINK[5]); c:fillMask(rect(128, 180, 146, 180), PINK[2])
  c:fillMask(rect(147, 162, 153, 162), PINK[5]); c:fillMask(rect(121, 162, 127, 162), PINK[5])
  c:fillMask(rect(126, 151, 148, 151), PINK[6])
  c:fillMask(rect(124, 169, 124, 181), PINK[5])
  -- rug: fringe + gold lozenges (right half, away from the perch)
  for fy = 177, 182, 2 do P(157, fy, GOLD[5]); P(197, fy, GOLD[5]) end
  for lx = 0, 2 do local d = S.diamond(184 + lx * 4, 179, 2); c:fillMask(d, BARN[2]); P(184 + lx * 4, 179, GOLD[5]) end
  c:fillMask(rect(158, 183, 196, 183), BARN[2])

  ---------------------------------------------------------- Loft: upper bunk over the hay bed, a porthole-window
  for _, px in ipairs{ 279, 312 } do local post = rect(px, 140, px + 1, 160); c:rim(post, INK); c:fillMask(post, TIMB[4]); c:fillMask(rect(px, 140, px, 160), TIMB[5]) end
  local rail = rect(277, 150, 315, 152); c:rim(rail, INK); c:fillMask(rail, TIMB[3]); c:fillMask(rect(277, 150, 315, 150), TIMB[5]); c:fillMask(rect(277, 152, 315, 152), TIMB[1])
  local mat = rect(281, 144, 311, 149); c:rim(mat, INK); c:fillMask(mat, TEAL[4]); c:fillMask(rect(281, 144, 311, 144), TEAL[6])
  for sx = 285, 309, 6 do c:fillMask(rect(sx, 145, sx, 149), TEAL[3]) end   -- quilt stitching
  local pil = rr(282, 141, 291, 145, 2); c:rim(pil, INK); c:fillMask(pil, ROSE[5]); c:fillMask(rect(283, 141, 288, 141), ROSE[6])
  local bl = rect(292, 146, 311, 149); c:fillMask(bl, VIOLET[4]); c:fillMask(rect(292, 146, 311, 146), VIOLET[6]); c:fillMask(rect(292, 149, 311, 149), VIOLET[2])
  c:fillMask(rect(279, 159, 280, 160), TIMB[2])
  -- hay bed: straw strands and a plaid blanket
  for i = 0, 22 do local hx, hy = 281 + floor(hash(i, 1, 64) * 30), 161 + floor(hash(i, 2, 64) * 12); P(hx, hy, GOLD[6]); P(hx + 1, hy + 1, GOLD[6]) end
  for gx = 298, 310, 4 do c:fillMask(rect(gx, 160, gx + 1, 173), ROSE[4]) end; c:fillMask(rect(298, 166, 311, 167), ROSE[4])
  -- window (drawn before the bunting is hung over it)
  local wm = rr(342, 122, 366, 140, 4); wm:clip(rect(342, 122, 366, 140)); c:rim(wm, INK); c:fillMask(wm, "#bfe4f6")
  c:fillMask(rect(342, 122, 366, 126), "#e4f6ff"); c:fillMask(wm:clip(rect(342, 135, 366, 140)), "#98c8ec")
  c:fillMask(rect(353, 122, 354, 140), TIMB[3]); c:fillMask(rect(342, 131, 366, 131), TIMB[3])
  c:fillMask(rect(343, 122, 343, 140), TIMB[5]); c:fillMask(rect(344, 124, 349, 125), "#f8f0e0"); c:fillMask(rect(358, 127, 363, 128), "#f8f0e0")
  c:fillMask(rect(340, 141, 368, 143), TIMB[4]); c:fillMask(rect(340, 143, 368, 143), TIMB[2]); c:fillMask(rect(340, 141, 368, 141), TIMB[6])
  for i = 0, 6 do local x = 276 + i * 16; local f = poly{{x, 128}, {x + 12, 128}, {x + 6, 138}}; c:rim(f, INK); c:fillMask(f, ({"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8"})[i % 4 + 1]) end
  -- crates: slats and nails
  for _, cr in ipairs{ {346, 150, 372, 174}, {350, 138, 368, 150} } do
    c:fillMask(rect(cr[1], cr[2] + 5, cr[3], cr[2] + 5), OAK[2]); c:fillMask(rect(cr[1], cr[4] - 5, cr[3], cr[4] - 5), OAK[2])
    P(cr[1] + 2, cr[2] + 2, IRON[5]); P(cr[3] - 2, cr[2] + 2, IRON[5])
  end

  ---------------------------------------------------------- Cellar: barrels, clay jars, a hanging string of onions
  for _, bb in ipairs{ {204, 232, 226, 256, 3}, {230, 238, 250, 256, 4} } do
    local cx = (bb[1] + bb[3]) // 2
    for y = bb[2] + 2, bb[4] - 2 do   -- stave lines
      for _, dx in ipairs{ -6, -2, 3, 7 } do if hash(cx + dx, y // 4, 65) > .15 then P(cx + dx, y, OAK[bb[5] - 1]) end end
    end
    P(cx, bb[2] + (bb[4] - bb[2]) // 2, IRON[2]); P(cx - 1, bb[2] + (bb[4] - bb[2]) // 2 - 1, IRON[6])
    c:fillMask(rect(bb[1] + 2, bb[2] + 1, bb[1] + 4, bb[2] + 1), OAK[6])
  end
  local tap = rect(239, 248, 243, 250); c:rim(tap, INK); c:fillMask(tap, IRON[4]); P(242, 251, "#d8482e"); P(242, 252, "#d8482e")  -- spigot on the right barrel
  local lid = rr(210, 222, 224, 231, 2); c:rim(lid, INK); S.obj(lid, OAK, { base = 5, lit = 2, shade = 2 }); c:fillMask(rect(210, 226, 224, 226), IRON[3])   -- small cask on top
  for _, jj in ipairs{ {268, 238, 279, 253, "#b6643a"}, {260, 244, 267, 253, "#cc8458"} } do   -- clay jars with a rim and a band of paint
    local m = rr(jj[1], jj[2], jj[3], jj[4], 3); c:rim(m, INK); c:fillMask(m, jj[5])
    c:fillMask(rect(jj[1] + 1, jj[2] + 1, jj[1] + 2, jj[4] - 2), "#e0a074"); c:fillMask(rect(jj[3] - 1, jj[2] + 2, jj[3], jj[4]), "#7e3c28")
    c:fillMask(rect(jj[1] + 1, jj[2] + 4, jj[3] - 1, jj[2] + 4), "#2b1c26"):fillMask(rect(jj[1] + 2, jj[2] + 5, jj[3] - 2, jj[2] + 5), CREAM[4])
    c:fillMask(rect(jj[1] + 1, jj[2] - 1, jj[3] - 1, jj[2]), jj[5])
  end
  for i = 0, 5 do local ox, oy = 232 + floor(sin(i * 1.7) * 2), 208 + i * 4; local o = c:ellipse(ox, oy, 2, 2); c:rim(o, INK); c:fillMask(o, i % 2 == 0 and "#e0b86a" or "#cc8a58") end   -- onion string
  c:fillMask(rect(232, 205, 232, 207), TIMB[2])

  ---------------------------------------------------------- Puzzle room: wall jigsaw missing pieces, table jigsaw half done, loose pieces
  local missing = { {1, 0}, {2, 1}, {0, 2}, {3, 2}, {1, 2} }
  for _, mm in ipairs(missing) do
    local x, y = 32 + mm[1] * 9, 212 + mm[2] * 9
    c:fillMask(rect(x, y, x + 8, y + 7), VIOLET[3]); c:fillMask(rect(x, y + 7, x + 8, y + 7), VIOLET[2]); c:fillMask(rect(x, y, x, y + 7), VIOLET[2])
  end
  c:rim(rect(31, 211, 68, 239), INK)
  local board = rect(82, 230, 108, 237); c:rim(board, INK); c:fillMask(board, CREAM[3])
  for gy = 0, 1 do for gx = 0, 5 do
    local x, y = 83 + gx * 4, 231 + gy * 3
    if gx < 3 or (gx == 3 and gy == 0) or (gx == 4 and gy == 1 and false) then
      c:fillMask(rect(x, y, x + 3, y + 2), cols[(gx + gy * 2) % 6 + 1]); c:fillMask(rect(x, y, x + 3, y), "#fff4d6")
      P(x + 3, y + 1, cols[(gx + gy * 2 + 1) % 6 + 1])
    else c:fillMask(rect(x, y, x + 3, y + 2), (gx + gy) % 2 == 0 and CREAM[4] or CREAM[3]) end
  end end
  for _, lp in ipairs{ {100, 252}, {106, 254}, {44, 252}, {52, 255}, {30, 254} } do c:fillMask(rect(lp[1], lp[2], lp[1] + 3, lp[2] + 2), cols[(lp[1] + lp[2]) % 6 + 1]); P(lp[1] + 4, lp[2] + 1, cols[(lp[1] + lp[2] + 1) % 6 + 1]) end
  local bx = rect(50, 244, 64, 252); c:rim(bx, INK); S.obj(bx, TIMB, { base = 5, lit = 1, shade = 2 }); c:fillMask(rect(52, 245, 62, 245), TIMB[2])   -- the piece box
  for i = 0, 3 do c:fillMask(rect(52 + i * 3, 242, 53 + i * 3, 243), cols[(i * 2) % 6 + 1]) end

  ---------------------------------------------------------- Contest hall: rosettes and a trophy plaque on the shelf wall
  rosette(240, 88, 4, GOLD, "#e8493b")
  rosette(259, 89, 3, TEAL, GOLD[5])

  ---------------------------------------------------------- Pal book nook: spines banded and tooled, leaners and a plant
  local palc = {"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8", "#8a6fd0", "#f5809f"}
  for shelf = 0, 2 do
    local y = 80 + shelf * 17
    local x = 419
    while x < 462 do
      local w = 3 + floor(hash(x, y, 2) * 3); local h = 9 + floor(hash(x, y, 3) * 4)
      local top = y + 13 - h
      local kind = floor(hash(x, y, 71) * 4)
      c:fillMask(rect(x + w, top + 1, x + w, y + 12), kind == 0 and BARN[3] or kind == 1 and VIOLET[3] or kind == 2 and TEAL[3] or GREEN[3])   -- shaded back edge
      c:fillMask(rect(x + 1, top + 2, x + w - 1, top + 2), GOLD[5]); c:fillMask(rect(x + 1, y + 9, x + w - 1, y + 9), GOLD[5])
      if hash(x, y, 72) > .55 then c:fillMask(rect(x + 1, top + 5, x + w - 1, top + 6), CREAM[5]) end
      if h < 11 then c:fillMask(rect(x + 1, top, x + w - 1, top), CREAM[5]) end
      x = x + w + 2
    end
  end
  for _, sp in ipairs{ {465, 84}, {465, 101} } do   -- leaning book + bookend
    local lb = poly{{sp[1] - 4, sp[2] + 9}, {sp[1] - 1, sp[2] + 9}, {sp[1] + 1, sp[2] + 1}, {sp[1] - 2, sp[2] + 1}}
  end
  local pot = rect(459, 116, 464, 120); c:rim(pot, INK); c:fillMask(pot, "#b6643a")
  for i, l in ipairs{ {458, 112}, {461, 110}, {464, 112}, {460, 114}, {463, 114} } do c:fillMask(rect(l[1], l[2], l[1] + 1, l[2] + 3), i % 2 == 0 and GREEN[4] or GREEN[5]) end

  ---------------------------------------------------------- Cat Fish nook: aquarium with a fish silhouette, weed, bubbles
  local tank = rect(378, 194, 412, 209); c:rim(tank, INK); c:fillMask(tank, "#7cc8dc")
  c:fillMask(rect(378, 194, 412, 196), "#a8e0ec"); c:fillMask(rect(378, 200, 412, 203), "#6cb8d0"); c:fillMask(rect(378, 204, 412, 209), "#5aa4c0")
  for x = 378, 412 do if x % 2 == 0 then P(x, 197, "#b8e8f2") end end
  c:fillMask(rect(378, 207, 412, 209), DIRT[5]); c:fillMask(rect(378, 207, 412, 207), DIRT[6] or "#e8c878"); for x = 379, 411, 3 do P(x, 208, DIRT[3]) end
  local fish = poly{ {388, 202}, {393, 199}, {399, 199}, {403, 202}, {399, 205}, {393, 205} }
  c:fillMask(fish, "#e8742e"); c:fillMask(fish:clip(rect(388, 199, 403, 200)), "#f5a04a"); c:fillMask(fish:clip(rect(388, 204, 403, 205)), "#c05024")
  local tail = poly{ {403, 202}, {408, 198}, {408, 206} }; c:fillMask(tail, "#f5a04a"); c:fillMask(rect(406, 201, 408, 203), "#e8742e")
  c:fillMask(rect(396, 199, 397, 205), "#fff4d6"); P(390, 201, INK); c:fillMask(rect(394, 197, 397, 198), "#e8742e")   -- fin
  P(389, 203, "#c05024")
  for _, wd in ipairs{ {382, 207}, {384, 207}, {408, 207} } do for k = 0, 6 do P(wd[1] + (k % 2), wd[2] - k, k % 3 == 0 and GREEN[5] or GREEN[4]) end end
  for _, bb in ipairs{ {385, 197}, {386, 195} , {409, 199}} do local b = c:ellipse(bb[1], bb[2], 1, 1); c:fillMask(b, "#e4f6ff") end
  c:fillMask(rect(379, 195, 379, 205), "#e4f6ff"); c:fillMask(rect(380, 195, 380, 198), "#e4f6ff")  -- glass glint
  local stand = rect(376, 210, 414, 211); c:rim(stand, INK); c:fillMask(stand, TIMB[3])
  -- the hammock gets a rope + knots; hook holds a fish-shaped plaque? (no) -- a rod leaning on the wall instead
  c:line({{374, 198}, {374, 209}}, 1):each(function(x, y) P(x, y, TIMB[4]) end); P(374, 209, "#e8493b")
end)

---------------------------------------------------------------- Yard door [4,124,72,190]: a big root-gate with a hanging sign (no text)
local post = rect(4, 128, 72, 190)
c:rim(post, TIMB[1]); S.planks(post, TIMB, { w = 7, base = 3, seed = 11 })
local arch = rr(16, 140, 60, 190, 14); c:rim(arch, TIMB[1]); S.planks(arch, OAK, { w = 5, base = 4, seed = 12 })
c:fillMask(rect(37, 140, 38, 190), OAK[1]); obj(rect(48, 164, 52, 168), GOLD, { base = 4 })
local sign = rect(18, 130, 58, 138); c:rim(sign, "#2b1c26"); c:fillMask(sign, GREEN[4]); c:fillMask(rect(18, 130, 58, 131), GREEN[5])
for i = 0, 3 do c:fillMask(rect(24 + i * 9, 133, 28 + i * 9, 135), "#fff4d6") end

---------------------------------------------------------------- ledges at the 24 perches (feet = perch y + 10)
local perches = {{60,60},{120,40},{180,58},{240,36},{300,58},{360,40},{420,62},{40,118},{96,100},{160,104},{220,96},{280,100},{340,98},{400,104},{450,120},{50,176},{110,170},{170,178},{230,172},{290,176},{350,170},{410,178},{70,236},{350,246}}
for i, p in ipairs(perches) do
  local x, y = p[1], p[2] + 11
  local m = rect(x - 16, y, x + 16, y + 3)
  c:rim(m, TIMB[1]); S.planks(m, OAK, { w = 8, base = 4, vert = true, seed = i })
  c:fillMask(rect(x - 16, y, x + 16, y), OAK[6])
  c:fillMask(rect(x - 10, y + 4, x - 8, y + 7), TIMB[3]); c:fillMask(rect(x + 8, y + 4, x + 10, y + 7), TIMB[3])
end

---------------------------------------------------------------- polish pass 3: material cues
polish(function()
  -- parlour window: gathered curtains with tie-backs (cloth folds), rod and sill
  c:fillMask(rect(97, 138, 121, 139), TIMB[2]); c:fillMask(rect(97, 138, 121, 138), TIMB[5]); P(96, 138, GOLD[5]); P(122, 138, GOLD[5])
  for side = 0, 1 do
    local x0 = side == 0 and 100 or 114
    for x = x0, x0 + 4 do for y = 140, 157 do
      local tone = ((x - x0) % 3 == 0) and ROSE[5] or ((x - x0) % 3 == 1) and ROSE[3] or ROSE[4]
      if y > 148 then tone = ((x - x0) % 2 == 0) and ROSE[3] or ROSE[2] end   -- folds fan out below the tie
      P(x, y, tone)
    end end
    c:fillMask(rect(x0, 148, x0 + 4, 149), GOLD[4]); c:fillMask(rect(x0, 148, x0 + 4, 148), GOLD[6])
    for x = x0, x0 + 4 do P(x, 158, (x % 2 == 0) and ROSE[2] or ROSE[1]) end
  end
  c:fillMask(rect(99, 158, 119, 159), TIMB[4]); c:fillMask(rect(99, 159, 119, 159), TIMB[2]); c:fillMask(rect(99, 158, 119, 158), TIMB[6])
  -- loft ladder: rope lashings on every rung, a coil of rope on the floor
  for y = 132, 170, 9 do
    for _, rx in ipairs{ 316, 334 } do
      for k = 0, 4 do P(rx + (k % 3), y - 1 + k, k % 2 == 0 and ROPE[2] or ROPE[3]) end
      P(rx, y + 4, ROPE[1]); P(rx + 2, y - 1, ROPE[4])
    end
  end
  for r = 0, 2 do c:fillMask(c:ellipse(326, 178 - r, 6 - r, 2):cut(c:ellipse(326, 178 - r, 4 - r, 0)), r == 0 and ROPE[2] or r == 1 and ROPE[3] or ROPE[4]) end
  c:rim(c:ellipse(326, 178, 6, 2), INK); c:fillMask(c:ellipse(326, 178, 6, 2):cut(c:ellipse(326, 178, 3, 1)), ROPE[2])
  for k = -5, 5 do P(326 + k, 178 + (k % 2), (k % 2 == 0) and ROPE[3] or ROPE[1]) end
  P(332, 176, ROPE[3]); P(333, 175, ROPE[2]); P(334, 177, ROPE[1])
  -- upper bunk blanket: diagonal fold shadows; hay bed: strap
  for i = 0, 4 do for k = 0, 3 do P(294 + i * 4 + k // 2, 146 + k, VIOLET[3]) end end
  c:fillMask(rect(281, 158, 311, 158), TIMB[3])
  -- cellar: rust bleeding from the hoops and nails, a seeping drip stain under the shelf
  for _, hy in ipairs{ 238, 250, 243, 251 } do
    for x = 204, 250 do if hash(x, hy, 90) > .78 and c:get(x, hy) == IRON[3]:lower() then P(x, hy, "#a8583a"); if hash(x, hy, 91) > .6 then P(x, hy + 1, "#7e3c28") end end end
  end
  for y = 215, 222 do P(270, y, STONE[2]); if y % 2 == 0 then P(271, y, STONE[2]) end end
  P(270, 223, "#5fa4c8"); P(270, 224, "#a8d8ec")
  -- contests: tarnish and polish on the cups, a swag of braided rope along the shelf front
  for x = 221, 262 do P(x, 112, (x % 3 == 0) and ROPE[3] or ROPE[2]) end
  -- puzzle room table: grain + a coffee ring-free chip; chair? only grain
  for x = 74, 110 do if hash(x, 1, 92) > .72 then P(x, 241, OAK[3]) end end
  c:fillMask(rect(72, 238, 112, 238), OAK[5])
  -- books: shelf boards with grain, a ribbon bookmark dangling out of a spine
  for shelf = 0, 2 do
    local y = 80 + shelf * 17
    c:fillMask(rect(418, y + 13, 464, y + 13), TIMB[5]); c:fillMask(rect(418, y + 15, 464, y + 15), TIMB[1])
    for x = 420, 462 do if hash(x, y, 93) > .8 then P(x, y + 14, TIMB[4]) end end
  end
  for k = 0, 4 do P(431, 93 + k - 1, k % 2 == 0 and "#e8493b" or "#b0322c") end; P(431, 96, "#e8493b"); P(432, 96, "#b0322c")
  -- catfish: hammock ropes from the wall hooks, fold lines in the cloth, rusty rim on the tank stand
  for k = 0, 5 do P(344 + k // 2, 194 + k, ROPE[2 + k % 2]); P(374 - k // 2, 194 + k, ROPE[2 + k % 2]) end
  P(344, 193, IRON[3]); P(374, 193, IRON[3])
  for i = 0, 4 do P(352 + i * 3, 199 + (i % 2), ROSE[3]); P(353 + i * 3, 201, ROSE[3]); P(355 + i * 2, 203, ROSE[3]) end
  for x = 377, 413 do if hash(x, 1, 94) > .8 then P(x, 210, "#a8583a") end end
  -- yard door: iron straps, rivets, rust, a rope pull, lichen over the lintel
  for _, sy in ipairs{ 150, 178 } do
    c:fillMask(rect(16, sy, 59, sy + 2), IRON[2]); c:fillMask(rect(16, sy, 59, sy), IRON[4]); c:fillMask(rect(16, sy + 2, 59, sy + 2), IRON[1])
    for x = 19, 57, 6 do P(x, sy + 1, IRON[6]) end
    for x = 17, 58 do if hash(x, sy, 95) > .82 then P(x, sy + 1, "#a8583a"); P(x, sy + 2, "#7e3c28") end end
  end
  c:fillMask(rect(37, 140, 38, 190), OAK[1])
  for k = 0, 9 do P(44, 166 + k, (k % 2 == 0) and ROPE[2] or ROPE[3]) end; c:fillMask(c:ellipse(44, 177, 1, 1), ROPE[3])
  for x = 6, 70 do local h = hash(x, 1, 96); if h > .5 then P(x, 127, GREEN[3]); if h > .75 then P(x, 126, GREEN[4]) end end end
  -- north-side moss on the roof beams, a bit more on the left room edges
  for _, b in ipairs{ {92, 126}, {214, 78}, {412, 72}, {20, 202}, {270, 116}, {196, 202}, {336, 188} } do
    for k = 0, 9 do
      local h = hash(k, b[1], 97)
      if h > .35 then P(b[1] - 2 + k, b[2] - 4, k < 5 and GREEN[3] or GREEN[2]); if h > .6 and k < 6 then P(b[1] - 2 + k, b[2] - 5, GREEN[4]) end end
    end
    for k = 0, 8 do if hash(k, b[2], 98) > .45 then P(b[1] - 1, b[2] + k, GREEN[3]); P(b[1], b[2] + k + 1, GREEN[2]) end end
  end
  -- ledges: nail heads, wear and a split in the middle board
  for i, p in ipairs(PAL) do
    if i <= 24 then
      local x, y = p[1], p[2] + 11
      P(x - 14, y + 1, IRON[2]); P(x + 14, y + 1, IRON[2]); P(x - 13, y + 1, IRON[5]); P(x + 13, y + 1, IRON[5])
      if hash(i, 1, 99) > .4 then local sx = x - 6 + floor(hash(i, 2, 99) * 12); P(sx, y + 1, OAK[1]); P(sx, y + 2, OAK[2]) end
      if hash(i, 3, 99) > .55 then P(x - 16 + floor(hash(i, 4, 99) * 30), y - 1, GREEN[3]); P(x - 16 + floor(hash(i, 5, 99) * 30), y, GREEN[4]) end
    end
  end
end)

---------------------------------------------------------------- polish pass 4: light and depth (key light top-left, shadows fall bottom-right)
local function mixc(h1, h2, t)
  local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
  local r1, g1, b1 = rgb(h1); local r2, g2, b2 = rgb(h2)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
end
-- tint the pixels of a mask toward col; the rim of the mask is only half filled (checker) so the edge steps instead of fading
local function tint(m, col, a, filter)
  local e = m:edge()
  m:each(function(x, y)
    local cur = c:get(x, y)
    if cur and (not filter or filter(cur, x, y)) and (not e:has(x, y) or (x + y) % 2 == 0) then c:put(x, y, mixc(cur, col, a)) end
  end)
end
local function shadow(m, a) tint(m, "#3a1c3c", a or .32) end
local function shaft(pts, a) local m = poly(pts); tint(m:shrink(1), "#ffe49a", a); tint(m, "#ffe49a", a * .5) end
polish(function()
  -- light shafts from the windows (warm, striped edges), a cool slit of daylight in the cellar
  shaft({{101, 143}, {118, 143}, {152, 185}, {131, 185}}, .22)
  shaft({{343, 142}, {366, 142}, {386, 175}, {360, 175}}, .16)
  local grate = rect(206, 208, 217, 214); c:rim(grate, INK); c:fillMask(grate, "#bfe4f6"); c:fillMask(rect(206, 208, 217, 209), "#e4f6ff")
  for x = 208, 216, 3 do c:fillMask(rect(x, 208, x, 214), IRON[2]) end
  shaft({{206, 216}, {217, 216}, {238, 252}, {226, 252}}, .10)
  -- hearth glow on the walls, rug and chair; aquarium glow, cool, on the left wall
  S.glow(192, 174, 26, "#ff9a40", .5, {96, 131, 188, 191})
  S.glow(396, 202, 18, "#8ad8f0", .30, {340, 193, 376, 211})
  S.glow(240, 100, 22, "#ffe49a", .12, {218, 83, 264, 117})
  -- cast shadows, always down and to the right
  shadow(rect(155, 156, 159, 184)); shadow(rect(124, 185, 160, 187)); shadow(rect(190, 151, 206, 152), .4); shadow(rect(184, 188, 206, 190), .25)
  shadow(rect(373, 152, 380, 176)); shadow(rect(348, 175, 382, 178)); shadow(rect(313, 162, 316, 174)); shadow(rect(281, 153, 311, 155), .4); shadow(rect(337, 126, 340, 172), .25)
  shadow(rect(227, 238, 229, 254)); shadow(rect(251, 244, 255, 254)); shadow(rect(280, 240, 284, 253)); shadow(rect(206, 255, 262, 258), .25)
  shadow(rect(221, 97, 262, 98), .35); shadow(rect(221, 112, 262, 113), .35)
  for shelf = 0, 2 do shadow(rect(419, 96 + shelf * 17, 464, 97 + shelf * 17), .35) end
  shadow(rect(74, 245, 114, 247)); shadow(rect(66, 253, 80, 255), .25); shadow(rect(413, 195, 415, 210), .3)
  local function onTrunk(h, x, y) return trunk:has(x, y) end
  tint(rect(190, 200, 214, 207), "#3a1c3c", .38, onTrunk); tint(rect(268, 190, 296, 198), "#3a1c3c", .38, onTrunk); tint(rect(212, 124, 270, 130), "#3a1c3c", .4, onTrunk)
  tint(rect(186, 76, 298, 84), "#1c3434", .4, onTrunk); tint(rect(186, 85, 298, 88), "#1c3434", .22, onTrunk)
  tint(rect(150, 216, 182, 222), "#3a1c3c", .18, onTrunk)
  tint(c:ellipse(322, 262, 34, 6), "#1c3434", .30, function(h) return isGreen(h) or h == DIRT[3]:lower() end)
  tint(c:ellipse(120, 266, 8, 3), "#1c3434", .30, function(h) return isGreen(h) end)
  for i, p in ipairs(PAL) do if i <= 24 then tint(rect(p[1] - 14, p[2] + 15, p[1] + 18, p[2] + 17), "#2a1a22", .3, function(h, x, y) return not isGreen(h) or true end) end end
  -- sun glints on the upper-left of the canopy, rim light on timber frames
  for i = 0, 80 do local x, y = floor(hash(i, 1, 100) * 460), floor(hash(i, 2, 100) * 90); if c:get(x, y) == LEAF[5]:lower() or c:get(x, y) == LEAF[4]:lower() then P(x, y, "#e8e48a"); P(x + 1, y, LEAF[6]) end end
  for _, b in ipairs{ {92, 126}, {270, 116}, {412, 72}, {20, 202}, {196, 202}, {336, 188}, {214, 78} } do c:fillMask(rect(b[1] - 2, b[2] - 3, b[1] + 6, b[2] - 3), TIMB[6]) end
  ---------------------------------------------------------- plant kinds beyond grass: ferns, toadstools, lavender, sunflowers, ivy
  local function fern(x, y, h)
    for k = 0, h do
      local fx = x + floor(sin(k / 5) * 2); P(fx, y - k, GREEN[3])
      local w = floor((h - k) / 3) + (k > 1 and 1 or 0)
      for d = 1, min(w, 5) do P(fx - d, y - k + floor(d / 2) + 1, (d % 2 == 0) and GREEN[4] or GREEN[5]); P(fx + d, y - k + floor(d / 2) + 1, (d % 2 == 0) and GREEN[3] or GREEN[2]) end
    end
  end
  fern(127, 258, 12); fern(133, 262, 8); fern(332, 240, 10); fern(326, 246, 7); fern(7, 232, 9)
  local function toad(x, y, r, cap)
    c:fillMask(rect(x, y, x + 1, y + 2), CREAM[5]); c:fillMask(rect(x - r, y - 2, x + 1 + r, y - 1), cap); c:fillMask(rect(x - r + 1, y - 3, x + r, y - 3), cap)
    P(x - 1, y - 2, CREAM[6]); P(x + 1, y - 3, CREAM[6]); P(x + r, y - 1, "#7a2a30")
  end
  toad(146, 249, 2, "#e8493b"); toad(152, 253, 1, "#e8493b"); toad(336, 252, 2, "#f5809f"); toad(228, 254, 2, "#cc8458")
  for i = 0, 4 do local x = 5 + i * 3; local h = 9 + (i * 5) % 4; for k = 0, h do P(x + floor(i % 2), 252 - k, k > h - 5 and "#a98ae0" or GREEN[3]) end; P(x, 252 - h - 1, "#c8b8ec") end
  for _, sf in ipairs{ {432, 215, 14}, {450, 212, 11}, {468, 216, 15} } do
    local x, y, h = sf[1], sf[2], sf[3]
    for k = 0, h do P(x, y - k, GREEN[3]) end
    P(x - 1, y - 4, GREEN[4]); P(x - 2, y - 5, GREEN[5]); P(x + 1, y - 7, GREEN[4]); P(x + 2, y - 8, GREEN[5])
    local hd = c:ellipse(x, y - h - 2, 3, 3); c:rim(hd, INK); c:fillMask(hd, GOLD[5]); c:fillMask(c:ellipse(x, y - h - 2, 1, 1), TIMB[2]); P(x - 2, y - h - 3, GOLD[6])
  end
  local vx = 290
  for y = 80, 113 do
    if hash(y, 1, 101) > .7 then vx = vx + (hash(y, 2, 101) > .5 and 1 or -1) end
    vx = max(286, min(291, vx))
    if trunk:has(vx, y) then P(vx, y, GREEN[2]); if y % 4 == 0 then P(vx - 1, y, LEAF[4]); P(vx - 2, y - 1, GREEN[4]); P(vx + 1, y + 1, GREEN[3]) end end
  end
end)

---------------------------------------------------------------- front leaves at the edges, a few flowers, then save
for _, b in ipairs{ {8, 20, 18, 14}, {472, 24, 16, 16}, {6, 252, 20, 14}, {330, 262, 20, 8} } do blob(b[1], b[2], b[3], b[4], LEAF) end
for i = 0, 18 do local x = 4 + i * 25 + floor(hash(i, 1, 1) * 10); local y = 250 + floor(hash(i, 2, 2) * 14)
  if x < 366 or y < 218 then if x > 200 and x < 300 and y > 240 then goto skip end c:fillMask(rect(x, y, x + 1, y + 1), cols[i % 6 + 1]) end
  ::skip:: end
c:save{ aseprite = OUT .. "tree-house.aseprite", png = OUT .. "tree-house.png" }
print(HP.report(c, true) and "ok" or "")
