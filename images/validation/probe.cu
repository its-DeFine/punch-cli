#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
static void check(cudaError_t result, const char* operation) {
  if (result != cudaSuccess) {
    std::fprintf(stderr, "%s failed: %s (%s)\n", operation, cudaGetErrorName(result), cudaGetErrorString(result));
    std::exit(EXIT_FAILURE);
  }
}
__global__ void increment(int* value) { *value += 1; }
int main() {
  int devices = 0;
  check(cudaGetDeviceCount(&devices), "cudaGetDeviceCount");
  if (devices != 1) { std::fprintf(stderr, "expected one visible CUDA device, found %d\n", devices); return 1; }
  int host = 41;
  int* device = nullptr;
  check(cudaMalloc(reinterpret_cast<void**>(&device), sizeof(host)), "cudaMalloc");
  check(cudaMemcpy(device, &host, sizeof(host), cudaMemcpyHostToDevice), "cudaMemcpy H2D");
  increment<<<1, 1>>>(device);
  check(cudaGetLastError(), "kernel launch");
  check(cudaDeviceSynchronize(), "cudaDeviceSynchronize");
  check(cudaMemcpy(&host, device, sizeof(host), cudaMemcpyDeviceToHost), "cudaMemcpy D2H");
  int status = 0;
  if (host != 42) { std::fprintf(stderr, "CUDA result mismatch: %d\n", host); status = 1; }
  check(cudaFree(device), "cudaFree");
  return status;
}
