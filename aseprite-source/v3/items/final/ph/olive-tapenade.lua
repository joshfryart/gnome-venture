-- olive-tapenade (final, Opus single pass, aC31_0). A small Provencal crock: bare terracotta foot (clay grit
-- specks) dipped in glossy ochre glaze that ends in a wavy drip line, rolled lip with a lit top edge; heaped
-- with dark olive paste (lumpy per-pixel relief, chopped green-olive bits, red pimento and caper flecks, an oily
-- glint), one whole green olive pressed into the top, and a slim olive-wood spreader stuck in at an angle
-- (grain lines, paler end grain, AO where it enters the paste). Ground shadow under the crock.
-- quirk: one caper has escaped and sits on the ground by the foot.
local NAME = "olive-tapenade"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLAZE = { "#6a3a1c", "#9a5a1e", "#c88428", "#e8aa34", "#f8cf5c", "#fff0a8" }
local CLAY  = { "#4e2420", "#74362a", "#9a4c34", "#bc6a44", "#d88c5c", "#eeb282" }
local PASTE = { "#16121a", "#251c26", "#382a32", "#4c3a3c", "#665044", "#87704e" }
local BITS  = { "#4e5f2a", "#728a36", "#9aae4c" }
local PIM, CAPER = { "#8e2030", "#d4402e" }, { "#2c3a20", "#4f6a2e", "#7f9a48" }
local WOOD  = { "#4a2e22", "#6e4630", "#92633e", "#b6844e", "#d4a868", "#ecca90" }
local OLV   = { "#283a1e", "#41562a", "#5f7630", "#80973a", "#a6b84c", "#cfd877" }

local CX = 32
c:groundShadow(CX, 54, 19, 2)

-- body: rows y 38..53, half width hw(y)
local Y0, Y1 = 38, 53
local function hw(y) local t = (y - Y0) / (Y1 - Y0) return 16.2 - 3.6 * t ^ 1.6 end
local body = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
local bn = {}
body:each(function(x, y) local h = hw(y)
  local nx = max(-0.96, min(0.96, (x - CX + 0.5) / (h + 0.3)))
  local ny = 0.25 + (y > Y1 - 2 and 0.5 or 0)
  bn[K(x, y)] = { A.norm(nx, ny, sqrt(1 - nx * nx)) }
end)
local glazeM, clayM = HP.mask(), HP.mask()
body:each(function(x, y)
  local line = 47 + floor(1.3 * sin((x - CX) * 0.55) + 0.5) + ((x % 9 == 3) and 2 or 0)     -- wavy dip line + drips
  if y < line then glazeM:set(x, y) else clayM:set(x, y) end
end)
local bb = {}
for x = CX - 18, CX + 18 do bb[K(x, Y0)] = -1 end                                         -- AO under the lip
local gtok, ctok = { r = { name = "glaze" } }, { r = { name = "clay" } }
local gv = X.light(bn, { amb = 0.08, wrap = 0.25 })
local gi = X.tone(c, glazeM, gv, GLAZE, { cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 }, bias = bb, tok = gtok })
local ci = X.tone(c, clayM, gv, CLAY, { cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 }, bias = bb, tok = ctok })
-- glaze edge bead (thicker glaze is darker) + clay grit
glazeM:each(function(x, y) if clayM:has(x, y + 1) then c:put(x, y, GLAZE[max(1, gi[K(x, y)] - 1)], gtok) end end)
clayM:each(function(x, y) if X.hash(x, y, 7) > 0.85 then c:put(x, y, CLAY[min(6, ci[K(x, y)] + 1)], ctok)
  elseif X.hash(x, y, 8) > 0.9 then c:put(x, y, CLAY[max(1, ci[K(x, y)] - 1)], ctok) end end)
-- vertical specular streak on the glaze + cool reflected light on the right
for y = 40, 45 do c:put(21, y, y < 43 and "#fffbe0" or GLAZE[6], gtok) end
c:put(22, 40, GLAZE[6], gtok)
body:edge():each(function(x, y) if x > CX + 8 and y > 40 and y < 50 then c:put(x, y, glazeM:has(x, y) and "#a08a70" or "#7a5a6a", gtok) end end)

-- rolled lip: ellipse ring
local lip = c:ellipse(CX, 37, 17, 2.5)
local hole = c:ellipse(CX, 36.5, 14.5, 1.5)
lip:cut(hole)
local ltok = { r = { name = "lip" } }
lip:each(function(x, y)
  local top = y <= 36
  local i = top and 5 or 3
  if x > CX + 9 then i = i - 1 end
  if x < CX - 10 and top then i = 6 end
  c:put(x, y, GLAZE[i], ltok)
end)
for x = CX - 13, CX + 13 do if lip:has(x, 39) then c:put(x, 39, GLAZE[2], ltok) end end   -- underside of the roll

-- paste heap: dome
local heap = HP.mask()
for y = 24, 37 do for x = CX - 16, CX + 16 do
  local dx = (x - CX + 0.5) / 15.0
  local top = 36.6 - 11.5 * max(0, 1 - dx * dx) ^ 0.7 + 1.0 * sin(x * 0.9) * max(0, 1 - dx * dx)
  if abs(dx) <= 1 and y >= top and y <= 37 and not lip:has(x, y) then heap:set(x, y) end
end end
heap:cut(lip)
local hn = X.pillow(heap, 4)
for k, n in pairs(hn) do local x, y = k % 1024 - 256, k // 1024 - 256
  local j = (X.hash(x // 2, y // 2, 4) - 0.5) * 0.9                                       -- lumpy relief
  hn[k] = { A.norm(n[1] + j, n[2] - j * 0.5, n[3]) } end
local pb = {}
X.ao(pb, heap, lip, 1, -1)
local ptok = { r = { name = "paste" } }
local pi_, pv = A.shade(c, heap, hn, PASTE, { amb = 0.1, wrap = 0.3, bias = pb, tok = ptok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
heap:copy():shrink(1):each(function(x, y) local h = X.hash(x, y, 31)
  if h > 0.93 then c:put(x, y, BITS[pv[K(x, y)] > 0.5 and 3 or 2], ptok)
  elseif h > 0.89 then c:put(x, y, BITS[1], ptok)
  elseif h < 0.035 then c:put(x, y, PIM[pv[K(x, y)] > 0.5 and 2 or 1], ptok) end end)
c:put(27, 28, "#c8b090", ptok) c:put(28, 28, "#a89070", ptok)                              -- oily glint

-- whole green olive pressed into the heap
local om, on = A.oval(25, 30, 3.6, 2.6, 0.35, 0.9)
local otok = { r = { name = "olive" } }
A.cast({}, heap, om, 1, 1, -1)
om:shift(1, 1):each(function(x, y) if heap:has(x, y) and not om:has(x, y) then c:put(x, y, PASTE[1], ptok) end end)
A.shade(c, om, on, OLV, { amb = 0.06, wrap = 0.2, tok = otok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
c:put(23, 28, "#f6f8d0", otok) c:put(24, 28, "#f6f8d0", otok) c:put(28, 31, OLV[2], otok)

-- spreader: slim olive-wood paddle stuck in at an angle
local wtok = { r = { name = "wood" } }
local sm, sn, ST, SS, si = A.stem(c, { { 39, 30 }, { 43, 24 }, { 48, 17 }, { 52, 11 } },
  function(t) return 1.5 + (t > 0.78 and 0.5 or 0) end, WOOD, { tok = wtok })
sm:each(function(x, y) local k = K(x, y)
  if abs(SS[k] + 0.2 * sin(ST[k] * 22)) < 0.12 and ST[k] < 0.85 then c:put(x, y, WOOD[max(1, si[k] - 1)], wtok) end   -- grain
  if ST[k] > 0.94 then c:put(x, y, SS[k] < 0 and WOOD[6] or WOOD[5], wtok) end                                      -- end grain
end)
-- AO where the handle enters the paste
for _, p in ipairs{ { 38, 31 }, { 39, 31 }, { 40, 31 }, { 41, 30 }, { 37, 30 } } do
  if heap:has(p[1], p[2]) and not sm:has(p[1], p[2]) then c:put(p[1], p[2], PASTE[1], ptok) end end

-- quirk: escaped caper on the ground at the right of the foot
local cm, cn = A.oval(52, 53, 1.8, 1.6, 0, 0.9)
A.shade(c, cm, cn, CAPER, { tok = { r = { name = "caper" } }, cuts = { 0.35, 0.65 } })
c:put(51, 52, "#b8c880")

A.save(c, NAME)
