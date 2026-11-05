-- stage-cover-4 (lean P1b_O10)
-- Growth stage 4 of ground cover: a dense, domed clover mat of overlapping leaflets over a thin soil rim, tall stalks with pink-white pom-pom flowers, and a fat bee visiting the biggest bloom (quirk).
local NAME = "stage-cover-4"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, vf, nm, adj)
  local tok = { r = { name = nm } }
  local nr = #ramp
  m:each(function(x, y)
    local v = vf(x, y)
    local i = 1 + floor(max(0, min(0.999, v)) * nr)
    if adj then i = adj(x, y, i, v) or i end
    c:put(x, y, ramp[max(1, min(nr, i))], tok)
  end)
end
local function T(nm) return { r = { name = nm } } end
local function blob(c, m, R, ramp, nm, amb, wrap, adj)
  local v = X.light(X.pillow(m, R), { amb = amb or 0.1, wrap = wrap or 0.25 })
  paint(c, m, ramp, function(x, y) return v[K(x, y)] end, nm, adj)
end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local LEAF = { "#143a2c", "#20603a", "#38884a", "#5cae54", "#8ed068", "#c4ee90" }
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 56, 25, 3)
local soil = c:ellipse(32, 52, 23, 5)
blob(c, soil, 6, SOIL, "soil", 0.1, 0.2, function(x, y, i) local h = X.hash(x, y, 5) if h > 0.9 then return 5 elseif h < 0.07 then return 1 end end)
local STALK = { "#2c5a3a", "#4a8450", "#7cb468", "#b4dc8c" }
-- flower stalks (behind the mat)
local fl = { {22, 44, 18, 14, 5}, {32, 42, 33, 7, 6}, {45, 44, 49, 17, 5} }
for _, f in ipairs(fl) do
  local sm, sn = G.tube({ {f[1], f[2]}, {f[1], f[2] - 10}, {f[3], f[4] + 8}, {f[3], f[4]} }, function(t) return 1.0 end)
  local sv = X.light(sn, { amb = 0.15, wrap = 0.3 })
  paint(c, sm, STALK, function(x, y) return sv[K(x, y)] end, "stalk")
end
-- leaf mat: back-to-front overlapping leaflets over a dome
local mat = {}
local rows = { {0.0, 36, 11}, {0.0, 40, 12}, {0.0, 46, 12} }
local L = {}
for _, p in ipairs{ {32,31,6},{24,33,6},{40,33,6},{17,38,6},{47,38,6},{29,37,6.5},{37,37,6.5},{22,43,6.5},{42,43,6.5},{32,42,7},{14,46,5.5},{50,46,5.5},{27,48,6.5},{37,48,6.5},{19,48,5},{45,48,5} } do L[#L + 1] = p end
for i, p in ipairs(L) do
  local ang = (X.hash(i, 3, 7) - 0.5) * 1.4
  local lm, ln = G.oval(p[1], p[2], p[3], p[3] * 0.8, ang, 1.1)
  local lv = X.light(ln, { amb = 0.1, wrap = 0.3 })
  local shade = (p[2] - 31) / 20
  paint(c, lm, LEAF, function(x, y) return max(0, min(1, lv[K(x, y)] * (1 - 0.25 * shade) + 0.05)) end, "leaf")
  -- pale chevron
  local cx, cy = p[1], p[2] - 1
  for s = -2, 2 do c:put(floor(cx + s + 0.5), floor(cy + abs(s) * 0.5 + 0.5), LEAF[6], T"chev") end
  -- dark seam under leaf
  for s = -p[3] + 1, p[3] - 1 do c:put(floor(p[1] + s + 0.5), floor(p[2] + p[3] * 0.8 + 0.5), LEAF[1], T"seam") end
end
-- pom-pom flowers
local PINK = { "#8c5a78", "#c08aa8", "#e6b6cc", "#f8dce8", "#fff4f8" }
for fi, f in ipairs(fl) do
  local r = f[5]
  local fm = c:ellipse(f[3], f[4], r, r - 0.5)
  blob(c, fm, r + 1, PINK, "flower", 0.12, 0.3)
  -- florets
  for k = 1, 9 do
    local a = k * 2.4 + fi
    local rr = (k % 3 + 1) * r / 4
    local px, py = floor(f[3] + cos(a) * rr + 0.5), floor(f[4] + sin(a) * rr * 0.9 + 0.5)
    c:put(px, py, k % 2 == 0 and PINK[1] or PINK[5], T"floret")
  end
  c:put(f[3] - 2, f[4] - 2, "#ffffff", T"floret")
end
-- bee on the middle bloom
local bx, by = 40, 9
c:fillMask(c:ellipse(bx, by, 3, 2), "#f2c230")
for _, p in ipairs{ {bx-1,by-1},{bx-1,by},{bx-1,by+1},{bx+1,by-1},{bx+1,by},{bx+1,by+1} } do c:put(p[1], p[2], "#2b1c26", T"bee") end
c:put(bx - 2, by, "#f8e070", T"bee") c:put(bx + 3, by, "#2b1c26", T"bee")
c:fillMask(c:ellipse(bx - 1, by - 3, 2, 1), "#d8f0ff") c:put(bx - 2, by - 3, "#ffffff", T"bee")
G.save(c, NAME)
