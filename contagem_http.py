import requests
import time
import os

contagem = 0

req = requests.head("http://localhost:8080/erro")
status_code = req.status_code
print(f'status code: {status_code}')

for i in contagem:
    if contagem <= 60:
        
        time.sleep(1)
    elif:
        contagem <= 60

    else:
        contagem == 60
        os.system('docker restart ')