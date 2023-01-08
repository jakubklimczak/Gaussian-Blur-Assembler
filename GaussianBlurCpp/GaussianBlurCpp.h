#pragma once

#ifdef GAUSSIANBLUR_EXPORT
#define GAUSSIANBLUR_CPP __declspec(dllexport)
#else
#define GAUSSIANBLUR_CPP __declspec(dllimport)
#endif

extern "C" GAUSSIANBLUR_CPP void ExecuteGaussianBlurCpp(int arraysize, int width, unsigned short* in_redAddr,
	unsigned short* in_greenAddr, unsigned short* in_blueAddr, unsigned short* out_redAddr,
	unsigned short* out_greenAddr, unsigned short* out_blueAddr);
