from fastapi import FastAPI
from monitoring import metrics, metrics_middleware


app = FastAPI()

app.middleware("http")(metrics_middleware)


@app.get("/")
def root():
    return {"message": "Hello World!"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/metrics")
def metrics_endpoint():
    return metrics()