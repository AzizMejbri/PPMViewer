PPM Viewer - C3 + SDL3
A simple PPM (Portable Pixmap) image viewer written in C3 using SDL3 for graphics.

🚀 Quick Start
1. Install Requirements
Linux (Ubuntu/Debian):

```bash
sudo apt-get install git c3c
sudo apt-get install libsdl3-dev
```


Linux (Fedora):

```bash
sudo dnf install git clang SDL3-devel
```


Linux (Arch):
```bash
sudo pacman -S sdl3
```


2. Get C3 Compiler
```
bash
git clone https://github.com/c3lang/c3c
cd c3c
make
sudo make install  # or add c3c to your PATH
```

on Arch you can simply 

```bash
sudo pacman -S c3c
```

3. Build & Run
bash
# Clone this repository
git clone [https://github.com/AzizMejbri/PPMViewer]
cd PPMViewer

# Build
c3c build -l SDL3

# Run (shows default image)

View Your Own PPM Image
```bash
build/PPM_Viewer your_image
```


✅ Supported Features
✅ PPM P6 format (binary RGB images)

✅ Images with 255 max colors

✅ Automatic window sizing

✅ Fast pixel-by-pixel rendering

🔧 Troubleshooting
Image Not Showing?
Make sure your image is PPM P6 format (binary, not ASCII)

Check the first 3 bytes: they should be P6\n

Max color value should be 255

Still Having Issues?
Check SDL3 installation: sdl3-config --version

Verify C3 compiler: c3c --version

Check file permissions on your PPM image

📋 Requirements
C3 compiler (c3c)

SDL3 library

PPM P6 format image (optional)

🐛 Common Issues
Error: "Library 'sdl3' not found"

Install SDL3 development packages

Use -L and -I flags to specify SDL3 location

Image appears wrong colors

Ensure your image is PPM P6 not P3 

Check max color value is 255

Tip: You can convert images to PPM P6 format using ImageMagick:

```bash
convert your-image.png -compress none your-image.ppm
```
Made with ❤️ using C3 + SDL3
