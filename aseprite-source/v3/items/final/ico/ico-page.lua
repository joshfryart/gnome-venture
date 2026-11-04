-- ico-page (final, Opus). A single portrait sheet of warm parchment with its top-right corner folded down
-- (dog-ear showing the paper back), a bold heading bar and five handwritten ink lines of varied length.
-- Material: per-pixel lit paper with a soft rolling wave across the sheet and a bevelled edge, sparse paper
-- fibres, lit fold crease on the dog-ear, contact shadow where the flap lies on the page, ink lines with a
-- darker lower row and a dry-brush tail.
-- quirk: a little green bookworm pokes out of a hole it has nibbled near the bottom.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, sin, cos, max, min, abs, sqrt, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.sqrt, math.pi
local c = A.new("ico-page")
local PAP  = { "#7a5e4e", "#b0927a", "#d4b994", "#ead4ac", "#f7e8c6", "#fff3da" }
local BACK = { "#8c6c5a", "#b89878", "#d8bc94", "#ecd5ac" }
local INKR = { "#3c2433", "#5a3a4c", "#7a5868" }
local HEAD = { "#7d2a3a", "#b5383f", "#e0574a" }
local WORM = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local ptok, btok, itok = A.tok("paper"), A.tok("back"), A.tok("ink")
local X0, Y0, X1, Y1, F = 19, 8, 45, 56, 9

local page = c:poly{ { X0, Y0 }, { X1 - F, Y0 }, { X1, Y0 + F }, { X1, Y1 }, { X0, Y1 } }
local n = X.pillow(page, 2)
for k, v in pairs(n) do
  local x = k % 1024 - 256
  local w = 0.34 * sin((x - X0) / (X1 - X0) * pi * 1.6 + 0.3)
  n[k] = { A.norm(v[1] + w, v[2], v[3]) }
end
local bias = {}
-- contact shadow where the flap lies on the page (left of and under the flap)
local flap = c:poly{ { X1 - F, Y0 }, { X1 - F, Y0 + F }, { X1, Y0 + F } }
G.cast(bias, page, flap, -1, 1, -1)
G.cast(bias, page, flap, -2, 2, -1)
local pidx = A.shade(c, page, n, PAP, { tok = ptok, bias = bias, amb = 0.14, wrap = 0.35, cuts = { 0.1, 0.24, 0.42, 0.62, 0.86 } })
-- paper fibres
page:shrink(2):each(function(x, y)
  local h = X.hash(x, y, 7)
  if h < 0.035 then A.step(c, pidx, PAP, x, y, -1, ptok) elseif h > 0.975 then A.step(c, pidx, PAP, x, y, 1, ptok) end
end)
-- flap (paper back): lit along the fold crease, darker toward the tip
flap:each(function(x, y)
  local d = (x - (X1 - F)) - (y - Y0)          -- 0 on the crease, negative toward the tip corner
  local i = d >= 0 and 4 or d >= -2 and 3 or d >= -5 and 2 or 1
  c:put(x, y, BACK[i], btok)
end)
for i = 0, F do c:put(X1 - F + i, Y0 + i, PAP[6], ptok) end
-- flap edges darker (separation from the page)
for y = Y0, Y0 + F do c:put(X1 - F, y, BACK[1], btok) end
for x = X1 - F, X1 do c:put(x, Y0 + F, BACK[1], btok) end

-- heading bar (red ink), 3 px tall, with a lit top row
for x = X0 + 4, X0 + 14 do
  c:put(x, 13, HEAD[3], itok) c:put(x, 14, HEAD[2], itok) c:put(x, 15, HEAD[1], itok)
end
c:put(X0 + 4, 13, HEAD[2], itok) c:put(X0 + 15, 14, HEAD[1], itok)
-- handwritten lines: 2 px, base over dark, with a dry tail and an occasional gap (word breaks)
local lines = { { 21, 21, 4 }, { 26, 18, 11 }, { 31, 21, 7 }, { 36, 19, 13 }, { 41, 21, 5 }, { 46, 12, 0 } }
for _, L in ipairs(lines) do
  local y, len, gap = L[1], L[2], L[3]
  for i = 0, len - 1 do
    local x = X0 + 4 + i
    if gap == 0 or i ~= gap then
      c:put(x, y, INKR[2], itok) c:put(x, y + 1, INKR[1], itok)
    end
  end
  c:put(X0 + 4 + len, y + 1, INKR[3], itok)
end
-- pop: one 2x1 hi glint upper-left
c:put(X0 + 2, Y0 + 2, A.CREAM, ptok) c:put(X0 + 3, Y0 + 2, A.CREAM, ptok)

-- quirk: bookworm poking out of a nibbled hole (lower right)
local hx, hy = 38, 52
A.map(c, {
  ".bkkkb.",
  "bkkkkkb",
  ".bbbbb.",
}, hx - 3, hy - 1, { k = INKR[1], b = PAP[2] }, itok)
-- nibbled crumbs
c:put(hx - 4, hy + 2, PAP[3], ptok) c:put(hx + 4, hy - 2, PAP[3], ptok)
local wt = A.tok("worm")
A.map(c, {
  ".hgg.",
  "hgggG",
  "hgegG",
  "hgggG",
  ".dGd.",
  ".hgG.",
  ".gGG.",
  ".dGd.",
  ".hgG.",
}, hx - 2, hy - 10, { h = WORM[4], g = WORM[3], G = WORM[2], d = WORM[1], e = A.INK }, wt)
c:put(hx - 1, hy - 9, "#e4f6c0", wt)
c:put(hx + 2, hy - 7, "#f5809f", wt)
A.save(c, "ico-page")
