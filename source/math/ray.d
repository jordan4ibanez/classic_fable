module math.ray;

// import hashset;
import math.aabb;
import math.vec3d;
import math.vec3i;
import raylib;
import std.algorithm;
import std.datetime.stopwatch;
import std.math;
import std.stdio;

// private static HashSet!Vec3i old;
// private static HashSet!Vec3i wideBandPoints;
private static bool[Vec3i] wideBandPoints;

void ray(const Vec3d startingPoint, const Vec3d endingPoint) {

    //? This might be one of the strangest and overcomplicated collision voxel raycasting algorithms ever created.

    // https://www.geeksforgeeks.org/bresenhams-algorithm-for-3-d-line-drawing/
    // http://www.cse.yorku.ca/~amana/research/grid.pdf
    // https://en.wikipedia.org/wiki/Bresenham's_line_algorithm
    // https://stackoverflow.com/a/28786538
    // https://deepnight.net/tutorial/bresenham-magic-raycasting-line-of-sight-pathfinding/
    // https://gdbooks.gitbooks.io/3dcollisions/content/Chapter3/raycast_aabb.html

    Vec3d start = startingPoint;
    Vec3d end = endingPoint;

    // Bump it out of strange floating point issues.
    if (start.x % 1.0 == 0) {
        // writeln("bump 1");
        start.x += 0.00001;
    }
    if (start.y % 1.0 == 0) {
        // writeln("bump 2");
        start.y += 0.00001;
    }
    if (start.z % 1.0 == 0) {
        // writeln("bump 3");
        start.z += 0.00001;
    }

    if (end.x % 1.0 == 0) {
        // writeln("bump 4");
        end.x += 0.00001;
    }
    if (end.y % 1.0 == 0) {
        // writeln("bump 5");
        end.y += 0.00001;
    }
    if (end.z % 1.0 == 0) {
        // writeln("bump 6");
        end.z += 0.00001;
    }

    //? Ultra wideband.

    // wideBandPoints.clear();

    double distance = vec3dDistance(start, end);

    auto sw = StopWatch(AutoStart.yes);
    const Vec3d direction = vec3dNormalize(vec3dSubtract(end, start));

    double thisDistance = 0.01;

    Vec3i thisPosition;
    Vec3d floatingPosition;

    Vec3i thisLocal;
    Vec3d pointDist;
    Vec3d localDist;

    int counter = 0;

    static const Vec3i[26] dirs = [
        Vec3i(-1, -1, -1),
        Vec3i(-1, -1, 0),
        Vec3i(-1, -1, 1),
        Vec3i(-1, 0, -1),
        Vec3i(-1, 0, 0),
        Vec3i(-1, 0, 1),
        Vec3i(-1, 1, -1),
        Vec3i(-1, 1, 0),
        Vec3i(-1, 1, 1),
        Vec3i(0, -1, -1),
        Vec3i(0, -1, 0),
        Vec3i(0, -1, 1),
        Vec3i(0, 0, -1),
        Vec3i(0, 0, 1),
        Vec3i(0, 1, -1),
        Vec3i(0, 1, 0),
        Vec3i(0, 1, 1),
        Vec3i(1, -1, -1),
        Vec3i(1, -1, 0),
        Vec3i(1, -1, 1),
        Vec3i(1, 0, -1),
        Vec3i(1, 0, 0),
        Vec3i(1, 0, 1),
        Vec3i(1, 1, -1),
        Vec3i(1, 1, 0),
        Vec3i(1, 1, 1),
    ];

    while (thisDistance < (distance + 0.01)) {

        floatingPosition.x = (direction.x * thisDistance) + start.x;
        floatingPosition.y = (direction.y * thisDistance) + start.y;
        floatingPosition.z = (direction.z * thisDistance) + start.z;

        thisPosition.x = cast(int) floor(floatingPosition.x);
        thisPosition.y = cast(int) floor(floatingPosition.y);
        thisPosition.z = cast(int) floor(floatingPosition.z);

        pointDist.x = endingPoint.x - thisPosition.x;
        pointDist.y = endingPoint.y - thisPosition.y;
        pointDist.z = endingPoint.z - thisPosition.z;
        const double pointDistance = sqrt(
            pointDist.x * pointDist.x + pointDist.y * pointDist.y + pointDist.z * pointDist.z);

        for (uint i = 0; i < 26; i++) {
            const Vec3i* thisDir = dirs.ptr + i;

            counter++;

            thisLocal.x = thisPosition.x + thisDir.x;
            thisLocal.y = thisPosition.y + thisDir.y;
            thisLocal.z = thisPosition.z + thisDir.z;

            localDist.x = endingPoint.x - thisPosition.x;
            localDist.y = endingPoint.y - thisPosition.y;
            localDist.z = endingPoint.z - thisPosition.z;
            
            const localDistance = sqrt(
                localDist.x * localDist.x + localDist.y * localDist.y + localDist.z * localDist.z);

            if (localDistance <= pointDistance) {
                // wideBandPoints[thisLocal] = true;
            }
        }

        thisDistance += 1.0;
    }

    // wideBandPoints.rehash();

    // writeln("did ", counter, " counts");

    // wideBandPoints.rehash();

    // AABB thisBox = AABB();
    // foreach (const ref key; wideBandPoints) {

    // thisBox.min.x = key.x;
    // thisBox.min.y = key.y;
    // thisBox.min.z = key.z;

    // thisBox.max.x = key.x + 1.0;
    // thisBox.max.y = key.y + 1.0;
    // thisBox.max.z = key.z + 1.0;

    // if (raycastBool(start, direction, thisBox)) {

    // DrawCube(Vec3d(cast(double) key.x + 0.5, cast(double) key.y + 0.5, cast(double) key.z + 0.5)
    //         .toRaylib(), 1, 1, 1, Colors.ORANGE);

    // DrawCubeWires(Vec3d(cast(double) key.x + 0.5, cast(double) key.y + 0.5, cast(double) key.z + 0.5)
    //         .toRaylib(), 1, 1, 1, Colors.BLACK);
    // }
    // }

    // HashSet!Vec3d testedPoints;

    // import raylib;

    // DrawLine3D(startingPoint.toRaylib(), endingPoint.toRaylib(), Colors.BLUE);

    writeln("took: ", cast(double) sw.peek().total!"usecs", " usecs");
}

// https://gdbooks.gitbooks.io/3dcollisions/content/Chapter3/raycast_aabb.html 
pragma(inline)
@safe @nogc
bool raycastBool(const ref Vec3d origin, const ref Vec3d dir, const ref AABB aabb) {
    const double t1 = (aabb.min.x - origin.x) / dir.x;
    const double t2 = (aabb.max.x - origin.x) / dir.x;

    const double t3 = (aabb.min.y - origin.y) / dir.y;
    const double t4 = (aabb.max.y - origin.y) / dir.y;

    const double t5 = (aabb.min.z - origin.z) / dir.z;
    const double t6 = (aabb.max.z - origin.z) / dir.z;

    const double aMin = min(t1, t2);
    const double aMax = max(t1, t2);
    const double bMin = min(t3, t4);
    const double bMax = max(t3, t4);
    const double cMin = min(t5, t6);
    const double cMax = max(t5, t6);
    const double eMin = min(aMax, bMax);
    const double eMax = max(aMin, bMin);

    const double tmin = max(eMax, cMin);
    const double tmax = min(eMin, cMax);

    // if tmax < 0, ray (line) is intersecting AABB, but whole AABB is behind us.
    // if tmin > tmax, ray doesn't intersect AABB.
    if (tmax < 0 || tmin > tmax) {
        return false;
    }

    return true;
}
