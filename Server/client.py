#!/usr/bin/env python3

# Fred test client
# (c) Justus Languell 2021

import sys
import json
import requests

if __name__ == '__main__':
    url = sys.argv[1]
    op = sys.argv[2]

    """
    if op == 'get':
        url += '/get'
        response = requests.get(url)
        content = response.text
        #print(content)
        messages = json.loads(content)
        formatted = json.dumps(messages, indent = 2)
        print(formatted)

        print("\nMessages: ")
        for block in messages:
            print("\nUser    : " + block['usr'])
            print("Message : " + block['msg'])
    """

    if op == 'get':
        url += '/get'
        params = {
                "n": sys.argv[3]
                }

        response = requests.post(url, 
                                 params = params,
                                 )

        content = response.text
        #print(content)
        messages = json.loads(content)
        formatted = json.dumps(messages, indent = 2)
        print(formatted)

        print("\nMessages: ")
        for block in messages:
            print("\nUser    : " + block['usr'])
            print("Message : " + block['msg'])
    
    if op == 'post':
        url += '/post'
        usr = sys.argv[3]
        msg = sys.argv[4]

        params = {
            "usr": usr,
            "msg": msg
        }

        response = requests.post(url, 
                                 params = params,
                                 )

        print(response.text)

