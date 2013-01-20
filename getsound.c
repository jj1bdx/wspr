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

#define SAMPLE_RATE  (12000)
#define FRAMES_PER_BUFFER (1024)
#define NUM_SECONDS     (114)
#define NUM_CHANNELS    (1)
/* #define DITHER_FLAG     (paDitherOff) */
#define DITHER_FLAG     (0) /**/

#define PA_SAMPLE_TYPE  paInt16
typedef short SAMPLE;
#define SAMPLE_SILENCE  (0)

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
static int recordCallback( const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData )
{
  paTestData *data = (paTestData*)userData;
  const SAMPLE *rptr = (const SAMPLE*)inputBuffer;
  SAMPLE *wptr = &data->recordedSamples[data->frameIndex * NUM_CHANNELS];
  long framesToCalc;
  long i;
  int finished;
  unsigned long framesLeft = data->maxFrameIndex - data->frameIndex;

  (void) outputBuffer; /* Prevent unused variable warnings. */
  (void) timeInfo;
  (void) statusFlags;
  (void) userData;

  if( framesLeft < framesPerBuffer ) {
    framesToCalc = framesLeft;
    finished = paComplete;
  }
   else {
     framesToCalc = framesPerBuffer;
     finished = paContinue;
   }

  if( inputBuffer == NULL ) {
    for( i=0; i<framesToCalc; i++ ) {
      *wptr++ = SAMPLE_SILENCE;                          /* left */
      if( NUM_CHANNELS == 2 ) *wptr++ = SAMPLE_SILENCE;  /* right */
    }
  }
  else {
    for( i=0; i<framesToCalc; i++ ) {
      *wptr++ = *rptr++;  /* left */
      if( NUM_CHANNELS == 2 ) *wptr++ = *rptr++;  /* right */
    }
  }
  data->frameIndex += framesToCalc;
  return finished;
}

/*******************************************************************/
extern int getsound_(short int iwave[])
{
  PaStreamParameters  inputParameters;
  PaStream*           stream;
  PaError             err = paNoError;
  paTestData          data;
  int                 i;
  int                 totalFrames;
  int                 numSamples;
  int                 numBytes;

  data.maxFrameIndex = totalFrames = NUM_SECONDS * SAMPLE_RATE;
  data.frameIndex = 0;
  numSamples = totalFrames * NUM_CHANNELS;
  numBytes = numSamples * sizeof(SAMPLE);
  data.recordedSamples = iwave;
  for( i=0; i<numSamples; i++ ) 
    data.recordedSamples[i] = 0;

  //  err = Pa_Initialize();
  //  if( err != paNoError ) goto done;

  inputParameters.device = Pa_GetDefaultInputDevice();
  inputParameters.channelCount = 1;
  inputParameters.sampleFormat = PA_SAMPLE_TYPE;
  inputParameters.suggestedLatency = Pa_GetDeviceInfo( inputParameters.device )->defaultLowInputLatency;
  inputParameters.hostApiSpecificStreamInfo = NULL;

  err = Pa_OpenStream(
              &stream,
              &inputParameters,
              NULL,                  /* &outputParameters, */
              SAMPLE_RATE,
              FRAMES_PER_BUFFER,
              paClipOff,
              recordCallback,
              &data );
  if( err != paNoError ) goto done;

  err = Pa_StartStream( stream );
  if( err != paNoError ) goto done;

  while( ( err = Pa_IsStreamActive( stream ) ) == 1 ) {
    Pa_Sleep(100);
  }
  if( err < 0 ) goto done;

  err = Pa_CloseStream( stream );    

done:
  //  Pa_Terminate();
  if( err != paNoError ) {
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    err = 1;          /* Always return 0 or 1, but no other return codes. */
  }
  return err;
}

