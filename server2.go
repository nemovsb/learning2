package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net"
	"regexp"
	"strconv"
	"strings"
)

func main() {
	defer log.Println("Server 2 done")

	listener, err := net.Listen("tcp", "tcpserver:9999")
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Server 2 run")

	for {
		log.Println("wait listener")
		conn, err := listener.Accept()
		log.Println("New listener ready!")
		if err != nil {
			log.Print(err)
			continue
		}

		log.Print(fmt.Sprintf("locAddr: %+v\nremAddr: %+v\n", conn.LocalAddr(), conn.RemoteAddr()))

		handleConn(conn)
	}
}

func handleConn(c net.Conn) {
	defer c.Close()
	for {
		message, err := bufio.NewReader(c).ReadString(' ')
		fmt.Println("err: ", err)
		if err == io.EOF {
			break
		}
		fmt.Print("Message Received:", message)

		fmt.Println()

		strs := regexp.MustCompile(`[\t\r\n]+`).ReplaceAllString(strings.TrimSpace(message), "\n")
		lines := strings.Split(string(strs), "\n")

		res := make([]string, 2)
		for idx, line := range lines {
			fmt.Printf("Line %d is: %s\n", idx, line)
			strNumbers := strings.Split(string(line), ",")
			nums := make([]int, 2)
			for i, strNumber := range strNumbers {
				var err error
				nums[i], err = strconv.Atoi(strNumber)
				if err != nil {
					log.Print(err)
					c.Write([]byte("Error"))
					return
				}
			}
			var result int
			for i := 1; i < len(nums); i++ {
				//fmt.Printf("Number %d is: %s\n", i, number)
				result = nums[i-1] * nums[i]
				fmt.Printf("RES %d is: %d\n", idx, result)
			}
			res[idx] = strconv.Itoa(result)
		}

		fmt.Println("Try send string")
		pattern := "%s\r\n%s\r\n\r\n "

		//time.Sleep(1 * time.Second)

		c.Write([]byte(fmt.Sprintf(pattern, res[0], res[1])))
	}
	fmt.Println("handleConn end")

}
