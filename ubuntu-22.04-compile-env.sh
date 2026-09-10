sudo apt update
sudo apt install -y fpc build-essential wget unzip ed

export TEX_HOME="$HOME/tex-fpc-build"
mkdir -p "$TEX_HOME"
cd "$TEX_HOME"

# Add the target binaries and TeX-FPC helper scripts to PATH
export PATH="$TEX_HOME/distro/bin:$TEX_HOME/tex-fpc/shell:$PATH"
