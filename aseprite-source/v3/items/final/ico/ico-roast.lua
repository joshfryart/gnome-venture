-- ico-roast (Opus artist pass). Roast drumstick on the diagonal: a plump glossy meat bulb upper-right tapering into a
-- slim bone shaft with a double-knuckle end lower-left. Material: 6-tone caramel crust lit per pixel, crackled crisp
-- blisters, glossy fat specular streak + glint, cool reflected light lower-right, a dark seared collar where the meat
-- wraps the bone (AO on the bone), bone with a pale polished ridge and a shadowed knuckle groove.
-- quirk: someone has already taken a bite (pink juicy meat showing in the bite).
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_0.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = D.new("ico-roast")
local tokBn = { r = { name = "bone" } }
local tokM = { r = { name = "meat" } }
local MEAT = { "#7a2e3e", "#b2475a", "#de7a80", "#f6a8a0" }
local BOUNCE = "#9a4a5e"

-- bone shaft + knuckles (painted first; meat overlaps the top)
local shaft, sn, ST, SS = X.cyl(28, 36, 14, 50, function() return 2.2 end)
local k1, n1 = G.oval(10.5, 48, 3.3, 3.3, 0)
local k2, n2 = G.oval(16, 53.5, 3.3, 3.3, 0)
local bone = shaft:copy():add(k1):add(k2)
local bn = {}
for k, v in pairs(sn) do bn[k] = v end
for k, v in pairs(n1) do bn[k] = v end
for k, v in pairs(n2) do bn[k] = v end
local meat, mn = G.oval(38, 25, 15, 12.5, -0.72)
local neck = X.cyl(37, 27, 25, 39, function(t) return 7 - t * 4.2 end)
local mm = meat:copy():add(neck)
local bias = {}
X.ao(bias, bone, mm, 2, -1)
-- groove between the two knuckles
bone:each(function(x, y) local d = (x - 10.5) - (y - 48) if k1:has(x, y) and k2:has(x, y) then bias[K(x, y)] = (bias[K(x, y)] or 0) - 2 end end)
D.tone(c, bone, bn, D.BONE, { bias = bias, tok = tokBn, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- polished ridge along the lit side of the shaft
shaft:each(function(x, y) local k = K(x, y) if SS[k] and SS[k] < -0.35 and SS[k] > -0.75 and ST[k] > 0.25 and ST[k] < 0.85 then c:put(x, y, D.BONE[6], tokBn) end end)
c:put(9, 46, D.CREAM, tokBn) c:put(10, 46, D.BONE[6], tokBn)

-- meat bulb: normals from oval for the bulb, pillow on the neck
local nn = X.pillow(mm, 5)
local mnorm = {}
mm:each(function(x, y) local k = K(x, y) mnorm[k] = mn[k] or nn[k] end)
local bite = c:ellipse(49, 13.5, 5, 4.5)
mm:cut(bite)
local v = X.light(mnorm, { amb = 0.06, wrap = 0.22 })
local mb = {}
-- seared collar: dark band where the meat ends on the bone
mm:each(function(x, y) local k = K(x, y)
  local t = ((x - 37) * -12 + (y - 27) * 12) / (12 * 12 + 12 * 12)
  if t > 0.86 then mb[k] = -2 elseif t > 0.74 then mb[k] = -1 end
end)
local idx = X.tone(c, mm, v, D.CRUST, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, bias = mb, tok = tokM })
-- crisp blisters: small lit bumps with a dark underside (hash scattered over the lit half)
mm:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i and i >= 3 and i <= 5 and X.hash(x, y, 7) < 0.07 and mm:has(x + 1, y + 1) and mm:has(x, y + 1) then
    c:put(x, y, D.CRUST[min(6, i + 1)], tokM)
    c:put(x + 1, y + 1, D.CRUST[max(1, i - 1)], tokM)
  end
end)
-- crackle lines on the crust
for _, p in ipairs{ {30, 22}, {31, 22}, {32, 23}, {41, 33}, {42, 33}, {43, 32}, {36, 16}, {37, 16} } do D.shift(c, p[1], p[2], D.CRUST, -2) end
-- cool reflected light lower-right rim
local rim = X.rim(mnorm)
mm:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.8 and (idx[k] or 3) <= 3 and (mb[k] or 0) == 0 then c:put(x, y, BOUNCE, tokM) end end)
-- glossy fat streak + glint upper-left
for _, p in ipairs{ {28, 18}, {29, 17}, {30, 16}, {31, 15}, {32, 15} } do c:put(p[1], p[2], D.CRUST[6], tokM) end
c:put(29, 18, D.CREAM, tokM) c:put(30, 17, D.CREAM, tokM)

-- quirk: bite. exposed meat rim (pink juicy flesh) inside the cut edge
local rimM = bite:grow(1):clip(mm)
rimM:each(function(x, y)
  local dx, dy = x - 49, y - 13.5
  local tone = (dx + dy < 0) and MEAT[2] or MEAT[3]
  if dx + dy > 3 then tone = MEAT[4] end
  c:put(x, y, tone, tokM)
end)
rimM:grow(1):clip(mm):cut(rimM):cut(c:rect(0,0,63,63):cut(bite:grow(3))):each(function(x, y) c:put(x, y, MEAT[1], tokM) end)
-- tooth notches


D.save(c, "ico-roast")
