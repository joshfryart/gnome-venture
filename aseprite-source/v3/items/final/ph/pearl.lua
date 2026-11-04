-- pearl (final, Opus single pass). One big lustrous pearl seated in an open oyster half-shell seen from the front-top:
-- a low, wide shell (frilly scalloped lip, rough grey-violet outer with concentric growth ridges, a hinge knob below)
-- holding a concave iridescent nacre cup (pink-lilac-mint bands, lit on the lower-right inner wall).
-- Material: per-pixel sphere light on the pearl (6 tones, cool lilac shade), pink orient rim + mint reflected light,
-- 2x1 cream specular + a soft window highlight, AO ring where the pearl sinks into the nacre, contact shadow.
-- quirk: a tiny barnacle (cone with a dark mouth) clings to the shell lip on the right.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("pearl")

local SHELL = { "#2f2638", "#4c3d55", "#6c5a6e", "#8f7c88", "#b6a3a6", "#d8c8c0" }
local NACRE = { "#7a6a96", "#a08bb6", "#c4aed0", "#e2cfe0", "#f4e6ec", "#fdf6f2" }
local PEARL = { "#4e4a6e", "#7c7898", "#aaa6c0", "#d2cedc", "#ece8e8", "#fbf8f2" }
local MINT, PINK, ROSE = "#b4e2d6", "#f2c6d4", "#e7a6c0"

-- shell: wide frilly ellipse, centre (32,41)
local CX, CY, RX, RY = 32, 41, 22, 12.5
local shell = HP.mask()
local SA = {}
for y = 20, 60 do for x = 4, 60 do
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  local a = atan(dy, dx)
  local r = sqrt(dx * dx + dy * dy)
  local frill = 1 + 0.055 * cos(a * 9) + (dy < 0 and 0.03 * cos(a * 17) or 0)
  if r <= frill then shell:set(x, y) SA[K(x, y)] = r / frill end
end end
-- hinge knob (umbo) below
local umbo = HP.mask()
for y = 52, 56 do for x = 28, 36 do
  local dx, dy = (x - 32) / 4.6, (y - 52.5) / 3.6
  if dx * dx + dy * dy <= 1 then umbo:set(x, y) end
end end
umbo:cut(shell)
-- nacre cup: inner ellipse, a bit higher (we see into the cup)
local cup = HP.mask()
local CA = {}
shell:each(function(x, y)
  local dx, dy = (x - CX) / (RX - 3.2), (y - (CY - 1.2)) / (RY - 3.4)
  local r = sqrt(dx * dx + dy * dy)
  if r <= 1 then cup:set(x, y) CA[K(x, y)] = r end
end)
local lip = shell:copy():cut(cup)

-- pearl
local PX, PY, PR = 32, 33, 10.2
local pearl = HP.mask()
for y = 20, 46 do for x = 18, 46 do
  if (x - PX) ^ 2 + (y - PY) ^ 2 <= (PR + 0.3) ^ 2 then pearl:set(x, y) end
end end

-- outer lip: pillow light + concentric growth ridges
local stok, ntok, ptok = { r = { name = "shell" } }, { r = { name = "nacre" } }, { r = { name = "pearl" } }
local lb = {}
X.ao(lb, lip, umbo, 1, -1)
local lidx = A.shade(c, lip:copy():cut(pearl), X.pillow(shell, 4), SHELL, { amb = 0.1, wrap = 0.3, bias = lb, tok = stok })
lip:copy():cut(pearl):each(function(x, y) local k = K(x, y)
  local r = SA[k]
  local ph = (r * 9.5) % 1
  if ph < 0.28 and X.hash(x, y, 3) > 0.25 then A.step(c, lidx, SHELL, x, y, -1, stok)
  elseif ph > 0.5 and ph < 0.62 and X.hash(x, y, 5) > 0.55 then A.step(c, lidx, SHELL, x, y, 1, stok) end
end)
-- lip edge of the cup gets a pale nacre rim (inner edge of shell)
-- umbo
local uidx = A.shade(c, umbo, X.pillow(umbo, 2.5), SHELL, { amb = 0.08, wrap = 0.25, tok = stok })
for x = 29, 35, 2 do if umbo:has(x, 54) then A.step(c, uidx, SHELL, x, 54, -1, stok) end end

-- nacre cup: concave -> invert pillow xy (lit on the lower-right inner wall)
local pn = X.pillow(cup, 5)
local cn = {}
for k, n in pairs(pn) do cn[k] = { -n[1] * 0.9, -n[2] * 0.9, n[3] } end
local cb = {}
X.ao(cb, cup, pearl, 2, -1)
local cupv = cup:copy():cut(pearl)
-- contact shadow: below/right of the pearl
pearl:shift(1, 2):each(function(x, y) if cupv:has(x, y) and not pearl:has(x, y) then local k = K(x, y) cb[k] = (cb[k] or 0) - 1 end end)
local cidx = A.shade(c, cupv, cn, NACRE, { amb = 0.14, wrap = 0.35, bias = cb, tok = ntok })
-- iridescent bands following the cup rim
cupv:each(function(x, y) local k = K(x, y)
  local r = CA[k]
  local i = cidx[k]
  if i and i >= 3 and not cb[k] then
    if r > 0.82 and r < 0.9 then c:put(x, y, PINK, ntok)
    elseif r > 0.66 and r < 0.72 and x > CX then c:put(x, y, MINT, ntok) end
  end
end)
-- pale inner rim where nacre meets the lip, deeper at the back (top) wall
cup:edge():each(function(x, y) if not pearl:has(x, y) then
  if y < CY - 3 then c:put(x, y, NACRE[1], ntok) elseif y > CY + 2 then c:put(x, y, NACRE[6], ntok) end
end end)

-- pearl: sphere light, orient colours
local pnrm = X.sphere(PX, PY, PR, pearl)
local pb = {}
-- AO where pearl sinks into the cup (lowest rows)
pearl:each(function(x, y) if y >= PY + PR - 1.5 then pb[K(x, y)] = -1 end end)
local pidx, pv = A.shade(c, pearl, pnrm, PEARL, { amb = 0.1, wrap = 0.3, bias = pb, tok = ptok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
local rim = X.rim(pnrm)
pearl:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and y < PY + PR - 1 then c:put(x, y, MINT, ptok) end
end)
-- pink orient: a soft band on the shade side inside the edge
pearl:shrink(1):edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.5 and y < PY + 7 and y > PY - 4 then c:put(x, y, ROSE, ptok) end
end)
-- window highlight: a soft cream patch and a 2x1 specular + one glint
for _, p in ipairs{ { 27, 27 }, { 28, 27 }, { 26, 28 }, { 27, 28 }, { 26, 29 } } do c:put(p[1], p[2], PEARL[6], ptok) end
c:put(28, 26, "#fffdf8", ptok) c:put(29, 26, "#fffdf8", ptok)
-- secondary faint reflection of the nacre in the lower pearl
c:put(35, 40, PINK, ptok) c:put(36, 40, PINK, ptok)

-- quirk: barnacle on the right lip
local bx, by = 50, 36
local bm = HP.mask()
for y = by - 3, by + 2 do for x = bx - 3, bx + 3 do if ((x - bx) / 3.2) ^ 2 + ((y - by) / 2.6) ^ 2 <= 1 then bm:set(x, y) end end end
local btok = { r = { name = "barnacle" } }
local BAR = { "#4a4048", "#7a6c6c", "#a8988e", "#d0c2b0", "#ece2d0" }
A.shade(c, bm, X.sphere(bx, by, 3, bm), BAR, { amb = 0.1, wrap = 0.3, tok = btok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
c:put(bx, by - 1, BAR[1], btok) c:put(bx + 1, by - 1, BAR[1], btok) c:put(bx - 1, by - 1, BAR[2], btok)
c:put(bx - 2, by, BAR[4], btok) c:put(bx + 2, by + 1, BAR[2], btok)

A.save(c, "pearl")
