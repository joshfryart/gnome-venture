set -e
cd /c/Users/hello/gv-icons
A="C:/Program Files/Aseprite/Aseprite.exe"
python gen_icons.py 264 glm-5.3-flash:cloud
cp icons.jsonl icons_v1.jsonl
"$A" -b --script make_icons.lua > /dev/null
mkdir -p out_v1
for f in out/ico-*.png; do case $f in *-s.png) ;; *) cp "$f" out_v1/;; esac; done
python revise.py glm-5.3-flash:cloud
cp icons.jsonl icons_v2.jsonl
"$A" -b --script make_icons.lua | tail -1
echo ALLDONE
