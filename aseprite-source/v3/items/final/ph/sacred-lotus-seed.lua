-- sacred-lotus-seed (final D step, Sonnet high). A torn scrap of lotus pad (round, wavy edge, peltate hub, forked
-- radial veins, a radial slit, the lower rim curled up to show the pale silvery underside, AO + contact shadow
-- under every nut) carries three slim hard dark-brown lotus nuts (glossy shell, pale tan nipple tip). The right nut has
-- germinated: its shell has split at the tip, and a thin petiole carries a tiny round floating leaf (radial veins,
-- scalloped edge) while a rolled spear leaf unrolls beside it.
-- quirk: a bead of water sits on the pad like a pearl (lotus effect), a bright rim, a spec and its own shadow.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2("sacred-lotus-seed")
local atan2 = function(y, x) return atan(y, x) end

local PAD  = { "#12363a", "#1d5a52", "#2b7a62", "#40996c", "#62b87c", "#92d49a" }
local UND  = { "#3c6e74", "#5d9a9a", "#8cc0b4", "#bde0cc" }
local VEIN = "#b4e6a8"
local NUT  = { "#1c100e", "#38211a", "#5a3826", "#7c5232", "#a07446", "#c9a070" }
local TIP  = { "#8a6a44", "#c4a470", "#e6cf9c", "#f8eac0" }
local STALK = { "#35704f", "#58996a", "#86c284", "#b6e4a0" }
local SPEAR = { "#255a44", "#3f8656", "#64b068", "#92d27e", "#c2eca0", "#e4f8c0" }
local WAT = { "#23467a", "#3a7ea8", "#6cc0cc", "#a8ecdc", "#e0fbf0" }
local tok = function(n) return { r = { name = n } } end

-- generic lotus pad: wavy ellipse, optional slit angle; returns mask, normals, info
local function padMask(cx, cy, rx, ry, wav, slit)
  local m = HP.mask()
  for y = floor(cy - ry - 3), floor(cy + ry + 3) do for x = floor(cx - rx - 3), floor(cx + rx + 3) do
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local th = atan2(ny, nx)
    local f = 1 + wav * sin(6 * th + 0.7) + wav * 0.6 * sin(11 * th + 2.1)
    if nx * nx + ny * ny <= f * f then
      local ok = true
      if slit then
        local d = abs(((th - slit + pi) % (2 * pi)) - pi)
        local r = sqrt(nx * nx + ny * ny)
        if r > 0.12 and d < 0.05 + 0.1 * r then ok = false end
      end
      if ok then m:set(x, y) end
    end
  end end
  return m
end
local function veins(m, cx, cy, rx, ry, n, rot, ptok, avoid)
  for i = 0, n - 1 do
    for _, br in ipairs{ { 0, 0.07 }, { -0.1, 0.62 }, { 0.1, 0.62 } } do
      local a = rot + i * 2 * pi / n + br[1] * (14 / n)
      for r = br[2], 0.97, 0.02 do
        local x, y = floor(cx + cos(a) * r * rx + 0.5), floor(cy + sin(a) * r * ry + 0.5)
        if m:has(x, y) and not (avoid and avoid:has(x, y)) then
          local lit = (cos(a) * -0.6 + sin(a) * -0.7) < 0.1
          c:put(x, y, lit and VEIN or PAD[5], ptok)
          local x2, y2 = x + (cos(a) > 0 and 0 or 1), y + (sin(a) > 0 and 1 or 0)
          if m:has(x2, y2) and not (avoid and avoid:has(x2, y2)) then c:put(x2, y2, PAD[2], ptok) end
        end
      end
    end
  end
end

-- ---------- nuts (masks first, for AO) ----------
-- cx, cy, long radius, short radius, angle of the long axis (tip at +u)
local nuts = {
  { 14.5, 47.5, 4.6, 3.0, -0.55 },
  { 25, 52, 4.6, 3.0, -1.0 },
  { 38.5, 46.5, 5.2, 3.1, -1.42 },     -- germinating, tip up
}
local allN = HP.mask()
for _, s in ipairs(nuts) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9) allN:add(s.m) end

-- ---------- pad ----------
local PCX, PCY, PRX, PRY = 29, 46, 24, 10.5
local pad = padMask(PCX, PCY, PRX, PRY, 0.035, -2.6)
local pn, pd = X.pillow(pad, 5)
local bias = {}
X.ao(bias, pad, allN, 1, -1) G.cast(bias, pad, allN, 1, 2, -1) G.cast(bias, pad, allN, 2, 3, -1)
-- gentle ripple: faint dark/light bands radiating
pad:each(function(x, y) local k = K(x, y)
  local th = atan2((y - PCY) / PRY, (x - PCX) / PRX)
  if sin(5 * th + 1) > 0.88 and pd[k] > 2 then bias[k] = (bias[k] or 0) - 1 end
end)
local ptok = tok("pad")
G.toneN(c, pad, pn, PAD, { bias = bias, tok = ptok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
veins(pad, PCX, PCY, PRX, PRY, 14, 0.2, ptok, allN:copy():add(allN:grow(1)))
-- curled lower rim: pale underside band along the front edge
pad:each(function(x, y) local k = K(x, y)
  local ny = (y - PCY) / PRY
  if pd[k] < 1.9 and ny > 0.38 then
    local i = pd[k] < 0.9 and 1 or 2
    if (x - PCX) > 6 then i = i - 1 end
    c:put(x, y, UND[max(1, min(4, i + (ny > 0.9 and 0 or 1)))], tok("under"))
  end
end)
-- hub (peltate boss)
do
  local hm = c:ellipse(PCX, PCY, 2.2, 1.6)
  local hn = X.sphere(PCX - 0.3, PCY - 0.4, 2.2, hm)
  X.tone(c, hm, X.light(hn, { amb = 0.1, wrap = 0.3 }), PAD, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, tok = tok("hub") })
  c:px(PCX - 1, PCY - 1, PAD[6])
end

-- ---------- sprout: spear leaf (behind), petiole + floating leaf ----------
-- rolled spear leaf unrolling
do
  local sm, sn, ST, SS = G.tube({ { 37, 42 }, { 34, 34 }, { 31, 28 }, { 30, 20 } }, function(t) return 0.9 + 1.0 * sin(pi * min(1, t * 1.05)) ^ 0.8 end)
  local idx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.35 }), SPEAR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = tok("spear") })
  sm:each(function(x, y) local k = K(x, y)
    local ph = (ST[k] * 9 + SS[k] * 0.9) % 1
    if ph < 0.3 and ST[k] > 0.18 then c:put(x, y, SPEAR[max(1, (idx[k] or 3) - 2)], tok("spear")) end
  end)
  c:px(30, 19, SPEAR[6])
end
-- petiole with tiny prickles
local pm, pnn, PT, PS = G.tube({ { 41, 41 }, { 40, 33 }, { 43, 25 }, { 45, 19 } }, function(t) return 0.95 end)
X.tone(c, pm, X.light(pnn, { amb = 0.2, wrap = 0.35 }), STALK, { cuts = { 0.3, 0.55, 0.8 }, tok = tok("petiole") })
for _, p in ipairs{ { 41, 37 }, { 41, 31 }, { 43, 27 } } do c:px(p[1] + 1, p[2], STALK[1]) end
-- small floating leaf
do
  local lcx, lcy, lrx, lry = 45, 16.5, 8, 3.7
  local lm = padMask(lcx, lcy, lrx, lry, 0.06, nil)
  local ln = X.pillow(lm, 2.6)
  local ltok = tok("fleaf")
  G.toneN(c, lm, ln, PAD, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, amb = 0.18, wrap = 0.3 })
  veins(lm, lcx, lcy, lrx, lry, 8, 0.4, ltok, nil)
  -- lower rim shows the pale underside
  local dd = X.dist(lm)
  lm:each(function(x, y) if dd[K(x, y)] < 1.0 and (y - lcy) / lry > 0.5 then c:put(x, y, UND[2], tok("under")) end end)
  c:px(floor(lcx), floor(lcy), PAD[6])
  -- contact shadow of the leaf on the stalk
  for _, p in ipairs{ { 44, 21 }, { 45, 21 }, { 46, 21 } } do if not lm:has(p[1], p[2]) then c:px(p[1], p[2], STALK[1]) end end
end

-- ---------- nuts ----------
for i, s in ipairs(nuts) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #nuts do vis:cut(nuts[j].m) X.ao(sb, s.m, nuts[j].m, 1, -1) end
  local tk = tok("nut" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local spec = X.spec(s.n, 45)
  local bx, by, bv
  vis:each(function(x, y) local k = K(x, y) if spec[k] and (not bv or spec[k] > bv) then bv, bx, by = spec[k], x, y end end)
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local idxs = X.tone(c, vis, X.light(s.n, { amb = 0.05, wrap = 0.15 }), NUT, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = sb, tok = tk })
  -- pale nipple cap at the tip end + faint longitudinal grain lines
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    if u > 0.74 and abs(v) < 0.7 then
      local k = K(x, y)
      c:put(x, y, TIP[max(1, min(4, (v < -0.1 and 3 or 2) + (u > 0.9 and -1 or 0)))], tk)
    elseif abs(v - 0.42) < 0.09 and abs(u) < 0.6 and idxs[K(x, y)] and idxs[K(x, y)] > 1 then
      c:put(x, y, NUT[max(1, idxs[K(x, y)] - 1)], tk)
    end
  end)
  -- glossy spec: 2x1 + glint
  if bx and i ~= 3 then c:px(bx, by, "#fff0d8") c:px(bx + 1, by, "#f8d8b0") c:px(bx - 1, by + 1, NUT[6]) end
  if i == 3 then
    -- split shell at the tip: dark crack with the pale-green plumule inside
    local tx, ty = s[1] + ca * s[3] * 0.62, s[2] + sa * s[3] * 0.62
    local nxp, nyp = -sa, ca
    for q = -2, 2 do
      local px, py = floor(tx + nxp * q * 0.9 + 0.5), floor(ty + nyp * q * 0.9 + 0.5)
      if vis:has(px, py) then c:put(px, py, abs(q) == 2 and NUT[1] or STALK[3], tk) end
    end
    c:px(floor(tx + 0.5), floor(ty + 0.5) - 1, SPEAR[5])
    c:px(floor(s[1] + 0.5) - 1, floor(s[2] + 0.5) - 3, NUT[6]) c:px(floor(s[1] + 0.5) - 1, floor(s[2] + 0.5) - 2, "#fff0d8")
  end
end

-- ---------- water bead (quirk) ----------
do
  local bx, by = 47.5, 45.5
  local bm = c:ellipse(bx, by, 2.5, 2.5)
  -- cast shadow lower-right (on the pad)
  for _, p in ipairs{ { 50, 47 }, { 51, 46 }, { 50, 48 }, { 49, 48 }, { 51, 47 } } do if pad:has(p[1], p[2]) and not bm:has(p[1], p[2]) then c:px(p[1], p[2], PAD[1]) end end
  local bn = X.sphere(bx - 0.4, by - 0.4, 2.5, bm)
  X.tone(c, bm, X.light(bn, { amb = 0.18, wrap = 0.45 }), WAT, { cuts = { 0.25, 0.5, 0.72, 0.9 }, tok = tok("bead") })
  c:px(floor(bx - 1.5), floor(by - 1.5), "#fff4d6") c:px(floor(bx - 0.5), floor(by - 1.5), "#fff4d6")
  c:px(floor(bx + 1.2), floor(by + 1.2), WAT[5])        -- caustic glow lower right
end

G.save2(c, "sacred-lotus-seed")
