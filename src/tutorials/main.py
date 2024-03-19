from fastapi import FastAPI, WebSocket

my_app = FastAPI()
# uvicorn main:my_app --reload

# http://127.0.0.1:8000/
# http://127.0.0.1:8000/docs/

@my_app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        data = await websocket.receive_text()
        await websocket.send_text(f"Message text was: {data}")

@my_app.get("/") # 'get' operation (just indicates)
async def root():
    return {"message": "Hello World"}

# path = endpoint = route

@my_app.get("/users/me")
async def read_user_me():
    return {"user_id": "the current user"}

@my_app.get("/users/{user_id}")
async def read_user(user_id: str):
    return {"user_id": user_id}

from enum import Enum

class ModelName(str, Enum):
    alexnet = "alexnet"
    resnet = "resnet"
    lenet = "lenet"

@my_app.get("/models/{model_name}")
async def get_model(model_name: ModelName): # enforces the arg to be in ModelName (Enum class)
    if model_name is ModelName.alexnet:
        return {"model_name": model_name, "message": "Deep Learning FTW!"}

    if model_name.value == "lenet":
        return {"model_name": model_name, "message": "LeCNN all the images"}

    return {"model_name": model_name, "message": "Have some residuals"}