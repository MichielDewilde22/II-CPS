
/*
 * Delay and sum beamforming for eRTIS using CUDA accelerated kernels.
 *
 * arguments: Delay matrix [( directions * channels),type int32] and matched filter matrix [( samples * channels), type single].
 * 
 * Compile with 'mexcuda -v mex_fast_SpatioTemp_MF_CUDA.cu' (-v for extra details for debugging)
 * Requires CUDA toolkit (9.1 was used by me) and visual studio (2015 was used by me).
 * Make sure to correctly set c++ compiler with 'mex -setup c++' and clicking on the link of the version you want.
 * And make sure to set the CUDA enviroment variable correctly with
 * 'setenv('MW_NVCC_PATH','C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\vX\bin')'
 *
 * Wouter Jansen
 */

#include "mex.h"
#include "gpu/mxGPUArray.h"
#include <string>     
        
/*
 * Device code for GPU kernel to calculate beamforming. 
 * With threads going over all 3 dimensions: directions, samples and microphones.
 */
void __global__ beamform_kernel(int const *delay_matrix, float const *dataMatchedFilter,float *dataBeamform,
     int nmicrophones, int ndirections, int nspsls, int output_size, int sample_size){
    int output_size_block = blockIdx.x * blockDim.x + threadIdx.x;
    int direction = blockIdx.y * blockDim.y + threadIdx.y;
    int microphone = blockIdx.z * blockDim.z + threadIdx.z;
    if(direction < ndirections && output_size_block < sample_size && microphone < nmicrophones){
            atomicAdd(&dataBeamform[output_size_block + direction*output_size], dataMatchedFilter[microphone*nspsls + delay_matrix[microphone*ndirections + direction] + output_size_block]);
    }
}

/*
 * Host code for CPU
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
    /* Declare all variables.*/
    mxGPUArray const *dataMatchedFilter;
    mxGPUArray const *delayMatrix;
    int * delayMatrixCPU;
    mxGPUArray *dataBeamForm;
    float const *d_dataMatchedFilter;
    int const *d_delayMatrix;
    float *d_dataBeamForm;
    int nmicrophones;
    int ndirections;
    int nspsls;
    int outputSize;
    int sampleSize;
    int maxDelay = 0;

    /* Initialize the MathWorks GPU API. */
    mxInitGPU();

    /* Throw an error if the input are not a CPU arrays. */
    if ( (mxIsGPUArray(prhs[0])) || (mxIsGPUArray(prhs[1]))) {
        mexErrMsgIdAndTxt("parallel:gpu:mexGPUExample:InvalidInput", "The input matrices have to be normal CPU arrays, not GPUArrays.\n");
    }

    /* Throw an error if the input are not the correct datatype. */
    if ( mxGetClassID(prhs[0]) != mxSINGLE_CLASS) {
        mexErrMsgIdAndTxt("parallel:gpu:mexGPUExample:InvalidInput", "The matched filter data matrix has to be of datatype 'single'.\n");
    }
    if ( mxGetClassID (prhs[1]) !=  mxINT32_CLASS) {
        mexErrMsgIdAndTxt("parallel:gpu:mexGPUExample:InvalidInput", "The delay matrix has to be of datatype 'int32'.\n");
    }

    dataMatchedFilter = mxGPUCreateFromMxArray(prhs[0]);
    delayMatrix = mxGPUCreateFromMxArray(prhs[1]);
    delayMatrixCPU = (int *)mxGetData( prhs[1] );

    nmicrophones = mxGPUGetDimensions(dataMatchedFilter)[1];
    nspsls = mxGPUGetDimensions(dataMatchedFilter)[0];
    ndirections = mxGPUGetDimensions(delayMatrix)[0];

    /* Extract a pointer to the input data on the device. */
    d_dataMatchedFilter = (float const *)(mxGPUGetDataReadOnly(dataMatchedFilter));
    d_delayMatrix = (int const *)(mxGPUGetDataReadOnly(delayMatrix));

    /* Calculate the maximum delay and set the output size. */
    for( int cnt = 0; cnt < nmicrophones * ndirections; cnt ++ ){
        if( delayMatrixCPU[ cnt ] > maxDelay ){
            maxDelay = delayMatrixCPU[ cnt ];
        }
    }
    outputSize = nspsls + maxDelay * 4;
    sampleSize = nspsls - 2 * maxDelay;

//     printf("microphones:%i directions:%i samples:%i output size:%i sample size:%i\n",nmicrophones, ndirections, nspsls, outputSize, sampleSize);

    /* Create a GPUArray to hold the result and get its underlying pointer. */
    mwSize dims[2] = {outputSize,ndirections };
    dataBeamForm = mxGPUCreateGPUArray(mxGPUGetNumberOfDimensions(dataMatchedFilter),
                            dims ,
                            mxGPUGetClassID(dataMatchedFilter),
                            mxGPUGetComplexity(dataMatchedFilter),
                            MX_GPU_INITIALIZE_VALUES );
    d_dataBeamForm = (float *)(mxGPUGetData(dataBeamForm));

    /* Execute the beamform kernel. */
    dim3 threadsPerBlock(32, 8, 4);
    dim3 numBlocks(ceil(sampleSize / (threadsPerBlock.x*1.0)), ceil(ndirections / (threadsPerBlock.y*1.0)), ceil(nmicrophones / (threadsPerBlock.z*1.0)));
    beamform_kernel<<<numBlocks, threadsPerBlock>>>(d_delayMatrix, d_dataMatchedFilter, d_dataBeamForm , nmicrophones, ndirections, nspsls, outputSize, sampleSize);

    /* Wrap the result up as a MATLAB gpuArray for return. */
    plhs[0] = mxGPUCreateMxArrayOnGPU(dataBeamForm);

    /*
     * The mxGPUArray pointers are host-side structures that refer to device
     * data. These must be destroyed before leaving the MEX function.
     */
    mxGPUDestroyGPUArray(dataMatchedFilter);
    mxGPUDestroyGPUArray(delayMatrix);
    mxGPUDestroyGPUArray(dataBeamForm);
}
