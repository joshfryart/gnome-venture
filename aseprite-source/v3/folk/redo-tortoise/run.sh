cd /home/user/gnome-venture/aseprite-source/v3/folk/redo-tortoise
for f in "$@"; do /tmp/aseq/squashfs-root/AppRun -b --script-param out=$PWD/new/ --script $f 2>&1 | tail -3; done
python3 - <<'PY'
from PIL import Image
import glob
for f in glob.glob('new/*.png'):
    im=Image.open(f).convert('RGBA'); im.resize((im.width*4,im.height*4),Image.NEAREST).save('/tmp/claude-0/n_'+f.split('/')[-1])
PY
