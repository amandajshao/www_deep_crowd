// klt_new.cpp : Defines the entry point for the console application.
//


#include "stdafx.h"
#include <cv.h>
#include <highgui.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>


#include "klt.h"

#include <stdlib.h>
#include <stdio.h>
#include "pnmio.h"
#include <vector>
#include "trk.h"

using namespace std;

#define REPLACE
#define MAX_FEATURE_NUMBER  5000

CvScalar _line_colos[6] = 
{
	CV_RGB(0,255,0),
	CV_RGB(0,0,255),
	CV_RGB(255,255, 0),
	CV_RGB(255,0,255),
	CV_RGB(0,255,255),
	CV_RGB(255,0,0),
};
static inline void drawTrk(IplImage *img, Trk &t, CvScalar color)
{
	if (t.size() < 5) return ;
	
	int start = 0;
	int sz = t.size();
	if (sz < 20)
	    start = 0;
	else
		start = sz - 20;

	

	CvPoint pt0 = cvPoint(t[start].x, t[start].y);
	CvPoint pt1 = {0};
	CvPoint swap = {0};
	for (int i = start + 1; i < sz; ++i)
	{
		pt1 = cvPoint(t[i].x, t[i].y);
		cvLine(img, pt0, pt1, color, 1,8,0);
        CV_SWAP(pt0, pt1, swap);
	}
}


static inline void _strcat(const char *one, const char *two, char *dst)
{
	strcpy(dst, one);
	strcat(dst, two);
}

int main(int argc, char* argv[])

{

  KLT_TrackingContext tc;
  KLT_FeatureList fl;
  KLT_FeatureTable ft;
  

  bool isShowResult = false;
  if (argc == 6) {
	isShowResult = true;
  }
  else if (argc == 7) {
	isShowResult = false;
  }
  else{
	fprintf(stderr, ">>>klt_new.exe path frame_num nfeatures scale foregroundthreshold\n");
	return 0;
  }


  int ncols, nrows;
  int i;
   
  IplImage *frame = NULL, *bgIm= NULL, *gray = NULL, *prev_gray = NULL, *swap_img = NULL, *on_draw = NULL;
  TrkSet trkList;
  Trk single_trk;
  TrkPoint single_point;
  vector<int> trkIds; //track ids of the current feature points being tracked
  vector<int> newTrkIds;
  CvSize frame_size;
  int x, y, k,m;
  char imageName[100];
  CvRNG rng_state = cvRNG(0xffffffff);
  std::vector<Color> colors;

  Color c;
  CvScalar line_color;
  int line_thickness = 1, radius = 3;	
  CvPoint center; 

  int nFeatures = atoi(argv[3]); /*** get frature number ***/
  const int FOREGROUND_THRESHOLD = atoi(argv[5]);
	
  //all the good foreground features detection on frame 1
  CvPoint2D32f frame1_fg_features[MAX_FEATURE_NUMBER]; 
  

  int *fgIndicator = (int*)malloc(sizeof(int) * nFeatures);
  int *trkIndex = (int*)malloc(sizeof(int) * nFeatures);

  assert(fgIndicator && trkIndex);

  int curMaxTrk=0;

  for (i=0;i<nFeatures;i++)
  {
    fgIndicator[i]=0;
    trkIndex[i]=0;
  }


  FILE *fileptr = NULL;
  FILE *listFile = NULL;
  
  /* if the source is image sequence */
  /*
  Get imgList file from src path and store klt file in store path too.
  argv[1] == srcPath, argv[2] = frameNum
  */
/*****************************************************************************************/

  const int startFrame=1,endFrame = atoi(argv[2]);
  const char *srcPath = argv[1];
  char dstFilename[256] = {0};
  const char *listFilename = "imageList.txt";
  char imgName[128] = {0};
  char srcfullName[256] = {0};
  char dstfullName[256] = {0};
  
/******************************************************************************************/
  sprintf(dstFilename, "klt_%d_%d_trk.txt", atoi(argv[3]), atoi(argv[4]));

  _strcat(srcPath, listFilename, srcfullName);
  _strcat(srcPath, dstFilename, dstfullName);
  
  listFile = fopen(srcfullName, "r");
  
  fileptr = fopen(dstfullName, "w");

  if (!fileptr || !listFile)
  {
    fprintf(stderr, "Error: Can not create the file!\n");
    exit(-1);
  }

  if (1 != fscanf(listFile, "%s", imgName)) return 0;
  
  _strcat(srcPath, imgName, srcfullName);
;

  /******If source is video *****/
  // CvCapture *cap = cvCaptureFromFile("D:/finger/finger_video2/Video1.wmv");
  // frame = cvQueryFrame(cap);
  /***********/
  // on_draw = cvCloneImage(frame);
 
  frame = cvLoadImage(srcfullName, 1); /* load gray scale image */
  
/******************************************************************************/
#define _align8(v) (((v) + 7) & ~(7))
  
  double scale = atoi(argv[4]) / 10.0;
  
  int imgwidth = frame->width * scale;
  int imgheight = frame->height * scale;
  CvSize imgsize = {_align8(imgwidth), _align8(imgheight)};
#undef _align8
  /****************************************************************************/

  on_draw = cvCreateImage(imgsize, 8, 3);
  cvResize(frame, on_draw,1);

  bgIm = cvCreateImage(imgsize, 8, 1);
  prev_gray = cvCreateImage(imgsize, 8, 1);
  gray = cvCreateImage(imgsize, 8, 1);
	
  bgIm->origin = on_draw->origin;
  cvCvtColor(on_draw, bgIm, CV_BGR2GRAY);

  cvReleaseImage( &frame );
  frame = NULL;
  
  tc = KLTCreateTrackingContext();
  fl = KLTCreateFeatureList(nFeatures);
  ft = KLTCreateFeatureTable(endFrame-startFrame+1, nFeatures);
  tc->sequentialMode = TRUE;
  tc->writeInternalImages = FALSE;
  tc->affineConsistencyCheck = -1;  /* set this to 2 to turn on affine consistency check */
 

  if (1 != fscanf(listFile, "%s", imgName)) return 0;
  
  _strcat(srcPath, imgName, srcfullName);
  
  frame = cvLoadImage(srcfullName, 1);

  cvResize(frame, on_draw,1);
  cvCvtColor(on_draw, gray, CV_BGR2GRAY);

  cvReleaseImage( &frame );
  
  ncols = gray->width;
  nrows = gray->height;
  KLTSelectGoodFeatures(tc, (unsigned char*)gray->imageData, ncols, nrows, fl);
  	
  curMaxTrk=-1;
  trkList.clear();
  trkIds.clear();
  for (k = 0; k < nFeatures; k++){
    x = (int) (fl->feature[k]->x+0.5);
    y = (int) (fl->feature[k]->y+0.5);
    if (abs(CV_IMAGE_ELEM(gray, uchar, y, x) - CV_IMAGE_ELEM(bgIm, uchar, y, x)) >= FOREGROUND_THRESHOLD)
    {
			
      fgIndicator[k]=1;
      curMaxTrk++;
      trkIndex[k]=curMaxTrk;
			

      single_point.x = (int) (fl->feature[k]->x+0.5);
      single_point.y = (int) (fl->feature[k]->y+0.5);
      single_point.t = startFrame;
      single_trk.clear();
      single_trk.push_back(single_point);
      trkList.push_back(single_trk);
			
    }

  }


 
  if (isShowResult) {
	cvNamedWindow("result");
  }

  CV_SWAP(prev_gray, gray, swap_img);

  for (i = startFrame+1 ; i < endFrame ; i=i+1)  {

    
    if (1 != fscanf(listFile, "%s", imgName)) return 0;
    
    _strcat(srcPath, imgName, srcfullName);
    
    frame = cvLoadImage(srcfullName, 1);
	cvResize(frame, on_draw, 1);

    // cvCopyImage(frame, on_draw);
    cvCvtColor(on_draw, gray, CV_BGR2GRAY);
    cvReleaseImage( &frame );
    frame = NULL;
    
    // pgmReadFile(fnamein, img2, &ncols, &nrows);
    // img2 = (unsigned char*)(gray->imageData);
    KLTTrackFeatures(tc, (unsigned char*)prev_gray->imageData, (unsigned char*)gray->imageData, gray->width, gray->height, fl);
	
		
#ifdef REPLACE
    KLTReplaceLostFeatures(tc, (unsigned char*)gray->imageData, gray->width, gray->height, fl);
    //img1_cv = cvLoadImage(fnamein, CV_LOAD_IMAGE_GRAYSCALE);
    for (k = 0; k < nFeatures; k++){
      if ( fl->feature[k]->val== 0) 
      {
        if (fgIndicator[k]==1)
        {
          single_point.x=int(fl->feature[k]->x+0.5);
          single_point.y=int(fl->feature[k]->y+0.5);
          single_point.t = i;
          //printf("the number of tracks: %d\n", trkList.size());
          //printf("the maximu tracks: %d\n", curMaxTrk);
          //printf("current trk Index: %d\n", trkIndex[k]);
          trkList[trkIndex[k]].push_back(single_point);

		  bool isTrkValid = true;
		  double maxdist = .0, dtmp = .0, x0 = .0, y0 = .0;
		  Trk &strk = trkList[trkIndex[k]];
		  if (strk.size() > 20 && strk.back().t == i) {
			    int trkSz = strk.size();
				x0 = strk.back().x; 
				y0 = strk.back().y;
				for (int di = trkSz - 20; di < trkSz; ++di) {
					dtmp = sqrt( pow(strk[di].x - x0, 2.0) + pow(strk[di].y - y0, 2.0));
					if (dtmp > maxdist) maxdist = dtmp;
				}
				if (maxdist < 3.0) {
					isTrkValid = false;
				}
			}
			 if (!isTrkValid) {
				//trkList.push_back(single_trk);
				//curMaxTrk++;
				fgIndicator[k]=0;
				//trkIndex[k]=curMaxTrk;
			 }

		 // cvCircle(on_draw, cvPoint(x,y),3,cvScalar(255,255,255,0), 2,8,0);
        }
      }

      if ( fl->feature[k]->val> 0) 
      {
        x = (int) (fl->feature[k]->x);
        y = (int) (fl->feature[k]->y);
            

        if (abs(CV_IMAGE_ELEM(gray, uchar, y, x) - CV_IMAGE_ELEM(bgIm, uchar, y, x)) >= FOREGROUND_THRESHOLD)
        {
         
          single_point.x = x;
          single_point.y = y;
          single_point.t = i;
          single_trk.clear();
          single_trk.push_back(single_point);
         
		  trkList.push_back(single_trk);
		  curMaxTrk++;
		  fgIndicator[k]=1;
		  trkIndex[k]=curMaxTrk;
			
		  
		  
		  bool isTrkValid = true;
		  double maxdist = .0, dtmp = .0, x0 = .0, y0 = .0;

		  if (single_trk.size() > 20 && single_trk.back().t == i) {
			    int trkSz = single_trk.size();
				x0 = single_trk.back().x; 
				y0 = single_trk.back().y;
				for (int di = trkSz - 20; di < trkSz; ++di) {
					dtmp = sqrt( pow(single_trk[di].x - x0, 2.0) + pow(single_trk[di].y - y0, 2.0));
					if (dtmp > maxdist) maxdist = dtmp;
				}
				if (maxdist < 3.0) {
					isTrkValid = false;
				}
			}
			
			 if (!isTrkValid) {
				//trkList.push_back(single_trk);
				//curMaxTrk++;
				fgIndicator[k]=0;
				//trkIndex[k]=curMaxTrk;
			 }

			 

		 // cvCircle(on_draw, cvPoint(x,y),3,cvScalar(255,255,255,0), 2,8,0);
        }

        if (abs(CV_IMAGE_ELEM(gray, uchar, y, x) - CV_IMAGE_ELEM(bgIm, uchar, y, x)) < FOREGROUND_THRESHOLD)
        {fgIndicator[k]=0;}

      }
    }

#endif


	/* draw all tracks out */
	if (isShowResult) {
    for (int ii = 0; ii < trkList.size(); ++ii)
		 if (trkList[ii].size() > 1 && trkList[ii].back().t == i)
		{
			drawTrk(on_draw, trkList[ii], _line_colos[ii%6]);
		}    
    
		cvShowImage("result", on_draw);
		if (cvWaitKey(5) == 'q') break;
	}
    
    
    CV_SWAP(prev_gray, gray, swap_img);
    // cvReleaseImage( &gray );
    if (isShowResult) {
		printf("the number of tracks: %d ; curFrame Number: %d\n", trkList.size(),i);
	}

    KLTStoreFeatureList(fl, ft, i);
    //sprintf(fnameout, "J:\\data\\traffic_XG\\feat%05d.ppm", i);
    //KLTWriteFeatureListToPPM(fl, img2, ncols, nrows, fnameout);

  }
  
  if (isShowResult) {
	cvDestroyWindow("result");
  }

#define EXPORT
#ifdef EXPORT
  for (int s = 0; s < trkList.size(); s++){
    fprintf(fileptr,"%d	", trkList[s].size());
    for (int tk = 0; tk < trkList[s].size(); tk++){
      fprintf(fileptr, "(%d,%d,%d)", trkList[s][tk].x, trkList[s][tk].y, trkList[s][tk].t);
    }
    fprintf(fileptr, "\n");
  }
#endif 

  fclose(fileptr); 



  // cvReleaseCapture(&cap);
  free(fgIndicator);
  free(trkIndex);
  cvReleaseImage(&on_draw);
  cvReleaseImage(&bgIm);
  cvReleaseImage(&gray);
  cvReleaseImage(&prev_gray);
  KLTFreeFeatureTable(ft);
  KLTFreeFeatureList(fl);
  KLTFreeTrackingContext(tc);
  //free(img1);
  //free(img2);

  return 0;
}

#define LENGTH 80
void KLTError(char *fmt, ...)
{
  va_list args;

  va_start(args, fmt);
  fprintf(stderr, "KLT Error: ");
  vfprintf(stderr, fmt, args);
  fprintf(stderr, "\n");
  va_end(args);
  exit(1);
}


/*********************************************************************
 * KLTWarning
 * 
 * Prints a warning message.
 * 
 * INPUTS
 * exactly like printf
 */

void KLTWarning(char *fmt, ...)
{
  va_list args;

  va_start(args, fmt);
  fprintf(stderr, "KLT Warning: ");
  vfprintf(stderr, fmt, args);
  fprintf(stderr, "\n");
  fflush(stderr);
  va_end(args);
}






/*********************************************************************/

static void _getNextString(
    FILE *fp,
    char *line)
{
  int i;

  line[0] = '\0';

  while (line[0] == '\0')  {
    fscanf(fp, "%s", line);
    i = -1;
    do  {
      i++;
      if (line[i] == '#')  {
        line[i] = '\0';
        while (fgetc(fp) != '\n') ;
      }
    }  while (line[i] != '\0');
  }
}


/*********************************************************************
 * pnmReadHeader
 */

void pnmReadHeader(
    FILE *fp, 
    int *magic, 
    int *ncols, int *nrows, 
    int *maxval)
{
  char line[LENGTH];
	
  /* Read magic number */
  _getNextString(fp, line);
  if (line[0] != 'P')
    KLTError("(pnmReadHeader) Magic number does not begin with 'P', "
             "but with a '%c'", line[0]);
  sscanf(line, "P%d", magic);
	
  /* Read size, skipping comments */
  _getNextString(fp, line);
  *ncols = atoi(line);
  _getNextString(fp, line);
  *nrows = atoi(line);
  if (*ncols < 0 || *nrows < 0 || *ncols > 10000 || *nrows > 10000)
    KLTError("(pnmReadHeader) The dimensions %d x %d are unacceptable",
             *ncols, *nrows);
	
  /* Read maxval, skipping comments */
  _getNextString(fp, line);
  *maxval = atoi(line);
  fread(line, 1, 1, fp); /* Read newline which follows maxval */
	
  if (*maxval != 255)
    KLTWarning("(pnmReadHeader) Maxval is not 255, but %d", *maxval);
}


/*********************************************************************
 * pgmReadHeader
 */

void pgmReadHeader(
    FILE *fp, 
    int *magic, 
    int *ncols, int *nrows, 
    int *maxval)
{
  pnmReadHeader(fp, magic, ncols, nrows, maxval);
  if (*magic != 5)
    KLTError("(pgmReadHeader) Magic number is not 'P5', but 'P%d'", *magic);
}


/*********************************************************************
 * ppmReadHeader
 */

void ppmReadHeader(
    FILE *fp, 
    int *magic, 
    int *ncols, int *nrows, 
    int *maxval)
{
  pnmReadHeader(fp, magic, ncols, nrows, maxval);
  if (*magic != 6)
    KLTError("(ppmReadHeader) Magic number is not 'P6', but 'P%d'", *magic);
}


/*********************************************************************
 * pgmReadHeaderFile
 */

void pgmReadHeaderFile(
    char *fname, 
    int *magic, 
    int *ncols, int *nrows, 
    int *maxval)
{
  FILE *fp;

  /* Open file */
  if ( (fp = fopen(fname, "rb")) == NULL)
    KLTError("(pgmReadHeaderFile) Can't open file named '%s' for reading\n", fname);

  /* Read header */
  pgmReadHeader(fp, magic, ncols, nrows, maxval);

  /* Close file */
  fclose(fp);
}


/*********************************************************************
 * ppmReadHeaderFile
 */

void ppmReadHeaderFile(
    char *fname, 
    int *magic, 
    int *ncols, int *nrows, 
    int *maxval)
{
  FILE *fp;

  /* Open file */
  if ( (fp = fopen(fname, "rb")) == NULL)
    KLTError("(ppmReadHeaderFile) Can't open file named '%s' for reading\n", fname);

  /* Read header */
  ppmReadHeader(fp, magic, ncols, nrows, maxval);

  /* Close file */
  fclose(fp);
}


/*********************************************************************
 * pgmRead
 *
 * NOTE:  If img is NULL, memory is allocated.
 */

unsigned char* pgmRead(
    FILE *fp,
    unsigned char *img,
    int *ncols, int *nrows)
{
  unsigned char *ptr;
  int magic, maxval;
  int i;

  /* Read header */
  pgmReadHeader(fp, &magic, ncols, nrows, &maxval);

  /* Allocate memory, if necessary, and set pointer */
  if (img == NULL)  {
    ptr = (unsigned char *) malloc(*ncols * *nrows * sizeof(char));
    if (ptr == NULL)  
      KLTError("(pgmRead) Memory not allocated");
  }
  else
    ptr = img;

  /* Read binary image data */
  {
    unsigned char *tmpptr = ptr;
    for (i = 0 ; i < *nrows ; i++)  {
      fread(tmpptr, *ncols, 1, fp);
      tmpptr += *ncols;
    }
  }

  return ptr;
}


/*********************************************************************
 * pgmReadFile
 *
 * NOTE:  If img is NULL, memory is allocated.
 */

unsigned char* pgmReadFile(
    char *fname,
    unsigned char *img,
    int *ncols, int *nrows)
{
  unsigned char *ptr;
  FILE *fp;

  /* Open file */
  if ( (fp = fopen(fname, "rb")) == NULL)
    KLTError("(pgmReadFile) Can't open file named '%s' for reading\n", fname);

  /* Read file */
  ptr = pgmRead(fp, img, ncols, nrows);

  /* Close file */
  fclose(fp);

  return ptr;
}


/*********************************************************************
 * pgmWrite
 */

void pgmWrite(
    FILE *fp,
    unsigned char *img, 
    int ncols, 
    int nrows)
{
  int i;

  /* Write header */
  fprintf(fp, "P5\n");
  fprintf(fp, "%d %d\n", ncols, nrows);
  fprintf(fp, "255\n");

  /* Write binary data */
  for (i = 0 ; i < nrows ; i++)  {
    fwrite(img, ncols, 1, fp);
    img += ncols;
  }
}


/*********************************************************************
 * pgmWriteFile
 */

void pgmWriteFile(
    char *fname, 
    unsigned char *img, 
    int ncols, 
    int nrows)
{
  FILE *fp;

  /* Open file */
  if ( (fp = fopen(fname, "wb")) == NULL)
    KLTError("(pgmWriteFile) Can't open file named '%s' for writing\n", fname);

  /* Write to file */
  pgmWrite(fp, img, ncols, nrows);

  /* Close file */
  fclose(fp);
}


/*********************************************************************
 * ppmWrite
 */

void ppmWrite(
    FILE *fp,
    unsigned char *redimg,
    unsigned char *greenimg,
    unsigned char *blueimg,
    int ncols, 
    int nrows)
{
  int i, j;

  /* Write header */
  fprintf(fp, "P6\n");
  fprintf(fp, "%d %d\n", ncols, nrows);
  fprintf(fp, "255\n");

  /* Write binary data */
  for (j = 0 ; j < nrows ; j++)  {
    for (i = 0 ; i < ncols ; i++)  {
      fwrite(redimg, 1, 1, fp); 
      fwrite(greenimg, 1, 1, fp);
      fwrite(blueimg, 1, 1, fp);
      redimg++;  greenimg++;  blueimg++;
    }
  }
}


/*********************************************************************
 * ppmWriteFileRGB
 */

void ppmWriteFileRGB(
    char *fname, 
    unsigned char *redimg,
    unsigned char *greenimg,
    unsigned char *blueimg,
    int ncols, 
    int nrows)
{
  FILE *fp;

  /* Open file */
  if ( (fp = fopen(fname, "wb")) == NULL)
    KLTError("(ppmWriteFileRGB) Can't open file named '%s' for writing\n", fname);

  /* Write to file */
  ppmWrite(fp, redimg, greenimg, blueimg, ncols, nrows);

  /* Close file */
  fclose(fp);
}

