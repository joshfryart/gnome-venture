-- build_all.lua : draws every v47 piece file.   run:  ase --batch --script build_all.lua
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib47.lua")
local T = dofile(D .. "tiles.lua")
local S = dofile(D .. "socks.lua")
local F = dofile(D .. "frames.lua")
local B = dofile(D .. "badges.lua")
for _, s in ipairs({ "strip", "hand" }) do
  local c = L.CFG[s]
  for _, t in ipairs(L.ORDER) do T.build(c, t) end
  for _, f in ipairs({ "body", "mind", "craft" }) do for _, k in ipairs({ "knob", "hole" }) do S.build(c, f, k) end end
  for _, o in ipairs({ "me", "foe", "env" }) do F.frame(c, o) end
  for _, k in ipairs({ "picked", "faded", "now" }) do F.overlay(c, k) end
  for _, b in ipairs({ "lock", "star", "flip", "eye", "land" }) do B.build(c, b) end
end
print("build_all done")
