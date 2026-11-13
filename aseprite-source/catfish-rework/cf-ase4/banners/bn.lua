-- bn.lua: banner scene helpers (480x120, hard pixels, 1px ink on hero objects, light from upper left)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/h3.lua")
local L = H.L
local floor, max, min, sin, cos, sqrt, abs, pi = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs, math.pi
local B = { H = H, L = L, mk = H.R, R = H, mixc = H.mixc, W = 480, HH = 120 }
local INK = "#2b1c26"
B.INK = INK
local function hsh(x, y, s) local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483) % 4294967296 n = ((n ~ (n >> 13)) * 1274126177) % 4294967296 return ((n ~ (n >> 16)) % 10007) / 10007 end
B.hsh = hsh
-- extra ramps
local R = H.R
B.R2 = {
  GINGER = R("#7a3a1c", "#c4602a", "#ee9040", "#f8b060", "#ffd08a", "#fff0c8"),
  CREAMC = R("#8a6a60", "#c8a890", "#efd9b4", "#f8ecc8", "#fff6dc", "#ffffff"),
  GREYC = R("#3d3654", "#6e6684", "#9890b0", "#b8b2cc", "#d4d0e0", "#f4f0fa"),
  TABBY = R("#4a2c1a", "#7a5030", "#a8784a", "#c8985c", "#e0b878", "#f6dca8"),
  CORAL = R("#7a2a3a", "#c4505a", "#ee7c70", "#f8a088", "#ffc4a0", "#ffe8d0"),
  WHITE = R("#7a7098", "#a8a2c4", "#e4dcea", "#f4eef0", "#fffaf0", "#ffffff"),
  SAND = R("#a07a50", "#cfa874", "#ecc98c", "#f6dca4", "#fceab8", "#fff6d0"),
  OCHRE = R("#7a4a28", "#b87a40", "#dca058", "#eebc74", "#f8d490", "#fff0bc"),
  LEAF = R("#143a2c", "#235e3a", "#348a46", "#52ac50", "#84cc62", "#c4ec8c"),
  LEAFD = R("#10302a", "#1a4a34", "#27703c", "#3a8c48", "#5aac54", "#90cc6c"),
  TEALC = R("#12404a", "#1f6e78", "#2c9a98", "#4cbab0", "#7ad8c8", "#c4f4e6"),
  RED2 = R("#6a1a28", "#a82a36", "#d44040", "#ec6446", "#fc8a60", "#ffc09a"),
  BLUEC = R("#1a2a5a", "#2a4a8a", "#3f6ec0", "#6c9ce0", "#9cc4f4", "#d8ecff"),
  DUSKR = R("#2a2048", "#4a3a7a", "#6e58a8", "#8e78c8", "#b0a0e0", "#e0d8f8"),
  STONEW = R("#6a5a60", "#a08a88", "#d8c4a8", "#ecdcc0", "#f8ecd4", "#fff8e8"),
  THATCH = R("#6a4a1a", "#a8782a", "#d4a040", "#e8bc58", "#f6d478", "#fff0a8"),
  CLAY = R("#6a3a22", "#a05a36", "#c8784a", "#de9660", "#f0b47e", "#ffd8a8"),
  GLOWR = R("#b05a1a", "#e8902a", "#ffc048", "#ffd870", "#ffe8a0", "#fff8d8"),
}

function B.new(w, h) local c = L.canvas(w or 480, h or 120, true) return c end
local function inb(c, x, y) return x >= 0 and y >= 0 and x < c.w and y < c.h end
function B.put(c, x, y, col, lay) if inb(c, x, y) then c:put(x, y, col, lay or "scene", true) end end
function B.px(c, list, col, lay) for _, p in ipairs(list) do B.put(c, p[1], p[2], p[3] or col, lay) end end
function B.fill(c, m, col, lay) m:each(function(x, y) B.put(c, x, y, col, lay) end) end
function B.rectc(c, x0, y0, x1, y1, col, lay) for y = y0, y1 do for x = x0, x1 do B.put(c, x, y, col, lay) end end end
function B.bands(c, y0, y1, cols, lay, x0, x1)
  local n, hgt = #cols, y1 - y0 + 1
  for y = y0, y1 do local col = cols[min(n, floor((y - y0) * n / hgt) + 1)] for x = x0 or 0, x1 or c.w - 1 do B.put(c, x, y, col, lay) end end
end
-- shaded part (flat ramp bands) without outline
function B.part(c, m, ramp, ws, wl, lay, o)
  o = o or {} o.ws, o.wl, o.ramp, o.ao, o.layer = ws or 1, wl or 1, ramp, false, lay or "body"
  m:each(function(x, y) if not inb(c, x, y) then m:unset(x, y) end end)
  c:part(m, o)
end
function B.ink(c, m, col)
  m:grow(1):cut(m):each(function(x, y) B.put(c, x, y, col or INK, "ink") end)
end
-- solid: shaded + ink
function B.solid(c, m, ramp, ws, wl, lay, o)
  B.part(c, m, ramp, ws, wl, lay, o)
  B.ink(c, m)
end
-- retone inside mask: fn(x,y,cur)->hex or nil
function B.retone(c, m, fn) m:each(function(x, y) local v = fn(x, y, c:get(x, y)) if v then B.put(c, x, y, v, "detail") end end) end
local function lit(c, x, y) return c:hex(c:get(x, y) or "#000000") end
-- ground shadow (soft): darken existing pixels in mask one ramp step toward given colour
function B.shade(c, m, col) m:each(function(x, y) B.put(c, x, y, col, "shadow") end) end
function B.dashes(c, y, x0, x1, col) for x = x0, x1 do if (x - x0) % 3 < 2 then B.put(c, x, y, col, "hem") end end end
function B.hem(c) local g = "#f5cf6a" B.dashes(c, 3, 2, c.w - 3, g) B.dashes(c, c.h - 4, 2, c.w - 3, g) end

-- poly/rect helpers
B.rect, B.ellipse, B.poly, B.line, B.tube, B.mask = L.rect, L.ellipse, L.poly, L.line, L.tube, L.mask
B.rr = H.rrect
function B.lineW(pts, w) local m = L.mask() local seg = L.line(pts) seg:each(function(x, y) for j = 0, w - 1 do m:set(x, y + j) end end) return m end

-- textures over an already painted mask (use ramp keys)
function B.tiles(c, m, ramp, tw, th, x0, y0)
  m:each(function(x, y)
    local row = floor((y - y0) / th)
    local ry = (y - y0) % th
    local off = (row % 2) * floor(tw / 2)
    local cur = c:get(x, y)
    if ry == th - 1 then B.put(c, x, y, ramp.b, "detail")
    elseif ry == 0 then B.put(c, x, y, ramp.L, "detail")
    elseif (x - x0 + off) % tw == 0 then B.put(c, x, y, ramp.s, "detail") end
  end)
end
function B.planks(c, m, ramp, pw, x0, ph, y0)  -- vertical plank seams (and clap boards if ph)
  m:each(function(x, y)
    if (x - x0) % pw == 0 then B.put(c, x, y, ramp.s, "detail")
    elseif ph and (y - y0) % ph == 0 then B.put(c, x, y, ramp.l, "detail")
    elseif ph and (y - y0) % ph == ph - 1 then B.put(c, x, y, ramp.b, "detail") end
  end)
end
function B.clap(c, m, ramp, ph, y0) -- horizontal clapboards: lit top row, shaded bottom row
  m:each(function(x, y)
    local r = (y - y0) % ph
    if r == 0 then B.put(c, x, y, ramp.l, "detail") elseif r == ph - 1 then B.put(c, x, y, ramp.b, "detail") end
  end)
end
function B.bricks(c, m, ramp, bw, bh, x0, y0)
  m:each(function(x, y)
    local row = floor((y - y0) / bh)
    if (y - y0) % bh == bh - 1 then B.put(c, x, y, ramp.b, "detail")
    elseif (x - x0 + (row % 2) * floor(bw / 2)) % bw == 0 then B.put(c, x, y, ramp.b, "detail")
    elseif hsh(x, y, 4) < 0.05 then B.put(c, x, y, ramp.l, "detail") end
  end)
end
function B.thatch(c, m, ramp, sl)   -- vertical-ish strands falling down-left to down-right
  m:each(function(x, y)
    local h = hsh(x + floor(y / (sl or 3)), floor(y / 5), 9)
    local cur = c:get(x, y)
    if h < 0.16 then B.put(c, x, y, ramp.s, "detail") elseif h > 0.9 then B.put(c, x, y, ramp.L, "detail") elseif h < 0.3 then B.put(c, x, y, ramp.b, "detail") end
    if y % 6 == 5 and hsh(x, y, 2) < 0.6 then B.put(c, x, y, ramp.b, "detail") end
  end)
end
function B.speck(c, m, cols, dens, seed)
  m:each(function(x, y) local h = hsh(x, y, seed or 1) if h < dens then B.put(c, x, y, cols[1 + floor(hsh(x, y, 77) * #cols)], "detail") end end)
end

-- sky, clouds, sun
function B.cloud(c, x, y, w, top, under)
  local m = L.ellipse(x, y, w * 0.5, w * 0.17):add(L.ellipse(x - w * 0.2, y - w * 0.1, w * 0.22, w * 0.15)):add(L.ellipse(x + w * 0.08, y - w * 0.14, w * 0.26, w * 0.2))
  m:each(function(xx, yy) B.put(c, xx, yy, (m:has(xx, yy + 2) and not m:has(xx, yy - 99)) and top or under, "cloud") end)
  m:each(function(xx, yy) if not m:has(xx, yy + 1) then B.put(c, xx, yy, under, "cloud") end end)
end
function B.sun(c, x, y, r, col, rim, halo)
  if halo then L.ellipse(x, y, r + 5, r + 5):each(function(xx, yy) if (xx + yy) % 2 == 0 then B.put(c, xx, yy, halo, "sun") end end) end
  local m = L.ellipse(x, y, r, r)
  m:each(function(xx, yy) B.put(c, xx, yy, col, "sun") end)
  m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) then B.put(c, xx, yy, rim, "sun") end end)
  B.put(c, x - 2, y - 2, "#ffffff", "sun") B.put(c, x - 1, y - 2, "#ffffff", "sun")
end

-- small things -------------------------------------------------------------------------------------
function B.lantern(c, x, y, ramp, o)   -- hanging lantern, x centre, y top of cord
  o = o or {}
  local len = o.cord or 5
  B.px(c, (function() local t = {} for j = 0, len - 1 do t[#t + 1] = { x, y + j, INK } end return t end)())
  local bx, by = x - 3, y + len
  local m = B.rr(bx, by, bx + 6, by + (o.h or 8), 2)
  B.solid(c, m, ramp, 1, 1)
  local gl = B.rect(bx + 2, by + 2, bx + 4, by + (o.h or 8) - 2)
  B.fill(c, gl, "#ffe68c") B.put(c, bx + 2, by + 2, "#ffffff")
  B.rectc(c, bx - 1, by - 1, bx + 7, by, ramp.D, "ink")
  B.put(c, x, by + (o.h or 8) + 1, ramp.m, "detail") B.put(c, x, by + (o.h or 8) + 2, ramp.l, "detail")
end
function B.bunting(c, x0, y0, x1, y1, sag, cols, gap)
  local pts, n = {}, x1 - x0
  for i = 0, n do local t = i / n pts[#pts + 1] = { x0 + i, floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) } end
  for _, p in ipairs(pts) do B.put(c, p[1], p[2], "#5a3a28", "rope") end
  local k = 0
  for i = 4, n - 4, gap or 8 do
    local p = pts[i + 1] k = k + 1
    local col = cols[(k - 1) % #cols + 1]
    local fl = L.poly({ { p[1] - 2.5, p[2] + 1 }, { p[1] + 3.5, p[2] + 1 }, { p[1] + 0.5, p[2] + 7.5 } })
    B.part(c, fl, col, 1, 1, "flag", { noao = true })
    B.ink(c, fl, col.D)
  end
end
function B.awning(c, x0, x1, y0, h, ra, rb, sw)   -- striped awning, slanted: top y0, bottom y0+h; scalloped hem
  sw = sw or 6
  local body = L.mask()
  for x = x0, x1 do for y = y0, y0 + h do body:set(x, y) end end
  B.solid(c, body, ra, 1, 1, "awning")
  -- stripes
  for x = x0, x1 do
    if floor((x - x0) / sw) % 2 == 1 then
      for y = y0, y0 + h do
        local base = c:get(x, y)
        local ramp = rb
        local t = (y == y0) and ramp.L or (y >= y0 + h - 1 and ramp.s or ((x == x1) and ramp.s or ramp.m))
        if y == y0 + 1 then t = ramp.l end
        B.put(c, x, y, t, "awning")
      end
    end
  end
  -- scallops
  for x = x0, x1 do
    local ph = (x - x0) % sw
    local sc = floor((x - x0) / sw) % 2 == 1 and rb or ra
    local d = (ph == 0 or ph == sw - 1) and 0 or 1
    if d == 1 then B.put(c, x, y0 + h + 1, sc.b, "awning") B.put(c, x, y0 + h + 2, INK, "ink")
    else B.put(c, x, y0 + h + 1, INK, "ink") end
  end
end
function B.emblem(c, x, y, r, bg, fg)  -- round sign with cat-head silhouette (no text)
  local m = L.ellipse(x, y, r, r)
  B.solid(c, m, bg, 1, 1, "sign")
  local f = L.ellipse(x, y + 1, r * 0.55, r * 0.42)
  f:add(L.poly({ { x - r * 0.6, y - r * 0.05 }, { x - r * 0.55, y - r * 0.75 }, { x - r * 0.1, y - r * 0.35 } }))
  f:add(L.poly({ { x + r * 0.6, y - r * 0.05 }, { x + r * 0.55, y - r * 0.75 }, { x + r * 0.1, y - r * 0.35 } }))
  B.fill(c, f, fg.s or fg, "sign")
  B.px(c, { { x - 2, y + 1, bg.l }, { x + 2, y + 1, bg.l } })
end
function B.ginger_ear(c, x, y, ramp) end

-- cats -----------------------------------------------------------------------------------------------
-- sitting cat seen from the front; (x, y) = centre bottom
function B.catSit(c, x, y, ramp, o)
  o = o or {}
  local s = o.s or 1
  local body = L.ellipse(x, y - 4 * s, 4.4 * s, 4.6 * s)
  local head = L.ellipse(x, y - 10 * s, 4.6 * s, 3.9 * s)
  local earL = L.poly({ { x - 5 * s, y - 11 * s }, { x - 4.2 * s, y - 16 * s }, { x - 1 * s, y - 13.5 * s } })
  local earR = L.poly({ { x + 5 * s, y - 11 * s }, { x + 4.2 * s, y - 16 * s }, { x + 1 * s, y - 13.5 * s } })
  local tail = L.tube({ { x + 4 * s, y - 1 }, { x + 7 * s, y - 2 }, { x + 8 * s, y - 6 * s } }, function() return 1.1 end)
  if o.tail ~= false then B.solid(c, tail, ramp, 1, 1, "cat") end
  B.solid(c, body, ramp, 1, 1, "cat")
  B.solid(c, earL:add(earR):add(head), ramp, 1, 1, "cat")
  if o.inner ~= false then B.px(c, { { x - 4 * s, y - 13 * s, "#e8909e" }, { x + 4 * s, y - 13 * s, "#e8909e" } }) end
  B.px(c, { { x - 2 * s, y - 10 * s, INK }, { x + 2 * s, y - 10 * s, INK }, { x, y - 8 * s, "#e8909e" } })
  B.put(c, x - 2 * s, y - 11 * s, ramp.L)
  if o.stripe then B.px(c, { { x - 1, y - 13 * s }, { x, y - 13 * s }, { x + 1, y - 13 * s }, { x, y - 12 * s }, { x - 4, y - 5 * s }, { x + 4, y - 5 * s }, { x - 3, y - 3 * s }, { x + 3, y - 3 * s } }, o.stripe) end
  if o.belly then B.fill(c, L.ellipse(x, y - 3.5 * s, 2.2 * s, 3 * s), o.belly, "cat") end
end
-- loaf / curled cat lying, (x,y) centre bottom, faces right
function B.catLoaf(c, x, y, ramp, o)
  o = o or {}
  local flip = o.flip and -1 or 1
  local body = L.ellipse(x, y - 3, 7.5, 3.6)
  local head = L.ellipse(x + 6.5 * flip, y - 3.5, 3.6, 3)
  local ear1 = L.poly({ { x + (4.5) * flip, y - 5 }, { x + 5 * flip, y - 9 }, { x + 7.5 * flip, y - 6.5 } })
  local ear2 = L.poly({ { x + (8.5) * flip, y - 5.5 }, { x + 9 * flip, y - 9 }, { x + 10 * flip, y - 5 } })
  local tail = L.tube({ { x - 6 * flip, y - 2 }, { x - 9 * flip, y - 3 }, { x - 9 * flip, y - 6 } }, function() return 1.1 end)
  B.solid(c, tail, ramp, 1, 1, "cat")
  B.solid(c, body, ramp, 1, 1, "cat")
  B.solid(c, head:add(ear1):add(ear2), ramp, 1, 1, "cat")
  B.px(c, { { x + 5 * flip, y - 4, INK }, { x + 8 * flip, y - 4, INK }, { x + 6 * flip, y - 3, "#e8909e" } })
  if o.stripe then B.px(c, { { x - 2, y - 6 }, { x, y - 6 }, { x + 2, y - 6 }, { x - 4, y - 4 }, { x - 1, y - 3 } }, o.stripe) end
end
-- foliage
function B.palm(c, x, y, h, lean, ramp, trunk)
  trunk = trunk or B.R2.TABBY
  local top = { x + lean, y - h }
  local tr = L.tube({ { x, y }, { x + lean * 0.3, y - h * 0.5 }, top }, function(t) return 2.4 - 1.0 * t end)
  B.solid(c, tr, trunk, 1, 1, "trunk")
  tr:each(function(xx, yy) if (yy % 5 == 0) then B.put(c, xx, yy, trunk.s, "detail") end end)
  local ang = { -2.9, -2.4, -1.9, -1.2, -0.7, -0.25, 0.1 }
  for i, a in ipairs(ang) do
    local len = 24 + (i % 3) * 4
    local ex, ey = top[1] + cos(a) * len, top[2] + sin(a) * len * 0.45 + 8 - abs(cos(a)) * 0
    local mx, my = top[1] + cos(a) * len * 0.55, top[2] + sin(a) * len * 0.5 - 4
    local fr = L.tube({ top, { mx, my }, { ex, ey } }, function(t) return max(0.7, 3.2 * sin(t * pi) ^ 0.6) end)
    B.solid(c, fr, (i % 2 == 0) and ramp or B.R2.LEAFD, 1, 1, "frond")
  end
  B.solid(c, L.ellipse(top[1], top[2] + 1, 2, 2), B.R2.TABBY, 1, 1, "frond")
end
function B.bushTree(c, x, y, rx, ry, ramp, tw, th)
  th = th or 12
  local trunk = L.rect(x - 1, y - th, x + 1, y)
  B.solid(c, trunk, B.R2.TABBY, 1, 1, "trunk")
  local m = L.ellipse(x, y - th - ry * 0.6, rx, ry):add(L.ellipse(x - rx * 0.5, y - th - ry * 0.3, rx * 0.6, ry * 0.7)):add(L.ellipse(x + rx * 0.5, y - th - ry * 0.3, rx * 0.6, ry * 0.7))
  B.solid(c, m, ramp, 2, 2, "leaf")
  B.speck(c, m, { ramp.L, ramp.l, ramp.s }, 0.14, 3)
end
function B.pot(c, x, y, ramp, w, h, plant, flower)
  w = w or 12 h = h or 9
  local m = L.poly({ { x - w / 2, y - h }, { x + w / 2, y - h }, { x + w / 2 - 1.5, y }, { x - w / 2 + 1.5, y } })
  m:add(L.rect(floor(x - w / 2 - 1), y - h, floor(x + w / 2 + 1), y - h + 1))
  if plant then
    local pm = L.ellipse(x, y - h - 4, w * 0.5, 4.6)
    B.solid(c, pm, plant, 1, 1, "leaf")
    B.speck(c, pm, { plant.L, plant.s }, 0.15, 5)
    if flower then for i = -1, 1 do B.px(c, { { x + i * 3, y - h - 5 - (i % 2), flower.m }, { x + i * 3 + 1, y - h - 5 - (i % 2), flower.l }, { x + i * 3, y - h - 6 - (i % 2), flower.L } }) end end
  end
  B.solid(c, m, ramp, 1, 1, "pot")
end
-- little yarn ball
function B.yarn(c, x, y, r, ramp, line)
  local m = L.ellipse(x, y, r, r)
  B.solid(c, m, ramp, 1, 1, "toy")
  B.line = B.line
  local ln = L.line({ { floor(x - r + 1), floor(y + 1) }, { floor(x), floor(y - r + 1) }, { floor(x + r - 1), floor(y + 1) } }):clip(m)
  ln:each(function(xx, yy) B.put(c, xx, yy, ramp.s, "detail") end)
end
function B.fishToy(c, x, y, ramp, w)
  w = w or 9
  local m = L.ellipse(x, y, w / 2, 2.6):add(L.poly({ { x + w / 2 - 1, y }, { x + w / 2 + 3, y - 3 }, { x + w / 2 + 3, y + 3 } }))
  B.solid(c, m, ramp, 1, 1, "toy")
  B.px(c, { { x - w / 2 + 2, y - 1, INK }, { x - 1, y - 1, ramp.s }, { x, y, ramp.s } })
end
-- glow on ground
function B.glow(c, cx, cy, rx, ry, col)
  L.ellipse(cx, cy, rx, ry):each(function(x, y) if (x + y) % 2 == 0 and inb(c, x, y) then B.put(c, x, y, col, "glow") end end)
end
function B.finish(c, name)
  B.hem(c)
  c:save(H.OUT, name)
  print(name, c:colours())
end
return B
