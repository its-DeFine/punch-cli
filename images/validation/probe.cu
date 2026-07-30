#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
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
  const char* visible = std::getenv("NVIDIA_VISIBLE_DEVICES");
  if (!visible || !*visible) { std::fprintf(stderr, "missing visible GPU identity list\n"); return 1; }
  int expected = 1;
  for (const char* cursor = visible; *cursor; ++cursor) if (*cursor == ',') ++expected;
  if (devices != expected) { std::fprintf(stderr, "expected %d visible CUDA devices, found %d\n", expected, devices); return 1; }

  std::vector<int*> allocations(devices, nullptr);
  for (int index = 0; index < devices; ++index) {
    check(cudaSetDevice(index), "cudaSetDevice");
    int host = 41 + index;
    check(cudaMalloc(reinterpret_cast<void**>(&allocations[index]), sizeof(host)), "cudaMalloc");
    check(cudaMemcpy(allocations[index], &host, sizeof(host), cudaMemcpyHostToDevice), "cudaMemcpy H2D");
    increment<<<1, 1>>>(allocations[index]);
    check(cudaGetLastError(), "kernel launch");
    check(cudaDeviceSynchronize(), "cudaDeviceSynchronize");
    check(cudaMemcpy(&host, allocations[index], sizeof(host), cudaMemcpyDeviceToHost), "cudaMemcpy D2H");
    if (host != 42 + index) { std::fprintf(stderr, "CUDA result mismatch on device %d: %d\n", index, host); return 1; }
  }

  const char* communication = std::getenv("PUNCH_GPU_COMMUNICATION");
  if (!communication || (std::strcmp(communication, "SAME_NODE") != 0 && std::strcmp(communication, "P2P_REQUIRED") != 0)) {
    std::fprintf(stderr, "invalid GPU communication requirement\n"); return 1;
  }
  if (std::strcmp(communication, "P2P_REQUIRED") == 0) {
    std::vector<int*> peerTargets(devices, nullptr);
    for (int destination = 0; destination < devices; ++destination) {
      check(cudaSetDevice(destination), "cudaSetDevice P2P target allocation");
      check(cudaMalloc(reinterpret_cast<void**>(&peerTargets[destination]), sizeof(int)), "cudaMalloc P2P target");
    }
    for (int destination = 0; destination < devices; ++destination) {
      for (int source = 0; source < devices; ++source) {
        if (source == destination) continue;
        int accessible = 0;
        check(cudaDeviceCanAccessPeer(&accessible, destination, source), "cudaDeviceCanAccessPeer");
        if (!accessible) { std::fprintf(stderr, "CUDA P2P unavailable from device %d to %d\n", destination, source); return 1; }
        check(cudaSetDevice(destination), "cudaSetDevice P2P");
        cudaError_t enabled = cudaDeviceEnablePeerAccess(source, 0);
        if (enabled != cudaSuccess && enabled != cudaErrorPeerAccessAlreadyEnabled) check(enabled, "cudaDeviceEnablePeerAccess");
        if (enabled == cudaErrorPeerAccessAlreadyEnabled) cudaGetLastError();
        check(cudaMemcpyPeer(peerTargets[destination], destination, allocations[source], source, sizeof(int)), "cudaMemcpyPeer");
        check(cudaDeviceSynchronize(), "cudaDeviceSynchronize P2P");
        int copied = 0;
        check(cudaMemcpy(&copied, peerTargets[destination], sizeof(copied), cudaMemcpyDeviceToHost), "cudaMemcpy P2P D2H");
        if (copied != 42 + source) { std::fprintf(stderr, "CUDA P2P result mismatch from device %d to %d\n", source, destination); return 1; }
      }
    }
    for (int destination = 0; destination < devices; ++destination) {
      check(cudaSetDevice(destination), "cudaSetDevice P2P target cleanup");
      check(cudaFree(peerTargets[destination]), "cudaFree P2P target");
    }
  }
  for (int index = 0; index < devices; ++index) {
    check(cudaSetDevice(index), "cudaSetDevice cleanup");
    check(cudaFree(allocations[index]), "cudaFree");
  }
  return 0;
}
