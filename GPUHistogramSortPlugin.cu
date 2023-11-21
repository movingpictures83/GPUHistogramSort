
#include <thrust/adjacent_difference.h>
#include <thrust/binary_search.h>
#include <thrust/copy.h>
#include <thrust/device_vector.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/sort.h>

#include "GPUHistogramSortPlugin.h"

void GPUHistogramSortPlugin::input(std::string infile){
readParameterFile(infile);
}

void GPUHistogramSortPlugin::run() {}

void GPUHistogramSortPlugin::output(std::string outfile) {

  int inputLength, num_bins;
  unsigned int *hostInput, *hostBins;

  inputLength = atoi(myParameters["N"].c_str());
  hostInput = (unsigned int*) malloc (inputLength*sizeof(unsigned int));
   std::ifstream myinput((std::string(PluginManager::prefix())+myParameters["data"]).c_str(), std::ios::in);
 int i;
 for (i = 0; i < inputLength; ++i) {
        int k;
        myinput >> k;
        hostInput[i] = k;
 }

  // Copy the input to the GPU
  //@@ Insert code here
  thrust::device_vector<int> deviceInput(inputLength);
  thrust::copy(hostInput, hostInput + inputLength, deviceInput.begin());

  // Determine the number of bins (num_bins) and create space on the host
  //@@ insert code here
  thrust::sort(deviceInput.begin(), deviceInput.end());
  //num_bins = deviceInput.back() + 1;
 num_bins = 4096;
  hostBins = (unsigned int *)malloc(num_bins * sizeof(unsigned int));

  // Allocate a device vector for the appropriate number of bins
  //@@ insert code here
  thrust::device_vector<int> deviceBins(num_bins);

  // Create a cumulative histogram. Use thrust::counting_iterator and
  // thrust::upper_bound
  //@@ Insert code here
  thrust::counting_iterator<int> search_begin(0);
  thrust::upper_bound(deviceInput.begin(), deviceInput.end(), search_begin,
                      search_begin + num_bins, deviceBins.begin());

  // Use thrust::adjacent_difference to turn the culumative histogram
  // into a histogram.
  //@@ insert code here.
  thrust::adjacent_difference(deviceBins.begin(), deviceBins.end(),
                              deviceBins.begin());

  // Copy the histogram to the host
  //@@ insert code here
  thrust::copy(deviceBins.begin(), deviceBins.end(), hostBins);
        std::ofstream outsfile(outfile.c_str(), std::ios::out);
        int j;
        for (i = 0; i < num_bins; ++i){
                outsfile << hostBins[i];//std::setprecision(0) << a[i*N+j];
                outsfile << "\n";
        }


  // Free space on the host
  //@@ insert code here
  free(hostBins);

}

PluginProxy<GPUHistogramSortPlugin> GPUHistogramSortPluginProxy = PluginProxy<GPUHistogramSortPlugin>("GPUHistogramSort", PluginManager::getInstance());
