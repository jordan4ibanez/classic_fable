import controls.mouse;
import core.memory;
import game.map;
import game.map_graphics;
import game.player;
import graphics.camera_handler;
import graphics.model_handler;
import graphics.texture_handler;
import math.vec2d;
import math.vec2i;
import math.vec3d;
import mods.api;
import raylib;
import std.conv;
import std.format;
import std.random;
import std.stdio;
import std.string;
import utility.window;

void main() {

	SetTraceLogLevel(TraceLogLevel.LOG_ERROR);

	Window.initialize();
	scope (exit) {
		Window.terminate();
	}

	CameraHandler.initialize();
	scope (exit) {
		CameraHandler.terminate();
	}

	TextureHandler.initialize();
	scope (exit) {
		TextureHandler.terminate();
	}

	ModelHandler.initialize();
	scope (exit) {
		ModelHandler.terminate();
	}

	Api.initialize();

	rlDisableBackfaceCulling();

	Mouse.lock();

	immutable int renderDistance = 16;
	foreach (immutable x; -renderDistance .. renderDistance) {
		foreach (immutable z; -renderDistance .. renderDistance) {
			if (vec2dDistance(Vec2d(), Vec2d(x, z)) <= renderDistance) {
				Map.debugGenerate(x, z);
			}
		}
	}

	auto rand = Random(unpredictableSeed());

	immutable ulong averager = 200;
	double[averager] GCcollection = 0;
	ulong index = 0;

	while (Window.shouldStayOpen()) {

		foreach (_; 0 .. uniform(1_000, 100_000, rand)) {
			Vec3d target;
			target.x = uniform(0.0, 48.0, rand);
			target.z = uniform(0.0, 16.0, rand);
			target.y = uniform(0.0, 256.0, rand);

			int blockID = uniform(0, 5, rand);

			Map.setBlockAtWorldPositionByID(target, blockID);
		}

		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);

		CameraHandler.begin();
		{
			Map.draw();

			// DrawCube(Vector3(0, 0, 0), 0.1, 0.1, 0.1, Colors.RED);
		}
		CameraHandler.end();

		DrawText(toStringz("FPS:" ~ to!string(GetFPS())), 10, 10, 30, Colors.BLACK);
		DrawText(toStringz("FPS:" ~ to!string(GetFPS())), 11, 11, 30, Colors.BLUE);

		GCcollection[index] = cast(double) GC.stats().usedSize / 1_000_000.0;

		double total = 0;
		foreach (size; GCcollection) {
			total += size;
		}
		total /= averager;

		DrawText(toStringz("Heap:" ~ format("%.2f", total) ~ "mb"), 10, 40, 30, Colors.BLACK);
		DrawText(toStringz("Heap:" ~ format("%.2f", total) ~ "mb"), 11, 41, 30, Colors.BLUE);

		index++;
		if (index >= averager) {
			index = 0;
		}
		// GC.disable();

		Vec3d pos = CameraHandler.getPosition();

		DrawText(toStringz("X:" ~ format("%.2f", pos.x)), 10, 70, 30, Colors.BLACK);
		DrawText(toStringz("X:" ~ format("%.2f", pos.x)), 11, 71, 30, Colors.BLUE);

		DrawText(toStringz("Y:" ~ format("%.2f", pos.y)), 10, 100, 30, Colors.BLACK);
		DrawText(toStringz("Y:" ~ format("%.2f", pos.y)), 11, 101, 30, Colors.BLUE);

		DrawText(toStringz("Z:" ~ format("%.2f", pos.z)), 10, 130, 30, Colors.BLACK);
		DrawText(toStringz("Z:" ~ format("%.2f", pos.z)), 11, 131, 30, Colors.BLUE);

		EndDrawing();
	}

}
