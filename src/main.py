
from factory.agent_factory import create_agent

def main():
    agent = create_agent('openai', 'gpt-4')
    response = agent.respond("Hello, how are you?")
    print(response)

    agent = create_agent('llama', 'lama3-8b')
    response = agent.respond("What is the weather today?")
    print(response)

if __name__ == "__main__":
    main()


import os
from datetime import datetime

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse, HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel

# GET/POST are indifferent (curl http://localhost:8000/ping)

app = FastAPI()  # uvicorn main:app --reload (sandbox)
# http://127.0.0.1:8000/
# http://127.0.0.1:8000/docs/

templates = Jinja2Templates(directory=".")


@app.get("/", response_class=HTMLResponse)
async def root(request: Request):

    # fmt: off
    links = [
        {"href": "/agents", "text": "Agents", "description": "Responses endpoint"},
        {"href": "/service", "text": "Service", "description": "n/a"},
        {"href": "/items", "text": "Items", "description": "n/a"},
        {"href": "/ping", "text": "Ping", "description": "Send the ball to see if it bounces back"},
    ]
    return templates.TemplateResponse("index.html", {"request": request, "links": links})
    # fmt: on


@app.api_route("/ping", methods=["GET", "POST"])
async def ping():
    """To check if the server is running."""
    print("Got /ping...")
    return JSONResponse(
        status_code=200,
        content={"ping": "pong"},
    )

generations = {}

class GenerationPayload(BaseModel):

    name: str
    generation: str
    datetime: datetime


@app.post("/agents/")
async def upload_generation(payload: GenerationPayload):
    generations[payload.name] = {"generation": payload.generation, "datetime": payload.datetime}
    return {"message": "Generation uploaded successfully"}


@app.get("/agents/{name}")
async def get_generation(name: str):
    if name in generations:
        return JSONResponse(status_code=200, content={"generations": generations[name]})
    raise HTTPException(status_code=404, detail="Agent not found")
