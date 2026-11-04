-- picket-fence-cross (final, Opus single pass): a four-way junction seen corner-on: a square post turned 45 degrees
-- with a blue painted pyramid cap, and four short picket arms running off on the two diagonals (an X). Material:
-- per-pixel pillow light, SW-facing run lit, SE-facing run in cool shade, end grain on the rail ends, nail heads,
-- grain streaks and a paint chip, a bright arris on the post edge, cap with lit/shade facets and a dark drip lip,
-- contact shadow behind pickets and AO at the feet, ground shadow.
-- quirk: somebody's red knitted mitten is hung to dry on the far right picket.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_4.lua")
local floor, abs = math.floor, math.abs
local c = A.new("picket-fence-cross")
c:groundShadow(32, 46, 24, 5)
local HGT = 20
-- back arms
A.rail(c, 13, 29, 32, 32, 0.5, { ends = { "l" } })
A.rail(c, 13, 29, 32, 40, 0.5, { ends = { "l" } })
A.rail(c, 35, 51, 32, 32, -0.5, { ends = { "r" }, bias = -1 })
A.rail(c, 35, 51, 32, 40, -0.5, { ends = { "r" }, bias = -1 })
A.picket(c, 16, 37, HGT, 0.5, { grain = 1 })
A.picket(c, 48, 37, HGT, -0.5, { bias = -1, grain = -1 })
A.picket(c, 23, 41, HGT, 0.5, { grain = -1 })
A.picket(c, 41, 41, HGT, -0.5, { bias = -1, grain = 1, chip = { -1, -10 } })
local function nails(cx, sl) local y = 32 + floor(sl * (cx - 32)) + 1 A.nail(c, cx, y) A.nail(c, cx, y + 8) end
nails(16, .5) nails(23, .5) nails(48, -.5) nails(41, -.5)
-- post + pyramid cap
local P = A.post(c, 32, 48, 4, 26, { top = false })
local CAP = { "#25365e", "#33528a", "#4776ad", "#64a0c8", "#93cbdf", "#c6ecef" }
local peak = P.top[32] - 9
local tok = { r = { name = "cap" } }
for x = 27, 36 do
  local d = x < 32 and (31 - x) or (x - 32)           -- 0 at the ridge
  local yt = peak + floor(d * 1.25)
  local yb = (P.top[math.max(28, math.min(35, x))] or P.top[32]) + 1
  for y = yt, yb do
    local lit = x < 32
    local i = lit and 5 or 3
    if y == yb then i = lit and 3 or 1                 -- lip in shade
    elseif x == 31 and y < yt + 3 then i = 6           -- ridge catch-light
    elseif lit and d >= 3 then i = 4
    elseif not lit and d >= 3 then i = 2 end
    c:put(x, y, CAP[i], tok)
  end
end
c:put(31, peak, CAP[6], tok) c:put(30, peak + 3, A.CREAM, tok)
-- front arms (after the post)
A.rail(c, 35, 51, 32, 32, 0.5, { ends = { "r" } })
A.rail(c, 35, 51, 32, 40, 0.5, { ends = { "r" } })
A.rail(c, 13, 29, 32, 32, -0.5, { ends = { "l" }, bias = -1 })
A.rail(c, 13, 29, 32, 40, -0.5, { ends = { "l" }, bias = -1 })
A.picket(c, 23, 49, HGT, -0.5, { bias = -1, grain = 1 })
A.picket(c, 41, 49, HGT, 0.5, { grain = -1 })
A.picket(c, 16, 53, HGT, -0.5, { bias = -1, grain = -1 })
A.picket(c, 48, 53, HGT, 0.5, { grain = 1, chip = { 1, -6 } })
nails(23, -.5) nails(16, -.5) nails(41, .5) nails(48, .5)
-- quirk: mitten hung on the far right picket's point
c:put(48, 18, A.INK)
A.map(c, {
  "..EE.",
  ".EeEE",
  "TEeEE",
  "TEEEr",
  ".EEEr",
  ".cCc.",
  ".CcC.",
}, 46, 19, { E = "#e8493b", e = "#ff8a5c", r = "#b52e3f", T = "#c93a3c", c = "#fff4d6", C = "#e3c99a" })
A.tuft(c, 31, 50) A.tuft(c, 12, 54) A.tuft(c, 51, 54)
A.save(c, "picket-fence-cross")
