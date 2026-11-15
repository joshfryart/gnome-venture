-- wayfarers-hat: wide brown felt hat, red band, blue jay feather. quirk: the feather tip is kinked.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wayfarers-hat" }

-- brim: underside rim first, then top surface
local brimTop = c:ellipse(32, 40, 27, 9)
local brimUnder = c:ellipse(32, 42, 27, 9):cut(brimTop)
local crown = c:poly{ {19,38}, {20,27}, {22,21}, {26,18}, {30,18}, {32,20}, {34,18}, {38,18}, {42,21}, {44,27}, {45,38} }
  :add(c:ellipse(32, 38, 13, 4))
for _, m in ipairs({ brimUnder }) do
  local i = W.lit(c, m, R.felt, { R = 1, bias = {} })
end
brimUnder:each(function(x, y) c:put(x, y, (y >= 48 or x > 46) and R.felt[1] or R.felt[2]) end)
-- brim top: flat-ish plane, crown casts shade to the lower right
local bias = {}
G.cast(bias, brimTop, crown, 3, 2, -1)
G.cast(bias, brimTop, crown, 1, 1, -1)
local bi = W.lit(c, brimTop, R.felt, { R = 5, hs = 0.7, bias = bias, cuts = { .2, .38, .55, .72, .9 } })
W.speckle(c, brimTop, bi, R.felt, 0.07, 3)
-- brim edge highlight on the upper-left rim, slight upturn
for x = 8, 22 do local y0 for y = 30, 50 do if brimTop:has(x, y) then y0 = y break end end if y0 then c:put(x, y0, R.felt[5]) end end
-- crown
W.sep(c, crown, brimTop, R.felt[1])
local ci = W.vcyl(c, crown, R.felt, 19, 45, { tilt = -0.05, cuts = { .22, .4, .58, .76, .92 } })
W.speckle(c, crown, ci, R.felt, 0.07, 7)
-- pinch dent: dark crease down the middle, lit ridge to the left of it
for y = 20, 27 do c:put(32, y, R.felt[y < 24 and 2 or 3]) end
for y = 19, 25 do c:put(31, y, R.felt[5]) end
c:put(29, 19, R.felt[6]) c:put(28, 19, R.felt[6]) c:put(27, 19, R.felt[5])
-- side pinches
W.put(c, { {24,22}, {24,23}, {25,24} }, R.felt[3]) W.put(c, { {40,22}, {40,23}, {39,24} }, R.felt[2])
-- band
local band = crown:copy():clip(c:rect(0, 31, 63, 36)):cut(c:rect(0,0,63,30))
local bandL = HP.mask() band:each(function(x, y) if y <= 35 + (math.abs(x - 32) < 9 and 1 or 0) then bandL:set(x, y) end end)
W.vcyl(c, bandL, R.ember, 19, 45, { cuts = { .2, .36, .52, .7, .88 } })
bandL:each(function(x, y) if not bandL:has(x, y - 1) then c:put(x, y, R.ember[x < 30 and 6 or 5]) end end)
bandL:each(function(x, y) if not bandL:has(x, y + 1) then c:put(x, y, R.ember[1]) end end)
-- band bow knot on the left
local knot = c:rrect(21, 31, 25, 36, 1)
W.lit(c, knot, R.ember, { R = 2 })
c:put(22, 32, R.ember[6]) W.vline(c, 25, 32, 35, R.ember[1])
-- feather: tucked in the band on the right, sweeping up-right
local fm, fn, FT, FS = G.blade(42, 35, 50, 24, 53, 9, function(t) if t < 0.12 then return 0.6 end return 2.6 * math.sin(math.pi * math.min(1, (t - 0.05) * 1.05)) ^ 0.6 end, { fold = 0.4 })
fm:cut(crown:copy():clip(c:rect(0, 31, 40, 63)))
W.sep(c, fm, crown, W.ink)
local fi = W.toneN(c, fm, fn, R.jay, { cuts = { .3, .5, .66, .8, .95 } })
fm:each(function(x, y)
  local k = K(x, y)
  local t, s = FT[k], FS[k]
  if math.abs(s) < 0.22 then c:put(x, y, R.jay[6]) end                  -- pale quill
  if t > 0.55 and t < 0.75 and math.abs(s) > 0.3 and (x + y) % 3 == 0 then c:put(x, y, R.jay[1]) end -- dark bar
  if t > 0.86 then c:put(x, y, s < 0 and R.jay[3] or R.jay[2]) end      -- dark tip
end)
-- kinked tip (quirk): notch on the outer edge
fm:each(function(x, y) if FT[K(x, y)] > 0.4 and FT[K(x, y)] < 0.47 and FS[K(x, y)] > 0.5 then c.pix[y * 64 + x] = nil c.own[y * 64 + x] = nil end end)
-- felt gloss pop on crown
c:put(22, 26, R.felt[6]) c:put(22, 27, R.felt[6])
W.save(c, "wayfarers-hat")
