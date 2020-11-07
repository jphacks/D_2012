package broadcaster

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/kelseyhightower/envconfig"
)

type impl struct {
	EnvConfig

	mux *http.ServeMux
}

func New(ctors ...func(mux *http.ServeMux, env ConfigAccessor)) *impl {

	env := &EnvConfig{}
	if err := envconfig.Process("", env); err != nil {
		log.Fatalf("failed to process env var: %v", err)
	}
	var accessor ConfigAccessor
	accessor = env

	log.Printf("environment variable: %d", accessor.GetPort())

	mux := http.NewServeMux()

	for _, h := range ctors {
		h(mux, env)
	}

	return &impl{
		EnvConfig: *env,
		mux:       mux,
	}
}

func (impl *impl) Start(ctx context.Context) error {

	server := &http.Server{Addr: fmt.Sprintf(":%d", impl.GetPort()), Handler: impl.mux}

	go func() {
		if err := server.ListenAndServe(); err != nil {
			log.Fatalf("error while starting broadcaster: %v", err)
		}
	}()

	<-ctx.Done()

	return server.Close()
}
