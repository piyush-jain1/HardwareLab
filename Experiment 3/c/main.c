/*
 * Copyright (C) 2009-2012 Chris McClelland
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



/*

Made by : 
Group-9

Mukul Verma
Piyush Jain
Saswata de
Shubhanshu Verma

*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <libfpgalink.h>
#include "args.h"


#define CHECK(x) \
	if ( status != FL_SUCCESS ) {       \
		returnCode = x;                   \
		fprintf(stderr, "%s\n", error); \
		flFreeError(error);             \
		goto cleanup;                   \
	}

#define MAX_HEIGHT 256
#define MAX_WIDTH 256


typedef struct BMP{ 

	unsigned short bType;           /* Magic number for file */
	unsigned int   bSize;           /* Size of file */
	unsigned short bReserved1;      /* Reserved */
	unsigned short bReserved2;      /* ... */
	unsigned int   bOffBits;        /* Offset to bitmap data */

	unsigned int  bISize;           /* Size of info header */
	unsigned int  bWidth;          /* Width of image */
	unsigned int   bHeight;         /* Height of image */
	unsigned short bPlanes;         /* Number of color planes */
	unsigned short bBitCount;       /* Number of bits per pixel */
	unsigned int  bCompression;    /* Type of compression to use */
	unsigned int  bSizeImage;      /* Size of image data */
	int           bXPelsPerMeter;  /* X pixels per meter */
	int      	    bYPelsPerMeter;  /* Y pixels per meter */
	unsigned int   bClrUsed;        /* Number of colors used */
	unsigned int   bClrImportant;   /* Number of important colors */
}BMP;

int R[MAX_HEIGHT][MAX_WIDTH], G[MAX_HEIGHT][MAX_WIDTH], B[MAX_HEIGHT][MAX_WIDTH];
int R1[MAX_HEIGHT][MAX_WIDTH], G1[MAX_HEIGHT][MAX_WIDTH], B1[MAX_HEIGHT][MAX_WIDTH];


//void RGB2YUV();
int Read_BMP_Header(char *filename, int *h, int *w,BMP *bmp) 
{
	printf("image header\n");
	FILE *f;
	int *p;
	f=fopen("test.bmp","r");
	// printf("\nReading BMP Header ");
	fread(&bmp->bType,sizeof(unsigned short),1,f);
	p=(int *)bmp;
	fread(p+1,sizeof(BMP)-4,1,f);
	if (bmp->bType != 19778) {
		printf("Error, not a BMP file!\n");
		return 0;
	} 

	*w = bmp->bWidth;
	*h = bmp->bHeight;
	return 1;
}

void Read_BMP_Data(char *filename,int *h,int *w,BMP *bmp)
{

	int i,j,i1,H,W,Wp,PAD;
	unsigned char *RGB;
	FILE *f;
	// printf("\nReading BMP Data ");
	f=fopen(filename,"r");
	fseek(f, 0, SEEK_SET);
	fseek(f, bmp->bOffBits, SEEK_SET);
	W = bmp->bWidth;
	H = bmp->bHeight;
	// printf("\nheight = %d width= %d \n",H,W);
	PAD = (3 * W) % 4 ? 4 - (3 * W) % 4 : 0;
	Wp = 3 * W + PAD;
	RGB = (unsigned char *)malloc(Wp*H *sizeof(unsigned char));
	for(i=0;i<Wp*H;i++) RGB[i]=0;
	
	fread(RGB, sizeof(unsigned char), Wp * H, f);

	i1=0;
	for (i = 0; i < H; i++) {
		for (j = 0; j < W; j++){
			i1=i*(Wp)+j*3;
			B[i][j]=RGB[i1];
			G[i][j]=RGB[i1+1];
			R[i][j]=RGB[i1+2];
		}
	}
	fclose(f);
	free(RGB);
}

///void YUV2RGB();
int write_BMP_Header(char *filename,int *h,int *w,BMP *bmp) 
{


	FILE *f;
	int *p;
	f=fopen(filename,"w");
	// printf("\n Writing BMP Header ");
	fwrite(&bmp->bType,sizeof(unsigned short),1,f);
	p=(int *)bmp;
	fwrite(p+1,sizeof(BMP)-4,1,f);
	return 1;
}

void write_BMP_Data(char *filename,int *h,int *w,BMP *bmp){

	int i,j,i1,H,W,Wp,PAD;
	unsigned char *RGB;
	FILE *f;
	// printf("\nWriting BMP Data\n");
	f=fopen(filename,"w");
	fseek(f, 0, SEEK_SET);
	fseek(f, bmp->bOffBits, SEEK_SET);
	W = bmp->bWidth;
	H = bmp->bHeight;
	// printf("\nheight = %d width= %d ",H,W);
	PAD = (3 * W) % 4 ? 4 - (3 * W) % 4 : 0;
	Wp = 3 * W + PAD;
	RGB = (unsigned char *)malloc(Wp* H * sizeof(unsigned char));
	fread(RGB, sizeof(unsigned char), Wp * H, f);

	i1=0;
	for (i = 0; i < H; i++) {
		for (j = 0; j < W; j++){
			i1=i*(Wp)+j*3;
			RGB[i1]=B1[i][j];
			RGB[i1+1]=G1[i][j];
			RGB[i1+2]=R1[i][j];
		}
	}
	fwrite(RGB, sizeof(unsigned char), Wp * H, f);
	fclose(f);
	free(RGB);
}

int main(int argc, const char *argv[]) {

	int h,w;
	BMP b;
	int j;
	BMP *bmp=&b;
	printf("bcsjbchjbsdc\n");

	Read_BMP_Header("test.bmp",&h,&w,bmp);
	Read_BMP_Data("test.bmp",&h,&w,bmp);

	int returnCode;
	struct FLContext *handle = NULL;
	FLStatus status;
	const char *error = NULL;
	bool flag;
	bool isNeroCapable, isCommCapable;
	uint32 numDevices, scanChain[16], i;
	const char *vp = NULL, *ivp = NULL, *jtagPort = NULL, *xsvfFile = NULL, *dataFile = NULL;
	bool scan = false, usbPower = false;
	const char *const prog = argv[0];

	printf("FPGALink \"C\" Example Copyright (C) 2011 Chris McClelland\n\n");
	argv++;
	argc--;
	while ( argc ) {
		if ( argv[0][0] != '-' ) {
			unexpected(prog, *argv);
			FAIL(1);
		}
		switch ( argv[0][1] ) {
		case 'h':
			usage(prog);
			FAIL(0);
			break;
		case 's':
			scan = true;
			break;
		case 'p':
			usbPower = true;
			break;
		case 'v':
			GET_ARG("v", vp, 2);
			break;
		case 'i':
			GET_ARG("i", ivp, 3);
			break;
		case 'j':
			GET_ARG("j", jtagPort, 4);
			break;
		case 'x':
			GET_ARG("x", xsvfFile, 5);
			break;
		case 'f':
			GET_ARG("f", dataFile, 6);
			break;
		default:
			invalid(prog, argv[0][1]);
			FAIL(7);
		}
		argv++;
		argc--;
	}
	if ( !vp ) {
		missing(prog, "v <VID:PID>");
		FAIL(8);
	}

	if ( !ivp && jtagPort ) {
		fprintf(stderr, "You can't specify --j without -i");
		FAIL(9);
	}
	if ( !jtagPort ) {
		jtagPort = "D0234";
	}

	flInitialise();
	
	printf("Attempting to open connection to FPGALink device %s...\n", vp);
	status = flOpen(vp, &handle, NULL);
	if ( status ) {
		if ( ivp ) {
			int count = 60;
			printf("Loading firmware into %s...\n", ivp);
			status = flLoadStandardFirmware(ivp, vp, jtagPort, &error);
			CHECK(10);
			
			printf("Awaiting renumeration");
			flSleep(1000);
			do {
				printf(".");
				fflush(stdout);
				flSleep(100);
				status = flIsDeviceAvailable(vp, &flag, &error);
				CHECK(11);
				count--;
			} while ( !flag && count );
			printf("\n");
			if ( !flag ) {
				fprintf(stderr, "FPGALink device did not renumerate properly as %s\n", vp);
				FAIL(12);
			}
			
			printf("Attempting to open connection to FPGLink device %s again...\n", vp);
			status = flOpen(vp, &handle, &error);
			CHECK(13);
		} else {
			fprintf(stderr, "Could not open FPGALink device at %s and no initial VID:PID was supplied\n", vp);
			FAIL(14);
		}
	}
	
	if ( usbPower ) {
		printf("Connecting USB power to FPGA...\n");
		status = flPortAccess(handle, 0x0080, 0x0080, NULL, &error);
		CHECK(15);
		flSleep(100);
	}

	isNeroCapable = flIsNeroCapable(handle);
	isCommCapable = flIsCommCapable(handle);
	if ( scan ) {
		if ( isNeroCapable ) {
			status = flScanChain(handle, &numDevices, scanChain, 16, &error);
			CHECK(16);
			if ( numDevices ) {
				printf("The FPGALink device at %s scanned its JTAG chain, yielding:\n", vp);
				for ( i = 0; i < numDevices; i++ ) {
					printf("  0x%08X\n", scanChain[i]);
				}
			} else {
				printf("The FPGALink device at %s scanned its JTAG chain but did not find any attached devices\n", vp);
			}
		} else {
			fprintf(stderr, "JTAG chain scan requested but FPGALink device at %s does not support NeroJTAG\n", vp);
			FAIL(17);
		}
	}

	if ( xsvfFile ) {
		printf("Playing \"%s\" into the JTAG chain on FPGALink device %s...\n", xsvfFile, vp);
		if ( isNeroCapable ) {
			status = flPlayXSVF(handle, xsvfFile, &error);
			CHECK(18);
		} else {
			fprintf(stderr, "XSVF play requested but device at %s does not support NeroJTAG\n", vp);
			FAIL(19);
		}
	}
	
	if ( dataFile && !isCommCapable ) {
		fprintf(stderr, "Data file load requested but device at %s does not support CommFPGA\n", vp);
		FAIL(20);
	}
	
	if ( isCommCapable ) {
		// printf("Writing channel 0x01 to zero count...\n");
		// byte = 0x01;
		// status = flWriteChannel(handle, 1000, 0x01, 1, &byte, &error);
		// CHECK(21);

		for(i=1;i<h-1;i++) 
	    {
		for(j=1;j<w-1;j++) {
					
					uint8 R_ret=0,G_ret=0,B_ret=0;
					uint8 addr = 0x01;

					//Declaring temp of uint8 type to pass to flwritechannel
					uint8 temp = R[i-1][j-1];

					//Red array
					
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i-1][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i-1][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i][j-1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i+1][j-1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i+1][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = R[i+1][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1; 
					status = flReadChannel(handle, 1000, addr, 1, &R_ret, &error);
					CHECK(22);
					R1[i][j] = R_ret;

					//Green array
					// resetting address
					
					addr = 0x01; 
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i-1][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i-1][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i][j-1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i+1][j-1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i+1][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = G[i+1][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1; 
					status = flReadChannel(handle, 1000, addr, 1, &G_ret, &error);
					CHECK(22);
					G1[i][j] = G_ret;


					//Red array
					//resetting address

					addr = 0x01; 
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i-1][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i-1][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i][j-1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i+1][j-1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i+1][j];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1;
					temp = B[i+1][j+1];
					status = flWriteChannel(handle, 10000, addr, 1, &temp, &error);
					addr = addr + 1; 
					status = flReadChannel(handle, 1000, addr, 1, &B_ret, &error);
					CHECK(22);
					B1[i][j] = B_ret;

					// FILE *fp;

					// fp = fopen("output" , "a");
					// printf("Output file created\n");
					// if(fp!=NULL)
					// {
					// 	fprintf(fp,"%d\n%d\n%d\n",R_ret,G_ret,B_ret);
					// 	printf("%d\n%d\n%d\n",R_ret,G_ret,B_ret);
					// }
					// else
					// {
					// 	printf("Problem in output file opening \n");		
					// }
					// fclose(fp);
					

				}
			} 
		}else {
				fprintf(stderr, "Unable to load file %s!\n", dataFile);
				FAIL(23);	
				}
		write_BMP_Header("lowpass.bmp",&h,&w,bmp);
		write_BMP_Data("lowpass.bmp",&h,&w,bmp);
		printf("Done \n");	
		// printf("Reading channel...\n");
		// status = flReadChannel(handle, 1000, 0x00, 2, buf, &error);
		// CHECK(24);
		// printf("Got 0x%02X\n", buf[0]);
		// printf("Reading channel...\n");
		// status = flReadChannel(handle, 1000, 0x00, 2, buf, &error);
		// CHECK(25);
		// printf("Got 0x%02X\n", buf[0]);
		// printf("Reading channel...\n");
		// status = flReadChannel(handle, 1000, 0x00, 2, buf, &error);
		// CHECK(26);
		// printf("Got 0x%02X\n", buf[0]);

	returnCode = 0;

cleanup:
	flClose(handle);
	return returnCode;
}

void usage(const char *prog) {
	printf("Usage: %s [-hps] -v <VID:PID> [-i <VID:PID>] [-x <xsvfFile>] [-f <dataFile>]\n\n", prog);
	printf("Load FX2 firmware, load the FPGA, interact with the FPGA.\n\n");
	printf("  -h             print this help and exit\n");
	printf("  -p             FPGA is powered from USB (Nexys2 only!)\n");
	printf("  -s             scan the JTAG chain\n");
	printf("  -v <VID:PID>   renumerated vendor and product ID of the FPGALink device\n");
	printf("  -i <VID:PID>   initial vendor and product ID of the FPGALink device\n");
	printf("  -j <jtagPort>  JTAG port config (e.g D0234)\n");
	printf("  -x <xsvfFile>  SVF, XSVF or CSVF file to play into the JTAG chain\n");
	printf("  -f <dataFile>  binary data to write to channel 0\n");
}
