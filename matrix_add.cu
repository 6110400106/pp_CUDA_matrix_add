#include<stdio.h>

#define N 833
void add(int *X, int* Y, int* Z) {

	for(int i = 0; i < N; i++) {
		for(int j = 0; j < N; j++) {
			Z[i*N+j] = X[i*N+j] + Y[i*N+j];
		}
	}

}

__global__ void add_kernel(int *X, int *Y, int *Z) {
	
	int i = threadIdx.x;
	int j = threadIdx.y;

	if(i < N && j < N) {
		Z[i*N+j] = X[i*N+j] + Y[i*N+j];
	}
}


int main () {

	//Input matrix
	int X[N*N];
	int Y[N*N];

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	for(int i = 0; i < N; i++) {
		for(int j = 0; j < N; j++) {
			X[i*N+j] = -1;
			Y[i*N+j] = 1;
		}
	}

	//Output matrix
	int Z[N*N];

	int *d_X, *d_Y, *d_Z;
	cudaMalloc((void**) &d_X, (N*N)*sizeof(int));
	cudaMalloc((void**) &d_Y, (N*N)*sizeof(int));
	cudaMalloc((void**) &d_Z, (N*N)*sizeof(int));

	cudaMemcpy(d_X, &X, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_Y, &Y, (N*N)*sizeof(int), cudaMemcpyHostToDevice);

	dim3 dimGrid(32, 32, 1);
	dim3 dimBlock(32, 32, 1);

	//Timed add_kernel function
	cudaEventRecord(start);
	add_kernel<<<dimGrid, dimBlock>>>(d_X, d_Y, d_Z);
	cudaEventRecord(stop);
	//add(X, Y, Z);

	cudaMemcpy(&Z, d_Z, (N*N)*sizeof(int), cudaMemcpyDeviceToHost);
	
	cudaEventSynchronize(stop);
	float milliseconds = 0;
	cudaEventElapsedTime(&milliseconds, start, stop);
	
	cudaFree(d_X);
	cudaFree(d_Y);
	cudaFree(d_Z);

	int sum = 0;
	for(int i = 0; i < N; i++) {
		for(int j = 0; j < N; j++) {
			//printf("%d ", Z[i*N+j]);
			sum += Z[i*N+j];
		}
		//printf("\n");
	}
	if(sum == 0)
		printf("All 0s! With N = %d\n", N);
	else {
		printf("Something is wrong!!!\n");
	}
	printf("Time used: %f milliseconds\n", milliseconds);
	
	return -1;

}
