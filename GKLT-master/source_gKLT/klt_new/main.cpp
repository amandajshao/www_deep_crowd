//// main.cpp : Defines the entry point for the console application.
////
//
////#include <stdio.h>  // printf
////
//#include <cstdio>
//using namespace std;
//
extern "C" {
	void RunExample1();
	void RunExample2();
	void RunExample3();
	void RunExample4();
	void RunExample5();
}
//
//int main(int argc, char* argv[])
//{
//	// select which example to run here
//	const int which = 3;
//
//	// run the appropriate example
//	switch (which) {
//	case 1:  RunExample1();  break;
//	case 2:  RunExample2();  break;
//	case 3:  RunExample3();  break;
//	case 4:  RunExample4();  break;  // Note:  example4 reads output from example 3
//	case 5:  RunExample5();  break;
//	default:  printf("There is no example number %d\n", which);
//	}
//	return 0;
//}

#include "stdafx.h"
#include "cv.h"
#include "highgui.h"
#include <string.h>
#include <assert.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>
#include <vector>
#include "trk.h"
#include "klt.h"

#include <stdlib.h>
#include <stdio.h>
#include "pnmio.h"

using namespace std;

#define REPLACE
#define FOREGROUND_THRESHOLD 26
#define MAX_FEATURE_NUMBER 4000

int _tmain(int argc, _TCHAR* argv[])

{
  unsigned char *img1, *img2;
  
  char fnamein[100], fnameout[100];
  KLT_TrackingContext tc;
  KLT_FeatureList fl;
  KLT_FeatureTable ft;
  const int nFeatures = 500, nFrames = 10;

  int fgIndicator[nFeatures];
  int trkIndex[nFeatures];
  int curMaxTrk=0;

  int ncols, nrows;
  int i;
   
    IplImage *bgIm, *img1_cv;
	TrkSet trkList;
	Trk single_trk;
	TrkPoint single_point;
	vector<int> trkIds; //track ids of the current feature points being tracked
	vector<int> newTrkIds;
	CvSize frame_size;
	int startFrame = 0, endFrame = 640, number_of_features, number_of_fg_features, x, y, k,m;
	char imageName[100];
	CvRNG rng_state = cvRNG(0xffffffff);
	std::vector<Color> colors;
	
	Color c;
	CvScalar line_color;
	int line_thickness = 1, radius = 3;	
	CvPoint center; 

	//all the good features detected on frame 1
    CvPoint2D32f frame1_features[MAX_FEATURE_NUMBER]; 
	
	//all the good foreground features detection on frame 1
    CvPoint2D32f frame1_fg_features[MAX_FEATURE_NUMBER]; 

	for (i=0;i<nFeatures;i++)
	{
		fgIndicator[i]=0;
		trkIndex[i]=0;
	}

    bgIm = cvLoadImage("I:\\data\\grand\\bg.pgm", CV_LOAD_IMAGE_GRAYSCALE);


  tc = KLTCreateTrackingContext();
  fl = KLTCreateFeatureList(nFeatures);
  ft = KLTCreateFeatureTable(nFrames, nFeatures);
  tc->sequentialMode = TRUE;
  tc->writeInternalImages = FALSE;
  tc->affineConsistencyCheck = -1;  /* set this to 2 to turn on affine consistency check */
 
  //img1 = pgmReadFile("I:\\data\\grand\\PGM\\00000.pgm", NULL, &ncols, &nrows);
  img1_cv = cvLoadImage("I:\\data\\grand\\PGM\\00000.pgm", CV_LOAD_IMAGE_GRAYSCALE);
  img2 = (unsigned char *) malloc(ncols*nrows*sizeof(unsigned char));

  KLTSelectGoodFeatures(tc, img1, ncols, nrows, fl);
  	//only keep those features which are foreground pixels
	number_of_fg_features = 0;
	trkList.clear();
	trkIds.clear();
	for (k = 0; k < nFeatures; k++){
        x = (int) (fl->feature[k]->x+0.5);
		y = (int) (fl->feature[k]->y+0.5);
		if (abs(CV_IMAGE_ELEM(img1_cv, uchar, y, x) - CV_IMAGE_ELEM(bgIm, uchar, y, x)) > FOREGROUND_THRESHOLD)
		{
			
            fgIndicator[k]=1;
            trkIndex[k]=curMaxTrk;
			

			single_point.x = (int) (fl->feature[k]->x+0.5);
			single_point.y = (int) (fl->feature[k]->y+0.5);
			single_point.t = startFrame;
			single_trk.clear();
			single_trk.push_back(single_point);
			trkList.push_back(single_trk);
			curMaxTrk++;
		}

	}


  KLTStoreFeatureList(fl, ft, 0);
  KLTWriteFeatureListToPPM(fl, img1, ncols, nrows, "I:\\data\\grand\\klt_result\\feat0.ppm");
  newTrkIds.clear();
  for (i = 1 ; i < nFrames ; i++)  {
    sprintf(fnamein, "I:\\data\\grand\\PGM\\%05d.pgm", i);
    pgmReadFile(fnamein, img2, &ncols, &nrows);
    KLTTrackFeatures(tc, img1, img2, ncols, nrows, fl);
	newTrkIds.clear();
		


#ifdef REPLACE
    KLTReplaceLostFeatures(tc, img2, ncols, nrows, fl);
    img1_cv = cvLoadImage("I:\\data\\grand\\PGM\\%05d.pgm", CV_LOAD_IMAGE_GRAYSCALE);
    for (k = 0; k < nFeatures; k++){

		
        if ( fl->feature[k]->val== 0) 
		{
	    if (fgIndicator[k]==1)
		{
		  single_point.x=int(fl->feature[k]->x+0.5);
	      single_point.y=int(fl->feature[k]->y+0.5);
          single_point.t = i;
		  trkList[trkIndex[k]].push_back(single_point);
		}
		}
		else
		{
			x = (int) (fl->feature[k]->x+0.5);
		    y = (int) (fl->feature[k]->y+0.5);
			if (abs(CV_IMAGE_ELEM(img1_cv, uchar, y, x) - CV_IMAGE_ELEM(bgIm, uchar, y, x)) > FOREGROUND_THRESHOLD)
			{
			  curMaxTrk++;
			  fgIndicator[k]=1;
			  trkIndex[k]=curMaxTrk;
			}
		
		}
	}


#endif



    KLTStoreFeatureList(fl, ft, i);
    sprintf(fnameout, "I:\\data\\grand\\klt_result\\feat%05d.ppm", i);
    KLTWriteFeatureListToPPM(fl, img2, ncols, nrows, fnameout);



  }
  FILE *fileptr;
  fileptr = fopen("I:\\data\\grand\\tracks_KLT.txt", "w");
		for (i = 0; i < trkList.size(); i++){
			fprintf(fileptr,"%d	", trkList[i].size());
			for (k = 0; k < trkList[i].size(); k++){
				fprintf(fileptr, "(%d,%d,%d)", trkList[i][k].x, trkList[i][k].y, trkList[i][k].t);
			}
			fprintf(fileptr, "\n");
		}
  fclose(fileptr); 


  //KLTWriteFeatureTable(ft, "I:\\data\\grand\\klt_result\\features.txt", "%5.1f");
  //KLTWriteFeatureTable(ft, "I:\\data\\grand\\klt_result\\features.ft", NULL);

  KLTFreeFeatureTable(ft);
  KLTFreeFeatureList(fl);
  KLTFreeTrackingContext(tc);
  free(img1);
  free(img2);

  return 0;
}
