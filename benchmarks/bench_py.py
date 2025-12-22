import time
start = time.time()
sum_val = 0
i = 0
while i < 1000000:
    sum_val += 1
    i += 1
end = time.time()
print(f"Python      : {(end - start) * 1000:.4f} ms")
