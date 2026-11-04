-- monkey-fur (final, Opus single pass): a lock of russet monkey fur bound at the root with twisted straw twine.
-- Five slim tufts sweep up out of the binding in a flame-like S curve, each with hair lines along its length,
-- sun-bleached tips and AO where tufts overlap; a short flared brush of cut hair under the binding (pale cut ends),
-- the twine's loose end trails off to the right with its twist showing.
-- quirk: a tiny hooked burr is snagged in the fur.
local NAME = "monkey-fur"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local FUR  = { "#3a1a1e", "#62281e", "#963e22", "#c8622a", "#ec9144", "#fcc77c" }
local TWN  = { "#51302b", "#8a5e30", "#c39648", "#ead08a" }
local BUR  = { "#2e3a24", "#4e5e2c", "#7c8a3a", "#b0b85a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- tufts (back to front): cubic bezier, base half width
local tufts = {
  { { { 28, 45 }, { 20, 36 }, { 19, 26 }, { 11, 18 } }, 3.4 },
  { { { 34, 45 }, { 44, 38 }, { 42, 28 }, { 52, 21 } }, 3.4 },
  { { { 29, 45 }, { 26, 33 }, { 15, 24 }, { 21, 9 } }, 3.6 },
  { { { 33, 45 }, { 38, 33 }, { 46, 22 }, { 41, 9 } }, 3.6 },
  { { { 31, 45 }, { 33, 33 }, { 26, 21 }, { 32, 6 } }, 3.8 },
}
local masks = {}
for i, tf in ipairs(tufts) do
  local w0 = tf[2]
  local m, n, T, S = G.tube(tf[1], function(t) if t > 0.97 then return 0.3 end return w0 * (1 - t) ^ 0.9 * (0.85 + 0.15 * sin(t * 9)) + 0.35 end)
  m:cut(HP.mask():add(c:rect(0, 44, 63, 63)))   -- binding covers the roots
  -- wispy forked tip: split the last stretch down the middle
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.8 and abs(S[k]) < 0.22 then m.s[k] = nil end end)
  masks[i] = { m = m, n = n, T = T, S = S }
end
for i, tf in ipairs(masks) do
  local bias = {}
  for j = i + 1, #masks do X.ao(bias, tf.m, masks[j].m, 1, -1) G.cast(bias, tf.m, masks[j].m, 1, 1, -1) end
  local tok = { r = { name = "tuft" .. i } }
  local v = X.light(tf.n, { amb = 0.1, wrap = 0.3 })
  local idx = X.tone(c, tf.m, v, FUR, { cuts = CUTS, bias = bias, tok = tok })
  -- hair lines along the tuft (constant offset across), bleached tips, darker roots
  tf.m:each(function(x, y) local k = K(x, y)
    local i0 = idx[k]
    local band = floor((tf.S[k] + 1) * 2.6 + tf.T[k] * 1.4)
    if band % 2 == 1 and tf.T[k] < 0.9 then i0 = i0 - 1 end
    if tf.T[k] > 0.8 then i0 = i0 + 1 end
    if tf.T[k] < 0.08 then i0 = i0 - 1 end
    c:put(x, y, FUR[max(1, min(6, i0))], tok)
  end)
end

-- brush of cut hair below the binding, flaring out
local brush = HP.mask()
for y = 50, 54 do local hw = 3 + (y - 50) * 0.7 for x = floor(31 - hw + 0.5), floor(31 + hw + 0.5) do brush:set(x, y) end end
local btok = { r = { name = "brush" } }
brush:each(function(x, y)
  local i = (x < 30 and 4 or x < 33 and 3 or 2)
  if (x + (y > 52 and 1 or 0)) % 2 == 0 then i = i - 1 end
  if y == 50 then i = 1 end                      -- AO under the binding
  if y == 54 then i = (x % 2 == 0) and 6 or 5 end -- pale cut ends
  c:put(x, y, FUR[max(1, i)], btok)
end)

-- twine binding: a short cylinder wrapped with diagonal twisted turns
local bind = c:rrect(26, 43, 36, 49, 1)
local ttok = { r = { name = "twine" } }
bind:each(function(x, y)
  local u = (x - 31) / 5.5
  local l = (-u * 0.8 + 0.55)
  local i = l > 0.55 and 4 or l > 0.15 and 3 or l > -0.35 and 2 or 1
  if i == 4 and x > 29 then i = 3 end
  local ph = (x + 2 * y) % 4
  if ph == 0 then i = max(1, i - 1) elseif ph == 1 and i < 4 then i = i + 1 end
  if y == 43 or y == 49 then i = max(1, i - 1) end
  c:put(x, y, TWN[i], ttok)
end)
-- loose twine end trailing to the lower right, twist dots alternating
local tail, tn = G.tube({ { 36, 47 }, { 40, 49 }, { 42, 53 }, { 46, 56 } }, function(t) return 0.85 end)
tail:cut(bind)
tail:each(function(x, y) local i = ((x + y) % 2 == 0) and 3 or 2 c:put(x, y, TWN[i], ttok) end)
c:put(46, 56, TWN[4], ttok)

-- quirk: hooked burr snagged on the right tuft
local bx, by = 45, 27
local bur = c:ellipse(bx, by, 2, 2)
local nb = X.sphere(bx - 0.4, by - 0.4, 2.2, bur)
local rtok = { r = { name = "burr" } }
X.tone(c, bur, X.light(nb, { amb = 0.1, wrap = 0.2 }), BUR, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
for _, p in ipairs{ { bx, by - 3 }, { bx + 3, by }, { bx - 3, by - 1 }, { bx + 2, by - 3 }, { bx - 2, by + 3 }, { bx + 2, by + 3 } } do c:put(p[1], p[2], BUR[2], rtok) end
c:put(bx - 1, by - 1, BUR[4], rtok)
-- contact shadow of the burr on the tuft under it
for _, p in ipairs{ { bx + 1, by + 3 }, { bx + 3, by + 2 }, { bx + 3, by + 1 } } do
  if masks[4].m:has(p[1], p[2]) or masks[2].m:has(p[1], p[2]) or masks[5].m:has(p[1], p[2]) then c:put(p[1], p[2], FUR[2], rtok) end end

-- single glint on the front tuft's sheen
if masks[5].m:has(29, 24) then c:put(29, 24, FUR[6], { r = { name = "tuft5" } }) end

A.save(c, NAME)
