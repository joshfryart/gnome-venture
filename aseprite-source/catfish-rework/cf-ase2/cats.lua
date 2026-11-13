-- cats.lua: Cat Fish grey template cats (idleA, pounce, catch, nap), hand-authored spans/polygons + offset-band shading,
-- hand-placed face, tufts, toes. quirk: nicked left ear (cat's left = viewer's right), a V notch in the outer edge.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local L = dofile(DIR .. "/cflib.lua")
local OUT = app.params["out"] or (DIR .. "/out/")
local K = L.K
local CATS = {}
local PASS = tonumber(app.params["pass"] or 1)
local FINAL = PASS == 4   -- pass 1 + ambient rows + 2 rim flicks only (no fur texture)
local floor = math.floor

-- HEAD (cols relative to x=8, rows absolute for idleA; shifted by ox,oy) ----------------------------
local FACE = { [10] = { 2, 32 } }
for y = 11, 19 do FACE[y] = { 1, 33 } end
local CHEEK = { [20] = { 1, 33 }, [21] = { 0, 34 }, [22] = { -1, 35 }, [23] = { 1, 33 }, [24] = { 0, 34 }, [25] = { 2, 32 },
  [26] = { 3, 31 }, [27] = { 4, 30 }, [28] = { 6, 28 }, [29] = { 8, 26 }, [30] = { 11, 23 } }
for y, r in pairs(CHEEK) do FACE[y] = r end
local CROWN_A = { [7] = { 14, 20 }, [8] = { 12, 22 }, [9] = { 11, 23 } }
local CROWN_F = { [7] = { 12, 22 }, [8] = { 7, 27 }, [9] = { 3, 31 } }
local FLAP_L = { [4] = { 7, 10 }, [5] = { 6, 11 }, [6] = { 5, 11 }, [7] = { 4, 11 }, [8] = { 4, 10 }, [9] = { 5, 8 }, [10] = { 6, 6 } }
local FLAP_R = { [4] = { 24, 27 }, [5] = { 23, 28 }, [6] = { 23, 29 }, [7] = { 23, 30 }, [8] = { 24, 30 }, [9] = { 26, 29 }, [10] = { 28, 28 } }
local EAR_L = { [2] = { 2, 3 }, [3] = { 2, 4 }, [4] = { 2, 5 }, [5] = { 2, 6 }, [6] = { 2, 7 }, [7] = { 2, 8 }, [8] = { 2, 9 }, [9] = { 2, 10 } }
local EAR_R = { [2] = { 31, 32 }, [3] = { 30, 32 }, [4] = { 29, 30 }, [5] = { 28, 29 }, [6] = { 27, 30 }, [7] = { 26, 32 }, [8] = { 25, 32 }, [9] = { 24, 32 } }
local PINK_L = { [4] = { 3, 3 }, [5] = { 3, 4 }, [6] = { 3, 5 }, [7] = { 4, 6 }, [8] = { 4, 6 } }
local PINK_R = { [4] = { 31, 31 }, [5] = { 30, 30 }, [6] = { 29, 30 }, [7] = { 28, 30 }, [8] = { 28, 30 } }
local EYE_OPEN = { "..uuu..", ".ucccu.", "uccuucu", "ucuuucu", "ucuuucu", ".ucccu.", "..uuu.." }

local EAR_RT = { [2] = { 33, 34 }, [3] = { 32, 34 }, [4] = { 31, 32 }, [5] = { 30, 31 }, [6] = { 29, 32 }, [7] = { 26, 32 }, [8] = { 25, 32 }, [9] = { 24, 32 } }
local EYE_BORED = { ".......", ".......", "uuuuuuu", "ucuuucu", "ucuuucu", ".ucccu.", "..uuu.." }
local function head(c, info, ox, oy, eyes, ears, fluff, opts)
  opts = opts or {}
  local X0 = 8 + ox
  local hm = L.spans(FACE, X0, oy)
  local earsM
  if ears == "folded" then
    hm:add(L.spans(CROWN_F, X0, oy))
  else
    hm:add(L.spans(CROWN_A, X0, oy))
    earsM = L.spans(EAR_L, X0, oy):add(L.spans(opts.twitch and EAR_RT or EAR_R, X0, oy))
    hm:add(earsM)
  end
  -- chin ruff: three clean tufts (left, centre longest, right) hanging over the chest
  local RUFF = { { 19, 31, 'l' }, { 20, 31, 'L' }, { 21, 31, 'l' }, { 22, 31, 'm' }, { 20, 32, 'L' }, { 21, 32, 'l' },
    { 23, 31, 'l' }, { 24, 31, 'L' }, { 25, 31, 'L' }, { 26, 31, 'l' }, { 27, 31, 'm' }, { 23, 32, 'm' }, { 24, 32, 'l' }, { 25, 32, 'L' }, { 26, 32, 'm' }, { 27, 32, 'b' },
    { 24, 33, 'm' }, { 25, 33, 'l' }, { 26, 33, 'b' }, { 25, 34, 'b' },
    { 28, 31, 'm' }, { 29, 31, 'b' }, { 30, 31, 'b' }, { 31, 31, 's' }, { 29, 32, 'b' }, { 30, 32, 's' } }
  if fluff then for _, p in ipairs(RUFF) do hm:set(p[1] + ox, p[2] + oy) end end
  c:part(hm, { ws = 2, wl = 5, cast = false })
  -- crown light: a soft lit dome on the upper-left of the head
  L.ellipse(19 + ox, 12.5 + oy, 8.5, 3.2):each(function(x, y) local t = c:get(x, y) if t == 'm' then c:put(x, y, 'l', "light") end end)
  if fluff then for _, p in ipairs(RUFF) do c:put(p[1] + ox, p[2] + oy, p[3], "detail") end end
  -- form planes: lit left cheek, turned-away right cheek, brighter brow
  L.ellipse(14 + ox, 25 + oy, 4, 3):each(function(x, y) local t = c:get(x, y) if t == 'm' then c:put(x, y, 'l', "light") end end)
  L.ellipse(37 + ox, 24.5 + oy, 4.5, 3.6):each(function(x, y) local t = c:get(x, y) if t == 'm' or t == 'l' then c:put(x, y, L.step(t, -1), "shade") end end)
  L.ellipse(16 + ox, 12.5 + oy, 4.5, 2.2):each(function(x, y) local t = c:get(x, y) if t == 'l' then c:put(x, y, 'L', "light") end end)
  info.head = hm
  -- muzzle puff: two lit lobes under the nose
  local mz = L.ellipse(25 + ox, 26.5 + oy, 5.6, 2.4)
  mz:each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) then c:put(x, y, (t == 's' or t == 'b') and 'l' or 'L', "light") end end)
  L.ellipse(22 + ox, 27 + oy, 1.6, 1):add(L.ellipse(28 + ox, 27 + oy, 1.6, 1)):each(function(x, y) c:put(x, y, 'g', "light") end)
  info.muzzle = mz
  if ears ~= "folded" then
    -- inner ears: pink with a darker inner side, fur tuft at the base
    for _, P in ipairs({ { PINK_L, 1 }, { PINK_R, -1 } }) do
      local pm = L.spans(P[1], X0, oy):clip(earsM:filter(function(x, y) return earsM:has(x + 1, y) and earsM:has(x - 1, y) end))
      pm:each(function(x, y)
        local inner = P[2] == 1 and not pm:has(x + 1, y) or P[2] == -1 and not pm:has(x - 1, y)
        c:put(x, y, inner and 'P' or 'p', "detail")
      end)
    end
    c:stamp({ { X0 + 4, 8 + oy, 'L' }, { X0 + 5, 9 + oy, 'L' }, { X0 + 3, 9 + oy, 'l' },
              { X0 + 30, 8 + oy, 'L' }, { X0 + 29, 9 + oy, 'L' }, { X0 + 31, 9 + oy, 'l' } })
    -- quirk: the nick shows the pale edge of the cut
    if not opts.twitch then c:put(X0 + 30, 5 + oy, 'L', "detail") end
    info.ears = earsM
  else
    -- folded ears: small flat caps folded forward over the crown, tips down toward the cheeks
    local fl, fr = L.spans(FLAP_L, X0, oy), L.spans(FLAP_R, X0, oy)
    for i, f in ipairs({ fl, fr }) do
      c:part(f, { ws = 1, wl = 1 })
      -- the opening: a dark-pink line under the fold, inner ear just peeking out
      f:each(function(x, y) if not f:has(x, y + 1) and f:has(x, y - 1) and f:has(x - 1, y) and f:has(x + 1, y) then c:put(x, y, 'P', "detail") end end)
      -- fold crease: a lit ridge one row under the top
      f:each(function(x, y) if not f:has(x, y - 1) and f:has(x, y + 1) then c:put(x, y + 1, 'L', "light") end end)
    end
    info.flaps = fl:copy():add(fr)
  end
  -- forehead gloss
  c:stamp({ { 13 + ox, 12 + oy, 'g' }, { 14 + ox, 11 + oy, 'g' }, { 15 + ox, 11 + oy, 'g' }, { 16 + ox, 11 + oy, 'L' }, { 13 + ox, 13 + oy, 'L' } })
  -- cheek tufts: a lit strand into each spike, a shade notch under it
  c:stamp({ { 7 + ox, 22 + oy, 'L' }, { 8 + ox, 22 + oy, 'L' }, { 9 + ox, 22 + oy, 'l' }, { 8 + ox, 23 + oy, 'b' }, { 9 + ox, 23 + oy, 'l' },
            { 8 + ox, 24 + oy, 'l' }, { 9 + ox, 24 + oy, 'l' }, { 10 + ox, 25 + oy, 'b' },
            { 43 + ox, 22 + oy, 'r' }, { 42 + ox, 22 + oy, 'b' }, { 42 + ox, 23 + oy, 'D' }, { 42 + ox, 24 + oy, 'r' }, { 41 + ox, 24 + oy, 'b' }, { 40 + ox, 25 + oy, 'D' } })
  -- eyes (locked boxes)
  local prot = L.mask()
  for _, ex in ipairs({ 16, 34 }) do
    local cx, cy = ex + ox, 21 + oy
    for dy = -3, 3 do for dx = -3, 3 do prot:set(cx + dx, cy + dy) end end
    if eyes == "open" then
      c:stamp(L.stamp(EYE_OPEN, cx - 3, cy - 3))
    elseif eyes == "blink" then
      for dx = -2, 2 do c:put(cx + dx, cy, '#', "detail") end
      c:put(cx - 3, cy + 1, '#', "detail") c:put(cx + 3, cy + 1, '#', "detail")
    elseif eyes == "bored" then
      c:stamp(L.stamp(EYE_BORED, cx - 3, cy - 3))
    elseif eyes == "yawn" then
      local sg = (ex == 16) and 1 or -1
      for _, p in ipairs({ { -3, -3 }, { -2, -2 }, { -1, -1 }, { 0, 0 }, { -1, 1 }, { -2, 2 }, { -3, 3 },
                           { -2, -3 }, { -1, -2 }, { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 2 }, { -2, 3 } }) do c:put(cx + sg * p[1], cy + p[2], '#', "detail") end
    elseif eyes == "happy" then
      c:stamp({ { cx - 1, cy - 1, '#' }, { cx, cy - 1, '#' }, { cx + 1, cy - 1, '#' }, { cx - 2, cy, '#' }, { cx + 2, cy, '#' } })
    else -- sleep
      c:stamp({ { cx - 2, cy, '#' }, { cx + 2, cy, '#' }, { cx - 1, cy + 1, '#' }, { cx, cy + 1, '#' }, { cx + 1, cy + 1, '#' }, { cx - 3, cy - 1, '#' } })
    end
  end
  -- nose (cream glint, pink, ink tip) + mouth
  local face = { { 24, 24, 'c' }, { 25, 24, 'p' }, { 26, 24, 'P' }, { 25, 25, '#' }, { 25, 26, '#' }, { 23, 26, '#' }, { 27, 26, '#' }, { 24, 27, '#' }, { 26, 27, '#' },
                 { 12, 25, 'p' }, { 13, 25, 'p' }, { 37, 25, 'p' }, { 38, 25, 'p' } }
  for _, p in ipairs(face) do
    if not ((opts.mouth == "open" or opts.mouth == "yawn" or opts.mouth == "smile") and p[2] >= 26 and p[1] >= 23 and p[1] <= 27) then
      c:put(p[1] + ox, p[2] + oy, p[3], "detail") prot:set(p[1] + ox, p[2] + oy)
    end
  end
  if opts.mouth == "open" or opts.mouth == "yawn" or opts.mouth == "smile" then
    local big = opts.mouth ~= "smile"
    local my, rx, ry = big and 29.5 or 27.8, big and 3.8 or 2.9, big and 3.4 or 1.9
    if opts.mouth == "yawn" then my, rx, ry = 30.4, 5.2, 4.3 end
    local mo = L.ellipse(25 + ox, my + oy, rx, ry)
    mo:grow(1):cut(mo):each(function(x, y) c:put(x, y, '#', "detail") prot:set(x, y) end)
    mo:each(function(x, y) c:put(x, y, 'P', "detail") prot:set(x, y) end)
    L.ellipse(25 + ox, my + ry * 0.55 + oy, rx * 0.62, ry * 0.5):clip(mo):each(function(x, y) c:put(x, y, 'p', "detail") end)
  elseif opts.mouth == "tongue" then
    for _, p in ipairs({ { 25, 27, 'p' }, { 25, 28, 'p' }, { 26, 28, 'P' } }) do c:put(p[1] + ox, p[2] + oy, p[3], "detail") prot:set(p[1] + ox, p[2] + oy) end
  end
  info.protect = prot
end

-- helpers ------------------------------------------------------------------------------------------
local function shadow(c, cx, cy, rx, ry, rx2)
  L.ellipse(cx, cy, rx, ry):each(function(x, y) c:put(x, y, 'W', "shade", true) end)
  L.ellipse(cx, cy, rx2 or rx * 0.7, math.max(0.6, ry - 0.8)):each(function(x, y) c:put(x, y, 'U', "shade", true) end)
end
local CURTOES = {}
local function toes(c, xs, y0, y1) for _, x in ipairs(xs) do CURTOES[#CURTOES + 1] = { x, y0 } for y = y0, y1 do c:put(x, y, 's', "detail") end end end
-- tail radius: full at the root, slim mid, a fuller brush near the tip, pointed end
local function BRUSH(t)
  if t < 0.6 then return 2.6 - 1.2 * t end
  if t < 0.86 then return 1.88 + (t - 0.6) * 1.6 end
  return 2.3 - (t - 0.86) * 9
end
local function tailTip(c, list) for _, p in ipairs(list) do c:put(p[1], p[2], p[3], "detail") end end

local N4 = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
local function interior(c, x, y, r)   -- true if every pixel within r (chebyshev) is part of the object
  for dy = -r, r do for dx = -r, r do if not c:isObj(x + dx, y + dy) then return false end end end
  return true
end

-- POP: light from the upper-left rakes the silhouette edge; violet bounce light on the lower-right
local function pop(c, info, gy)
  local lit, mid = {}, {}
  c.obj:each(function(x, y)
    local t = c:get(x, y)
    if not t or info.protect:has(x, y) then return end
    local d = L.dist(c.obj, x, y, L.UL, 5)
    if d <= 2 and (t == 'm' or t == 'l' or t == 'b') then lit[#lit + 1] = { x, y, 'L' }
    elseif d <= 4 and (t == 'm' or t == 'b') then mid[#mid + 1] = { x, y, 'l' } end
  end)
  for _, p in ipairs(mid) do c:put(p[1], p[2], p[3], "light") end
  for _, p in ipairs(lit) do c:put(p[1], p[2], p[3], "light") end
  -- bounce rim, two px deep: edge 'r', next px in 'b' (stepped)
  local rim, inner = {}, {}
  c.obj:each(function(x, y)
    local t = c:get(x, y)
    if not t or not L.isCoat(t) or (gy and y >= gy - 1 and not c.obj:has(x, y + 1)) then return end
    local right, below = not c.obj:has(x + 1, y), not c.obj:has(x, y + 1)
    if (right and c.obj:has(x - 1, y)) or (below and c.obj:has(x, y - 1) and c.obj:has(x + 1, y)) then
      if t ~= 'g' and t ~= 'L' then rim[#rim + 1] = { x, y } end
      local ix, iy = right and x - 1 or x, (not right and below) and y - 1 or y
      local ti = c:get(ix, iy)
      if ti == 's' or ti == 'D' or ti == 'm' or ti == 'b' then inner[#inner + 1] = { ix, iy, 'r' } end
    end
  end)
  for _, p in ipairs(inner) do if not info.protect:has(p[1], p[2]) then c:put(p[1], p[2], p[3], "rim") end end
  for _, p in ipairs(rim) do c:put(p[1], p[2], 'r', "rim") end
  -- speculars: a soft gloss pair on the lit shoulder of each big form
  for _, m in ipairs({ info.chest, info.haunch }) do
    if m and m:count() > 0 then
      local x0, y0, x1, y1 = 99, 99, -9, -9
      m:each(function(x, y) if c:isObj(x, y) and not info.head:has(x, y) then x0 = math.min(x0, x) y0 = math.min(y0, y) x1 = math.max(x1, x) y1 = math.max(y1, y) end end)
      local gx, gy2 = floor(x0 + (x1 - x0) * 0.3), floor(y0 + (y1 - y0) * 0.24)
      for _, p in ipairs({ { 0, 0, 'g' }, { 1, 0, 'g' }, { -1, 1, 'L' }, { 0, 1, 'L' }, { 2, 0, 'L' }, { 0, -1, 'L' } }) do
        local t = c:get(gx + p[1], gy2 + p[2])
        if t and L.isCoat(t) and c:isObj(gx + p[1], gy2 + p[2]) and not info.head:has(gx + p[1], gy2 + p[2]) and not (info.fish and info.fish:has(gx + p[1], gy2 + p[2])) then c:put(gx + p[1], gy2 + p[2], p[3], "light") end
      end
    end
  end
end

-- TEXTURE (pass 2/3) ---------------------------------------------------------------------------------
local function hash(x, y, s) local n = (x * 73856093 ~ y * 19349663 ~ (s or 0) * 83492791) & 0x7fffffff return (n % 1000) / 1000 end
local TEXOK = { s = true, b = true, m = true, l = true }
-- one fur stroke: root darker, middle as is, tip lighter; refuses to touch outline margin, eyes, face details
local function stroke(c, info, used, x, y, dx, dy, n, o)
  local pts = {}
  local len = math.sqrt(dx * dx + dy * dy)
  if len == 0 then return false end
  dx, dy = dx / len, dy / len
  for i = 0, n - 1 do
    local px, py = floor(x + dx * i + 0.5), floor(y + dy * i + 0.5)
    local last = pts[#pts]
    if not last or last[1] ~= px or last[2] ~= py then pts[#pts + 1] = { px, py } end
  end
  if #pts < 2 then return false end
  for _, p in ipairs(pts) do
    local t = c:get(p[1], p[2])
    local k = K(p[1], p[2])
    if not t or not TEXOK[t] or used[k] or info.protect:has(p[1], p[2]) or not interior(c, p[1], p[2], o.margin) then return false end
    if o.guard and o.guard:has(p[1], p[2]) then return false end
    if o.region and not o.region:has(p[1], p[2]) then return false end
  end
  for i, p in ipairs(pts) do
    local t = c:get(p[1], p[2])
    local nt
    if i == 1 then nt = (t == 's') and 'D' or L.step(t, -1)
    elseif i < #pts and o.dark2 then nt = (t == 's') and 'D' or L.step(t, -1)
    elseif i == #pts then nt = (t == 'l' and o.lightTips) and 'L' or L.step(t, 1) if t == 's' then nt = 'b' end
    end
    if nt and nt ~= t then c:put(p[1], p[2], nt, (L.LADDER[nt] or 0) >= 5 and "light" or "shade") used[K(p[1], p[2])] = true else used[K(p[1], p[2])] = true end
  end
  return true
end
local function lattice(c, info, used, region, sx, sy, dirf, n, o)
  local y0, y1, x0, x1 = 99, -99, 99, -99
  region:each(function(x, y) y0 = math.min(y0, y) y1 = math.max(y1, y) x0 = math.min(x0, x) x1 = math.max(x1, x) end)
  o.region = region
  local row = 0
  for y = y0, y1, sy do
    row = row + 1
    for x = x0 + ((row % 2 == 0) and sx // 2 or 0), x1, sx do
      local jx, jy = 0, 0
      if o.jitter then jx = floor(hash(x, y, 1) * 3) - 1 jy = floor(hash(x, y, 2) * 2) end
      local px, py = x + jx, y + jy
      if region:has(px, py) then
        local dx, dy = dirf(px, py)
        local len = n + ((o.jitter and hash(px, py, 3) > 0.5) and 1 or 0)
        stroke(c, info, used, px, py, dx, dy, len, o)
      end
    end
  end
end
local function tailStrokes(c, info, used, o)
  if not info.tailPts or not info.tail then return end
  local cv = L.curve(info.tailPts)
  local i = 1
  local idx = 3
  while idx <= #cv - 2 do
    local step = (idx > 0.78 * #cv) and math.max(2, o.tailStep - 2) or o.tailStep
    local p, q = cv[idx], cv[math.min(#cv, idx + 4)]
    local dx, dy = q[1] - p[1], q[2] - p[2]
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
      local nx, ny = -dy / len, dx / len
      local off = ({ 0, 1, 0, -1 })[(i % 4) + 1] * (o.tailOff or 1)
      stroke(c, info, used, p[1] + nx * off, p[2] + ny * off, dx, dy, o.tailLen or 3, { margin = o.tmargin or 0, lightTips = true, region = info.tail })
    end
    i = i + 1
    idx = idx + step
  end
end
local function texture(c, info)
  local used = {}
  local P3 = PASS >= 3
  local base = { margin = 1, lightTips = false, jitter = not P3, dark2 = false, guard = info.protect:grow(P3 and 2 or 0) }
  local SX, SY = P3 and 5 or 4, P3 and 4 or 3
  local headM, ox, oy = info.head, info.ox, info.oy
  local function copy(o) local n = {} for k, v in pairs(base) do n[k] = v end for k, v in pairs(o or {}) do n[k] = v end return n end
  local bodyR = info.chest:copy():add(info.haunch):cut(headM):cut(info.paws or L.mask())
  if info.fish then bodyR:cut(info.fish:grow(1)) end
  bodyR = bodyR:filter(function(x, y) return c:isObj(x, y) end)
  local fr = info.frame
  local cx = (fr == "nap") and 43 or 25
  local function down(x, y)    -- fur falls down and slightly outward from the centre line
    return (x - cx) * 0.4 + ((y % 2 == 0) and 0.25 or -0.25), 1
  end
  local function arc(x, y)     -- follows the haunch curve: tangent around the haunch centre
    local u, v = x - info.hcx, y - info.hcy
    return -v * 1.1 - 0.3, u * 0.8 + 0.7
  end
  if fr == "idleA" or fr == "catch" then
    lattice(c, info, used, bodyR:filter(function(x, y) return y >= 41 end), SX, SY, arc, 3, copy())
    lattice(c, info, used, bodyR:filter(function(x, y) return y < 41 end), SX, SY, down, 3, copy({ margin = 1 }))
    lattice(c, info, used, info.legs:copy():cut(headM):cut(info.paws), 4, 4, function() return 0, 1 end, 3, copy())
  elseif fr == "pounce" then
    lattice(c, info, used, bodyR, SX, SY, function(x, y) return 1, (y - 36) * 0.1 + 0.15 end, 3, copy())
    lattice(c, info, used, info.haunch:copy():cut(headM), SX, SY, arc, 3, copy())
    lattice(c, info, used, info.legs:copy():cut(headM), 5, 4, function(x, y) return 1, 0.45 end, 3, copy())
  else
    lattice(c, info, used, bodyR, SX, SY, function(x, y) return -0.8, (y - 47) * 0.12 + 0.7 end, 3, copy())
    lattice(c, info, used, info.haunch:copy():cut(headM), SX, SY, arc, 3, copy())
  end
  -- cheek / head fur: short strokes radiating from the muzzle, only on the cheek rims and brow
  local hr = headM:filter(function(x, y) return c:isObj(x, y) end)
  local cheeks = hr:filter(function(x, y) return (math.abs(x - (25 + ox)) >= 8 and y >= 17 + oy and y <= 29 + oy) or (y <= 12 + oy and math.abs(x - (25 + ox)) >= 3) end)
  lattice(c, info, used, cheeks, P3 and 4 or 3, 2, function(x, y)
    if y <= 12 + oy then return (x - (25 + ox)) * 0.25, 1 end
    return (x < 25 + ox) and -1 or 1, 0.55
  end, 2, copy({ margin = 1 }))
  tailStrokes(c, info, used, copy({ tailStep = P3 and 4 or 3, tailLen = 3, tailOff = P3 and 0 or 1 }))
  -- p3: remove any texture pixel that has no texture neighbour (no stray noise)
  if P3 then
    for k in pairs(used) do
      local x, y = L.XY(k)
      local nb = 0
      for dy = -1, 1 do for dx = -1, 1 do if (dx ~= 0 or dy ~= 0) and used[K(x + dx, y + dy)] then nb = nb + 1 end end end
      if nb == 0 then used[k] = nil end
    end
  end
  return used
end

local function extras(c, info, gy)
  local ox, oy = info.ox, info.oy
  if not FINAL then
  -- whisker pops: two fine light strokes per cheek, inside the face
  local WL = { { 18, 27, 'g' }, { 17, 27, 'g' }, { 16, 26, 'L' }, { 15, 26, 'L' }, { 18, 28, 'L' }, { 17, 28, 'L' }, { 16, 29, 'l' } }
  for _, p in ipairs(WL) do
    local x1, x2 = p[1] + ox, 50 - p[1] + ox
    for _, x in ipairs({ x1, x2 }) do
      local t = c:get(x, p[2] + oy)
      if t and L.isCoat(t) and not (x == x2 and PASS >= 3 and p[3] == 'l') then c:put(x, p[2] + oy, p[3], "detail") end
    end
  end
  -- paw pad texture: a lit knuckle above each toe line, flanking toe-top highlights
  for _, tp in ipairs(CURTOES) do
    local x, y = tp[1], tp[2]
    local t = c:get(x, y - 1)
    if t and L.isCoat(t) and t ~= 's' and t ~= 'D' then c:put(x, y - 1, 'L', "light") end
    for _, dx in ipairs({ -1, 1 }) do
      local tt = c:get(x + dx, y)
      if tt and (tt == 'm' or tt == 'b') then c:put(x + dx, y, 'l', "light") end
    end
  end
  -- inner-ear fluff: cream hairs crossing the pink
  if info.ears then
    local X0 = 8 + ox
    for _, p in ipairs({ { 5, 7 }, { 4, 6 }, { 29, 7 }, { 30, 6 }, { 5, 8 }, { 29, 8 } }) do
      local t = c:get(X0 + p[1], p[2] + oy)
      if t == 'p' or t == 'P' then c:put(X0 + p[1], p[2] + oy, 'c', "detail") end
    end
  end
  end
  if PASS < 3 then return end
  -- ambient dark rows where a part meets what is behind it (head onto chest, arms/legs onto body, tail root)
  local function ambient(front, behindOK)
    local r1, r2 = {}, {}
    front:each(function(x, y)
      for _, d in ipairs({ { 0, 1 }, { 1, 0 } }) do
        local qx, qy = x + d[1], y + d[2]
        if not front:has(qx, qy) and c:isObj(qx, qy) and behindOK(qx, qy) then
          local t = c:get(qx, qy)
          if t and L.isCoat(t) and L.LADDER[t] > 2 then r1[#r1 + 1] = { qx, qy } end
          local px, py = qx + d[1], qy + d[2]
          local t2 = c:get(px, py)
          if not front:has(px, py) and t2 and L.isCoat(t2) and L.LADDER[t2] > 3 and behindOK(px, py) then r2[#r2 + 1] = { px, py } end
        end
      end
    end)
    for _, p in ipairs(r2) do c:put(p[1], p[2], 'b', "shade") end
    for _, p in ipairs(r1) do c:put(p[1], p[2], 's', "shade") end
  end
  local notFace = function(x, y) return not info.protect:has(x, y) and not (info.fish and info.fish:has(x, y)) end
  ambient(info.head, function(x, y) return notFace(x, y) and not info.head:has(x, y) end)
  if info.legs and info.legs:count() > 0 then ambient(info.legs, function(x, y) return notFace(x, y) and not info.head:has(x, y) end) end
  -- rim-light fur flicks
  if FINAL then
    -- only two: the lower-right-most rim pixel, and one >= 9px away along the silhouette
    local cand = {}
    c.obj:each(function(x, y)
      if c:get(x, y) == 'r' then
        local ix, iy = (not c.obj:has(x + 1, y)) and x - 1 or x, (c.obj:has(x + 1, y)) and y - 1 or y
        local t = c:get(ix, iy)
        if (t == 'b' or t == 's' or t == 'D') and not info.protect:has(ix, iy) and not (gy and y >= gy - 3) then cand[#cand + 1] = { x, y, ix, iy, x + y * 1.3 } end
      end
    end)
    table.sort(cand, function(a, b) if a[5] ~= b[5] then return a[5] > b[5] end if a[2] ~= b[2] then return a[2] > b[2] end return a[1] > b[1] end)
    local picked = {}
    for _, p in ipairs(cand) do
      local okp = true
      for _, q in ipairs(picked) do if math.abs(p[1] - q[1]) + math.abs(p[2] - q[2]) < 9 then okp = false end end
      if okp and #picked < 2 then picked[#picked + 1] = p c:put(p[3], p[4], 'r', "rim") end
    end
    return
  end
  local n = 0
  c.obj:each(function(x, y)
    if c:get(x, y) == 'r' then
      n = n + 1
      if n % 3 == 0 then
        local ix, iy = (not c.obj:has(x + 1, y)) and x - 1 or x, (c.obj:has(x + 1, y)) and y - 1 or y
        local t = c:get(ix, iy)
        if t == 'b' or t == 's' or t == 'D' then c:put(ix, iy, 'r', "rim") end
      end
    end
  end)
end

local function finish(c, info, gy)
  if gy then c:contact(gy) end
  if PASS == 2 or PASS == 3 then info.tex = texture(c, info) end
  pop(c, info, gy)
  if info.after then info.after(c) end
  if PASS >= 2 then extras(c, info, gy) end
  CURTOES = {}
  c:outline()
  if PASS == 3 and gy then   -- contact shadow: a darker pool where the paws meet the ground
    c.obj:each(function(x, y)
      if y >= gy - 1 and not c.obj:has(x, y + 1) and c:get(x, y) == 'D' and c:get(x, y + 2) == 'W' then c:put(x, y + 2, 'U', "shade", true) end
    end)
  end
end

-- FRAMES -------------------------------------------------------------------------------------------
local function tailIdle(c, info, bob, pts0, tip0)
  if bob then
    local m = L.ellipse(39.5, 52.5, 3, 2.6)
    c:part(m, { ws = 1, wl = 1 })
    info.tail = m info.tailT = {}
    c:stamp({ { 38, 51, 'g' }, { 39, 50, 'L' }, { 42, 52, 'r' } })
    return
  end
  local pts = pts0 or { { 36, 54 }, { 44, 55 }, { 50, 53 }, { 54, 48 }, { 55, 42 }, { 53, 36 }, { 52, 33 } }
  local m, T = L.tube(pts, BRUSH)
  c:part(m, { ws = 1, wl = 2 })
  info.tail, info.tailT, info.tailPts = m, T, pts
  tailTip(c, tip0 or { { 52, 34, 'g' }, { 51, 35, 'L' }, { 52, 36, 'L' }, { 54, 37, 's' } })
end

-- lift everything painted so far (body, limbs, tail) by dy rows; the head is painted afterwards at its own height
local function shiftBody(c, info, dy)
  local nt, nl, no = {}, {}, L.mask()
  for k, t in pairs(c.t) do local x, y = L.XY(k) nt[K(x, y + dy)] = t nl[K(x, y + dy)] = c.ly[k] end
  c.obj:each(function(x, y) no:set(x, y + dy) end)
  c.t, c.ly, c.obj = nt, nl, no
  for _, n in ipairs({ "legs", "paws", "chest", "haunch", "tail" }) do if info[n] then info[n] = info[n]:shift(0, dy) end end
  if info.tailT then local T = {} for k, v in pairs(info.tailT) do local x, y = L.XY(k) T[K(x, y + dy)] = v end info.tailT = T end
  if info.tailPts then local P = {} for i, p in ipairs(info.tailPts) do P[i] = { p[1], p[2] + dy } end info.tailPts = P end
  if info.hcy then info.hcy = info.hcy + dy end
end

local function sit(o, cfg, frame)
  cfg = cfg or {}
  local hx, hy = cfg.hx or 0, cfg.hy or 0
  local c, info = L.canvas(64, 64), { frame = frame, ox = hx, oy = hy, bdy = cfg.hop and -cfg.hop or 0 }
  if not cfg.hop then shadow(c, 28, 57.5, 20, 2, 13) end
  tailIdle(c, info, o.tail == "bobtail", cfg.tailPts, cfg.tailTip)
  local haunch = L.ellipse(25, 47, 15, 9.6)
  c:part(haunch, { ws = 3, wl = 4 })
  local feet = L.ellipse(13, 54.6, 3.6, 1.8):add(L.ellipse(37, 54.6, 3.6, 1.8))
  c:part(feet, { ws = 1, wl = 1 })
  local chest = L.ellipse(25, 37, 10.6, 8.6)
  local legL = L.poly({ { 16.4, 40 }, { 22.4, 38 }, { 22.4, 53 }, { 17.4, 53 } })
  local legR = L.poly({ { 27.6, 38 }, { 33.6, 40 }, { 32.6, 53 }, { 27.6, 53 } })
  local front = chest:copy():add(legL):add(legR)
  c:part(front, { ws = 2, wl = 4 })
  -- belly light: a pale bib down the chest
  L.ellipse(25, 38, 4.2, 6):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and front:has(x, y) then c:put(x, y, L.step(t, 1), "light") end end)
  -- leg creases: one shade line where each leg turns under the chest
  for y = 47, 52 do c:put(22, y, 's', "shade") end
  local paws = L.ellipse(19.5, 54.4, 3.6, 2.1):add(L.ellipse(30.5, 54.4, 3.6, 2.1))
  c:part(paws, { ws = 1, wl = 1, noao = true })
  toes(c, { 18, 21, 29, 32 }, 55, 56)
  toes(c, { 12, 14, 36, 38 }, 55, 56)
  info.legs = legL:copy():add(legR) info.paws = paws:copy():add(feet) info.chest = chest info.haunch = haunch
  info.hcx, info.hcy, info.hrx, info.hry = 25, 47, 15, 9.6
  if cfg.armsUp then cfg.armsUp(c, info) end
  if cfg.hop then shiftBody(c, info, -cfg.hop) end
  head(c, info, hx, hy, cfg.eyes or "open", o.ears, true, cfg.opts)
  -- chest fluff: three lit spikes hanging under the chin
  -- thigh crease where each haunch turns into the front leg
  c:stamp({ { 14, 44, 'b' }, { 15, 45, 'b' }, { 16, 46, 'b' }, { 36, 44, 'b' }, { 35, 45, 'b' }, { 34, 46, 'b' }, { 15, 44, 'L' }, { 16, 45, 'l' } }, "detail")
  if cfg.arm then cfg.arm(c, info) end
  finish(c, info, not cfg.hop and 56 or nil)
  if cfg.hop then shadow(c, 28, 58.2, 12, 1.9, 7) end
  return c, info
end
CATS.idleA = function(o) return sit(o, {}, "idleA") end

CATS.catch = function(o)
  local c, info = L.canvas(64, 64), { frame = "catch", ox = 0, oy = 0 }
  shadow(c, 28, 57.5, 20, 2, 13)
  if o.tail == "bobtail" then tailIdle(c, info, true) else
    local pts = { { 36, 54 }, { 45, 54 }, { 50, 50 }, { 52, 44 }, { 50, 39 }, { 46, 36 }, { 43, 36 } }
    local m, T = L.tube(pts, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT, info.tailPts = m, T, pts
    tailTip(c, { { 45, 35, 'g' }, { 46, 35, 'L' }, { 44, 35, 'L' } })
  end
  local haunch = L.ellipse(25, 47, 15, 9.6)
  c:part(haunch, { ws = 3, wl = 4 })
  local feet = L.ellipse(13, 54.6, 3.6, 1.8):add(L.ellipse(37, 54.6, 3.6, 1.8)):add(L.ellipse(20, 55, 3.2, 1.6)):add(L.ellipse(30, 55, 3.2, 1.6))
  c:part(feet, { ws = 1, wl = 1 })
  toes(c, { 12, 14, 36, 38, 19, 21, 29, 31 }, 55, 56)
  local chest = L.ellipse(25, 37, 10.6, 8.6)
  c:part(chest, { ws = 2, wl = 4 })
  L.ellipse(25, 47, 4, 4):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and y < 53 then c:put(x, y, L.step(t, 1), "light") end end)
  -- arms: shoulder, elbow tucked in, forearm up to the paws gripping the fish
  local armL = L.tube({ { 15.5, 33 }, { 15, 37 }, { 17, 41 } }, function(t) return 2.4 - 0.5 * t end)
  local armR = L.tube({ { 34.5, 33 }, { 35, 37 }, { 33, 41 } }, function(t) return 2.4 - 0.5 * t end)
  c:part(armL, { ws = 1, wl = 2, ao = false }) c:part(armR, { ws = 1, wl = 1, ao = false })
  -- the fish (fixed accent colours, never recoloured): big, held across the belly, head left, tail right
  local FISH = {
    "..........ddddd...........",
    "........ddyYYYyydd....dd..",
    "......ddyYYYYyyyyodd.dffd.",
    "....ddyYYwwyyyyyoooOddfffd",
    "...dyYYYw##yyyyooooOOdffd.",
    "..dyyYYYw##yyyoooooOOOdfd.",
    "..dyyyYYyyyyooooooOOOOd...",
    "...dooyyyyoooooooOOOOdd...",
    "....ddoOOOOOOOOOOOOdd.....",
    "......dddOOOOOOddd........",
    "........ddddddd...........",
  }
  local FC = { d = "#ac3b1d", O = "#dc6f2c", o = "#e38111", y = "#f2a860", Y = "#ffc27a", w = "#fff1c8", f = "#f2c14e", ['#'] = '#' }
  local fm = L.mask()
  for j, row in ipairs(FISH) do for i = 1, #row do local ch = row:sub(i, i)
    if ch ~= '.' then c:put(11 + i, 35 + j, FC[ch], "detail") fm:set(11 + i, 35 + j) end end end
  info.fishBox = fm
  -- paws wrap over the fish belly: lit back of the paw, three toe lines
  local paws = L.ellipse(18.5, 44.5, 3, 2.2):add(L.ellipse(32, 44.5, 3, 2.2))
  c:part(paws, { ws = 1, wl = 1, noao = true })
  toes(c, { 17, 19, 31, 33 }, 45, 46)
  info.legs = armL:copy():add(armR) info.paws = paws:copy():add(feet) info.chest = chest info.haunch = haunch
  info.fish = fm
  info.hcx, info.hcy, info.hrx, info.hry = 25, 47, 15, 9.6
  head(c, info, 0, 0, "happy", o.ears, true)
  finish(c, info, 56)
  return c, info
end

CATS.pounce = function(o)
  local c, info = L.canvas(64, 64), { frame = "pounce", ox = 16, oy = 0 }
  shadow(c, 31, 58.5, 14, 1.5, 9)
  -- tail streaming up-left
  if o.tail == "bobtail" then
    local m = L.ellipse(9.5, 31.5, 2.8, 2.8) c:part(m, { ws = 1, wl = 1 }) info.tail = m info.tailT = {}
    c:stamp({ { 8, 30, 'g' }, { 9, 29, 'L' } })
  else
    local pts = { { 12, 33 }, { 8, 28 }, { 6, 21 }, { 7, 14 }, { 10, 9 }, { 13, 7 } }
    local m, T = L.tube(pts, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT, info.tailPts = m, T, pts
    tailTip(c, { { 10, 8, 'g' }, { 11, 7, 'L' }, { 9, 9, 'L' } })
  end
  -- far legs (one step darker): far hind trailing, far front reaching with a bent elbow
  local farHind = L.tube({ { 18, 40 }, { 15.5, 45 }, { 14, 49 } }, function(t) return 2.1 - 0.8 * t end)
  local farFront = L.tube({ { 37, 35 }, { 43, 37.5 }, { 48, 37 }, { 52, 38.5 } }, function(t) return 2.3 - 0.9 * t end)
  c:part(farHind, { ws = 1, wl = 1, lift = -1 }) c:part(farFront, { ws = 1, wl = 1, lift = -1 })
  local farPaws = L.ellipse(14, 50.6, 3, 1.7):add(L.ellipse(54.2, 38.8, 2.8, 2.1))
  c:part(farPaws, { ws = 1, wl = 1, lift = -1, noao = true })
  -- torso: rump, tucked waist, shoulder mass (arched back, belly tucked up)
  local waist = L.ellipse(22, 35.4, 8.5, 4.3)
  local shoulder = L.ellipse(31.5, 35.2, 7.2, 5.6)
  local torso = waist:copy():add(shoulder)
  c:part(torso, { ws = 2, wl = 3 })
  local haunch = L.ellipse(14, 36.6, 7.4, 6.8)
  c:part(haunch, { ws = 2, wl = 3 })
  -- near hind leg: thigh bulge -> knee -> shin -> hock -> long foot pushing off
  local hind = L.tube({ { 10, 41 }, { 7, 45 }, { 5.2, 49 } }, function(t) return 2.7 - 1.2 * t end)
  c:part(hind, { ws = 1, wl = 1 })
  local hock = L.ellipse(5.6, 47.3, 1.9, 1.9)
  c:part(hock, { ws = 1, wl = 1, ao = false })
  local foot = L.ellipse(4, 51.6, 3.9, 1.7)
  c:part(foot, { ws = 1, wl = 1, noao = true })
  toes(c, { 1, 3, 5 }, 52, 53)
  -- near front leg: shoulder -> upper arm -> elbow -> slim forearm -> wrist -> paw
  local upper = L.tube({ { 33, 37 }, { 38.5, 41 } }, function(t) return 3.3 - 0.7 * t end)
  local elbow = L.ellipse(39.8, 42, 2.6, 2.4)
  local fore = L.tube({ { 40, 42 }, { 46, 43.4 } }, function(t) return 2.2 - 0.7 * t end)
  c:part(upper, { ws = 1, wl = 2 }) c:part(elbow, { ws = 1, wl = 1, ao = false }) c:part(fore, { ws = 1, wl = 1 })
  local paw = L.ellipse(49.6, 44.3, 3.6, 2.5)
  c:part(paw, { ws = 1, wl = 1, noao = true })
  toes(c, { 49, 51, 53 }, 45, 46)
  -- belly light on the stretched underside, a spine glint, flank plane
  L.ellipse(27, 39.2, 6, 1.8):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and torso:has(x, y) then c:put(x, y, L.step(t, 1), "light") end end)
  c:stamp({ { 19, 31, 'L' }, { 20, 31, 'L' }, { 21, 31, 'l' }, { 26, 30, 'L' }, { 27, 29, 'L' }, { 28, 29, 'L' } }, "light")
  info.legs = upper:copy():add(fore):add(elbow):add(hind):add(hock):add(farHind):add(farFront) info.paws = paw:copy():add(foot):add(farPaws) info.chest = torso info.haunch = haunch
  info.hcx, info.hcy, info.hrx, info.hry = 24.5, 35.5, 14.5, 6.6
  head(c, info, 16, 0, "open", o.ears)
  info.after = function(c)
    c:stamp({ { 12, 30, 'L' }, { 13, 30, 'g' }, { 10, 32, 'L' } })
  end
  finish(c, info, nil)
  return c, info
end

CATS.nap = function(o)
  local c, info = L.canvas(64, 64), { frame = "nap", ox = 0, oy = 18 }
  shadow(c, 37, 58, 25, 2, 18)
  local body = L.ellipse(43, 47.5, 18, 9.2)
  c:part(body, { ws = 3, wl = 4 })
  local hip = L.ellipse(51, 46, 9.5, 9.5)
  c:part(hip, { ws = 3, wl = 4 })
  if o.tail == "bobtail" then
    local m = L.ellipse(59.5, 52, 2.8, 2.6) c:part(m, { ws = 1, wl = 1 }) info.tail = m info.tailT = {}
    c:stamp({ { 58, 51, 'L' }, { 59, 50, 'L' } })
  else
    local pts = { { 58, 52 }, { 54, 55.5 }, { 44, 56.5 }, { 32, 56.5 }, { 22, 55.5 }, { 15, 53.5 }, { 11, 52 } }
    local m, T = L.tube(pts, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT, info.tailPts = m, T, pts
    tailTip(c, { { 13, 52, 'g' }, { 14, 52, 'L' }, { 12, 53, 'L' } })
  end
  local paws = L.ellipse(17, 49.5, 4.2, 2.2):add(L.ellipse(32.5, 49.5, 4.2, 2.2))
  c:part(paws, { ws = 1, wl = 1 })
  toes(c, { 15, 18, 31, 34 }, 50, 51)
  info.legs = L.mask() info.paws = paws info.chest = body info.haunch = hip
  info.hcx, info.hcy, info.hrx, info.hry = 51, 46, 9.5, 9.5
  head(c, info, 0, 18, "sleep", o.ears)
  info.after = function(c)
    -- back fur tuft on the hip, lit
    c:stamp({ { 47, 37, 'g' }, { 48, 37, 'L' }, { 46, 38, 'L' }, { 51, 37, 'L' } })
  end
  finish(c, info, 57)
  return c, info
end

-- ROLLOUT frames (the other 15): sitting family reuses sit(), the five action poses are built like pounce/nap ------------
local function limb(c, info, pts, r0, r1, o)
  local m, T = L.tube(pts, function(t) return r0 + (r1 - r0) * t end)
  c:part(m, o or { ws = 1, wl = 2 })
  info.legs = info.legs:copy():add(m)
  info.limbs = info.limbs or {}
  info.limbs[#info.limbs + 1] = { m, T }
  return m
end
local function paw(c, info, cx, cy, rx, ry, o)
  local m = L.ellipse(cx, cy, rx, ry)
  c:part(m, o or { ws = 1, wl = 1, noao = true })
  info.paws = info.paws:copy():add(m)
  return m
end
local function raisedPaw(c, info, cx, cy, pads)
  local pm = L.ellipse(cx, cy, 3.5, 2.8)
  local ring = pm:grow(1):cut(pm)
  local over = L.mask()
  ring:each(function(x, y) if c:isObj(x, y) and c:get(x, y) ~= '#' then over:set(x, y) end end)
  paw(c, info, cx, cy, 3.5, 2.8, { ws = 1, wl = 1, noao = true, lift = 2 })
  over:each(function(x, y) c:put(x, y, '#', "outline") end)
  local fx, fy = floor(cx), floor(cy)
  if pads then
    for _, p in ipairs({ { 0, 1, 'P' }, { 1, 1, 'P' }, { -1, -1, 'p' }, { 0, -2, 'p' }, { 1, -2, 'p' }, { 2, -1, 'p' } }) do
      c:put(fx + p[1], fy + p[2], p[3], "detail")
    end
  else
    -- lit back of the paw: three toe lines, each topped by a bright knuckle
    for _, dx in ipairs({ -1, 1 }) do c:put(fx + dx, fy, 's', "detail") c:put(fx + dx, fy + 1, 'b', "detail") c:put(fx + dx, fy - 1, 'L', "light") end
    c:put(fx, fy - 2, 'g', "light") c:put(fx - 2, fy - 1, 'L', "light") c:put(fx + 2, fy - 1, 'L', "light")
  end
end
local TP2 = { { 36, 54 }, { 45, 55 }, { 51, 53 }, { 55, 47 }, { 57, 40 }, { 56, 34 }, { 54, 31 } }
local TT2 = { { 54, 32, 'g' }, { 55, 33, 'L' }, { 54, 34, 'L' }, { 56, 35, 's' } }
local TPF = { { 36, 54 }, { 45, 55 }, { 52, 54 }, { 57, 51 }, { 60, 46 }, { 61, 41 }, { 59, 38 } }
local TTF = { { 59, 39, 'g' }, { 60, 40, 'L' }, { 59, 41, 'L' }, { 61, 42, 's' } }

CATS.idleB = function(o) return sit(o, { hx = 1, hy = 1, tailPts = TP2, tailTip = TT2 }, "idleB") end
CATS.blink = function(o) return sit(o, { eyes = "blink" }, "blink") end
CATS.eartwitch = function(o) return sit(o, { opts = { twitch = true } }, "eartwitch") end
CATS.tailflick = function(o) return sit(o, { tailPts = TPF, tailTip = TTF }, "tailflick") end
CATS.yawn = function(o) return sit(o, { hy = -1, eyes = "yawn", opts = { mouth = "yawn" } }, "yawn") end
local DARMS = { ws = 1, wl = 1, lift = -1 }
CATS.bored = function(o) return sit(o, { hx = -1, hy = 3, eyes = "bored", arm = function(c, info)
  limb(c, info, { { 32, 43 }, { 37.5, 45 }, { 39, 40.5 } }, 2.5, 2.2, DARMS)
  raisedPaw(c, info, 39.5, 37, false)
end }, "bored") end
CATS.washA = function(o) return sit(o, { eyes = "sleep", arm = function(c, info)
  limb(c, info, { { 32, 42 }, { 38, 44 }, { 39.5, 39 } }, 2.5, 2.2, DARMS)
  raisedPaw(c, info, 39.5, 35.5, false)
end }, "washA") end
CATS.washB = function(o) return sit(o, { hx = 2, hy = 3, eyes = "sleep", opts = { mouth = "tongue" }, arm = function(c, info)
  limb(c, info, { { 32, 43 }, { 38.5, 45 }, { 40, 40.5 } }, 2.5, 2.2, DARMS)
  raisedPaw(c, info, 40.5, 37.5, false)
end }, "washB") end
CATS.swatA = function(o) return sit(o, { hx = -2, hy = 3, arm = function(c, info)
  limb(c, info, { { 34, 40 }, { 40, 32 }, { 45, 24 } }, 2.5, 2.0)
  raisedPaw(c, info, 46.5, 20.5, true)
end }, "swatA") end
CATS.happy = function(o) return sit(o, { hop = 3, eyes = "happy", opts = { mouth = "smile" }, armsUp = function(c, info)
  for _, s in ipairs({ { 15, 7, 5, 1 }, { 35, 43, 45, -1 } }) do
    limb(c, info, { { s[1], 38 }, { s[2], 32 }, { s[3], 21 } }, 2.4, 2.0)
    raisedPaw(c, info, s[3] + 0.5, 18.5, false)
  end
end }, "happy") end

local BOB = { stalk = { 5, 35 }, wiggle = { 4, 30 }, stretch = { 4, 22 }, swatB = { 4, 43 } }
local function crouch(o, frame, ox, oy, eyes, build, tailPts, tipList, gy)
  local c, info = L.canvas(64, 64), { frame = frame, ox = ox, oy = oy }
  info.legs, info.paws = L.mask(), L.mask()
  shadow(c, 30, 58, 22, 2, 15)
  if o.tail == "bobtail" then
    local bp = BOB[frame]
    local m = L.ellipse(bp[1], bp[2], 2.8, 2.8) c:part(m, { ws = 1, wl = 1 }) info.tail = m info.tailT = {}
    c:stamp({ { bp[1] - 1, bp[2] - 1, 'g' }, { bp[1], bp[2] - 2, 'L' } })
  else
    local m, T = L.tube(tailPts, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT, info.tailPts = m, T, tailPts
    tailTip(c, tipList)
  end
  build(c, info)
  head(c, info, ox, oy, eyes, o.ears, false, nil)
  if info.after then info.after(c) end
  finish(c, info, gy)
  return c, info
end

CATS.jump = function(o)
  local c, info = L.canvas(64, 64), { frame = "jump", ox = 9, oy = 2 }
  info.legs, info.paws = L.mask(), L.mask()
  shadow(c, 30, 60, 11, 1.4, 7)
  -- tail whips straight up behind the haunch
  local tp = { { 21, 48 }, { 14, 47 }, { 8, 41 }, { 6, 33 }, { 8, 26 }, { 11, 22 } }
  if o.tail == "bobtail" then
    local m = L.ellipse(10.5, 43.5, 2.8, 2.8) c:part(m, { ws = 1, wl = 1 }) info.tail = m info.tailT = {}
    c:stamp({ { 9, 42, 'g' }, { 10, 41, 'L' } })
  else
    local m, T = L.tube(tp, BRUSH) c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT, info.tailPts = m, T, tp
    tailTip(c, { { 11, 23, 'g' }, { 10, 24, 'L' }, { 12, 24, 'L' } })
  end
  -- far hind leg trailing, far arm reaching forward-low (one step darker)
  limb(c, info, { { 26, 47 }, { 20, 52 }, { 14, 54 } }, 2.6, 2.0, { ws = 1, wl = 1, lift = -1 })
  paw(c, info, 12.5, 54.4, 3.2, 1.8, { ws = 1, wl = 1, lift = -1, noao = true })
  limb(c, info, { { 42, 42 }, { 50, 44 }, { 58, 40 } }, 3.0, 2.2, { ws = 1, wl = 1, lift = -1 })
  paw(c, info, 60, 39, 3.2, 2.4, { ws = 1, wl = 1, lift = -1, noao = true })
  -- body: full rump + chest, stretched into the leap
  local haunch = L.ellipse(22, 46.5, 9.2, 8)
  c:part(haunch, { ws = 2, wl = 3 })
  local chest = L.ellipse(35, 44, 11.4, 8.6)
  c:part(chest, { ws = 2, wl = 3 })
  L.ellipse(35, 46, 4.6, 5):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and chest:has(x, y) then c:put(x, y, L.step(t, 1), "light") end end)
  -- near hind leg: thigh -> shin pushed back off the ground, long foot
  limb(c, info, { { 24, 48 }, { 17, 53 }, { 9, 55 } }, 3.2, 2.2)
  paw(c, info, 6.5, 55, 3.6, 1.9)
  toes(c, { 4, 6, 8 }, 55, 56)
  toes(c, { 11, 13 }, 54, 55)
  -- near arm: shoulder -> bent elbow -> forearm stretched up and forward
  limb(c, info, { { 40, 40 }, { 48, 37 }, { 55, 30 }, { 58, 24 } }, 3.3, 2.4)
  raisedPaw(c, info, 58.5, 21.5, false)
  info.chest, info.haunch = chest, haunch
  info.hcx, info.hcy, info.hrx, info.hry = 28, 46, 14, 8.6
  head(c, info, 9, 2, "open", o.ears, false, nil)
  finish(c, info, nil)
  return c, info
end

CATS.stalk = function(o)   -- low hunting crouch: head down in line with hunched shoulders, hips and elbows raised
  return crouch(o, "stalk", 20, 21, "open", function(c, info)
    local farFront = limb(c, info, { { 28, 42 }, { 30, 49 }, { 34, 54 } }, 2.5, 2.1, { ws = 1, wl = 1, lift = -1 })
    local torso = L.poly({ { 8, 36 }, { 16, 33 }, { 24, 35 }, { 31, 41 }, { 31, 50 }, { 12, 50 }, { 6, 44 } })
    c:part(torso, { ws = 2, wl = 3 })
    local haunch = L.ellipse(12, 43.5, 9, 9.6) c:part(haunch, { ws = 2, wl = 3 })
    -- shoulder blade hump and a spine glint
    local sh = L.ellipse(24, 41, 4.6, 4.6)
    L.ellipse(23, 39.5, 3.4, 2.4):each(function(x, y) local t = c:get(x, y) if t == 'm' or t == 'b' then c:put(x, y, 'l', "light") end end)
    c:stamp({ { 21, 37, 'L' }, { 22, 36, 'L' }, { 23, 37, 'l' }, { 11, 35, 'L' }, { 12, 34, 'g' }, { 13, 34, 'L' } }, "light")
    -- folded hind leg + foot under the haunch
    local feet = L.ellipse(9, 54.6, 4, 1.8):add(L.ellipse(18, 54.6, 3.4, 1.8))
    c:part(feet, { ws = 1, wl = 1 })
    toes(c, { 7, 9, 17, 19 }, 55, 56)
    -- near front leg: elbow pokes up behind the head, forearm down to the floor
    local arm = limb(c, info, { { 24, 40 }, { 26, 47 }, { 31, 54 } }, 3.0, 2.3)
    local pw = L.ellipse(33, 54.6, 3.6, 1.9):add(L.ellipse(46, 54.6, 3.6, 1.9))
    c:part(pw, { ws = 1, wl = 1, noao = true })
    toes(c, { 32, 34, 45, 47 }, 55, 56)
    info.paws = feet:copy():add(pw) info.chest, info.haunch = torso, haunch
    info.hcx, info.hcy, info.hrx, info.hry = 12, 43.5, 9, 9.6
  end, { { 7, 40 }, { 3, 33 }, { 3, 24 }, { 6, 17 }, { 11, 14 } }, { { 11, 14, 'g' }, { 10, 15, 'L' }, { 12, 15, 'L' } }, 56)
end

CATS.wiggle = function(o)
  return crouch(o, "wiggle", 15, 19, "open", function(c, info)
    local torso = L.ellipse(25, 42, 12, 6.2) c:part(torso, { ws = 2, wl = 3 })
    local haunch = L.ellipse(12, 38, 8.2, 12.2) c:part(haunch, { ws = 2, wl = 3 })
    local legs = L.tube({ { 12, 48 }, { 12, 52 }, { 12, 54 } }, function() return 2.4 end)
    c:part(legs, { ws = 1, wl = 1 })
    local feet = L.ellipse(11, 54.6, 4, 1.8):add(L.ellipse(20, 54.6, 3.4, 1.8))
    c:part(feet, { ws = 1, wl = 1 })
    toes(c, { 9, 11, 19, 21 }, 55, 56)
    local pw = L.ellipse(31, 54.6, 3.6, 1.9):add(L.ellipse(44, 54.6, 3.6, 1.9))
    c:part(pw, { ws = 1, wl = 1, noao = true })
    toes(c, { 30, 32, 43, 45 }, 55, 56)
    info.legs = legs info.paws = feet:copy():add(pw) info.chest, info.haunch = torso, haunch
    info.hcx, info.hcy, info.hrx, info.hry = 12, 38, 8.2, 12.2
  end, { { 8, 32 }, { 4, 26 }, { 4, 17 }, { 7, 11 }, { 12, 9 } }, { { 12, 9, 'g' }, { 11, 10, 'L' }, { 13, 10, 'L' } }, 56)
end

CATS.stretch = function(o)   -- down-dog: rump high, back sloping to low shoulders, chest near the floor, arms reaching forward
  return crouch(o, "stretch", 19, 18, "bored", function(c, info)
    limb(c, info, { { 28, 45 }, { 40, 51 }, { 51, 54 } }, 2.4, 1.9, { ws = 1, wl = 1, lift = -1 })
    paw(c, info, 54, 54.6, 3.2, 1.8, { ws = 1, wl = 1, lift = -1, noao = true })
    -- far hind leg
    limb(c, info, { { 18, 40 }, { 18.5, 48 }, { 19, 53 } }, 2.6, 2.1, { ws = 1, wl = 1, lift = -1 })
    paw(c, info, 19, 54.6, 3.2, 1.8, { ws = 1, wl = 1, lift = -1, noao = true })
    -- back: hips up top-left, spine running down to the shoulders
    local back = L.poly({ { 2, 29 }, { 7, 20 }, { 16, 19 }, { 25, 28 }, { 32, 37 }, { 33, 47 }, { 20, 45 }, { 4, 41 } })
    c:part(back, { ws = 2, wl = 3 })
    local hip = L.ellipse(10, 29, 8, 9)
    c:part(hip, { ws = 2, wl = 3 })
    -- shoulder plane: a lit blade behind the head, a shade crease where hip meets back
    L.ellipse(26, 38, 4.5, 5):each(function(x, y) local t = c:get(x, y) if t == 'm' or t == 'b' then c:put(x, y, 'l', "light") end end)
    for _, p in ipairs({ { 17, 27 }, { 18, 28 }, { 18, 29 }, { 19, 30 }, { 19, 31 }, { 20, 32 } }) do if back:has(p[1], p[2]) then c:put(p[1], p[2], 's', "shade") end end
    c:stamp({ { 8, 21, 'g' }, { 9, 21, 'L' }, { 10, 21, 'L' }, { 6, 23, 'L' }, { 14, 22, 'L' }, { 16, 24, 'l' }, { 22, 30, 'L' }, { 23, 31, 'l' } }, "light")
    -- near hind leg: thigh down to a plantigrade foot
    limb(c, info, { { 9, 36 }, { 9, 46 }, { 10, 53 } }, 3.6, 2.4)
    paw(c, info, 10, 54.6, 3.8, 1.8)
    toes(c, { 8, 10, 12 }, 55, 56)
    toes(c, { 18, 20 }, 55, 56)
    -- near arm, shoulder out from under the head
    limb(c, info, { { 29, 44 }, { 40, 51 }, { 53, 54 } }, 2.7, 2.1)
    paw(c, info, 57, 54.4, 3.8, 1.9)
    toes(c, { 56, 58, 60 }, 54, 55)
    info.chest, info.haunch = back, hip
    info.hcx, info.hcy, info.hrx, info.hry = 12, 30, 12, 10
  end, { { 6, 29 }, { 3, 22 }, { 3, 14 }, { 6, 9 }, { 11, 8 } }, { { 11, 8, 'g' }, { 10, 9, 'L' }, { 12, 9, 'L' } }, 56)
end

CATS.swatB = function(o)
  return crouch(o, "swatB", 7, 6, "open", function(c, info)
    local torso = L.ellipse(25, 48, 12, 6.8) c:part(torso, { ws = 2, wl = 3 })
    local haunch = L.ellipse(13, 48, 8.6, 8) c:part(haunch, { ws = 2, wl = 3 })
    local feet = L.ellipse(10, 54.6, 4, 1.8):add(L.ellipse(21, 54.6, 3.4, 1.8)):add(L.ellipse(30, 54.6, 3.4, 1.8))
    c:part(feet, { ws = 1, wl = 1 })
    toes(c, { 8, 10, 20, 22, 29, 31 }, 55, 56)
    limb(c, info, { { 36, 43 }, { 46, 42 }, { 53, 41 } }, 2.5, 1.9)
    paw(c, info, 56, 40.5, 3.4, 2.5)
    c:stamp({ { 60, 38, 'L' }, { 61, 40, 'L' }, { 60, 42, 'L' } }, "detail")
    toes(c, { 55, 57 }, 40, 41)
    info.paws = info.paws:copy():add(feet) info.chest, info.haunch = torso, haunch
    info.hcx, info.hcy, info.hrx, info.hry = 13, 48, 8.6, 8
  end, { { 9, 50 }, { 5, 44 }, { 4, 34 }, { 6, 25 }, { 9, 21 } }, { { 9, 21, 'g' }, { 8, 22, 'L' }, { 10, 22, 'L' } }, 56)
end

local NEWFR = { "idleB", "blink", "eartwitch", "tailflick", "yawn", "bored", "washA", "washB", "swatA", "happy", "jump", "stalk", "wiggle", "stretch", "swatB" }

local FR = { "idleA", "pounce", "catch", "nap" }
if app.params["frames"] == "new" then FR = NEWFR end
local MODE = app.params["only"] or "all"
if MODE ~= "overlays" then
  for _, f in ipairs(FR) do
    local c, info = CATS[f]({})
    c:save(OUT, "cf-cat-grey-" .. f)
    print(f, "colours", c:colours(), "spurs", table.concat(c:spurs(), " "))
  end
end
if MODE == "cats" then return end

-- OVERLAYS ------------------------------------------------------------------------------------------
local OV = OUT .. "overlays/"
local WH = { g = "#fbf6ec", L = "#fbf6ec", l = "#e6dfd2", m = "#e6dfd2", b = "#bab0c0", r = "#bab0c0", s = "#bab0c0", D = "#8d829a" }
local WEDGE = "#463e5e"
local floor, atan, sqrt, pi = math.floor, math.atan, math.sqrt, math.pi

local function eyeBox(info, x, y)
  for _, ex in ipairs({ 16, 34 }) do if math.abs(x - ex - info.ox) <= 3 and math.abs(y - 21 - info.oy) <= 3 then return true end end
  return false
end
local function ok(c, info, x, y)
  local t = c:get(x, y)
  return t and L.isCoat(t) and c:isObj(x, y) and not info.protect:has(x, y) and not eyeBox(info, x, y)
end
local function newP() return L.canvas(64, 64) end
local function dark(P, c, info, x, y, n) if ok(c, info, x, y) then P:put(x, y, L.step(c:get(x, y), n)) end end
-- points/spots: absolute mapping so lit felt still goes clearly dark
local PT = { g = 'b', L = 'b', l = 's', m = 's', b = 'D', r = 'D', s = 'D', D = 'D' }
local function point(P, c, info, x, y) if ok(c, info, x, y) then P:put(x, y, PT[c:get(x, y)]) end end
local function lightTone(P, c, info, x, y, n) if ok(c, info, x, y) then P:put(x, y, L.step(c:get(x, y), n)) end end
local function white(P, c, info, m)
  m:each(function(x, y) if ok(c, info, x, y) then P:put(x, y, WH[c:get(x, y)]) end end)
  -- 1px coat-deep seam where the patch meets coat felt on its shade side (below / right), so white holds its shape on pale coats
  -- (softened: a dithered seam, the rest of the edge steps to the patch's own crescent tone)
  m:each(function(x, y)
    if P:get(x, y) and ((ok(c, info, x + 1, y) and not m:has(x + 1, y)) or (ok(c, info, x, y + 1) and not m:has(x, y + 1))) then
      P:put(x, y, ((x + y) % 2 == 0) and WEDGE or "#bab0c0")
    end
  end)
end
-- visible pixels of the main body ellipse
local function bodyEll(info) return info.hcx, info.hcy, info.hrx, info.hry end
local function radialStripes(P, c, info, cx, cy, rx, ry, n, region, phase)
  region:each(function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    local rho = sqrt(u * u + v * v)
    if rho < 0.42 or rho > 1.15 then return end
    local a = (atan(v, u) / (2 * pi) * n + (phase or 0)) % 1
    local w = 0.10 + 0.24 * math.min(1, (rho - 0.42) / 0.5)
    if a < w then dark(P, c, info, x, y, -2) end
  end)
end
local function tailRings(P, c, info, n0)
  if not info.tailT then return end
  info.tail:each(function(x, y)
    local t = info.tailT[K(x, y)]
    if not t then return end
    if t > 0.93 then dark(P, c, info, x, y, -2) return end
    local a = (t * (n0 or 6)) % 1
    if t > 0.12 and a > 0.55 and a < 0.78 then dark(P, c, info, x, y, -2) end
  end)
end
local function visible(c, m) return m:filter(function(x, y) return c:isObj(x, y) end) end
local function points(list, ox, oy) local m = L.mask() for _, p in ipairs(list) do m:set(p[1] + ox, p[2] + oy) end return m end

-- per-frame body regions that carry body markings (excluding head)
local function bodyRegion(c, info)
  local m = info.chest:copy():add(info.haunch)
  m:cut(info.head)
  return visible(c, m)
end

local PAT = {}
local SITF = { idleA = true, idleB = true, blink = true, eartwitch = true, tailflick = true, yawn = true, bored = true, washA = true, washB = true, swatA = true, happy = true }
local function isSit(info) return SITF[info.frame] end
local function bd(info) return info.bdy or 0 end
-- action poses (not sitting): body ellipse of the haunch + per-pose white bib / calico patches (absolute px)
local ACT = {
  jump    = { h = { 22, 46.5, 9.2, 8 },  bib = function() return L.ellipse(35, 47, 5, 5.5) end,
              patch = function() return { L.ellipse(21, 46, 6, 5), L.ellipse(45, 41, 5, 4) } end, white2 = function() return L.ellipse(30, 50, 5, 3) end },
  stalk   = { h = { 12, 43.5, 9, 9.6 }, bib = function() return L.ellipse(25, 47, 3.5, 3.5) end,
              patch = function() return { L.ellipse(12, 42, 6, 6), L.ellipse(21, 37, 4, 3) } end, white2 = function() return L.ellipse(22, 50, 4, 3) end },
  wiggle  = { h = { 12, 38, 8.2, 12.2 }, bib = function() return L.ellipse(23, 46, 3.5, 3.5) end,
              patch = function() return { L.ellipse(11, 33, 5, 6), L.ellipse(19, 40, 3, 3) } end, white2 = function() return L.ellipse(20, 48, 4, 3) end },
  stretch = { h = { 10, 29, 8, 9 },      bib = function() return L.ellipse(27, 42, 3, 4) end,
              patch = function() return { L.ellipse(10, 27, 6, 6), L.ellipse(22, 32, 4, 3) } end, white2 = function() return L.ellipse(26, 44, 4, 3) end },
  swatB   = { h = { 13, 48, 8.6, 8 },    bib = function() return L.ellipse(25, 45, 5, 4) end,
              patch = function() return { L.ellipse(12, 46, 6, 6), L.ellipse(32, 51, 4, 3) } end, white2 = function() return L.ellipse(22, 51, 5, 3) end },
}
local function socks(info) return info.legs:filter(function(x, y) return y >= 46 end):add(info.paws) end
-- body flank stripes for horizontal bodies: bars across the back, fading toward the belly
local function flank(P, c, info, region, period, slant)
  local y0, y1 = 99, -99
  region:each(function(x, y) y0 = math.min(y0, y) y1 = math.max(y1, y) end)
  region:each(function(x, y)
    if y <= y0 + 0.72 * (y1 - y0) and (floor(x + y * (slant or 0.3)) % period) == 0 then dark(P, c, info, x, y, -2) end
  end)
end
local function limbRings(P, c, info)
  for _, L2 in ipairs(info.limbs or {}) do
    L2[1]:each(function(x, y)
      local t = L2[2][K(x, y)]
      if t and t > 0.18 and ((t * 3.4) % 1) > 0.58 and not info.head:has(x, y) then dark(P, c, info, x, y, -2) end
    end)
  end
end
local function headPts(P, c, info, ox, oy)
  points({ { 25, 12 }, { 25, 13 }, { 25, 14 }, { 25, 15 }, { 21, 12 }, { 22, 13 }, { 22, 14 }, { 29, 12 }, { 28, 13 }, { 28, 14 },
           { 23, 9 }, { 23, 10 }, { 27, 9 }, { 27, 10 }, { 25, 8 }, { 25, 9 }, { 25, 10 },
           { 9, 18 }, { 10, 18 }, { 11, 19 }, { 9, 20 }, { 10, 20 }, { 11, 20 }, { 41, 18 }, { 40, 18 }, { 39, 19 }, { 41, 20 }, { 40, 20 }, { 39, 20 } }, ox, oy)
    :each(function(x, y) dark(P, c, info, x, y, -2) end)
end
PAT.tabby = function(c, info)
  local P, ox, oy = newP(), info.ox, info.oy
  headPts(P, c, info, ox, oy)
  local cx, cy, rx, ry = bodyEll(info)
  local reg = bodyRegion(c, info)
  local B = bd(info)
  if isSit(info) or info.frame == "catch" then
    -- haunch sides: stripes wrap the hips; chest: two necklace arcs
    radialStripes(P, c, info, cx, cy, rx, ry, 13, reg:filter(function(x, y) return math.abs(x - cx) > 7 end), 0.1)
    reg:each(function(x, y)
      local u, v = (x - 25) / 10, (y - 27 - B) / 6.5
      local r = sqrt(u * u + v * v)
      if (r > 1.12 and r < 1.24) or (r > 1.45 and r < 1.57) then if math.abs(x - 25) > 1 then dark(P, c, info, x, y, -2) end end
    end)
    if isSit(info) then
      for _, y in ipairs({ 44 + B, 48 + B }) do for x = 18, 21 do dark(P, c, info, x, y, -2) end for x = 29, 32 do dark(P, c, info, x, y, -2) end end
    end
  elseif info.frame == "pounce" then
    radialStripes(P, c, info, cx, cy + 3, rx, ry + 3, 16, reg:filter(function(x, y) return y < cy + 3 end), 0.0)
    radialStripes(P, c, info, 13.5, 38, 6.8, 6.2, 7, visible(c, info.haunch), 0.3)
    info.legs:each(function(x, y) if x == 39 or x == 40 or x == 44 or y == 45 or y == 47 then if not info.head:has(x, y) and x > 8 then dark(P, c, info, x, y, -2) end end end)
  elseif ACT[info.frame] then
    local h = ACT[info.frame].h
    local hm = visible(c, info.haunch):cut(info.head)
    radialStripes(P, c, info, h[1], h[2], h[3], h[4], 9, hm, 0.2)
    flank(P, c, info, visible(c, info.chest):cut(info.head):cut(info.haunch:grow(1)), 5, info.frame == "stretch" and 0.55 or 0.3)
  else
    radialStripes(P, c, info, 43, 47.5, 18, 9.2, 15, reg:filter(function(x, y) return y < 52 end), 0.05)
    radialStripes(P, c, info, cx, cy, rx, ry, 9, visible(c, info.haunch), 0.2)
  end
  limbRings(P, c, info)
  tailRings(P, c, info, 6)
  return P
end

local SPOTS = {
  idleA = { { 11, 43 }, { 13, 48 }, { 37, 43 }, { 38, 48 }, { 12, 52 }, { 39, 52 }, { 22, 34 }, { 28, 34 }, { 25, 37 } },
  catch = { { 11, 43 }, { 13, 48 }, { 37, 43 }, { 38, 48 }, { 12, 52 }, { 39, 52 }, { 21, 34 }, { 28, 34 } },
  pounce = { { 13, 32 }, { 19, 31 }, { 25, 30 }, { 31, 31 }, { 17, 36 }, { 23, 35 }, { 10, 37 }, { 14, 41 }, { 28, 35 } },
  nap = { { 38, 40 }, { 44, 39 }, { 50, 39 }, { 55, 42 }, { 41, 45 }, { 47, 44 }, { 53, 47 }, { 57, 48 }, { 36, 46 } },
}
local function spotList(c, info)
  if isSit(info) then
    local l = {}
    for _, p in ipairs(SPOTS.idleA) do l[#l + 1] = { p[1], p[2] + bd(info) } end
    return l
  end
  -- action poses: spots on a jittered lattice over the visible body + upper limbs
  local reg = visible(c, info.chest:copy():add(info.haunch)):cut(info.head:grow(1))
  local l, row = {}, 0
  for y = 12, 58, 5 do
    row = row + 1
    for x = 3 + ((row % 2 == 0) and 3 or 0), 62, 6 do
      local px, py = x + floor(hash(x, y, 1) * 3) - 1, y + floor(hash(x, y, 2) * 2)
      local good = true
      for dy = 0, 1 do for dx = 0, 2 do if not (reg:has(px + dx, py + dy) and ok(c, info, px + dx, py + dy)) then good = false end end end
      if good then l[#l + 1] = { px, py } end
    end
  end
  return l
end
PAT.spotted = function(c, info)
  local P, ox, oy = newP(), info.ox, info.oy
  for i, s in ipairs(spotList(c, info)) do
    local big = (i % 3 ~= 0)
    local m = big and points({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 }, { 2, 0 }, { 2, 1 } }, s[1], s[2]):unset(s[1] + 2, s[2] + 1) or points({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }, s[1], s[2])
    m:each(function(x, y)
      if ok(c, info, x, y) then P:put(x, y, (x == s[1] and y == s[2]) and 's' or 'D') end   -- soft top-left, deep core: reads on white coats too
    end)
  end
  points({ { 22, 11 }, { 23, 11 }, { 27, 11 }, { 28, 11 }, { 25, 9 }, { 25, 10 }, { 10, 19 }, { 11, 19 }, { 39, 19 }, { 40, 19 } }, ox, oy):each(function(x, y) dark(P, c, info, x, y, -2) end)
  if info.tailT then info.tail:each(function(x, y) local t = info.tailT[K(x, y)]
    if t and ((t > 0.3 and t < 0.37) or (t > 0.55 and t < 0.62) or t > 0.92) then dark(P, c, info, x, y, -2) end end) end
  return P
end

local BIB = {
  idleA = function() return L.ellipse(25, 39, 5.2, 7.5):add(L.rect(17, 51, 23, 57)):add(L.rect(27, 51, 34, 57)) end,
  catch = function() return L.ellipse(25, 46, 5.5, 5.5):add(L.ellipse(25, 34, 3.5, 3)) end,
  pounce = function() return L.ellipse(35, 37, 4.5, 4) end,
  nap = function() return L.mask() end,
}
local function bibFor(c, info)
  if isSit(info) then return BIB.idleA():shift(0, bd(info)) end
  if ACT[info.frame] then return ACT[info.frame].bib():add(socks(info)) end
  return BIB[info.frame]()
end
local function chinMuzzle(info)
  return info.muzzle:copy():add(L.ellipse(25 + info.ox, 29 + info.oy, 4.5, 2.2)):clip(info.head)
end
PAT.tuxedo = function(c, info)
  local P = newP()
  local m = bibFor(c, info):add(chinMuzzle(info)):add(info.paws)
  white(P, c, info, m)
  return P
end
local PATCH = {
  idleA = function() return { L.ellipse(13, 11, 6, 5), L.ellipse(37, 46, 6.5, 7), L.ellipse(51, 46, 4, 7) } end,
  catch = function() return { L.ellipse(13, 11, 6, 5), L.ellipse(37, 47, 6.5, 6.5), L.ellipse(51, 46, 4, 7) } end,
  pounce = function() return { L.ellipse(29, 11, 6, 5), L.ellipse(16, 34, 7, 5.5), L.ellipse(6, 20, 4, 6) } end,
  nap = function() return { L.ellipse(13, 29, 6, 5), L.ellipse(49, 42, 8, 6), L.ellipse(34, 57, 6, 3) } end,
}
local function patchesFor(c, info)
  if isSit(info) then
    local l = PATCH.idleA()
    l[1] = L.ellipse(13 + info.ox, 11 + info.oy, 6, 5)     -- head patch follows the head
    for i = 2, #l do l[i] = l[i]:shift(0, bd(info)) end
    return l
  end
  if ACT[info.frame] then
    local l = ACT[info.frame].patch()
    table.insert(l, 1, L.ellipse(13 + info.ox, 11 + info.oy, 6, 5))
    return l
  end
  return PATCH[info.frame]()
end
PAT.calico = function(c, info)
  local P = newP()
  for _, m in ipairs(patchesFor(c, info)) do m:each(function(x, y) dark(P, c, info, x, y, -2) end) end
  local wm = bibFor(c, info):add(chinMuzzle(info)):add(info.paws)
  if isSit(info) or info.frame == "catch" then wm:add(L.ellipse(25, 48 + bd(info), 7, 6)) end
  if info.frame == "nap" then wm:add(L.ellipse(30, 55, 6, 3)) end
  if ACT[info.frame] then wm:add(ACT[info.frame].white2()) end
  white(P, c, info, wm)
  return P
end
PAT.pointed = function(c, info)
  local P, ox, oy = newP(), info.ox, info.oy
  local core = L.mask()
  core:add(L.ellipse(25 + ox, 26 + oy, 6.5, 4.2):clip(info.head))
  if info.ears then core:add(info.ears:filter(function(x, y) return y <= 7 + oy end)) end
  core:add(info.paws)
  if info.tailT then info.tail:each(function(x, y) local t = info.tailT[K(x, y)] if t and t > 0.45 then core:set(x, y) end end) end
  local halo = core:grow(1):cut(core)
  local halo2 = core:grow(2):cut(core):cut(halo)
  -- pale body (one step up), then points step down, with pixel-step halos
  c.obj:each(function(x, y) if not core:has(x, y) and not halo:has(x, y) and not halo2:has(x, y) then lightTone(P, c, info, x, y, 1) end end)
  halo2:each(function(x, y) if (x + y) % 2 == 0 then dark(P, c, info, x, y, -1) end end)
  halo:each(function(x, y) dark(P, c, info, x, y, -2) end)
  core:each(function(x, y) point(P, c, info, x, y) end)
  -- core of the core: deepest at the very tips
  if info.tailT then info.tail:each(function(x, y) local t = info.tailT[K(x, y)] if t and t > 0.8 then dark(P, c, info, x, y, -3) end end) end
  if info.ears then info.ears:each(function(x, y) if y <= 4 + oy then dark(P, c, info, x, y, -3) end end) end
  return P
end

local function diff(a, b, region)   -- -> mask (base pixels to clear), overlay canvas (variant pixels)
  local mask, ov = L.canvas(64, 64), L.canvas(64, 64)
  local n = 0
  for y = 0, 63 do for x = 0, 63 do
    if region(x, y) then
      local ta, tb = a:get(x, y), b:get(x, y)
      local ha, hb = ta and a:hex(ta), tb and b:hex(tb)
      if ha ~= hb then
        if ha then mask:put(x, y, "#ffffff") n = n + 1 end
        if hb then ov:put(x, y, tb, b.ly[K(x, y)]) end
      end
    end
  end end
  return mask, ov, n
end
local function clash(maskC, info)
  local bad = 0
  for k in pairs(maskC.t) do local x, y = L.XY(k) if info.protect:has(x, y) or eyeBox(info, x, y) then bad = bad + 1 end end
  return bad
end

for _, f in ipairs(FR) do
  local c, info = CATS[f]({})
  for _, pn in ipairs({ "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
    local P = PAT[pn](c, info)
    P:save(OV, "cf-pat-" .. pn .. "-grey-" .. f, true)
  end
  local cf = CATS[f]({ ears = "folded" })
  local em, eo = diff(c, cf, function(x, y) return y < info.oy + 17 end)
  em:save(OV, "cf-ears-mask-" .. f, true) eo:save(OV, "cf-ears-folded-" .. f, true)
  local cb = CATS[f]({ tail = "bobtail" })
  local tm, to = diff(c, cb, function(x, y) return not (info.head:has(x, y)) end)
  tm:save(OV, "cf-tail-mask-" .. f, true) to:save(OV, "cf-tail-bobtail-" .. f, true)
  print(f, "ears mask clash", clash(em, info), "tail mask clash", clash(tm, info))
end
