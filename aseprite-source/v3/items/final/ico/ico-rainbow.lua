-- ico-rainbow (final pass, Opus). A tall half-ring of six 3-px bands (ember, tangerine, sun, leaf, sea, violet), lit
-- as one rounded tube across its width so the outer upper-left shoulder glows and the inner lower-right falls into
-- shade; each band has its own 5-tone ramp and a 1-px lit lip on its outer edge (candy-glass bevel), one long
-- specular streak on the red band. Its feet sink into two puffy cream clouds (6-tone, creased puffs, shadowed belly)
-- with a dark ambient row where the bands enter the cloud.
-- quirk: a tiny bluebird has perched on the very top of the arch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, atan, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.atan, math.pi
local c = A.new("ico-rainbow")
local BANDS = {
  { "#6e1e36", "#a82a3a", "#dc3e3c", "#f8644c", "#ff9a7a" }, -- red
  { "#7e3418", "#bf5a1c", "#ee8424", "#ffa640", "#ffcb7a" }, -- orange
  { "#8a5a14", "#cc961c", "#f5c62e", "#ffe15c", "#fff2a8" }, -- yellow
  { "#1d5a40", "#2d8a4c", "#4cb056", "#7ccc62", "#bce88a" }, -- green
  { "#23447e", "#2d68b0", "#3e92d8", "#6cb8ee", "#b0e0fa" }, -- blue
  { "#33245e", "#523a92", "#7458c0", "#9a80dc", "#cbb8f2" }, -- violet
}
local CREAMR = { "#8c6a62", "#bf9a86", "#e2c2a2", "#f4dcb8", "#fff0d2", "#fffbec" }
local CX, CY, RO, BW = 32, 43, 24, 3
local RI = RO - #BANDS * BW + 1

-- arch as one tube across the radius
local m, n, S, Aa = A.arc(CX, CY, (RO + RI) / 2, (RO - RI) / 2, pi, 2 * pi)
local v = X.light(n, { amb = 0.1, wrap = 0.4 })
local btok = {}
for i = 1, #BANDS do btok[i] = { r = { name = "band" .. i } } end
local function bandOf(x, y)
  local r = sqrt((x - CX)^2 + (y - CY)^2)
  return max(1, min(#BANDS, floor((RO + 0.5 - r) / BW) + 1)), r
end
m:each(function(x, y)
  local k = K(x, y)
  local b, r = bandOf(x, y)
  local ramp = BANDS[b]
  local val = v[k]
  local i = 1
  for j, t in ipairs{ 0.22, 0.42, 0.62, 0.86 } do if val >= t then i = j + 1 end end
  -- bevel inside the band: outer row lit, inner row one down
  local inBand = (RO + 0.5 - r) - (b - 1) * BW
  if inBand < 1 then i = i + 1 elseif inBand >= BW - 1 then i = i - 1 end
  i = max(1, min(5, i))
  c:put(x, y, ramp[i], btok[b])
end)
-- specular streak on the red band's upper-left shoulder
for a = 0, 30 do
  local t = pi * 1.17 + a / 30 * 0.22
  local x, y = floor(CX + math.cos(t) * (RO - 1) + .5), floor(CY + math.sin(t) * (RO - 1) + .5)
  if m:has(x, y) then c:put(x, y, "#ffd2b8", btok[1]) end
end
c:put(floor(CX + math.cos(pi * 1.2) * (RO - 1) + .5), floor(CY + math.sin(pi * 1.2) * (RO - 1) + .5), A.CREAM, btok[1])

-- clouds at the feet (drawn over the band ends); ambient row on the bands just above each cloud
local function foot(cx)
  local bumps = { { cx - 5, CY + 1, 4 }, { cx + 1, CY - 2, 5 }, { cx + 6, CY + 1, 4 }, { cx - 1, CY + 2, 4, true } }
  local before = {}
  local cm = A.cloud(c, bumps, CY + 6, cx - 9, cx + 10, CREAMR, { baseH = 4, amb = 0.2 })
  -- AO row on the arch just above the cloud top
  cm:each(function(x, y)
    if not cm:has(x, y - 1) and m:has(x, y - 1) then
      local b = bandOf(x, y - 1) c:put(x, y - 1, BANDS[b][1], btok[b])
    end
  end)
  return cm
end
foot(CX - RO + 9) foot(CX + RO - 9)

-- quirk: bluebird perched on the top of the arch (faces left; ink eye with glint, gold beak, pale belly)
local bx, by = 30, CY - RO - 6
A.map(c, {
  "...bbb...",
  "..bBBBb..",
  "gkcBBBBbt",
  ".pcwBBBbt",
  "..wwwbbt.",
  "...o.o...",
}, bx, by, { b = "#3a6ab0", B = "#5a9ae0", c = "#a8d8f8", k = "#2b1c26", g = "#f5b82e", w = "#fff0d2", p = "#f5809f", t = "#2a4a7a", o = "#d98322" })
A.save(c, "ico-rainbow")
