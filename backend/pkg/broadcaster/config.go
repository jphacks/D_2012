package broadcaster

import (
	"database/sql"
	"fmt"

	"github.com/line/line-bot-sdk-go/linebot"
)

type EnvConfig struct {
	port            int    `envconfig:"PORT" default:"8080"`
	DBInstance      string `envconfig:"DB_INSTANCE"`
	DBUser          string `envconfig:"DB_USER"`
	DBPassword      string `envconfig:"DB_PASSWORD"`
	DBSocketDir     string `envconfig:"DB_SOCKET_DIR"`
	DBTCPHost       string `envconfig:"DB_TCP_HOST"`
	DBName          string `envconfig:"DB_NAME"`
	LINESecret      string `envconfig:"LINE_SECRET"`
	LINEAccessToken string `envconfig:"LINE_ACCESS_TOKEN"`
}

type ConfigAccessor interface {
	GetPort() int
	GetPooledDBConn() (*sql.DB, error)
	GetLINEBotClient() (*linebot.Client, error)
}

var _ ConfigAccessor = (*EnvConfig)(nil)

func (e *EnvConfig) GetPort() int {
	return e.port
}

func (e *EnvConfig) GetPooledDBConn() (*sql.DB, error) {

	if e.DBSocketDir == "" && e.DBTCPHost == "" {
		return nil, fmt.Errorf("either DB_SOCKET_DIR or DB_TCP_HOST must be provided")
	}

	dbhost := fmt.Sprintf("%s:%s@tcp(%s)/%s?parseTime=true", e.DBUser, e.DBPassword, e.DBTCPHost, e.DBName)
	if e.DBSocketDir != "" {
		dbhost = fmt.Sprintf("%s:%s@unix(/%s/%s)/%s?parseTime=true", e.DBUser, e.DBPassword, e.DBSocketDir, e.DBInstance, e.DBName)
	}

	pool, err := sql.Open("mysql", dbhost)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize db client: %v", err)
	}

	pool.SetMaxIdleConns(5)
	pool.SetMaxOpenConns(7)
	pool.SetConnMaxLifetime(1800)

	return pool, nil
}

func (e *EnvConfig) GetLINEBotClient() (*linebot.Client, error) {
	bot, err := linebot.New(e.LINESecret, e.LINEAccessToken)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize LINE sdk: %v", err)
	}

	return bot, nil
}
