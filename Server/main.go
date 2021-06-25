/*
 * Fred server prototype
 * (c) Justus Languell 2021
 * Aka: Juicestus
 * Aka: $nmap -vvsnp 1-443 192.169.0.0/8
 */

package main

import (
	"fmt"
	"log"
	"strings"
	"net/http"
    "io/ioutil"
)


func read() (r string) {
	db := "database.db"
    datbyte, err := ioutil.ReadFile(db)
    if err != nil {
        panic(err)
    }
	datraw := string(datbyte)
	dat := ""
	for i := 0; i < len(datraw); i++ {
		if datraw[i] != '\n' {
			dat += string(datraw[i])
		}
	}
	r = dat
	//r = ("[" + dat + "]")
	return
}

func write(usr string, msg string) {
	db := "database.db"
	comb := "{\"usr\":\"" + usr + "\",\"msg\":\"" + msg + "\"},"
	full := read() + comb
	data := []byte(full)
    err := ioutil.WriteFile(db, data, 0644)
    if err != nil {
        panic(err)
    }

}
func post(w http.ResponseWriter, r *http.Request) {
	/*
	if r.URL.Path != "/post" {
		http.Error(w, "<script>window.location = '/'</script><h2>404 not found<h2>", http.StatusNotFound)
		return
	}
	*/

	switch r.Method {
		case "GET":
			 //http.ServeFile(w, r, "post.html")
			 //http.ServeFile(w, r, "database.db")
			 resp := read()
			 resp = strings.TrimSuffix(resp, ",")
			 fmt.Fprintf(w, "[" + resp + "]")

		case "POST":
			// Call ParseForm() to parse the raw query and update r.PostForm and r.Form.
			if err := r.ParseForm(); err != nil {
				fmt.Fprintf(w, "ParseForm() err: %v", err)
				return
			}
			//fmt.Fprintf(w, "Post from website! r.PostFrom = %v\n", r.PostForm)
			usr := r.FormValue("usr")
			msg := r.FormValue("msg")
			fmt.Fprintf(w, "Message Posted")
			write(usr, msg)
			fmt.Printf("%v: %v\n", usr, msg)

		default:
			fmt.Fprintf(w, "Sorry, only GET and POST methods are supported.")
	}
}

func index(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}

	switch r.Method {
		case "GET":
			http.ServeFile(w, r, "index.html")

		default:
			fmt.Fprintf(w, "Sorry, only GET methods are supported.")
	}
}

func main() {
	http.HandleFunc("/", index)
	http.HandleFunc("/post", post)

	fmt.Printf("Fred Server (c) Justus Languell 2021\n")
	fmt.Printf("Starting server for testing HTTP POST...\n")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
