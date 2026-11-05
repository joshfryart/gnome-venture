-- Treehouse milestone dressing layers (transparent): rug (5 pals), string lights (10), telescope (20), pennant (40). Sizes = here_layouts.json 'treehouse'.dress
-- Hard pixels only (alpha 0/255), 1px ink outline from c:finish, light from the upper left, warm light / cool shadow.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/tree-yard/out/")
local floor, sin, cos, sqrt, abs, max, min = math.floor, math.sin, math.cos, math.sqrt, math.abs, math.max, math.min
local function new(name, w, h)
  local c = HP.canvas{ w = w, h = h, scale = 1, name = name }
  return c, dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
end
local function save(c, n) c:finish{ outline = true }; c:save{ aseprite = OUT .. n .. ".aseprite", png = OUT .. n .. ".png" } end
-- 6-tone ramps (dark to light): warm light, cool violet shadow
local MAD   = {"#3a1830", "#5e2640", "#8a3a42", "#b0503e", "#d0724e", "#ec9c6a"}   -- madder-red cloth
local BRASS = {"#3a2638", "#6a4030", "#9c6a2c", "#c89636", "#ecc058", "#fcecA0"}    -- brass
local GILT  = {"#4a2a34", "#80501e", "#b88226", "#e0ac34", "#f6d460", "#fff0a8"}    -- gold thread
local function pick(r, i) return r[max(1, min(#r, i))] end

-- shared: a per-pixel painter over a coverage table, with distance-to-edge (chebyshev, up to r)
local function cover() return setmetatable({}, { __index = function() return nil end }) end
local function edgeDist(cv, W, x, y, r)
  for d = 1, r do
    for dy = -d, d do for dx = -d, d do
      if max(abs(dx), abs(dy)) == d and not cv[(y + dy) * W + (x + dx)] then return d - 1 end
    end end
  end
  return r
end

-- rug 72x24 (perspective: a flat lozenge, fringe at both ends)
do
  local c, S = new("rug", 72, 24)
  local m = S.poly{{9, 3}, {62, 3}, {67, 11}, {62, 19}, {9, 19}, {4, 11}}
  local cv, row = cover(), {}
  m:each(function(x, y) cv[y * 72 + x] = true; local r = row[y] or { 99, -1 }; r[1] = min(r[1], x); r[2] = max(r[2], x); row[y] = r end)
  m:each(function(x, y)
    local d = edgeDist(cv, 72, x, y, 5)
    local col
    local tl = not cv[(y - 2) * 72 + x] or not cv[y * 72 + x - 2]      -- upper-left rim catches the light
    local br = not cv[(y + 2) * 72 + x] or not cv[y * 72 + x + 2]      -- lower-right rim is in shade
    if d == 0 then col = tl and MAD[5] or (br and MAD[1] or MAD[3])
    elseif d == 1 then col = tl and GILT[5] or (br and GILT[3] or GILT[4])
    elseif d == 2 then col = br and MAD[3] or MAD[4]
    elseif d == 3 then col = br and S.CREAM[3] or S.CREAM[5]
    else
      -- woven field: a row of lozenges, teal rings round a cream heart, on madder
      local dx = abs(((x - 6) % 12) - 6); local dy = abs(y - 11)
      local k = dx + dy * 1.5
      if k <= 1.5 then col = S.CREAM[5] elseif k <= 3.5 then col = S.TEAL[3] elseif k <= 5 then col = MAD[5] else col = MAD[3] end
    end
    if col then c:px(x, y, col) end
  end)
  for y = 12, 15 do for x = 16, 20 do   -- patched corner: a teal scrap, stitched in cream
    local edge = (x == 16 or x == 20 or y == 12 or y == 15)
    c:px(x, y, edge and ((x + y) % 2 == 0 and S.CREAM[5] or MAD[3]) or S.TEAL[3])
  end end
  c:px(18, 13, S.TEAL[5]); c:px(17, 14, S.TEAL[2]); c:px(19, 14, S.TEAL[2])
  for x = 12, 68 do c:px(x, 20, "#4a2c3c") end                        -- contact shadow, thrown to the lower right
  for y = 5, 17 do   -- fringe hangs off the left and right ends, with a knot row
    local len = (y % 2 == 0) and 3 or 2
    for k = 1, len do
      local col = (k == len) and "#b89484" or ((y % 4 == 1) and "#e8b4a0" or "#ecd8b0")   -- cream strands, a rosy one every 4th
      c:px(row[y][1] - k, y, col); c:px(row[y][2] + k, y, col)
    end
  end
  save(c, "tree-dress-rug")
end
-- string lights 260x26 (a sagging rope cord with glowing bulbs)
do
  local c, S = new("lights", 260, 26)
  local function cy(x) return 3 + floor(8 * (1 - (((x % 86) / 43) - 1) ^ 2) + .5) end
  for x = 0, 259 do   -- twisted rope: two tones in short runs
    c:px(x, cy(x), (floor(x / 2) % 2 == 0) and "#a8825a" or "#6a4a2e")
  end
  local cols = { {"#ffe38a", "#fff4c0", "#e0a83a"}, {"#ff8a5c", "#ffc09a", "#c8503a"},
                 {"#a8d870", "#d8f0a0", "#6a9a48"}, {"#8ae0d8", "#d0f8f0", "#4a9ca0"},
                 {"#f5809f", "#ffc4d4", "#b04a78"}, {"#ab93ea", "#dcd0fa", "#6a52b0"} }
  local halo = { "#fff0b0", "#ffd0a8", "#e4f4b0", "#d4f6ec", "#ffd4e0", "#e6defc" }
  local shape = {1, 3, 5, 5, 3, 1}
  for i = 0, 15 do
    local x = 8 + i * 16; local y0 = cy(x); local cl = cols[i % 6 + 1]
    local bulb = {}
    for k, r in ipairs(shape) do for dx = -(r // 2), r // 2 do bulb[(y0 + 2 + k) * 400 + x + dx] = true end end
    for key in pairs(bulb) do   -- glow ring: 1px, 4-neighbours of the bulb
      local bx, by = key % 400, key // 400
      for _, o in ipairs{{1, 0}, {-1, 0}, {0, 1}, {0, -1}} do
        local nx, ny = bx + o[1], by + o[2]
        if not bulb[ny * 400 + nx] and ny > y0 + 2 then c:px(nx, ny, halo[i % 6 + 1]) end
      end
    end
    c:px(x, y0 + 1, "#7a5a2a"); c:px(x, y0 + 2, "#4a3016")
    for k, r in ipairs(shape) do
      for dx = -(r // 2), r // 2 do
        local col = cl[1]
        if k <= 3 and dx < 0 and (k == 2 or dx == -(r // 2) and k == 3) then col = cl[2] end
        if (k >= 4 and dx >= 0) or (k == 3 and dx == 2) then col = cl[3] end
        c:px(x + dx, y0 + 2 + k, col)
      end
    end
  end
  save(c, "tree-dress-lights")
end
-- telescope 40x48 (brass tube on a wooden tripod, angled up and to the right)
do
  local c, S = new("telescope", 40, 48)
  local function leg(x0, y0, x1, y1, base)
    S.obj(S.poly{{x0 - 1, y0}, {x0 + 1, y0}, {x1 + 1, y1}, {x1 - 1, y1}}, S.TIMB, { base = base })
  end
  leg(20, 27, 21, 44, 2)                 -- back leg, in shadow
  leg(20, 27, 8, 46, 4); leg(20, 27, 32, 46, 3)
  for x = 14, 26 do c:px(x, 38, (x < 20) and S.TIMB[5] or S.TIMB[3]); c:px(x, 39, S.TIMB[2]) end   -- cross brace
  for _, fx in ipairs{8, 32} do c:fillMask(S.rect(fx - 1, 45, fx + 1, 46), BRASS[3]) end             -- brass feet
  S.obj(S.rect(18, 21, 22, 27), S.IRON, { base = 3 })                                                  -- mount
  for x = 18, 22 do c:px(x, 21, S.IRON[1]) end; c:px(20, 24, S.IRON[5])                                -- tube shadow on the mount, hinge pin
  -- the tube: eyepiece, body, joint rings, wide objective bell with a lens
  local p0x, p0y, dx, dy, L = 8, 24, 26, -17, sqrt(26 * 26 + 17 * 17)
  local ux, uy = dx / L, dy / L; local nx, ny = uy, -ux; if ny > 0 then nx, ny = -nx, -ny end
  for y = 0, 24 do for x = 0, 39 do
    local px, py = x - p0x, y - p0y
    local t, sd = (px * ux + py * uy) / L, px * nx + py * ny
    local hw
    if t >= 0 and t < .13 then hw = 1.8 elseif t >= .13 and t < .72 then hw = 3.1 elseif t >= .72 and t <= 1 then hw = 4.2 end
    if hw and abs(sd) <= hw then
      local u = sd / hw; local tone = 4
      if u > .55 then tone = 6 elseif u > .1 then tone = 5 elseif u < -.6 then tone = 2 elseif u < -.15 then tone = 3 end
      if (t >= .125 and t < .15) or (t >= .70 and t < .74) then tone = (u > 0) and 5 or 2 end   -- joint rings
      if t >= .95 then tone = (u > 0) and 6 or 3 end                                           -- rim of the bell
      if t < .13 then tone = (u > .1) and 4 or ((u < -.15) and 2 or 3) end                       -- eyepiece: darker bronze
      if t < .035 then tone = (u > 0) and 4 or 1 end                                            -- iron-dark eyecup rim
      local col = BRASS[tone]
      if t >= .3 and t < .56 and floor(t * L) % 4 == 0 and t < .55 then col = (u > 0.1) and "#9a6a48" or "#5e3a34" end   -- leather grip wrap
      if t >= .85 and t < .895 and abs(u) < .3 and u > -.3 then col = BRASS[1] end            -- rivets on the bell
      c:px(x, y, col)
    end
  end end
  -- lens: a blue glass disc on the bell end, one glint
  for _, p in ipairs{{34, 6}, {35, 6}, {34, 7}, {35, 7}, {35, 8}, {36, 7}, {34, 5}} do c:px(p[1], p[2], "#6aa6cc") end
  c:px(34, 6, "#d8f0f8"); c:px(34, 5, "#a8d4ec")
  save(c, "tree-dress-telescope")
end
-- pennant 56x30 (a swallow-tail flag on a pole, stitched crest)
do
  local c, S = new("banner", 56, 30)
  for y = 3, 29 do for x = 4, 6 do c:px(x, y, S.TIMB[(x == 4) and 5 or (x == 5 and 4 or 3)]) end end
  for y = 7, 28, 5 do c:px(5, y, S.TIMB[2]) end                      -- grain
  for _, y in ipairs{6, 14, 22} do c:px(5, y, GILT[5]); c:px(6, y, GILT[2]) end    -- brass rivets holding the cloth
  c:fillMask(S.rect(3, 1, 7, 3), GILT[4]); c:px(3, 1, GILT[3]); c:px(7, 1, GILT[3]); c:fillMask(S.rect(4, 1, 5, 1), GILT[6])
  local cv, W = cover(), 64
  for x = 7, 53 do
    local w = sin((x - 7) / 9) * 1.2
    local t, b = 4 + (x - 7) * .05 + w, 24 - (x - 7) * .05 + w
    for y = floor(t + .5), floor(b + .5) do
      if not (x > 44 and abs(y - 14) < (x - 44) * .8) then cv[y * W + x] = true end
    end
  end
  for key in pairs(cv) do
    local x, y = key % W, key // W
    local d = edgeDist(cv, W, x, y, 4)
    local col = MAD[4]
    local fx = 29 + (y - 14) * .18
    local top = not cv[(y - 2) * W + x]; local bot = not cv[(y + 2) * W + x]
    if d == 0 then col = top and MAD[5] or ((bot or not cv[y * W + x + 2]) and MAD[2] or MAD[3])
    elseif d == 1 and top then col = MAD[5]
    elseif d == 1 and bot then col = MAD[3]
    elseif x <= 8 then col = MAD[3]                                 -- the pole throws a shade onto the cloth
    elseif abs(x - fx) < .6 then col = MAD[2]                       -- cloth fold: crease ...
    elseif x > fx and x < fx + 2 then col = MAD[5]                  -- ... and the lit ridge after it
    elseif x < fx and x > fx - 5 then col = MAD[3] end              -- ... shade before it
    if x > 44 and y > 14 and col == MAD[4] then col = MAD[3] end   -- underside of the lower tail
    if d == 2 and (x + y) % 3 ~= 0 then col = (bot or x > 44 and y > 14) and GILT[3] or GILT[4] end            -- gold stitching
    c:px(x, y, col)
  end
  do   -- a gold tassel under the lower tail tip
    local by = 0; for y = 0, 29 do if cv[y * W + 51] then by = y end end
    c:px(51, by + 1, GILT[2]); c:px(51, by + 2, GILT[4]); c:px(50, by + 3, GILT[5]); c:px(51, by + 3, GILT[4]); c:px(52, by + 3, GILT[3])
  end
  -- crest: a little pointed gnome-hat, gold, with a brim
  local hat = {{10, 1}, {11, 3}, {12, 3}, {13, 5}, {14, 5}, {15, 7}}
  for _, r in ipairs(hat) do for dx = -(r[2] // 2), r[2] // 2 do
    c:px(19 + dx, r[1], (dx < 0) and GILT[6] or ((dx > 0 and r[2] > 1) and GILT[4] or GILT[5]))
  end end
  for dx = -4, 4 do c:px(19 + dx, 16, (dx < 2) and GILT[4] or GILT[3]); c:px(19 + dx, 17, GILT[2]) end
  c:px(20, 9, GILT[5])
  save(c, "tree-dress-banner")
end
print("ok")
