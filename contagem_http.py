import requests
import time

contagem = 1

while contagem <= 10:
    req = requests.head("http://localhost:8080/erro")
    status_code = req.status_code
    print(f'status code: {status_code}')
    time.sleep(1)
    if status_code == 200:
        continue
    else:
        contagem = contagem + 1
