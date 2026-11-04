-- laterite-clay (final, Opus single pass): a wire-cut loaf of rust-red laterite clay, 3/4 view.
-- Body: per-pixel pillow+sphere light on a 6-tone rust ramp, dry crack lines with a lit lower lip, a concave thumb
-- dent (inverted light), three iron pisolith nodules with a metallic glint, one damp specular. The oval cut end shows
-- the fresh interior: brighter red with pale ochre vermiform mottles, iron-dark spots and diagonal wire-drag lines,
-- a bright cut lip on the upper-left rim and a dark lip lower-right.
-- quirk: an earthworm curls up out of a crack on top.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local c = A.new("laterite-clay")
local RC = { "#4a1e24", "#7a2e2b", "#a6412c", "#cb5d31", "#e98243", "#ffb06c" }
c:groundShadow(30, 50, 21, 2.5)
local body = HP.mask()
for _, e in ipairs{ { 28, 41, 17, 8 }, { 22, 36, 10, 7 }, { 34, 35, 10, 6 }, { 40, 41, 7, 8 } } do body:add(A.ellm(e[1], e[2], e[3], e[4])) end
local face = A.ellm(46, 40, 4.5, 8.5)
-- trim body right of the face
local trim = HP.mask()
body:each(function(x, y) if x > 46 and not face:has(x, y) then trim:set(x, y) end end)
body:cut(trim)
local nP = X.pillow(body, 6)
local nS = X.sphere(29, 38, 17, body)
local n = {}
for k, v in pairs(nP) do local s = nS[k] n[k] = { A.norm(v[1] * 0.45 + s[1] * 0.55, v[2] * 0.45 + s[2] * 0.55, v[3] * 0.45 + s[3] * 0.55) } end
-- thumb dent: inverted normals inside
local dent = A.ellm(24, 35, 3.2, 1.8)
dent:each(function(x, y) local k = K(x, y) if n[k] then n[k] = { A.norm(-(x - 24) / 4, -(y - 35) / 2.4, 0.7) } end end)
local bias = {}
body:each(function(x, y) if face:has(x + 1, y) or face:has(x + 2, y) then bias[K(x, y)] = -1 end end)   -- AO beside the cut edge
local idx = A.shade(c, body, n, RC, { bias = bias, amb = 0.08 })
-- cool reflected light along the lower-right underside
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > 44 then c:put(x, y, "#8a3a4e") end end)
-- dry cracks (dark groove + lit lower lip)
local function crack(pts)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local nn = max(math.abs(x1 - x0), math.abs(y1 - y0))
    for s = 0, nn do
      local x, y = floor(x0 + (x1 - x0) * s / nn + 0.5), floor(y0 + (y1 - y0) * s / nn + 0.5)
      if body:has(x, y) and not dent:has(x, y) then
        c:put(x, y, RC[1])
        if body:has(x, y + 1) and (idx[K(x, y + 1)] or 1) >= 3 then c:put(x, y + 1, RC[min(6, idx[K(x, y + 1)] + 1)]) end
      end
    end
  end
end
crack{ { 30, 31 }, { 32, 34 }, { 31, 37 } }
crack{ { 32, 34 }, { 36, 35 }, { 39, 33 } }
crack{ { 17, 40 }, { 20, 42 }, { 19, 45 } }
crack{ { 36, 44 }, { 38, 47 } }
-- iron pisoliths
for _, p in ipairs{ { 14, 38 }, { 27, 44 }, { 40, 38 } } do
  c:put(p[1], p[2], "#5a2a33") c:put(p[1] + 1, p[2], "#3d1d26") c:put(p[1], p[2] + 1, "#3d1d26") c:put(p[1] + 1, p[2] + 1, "#2f1820")
  c:put(p[1], p[2], "#d79a8c")
end
-- damp specular on the lit shoulder
c:put(20, 31, "#ffd9a6") c:put(21, 31, "#ffd9a6") c:put(19, 32, RC[6])
-- cut face
local fb = { "#6e2a2c", "#8f3529", "#b0442d", "#d0603a", "#f08a50" }
face:each(function(x, y)
  local t = 3
  local u, v = (x - 46) / 4.5, (y - 40) / 8.5
  if u + v * 0.6 > 0.55 then t = 2 end
  if not face:has(x - 1, y) or not face:has(x, y - 1) then t = 5 end
  if not face:has(x + 1, y) or not face:has(x, y + 1) then t = (t == 5) and 4 or 1 end
  if t >= 2 and t <= 3 and (x + y) % 4 == 0 and (u + v) > -0.6 then t = t - 1 end   -- wire-drag lines
  c:put(x, y, fb[t])
end)
-- mottles inside the face (pale ochre worm-veins + iron spots)
local mot = {
  { 44, 36, "#e9b360" }, { 45, 37, "#f4d398" }, { 45, 38, "#e9b360" }, { 46, 39, "#e9b360" },
  { 47, 42, "#e9b360" }, { 48, 43, "#f4d398" }, { 47, 44, "#e9b360" },
  { 44, 44, "#e9b360" }, { 44, 45, "#c98a3e" }, { 48, 35, "#c98a3e" },
  { 47, 39, "#4a1e24" }, { 45, 47, "#4a1e24" },
}
for _, m in ipairs(mot) do if face:has(m[1], m[2]) and face:has(m[1] - 1, m[2]) and face:has(m[1] + 1, m[2]) then c:put(m[1], m[2], m[3]) end end
-- quirk: earthworm curling out of the top crack
local worm = { { 31, 33, "#c94f84" }, { 31, 32, "#e07a96" }, { 31, 31, "#f5809f" }, { 31, 30, "#f5809f" }, { 32, 29, "#f5809f" },
  { 33, 29, "#ffc4d8" }, { 34, 30, "#f5809f" }, { 32, 30, "#c94f84" } }
for _, w in ipairs(worm) do c:put(w[1], w[2], w[3]) end
c:put(34, 29, "#fff4d6")
A.save2(c, "laterite-clay")
