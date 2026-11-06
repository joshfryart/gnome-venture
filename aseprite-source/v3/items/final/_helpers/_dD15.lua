-- _dD15.lua: private helpers for the D15 chunk (ph/sea-grapes .. ph/siam-tulip-seed). First draft layer over batch2/_b2.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local D = setmetatable({}, { __index = B })
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
D.R = {  -- 6-tone ramps, dark -> light
  leaf  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" },
  fresh = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" },
  bluegr= { "#173a45", "#1f5560", "#2b7573", "#3f9a86", "#6cbd9a", "#a4dcb4" },
  tan   = { "#4a2e22", "#6e4530", "#946440", "#b8864f", "#d8ac6c", "#f0d296" },
  red   = { "#4a1426", "#7a1f35", "#a82c3a", "#d4463a", "#f0705a", "#ffa882" },
  brown = { "#2e1c1c", "#4f2d26", "#74422f", "#9a5d3a", "#bc8250", "#dcb07a" },
  cream = { "#8a7a6a", "#b4a48e", "#d4c6a8", "#ebdfc4", "#f6eed8", "#fffbea" },
  purple= { "#2c1f4a", "#46306e", "#62459a", "#8266bc", "#a88ad8", "#cdb6f0" },
  stone = { "#2e3048", "#444663", "#5e607a", "#74758c", "#aaa9b8", "#d4d3de" },
  iron  = { "#1a1822", "#2a2832", "#3c3a4a", "#54526a", "#74758c", "#a4a6b8" },
  gold  = { "#6e3a1c", "#a45a20", "#d98322", "#f5b82e", "#ffd860", "#fff0a8" },
  salt  = { "#6a7ea0", "#8fa4c4", "#b4c6e0", "#d6e4f2", "#eef6fc", "#f8fcff" },
  mauve = { "#2c1a28", "#4a2a3c", "#6e405a", "#905a74", "#b87c92", "#dca4b4" },
  quartz= { "#4a6aa0", "#6a8cc0", "#8fb2dc", "#b4d2ee", "#d8ecfa", "#f4faff" },
  pink  = { "#7d2c5e", "#a8467a", "#d4659a", "#f5809f", "#ffa8c0", "#ffd4e0" },
  skin  = { "#6b6a48", "#8f8e62", "#b5b484", "#d2d1a6", "#e6e4c2", "#f6f4dc" },
  olive = { "#2a3a18", "#41581f", "#5f7a2a", "#84a03a", "#a8c258", "#cfe08a" },
}
function D.new(name) return B.new(name) end
-- seed-on-scrap scene. o: leaf ramp, la, lb, lw, veins, seeds{cx,cy,rx,ry,ang[,ramp]}, seed ramp, sprout(c), extra(c)
function D.seedScene(name, o)
  local c = D.new(name)
  B.blade(c, o.la[1], o.la[2], o.lb[1], o.lb[2], o.lw, o.leaf, { veins = o.veins or { 6, 12, 18, 24, 30, 36 }, slant = 2.4 })
  if o.pre then o.pre(c) end
  for _, s in ipairs(o.seeds) do B.seed(c, s[1], s[2], s[3], s[4], s[5], s[6] or o.seed, o.shadow or "#163a35", o.glint) end
  if o.sprout then o.sprout(c) end
  if o.extra then o.extra(c) end
  B.fin()
  return c
end
-- dot-ish glint
function D.gl(c, x, y) c:px(x, y, D.CREAM) end
-- bezier/sweep helper re-export
D.sweep = B.H.sweep
return D
