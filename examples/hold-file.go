package main

import (
    "bufio"
    "fmt"
    "os"
)

func must(err error) {
    if err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
}

func main() {
    f, err := os.OpenFile("held.log",
        os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0640)
    must(err)
    _, err = f.WriteString("hello\n")
    must(err)
    fmt.Printf("PID=%d FD=%d\n", os.Getpid(), f.Fd())
    input := bufio.NewReader(os.Stdin)
    fmt.Println("Enter: close file")
    _, err = input.ReadString('\n')
    must(err)
    must(f.Close())
    fmt.Println("File closed. Enter: exit process")
    _, err = input.ReadString('\n')
    must(err)
}

