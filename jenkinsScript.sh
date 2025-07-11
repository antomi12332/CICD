export PROJECT_NAME="$PROJECTNAME"
export SAMBA_DIR="/mnt/jenkins_build/"
export ANDROID="${PROJECT_NAME}Android"
export IOS="${PROJECT_NAME}iOS"
export LINUX="${PROJECT_NAME}Linux"
export MAC_OS="${PROJECT_NAME}MacOS"
export WEB="${PROJECT_NAME}Web"
export WINDOWS="${PROJECT_NAME}Windows"

## Web
mkdir -p ~/${WEB};
godot --headless --export-release "Web" ~/${WEB}/index.html;
cd ~/${WEB} && zip -r ${WEB}.zip ./*;
cp -rfv ~/${WEB}/${WEB}.zip ${SAMBA_DIR};
cp -rfv ~/${WEB}/${WEB}.zip ${WORKSPACE};
cd ~/${WEB} && rm -rf ${WEB}.zip ~/${WEB};

## Linux
cd ${WORKSPACE};
mkdir -p ~/$LINUX;
godot --headless --export-release 'Linux' ~/$LINUX/$LINUX.x86_64;
cd ~/${LINUX} && zip -r ${LINUX}.zip ./*;
cp -rfv ~/${LINUX}/${LINUX}.zip ${SAMBA_DIR};
cp -rfv ~/${LINUX}/${LINUX}.zip ${WORKSPACE};
cd ~/${LINUX} && rm -rf ${LINUX}.zip ~/${LINUX};

## MacOS
cd ${WORKSPACE};
mkdir -p ~/$MAC_OS;
godot --headless --export-release 'macOS' ~/$MAC_OS/$MAC_OS.zip;
cp -rfv ~/${MAC_OS}/${MAC_OS}.zip ${SAMBA_DIR};
cp -rfv ~/${MAC_OS}/${MAC_OS}.zip ${WORKSPACE};
cd ~/${MAC_OS} && rm -rf ${MAC_OS}.zip ~/${MAC_OS};

## Windows
cd ${WORKSPACE};
mkdir -p ~/$WINDOWS;
godot --headless --export-release "Windows Desktop" ~/$WINDOWS/$WINDOWS.exe;
cd ~/${WINDOWS} && zip -r ${WINDOWS}.zip ./*;
cp -rfv ~/${WINDOWS}/${WINDOWS}.zip ${SAMBA_DIR};
cp -rfv ~/${WINDOWS}/${WINDOWS}.zip ${WORKSPACE};
cd ~/${WINDOWS} && rm -rf ${WINDOWS}.zip ~/${WINDOWS};

# Upload to itch
cd ${WORKSPACE}/playwright;
npm ci;
npx playwright install;
CI=true npx playwright test --workers=1 tests/uploadItch.spec.ts;