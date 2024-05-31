#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <stdint.h>
#include <SDL2/SDL.h>
#include "mandelbrot.h"


int main()
{
    uint16_t width = 1000;
    uint16_t height = 1000;
    uint16_t max_iterations = 400;
    uint16_t out_point = 3;
    double re_offset = -0.5;
    double im_offset = 0.0;
    double zoom = 1.0;

    // init SDL
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) return -1;

    // create some stuff to make it work
    SDL_Window *window = SDL_CreateWindow("Benoit Mandelbrot Heritage", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_ALLOW_HIGHDPI);
    if (window == NULL) {
        SDL_Quit();
        return -1;
    }
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == NULL) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    uint8_t* buf = (uint8_t*)malloc(width * height * 4 * sizeof(uint8_t*));

    // Generate Mandelbrot set
    mandelbrot(buf, width, height, max_iterations, out_point, zoom, re_offset, im_offset);

    SDL_Surface* surface = SDL_CreateRGBSurfaceFrom(buf, width, height, 32, width * 4, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);

    int quit = 0;
    SDL_Event e;
    while (!quit) {
        int is_redraw_needed = 0;
        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_QUIT) {
                quit = 1;
            }
            else if (e.type == SDL_MOUSEWHEEL) {
                int mouse_x, mouse_y;
                SDL_GetMouseState(&mouse_x, &mouse_y);
                double re_before_zoom = ((double)mouse_x - width / 2.0) * 4.0 / (width * zoom) + re_offset;
                double im_before_zoom = ((double)mouse_y - height / 2.0) * 4.0 / (height * zoom) + im_offset;

                if (e.wheel.y > 0) zoom *= 1.1;
                else if (e.wheel.y < 0) zoom /= 1.1;

                double re_after_zoom = ((double)mouse_x - width / 2.0) * 4.0 / (width * zoom) + re_offset;
                double im_after_zoom = ((double)mouse_y - height / 2.0) * 4.0 / (height * zoom) + im_offset;

                re_offset += (re_before_zoom - re_after_zoom);
                im_offset += (im_before_zoom - im_after_zoom);
                is_redraw_needed = 1;
            }
            else if (e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT)
            {
                int mouse_x = e.button.x;
                int mouse_y = e.button.y;

                re_offset += ((double) mouse_x - width / 2.0) * 4.0 / (width * zoom);
                im_offset += ((double) mouse_y - height / 2.0) * 4.0 / (height * zoom);
                is_redraw_needed = 1;
            }
        }
        if (is_redraw_needed)
        {
            mandelbrot(buf, width, height, max_iterations, out_point, zoom, re_offset, im_offset);
            SDL_Surface* surface = SDL_CreateRGBSurfaceFrom(buf, width, height, 32, width * 4, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
            SDL_DestroyTexture(texture);
            texture = SDL_CreateTextureFromSurface(renderer, surface);
            SDL_FreeSurface(surface);
        }
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyTexture(texture);
    free(buf);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}