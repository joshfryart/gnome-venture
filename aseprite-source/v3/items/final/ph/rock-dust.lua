-- rock-dust (final, Sonnet high). A slim goblet-shaped granite mortar on a flared foot, speckled stone with a
-- chiselled band and a bright lip, heaped with fine pale-lilac rock dust that spills over the rim; a slim stone
-- pestle with a knobbed head leans in the heap. Ambient shading under the lip, on the stem and where the pestle
-- sinks into the dust; powder is speckled with cream mica. quirk: a little puff of dust floats up like a cloud
-- with a sparkle in it.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_5.lua")
local HP, X, K, B = D.HP, D.X, D.K, D.B
local floor, ceil, abs, sin, cos, pi, max, min, sqrt = math.floor, math.ceil, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rock-dust")
local GR = { "#2c2d44", "#464863", "#686a86", "#8d8ca4", "#b3b1c4", "#dedbe6" }
local DU = { "#645d86", "#8a82ae", "#aaa2cc", "#c8c0e2", "#e2dcf2", "#f6f2fc" }
local CX = 31
D.shadow(c, CX, 56, 20, 1.6)

-- body profile: half-width by row
local function hw(y)
  if y <= 33 then return 19 end
  if y <= 35 then return 19.4 end
  if y <= 42 then return 19.4 - (y - 35) * 0.34 end
  if y <= 49 then return 17 - (y - 42) * 1.35 end
  if y <= 51 then return 7.5 end
  if y == 52 then return 7 end
  return 8.5 + (y - 52) * 1.55
end
local body = HP.mask()
for y = 33, 56 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h + 0.5) do body:set(x, y) end end
-- bowl/stem/foot normals: horizontal cylinder light plus facing-down darkening
local nrm = {}
body:each(function(x, y)
  local t = D.clamp((x - CX) / (hw(y) + 0.6), -0.97, 0.97)
  local ny = D.clamp((y - 40) / 26, -0.6, 0.5)
  if y > 50 then ny = -0.2 end
  local l = sqrt(t * t + ny * ny + (1 - t * t))
  nrm[K(x, y)] = { t / l, ny / l, sqrt(max(0.05, 1 - t * t)) / l }
end)
local v = X.light(nrm, { amb = 0.08, wrap = 0.3 })
local bias = {}
body:each(function(x, y)
  local k = K(x, y)
  local h = D.hash(x, y, 9)
  local b = 0
  if h > 0.93 then b = 1 elseif h < 0.07 then b = -1 end        -- granite speckle
  -- chiselled band
  if y == 40 or y == 41 then b = b - 1 end
  -- under-lip ambient shading
  if y == 37 or y == 38 then b = b - 1 end
  -- foot top ambient + stem dark
  if y == 52 then b = b - 1 end
  if y >= 50 and y <= 51 then b = b - 1 end
  bias[k] = b
end)
X.tone(c, body, v, GR, { cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 }, bias = bias })
-- chisel band highlight under the groove
for x = floor(CX - 16), floor(CX + 16) do if body:has(x, 42) and abs(x - CX) < hw(42) - 1 and x < CX + 6 then c:px(x, 42, GR[5]) end end
-- foot rim highlight and bottom row
for x = floor(CX - hw(53)) + 1, floor(CX + hw(53)) - 1 do c:px(x, 53, x < CX + 2 and GR[5] or GR[4]) end
for x = floor(CX - hw(56)) + 1, floor(CX + hw(56)) - 1 do c:px(x, 56, GR[1]) end

-- rim: lit torus ring
local rimOut = c:ellipse(CX, 33, 19, 6)
local rimIn = c:ellipse(CX, 33, 16, 4)
local ring = rimOut:copy():cut(rimIn)
do
  local n = X.pillow(ring, 1.8)
  local vv = X.light(n, { amb = 0.1, wrap = 0.3 })
  local b2 = {}
  ring:each(function(x, y) local h = D.hash(x, y, 4) if h > 0.9 then b2[K(x, y)] = 1 elseif h < 0.06 then b2[K(x, y)] = -1 end end)
  X.tone(c, ring, vv, GR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = b2 })
end
-- bowl interior (far wall) shade, then dust fills
local inner = rimIn
D.paintF(c, inner, GR, function(x, y) local t = (y - 29) / 8 return 1.2 + t * 0.8 + ((x < CX - 8) and 0.6 or 0) end)

-- pestle (behind the heap front): slim stone shaft, knobbed head
local pm = D.stalk(c, 38, 31, 51, 11, function(t) return 2.0 + 0.9 * t end, GR, { -0.2 })
local kn = B.ell(52, 9, 3.9, 3.4, -0.5)
B.lit(c, kn, GR, 3)
c:px(50, 7, GR[6]) c:px(51, 7, GR[6]) c:px(49, 8, GR[5])
-- grip band

-- dust heap: dome in the bowl spilling over the front lip
local heap = c:ellipse(CX - 1, 31, 14.5, 7.5)
heap:add(c:ellipse(CX + 1, 35, 11, 3.2))
heap:add(c:ellipse(CX - 8, 36, 4, 2))
heap:cut(c:rect(0, 0, 63, 25))
do
  local idx = D.litB(c, heap, DU, 6, { wrap = 0.35, amb = 0.12 }, function(x, y)
    local h = D.hash(x, y, 14)
    if h > 0.9 then return 1 elseif h < 0.1 then return -1 end
  end)
  -- contact shadow/ambient where heap meets rim front and pestle
  heap:each(function(x, y)
    local nearP = false
    for dy = -1, 1 do for dx = -1, 1 do if pm:has(x + dx, y + dy) then nearP = true end end end
    if nearP and y > 27 then c:px(x, y, DU[1]) end
  end)
  -- front edge dark row where the heap overlaps the lip
  heap:each(function(x, y) if not heap:has(x, y + 1) and y >= 35 then c:px(x, y, DU[2]) end end)
end
-- sparkly mica in the dust
for _, q in ipairs{ {24,29},{29,27},{36,31},{33,35},{26,34} } do if heap:has(q[1], q[2]) then c:px(q[1], q[2], "#fff4d6") end end
-- pestle re-drawn over the heap's upper part (the shaft sits in the heap, head up)
local pm2 = D.stalk(c, 38, 29, 51, 11, function(t) return 2.0 + 0.9 * t end, GR, { -0.2 })
-- stone-dust sinking dark where the shaft enters
for _, q in ipairs{ {36,30},{37,31},{38,31},{39,31} } do c:px(q[1], q[2], DU[2]) end
B.lit(c, kn, GR, 3)
c:px(50, 7, GR[6]) c:px(51, 7, GR[6]) c:px(49, 8, GR[5])
-- grains spilled on the ground
for _, q in ipairs{ {48,56},{52,55},{45,57} } do c:px(q[1], q[2], DU[4]) c:px(q[1] + 1, q[2], DU[2]) end

-- quirk: floating dust puff with a sparkle
local pf = HP.mask()
pf:add(c:ellipse(13, 22, 3.6, 2.8)):add(c:ellipse(18, 19, 3.6, 3.2)):add(c:ellipse(10, 25, 2.6, 2.2)):add(c:ellipse(17, 24, 3.6, 2.4))
D.litB(c, pf, DU, 3, { wrap = 0.35, amb = 0.1 })
c:px(15, 17, DU[6]) c:px(16, 17, DU[6])
c:sparkle(25, 13)
D.fin()
