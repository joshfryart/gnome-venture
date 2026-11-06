-- pickled-beets (C34, Opus single pass). Classic mason jar: knurled gold screw band (bevelled rolled edges, specular),
-- glass threads, rounded shoulder, straight body. Inside: magenta brine with stacked beet slices face-on to the glass,
-- each a bevelled disc (6-tone) with pale concentric growth rings and a contact shadow where it overlaps the one behind;
-- a bay leaf and peppercorns in the gaps. Glass highlight band, pale core, dark right band, cool bounce.
-- quirk: a drip of beet brine has run down from under the lid and beaded on the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("pickled-beets")
local CX = 32
local BEET = { "#2e0f2a", "#55163e", "#7e1f4f", "#a8306a", "#cf5288", "#ec8cb0" }
local BRINE = { "#6a2458", "#9a3a72", "#c25a8e", "#de86ac", "#f0aac6", "#fcd2e2" }
local GOLD = { "#5a2e1f", "#8f4a1f", "#d98322", "#f5b82e", "#ffd970", "#fff2c0" }

c:groundShadow(CX - .5, 53, 14, 1)
local function hwBody(y)
  if y < 17 or y > 51 then return nil end
  if y <= 18 then return 9.5 end      -- threaded neck
  if y == 19 then return 10.5 elseif y == 20 then return 11.5 end
  if y == 50 then return 11.5 elseif y == 51 then return 10.5 end
  return 12
end
local body, bn, NX = A.lathe(CX, 17, 51, hwBody)
local inner = body:shrink(1)
local LEVEL = 21
local air, brine = HP.mask(), HP.mask()
inner:each(function(x, y) if y < LEVEL then air:set(x, y) else brine:set(x, y) end end)
local function sub(m) local t = {} m:each(function(x, y) t[K(x, y)] = bn[K(x, y)] end) return t end
A.tone(c, air, sub(air), A.GLASS, { amb = .4, wrap = .5 })

-- slices (back to front)
local SL = { { 26.5, 27, 5.5 }, { 37.5, 26, 5.5 }, { 32, 34, 6 }, { 25.5, 42, 5.5 }, { 38.5, 41, 5.5 }, { 31.5, 48.5, 5.5 } }
local masks = {}
for i, s in ipairs(SL) do masks[i] = A.rell(s[1], s[2], 1, 0, s[3], s[3] - .4):clip(inner) end
local slices = HP.mask() for _, m in ipairs(masks) do slices:add(m) end
local bb = {} X.ao(bb, brine, slices, 1, -1)
A.tone(c, brine:copy():cut(slices), sub(brine), BRINE, { amb = .3, wrap = .45, bias = bb })
for x = CX - 11, CX + 11 do if brine:has(x, LEVEL) and not slices:has(x, LEVEL) then c:put(x, LEVEL, BRINE[6]) end end
-- bay leaf + peppercorns in gaps (before slices so slices overlap them)
A.leaf(c, 41, 33, .2, 1, 6, 1.5, { "#2a3a1e", "#3e5226", "#5a6e30", "#7a8a3c", "#9eaa52", "#c4c87a" }, { R = 1.2 })
for _, p in ipairs{ { 22, 35 }, { 33, 41 }, { 42, 49 } } do
  c:put(p[1], p[2], "#4a2a2a") c:put(p[1] + 1, p[2], "#2e1c22") c:put(p[1], p[2] + 1, "#3a2226")
end
for i, s in ipairs(SL) do
  local m = masks[i]
  local n = X.pillow(m, 2.2)
  local bias = {}
  m:each(function(x, y) bias[K(x, y)] = -2 end)
  for j = i + 1, #SL do X.ao(bias, m, masks[j]:shift(1, 1), 1, -1) end
  local idx = A.tone(c, m, n, BEET, { amb = .1, wrap = .3, bias = bias })
  m:each(function(x, y)
    local dx, dy = (x + .5 - s[1]) / s[3], (y + .5 - s[2]) / (s[3] - .4)
    local q = sqrt(dx * dx + dy * dy)
    local k = K(x, y)
    local ring = (q > .3 and q < .46) or (q > .66 and q < .78)
    if ring and (bias[k] or 0) == -2 then c:put(x, y, BEET[min(6, (idx[k] or 3) + 2)]) end
  end)
  -- tiny root-hair dimple at centre
  c:put(floor(s[1]), floor(s[2]), BEET[max(1, (idx[K(floor(s[1]), floor(s[2]))] or 3) - 1)])
end
A.glass(c, body:copy():clip(HP.rect(0, 19, 63, 63)), inner, bn, NX, { ys = 19 })

-- threads on the neck
local neck = body:copy():clip(HP.rect(0, 17, 63, 18))
A.tone(c, neck, sub(neck), A.GLASS, { amb = .35, wrap = .4 })
for x = CX - 9, CX + 8, 3 do c:put(x, 18, A.GLASS[2]) c:put(x + 1, 17, A.GLASS[2]) end

-- screw band lid (rows 10..16) with rolled edges + knurl
local lm, ln, LNX = A.lathe(CX, 10, 16, function(y) if y == 10 then return 10 end return 11 end)
local bias = {}
lm:each(function(x, y) if y == 11 or y == 16 then bias[K(x, y)] = 1 elseif y == 12 or y == 15 then bias[K(x, y)] = -1 end end)
local idx = A.tone(c, lm, ln, GOLD, { amb = .08, wrap = .2, bias = bias })
lm:each(function(x, y)
  if y >= 13 and y <= 14 and (x % 2 == 0) then c:put(x, y, GOLD[max(1, (idx[K(x, y)] or 3) - 1)]) end
end)
-- lid top face
for x = CX - 9, CX + 8 do c:put(x, 10, x < CX - 2 and GOLD[6] or (x < CX + 4 and GOLD[5] or GOLD[4])) end
c:put(CX - 7, 13, A.SPEC) c:put(CX - 7, 14, GOLD[6])

-- quirk: brine drip from under the lid, beaded on the glass (right of centre)
local dx = CX + 5
for y = 17, 25 do c:put(dx, y, y < 20 and BRINE[4] or "#e87aa8") c:put(dx + 1, y, BRINE[2]) end
for _, p in ipairs{ { -1, 26 }, { 0, 26 }, { 1, 26 }, { -1, 27 }, { 0, 27 }, { 1, 27 }, { 0, 28 } } do
  c:put(dx + p[1], p[2], p[1] == 1 and BRINE[2] or BRINE[5])
end
c:put(dx - 1, 26, A.SPEC) c:put(dx, 28, BRINE[1])
A.fin(c, "pickled-beets")
