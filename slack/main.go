package main

import (
	"log"
	"os"
	"strings"
	"time"

	"github.com/slack-go/slack"
)

func main() {
	sc := slack.New(os.Getenv("MAPLE_BOT_TOKEN"))
	channelID := os.Getenv("MAPLE_CHANNEL_ID")

	err := getMessages(sc, channelID)
	if err != nil {
		panic(err)
	}
}

func getMessages(sc *slack.Client, channelID string) error {
	hasMore := true
	cursor := ""

	file := "output.md"
	f, err := os.Create(file)
	if err != nil {
		return err
	}
	defer f.Close()

	for hasMore {
		h, err := getHistories(sc, channelID, cursor)
		if err != nil {
			return err
		}
		log.Println("get histories success !!")
		time.Sleep(1 * time.Second)

		cursor = h.ResponseMetaData.NextCursor
		hasMore = h.HasMore

		for _, m := range h.Messages {
			ms, err := getConversations(sc, channelID, m.Timestamp)
			if err != nil {
				return err
			}

			time.Sleep(1 * time.Second)

			err = writeMessages(f, ms, channelID)
			if err != nil {
				return err
			}
		}
		break
	}

	return nil
}

func getHistories(sc *slack.Client, channelID, cursor string) (*slack.GetConversationHistoryResponse, error) {
	return sc.GetConversationHistory(&slack.GetConversationHistoryParameters{
		ChannelID: channelID,
		Cursor:    cursor,
	})
}

func getConversations(sc *slack.Client, channelID, ts string) ([]slack.Message, error) {
	ms, _, _, err := sc.GetConversationReplies(&slack.GetConversationRepliesParameters{
		ChannelID: channelID,
		Timestamp: ts,
	})
	if err != nil {
		return nil, err
	}

	return ms, nil
}

func writeMessages(f *os.File, ms []slack.Message, channelID string) error {
	if len(ms) == 0 {
		return nil
	}

	// timestamp(1725850177.150049)から「.」をリプレイス
	ts := strings.Replace(ms[0].Timestamp, ".", "", -1)
	d := []byte("SlackURL: " + "https://e-dash-hq.slack.com/archives/" + channelID + "/p" + ts)

	_, err := f.Write(d)
	if err != nil {
		return err
	}

	for _, m := range ms {
		// textから改行を削除
		m.Text = strings.Replace(m.Text, "\n", "", -1)

		_, err = f.Write([]byte(m.Text))
		if err != nil {
			return err
		}
	}

	_, err = f.Write([]byte("\n"))
	if err != nil {
		return err
	}

	return nil
}
