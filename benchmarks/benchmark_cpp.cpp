#include <iostream>

long long fib(long long n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

long long consume_stack(long long limit, long long d, long long a, long long b, long long c, long long e, long long f, long long g, long long h, long long i) {
    if (d >= limit) {
        return d;
    }
    return consume_stack(limit, d + 1, a+1, b+1, c+1, e+1, f+1, g+1, h+1, i+1);
}

int main() {
    std::cout << "Fib(50):" << std::endl;
    std::cout << fib(50) << std::endl;

    std::cout << "Loop 10 Billion:" << std::endl;
    long long sum = 0;
    long long i = 0;
    while (i < 10000000000LL) {
        sum += i;
        i++;
    }
    std::cout << sum << std::endl;
    
    std::cout << "TCO Stack Dive (10M depth):" << std::endl;
    std::cout << consume_stack(10000000, 0, 1, 2, 3, 4, 5, 6, 7, 8) << std::endl;

    return 0;
}
