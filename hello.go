// hello.go

package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	// Replacing .env file content with hardcoded value
	model := "mistral"

	// get command line argument
	if len(os.Args) < 2 {
		fmt.Println("Please provide an argument.")
		os.Exit(1)
	}
	version, err := strconv.Atoi(os.Args[1])
	if err != nil || version < 1 || version > 10 {
		fmt.Println("Invalid argument. Please provide a valid version number between 1 and 10.")
		os.Exit(1)
	}
	fmt.Printf("Hello %s, version %d.\n", model, version)

	// print help output

}
