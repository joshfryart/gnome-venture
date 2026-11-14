-- tiles48.lua : tile-<size>-<type> (mine), foe-<size>-<type> (the creature's), env-<size>-<kind> (the environment's), plate-<size>, digits-<size>
-- layers: base, bevel, [teeth | stitch], rim, glyph. The glyph is its own layer (the kit holds tile and glyph apart, so a named piece can swap in its own icon).
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib48.lua")
local G = dofile(D .. "glyphs48.lua")
local T = {}
local function out(c, file, layers, glyph, key)
  layers[#layers + 1] = { name = "glyph", cv = glyph }
  L.save(L.OUT .. c.name .. "/" .. file, c.W, c.H, layers)
  L.savelayer(L.OUT .. "scripts/layers/glyph-" .. c.name .. "-" .. key, glyph)
end

function T.me(c, t)
  local P = L.TYPES[t]
  local base, bevel, rim = L.body(c, P)
  local glyph, w, h = G.make(c, "me", t, P)
  out(c, "tile-" .. c.name .. "-" .. t, { { name = "base", cv = base }, { name = "bevel", cv = bevel }, { name = "rim", cv = rim } }, glyph, "me-" .. t)
  print(("glyph %s me  %-7s %dx%d"):format(c.name, t, w, h))
end

function T.foe(c, t)
  local R = L.FOE
  local base, bevel, rim = L.body(c, R)
  -- teeth: bone fangs along the top and the bottom edge, outside the socket mouths (the creature's mark, readable without colour)
  local teeth = L.cv(c.W, c.H)
  local hand = c.name == "hand"
  local pos = hand and { 9, 19, 28 } or { 6, 12 }
  local wmax = hand and 9 or 5
  for _, p0 in ipairs(pos) do for _, cx in ipairs({ p0, c.BW - 1 - p0 }) do
    local rows = (wmax + 1) // 2
    for r = 0, rows - 1 do
      local w = wmax - 2 * r
      for k = -(w - 1) // 2, (w - 1) // 2 do
        local col = (k == (w - 1) // 2 or r == rows - 1) and R.toothsh or R.tooth
        local function put(y) if L.inBody(c, cx + k, y) and not L.isRim(c, cx + k, y) then teeth:set(c.T + cx + k, c.T + y, col) end end
        put(1 + r); put(c.BH - 2 - r)
      end
    end
  end end
  local glyph, w, h = G.make(c, "foe", t, L.TYPES[t])
  out(c, "foe-" .. c.name .. "-" .. t, { { name = "base", cv = base }, { name = "bevel", cv = bevel }, { name = "teeth", cv = teeth }, { name = "rim", cv = rim } }, glyph, "foe-" .. t)
  print(("glyph %s foe %-7s %dx%d"):format(c.name, t, w, h))
end

function T.env(c, kind)
  local R, K = L.ENV, L.KINDS[kind]
  local base, bevel, rim = L.body(c, R)
  -- a dashed stitch in the kind's colour, 3 on 2 off, mirrored from the middle of each side
  local st = L.cv(c.W, c.H)
  local n = c.stitchIn
  local function pat(i, len) local j = i; if i >= len / 2 then j = len - 1 - i end; return (j % 5) < 3 end
  local lx, ly = c.BW - 2 * n - 4, c.BH - 2 * n - 4
  local th = (c.name == "hand") and 2 or 1
  for k = 0, th - 1 do
    for i = 0, lx - 1 do if pat(i, lx) then st:set(c.T + n + 2 + i, c.T + n + k, K.shade); st:set(c.T + n + 2 + i, c.T + c.BH - 1 - n - k, K.shade) end end
    for i = 0, ly - 1 do if pat(i, ly) then st:set(c.T + n + k, c.T + n + 2 + i, K.shade); st:set(c.T + c.BW - 1 - n - k, c.T + n + 2 + i, K.shade) end end
  end
  local glyph, w, h = G.make(c, "env", kind, K)
  out(c, "env-" .. c.name .. "-" .. kind, { { name = "base", cv = base }, { name = "bevel", cv = bevel }, { name = "stitch", cv = st }, { name = "rim", cv = rim } }, glyph, "env-" .. kind)
  print(("glyph %s env %-7s %dx%d"):format(c.name, kind, w, h))
end

-- the number plate (16 x 12 / 28 x 20) and its digits: figures drawn by hand at 6 x 10 with 2 px strokes (strip); the hand size is the same drawing at 1.5 x (9 x 15, 3 px strokes)
local FONT = {
  { ".####.", "######", "##..##", "##..##", "##..##", "##..##", "##..##", "##..##", "######", ".####." },
  { "..##..", ".###..", "####..", "..##..", "..##..", "..##..", "..##..", "..##..", "######", "######" },
  { ".####.", "######", "##..##", "....##", "...###", "..###.", ".###..", "###...", "######", "######" },
  { ".####.", "######", "....##", "....##", "..###.", "..###.", "....##", "....##", "######", ".####." },
  { "...###", "..####", ".##.##", "##..##", "##..##", "######", "######", "....##", "....##", "....##" },
  { "######", "######", "##....", "#####.", "######", "....##", "....##", "##..##", "######", ".####." },
  { ".####.", "######", "##....", "#####.", "######", "##..##", "##..##", "##..##", "######", ".####." },
  { "######", "######", "....##", "...###", "...##.", "..###.", "..##..", "..##..", "..##..", "..##.." },
  { ".####.", "######", "##..##", "##..##", ".####.", ".####.", "##..##", "##..##", "######", ".####." },
  { ".####.", "######", "##..##", "##..##", "######", ".#####", "....##", "....##", "######", ".####." },
}
function T.plate(c)
  local hand = c.name == "hand"
  local w, h, k = hand and 28 or 16, hand and 20 or 12, hand and 3 or 2
  local p = L.cv(w, h)
  local r = hand and 3 or 2
  local f = L.S.rrect(0, 0, w, h, r)
  for y = 0, h - 1 do for x = 0, w - 1 do if f(x + .5, y + .5) then p:set(x, y, (y >= h - (hand and 2 or 1)) and 0x150d07 or L.INK) end end end
  L.save(L.OUT .. c.name .. "/plate-" .. c.name, w, h, { { name = "plate", cv = p } })
  local gw, gh = 3 * k, 5 * k
  local d = L.cv(gw * 10, gh)
  local sc = k / 2
  for n = 0, 9 do
    local F = FONT[n + 1]
    for y = 0, gh - 1 do for x = 0, gw - 1 do
      local hit = 0
      for sy = 0, 3 do for sx = 0, 3 do
        local ux, uy = math.floor((x + (sx + .5) / 4) / sc), math.floor((y + (sy + .5) / 4) / sc)
        if F[uy + 1]:sub(ux + 1, ux + 1) == "#" then hit = hit + 1 end
      end end
      if hit >= 8 then d:set(n * gw + x, y, L.CREAM) end
    end end
  end
  L.save(L.OUT .. c.name .. "/digits-" .. c.name, gw * 10, gh, { { name = "digits", cv = d } })
end
return T
