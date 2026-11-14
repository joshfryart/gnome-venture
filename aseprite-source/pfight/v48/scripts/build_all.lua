-- build_all.lua : draws every v48 file.   run:  ase --batch --script build_all.lua   (scripts/run.sh does it and then checks)
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib48.lua")
local T = dofile(D .. "tiles48.lua")
for _, s in ipairs({ "strip", "hand" }) do
  local c = L.CFG[s]
  for _, t in ipairs(L.ORDER) do T.me(c, t); T.foe(c, t) end
  for _, k in ipairs(L.KORDER) do T.env(c, k) end
  T.plate(c)
end
print("build_all done")
