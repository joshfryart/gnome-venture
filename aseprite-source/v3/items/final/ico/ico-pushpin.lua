-- ico-pushpin (Opus single pass). A slim classic map pin tilted ~24 deg, cap upper-right, point lower-left.
-- Lathe-turned body: rounded-box cap, waisted grip with two turned rings, a thin flange, a 3 px steel needle.
-- Material: per-pixel light (6-tone glossy red plastic, cool-violet shade), specular streak + glint on the cap
-- shoulder, cool reflected light on the lower-right rims, AO where cap/grip/flange/needle meet. Steel: bevelled
-- 6-tone needle with a bright edge and a dark shade edge.
-- quirk: a little torn note is still speared on the needle, with a red scribble on it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA8_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-pushpin")
local RED   = { "#561634", "#8c2238", "#c0303e", "#e44a3c", "#ff7a58", "#ffb088" }
local STEEL = { "#33354d", "#555a7a", "#7e839f", "#a9aec6", "#d2d6e8", "#f0f2fa" }
local PAPER = { "#8a7262", "#b89c82", "#dcc6a4", "#efdfbe", "#fff0d4" }
local BOUNCE = "#9a4a78"

local AX, AY = 41, 6
local ang = math.rad(24)
local LEN = 53
local BX, BY = AX - math.sin(ang) * LEN, AY + math.cos(ang) * LEN
local function sup(d, d0, d1, R, p)        -- rounded-box profile between d0..d1
  local h = (d1 - d0) / 2
  local u = abs((d - (d0 + h)) / h)
  if u >= 1 then return 0 end
  return R * (1 - u ^ p) ^ (1 / p)
end
local function rf(d)
  if d <= 11 then return sup(d, -0.2, 11.2, 10.5, 3.2) end                 -- cap
  if d <= 23 then                                                           -- waisted grip
    local u = (d - 11) / 12
    local r = 3.6 + 1.6 * (2 * u - 1) ^ 2
    return r
  end
  if d <= 27.5 then return max(3.2, sup(d, 22.6, 27.6, 8.6, 2.6)) end       -- flange
  if d <= 46 then return 1.45 end                                           -- needle
  return 1.45 * (1 - (d - 46) / 7) + 0.3
end
local m, n, D, S, ax = A.lathe(AX, AY, BX, BY, rf)

-- paper note behind the needle (drawn first so the needle covers it)
local pcx, pcy = AX - math.sin(ang) * 40, AY + math.cos(ang) * 40
local pm = c:poly{ { pcx - 9, pcy - 5 }, { pcx - 4, pcy - 7 }, { pcx - 1, pcy - 6 }, { pcx + 3, pcy - 8 }, { pcx + 8, pcy - 5 },
  { pcx + 9, pcy + 2 }, { pcx + 6, pcy + 3 }, { pcx + 4, pcy + 6 }, { pcx + 1, pcy + 4 }, { pcx - 3, pcy + 6 }, { pcx - 8, pcy + 4 } }
local ptok = { r = { name = "paper" } }
local pidx = {}
pm:each(function(x, y)
  local q = (x - pcx) * 0.5 + (y - pcy)
  local v = q > 3.5 and 2 or (q > 0.5 and 3 or (q > -3.5 and 4 or 5))
  pidx[K(x, y)] = v
  c:put(x, y, PAPER[v], ptok)
end)
-- folded-up corner (upper-left): a lit flap with a dark crease
A.pts(c, { { floor(pcx - 8), floor(pcy - 4) }, { floor(pcx - 7), floor(pcy - 4) }, { floor(pcx - 7), floor(pcy - 3) } }, PAPER[2], ptok)
-- two scribbled lines of red handwriting, slanting with the note
for i = 0, 9 do local x = floor(pcx - 6 + i) local y = floor(pcy - 3 + i * 0.12 + ((i % 3 == 1) and -1 or 0))
  if pm:has(x, y) and i ~= 5 then c:put(x, y, "#c8344a", ptok) end end
for i = 0, 6 do local x = floor(pcx - 5 + i) local y = floor(pcy + 1 + i * 0.12 + ((i % 3 == 2) and -1 or 0))
  if pm:has(x, y) then c:put(x, y, "#c8344a", ptok) end end

-- body tones
local bias = {}
local bodyM, needM = HP.mask(), HP.mask()
m:each(function(x, y) local k = K(x, y) local d = D[k]
  if d > 27.2 then needM:set(x, y) else bodyM:set(x, y) end
  if (d > 11 and d < 12.6) or (d > 22.2 and d < 23.6) then bias[k] = -1 end       -- AO under cap / over flange
  if d > 27.2 and d < 29.6 then bias[k] = -1 end                                   -- needle root
end)
local rtok = { r = { name = "pinred" } }
local idx = A.tone(c, bodyM, n, RED, { amb = 0.04, wrap = 0.1, bias = bias, cuts = { 0.24, 0.42, 0.58, 0.74, 0.9 }, tok = rtok })
local stok = { r = { name = "steel" } }
local sidx = A.tone(c, needM, n, STEEL, { amb = 0.12, wrap = 0.3, bias = bias, cuts = { 0.2, 0.34, 0.5, 0.64, 0.8 }, tok = stok })
-- steel bevel: bright lit edge row + dark shade edge on the needle
needM:each(function(x, y) local k = K(x, y)
  if D[k] < 48 then
    if S[k] < -0.55 then c:put(x, y, STEEL[6], stok) elseif S[k] > 0.6 then c:put(x, y, STEEL[2], stok) end
  end
end)
-- paper contact shadow beside the needle (lower-right) + pierce hole
pm:each(function(x, y)
  if not needM:has(x, y) and (needM:has(x - 1, y) or needM:has(x - 1, y - 1)) then c:put(x, y, PAPER[1], ptok) end
end)

-- reflected cool light on the lower-right rims of cap and flange
local rim = X.rim(n)
bodyM:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.75 and S[k] > 0.7 then c:put(x, y, BOUNCE, rtok) end end)
-- turned groove round the grip: dark groove + lit lip above it (skip the outer edge pixels)
bodyM:each(function(x, y) local k = K(x, y) local d = D[k]
  if abs(S[k]) < 0.85 then
    if abs(d - 17.2) < 0.5 then c:put(x, y, RED[max(1, (idx[k] or 3) - 2)], rtok)
    elseif abs(d - 16.2) < 0.5 and S[k] < 0.3 then c:put(x, y, RED[min(6, (idx[k] or 3) + 1)], rtok) end
  end end)
-- specular streak on the cap shoulder, along the lit side
for d = 2.5, 8.5, 1 do
  local s = -0.62 * 10.5
  local x = floor(AX + ax.ux * d + ax.px * s + .5)
  local y = floor(AY + ax.uy * d + ax.py * s + .5)
  if bodyM:has(x, y) then c:put(x, y, RED[6], rtok) end
end
do local d, s = 4.5, -0.6 * 10.5
  local x = floor(AX + ax.ux * d + ax.px * s + .5) local y = floor(AY + ax.uy * d + ax.py * s + .5)
  c:put(x, y, A.SPEC, rtok) c:put(x + 1, y, A.SPEC, rtok) end
A.save(c)
