
def fib(n):
    if n < 2: return n
    return fib(n-1) + fib(n-2)

print("Fibonacci(40):")
print(fib(40))

print("\nLoop 100M iterations:")
sum_val = 0
i = 0
while i < 100000000:
    sum_val += i
    i += 1
print(sum_val)
