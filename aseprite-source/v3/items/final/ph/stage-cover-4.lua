-- stage-cover-4 (lean P1b_O20)
-- Growth stage 4 of ground cover (clover): soil mound like stage-grain-1, a fan of tall stalks each with a trefoil of chevron-marked leaflets, three pink pom-pom blooms and a bee (quirk) on the tallest.
local NAME = "stage-cover-4"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tk(n) return { r = { name = n } } end
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = tk(nm) if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local LEAF = { "#103a2c", "#1c6238", "#34904a", "#5cb854", "#92da68", "#cdf49a" }
local STALK = { "#2c5a3a", "#4a8450", "#7cb468", "#b4dc8c" }
local PINK = { "#7a2a5c", "#b84a86", "#e276aa", "#f8a8c8", "#ffe0ec" }
c:groundShadow(32, 56, 24, 3)
local soil = c:ellipse(32, 50, 22, 7)
soil:add(c:ellipse(32, 47, 15, 6))
ball(soil, 9, SOIL, "soil", { amb = 0.1, wrap = 0.2 })
soil:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5], tk"soil") elseif h < 0.07 then c:put(x, y, SOIL[1], tk"soil") end end)
for _, p in ipairs{ {16,52},{17,52},{48,52},{49,52},{47,53} } do c:put(p[1], p[2], "#b8a898", tk"pb") end
-- stalks: base, control, tip (flower or leaf trio)
local S = {
  { 30, 24, 22, 20, 5.5, "bloom" }, { 34, 20, 43, 14, 5.5, "bloom" }, { 32, 12, 33, 6, 5, "bloom" },
  { 29, 12, 13, 30, 0, "leaf" }, { 35, 12, 51, 30, 0, "leaf" }, { 31, 10, 24, 34, 0, "leaf" }, { 33, 10, 41, 36, 0, "leaf" },
}
local function trefoil(cx, cy, r, rot)
  for k = 0, 2 do
    local a = rot + k * 2.0944 - 1.5708
    local lx, ly = cx + cos(a) * r * 0.8, cy + sin(a) * r * 0.8
    local lm, ln = G.oval(lx, ly, r * 0.85, r * 0.65, a, 1.1)
    G.toneN(c, lm, ln, LEAF, { tok = tk("leaflet"), amb = 0.1, wrap = 0.3, cuts = {0.2,0.38,0.55,0.72,0.86} })
    for s = -1, 1 do c:put(floor(lx + cos(a) * s * 1.2 + 0.5), floor(ly + sin(a) * s * 1.2 + 0.5), LEAF[6], tk"chev") end
  end
end
local blooms = {}
for _, s in ipairs(S) do
  local ax, ay = 32 + (s[1] - 32) * 0.4, 46
  local sm, sn = G.tube({ {ax, ay}, {s[1], ay - 8}, {s[3], s[4] + 8}, {s[3], s[4]} }, function(t) return 1.1 end)
  G.toneN(c, sm, sn, STALK, { tok = tk"stalk", amb = 0.15, wrap = 0.3, cuts = {0.3,0.55,0.8} })
  if s[6] == "leaf" then trefoil(s[3], s[4], 4.5, (s[3] - 32) * 0.03) else blooms[#blooms + 1] = s end
end
for fi, f in ipairs(blooms) do
  local r = f[5]
  local fm = c:ellipse(f[3], f[4], r, r - 0.5)
  ball(fm, r + 1, PINK, "flower", { amb = 0.12, wrap = 0.3, cuts = {0.2,0.4,0.6,0.8} })
  for k = 1, 10 do
    local a = k * 2.4 + fi
    local rr = (k % 3 + 1) * r / 4
    c:put(floor(f[3] + cos(a) * rr + 0.5), floor(f[4] + sin(a) * rr * 0.9 + 0.5), k % 2 == 0 and PINK[1] or PINK[5], tk"floret")
  end
  c:put(f[3] - 2, f[4] - 2, "#fff4f8", tk"floret")
end
-- base leaves hugging the soil
for _, p in ipairs{ {20,45,4.5},{26,47,4.5},{38,47,4.5},{44,45,4.5},{32,46,5} } do trefoil(p[1], p[2], p[3], (p[1] - 32) * 0.04) end
-- bee on the top bloom (quirk)
local bx, by = 40, 5
c:fillMask(c:ellipse(bx, by, 3, 2), "#f2c230")
for _, p in ipairs{ {bx-1,by-1},{bx-1,by},{bx-1,by+1},{bx+1,by-1},{bx+1,by},{bx+1,by+1} } do c:put(p[1], p[2], "#2b1c26", tk"bee") end
c:put(bx - 2, by, "#f8e070", tk"bee") c:put(bx + 3, by, "#2b1c26", tk"bee")
c:fillMask(c:ellipse(bx - 1, by - 3, 2, 1), "#d8f0ff") c:put(bx - 2, by - 3, "#e8fbff", tk"bee")
G.save(c, NAME)
