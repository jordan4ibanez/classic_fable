import graphics.camera_handler;
import graphics.model_handler;
import graphics.texture_handler;
import math.vec2d;
import math.vec3d;
import raylib;
import std.stdio;

void main() {
	// call this before using raylib
	validateRaylibBinding();
	InitWindow(1000, 1000, "Classic Fable Prototyping");
	scope (exit) {
		CloseWindow();
	}
	SetTargetFPS(60);

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

	rlDisableBackfaceCulling();

	float[] vertices;

	void makeCube(const Vec3d min, const Vec3d max) {

		assert(min.x >= 0 && min.y >= 0 && min.z >= 0, "min is out of bounds");
		assert(max.x <= 1 && max.y <= 1 && max.z <= 1, "max is out of bounds");

		pragma(inline, true)
		void makeQuad(
			const Vec3d topLeft, /*0*/
			const Vec3d bottomLeft, /*1*/
			const Vec3d bottomRight, /*2*/
			const Vec3d topRight /*3*/ ) {
			// Tri 1.
			vertices ~= topLeft.toFloatArray(); // 0
			vertices ~= bottomLeft.toFloatArray(); // 1
			vertices ~= bottomRight.toFloatArray(); // 2
			// Tri 2.
			vertices ~= bottomRight.toFloatArray(); // 2
			vertices ~= topRight.toFloatArray(); // 3
			vertices ~= topLeft.toFloatArray(); // 0
		}

		/*
		This is kind of weird.

		Right handed means that you're looking forwards pointing at -Z.
		Left is -X, right is +x.

		But the math is using actual player coordinates so that means that Z is technically inverted.
		But we math that right out and pretend it's normal.

		So the chunk will generate behind you and to your right.
		*/

		// Front.
		makeQuad(
			Vec3d(max.x, max.y, min.z),
			Vec3d(max.x, min.y, min.z),
			Vec3d(min.x, min.y, min.z),
			Vec3d(min.x, max.y, min.z)
		);

		// Back.
		makeQuad(
			Vec3d(min.x, max.y, max.z),
			Vec3d(min.x, min.y, max.z),
			Vec3d(max.x, min.y, max.z),
			Vec3d(max.x, max.y, max.z)
		);

		// Left.
		makeQuad(
			Vec3d(min.x, max.y, min.z),
			Vec3d(min.x, min.y, min.z),
			Vec3d(min.x, min.y, max.z),
			Vec3d(min.x, max.y, max.z)
		);

		// Right.
		makeQuad(
			Vec3d(max.x, max.y, max.z),
			Vec3d(max.x, min.y, max.z),
			Vec3d(max.x, min.y, min.z),
			Vec3d(max.x, max.y, min.z)
		);

		// Top of top points towards -Z.
		// Top.
		makeQuad(
			Vec3d(min.x, max.y, min.z),
			Vec3d(min.x, max.y, max.z),
			Vec3d(max.x, max.y, max.z),
			Vec3d(max.x, max.y, min.z)
		);

		// Top of bottom points towards -Z.
		// Bottom.
		makeQuad(
			Vec3d(max.x, min.y, min.z),
			Vec3d(max.x, min.y, max.z),
			Vec3d(min.x, min.y, max.z),
			Vec3d(min.x, min.y, min.z)
		);
	}

	makeCube(Vec3d(0, 0, 0), Vec3d(1, 1, 1));

	TexPoints blah = TextureHandler.getPoints("testing.png");

	float[] textureCoordinates = [
		// Front.
		blah.topLeft.x, blah.topLeft.y, // 0
		blah.bottomLeft.x, blah.bottomLeft.y, // 1
		blah.bottomRight.x, blah.bottomRight.y, // 2

		blah.bottomRight.x, blah.bottomRight.y, // 2
		blah.topRight.x, blah.topRight.y, // 3
		blah.topLeft.x, blah.topLeft.y, // 0

		// Back.
		blah.topLeft.x, blah.topLeft.y, // 0
		blah.bottomLeft.x, blah.bottomLeft.y, // 1
		blah.bottomRight.x, blah.bottomRight.y, // 2

		blah.bottomRight.x, blah.bottomRight.y, // 2
		blah.topRight.x, blah.topRight.y, // 3
		blah.topLeft.x, blah.topLeft.y, // 0

		// Left.
		blah.topLeft.x, blah.topLeft.y, // 0
		blah.bottomLeft.x, blah.bottomLeft.y, // 1
		blah.bottomRight.x, blah.bottomRight.y, // 2

		blah.bottomRight.x, blah.bottomRight.y, // 2
		blah.topRight.x, blah.topRight.y, // 3
		blah.topLeft.x, blah.topLeft.y, // 0

		// Right.
		blah.topLeft.x, blah.topLeft.y, // 0
		blah.bottomLeft.x, blah.bottomLeft.y, // 1
		blah.bottomRight.x, blah.bottomRight.y, // 2

		blah.bottomRight.x, blah.bottomRight.y, // 2
		blah.topRight.x, blah.topRight.y, // 3
		blah.topLeft.x, blah.topLeft.y, // 0

		// Top.
		blah.topLeft.x, blah.topLeft.y, // 0
		blah.bottomLeft.x, blah.bottomLeft.y, // 1
		blah.bottomRight.x, blah.bottomRight.y, // 2

		blah.bottomRight.x, blah.bottomRight.y, // 2
		blah.topRight.x, blah.topRight.y, // 3
		blah.topLeft.x, blah.topLeft.y, // 0

		// Bottom.
		blah.topLeft.x, blah.topLeft.y, // 0
		blah.bottomLeft.x, blah.bottomLeft.y, // 1
		blah.bottomRight.x, blah.bottomRight.y, // 2

		blah.bottomRight.x, blah.bottomRight.y, // 2
		blah.topRight.x, blah.topRight.y, // 3
		blah.topLeft.x, blah.topLeft.y, // 0
	];

	ModelHandler.newModelFromMesh("triangle", vertices, textureCoordinates);

	while (!WindowShouldClose()) {
		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);

		DrawText("Hello, World!", 10, 10, 28, Colors.BLACK);

		CameraHandler.begin();

		{

			ModelHandler.draw("triangle", Vec3d(0, 0, 0));

			// DrawCube(Vector3(0, 0, -5), 1, 1, 1, Colors.RED);
		}

		CameraHandler.end();
		EndDrawing();
	}

}
