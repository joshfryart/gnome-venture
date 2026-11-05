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
room({92, 126, 210, 196}, CREAM, OAK, { seed = 2 })
window(100, 140, 118, 156)
obj(rr(124, 150, 150, 168, 3), PINK, { base = 4 }); obj(rr(120, 160, 128, 178, 2), PINK, { base = 3 }); obj(rr(146, 160, 154, 178, 2), PINK, { base = 3 })  -- sofa
obj(rect(124, 168, 150, 182), PINK, { base = 3 }); obj(rect(126, 182, 130, 184), TIMB, { base = 2 }); obj(rect(144, 182, 148, 184), TIMB, { base = 2 })
obj(rect(158, 176, 196, 183), BARN, { base = 4 })   -- rug
c:fillMask(rect(160, 178, 194, 178), GOLD[5]); c:fillMask(rect(160, 181, 194, 181), GOLD[5])
obj(rect(172, 144, 186, 158), TEAL, { base = 3 }); c:fillMask(rect(174, 146, 184, 156), "#f4d88a")  -- picture
lantern(166, 134)

-- Loft [270,116,390,186]: hay bed, ladder, crates, bunting
room({270, 116, 390, 186}, CREAM, OAK, { seed = 3, pw = 8 })
obj(rect(280, 160, 312, 174), "#cc9e40" and GOLD, { base = 4 }); obj(rr(282, 152, 296, 162, 2), ROSE, { base = 4 })  -- bed and pillow
for i = 0, 5 do c:fillMask(rect(316 + i * 4, 126, 316 + i * 4, 172), TIMB[3]) end   -- (rungs drawn below)
obj(rect(316, 126, 318, 174), TIMB, { base = 4 }); obj(rect(334, 126, 336, 174), TIMB, { base = 4 })
for y = 132, 170, 9 do obj(rect(318, y, 334, y + 2), TIMB, { base = 5 }) end   -- ladder
obj(rect(346, 150, 372, 174), OAK, { base = 4 }); obj(rect(350, 138, 368, 150), OAK, { base = 5 }); c:fillMask(rect(346, 160, 372, 160), OAK[2])  -- crates
for i = 0, 6 do local x = 276 + i * 16; local f = poly{{x, 128}, {x + 12, 128}, {x + 6, 138}}; c:rim(f, "#2b1c26"); c:fillMask(f, ({"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8"})[i % 4 + 1]) end
lantern(300, 134)

-- Cellar [196,202,290,264]: barrels, jar shelf, steps
room({196, 202, 290, 264}, STONE, STONE, { seed = 4, glow = .22 })
obj(rr(204, 232, 226, 256, 4), OAK, { base = 3 }); c:fillMask(rect(204, 238, 226, 239), IRON[3]); c:fillMask(rect(204, 250, 226, 251), IRON[3])
obj(rr(230, 238, 250, 256, 4), OAK, { base = 4 }); c:fillMask(rect(230, 243, 250, 244), IRON[3]); c:fillMask(rect(230, 251, 250, 252), IRON[3])
obj(rect(256, 214, 284, 218), TIMB, { base = 4 })
for i = 0, 3 do local x = 258 + i * 7; local j = rect(x, 206, x + 4, 213); c:rim(j, "#2b1c26"); c:fillMask(j, ({"#e8493b", "#f5b82e", "#7cc35a", "#8a6fd0"})[i + 1]); c:fillMask(rect(x, 206, x + 4, 207), CREAM[5]) end
for i = 0, 3 do local x = 258 + i * 7; local j = rect(x, 224, x + 4, 231); c:rim(j, "#2b1c26"); c:fillMask(j, ({"#f5809f", "#5fc4c8", "#f5b82e", "#e8493b"})[i + 1]) end
obj(rect(256, 232, 284, 235), TIMB, { base = 4 }); lantern(264, 246)

-- Puzzle Room [20,202,120,264]: table of jigsaw pieces and a wall of puzzle pictures
room({20, 202, 120, 264}, VIOLET, OAK, { seed = 5 })
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
room({214, 78, 268, 122}, CREAM, OAK, { seed = 6, pw = 6 })
obj(rect(220, 108, 262, 111), TIMB, { base = 4 }); obj(rect(220, 94, 262, 96), TIMB, { base = 4 })
local function cup(x, y, g)
  local bowl = poly{{x, y}, {x + 8, y}, {x + 6, y + 6}, {x + 2, y + 6}}; c:rim(bowl, "#2b1c26"); c:fillMask(bowl, GOLD[g]); c:fillMask(rect(x + 1, y, x + 2, y + 3), GOLD[6])
  c:fillMask(rect(x + 3, y + 6, x + 5, y + 8), GOLD[3]); c:fillMask(rect(x + 1, y + 8, x + 7, y + 9), GOLD[2])
end
cup(224, 99, 4); cup(238, 99, 5); cup(252, 99, 4); cup(226, 85, 5); cup(246, 85, 4)
for i = 0, 2 do local d = S.diamond(228 + i * 14, 105, 3); c:rim(d, "#2b1c26"); c:fillMask(d, ({"#e8493b", "#5fc4c8", "#f5809f"})[i + 1]) end

-- Pal Book nook [412,72,470,130]: bookshelf
room({412, 72, 470, 130}, OAK, OAK, { seed = 8, pw = 5 })
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
room({336, 188, 420, 216}, TEAL, OAK, { seed = 9 })
local ham = poly{{346, 198}, {372, 198}, {366, 206}, {352, 206}}; c:rim(ham, "#2b1c26"); c:fillMask(ham, ROSE[4]); c:fillMask(rect(350, 198, 368, 199), ROSE[5])
c:line({{380, 196}, {394, 202}, {400, 208}}, 1):each(function(x, y) c:put(x, y, "#2b1c26") end)
c:fillMask(rect(398, 207, 402, 210), "#e8493b")
local bowl = rect(406, 205, 414, 209); c:rim(bowl, "#2b1c26"); c:fillMask(bowl, "#5fc4c8")

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

---------------------------------------------------------------- front leaves at the edges, a few flowers, then save
for _, b in ipairs{ {8, 20, 18, 14}, {472, 24, 16, 16}, {6, 252, 20, 14}, {330, 262, 20, 8} } do blob(b[1], b[2], b[3], b[4], LEAF) end
for i = 0, 18 do local x = 4 + i * 25 + floor(hash(i, 1, 1) * 10); local y = 250 + floor(hash(i, 2, 2) * 14)
  if x < 366 or y < 218 then if x > 200 and x < 300 and y > 240 then goto skip end c:fillMask(rect(x, y, x + 1, y + 1), cols[i % 6 + 1]) end
  ::skip:: end
c:save{ aseprite = OUT .. "tree-house.aseprite", png = OUT .. "tree-house.png" }
print(HP.report(c, true) and "ok" or "")
