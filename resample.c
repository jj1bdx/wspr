#include <stdio.h>
#include <samplerate.h>

int resample_( float din[], float dout[], double *samfac, int *jz, int *ntype)
{
  SRC_DATA src_data;
  int input_len;
  int output_len;
  int ierr;
  int nchan=1;
  double src_ratio;

  src_ratio=*samfac;
  input_len=*jz;
  output_len=(int) (input_len*src_ratio);

  src_data.data_in=din;
  src_data.data_out=dout;
  src_data.src_ratio=src_ratio;
  src_data.input_frames=input_len;
  src_data.output_frames=output_len;

  ierr=src_simple(&src_data,*ntype,nchan);
  *jz=output_len;
  /*  printf("%d  %d  %d  %d  %f\n",input_len,output_len,
	 src_data.input_frames_used,
	 src_data.output_frames_gen,src_ratio);
  */
  return ierr;
}
