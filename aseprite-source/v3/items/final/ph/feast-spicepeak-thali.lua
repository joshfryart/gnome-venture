-- feast-spicepeak-thali (lean E2_00)
local NAME = "feast-spicepeak-thali"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, tok, amb, wrap)
  local n = X.pillow(m, R)
  return X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n
end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function mix(a, b, t) local r1,g1,b1 = hx(a) local r2,g2,b2 = hx(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5)) end
local function ramp6(base) return { mix(base,"#1c1020",.62), mix(base,"#2a1428",.36), mix(base,"#2a1428",.14), base, mix(base,"#fff2b0",.3), mix(base,"#fff8e0",.6) } end
c:groundShadow(32, 56, 26, 4)
local STEEL = { "#3c4458", "#5a647c", "#7e8aa4", "#a4b0c8", "#cdd6e6", "#eef2fa" }
local plate = c:ellipse(32, 31, 25, 25)
local pt = { r = { name = "plate" } }
shade(plate, STEEL, 9, pt, 0.2, 0.3)
local well = c:ellipse(32, 31, 21, 21)
well:each(function(x, y) c:put(x, y, (x + y < 60) and STEEL[3] or STEEL[2], pt) end)
well:edge():each(function(x, y) c:put(x, y, STEEL[1], pt) end)
for a = 0, 2 * pi, 0.2 do c:put(floor(32 + 23 * cos(a) + .5), floor(31 + 23 * sin(a) + .5), STEEL[6], pt) end
local cols = { "#c62e22", "#e8b020", "#5aa832", "#e07a24", "#8a2e5a" }
for i = 1, 5 do
  local a = -2.35 + (i - 1) * (2 * pi / 5)
  local cx, cy = floor(32 + 14.5 * cos(a) + .5), floor(31 + 14.5 * sin(a) + .5)
  c:ellipse(cx + 1, cy + 2, 7, 6):each(function(x, y) if well:has(x, y) then c:put(x, y, STEEL[1], pt) end end)
  local ring = c:ellipse(cx, cy, 6, 6)
  shade(ring, STEEL, 5, pt, 0.2, 0.3)
  local fill = c:ellipse(cx, cy, 4, 4)
  local ft = { r = { name = "curry" .. i } }
  X.tone(c, fill, X.light(X.pillow(fill, 4), { amb = 0.15, wrap = 0.3 }), ramp6(cols[i]), { cuts = CUTS, tok = ft })
  c:put(cx - 2, cy - 2, "#fff8e8", ft)
  if i == 3 then c:put(cx + 1, cy + 1, "#2b6a2c", ft) end
  if i == 1 then c:put(cx + 1, cy, "#f8d0a0", ft) c:put(cx, cy + 1, "#f8d0a0", ft) end
end
-- rice peak in the centre
local RICE = { "#a89a88", "#cfc2ae", "#e8dcc6", "#f6eede", "#fffaf0", "#fffcf0" }
local peak = c:ellipse(32, 31, 7, 7)
local rt = { r = { name = "rice" } }
shade(peak, RICE, 7, rt, 0.1, 0.3)
peak:each(function(x, y) if X.hash(x, y, 2) > 0.8 then c:put(x, y, RICE[2], rt) end end)
for _, p in ipairs{ {30,29},{34,33},{29,33},{35,29} } do c:put(p[1], p[2], "#f0a830", rt) end
-- chili on top of the peak
local chm, chn = G.tube({ {29,31}, {31,26}, {33,25}, {37,27} }, function(t) return 1.8 - 1.0 * t end)
local ct = { r = { name = "chili" } }
X.tone(c, chm, X.light(chn, { amb = 0.1, wrap = 0.25 }), { "#4a1218", "#7a1c24", "#aa2c30", "#d04838", "#ec7048", "#f8a060" }, { cuts = CUTS, tok = ct })
c:put(28, 31, "#3f7a2c", ct) c:put(28, 30, "#6aa83a", ct)
-- quirk: a chili has escaped the plate
local em, en = G.tube({ {50,53}, {55,57}, {58,53}, {60,49} }, function(t) return 1.7 - 0.9 * t end)
local et = { r = { name = "chili2" } }
X.tone(c, em, X.light(en, { amb = 0.1, wrap = 0.25 }), { "#4a1218", "#7a1c24", "#aa2c30", "#d04838", "#ec7048", "#f8a060" }, { cuts = CUTS, tok = et })
c:put(50, 53, "#3f7a2c", et) c:put(49, 54, "#6aa83a", et)
G.save(c, NAME)
