package main

import (
	"context"
	"log"

	"github.com/jphacks/D_2012/backend/pkg/apis/v1"
	"github.com/jphacks/D_2012/backend/pkg/broadcaster"
)

func main() {
	log.Println("Hello world")

	ctx := context.Background()

	c := broadcaster.New(v1.NewHandler)

	if err := c.Start(ctx); err != nil {
		log.Fatalf("error main: %v", err)
	}
}
