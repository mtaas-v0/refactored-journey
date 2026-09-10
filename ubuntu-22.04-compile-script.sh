source ubuntu-22.04-compile-env.sh

wget http://mirrors.ctan.org/systems/knuth/dist.zip
wget http://mirrors.ctan.org/systems/knuth/local.zip
wget http://mirrors.ctan.org/systems/unix/tex-fpc.zip

unzip -q dist.zip
unzip -q local.zip
unzip -q tex-fpc.zip
rm -f *.zip

mkdir -p "$TEX_HOME/distro/bin"
mkdir -p "$TEX_HOME/distro/TeXinputs"
mkdir -p "$TEX_HOME/distro/TeXformats"
mkdir -p "$TEX_HOME/distro/TeXfonts"
mkdir -p "$TEX_HOME/distro/MFbases"
mkdir -p "$TEX_HOME/distro/MFinputs"
mkdir -p "$TEX_HOME/distro/PKfonts"

# Populate source files into their staging paths
cp -r "$TEX_HOME/dist"/* "$TEX_HOME/tex-fpc/"
cp "$TEX_HOME/dist/lib"/* "$TEX_HOME/distro/TeXinputs/"
cp "$TEX_HOME/dist/cm"/* "$TEX_HOME/distro/MFinputs/"
cp "$TEX_HOME/local/cm"/* "$TEX_HOME/distro/MFinputs/"
cp "$TEX_HOME/tex-fpc/shell"/* "$TEX_HOME/distro/bin/"
chmod +x "$TEX_HOME/distro/bin"/* "$TEX_HOME/tex-fpc/shell"/*

cd "$TEX_HOME"
fpc tex-fpc/tangle.p
mv tex-fpc/tangle distro/bin/

cd "$TEX_HOME"

# Initial Metafont
itgl tex-fpc/mf/mf.web tex-fpc/mf.ch
mv inimf distro/bin/
mv mf.pool distro/MFbases/

# Initial TeX
itgl tex-fpc/tex/tex.web tex-fpc/tex.ch
mv initex distro/bin/
mv tex.pool distro/TeXformats/

cd "$TEX_HOME/distro"
inimf ../dist/lib/plain input ../tex-fpc/local dump
mv plain.base MFbases/


cd "$TEX_HOME/tex-fpc/mf"
cp ../mf.ch .
../ch.ch/mkprod mf
tgl mf.web mf.ch
mv mf "$TEX_HOME/distro/bin/"

cd "$TEX_HOME/tex-fpc/cm"
ln -sf "$TEX_HOME/distro/MFbases" .
ln -sf "$TEX_HOME/distro/MFinputs" .
ln -sf "$TEX_HOME/distro/TeXfonts" .

bash "$TEX_HOME/tex-fpc/MFT/plainfonts"

ls -la "$TEX_HOME/distro/TeXfonts"


cd "$TEX_HOME"

# Copy manfnt and other lib fonts to MFinputs
cp dist/lib/*mf distro/MFinputs/ 2>/dev/null || true
cp local/lib/*mf distro/MFinputs/ 2>/dev/null || true

cd "$TEX_HOME/distro"
mkfont manfnt

cd "$TEX_HOME/distro"

# Ensure plain.tex and hyphen.tex are available in TeXinputs
cp "$TEX_HOME/dist/lib/plain.tex" TeXinputs/
cp "$TEX_HOME/dist/lib/hyphen.tex" TeXinputs/

# Run initex
initex ../dist/lib/plain '\dump'

# Move the resulting format file
mv plain.fmt TeXformats/

cd "$TEX_HOME/tex-fpc/tex"
cp ../tex.ch .
../ch.ch/mkprod tex
tgl tex.web tex.ch
mv tex "$TEX_HOME/distro/bin/"

cd "$TEX_HOME"
cat << 'EOF' > test.tex
\magnification=\magstep1
\centerline{\bf Welcome to TeX-FPC 4th Edition on Ubuntu 22.04}
\medskip
This document was typeset using the original Stanford WEB source compiled via FPC.
\bye
EOF

cat << EOF > "$TEX_HOME/distro/bin/mk_TeX_dir"
#!/bin/sh
ln -sf "$TEX_HOME/distro/TeXinputs" TeXinputs
ln -sf "$TEX_HOME/distro/TeXfonts" TeXfonts
ln -sf "$TEX_HOME/distro/TeXformats" TeXformats
ln -sf "$TEX_HOME/distro/PKfonts" PKfonts
ln -sf "$TEX_HOME/distro/DVIPSconf" DVIPSconf
EOF

cat << EOF > "$TEX_HOME/distro/bin/mk_MF_dir"
#!/bin/sh
ln -sf "$TEX_HOME/distro/MFinputs" MFinputs
ln -sf "$TEX_HOME/distro/MFbases" MFbases
ln -sf "$TEX_HOME/distro/PKfonts" PKfonts
ln -sf "$TEX_HOME/distro/TeXfonts" TeXfonts
EOF

chmod +x "$TEX_HOME/distro/bin/mk_TeX_dir" "$TEX_HOME/distro/bin/mk_MF_dir"

# Create local directory links expected by TeX-FPC
mk_TeX_dir


# 1. Check where the TeXformats symlink is pointing:
ls -ld TeXformats

# 2. Check if plain.fmt actually exists anywhere in your build tree:
find "$TEX_HOME" -name "plain.fmt"

tex '&plain' test.tex

