#include "pch.h" 
#include <iostream>
#include "GaussianBlurCpp.h"

void ExecuteGaussianBlurCpp(int arraysize, int width, unsigned short* in_redAddr,
							unsigned short* in_greenAddr, unsigned short* in_blueAddr, unsigned short* out_redAddr,
							unsigned short* out_greenAddr, unsigned short* out_blueAddr)
{
	int kernel[9]{ 1,2,1,2,4,2,1,2,1};

	int j = 0;
	int temp;
	int m = 0;

	for (int i = 0; i < arraysize; i++)
	{
		
		if (j % width == 0)
		{
			j += 2;
			i--;
			continue;
		}
//=======================================RED==========================================================================
		temp = 0;
		m = 0;
		for (int k = 0; k < width*3; k+=width) {
			for (int l = 0; l < 3; l++) {
				temp+= in_redAddr[j+k+l] * kernel[m];
				m++;
			}
		}
		out_redAddr[i] = temp / 16;

//=====================================GREEN==========================================================================

		temp = 0;
		m = 0;
		for (int k = 0; k < width*3; k+=width) {
			for (int l = 0; l < 3; l++) {
				temp+= in_greenAddr[j+k+l] * kernel[m];
				m++;
			}
		}
		out_greenAddr[i] = temp / 16;

//=====================================BLUE===========================================================================

		temp = 0;
		m = 0;
		for (int k = 0; k < width*3; k+=width) {
			for (int l = 0; l < 3; l++) {
				temp+= in_blueAddr[j+k+l] * kernel[m];
				m++;
			}
		}

		out_blueAddr[i] = temp / 16;

		j += 1;
	}
}