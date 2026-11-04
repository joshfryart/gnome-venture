-- rhubarb-jam (final, agent aD12_3). Slim straight glass jar of glossy pink-red rhubarb jam (vertical-cylinder glass,
-- cool reflected edge, pale reflection streak, fruit chunks + bubbles, meniscus) with a red gingham cloth cover gathered
-- under twisted twine (knot + tails), pleated scalloped skirt that shades the glass, and a cream paper label with a
-- little rhubarb drawing. quirk: a sticky jam thumbprint on the cloth skirt.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("rhubarb-jam")
local GL  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fe0e8", "#c6f2f4", "#f0fcff" }
local JAM = { "#5a1330", "#8c2146", "#c23459", "#e8506f", "#f7809a", "#ffb8c6" }
local CRM = { "#8a6a58", "#b58d70", "#dcb590", "#f2d4a8", "#fbe7c4", "#fff4d6" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local GOLD = { "#6a4a22", "#a07a34", "#cfa04a", "#ecc86a", "#f8e49a", "#fff4d6" }
c:groundShadow(32, 57, 17, 3)

-- glass body: shoulders + short neck
local glass = c:rrect(18, 26, 45, 56, 5):add(c:rect(23, 18, 40, 30))
A.vcyl(c, glass, GL, 19, 44, { amb = 0.15, wrap = 0.35 })
local inner = glass:copy():shrink(2)
local jam = inner:copy():clip(c:rect(0, 32, 63, 63))
local head = inner:copy():cut(jam)
head:each(function(x, y) c:px(x, y, x > 39 and GL[3] or (x > 35 and GL[4] or GL[5])) end)
A.vcyl(c, jam, JAM, 20, 43, { amb = 0.12, wrap = 0.3 })
for x = 21, 42 do if jam:has(x, 32) then c:px(x, 32, x < 36 and JAM[6] or JAM[5]) end if jam:has(x, 33) and x > 38 then c:px(x, 33, JAM[2]) end end
-- fruit chunks (pale rhubarb bits) + bubbles
for _, q in ipairs{ {26,35},{33,36},{21,43},{22,51},{41,41},{40,47},{35,53},{27,53},{30,34} } do
  if jam:has(q[1], q[2]) and jam:has(q[1] + 2, q[2]) then
    c:px(q[1], q[2], JAM[5]) c:px(q[1] + 1, q[2], JAM[5]) c:px(q[1] + 2, q[2], JAM[4])
    c:px(q[1] + 1, q[2] + 1, JAM[2]) c:px(q[1] + 2, q[2] + 1, JAM[2])
  end
end
for _, q in ipairs{ {23,40},{22,47},{40,37},{39,52} } do c:px(q[1], q[2], JAM[6]) c:px(q[1] + 1, q[2] + 1, JAM[5]) end
-- glass reflection streaks and thick base
for y = 34, 49 do if jam:has(21, y) then c:px(21, y, y < 46 and JAM[6] or JAM[5]) end end
for y = 36, 44 do c:px(22, y, JAM[5]) end
for y = 31, 50 do c:px(19, y, GL[6]) end
for x = 22, 38 do c:px(x, 55, GL[5]) end
for x = 22, 41 do c:px(x, 56, GL[2]) end
for y = 33, 52 do c:px(44, y, "#3a86b0") end

-- paper label with rhubarb drawing
local lab = c:rrect(24, 37, 39, 52, 1)
A.lit(c, lab, CRM, 1.6, { amb = 0.1 })
lab:copy():cut(lab:copy():shrink(1)):each(function(x, y) c:px(x, y, (x > 36 or y > 49) and CRM[1] or CRM[2]) end)
A.line(c, 31, 44, 30, 49, "#d04060") A.line(c, 32, 44, 31, 49, "#ec6280") A.line(c, 33, 44, 34, 48, "#a02a4a") A.line(c, 34, 44, 35, 48, "#d04060")
c:px(30, 50, "#a02a4a")
local lf = c:ellipse(32, 41, 4, 2.2)
A.lit(c, lf, LEAF, 1.5)
for x = 29, 35 do c:px(x, 41, LEAF[6]) end c:px(31, 40, LEAF[5]) c:px(33, 42, LEAF[2])
for x = 27, 36, 2 do c:px(x, 51, CRM[1]) end

-- cloth cover: cap, gathered waist, pleated scalloped skirt
local HW = {[10]=6,[11]=9,[12]=11,[13]=12,[14]=12,[15]=12,[16]=12,[17]=12,[18]=11,[19]=10,[20]=9,[21]=8,[22]=8,[23]=9,[24]=11,[25]=13,[26]=14,[27]=15,[28]=15}
local lift = { 0, 1, 2, 2, 1, 0 }
local cloth = HP.mask()
for y = 10, 28 do local h = HW[y]
  for x = floor(32 - h), floor(32 + h) - 1 do
    if y < 26 or y <= 28 - lift[((x - 17) % 6) + 1] then cloth:set(x, y) end
  end
end
-- cast shadow of the skirt onto glass / jam
cloth:shift(1, 2):each(function(x, y) if glass:has(x, y) and not cloth:has(x, y) then c:px(x, y, y < 32 and "#6aa8b8" or JAM[1]) end end)
local n = X.pillow(cloth, 5)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local W  = { "#6a4a64", "#9a7a92", "#cdb2c0", "#efdce0", "#fff0ee", "#fffaf6" }
local M  = { "#5a2a52", "#8a4468", "#c0708a", "#e49aae", "#f6bccb", "#ffd8e0" }
local DK = { "#4a1030", "#7a1c46", "#b02c5a", "#d84870", "#ee6c8c", "#ff9ab0" }
local cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local tok = { r = { name = "cloth" } }
cloth:each(function(x, y)
  local k = K(x, y)
  local i = 1
  for j, t in ipairs(cuts) do if v[k] >= t then i = j + 1 end end
  if y >= 24 and y <= 28 then local f = ((x - 17) % 6) if f == 2 or f == 3 then i = i - 1 end end
  i = max(1, min(6, i))
  local kind = (floor(x / 3) % 2 == 0 and 1 or 0) + (floor(y / 3) % 2 == 0 and 1 or 0)
  local r = kind == 2 and DK or (kind == 1 and M or W)
  c:put(x, y, r[i], tok)
end)
-- crease lines at the waist
for x = 25, 38 do if cloth:has(x, 20) and x % 3 == 0 then c:px(x, 20, M[2]) end end
-- twisted twine + knot + tails
for x = 24, 39 do for y = 21, 22 do
  local t = (x + y) % 3
  c:px(x, y, t == 0 and GOLD[2] or (t == 1 and GOLD[4] or GOLD[3]))
end end
for x = 24, 39 do c:px(x, 23, GOLD[1]) end
local knot = c:ellipse(38.5, 21.5, 2, 2)
A.lit(c, knot, GOLD, 1.5) c:px(38, 21, GOLD[6])
A.line(c, 39, 23, 41, 29, GOLD[2]) A.line(c, 40, 23, 43, 28, GOLD[3])
c:px(41, 30, GOLD[1]) c:px(44, 29, GOLD[1]) c:px(42, 30, GOLD[2])
-- quirk: sticky thumbprint on the skirt
local tp = c:ellipse(22.5, 25.5, 2, 2.6)
tp:each(function(x, y) c:px(x, y, "#a82e46") end)
for _, q in ipairs{ {21,24},{22,23},{23,24},{21,26},{22,27},{23,26},{22,25},{23,25} } do if tp:has(q[1], q[2]) then c:px(q[1], q[2], JAM[4]) end end
c:px(22, 24, "#6e1f3a")
A.save(c, "rhubarb-jam")
