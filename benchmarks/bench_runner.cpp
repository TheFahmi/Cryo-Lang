#include <iostream>
#include <vector>
#include <string>
#include <chrono>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/resource.h>
#include <iomanip>

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <command> [args...]" << std::endl;
        return 1;
    }

    // Measure time
    auto start = std::chrono::high_resolution_clock::now();

    pid_t pid = fork();
    if (pid == 0) {
        // Child process
        // Redirect stdout/stderr if needed, but for now we keep them to see output
        execvp(argv[1], &argv[1]);
        perror("execvp failed");
        exit(1);
    } else if (pid > 0) {
        // Parent process
        int status;
        waitpid(pid, &status, 0);
        
        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> distinct = end - start;

        // Get memory usage (Max RSS)
        struct rusage usage;
        if (getrusage(RUSAGE_CHILDREN, &usage) == 0) {
             std::cout << "Time: " << std::fixed << std::setprecision(5) << distinct.count() << "s" << std::endl;
             std::cout << "Peak Memory: " << usage.ru_maxrss << " KB" << std::endl;
        } else {
            std::cerr << "Failed to get resource usage" << std::endl;
        }
        
        if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
            return WEXITSTATUS(status);
        }
        return 0;

    } else {
        perror("fork failed");
        return 1;
    }
}
