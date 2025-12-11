module ppm_viewer;
import std::io;
import std::io::file;
import sdl3;


faultdef FILEOPEN_ERR;


fn void set_pixel(Surface* surface, Palette* palette, uint x, uint y, char r, char g, char b, char a = 255 ){ 
  char* pixel = surface.pixels + y * surface.pitch + x * 4;
  
  uint color = surface.format.get_details().map_rgba(palette, r, g, b, a); 

  *(uint *)pixel = color;

}

fn void set_pixels(Surface* surface, Palette* palette, uint width, uint height, char* buffer ){   
  surface.lock();
  
  for(uint y = 0; y < height; y++) {
    for (uint x = 0; x < width; x++) {
      uint ppm_index = (y * width + x) * 3;
      
      // Read RGB values from PPM buffer
      char r = buffer[ppm_index];
      char g = buffer[ppm_index + 1];
      char b = buffer[ppm_index + 2];
      
      // Set pixel in surface (converts to RGBA8888)
      set_pixel(surface, palette, x, y, r, g, b, 255);
    }
  }
  
  surface.unlock();
}


fn bool Texture.update_from_surface(Texture* texture, Surface* surface) {

  float tex_w, tex_h;
  texture.get_size(&tex_w, &tex_h);
    
  void* pixels;
  int pitch;
  usz bbp = surface.format.get_details().bytes_per_pixel;
    
  if (texture.lock(null, &pixels, &pitch) == true) {
    for (int y = 0; y < surface.h; y++) {
      char* src_row = (char*)surface.pixels + (y * surface.pitch);
      char* dst_row = (char*)pixels + (y * pitch);
      mem::copy(dst_row, src_row, surface.w * bbp);
    }
    texture.unlock();
    return true;
  }
  return false;
}

fn int main(String[] args)
{
  if (args.len != 2){
    io::printfn("\e[31mUsage: %s <File>\e[m\n", args[0]);
    return 1;
  }
  File f = file::open(args[1], "rb")!!;

  ulong file_size = f.seek(0, Seek.END)!!;
    
  io::printfn("File size: %s bytes", file_size);
    
  f.seek(0)!!;

  char[] buffer = mem::temp_array(char, file_size);
  f.read(buffer)!!;


  if (catch close_err = f.close()) {
      io::printfn("Warning: Failed to close file: %s", close_err);
  }

// We try with raw PPM P6 first for its simplicity
  assert(buffer[0] == 'P' && buffer[1] == '6' && buffer[2] == '\n', 
  "This file does not contain the proper PPM P6 Header!");
  
  uint i = 3;
  uint width = 0;
  uint height = 0;
  uint colorspace = 0;
  while ( buffer[i] != ' ' ){
    width = width * 10 + buffer[i] - '0';
    i++;
  } 
  i++;

  while( buffer[i] != '\n' ){
    height = height * 10 + buffer[i] - '0';
    i++;
  }
  i++;
  
  while( buffer[i] != '\n' ){
    colorspace = colorspace * 10 + buffer[i] - '0';
    i++;
  }
  i++;

  io::printfn("width: %s\nheight: %s\ncolorspace: %s\n", width, height, colorspace);

  sdl3::init(sdl3::subsystem::VIDEO);
  defer sdl3::quit();

  sdl3::Window* win = sdl3::create_window("PPM Viewer", 
    width,
    height, 
    sdl3::window_flags::RESIZABLE | sdl3::window_flags::BORDERLESS
  );
  defer win.destroy();
  
  Surface* surface = sdl3::create_surface(width, height, sdl3::pixel_format::RGBA8888);
  defer surface.destroy();

  Palette* palette = sdl3::create_palette(256);
  defer palette.destroy();


  set_pixels(surface, palette, width, height, buffer);


  Renderer* renderer = sdl3::create_renderer(win, null);
  defer renderer.destroy();

  Texture* texture = sdl3::create_texture(
    renderer,
    sdl3::pixel_format::RGBA8888,
    sdl3::texture_access::STREAMING,  // ← THIS IS CRITICAL!
    width,
    height
  );
  defer texture.destroy();
  renderer.clear();

  texture.update_from_surface(surface);
  sdl3::render_texture(renderer, texture, null, null);

  renderer.present();

 
  
  sdl3::Event event;
  bool run = true;
  while (run){
    event.poll();
    switch(event.type){
      case sdl3::event_type::QUIT:
        run = false;
        break;
      case sdl3::event_type::WINDOW_CLOSE_REQUESTED:
        run = false;
        break;
      default:
        break;
    }
     
    sdl3::delay(66);
  }



	return 0;
}
