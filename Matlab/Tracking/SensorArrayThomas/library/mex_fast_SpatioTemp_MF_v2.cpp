//You can include any C libraries that you normally use
#include "math.h"
#include "mex.h"   //--This one is required

#define DATAMF_2D( a, b ) data_MF[ ( a ) + ( b ) * n_sps ]
#define DATABF_2D( c, d ) data_BF[ ( c ) + ( d ) * n_sps_BF ]
#define DELAYS_2D( e, f ) delay_Int_mat[ ( e ) + ( f ) * n_azel ]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{

    //Declarations
    mxArray *data_MF_ptr;
    double *data_MF, *data_BF;
    
    mxArray * delay_Int_ptr;
    double * delay_Int_mat;
       
    int i,j;
    int n_sps, n_chans, n_azel, n_sps_BF;
    int azel_cnt, chan_cnt, spl_cnt;
    
    int data_BF_idx, delay_base_idx;
    int max_delay = 0;
    int cur_delay;
    int chan_offset = 0;
    int BF_offset = 0;
    //Copy input pointer x
    

    //Get matrix with Matched Filter data:
    data_MF_ptr = prhs[ 0 ];    
    data_MF = mxGetPr( data_MF_ptr );
    n_chans = mxGetN( data_MF_ptr );
    n_sps = mxGetM( data_MF_ptr );
    
    // Now, get the matrix with the sample delays:
    delay_Int_ptr = prhs[ 1 ];    
    delay_Int_mat = mxGetPr( delay_Int_ptr );
    n_azel = mxGetM( delay_Int_ptr );

    // Find the maximum of the delay_mat:
    
    for( int cnt = 0; cnt < n_chans * n_azel; cnt ++ ){
        if( delay_Int_mat[ cnt ] > max_delay ){
            max_delay = delay_Int_mat[ cnt ];
        }
    }
    //printf( "The maximum delay is %d\n", max_delay );
    
    n_sps_BF = n_sps + max_delay * 4;
    // Allocate memory and assign output pointer
    plhs[0] = mxCreateDoubleMatrix( n_sps_BF , n_azel, mxREAL );
    
    //Get a pointer to the data space in our newly allocated memory
    data_BF = mxGetPr( plhs[0] );
    
    
    /*
    // Zero init:
    for( int cnt = 0; cnt < n_sps_BF * n_azel; cnt++ ){
        data_BF[ cnt ] = 0;
    }
    */
    
    
    /*
    for( azel_cnt = 0; azel_cnt < n_azel; azel_cnt++ ){
        for( chan_cnt = 0; chan_cnt < n_chans; chan_cnt++ ){
            printf( "%f, ", DELAYS_2D( azel_cnt, chan_cnt ) );
        }
        printf("\n");
    }
    */
 
    // Now, do the beamforming:   
    /*
    for( azel_cnt = 0; azel_cnt < n_azel; azel_cnt++ ){
        for( spl_cnt = 0; spl_cnt < ( n_sps - 2 * max_delay ) ; spl_cnt++ ){
            // First, just copy the sample from the first channel:
            DATABF_2D( spl_cnt, azel_cnt ) = 0;
            // Now, add all the other channels:
            for( chan_cnt = 0; chan_cnt < n_chans; chan_cnt++ ){
                cur_delay = DELAYS_2D( azel_cnt, chan_cnt );
                DATABF_2D( spl_cnt, azel_cnt ) += data_MF[ spl_cnt + cur_delay, chan_cnt ];
            }
        }
    }
    */
    
    // Beamforming 2.0:
    for( azel_cnt = 0; azel_cnt < n_azel; azel_cnt++ ){
        // Init to 0:
        for( spl_cnt = 0; spl_cnt < ( n_sps - 2 * max_delay ) ; spl_cnt++ ){
            DATABF_2D( spl_cnt, azel_cnt ) = 0;
        }
        BF_offset = azel_cnt * n_sps_BF; 
        for( chan_cnt = 0; chan_cnt < n_chans; chan_cnt++ ){
            cur_delay = DELAYS_2D( azel_cnt, chan_cnt );
            chan_offset = chan_cnt * n_sps;
            
            // Now, add all the other channels:
            for( spl_cnt = 0; spl_cnt < ( n_sps - 2 * max_delay ) ; spl_cnt++ ){
                data_BF[ spl_cnt +  BF_offset ] += data_MF[ spl_cnt + cur_delay + chan_offset ];
            }
        }
    }       
    
}






