/** @file patest_record.c
	@brief Record input into an array; Save array to a file; Playback recorded data.
	@author Phil Burk  http://www.softsynth.com
*/
/*
 * $Id: patest_record.c 249 2006-08-09 20:08:01Z va3db $
 *
 * This program uses the PortAudio Portable Audio Library.
 * For more information see: http://www.portaudio.com
 * Copyright (c) 1999-2000 Ross Bencina and Phil Burk
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * Any person wishing to distribute modifications to the Software is
 * requested to send the modifications to the original developer so that
 * they can be incorporated into the canonical version.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "portaudio.h"

/* #define SAMPLE_RATE  (17932) // Test failure to open with this value. */
#define SAMPLE_RATE  (12000)
#define FRAMES_PER_BUFFER (1024)
#define NUM_SECONDS     (114)
#define NUM_CHANNELS    (1)
/* #define DITHER_FLAG     (paDitherOff) */
#define DITHER_FLAG     (0) /**/

/* Select sample format. */
#define PA_SAMPLE_TYPE  paInt16
typedef short SAMPLE;

typedef struct
{
    int          frameIndex;  /* Index into sample array. */
    int          maxFrameIndex;
    SAMPLE      *recordedSamples;
} paTestData;

/* This routine will be called by the PortAudio engine when audio is needed.
** It may be called at interrupt level on some machines so don't do anything
** that could mess up the system like calling malloc() or free().
*/
static int playCallback( const void *inputBuffer, void *outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void *userData )
{
  paTestData *data = (paTestData*)userData;
  SAMPLE *rptr = &data->recordedSamples[data->frameIndex * NUM_CHANNELS];
  SAMPLE *wptr = (SAMPLE*)outputBuffer;
  unsigned int i;
  int finished;
  unsigned int framesLeft = data->maxFrameIndex - data->frameIndex;

  (void) inputBuffer; /* Prevent unused variable warnings. */
  (void) timeInfo;
  (void) statusFlags;
  (void) userData;

  if( framesLeft < framesPerBuffer )  {
    /* final buffer... */
    for( i=0; i<framesLeft; i++ )  {
      *wptr++ = *rptr++;  /* left */
      if( NUM_CHANNELS == 2 ) *wptr++ = *rptr++;  /* right */
    }
    for( ; i<framesPerBuffer; i++ )  {
      *wptr++ = 0;  /* left */
      if( NUM_CHANNELS == 2 ) *wptr++ = 0;  /* right */
    }
    data->frameIndex += framesLeft;
    finished = paComplete;
  }
  else  {
    for( i=0; i<framesPerBuffer; i++ )  {
      *wptr++ = *rptr++;  /* left */
      if( NUM_CHANNELS == 2 ) *wptr++ = *rptr++;  /* right */
    }
    data->frameIndex += framesPerBuffer;
    finished = paContinue;
  }
  return finished;
}

/*******************************************************************/
extern int playsound_(short int iwave[], int *npts)
{
  PaStreamParameters  outputParameters;
  PaStream*           stream;
  PaError             err = paNoError;
  paTestData          data;
  int                 totalFrames;
  int                 numSamples;
  int                 numBytes;
  int itemp=0;

  //  data.maxFrameIndex = totalFrames = NUM_SECONDS * SAMPLE_RATE;
  data.maxFrameIndex = totalFrames = *npts;
  data.frameIndex = 0;
  numSamples = totalFrames * NUM_CHANNELS;
  numBytes = numSamples * sizeof(SAMPLE);
  data.recordedSamples = iwave;

  /* Play the wave file */
  data.frameIndex = 0;
  //  err = Pa_Initialize();
  //  if( err != paNoError ) goto done;
  outputParameters.device = Pa_GetDefaultOutputDevice();
  outputParameters.channelCount = NUM_CHANNELS;
  outputParameters.sampleFormat =  PA_SAMPLE_TYPE;
  outputParameters.suggestedLatency = Pa_GetDeviceInfo( outputParameters.device )->defaultLowOutputLatency;
  outputParameters.hostApiSpecificStreamInfo = NULL;

  err = Pa_OpenStream(
              &stream,
              NULL,                                /* no input */
              &outputParameters,
              SAMPLE_RATE,
              FRAMES_PER_BUFFER,
              paClipOff,
              playCallback,
              &data );
  if( err != paNoError ) goto done;

  if( stream ) {
    err = Pa_StartStream( stream );
    if( err != paNoError ) goto done;

    while( ( err = Pa_IsStreamActive( stream ) ) == 1 )  {
      itemp++;
      printf("a %d   %d   %d\n",itemp,*npts,data.frameIndex);
      Pa_Sleep(1000);
    }
    if( err < 0 ) goto done;
        
    err = Pa_CloseStream( stream );
    if( err != paNoError ) goto done;    
  }

done:
  //  Pa_Terminate();
  //    if( data.recordedSamples )       /* Sure it is NULL or valid. */
  //        free( data.recordedSamples );
  if( err != paNoError ) {
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    err = 1;          /* Always return 0 or 1, but no other return codes. */
  }
  return err;
}

int pa_init_(void)
{
  int err;
  err = Pa_Initialize();
  if(err==0) printf("Portaudio initialized\n");
  return err;
}

void pa_terminate_(void)
{
  Pa_Terminate();
  printf("Portaudio terminated\n");
}

void msleep_(int *msec0)
{
  Pa_Sleep(*msec0);
}
