#include <stdio.h>
#include <portaudio.h>
#include <string.h>

#define NUM_CHANNELS    (1)
#define PA_SAMPLE_TYPE  paInt16
#define SAMPLE_RATE  (48000)

int padevsub_(int *numdev, int *ndefin, int *ndefout, int nchin[], 
	      int nchout[], int inerr[], int outerr[])
{
  int      i,devIdx;
  int      numDevices;
  const    PaDeviceInfo *pdi;
  PaError  err;
  PaStreamParameters inputParameters;
  PaStreamParameters outputParameters;
  FILE *fp;

  Pa_Initialize();
  numDevices = Pa_GetDeviceCount();
  *numdev = numDevices;

  if( numDevices < 0 )  {
    err = numDevices;
    Pa_Terminate();
    return err;
  }

  if ((devIdx = Pa_GetDefaultInputDevice()) > 0) {
    *ndefin = devIdx;
  } else {
    *ndefin = 0;
  }

  if ((devIdx = Pa_GetDefaultOutputDevice()) > 0) {
    *ndefout = devIdx;
  } else {
    *ndefout = 0;
  }

  fp=fopen("audio_caps","w");
  for( i=0; i < numDevices; i++ )  {
    pdi = Pa_GetDeviceInfo(i);
    nchin[i]=pdi->maxInputChannels;
    nchout[i]=pdi->maxOutputChannels;
    inerr[i]=1;
    outerr[i]=1;
    if(nchin[i]>0)  {
      inputParameters.device = i;
      inputParameters.channelCount = NUM_CHANNELS;
      inputParameters.sampleFormat = PA_SAMPLE_TYPE;
      inputParameters.suggestedLatency = 0.4;
      inputParameters.hostApiSpecificStreamInfo = NULL;
      // The following call causes problems on Ubuntu 9.10.  Until we figure
      // that out, we'll assume the required sound format is OK and
      // learn the truth when we actually select & open the device.  --W1BW
      //inerr[i] = Pa_IsFormatSupported(&inputParameters,NULL,SAMPLE_RATE);
      inerr[i] = 0;
    }

    if(nchout[i]>0)  {
      outputParameters.device = i;
      outputParameters.channelCount = NUM_CHANNELS;
      outputParameters.sampleFormat =  PA_SAMPLE_TYPE;
      outputParameters.suggestedLatency = 0.4;
      outputParameters.hostApiSpecificStreamInfo = NULL;
      // The following call causes problems on Ubuntu 9.10.  Until we figure
      // that out, we'll assume the required sound format is OK and
      // learn the truth when we actually select & open the device.  --W1BW
      //outerr[i] = Pa_IsFormatSupported(NULL,&outputParameters,SAMPLE_RATE);
      outerr[i] = 0;
    }
    fprintf(fp,"%2d  %3d  %3d  %6d  %6d  %s\n",i,nchin[i],nchout[i],inerr[i],
	   outerr[i],pdi->name);
  }
  fclose(fp);
  return 0;
}

