-- red-ochre (final, Sonnet high, D12-1). A raw nodule of red ochre, split into five crisp facets with sedimentary
-- bands of yellow ochre and a dark iron seam, hematite glitter on the fresh faces, resting against a pearly scallop-shell
-- paint dish (radial ribs, scalloped lip, raised ears at the hinge) that holds a heap of fine red powder with a finger
-- swipe through it. Ambient shading and a contact shadow where nodule meets shell. quirk: a tiny red thumbprint is
-- pressed on the shell lip, with a few stray grains of powder around it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("red-ochre")
local OC  = { "#34121a", "#6a2220", "#9a3026", "#c44c30", "#de7042", "#f4a05e" }
local YEL = { "#5e3a16", "#926022", "#c48a2c", "#e2b04a", "#f4d27a", "#fff0aa" }
local PW  = { "#5a1a22", "#8e2c2a", "#bc4630", "#de6a42", "#f2905c", "#ffc294" }
local SH  = { "#6a4a5c", "#957080", "#c19a98", "#e4c4b0", "#f6e2d0", "#fffaf0" }
local CREAM = "#fff4d6"
local nz = A.noise1

c:groundShadow(33, 58, 22, 2.5)

-- scallop shell (hinge at bottom, fan opening up)
local HX, HY, RB, NR = 40, 57, 17.5, 8
local TH0, TH1 = -pi * 0.88, -pi * 0.12
local shell = HP.mask()
local U = {}
for y = 30, 62 do for x = 15, 62 do
  local dx, dy = x + 0.5 - HX, y + 0.5 - HY
  local r, th = sqrt(dx * dx + dy * dy), atan(dy, dx)
  if th >= TH0 and th <= TH1 then
    local u = (th - TH0) / (TH1 - TH0)
    local f = (u * NR) % 1
    local R = RB + 2.1 * sqrt(max(0, 1 - (2 * f - 1) ^ 2))
    if r <= R then shell:set(x, y) U[K(x, y)] = { u * NR, r, R } end
  end
end end
for _, q in ipairs{ { -5, 2, 5, 2, 3, -4, -3, -4 } } do
  local ear = c:poly{ { HX - 5, HY + 2 }, { HX + 5, HY + 2 }, { HX + 4, HY - 4 }, { HX - 4, HY - 4 } }
  shell:add(ear) ear:each(function(x, y) U[K(x, y)] = U[K(x, y)] or { 4, 4, 8 } end)
end
local sn = X.pillow(shell, 3.2)
local sidx = A.shade(c, shell, sn, SH, { cuts = { 0.24, 0.42, 0.6, 0.78, 0.92 }, amb = 0.1, wrap = 0.3 })
shell:each(function(x, y) local k = K(x, y)
  local u = U[k] if not u then return end
  local f = u[1] % 1
  local i = sidx[k] or 3
  if u[2] > 6 and u[2] < u[3] - 1.2 then
    if f < 0.12 or f > 0.93 then c:px(x, y, SH[max(1, i - 2)])
    elseif f > 0.42 and f < 0.58 then c:px(x, y, SH[min(6, i + 1)]) end
  end
  -- lip: pale rim along the scalloped edge, lit side only
  if u[2] > u[3] - 1.3 and u[2] > 6 and (x + y) < HX + HY - 6 then c:px(x, y, SH[6]) end
end)
-- growth arcs near the hinge
for r = 5, 7, 2 do for i = 0, 40 do
  local th = TH0 + (TH1 - TH0) * i / 40
  local x, y = floor(HX + cos(th) * r), floor(HY + sin(th) * r)
  if shell:has(x, y) then c:px(x, y, SH[2]) end
end end

-- powder heap in the shell
local pcx, pcy = 40, 49
local heap = HP.mask()
for x = pcx - 11, pcx + 11 do
  local f = max(0, 1 - abs(x + 0.5 - pcx) / 11)
  local top = floor(pcy + 4 - 12 * f ^ 0.72 + 0.5)
  local bot = floor(pcy + 4 + 1.6 * sqrt(f) + 0.5)
  for y = top, bot do heap:set(x, y) end
end
heap:clip(shell)
local hn = X.pillow(heap, 4.6, 1.5)
local hbias = {}
local hidx = A.shade(c, heap, hn, PW, { cuts = { 0.22, 0.4, 0.58, 0.75, 0.9 }, amb = 0.08, wrap = 0.25 })
-- grain: scattered lighter/darker specks
heap:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 17)
  local i = hidx[k] or 3
  if h > 0.86 then c:px(x, y, PW[min(6, i + 1)]) elseif h < 0.1 then c:px(x, y, PW[max(1, i - 1)]) end end)
-- finger swipe: a curved furrow with raised lips
for i = 0, 12 do
  local t = i / 12
  local x, y = floor(35 + t * 10 + .5), floor(49 + 1.6 * sin(t * pi * 1.1) + .5)
  if heap:has(x, y) then c:px(x, y, PW[2]) end
  if heap:has(x, y - 1) then c:px(x, y - 1, PW[6]) end
  if heap:has(x, y + 1) then c:px(x, y + 1, PW[3]) end
end
-- dark seam where heap meets shell
local rim = heap:grow(1):cut(heap)
rim:each(function(x, y) if shell:has(x, y) and (y > pcy or x > pcx + 3) then c:px(x, y, SH[1]) end end)

-- quirk: thumbprint on the lip (upper right), stray grains
local tx, ty = floor(HX + cos(-0.62) * 16.2), floor(HY + sin(-0.62) * 16.2)
local tp = A.ell and nil
local tpm = HP.mask()
for y = ty - 4, ty + 4 do for x = tx - 4, tx + 4 do
  local dx, dy = x - tx, y - ty
  local a, b = dx * 0.8 - dy * 0.6, dx * 0.6 + dy * 0.8
  if (a / 3.4) ^ 2 + (b / 2.5) ^ 2 <= 1 and shell:has(x, y) and not heap:has(x, y) then tpm:set(x, y) end
end end
tpm:each(function(x, y)
  local dx, dy = x - tx, y - ty
  local a, b = dx * 0.8 - dy * 0.6, dx * 0.6 + dy * 0.8
  local rr = sqrt((a / 3.4) ^ 2 + (b / 2.5) ^ 2)
  c:px(x, y, (floor(rr * 3 + 0.2) % 2 == 0) and PW[3] or PW[5])
end)
for _, g in ipairs{ { -5, 2 }, { 4, 3 }, { -2, -4 }, { 6, -1 } } do
  local x, y = tx + g[1], ty + g[2]
  if shell:has(x, y) and not heap:has(x, y) and not tpm:has(x, y) then c:px(x, y, PW[4]) end
end

-- ochre nodule (front left), five facets
local nod = c:poly{ { 10, 52 }, { 7, 44 }, { 9, 35 }, { 14, 29 }, { 19, 26 }, { 24, 30 }, { 26, 38 }, { 26, 46 }, { 24, 53 }, { 17, 56 } }
local fseed = {
  { 13, 36, -0.2, -0.75 }, { 20, 33, 0.4, -0.5 }, { 11, 46, -0.7, 0.1 }, { 17, 49, 0.05, 0.45 }, { 23, 43, 0.7, 0.2 },
}
local FID = {}
local nn = X.pillow(nod, 2.4)
nod:each(function(x, y) local k = K(x, y)
  local best, bi = 1e9
  for i, s in ipairs(fseed) do
    local d = (x - s[1]) ^ 2 + (y - s[2]) ^ 2
    if d < best then best, bi = d, i end
  end
  FID[k] = bi
  local s = fseed[bi]
  local n = nn[k]
  nn[k] = { A.norm(n[1] + s[3] * 0.75, n[2] + s[4] * 0.75, n[3] * 0.9) }
end)
local bias = {}
X.ao(bias, nod, shell, 1, -1)
local nidx = A.shade(c, nod, nn, OC, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, bias = bias, amb = 0.14, wrap = 0.3 })
nod:each(function(x, y) local k = K(x, y)
  local i = nidx[k] or 3
  -- strata: yellow ochre band, dark iron seam, tilted and wavy
  local v = x * 0.32 + y * 0.9 + 3.0 * nz(x * 0.22 + y * 0.1, 8)
  local b = v % 15
  if b < 1.6 then c:px(x, y, YEL[max(1, min(6, i))])
  elseif b > 6.0 and b < 7.0 then c:px(x, y, OC[max(1, i - 2)])
  end
  -- facet crease: bevel (dark on the lower-right side of a change, lit on the upper-left)
  local f = FID[k]
  local fl, fu = FID[K(x - 1, y)], FID[K(x, y - 1)]
  if (fl and fl ~= f) or (fu and fu ~= f) then c:px(x, y, OC[max(1, i - 2)]) end
  local fr, fd = FID[K(x + 1, y)], FID[K(x, y + 1)]
  if ((fr and fr ~= f) or (fd and fd ~= f)) and (x + y) < 62 then c:px(x, y, OC[min(6, i + 1)]) end
end)
-- contact shadow of the nodule on the shell
local cb = {}
G.cast(cb, shell, nod, 2, 1, -1)
nod:shift(2, 1):each(function(x, y) if shell:has(x, y) and not nod:has(x, y) and not heap:has(x, y) then c:px(x, y, SH[1]) end end)
-- hematite glitter on the fresh faces
c:px(13, 34, CREAM) c:px(14, 34, CREAM) c:px(20, 31, CREAM) c:px(18, 44, YEL[6]) c:px(23, 37, CREAM)
A.save(c, "red-ochre")
