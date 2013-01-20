#include <stdio.h>
#include <stdlib.h>
#include "portaudio.h"

/* #define DITHER_FLAG     (paDitherOff)  */
#define DITHER_FLAG     (0) /**/
#define PA_SAMPLE_TYPE  paInt16
typedef short SAMPLE;

int soundinit_(void)
{
  PaError err;
  err = Pa_Initialize();
  if( err == paNoError ) {
    return 0;
  }
  else {
//    Pa_Terminate();
    fprintf( stderr, "An error occured when initializing the audio stream\n");
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "WSPR will now exit/n");
    exit(255);
  }
}

int soundexit_(void)
{
  Pa_Terminate();
  return 0;
}

int soundin_(int *idevin, int *nrate0, short recordedSamples[], 
	     int *nframes0, int *iqmode)
{
    PaStreamParameters inputParameters;
    PaStream *stream;
    PaError err;
    int i;
    int totalFrames;
    int numSamples;
    int numBytes;
    int num_channels;
    int nrate;
    int frames_per_buffer=1024;

    nrate=*nrate0;
    if(nrate>12000) frames_per_buffer=4096;
    totalFrames=*nframes0;
    num_channels=*iqmode + 1;
    numSamples = totalFrames * num_channels;
    numBytes = numSamples * sizeof(SAMPLE);
    for( i=0; i<numSamples; i++ ) 
      recordedSamples[i] = 0;

    inputParameters.device = *idevin;
    if(*idevin<0) inputParameters.device = Pa_GetDefaultInputDevice();
    inputParameters.channelCount = num_channels;
    inputParameters.sampleFormat = PA_SAMPLE_TYPE;
    inputParameters.suggestedLatency = 0.4;
    inputParameters.hostApiSpecificStreamInfo = NULL;

    err = Pa_OpenStream(
              &stream,
              &inputParameters,
              NULL,                  /* &outputParameters, */
              nrate,
              frames_per_buffer,
              paClipOff,
              NULL, /* no callback, use blocking API */
              NULL ); /* no callback, so no callback userData */
    if( err != paNoError ) goto error;

    err = Pa_StartStream( stream );
    if( err != paNoError ) goto error;

    err = Pa_ReadStream( stream, recordedSamples, totalFrames );
    if( err != paNoError ) goto error;
    
    err = Pa_CloseStream( stream );
    if( err != paNoError ) goto error;
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    soundinit_();
    return -1;
}

int soundout_(int *idevout, int *nrate0, short recordedSamples[], 
	      int *nframes0, int *iqmode)
{
    PaStreamParameters outputParameters;
    PaStream *stream;
    PaError err;
    int totalFrames;
    int numSamples;
    int numBytes;
    int num_channels;
    int nrate;
    int frames_per_buffer=1024;

    nrate=*nrate0;
    if(nrate>12000) frames_per_buffer=4096;
    totalFrames=*nframes0;
    num_channels=*iqmode + 1;
    numSamples = totalFrames * num_channels;
    numBytes = numSamples * sizeof(SAMPLE);
    outputParameters.device = *idevout;
    if(*idevout<0) outputParameters.device = Pa_GetDefaultOutputDevice();
    outputParameters.channelCount = num_channels;
    outputParameters.sampleFormat =  PA_SAMPLE_TYPE;
    outputParameters.suggestedLatency = 0.4;
    outputParameters.hostApiSpecificStreamInfo = NULL;

    err = Pa_OpenStream(
              &stream,
              NULL, /* no input */
              &outputParameters,
              nrate,
              frames_per_buffer,
              paClipOff,
              NULL, /* no callback, use blocking API */
              NULL ); /* no callback, so no callback userData */
    if( err != paNoError ) goto error;

    if( stream )
    {
        err = Pa_StartStream( stream );
        if( err != paNoError ) goto error;

        err = Pa_WriteStream( stream, recordedSamples, totalFrames );
        if( err != paNoError ) goto error;

        err = Pa_CloseStream( stream );
        if( err != paNoError ) goto error;
    }
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    soundinit_();
    return -1;
}

void msleep_(int *msec0)
{
  Pa_Sleep(*msec0);
}
