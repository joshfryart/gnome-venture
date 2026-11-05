-- grilled-sardines (lean P1b_O2)
local NAME = "grilled-sardines"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local drawn = HP.mask()
-- lit(mask, normals, ramp, opts): tone with normals; opts.seam = colour for the border where it overlaps earlier art
local function lit(m, n, ramp, o)
  o = o or {}
  local prior = drawn:copy()
  local _, v = G.toneN(c, m, n, ramp, o)
  if o.seam then m:edge():each(function(x, y) if prior:has(x, y) then c:px(x, y, o.seam) end end) end
  drawn:add(m)
  return v
end
local function pil(m, ramp, R, o) return lit(m, X.pillow(m, R), ramp, o) end
local function hx(x, y, s) return X.hash(x, y, s or 1) end
-- two grilled sardines on a blue platter with a lemon wedge and steam; quirk: one fish winks (eye is a closed slit) and the steam curls
local BL = { "#1c3752", "#2a587a", "#3f80a0", "#62a6bc", "#92cad4", "#c8eaec" }
local CR = { "#8a7a6a", "#b8a890", "#dccdb0", "#efe4cc", "#faf3e0", "#fffaf0" }
local SL = { "#26334e", "#40608a", "#7a9cc0", "#aac4dc", "#d8e8f2", "#f6fcff" }
local LM = { "#8a6410", "#c49a14", "#e8c42a", "#f6e04c", "#fff08a", "#fffbc0" }
c:groundShadow(32, 56, 27, 3)
local plate = c:ellipse(32, 39, 26, 16)
pil(plate, BL, 4, {})
local inner = c:ellipse(32, 39, 21, 12)
inner:each(function(x, y) c:put(x, y, CR[4]) end)
inner:edge():each(function(x, y) c:px(x, y, (x + y * 2 < 78) and CR[2] or CR[6]) end)
local function fish(cx, cy, wink, seam)
  local body, n = G.oval(cx, cy, 13.5, 5, 0, 1)
  local tail = c:poly{ {cx + 11, cy}, {cx + 19, cy - 6}, {cx + 20, cy - 5}, {cx + 17, cy}, {cx + 20, cy + 5}, {cx + 19, cy + 6} }
  local tn = {}
  tail:each(function(x, y) tn[K(x, y)] = { -0.2, -0.3, 0.9 } end)
  lit(tail, tn, SL, { seam = seam })
  tail:each(function(x, y) if (y - cy + (x - cx) * 0.3) % 3 < 1 then c:px(x, y, SL[2]) end end)
  lit(body, n, SL, { seam = seam, amb = 0.12 })
  body:each(function(x, y)
    if y <= cy - 3 then c:px(x, y, y <= cy - 4 and "#1f4a66" or "#2e6a86") end
    local d = (x - cx) + (y - cy) * 1.1
    if x > cx - 7 and x < cx + 10 and abs(y - cy) <= 4 and (d % 5) < 1.3 then c:px(x, y, "#2e1a1c") end
  end)
  body:each(function(x, y)
    local d = (x - cx) + (y - cy) * 1.1
    if x > cx - 7 and x < cx + 10 and abs(y - cy) <= 3 and (d % 5) >= 1.3 and (d % 5) < 2.1 and hx(x, y, 8) > 0.55 then c:px(x, y, "#e0782c") end
  end)
  for dy = -3, 3 do c:px(cx - 8, cy + dy, SL[3]) end   -- gill
  if wink then c:px(cx - 11, cy - 1, "#14182a") c:px(cx - 10, cy - 1, "#14182a")
  else c:px(cx - 11, cy - 1, "#14182a") c:px(cx - 10, cy - 1, SL[6]) c:px(cx - 11, cy, SL[6]) c:px(cx - 10, cy, "#14182a") end
  c:px(cx - 4, cy - 2, SL[6]) c:px(cx - 3, cy - 2, SL[6])
end
fish(26, 33, false, nil)
fish(30, 45, true, SL[1])
-- lemon wedge
local half = c:ellipse(49, 34, 7, 7)
local wedge = HP.mask()
half:each(function(x, y) if x >= 50 then wedge:set(x, y) end end)
wedge:each(function(x, y) c:put(x, y, LM[2]) end)
local pith = wedge:copy():shrink(1)
pith:each(function(x, y) c:put(x, y, LM[6]) end)
local flesh = pith:copy():shrink(1)
flesh:each(function(x, y) c:put(x, y, (x - 50) + (y - 34) * 0 < 3 and LM[4] or LM[3]) end)
for _, a in ipairs{ -1.1, -0.55, 0, 0.55, 1.1 } do
  for r = 1, 4 do local px, py = floor(50 + cos(a) * r + 0.5), floor(34 + sin(a) * r + 0.5) if flesh:has(px, py) then c:px(px, py, LM[6]) end end
end
c:px(53, 30, "#fff8f0") c:px(52, 31, LM[5])
-- steam
for _, s in ipairs{ { {24, 22}, {26, 18}, {23, 14}, {26, 10}, {24, 6} }, { {35, 21}, {37, 17}, {34, 13}, {37, 9} } } do
  c:fillMask(c:line(s, 2), "#d6d0ea")
  c:fillMask(c:line(s, 1), "#f2effa")
end
G.save(c, NAME)
