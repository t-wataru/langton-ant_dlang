import std.stdio;
import bindbc.sdl, bindbc.sdl.image;
import std.math;

char[4] getRGBAfromPixel(uint pixel)
{
	//SDL_PIXELFORMAT_ABGR8888用
	char[4] rgba;
	rgba[0] = pixel & 255;
	rgba[1] = pixel >> 8 & 255;
	rgba[2] = pixel >> 16 & 255;
	rgba[3] = pixel >> 24 & 255;
	return rgba;
}

uint getPixel(char[4] rgba)
{
	//SDL_PIXELFORMAT_ABGR8888用
	return (((256 * rgba[3] + rgba[2]) * 256 + rgba[1]) * 256 + rgba[0]);
}

class Field
{
	int[][] field;
	int w, h;
	this(int _w, int _h)
	{
		w = _w;
		h = _h;
		for (int field_x = 0; field_x < w; field_x++)
		{
			int[] tmp;
			for (int field_y = 0; field_y < h; field_y++)
			{
				tmp ~= 0;
			}
			field ~= tmp;
		}
	}
}

class Ant
{
	int x = 0, y = 0, r = 0, w = 0, h = 0;
	Field field;
	this(int _x, int _y, int _r, Field _field)
	{
		x = _x;
		y = _y;
		r = _r;
		field = _field;
	}

	void update()
	{
		int[][] move = [[1, 0], [0, 1], [-1, 0], [0, -1]];
		if (field.field[x][y])
			r++;
		else
			r--;
		r = (r + 4) % 4;
		x += move[r][0];
		y += move[r][1];
		if (x >= field.w)
			x = 0;
		if (x < 0)
			x = field.w - 1;
		if (y >= field.h)
			y = 0;
		if (y < 0)
			y = field.h - 1;
		field.field[x][y] ^= 1;
	}

}

class Display
{
	SDL_Window* window;
	SDL_Renderer* renderer;
	SDL_Surface* surface_black;
	SDL_Surface* surface_white;
	SDL_Texture* texture_black;
	SDL_Texture* texture_white;
	SDL_Rect rect;
	Field field;
	this(Field _field)
	{
		const SDLSupport ret = loadSDL("./SDL2.dll");
		if (ret != sdlSupport)
		{
			if (ret == SDLSupport.noLibrary)
			{
				"SDL shared library failed to load".writeln;
			}
			else if (SDLSupport.badLibrary)
			{
				`One or more symbols failed to load. The likely cause is that the
				shared library is for a lower version than bindbc-sdl was configured
				to load (via SDL_201, SDL_202, etc.)`.writeln;
			}
		}
		SDL_Init(SDL_INIT_VIDEO);
		// loadSDLImage();
		rect.w = 5;
		rect.h = 5;
		window = SDL_CreateWindow("Test", SDL_WINDOWPOS_CENTERED,
				SDL_WINDOWPOS_CENTERED, 1000, 1000, SDL_WINDOW_SHOWN);
		renderer = SDL_CreateRenderer(window, 1, cast(SDL_RendererFlags) 0);
		texture_black = SDL_CreateTextureFromSurface(renderer, SDL_LoadBMP("black.bmp"));
		texture_white = SDL_CreateTextureFromSurface(renderer, SDL_LoadBMP("white2.bmp"));
		field = _field;
	}

	void draw()
	{
		rect.x = 0;
		rect.y = 0;
		//SDL_RenderClear(renderer);

		foreach (int[] cell_line; field.field)
		{
			foreach (int cell; cell_line)
			{
				SDL_RenderCopy(renderer, [texture_white, texture_black][cell], null, &rect);
				rect.y += rect.h;
			}
			rect.x += rect.w;
			rect.y = 0;
		}
		SDL_RenderPresent(renderer);
	}

	void dirtyDraw(Ant[] ants)
	{
		rect.x = 0;
		rect.y = 0;
		// SDL_RenderClear(renderer);
		foreach (Ant ant; ants)
		{
			int cell = field.field[ant.x][ant.y];
			rect.x = ant.x * rect.w;
			rect.y = ant.y * rect.h;
			SDL_RenderCopy(renderer, [texture_white, texture_black][cell], null, &rect);
		}
		SDL_RenderPresent(renderer);
	}
}

void main()
{
	Field field = new Field(200, 200);
	Ant ant1 = new Ant(100, 100, 1, field);
	//Ant ant2 = new Ant(150,150,2,field);
	Display display = new Display(field);
	display.draw();

	for (int i = 0; i < 0000; i++)
	{
		ant1.update();
		//ant2.update();
	}

	bool running = true;
	while (running)
	{
		SDL_Event e;
		while (SDL_PollEvent(&e))
		{
			switch (e.type)
			{
			case SDL_KEYDOWN, SDL_QUIT:
				running = false;
				break;
			default:
				break;
			}
		}
		SDL_Delay(0);

		ant1.update();
		//ant2.update();
		// display.dirtyDraw([ant1]);
		display.draw();

	}

}
