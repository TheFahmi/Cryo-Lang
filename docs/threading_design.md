# Argon Threading & Concurrency

**Version:** v3.1.0  
**Status:** ✅ Implemented

## Overview

Argon provides **true OS-level parallelism** through its threading module. This enables real parallel execution using native operating system threads, not simulated concurrency.

## Features

- **OS Threads**: Real parallel execution using `std::thread`
- **Channels**: Thread-safe message passing (mpsc)
- **Non-blocking Operations**: Try-receive and timeout support
- **Worker API**: Simple spawn/join semantics

## Built-in Functions

### Thread Management

| Function | Description |
|----------|-------------|
| `thread_spawn(value, operation)` | Spawn a new OS thread with a computation |
| `thread_join(worker_id)` | Wait for thread completion and get result |
| `thread_is_done(worker_id)` | Check if thread has finished |
| `thread_active_count()` | Get number of active threads |

### Channel Communication

| Function | Description |
|----------|-------------|
| `channel_new()` | Create a new unbuffered channel |
| `channel_send(ch, value)` | Send value to channel (returns bool) |
| `channel_recv(ch)` | Receive from channel (blocking) |
| `channel_try_recv(ch)` | Receive without blocking (returns null if empty) |
| `channel_recv_timeout(ch, ms)` | Receive with timeout in milliseconds |
| `channel_close(ch)` | Close the channel |

## Supported Operations

When spawning a thread with `thread_spawn(value, operation)`, the following operations are available:

| Operation | Description | Example |
|-----------|-------------|---------|
| `"fib"` | Compute Fibonacci number | `thread_spawn(30, "fib")` |
| `"factorial"` | Compute factorial | `thread_spawn(10, "factorial")` |
| `"double"` | Multiply by 2 | `thread_spawn(21, "double")` |
| `"square"` | Square the value | `thread_spawn(5, "square")` |
| `"sleep"` | Sleep for N milliseconds | `thread_spawn(100, "sleep")` |

## Examples

### Parallel Fibonacci

```argon
fn main() {
    // Spawn 4 parallel fibonacci computations
    let t1 = thread_spawn(30, "fib");
    let t2 = thread_spawn(31, "fib");
    let t3 = thread_spawn(32, "fib");
    let t4 = thread_spawn(33, "fib");
    
    // Wait for all results
    let r1 = thread_join(t1);
    let r2 = thread_join(t2);
    let r3 = thread_join(t3);
    let r4 = thread_join(t4);
    
    print("fib(30) = " + r1);  // 832040
    print("fib(31) = " + r2);  // 1346269
    print("fib(32) = " + r3);  // 2178309
    print("fib(33) = " + r4);  // 3524578
}
```

### Channel Communication

```argon
fn main() {
    // Create channel
    let ch = channel_new();
    
    // Send messages
    channel_send(ch, 42);
    channel_send(ch, 100);
    channel_send(ch, 999);
    
    // Receive messages (FIFO order)
    let v1 = channel_recv(ch);  // 42
    let v2 = channel_recv(ch);  // 100
    let v3 = channel_recv(ch);  // 999
    
    print("Received: " + v1 + ", " + v2 + ", " + v3);
}
```

### Non-blocking Receive

```argon
fn main() {
    let ch = channel_new();
    
    // Try to receive from empty channel
    let result = channel_try_recv(ch);
    if (result == null) {
        print("Channel is empty");
    }
    
    // Send something
    channel_send(ch, 777);
    
    // Now try_recv will succeed
    let value = channel_try_recv(ch);
    print("Got: " + value);  // 777
}
```

### Timeout Receive

```argon
fn main() {
    let ch = channel_new();
    
    // Wait up to 100ms for a message
    let result = channel_recv_timeout(ch, 100);
    
    if (result == null) {
        print("Timeout - no message received");
    } else {
        print("Got: " + result);
    }
}
```

### Check Thread Status

```argon
fn main() {
    let worker = thread_spawn(500, "sleep");
    
    // Check if done immediately
    if (!thread_is_done(worker)) {
        print("Worker is still running...");
    }
    
    // Wait for completion
    let result = thread_join(worker);
    print("Worker finished");
}
```

## Implementation Details

The threading module is implemented in Rust using:

- `std::thread` for OS thread management
- `std::sync::mpsc` for channel communication
- `Arc<Mutex<>>` for thread-safe shared state

### Architecture

```
┌─────────────────────────────────────────┐
│           Argon Interpreter             │
├─────────────────────────────────────────┤
│          ThreadManager                  │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │   Workers   │  │    Channels     │  │
│  │ HashMap<id> │  │ Sender/Receiver │  │
│  └─────────────┘  └─────────────────┘  │
├─────────────────────────────────────────┤
│           OS Threads (std::thread)      │
└─────────────────────────────────────────┘
```

### Thread Safety

- `ThreadValue` is a serializable enum that can be safely passed between threads
- Channels use Rust's `mpsc` (multi-producer, single-consumer)
- The `Receiver` is wrapped in `Arc<Mutex<>>` for safe sharing

## Limitations

1. **Custom Functions**: Currently only predefined operations (fib, factorial, etc.) can be spawned. Custom Argon functions cannot be executed in parallel yet.

2. **Structs**: Struct values cannot be sent through channels (they serialize to Null).

3. **Functions**: Function values cannot be sent through channels.

## Future Enhancements

- [ ] Spawn arbitrary Argon functions in threads
- [ ] Work-stealing thread pool
- [ ] Async/await integration
- [ ] Parallel iterators

## See Also

- [Channel Module](../stdlib/channel.ar) - High-level channel patterns
- [Worker Module](../stdlib/worker.ar) - Worker pool abstractions
