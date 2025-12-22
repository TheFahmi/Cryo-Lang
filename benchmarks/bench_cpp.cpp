#include <iostream>
#include <chrono>

int main() {
    auto start = std::chrono::high_resolution_clock::now();
    volatile long long sum = 0; 
    long long i = 0;
    while (i < 1000000) {
        sum++;
        i++;
    }
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> elapsed = end - start;
    std::cout << "C++ Native  : " << elapsed.count() << " ms\n";
    return 0;
}
