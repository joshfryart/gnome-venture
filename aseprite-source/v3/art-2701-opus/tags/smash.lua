-- smash (Opus). Tag "heavy" (Smash: a heavy blow). A big wooden beetle mallet slammed straight down onto a
-- flagstone: the barrel head (two iron hoops) sits buried on the stone, its ash handle swings up to the right,
-- motion arcs above show the drop, the slab splits in a star of cracks and chips and dust puffs fly out both sides.
-- Material: end-grain rings on the head's top, lengthwise grain on the barrel, bevelled iron hoops with rivets,
-- cut stone with a lit top face, darker front face and chiselled cracks.
-- quirk: a daisy beside the strike has been knocked flat, petals splayed.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = O.new("smash")

local HEAD = { "#4a2a22", "#6e3a26", "#9a5a34", "#c27c46", "#e0a464", "#f6cc8e" }
local ASH  = { "#5a3626", "#8a5a36", "#c0884e", "#deae6c", "#f4d496", "#fff0c4" }
local IRON = { "#2f3150", "#444663", "#62647e", "#8a8ba2", "#b8b8c8", "#e6e6ee" }
local STN  = { "#3a3a56", "#4e4f6c", "#6a6b86", "#8c8da4", "#b0b0c2", "#d6d5e0" }
local DUST = { "#b0a8a0", "#d4ccc0", "#f0e8da" }
local SWO  = { "#5f9ad0", "#8bc4ea", "#e4f6ff" }

-- flagstone slab: top face + front face
local top = c:poly{ { 6, 46 }, { 12, 41 }, { 54, 41 }, { 59, 46 } }
local front = c:rect(6, 47, 59, 52)
front:add(c:rect(7, 53, 58, 53))
do
  local tok = O.tok("slab")
  local b = {}
  top:each(function(x, y) if O.hash(x, y, 11) > 0.88 then b[K(x, y)] = -1 end end)
  local n = {} top:each(function(x, y) n[K(x, y)] = { (x - 32) / 120, -0.5, 0.7 } end)
  local ti = O.shade(c, top, n, STN, { tok = tok, bias = b, amb = 0.2 })
  local fn = {} front:each(function(x, y) fn[K(x, y)] = { (x - 32) / 120 + 0.15, 0.3, 0.9 } end)
  local fb = {}
  front:each(function(x, y) if O.hash(x, y, 12) > 0.85 then fb[K(x, y)] = -1 end if y == 47 then fb[K(x, y)] = 1 end end)
  local fi = O.shade(c, front, fn, STN, { tok = tok, bias = fb, amb = 0.1, cuts = { 0.25, 0.42, 0.6, 0.78, 0.92 } })
  -- star of cracks from the strike point
  local sx, sy = 25, 45
  for _, cr in ipairs{
    { { 25, 45 }, { 17, 43 }, { 12, 44 } }, { { 25, 45 }, { 33, 42 }, { 38, 42 } }, { { 25, 45 }, { 30, 47 }, { 32, 51 } },
    { { 25, 45 }, { 21, 48 }, { 20, 52 } }, { { 25, 45 }, { 41, 46 }, { 47, 45 } },
  } do
    local m = c:line(cr, 1)
    m:each(function(x, y) if top:has(x, y) or front:has(x, y) then c:put(x, y, STN[1], tok) end end)
    -- lit lip on the upper side of each crack
    m:each(function(x, y) if (top:has(x, y - 1) or front:has(x, y - 1)) and not m:has(x, y - 1) then c:put(x, y - 1, STN[6], tok) end end)
  end
end

-- motion arcs above the head (behind it)
do
  local tok = O.tok("swoosh")
  for i, a in ipairs{ { 26, 36, 22, -2.75, -2.2 }, { 26, 36, 22, -2.05, -1.55 } } do
    for t = a[4], a[5], 0.01 do
      local x, y = floor(a[1] + cos(t) * a[3] + .5), floor(a[2] + sin(t) * a[3] + .5)
      c:put(x, y, SWO[2], tok)
      local x2, y2 = floor(a[1] + cos(t) * (a[3] - 1) + .5), floor(a[2] + sin(t) * (a[3] - 1) + .5)
      if not (x2 == x and y2 == y) then c:put(x2, y2, SWO[3], tok) end
    end
  end
end

-- mallet: barrel head on an axis tilted down-right, handle perpendicular to it going up-right
local HCX, HCY = 23, 31
local AA = 0.9                                   -- head axis angle (u points down-right, toward the strike face)
local aux, auy = cos(AA), sin(AA)
local avx, avy = -auy, aux                      -- v across the head (points down-left)
local HL, HR = 11.5, 7.2                         -- half length, radius
local hx1, hy1 = HCX + avx * -1 * 0, HCY
local hdx, hdy = -avx, -avy                      -- handle direction (up-right)
local hm, hn, HT, HS = X.cyl(HCX + hdx * 5, HCY + hdy * 5, HCX + hdx * 34, HCY + hdy * 34, function(t) return t > 0.94 and 2.4 or 2.0 end)
do
  local tok = O.tok("handle")
  local b = {}
  hm:each(function(x, y) local k = K(x, y) if HT[k] < 0.06 then b[k] = -2 end end)       -- AO where it enters the head
  local idx = O.shade(c, hm, hn, ASH, { tok = tok, bias = b, amb = 0.15, wrap = 0.3 })
  hm:each(function(x, y) local k = K(x, y) if HS[k] < -0.4 and HT[k] > 0.15 and HT[k] < 0.88 then O.set(c, idx, ASH, x, y, 5, tok) end end)
  -- leather grip wrap near the end
  hm:each(function(x, y) local k = K(x, y) if HT[k] > 0.7 and HT[k] < 0.9 and floor(HT[k] * 60) % 3 == 0 then O.step(c, idx, ASH, x, y, -1, tok) end end)
end
local head, HU, HV = O.lmask(HCX, HCY, AA, 16, function(u, v)
  local bul = 0.9 * cos((u / HL) * pi / 2)
  return u >= -HL and u <= HL and abs(v) <= HR + bul
end)
do
  local tok = O.tok("head")
  local n = {}
  head:each(function(x, y) local k = K(x, y)
    local s = max(-0.97, min(0.97, HV[k] / (HR + 1.5)))
    n[k] = { avx * s, avy * s, sqrt(1 - s * s) }
  end)
  local b = {}
  head:each(function(x, y) local k = K(x, y)
    -- lengthwise grain lines (run along u)
    local vv = HV[k]
    if abs((vv + 20) % 3.2 - 1.6) < 0.35 and O.hash(floor(HU[k] / 3), floor(vv), 4) > 0.3 then b[k] = -1 end
    if HU[k] > HL - 1.5 then b[k] = (b[k] or 0) - 1 end            -- the striking face, AO at the stone
  end)
  local idx = O.shade(c, head, n, HEAD, { tok = tok, bias = b, amb = 0.1, wrap = 0.3 })
  -- iron hoops
  head:each(function(x, y) local k = K(x, y)
    local u = HU[k]
    for _, hu in ipairs{ -HL + 3, HL - 4.5 } do
      if u >= hu and u < hu + 2.5 then
        local s = HV[k] / (HR + 1.5)
        local i = idx[k] and min(6, max(1, idx[k])) or 3
        if u >= hu + 1.6 then i = max(1, i - 2) end
        c:put(x, y, IRON[i], tok)
      end
    end
  end)
  -- rivets on the hoops (lit side)
  for _, hu in ipairs{ -HL + 4, HL - 3.5 } do
    local x, y = floor(HCX + aux * hu + avx * -3.5 + .5), floor(HCY + auy * hu + avy * -3.5 + .5)
    c:put(x, y, IRON[6], tok)
  end
  -- end grain cap at the upper end
  local tokC = O.tok("cap")
  local cap = O.lmask(HCX, HCY, AA, 16, function(u, v)
    return ((u + HL) / 2.6) ^ 2 + (v / (HR + 0.2)) ^ 2 <= 1
  end)
  cap:each(function(x, y)
    local dx, dy = x - HCX, y - HCY
    local u, v = dx * aux + dy * auy, dx * avx + dy * avy
    local r = sqrt(((u + HL) / 2.6) ^ 2 + (v / (HR + 0.2)) ^ 2)
    local ring = floor(r * 3.6) % 2 == 0
    c:put(x, y, r > 0.82 and HEAD[4] or (ring and HEAD[6] or HEAD[5]), tokC)
  end)
  c:put(floor(HCX - aux * HL + .5), floor(HCY - auy * HL + .5), HEAD[3], tokC)
end

-- chips + dust puffs flying out
do
  local tok = O.tok("chips")
  for _, ch in ipairs{ { 9, 34, 2 }, { 5, 39, 1 }, { 40, 32, 2 }, { 45, 36, 1 }, { 12, 29, 1 } } do
    local x, y, s = ch[1], ch[2], ch[3]
    if s == 2 then O.map(c, { "hb", "bd" }, x, y, { h = STN[6], b = STN[4], d = STN[2] }, tok)
    else O.map(c, { "hd" }, x, y, { h = STN[5], d = STN[3] }, tok) end
  end
  local tokD = O.tok("dust")
  for _, d in ipairs{ { 8, 41, 3 }, { 40, 39, 3 }, { 46, 35, 1.6 } } do
    local m = O.oval(d[1], d[2], d[3], d[3] * 0.75)
    local mm = O.oval(d[1] + 0.5, d[2] - 0.5, d[3] - 1, d[3] * 0.75 - 1)
    m:each(function(x, y) c:put(x, y, mm:has(x, y) and DUST[3] or DUST[2], tokD) end)
    m:each(function(x, y) if not m:has(x + 1, y + 1) then c:put(x, y, DUST[1], tokD) end end)
  end
end

-- quirk: a daisy knocked flat on the slab, stem pointing away from the blow
do
  local tok = O.tok("daisy")
  O.map(c, {
    "..p.p..",
    ".pPpPp.",
    "pPyyspp",
    ".pysdp.gg",
    "pp.p.pgg..",
    "..p.p.....",
  }, 45, 40, { p = "#e8628a", P = "#ffb4cc", y = "#f5b82e", s = "#d98322", d = "#8f4a1f", g = "#3f9150" }, tok)
end

O.save(c, "smash")
