-- rainbow-fish (Opus single pass, final). A slim, gently S-bent trout-like fish: a spine bezier swept into a tapered
-- body whose colour runs in eight rainbow bands across the flank (indigo back -> blue -> teal -> green -> yellow ->
-- orange -> pink -> lilac belly), each band its own 6-tone ramp lit per pixel, wavy band edges, offset scale scallops,
-- a glossy back streak, gill plate arc, round eye, nostril + lip, ray-lined forked tail, dorsal, anal, pelvic and
-- pectoral fins with lit rays.
-- quirk: three bubbles rise from its mouth, the biggest one holding a tiny rainbow.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_3.lua")
local G, X, HP, K = A.G, A.X, A.HP, A.K
local floor, max, min, abs, sqrt, sin, cos, pi, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi, math.atan
local c = G.new2("rainbow-fish")
local R = A.ramp
local BANDS = { R("#4a46b8"), R("#3f86e0"), R("#34c4b0"), R("#78d058"), R("#f4d846"), R("#f6963c"), R("#ec5a78"), R("#c8b8ec") }
local P = { { 12, 36 }, { 24, 41 }, { 36, 29 }, { 47, 34 } }
local function W(t)
  if t < 0.3 then local u = t / 0.3 return 0.7 + 5.2 * (1 - (1 - u) ^ 2) end
  local u = (t - 0.3) / 0.7
  return 1.7 + 4.4 * (1 - u) ^ 1.2
end
local body, bn, T, S, sm = G.tube(P, W, 220)
-- point on the body edge at t, s (s<0 back/lit, s>0 belly), outwards by `out`
local function edgePt(t, s, out)
  local i = max(1, min(#sm, floor(t * (#sm - 1) + 1.5)))
  local q = sm[i]
  local w = W(t) + (out or 0)
  return q.x + q.px * s * w, q.y + q.py * s * w
end
local function polyMask(pts) return c:poly(pts) end
-- ray-lined fin painter: origin (ox,oy), nrays across angle, ramp, lit direction
local function paintFin(m, ox, oy, rp, nr, o)
  o = o or {}
  local tok = { r = { name = o.name or "fin" } }
  local n = X.pillow(m, 2.2)
  local v = X.light(n, { amb = .22, wrap = .4 })
  local ix = X.tone(c, m, v, rp, { cuts = { .3, .45, .6, .75, .9 }, tok = tok })
  m:each(function(x, y)
    local k = K(x, y)
    local a = atan(y - oy, x - ox)
    local r = sqrt((x - ox) ^ 2 + (y - oy) ^ 2)
    local f = (a * nr / (o.span or 1.0)) % 1
    local i = ix[k] or 3
    if f < 0.32 and r > 2 then i = i - 1 elseif f > 0.72 then i = i + 1 end
    c:put(x, y, rp[max(1, min(6, i))], tok)
  end)
end
-- tail (behind body)
do
  local bx, by = edgePt(1, 0)
  local tail = polyMask{ { bx - 2, by - 2 }, { bx + 3, by - 6 }, { bx + 10, by - 11 }, { bx + 9, by - 5 }, { bx + 6, by }, { bx + 9, by + 6 }, { bx + 10, by + 12 }, { bx + 3, by + 7 }, { bx - 2, by + 2 } }
  paintFin(tail, bx - 2, by, R("#e0508a"), 9, { name = "tail", span = 1.2 })
  -- violet lower lobe
  tail:each(function(x, y) if y > by + 2 then
      local ix = c.pix and 0
    end end)
  local lower = HP.mask() tail:each(function(x, y) if y > by + 1 then lower:set(x, y) end end)
  paintFin(lower, bx - 2, by, R("#7a56d0"), 9, { name = "tail2", span = 1.2 })
  -- gold sheen on the upper lobe tip
  c:px(bx + 9, by - 10, "#ffe6a0") c:px(bx + 8, by - 9, "#ffe6a0") c:px(bx + 7, by - 8, "#fcc27c")
end
-- dorsal (sail on the back)
do
  local x0, y0 = edgePt(.36, -1, -1) local x1, y1 = edgePt(.6, -1, -1)
  local ax, ay = edgePt(.42, -1, 7)
  local d = polyMask{ { x0, y0 }, { ax, ay }, { ax + 5, ay + 1 }, { x1, y1 } }
  paintFin(d, (x0 + x1) / 2, (y0 + y1) / 2 + 3, R("#4a6ad8"), 8, { name = "dorsal", span = 1.4 })
end
-- adipose nub
do local x0, y0 = edgePt(.76, -1, -1) local ax, ay = edgePt(.78, -1, 3)
  c:fillMask(polyMask{ { x0 - 1, y0 }, { ax, ay }, { x0 + 2, y0 } }, "#3f64c8") end
-- anal fin + pelvic fin (belly)
do
  local x0, y0 = edgePt(.62, 1, -1) local x1, y1 = edgePt(.78, 1, -1)
  local ax, ay = edgePt(.7, 1, 6)
  paintFin(polyMask{ { x0, y0 }, { ax - 1, ay }, { x1, y1 } }, (x0 + x1) / 2, y0 - 2, R("#f08a50"), 6, { name = "anal" })
  local p0x, p0y = edgePt(.42, 1, -1) local pax, pay = edgePt(.46, 1, 5)
  paintFin(polyMask{ { p0x, p0y }, { pax - 1, pay }, { p0x + 4, p0y } }, p0x + 1, p0y - 2, R("#f4a45a"), 5, { name = "pelvic" })
end
-- body: banded + lit
do
  local v = X.light(bn, { amb = .1, wrap = .3 })
  local tok = {}
  local rr = X.rim(bn)
  local ix = {}
  body:each(function(x, y)
    local k = K(x, y)
    local s, t = S[k], T[k]
    local sw = s + .07 * sin(t * 17) + .03 * sin(t * 41)
    local b = max(1, min(8, floor((sw + 1) * 4) + 1))
    local val = v[k]
    local i = 1 for j, th in ipairs{ .2, .36, .52, .68, .84 } do if val >= th then i = j + 1 end end
    if rr[k] > .8 then i = min(6, i + 1) end
    -- head is silvery on the cheek: tone up bands near the gill cover
    c:put(x, y, BANDS[b][i], { r = { name = "band" .. b } })
    ix[k] = { b, i }
  end)
  -- scale scallops (behind the gill cover)
  body:each(function(x, y)
    local k = K(x, y)
    local t = T[k]
    if t > .3 and t < .98 and abs(S[k]) < .86 then
      local row = floor((y + 1) / 3)
      local col = (x + (row % 2) * 2) % 4
      local j = (y + 1) % 3
      local b, i = ix[k][1], ix[k][2]
      if j == 2 and col < 2 then c:put(x, y, BANDS[b][max(1, i - 1)], { r = { name = "scale" } })
      elseif j == 0 and col == 1 and i >= 3 then c:put(x, y, BANDS[b][min(6, i + 1)], { r = { name = "scale" } }) end
    end
  end)
  -- glossy streak on the back
  for _, t in ipairs{ .4, .44, .48, .52, .56 } do
    local x, y = edgePt(t, -.6, 0) c:px(floor(x + .5), floor(y + .5), "#f2f0ff")
  end
  local x, y = edgePt(.42, -.62, 0) c:px(floor(x + .5) - 1, floor(y + .5) + 1, "#cdd6ff")
  -- gill cover arc
  body:each(function(x, y)
    local k = K(x, y) local t = T[k]
    if abs(t - .305 - .02 * (S[k] ^ 2)) < .012 and abs(S[k]) < .92 then c:put(x, y, BANDS[max(1, floor((S[k] + 1) * 4) + 1)][2], { r = { name = "gill" } }) end
  end)
  -- belly fade: pale lilac lowest rim already in band 8; chin
end
-- pectoral fin over the flank
do
  local ox, oy = edgePt(.33, .25, 0)
  local pm = polyMask{ { ox - 1, oy - 2 }, { ox + 5, oy + 1 }, { ox + 8, oy + 5 }, { ox + 3, oy + 5 }, { ox - 2, oy + 2 } }
  paintFin(pm, ox - 1, oy - 1, R("#ffc060"), 6, { name = "pect", span = 1.1 })
  pm:edge():each(function(x, y) if y > oy + 3 then c:px(x, y, "#c97a3c") end end)
end
-- head: eye, nostril, lip
do
  local ex, ey = edgePt(.115, -.28, 0)
  ex, ey = floor(ex + .5), floor(ey + .5)
  local rows = { ".11.", "1221", "1221", ".11." }
  for j = 1, 4 do for i = 1, 4 do local ch = rows[j]:sub(i, i)
    if ch == "1" then c:px(ex - 1 + i, ey - 1 + j, "#fff4d6") elseif ch == "2" then c:px(ex - 1 + i, ey - 1 + j, "#2b1c26") end end end
  c:px(ex + 1, ey, "#fff4d6")                            -- glint
  c:px(ex, ey - 2, "#8aa8e8")                            -- brow shade
  local nx, ny = edgePt(.045, -.3, 0)
  c:px(floor(nx + .5), floor(ny + .5), "#27407a")        -- nostril
  local lx, ly = edgePt(.02, .35, 0)
  c:px(floor(lx + .5), floor(ly + .5), "#7a2a4e") c:px(floor(lx + .5) + 1, floor(ly + .5), "#c24a72")
end
-- bubbles from the mouth (quirk)
local mx, my = edgePt(0, 0, 0)
local function bubble(cx, cy, r, rainbow)
  local m = c:ellipse(cx, cy, r, r)
  m:each(function(x, y) c:px(x, y, "#9fdcf2") end)
  m:shrink(1):each(function(x, y) c:px(x, y, "#e6faff") end)
  m:edge():each(function(x, y) c:px(x, y, "#4a9cd0") end)
  c:px(floor(cx - r * .5), floor(cy - r * .5), "#f4fbff")
  if rainbow then
    local cols = { "#ec5a78", "#f4d846", "#3f86e0" }
    for i = 1, 3 do c:px(cx - 1 + i - 1 + 0, cy + 1 - (i == 2 and 1 or 0), cols[i]) end
  end
end
bubble(floor(mx) - 3, floor(my) - 5, 1.6)
bubble(floor(mx) - 1, floor(my) - 11, 2.2)
bubble(floor(mx) + 3, floor(my) - 19, 4.2, true)
G.save2(c, "rainbow-fish")
