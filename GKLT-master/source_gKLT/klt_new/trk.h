#include <vector>

typedef struct
{
	int x; //x coordinate, zero based
	int y; //y coordinate, zero based
	int t; //time stamp, zero based
} TrkPoint; //point on the track

typedef std::vector<TrkPoint> Trk; //single track
typedef std::vector<Trk> TrkSet; //a set of tracks

typedef struct
{
	int r;
	int g;
	int b;
}Color;

/*class Color{
private:
	int d_r;
	int d_g;
	int d_b;
public:
	Color(int r0, int g0, int b0);
	int r();
	int g();
	int b();
};*/

