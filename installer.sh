#!/bin/bash

echo -e "**************\nStarting PS installer...\n"
sleep 1

cameraraw=1
echo -e "**************\nWould you like to install Adobe Camera Raw at the end?"
read -p "(1 - Yes, 0 - No): " cameraraw
sleep 1

vdk3d=1
echo -e "**************\nWould you like to install vdk3d proton?"
read -p "(1 - Yes, 0 - No): " vdk3d
sleep 1

echo -e "**************\nMaking PS prefix...\n"
sleep 1
rm -rf $PWD/PS-Prefix
mkdir $PWD/PS-Prefix/
sleep 1

echo -e "**************\nDownloading winetricks and making executable if not already so...\n"
sleep 1
wget -nc https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sleep 1

echo -e "**************\nDownloading Photoshop, CameraRaw, and allredist files if not already downloaded...\n"
sleep 1

mkdir -p Installers

if ! [ -f Installers/allredist.tar.xz ]; then
  if [ $cameraraw = 1 ]; then
    curl -L "https://drive.google.com/uc?export=download&id=1qcmyHzWerZ39OhW0y4VQ-hOy7639bJPO" > Installers/allredist.tar.xz
  fi
else
  echo -e "The file allredist.tar.xz exists"
fi

if ! [ -f Installers/AdobePhotoshop2021.tar.xz ]; then
  curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/AdobePhotoshop2021.tar.xz" > Installers/AdobePhotoshop2021.tar.xz
else
  echo -e "The file AdobePhotoshop2021.tar.xz exists"
fi

if ! [ -f Installers/CameraRaw_12_2_1.exe ]; then
  curl -L "https://download.adobe.com/pub/adobe/photoshop/cameraraw/win/12.x/CameraRaw_12_2_1.exe" > Installers/CameraRaw_12_2_1.exe
else
  echo -e "The file CameraRaw_12_2_1.exe exists\n"
fi

sleep 1

echo -e "**************\nExtracting files...\n"
sleep 1
rm -fr Installers/allredist
rm -fr "Installers/Adobe Photoshop 2021"
tar -xvf Installers/AdobePhotoshop2021.tar.xz -C Installers/
mkdir Installers/allredist
tar -xvf Installers/allredist.tar.xz -C Installers/
sleep 1


echo -e "**************\nBooting & creating new prefix\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ wineboot
sleep 1

echo -e "**************\nSetting win version to win10\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ ./winetricks win10
sleep 1

echo -e "**************\nInstalling & configuring winetricks components...\n"
WINEPREFIX=$PWD/PS-Prefix/ ./winetricks fontsmooth=rgb gdiplus msxml3 msxml6 atmlib corefonts dxvk
sleep 1

echo -e "**************\nInstalling redist components...\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2010/vcredist_x64.exe /q /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2010/vcredist_x86.exe /q /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2012/vcredist_x86.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2012/vcredist_x64.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2013/vcredist_x86.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2013/vcredist_x64.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2019/VC_redist.x64.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine Installers/allredist/redist/2019/VC_redist.x86.exe /install /quiet /norestart
sleep 1


if [ $vdk3d = "1" ]; then
  echo -e "**************\nInstalling vdk3d proton...\n"
  sleep 1
  WINEPREFIX=$PWD/PS-Prefix/ sh Installers/allredist/setup_vkd3d_proton.sh install
  sleep 1
fi

echo -e "**************\nMaking PS directory and copying files...\n"
sleep 1
mkdir $PWD/PS-Prefix/drive_c/Program\ Files/Adobe
mv Installers/Adobe\ Photoshop\ 2021 $PWD/PS-Prefix/drive_c/Program\ Files/Adobe/Adobe\ Photoshop\ 2021
sleep 1

echo -e "**************\nCopying launcher files...\n"

sleep 1
prefix=$PWD/PS-Prefix
pwd=$PWD
rm -f launcher.sh
echo -e "#\!/bin/bash\ncd \"$PWD/PS-Prefix/drive_c/Program Files/Adobe/Adobe Photoshop 2021/\" && WINEPREFIX=\"$prefix\" wine photoshop.exe" >> launcher.sh
chmod +x launcher.sh
rm -f photoshop.desktop
echo -e "[Desktop Entry]\nName=Photoshop CC\nExec=cd \"$PWD/PS-Prefix/drive_c/Program Files/Adobe/Adobe Photoshop 2021/\" && WINEPREFIX=\"$prefix\" wine photoshop.exe\nType=Application\nComment=Photoshop CC 2021\nCategories=Graphics;2DGraphics;RasterGraphics;GTK;\nIcon=$PWD/Images/photoshop.svg\nStartupWMClass=photoshop.exe\nMimeType=image/png;image/psd;image;" >> photoshop.desktop
chmod +x photoshop.desktop
mv photoshop.desktop ~/.local/share/applications/photoshop.desktop
rm -rf Installers/allredist
rm winetricks
sleep 1

if [ $cameraraw = "1" ]; then
  echo -e "**************\nInstalling Adobe Camera Raw, please follow the instructions on the installer...\n"
  sleep 1
  WINEPREFIX=$PWD/PS-Prefix/ wine Installers/CameraRaw_12_2_1.exe
  sleep 1
fi

echo -e "**************\nAdobe Photoshop CC 2021 Installed!\n"
echo -e "Use this command to run Photoshop if the launcher and desktop files don't work, then make your own desktop entry:\n\ncd \"$PWD/PS-Prefix/drive_c/Program Files/Adobe/Adobe Photoshop 2021/\" && WINEPREFIX=\"$prefix\" wine photoshop.exe"
