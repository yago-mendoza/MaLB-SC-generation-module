import time
from fastapi import FastAPI

from fastapi.responses import JSONResponse
import requests


def request_this_server():
    """This function could be called from a different script but I added it here to keep
    thigns together"""

    # Request 0
    try:
        o = requests.get("http://localhost:1234/ping")
        print(o.json())
    except Exception as e:
        print("Oh... I couldn't connect :c")
        print(e)

    # Request 1
    try:

        o = requests.post(
            "http://localhost:1234/process",
            json={
                "parameter_0": "hello",
                "parameter_1": 2,
            },
        )
        print(o.json())
    except Exception as e:
        print("Oh... I couldn't connect :c")
        print(e)


app = FastAPI()
# uvicorn main:app --reload

@app.get("/")
def root():
    return {"Hello":"World"}

@app.api_route("/ping", methods=["GET", "POST"])
async def ping():
    """To check if the server is running."""
    print("Got /ping...")
    return JSONResponse(status_code=200, content={"ping": "pong"})


@app.post("/process")
def process_data(parameter_0: str, parameter_1: int):
    """Do thingsssss"""
    print("Got /process...")

    def this_function_is_very_expensive_to_compute():
        time.sleep(4)
        return "done"

    this_function_is_very_expensive_to_compute()

    return JSONResponse(status_code=200, content={"result": "done"})


# requests for testing