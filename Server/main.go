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
	"strconv"
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

// Input from app cannot contain "},{", "}|{" or 
//" " " (like the single quote lol)

func msgs(n int) (r string) {
	raw := read()
	raw = strings.TrimSuffix(raw, ",")
	piped := strings.Replace(raw, "},{", "}|{", -1)
	ls := strings.Split(piped, "|")

	lls := len(ls)
	r = "["

	if n == -1 {
		r += (raw + "]")
	} else if n < lls {
		//needed := lls - n
		for i := n; i < lls; i++ {
			r += (ls[i] + ",")
		}
		r = strings.TrimSuffix(r, ",")
		r += "]"
	} else {
		//r += (raw + "]")
		r += "]"
	}
	return
}

func post(w http.ResponseWriter, r *http.Request) {

	if r.URL.Path != "/post" {
		http.Error(w,
				   "<script>window.location = '/'</script><h2>404 not found<h2>",
				   http.StatusNotFound)
		return
	}

	switch r.Method {
		case "GET":
			 http.ServeFile(w, r, "post.html")

		case "POST":
			if err := r.ParseForm(); err != nil {
				fmt.Fprintf(w, "ParseForm() err: %v", err)
				return
			}

			usr := r.FormValue("usr")
			msg := r.FormValue("msg")
			fmt.Fprintf(w, "Message Posted")
			write(usr, msg)
			fmt.Printf("%v: %v\n", usr, msg)

		default:
			fmt.Fprintf(w, "Sorry, only GET and POST methods are supported.")
	}
}

func get(w http.ResponseWriter, r *http.Request) {

	if r.URL.Path != "/get" {
		http.Error(w,
				   "<script>window.location = '/'</script><h2>404 not found<h2>",
				   http.StatusNotFound)
		return
	}


	switch r.Method {
		case "GET":
			http.ServeFile(w, r, "get.html")

		case "POST":
			if err := r.ParseForm(); err != nil {
				fmt.Fprintf(w, "ParseForm() err: %v", err)
				return
			}

			rn := r.FormValue("n")
			n, err := strconv.Atoi(rn)

			if err == nil {
				if n >= -1 {
					fmt.Printf("Someone requested %v messages\n", n)
					resp := msgs(n)
					fmt.Fprintf(w, resp)
				} else {
					fmt.Fprintf(w, "[]")
					fmt.Printf("Someone requested negative messages\n")
				}
			} else {
				fmt.Fprintf(w, "[]")
				fmt.Printf("Someone requested non int messages\n")
			}

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
	http.HandleFunc("/get", get)

	fmt.Printf("Fred Server (c) Justus Languell 2021\n")
	fmt.Printf("Starting server on port 8080...\n")

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
