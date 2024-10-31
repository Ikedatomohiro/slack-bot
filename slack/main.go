package main

import (
	"bufio"
	"log"
	"os"
	consts "slack-bot/consts"
	"strings"
	"time"

	"github.com/slack-go/slack"
)

func main() {
	slackClient := slack.New(os.Getenv("MAPLE_BOT_TOKEN"))
	channelID := os.Getenv("MAPLE_CHANNEL_ID")

	err := getMessages(slackClient, channelID)
	if err != nil {
		panic(err)
	}

	// outpt.mdの順番を逆にする
	err = reverseFile(consts.FROM_SLACK_MESSAGE, consts.FOR_RAG_MESSAGE)
	if err != nil {
		panic(err)
	}
}

func getMessages(slackClient *slack.Client, channelID string) error {
	hasMore := true
	cursor := ""

	f, err := os.Create(consts.FROM_SLACK_MESSAGE)
	if err != nil {
		return err
	}
	defer f.Close()

	for hasMore {
		h, err := getHistories(slackClient, channelID, cursor)
		if err != nil {
			return err
		}
		log.Println("get histories success !!")
		time.Sleep(1 * time.Second)

		cursor = h.ResponseMetaData.NextCursor
		hasMore = h.HasMore

		for _, m := range h.Messages {
			ms, err := getConversations(slackClient, channelID, m.Timestamp)
			if err != nil {
				return err
			}

			time.Sleep(1 * time.Second)

			err = writeMessages(f, ms, channelID)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func getHistories(slackClient *slack.Client, channelID, cursor string) (*slack.GetConversationHistoryResponse, error) {
	return slackClient.GetConversationHistory(&slack.GetConversationHistoryParameters{
		ChannelID: channelID,
		Cursor:    cursor,
	})
}

func getConversations(slackClient *slack.Client, channelID, ts string) ([]slack.Message, error) {
	ms, _, _, err := slackClient.GetConversationReplies(&slack.GetConversationRepliesParameters{
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

func reverseFile(inputFile, outputFile string) error {
	// 元ファイルを開く
	f, err := os.Open(inputFile)
	if err != nil {
		return err
	}
	defer f.Close()

	// 出力ファイルを作成
	out, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer out.Close()

	// 元ファイルのサイズを取得
	stat, err := f.Stat()
	if err != nil {
		return err
	}
	fileSize := stat.Size()

	var line []byte
	buf := make([]byte, 1)

	writer := bufio.NewWriter(out)

	// ファイル末尾から逆順に読み込み
	for offset := fileSize - 1; offset >= 0; offset-- {
		_, err := f.Seek(offset, 0)
		if err != nil {
			return err
		}

		_, err = f.Read(buf)
		if err != nil {
			return err
		}

		if buf[0] == '\n' && len(line) > 0 {
			// 行を逆順にして保存
			for i := len(line) - 1; i >= 0; i-- {
				writer.WriteByte(line[i])
			}
			writer.WriteByte('\n')
			line = nil
		} else {
			line = append(line, buf[0])
		}
	}

	// 最後の行を逆順にして保存
	for i := len(line) - 1; i >= 0; i-- {
		writer.WriteByte(line[i])
	}
	writer.WriteByte('\n')

	// 書き込みを確定
	writer.Flush()

	return nil
}
