package v1

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/line/line-bot-sdk-go/linebot"

	_ "github.com/go-sql-driver/mysql"

	"github.com/jphacks/D_2012/backend/pkg/broadcaster"
)

type Response struct {
	Ratio float64 `json:"ratio"`
}

type Request struct {
	UserID string `json:"userID"`
	State  string `json:"state"`
}

type Item struct {
	UserID      string
	LastUpdated time.Time
	State       string
}

type handler struct {
	pool *sql.DB
	line *linebot.Client
}

const prefix = "/v1"

// insert into v1table values ('id', '2020-11-01 10:11:12', 'in');
// insert into v1table values ('deadbeafdead', '2020-11-02 10:11:12', 'in') on duplicate key update state='out';

// TODO data race in handler struct

func (h *handler) handle(w http.ResponseWriter, r *http.Request) {
	// TODO query to db, return the result

	res := &Response{Ratio: -0.1}

	result := h.pool.QueryRow("SELECT sum(case when `state` = 'in' then 1 else 0 end)/count(*) as ratio FROM v1table;")
	if err := result.Scan(&res.Ratio); err != nil {
		log.Println(err)
	}

	bytes, err := json.Marshal(*res)
	if err != nil {
		log.Println(err)
	}

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.Write(bytes)
	w.Write([]byte("\n"))

	log.Printf("%+v", res)
}

func (h *handler) handleFake(w http.ResponseWriter, r *http.Request) {
	now := time.Now().Second()
	res := Response{Ratio: float64(now) / float64(60)}

	bytes, err := json.Marshal(res)
	if err != nil {
		log.Println(err)
	}

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.Write(bytes)
}

func (h *handler) handleEnter(w http.ResponseWriter, r *http.Request) {
	events, err := h.line.ParseRequest(r)
	if err != nil {
		log.Printf("failed to parse line webhook: %v\n", err)
	}

	var userID string
	for _, event := range events {
		if event.Type == linebot.EventTypeBeacon {
			beaconEventType := event.Beacon.Type
			if beaconEventType == linebot.BeaconEventTypeEnter {
				userID = event.Source.UserID
				if userID == "" {
					w.WriteHeader(http.StatusBadRequest)
					log.Println("user id is nil")
					return
				}

				now := time.Now().UTC().Format("2006-01-02 15:04:05")
				log.Println(now)

				if _, err := h.pool.Exec(
					`insert into v1table values (?, ?, 'in') on duplicate key update state='in';`,
					userID, now); err != nil {
					log.Println(err)
					w.WriteHeader(http.StatusBadRequest)
					return
				}
			}
		}
	}

	fmt.Fprint(w, "ok")
}

func (h *handler) handleCron(w http.ResponseWriter, r *http.Request) {
	if _, err := h.pool.Exec("UPDATE v1table SET state = 'out' WHERE TIMESTAMPDIFF(hour, latest_updated, NOW()) >= 4;"); err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	fmt.Fprintln(w, "ok")
}

func NewHandler(mux *http.ServeMux, env broadcaster.ConfigAccessor) {
	handler := handler{}

	p, err := env.GetPooledDBConn()
	if err != nil {
		log.Fatalf("failed to initialize v1 handler: %v", err)
	}

	handler.pool = p

	bot, err := env.GetLINEBotClient()
	if err != nil {
		log.Fatalln(err)

	}
	handler.line = bot

	mux.HandleFunc(prefix, handler.handle)
	mux.HandleFunc(fmt.Sprintf("%s/fake", prefix), handler.handleFake)
	mux.HandleFunc(fmt.Sprintf("%s/enter", prefix), handler.handleEnter)
	mux.HandleFunc(fmt.Sprintf("%s/cron", prefix), handler.handleCron)
}

func (h *handler) initializeTable() {
	if _, err := h.pool.Exec(`CREATE TABLE IF NOT EXISTS v1table
	( user_id varchar(35) unique NOT NULL, latest_updated timestamp NOT NULL,
	state enum('in','out') NOT NULL, PRIMARY KEY (user_id) );`); err != nil {
		log.Fatalf("unable to initialize database: %v", err)
	}
}
