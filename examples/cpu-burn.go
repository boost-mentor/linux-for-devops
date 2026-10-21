// Recording helper: four runnable workers; exits automatically after 120 seconds.
package main

import (
    "fmt"
    "os"
    "runtime"
    "sync/atomic"
    "time"
)

var counter atomic.Uint64

func main() {
    runtime.GOMAXPROCS(4)
    fmt.Printf("CPU demo PID=%d; 4 workers; automatic stop in 120 seconds\n", os.Getpid())
    for i := 0; i < 4; i++ {
        go func() {
            var x uint64 = 1
            for {
                for j := 0; j < 100000; j++ { x = x*1664525 + 1013904223 }
                counter.Add(x)
            }
        }()
    }
    time.Sleep(120*time.Second)
    fmt.Println("Time limit reached")
}
