-- samphire (first draft, Sonnet). A bunch of five jointed, fleshy sea-asparagus stems fanning up out of wet grey-brown
-- mud, each segmented with notch lines and forking into pale-tipped branchlets.
-- quirk: a tiny spiral shell sits in the mud at the base.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("samphire")
local floor = math.floor
-- mud mound
local mud = c:ellipse(32, 54, 18, 5)
A.lit(c, mud, A.R("#6a5a56"), 3, { amb = .08 })
A.speck(c, mud, { "#8a7a72", "#4a3a3c" }, .15, 4)
local G = A.R("#4a9a4e")
local function stem(x0, y0, x1, y1, w, forks)
  A.rod(c, x0, y0, x1, y1, w, G, { amb = .1, wrap = .3 })
  local n = floor(math.sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2) / 3)
  for i = 1, n do
    local t = i / (n + .5)
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    for dx = -floor(w + .5), floor(w + .5) do c:px(x + dx, y, G[2]) end
  end
  for _, f in ipairs(forks or {}) do
    local t, ex, ey = f[1], f[2], f[3]
    local sx, sy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    A.rod(c, sx, sy, ex, ey, .9, G, { amb = .1 })
    A.sph(c, ex, ey, 1.4, "#c4e07a", { nospec = true })
  end
  A.sph(c, x1, y1, w + .4, "#b6dc7a", { nospec = true })
  c:px(x1 - 1, y1 - 1, "#f0ffc0")
end
stem(32, 54, 14, 14, 1.6, { { .55, 9, 24 }, { .75, 21, 16 } })
stem(33, 54, 27, 8, 1.7, { { .5, 17, 24 }, { .65, 36, 22 } })
stem(34, 54, 39, 6, 1.7, { { .45, 28, 26 } , { .7, 47, 18 } })
stem(35, 54, 52, 12, 1.6, { { .5, 55, 30 }, { .7, 41, 20 } })
stem(33, 54, 22, 30, 1.3, {})
-- shell
A.sph(c, 47, 51, 2.4, "#efe4c4", {})
c:px(47, 51, "#b8864a") c:px(48, 52, "#b8864a") c:px(46, 50, "#fff4d6")
A.fin()
