import os
import pandas as pd
import joblib
from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from enum import Enum

# Initialize FastAPI
app = FastAPI(title="Astronaut Health API")

# Load predictive model
model = joblib.load("astro_model_realistic.pkl")

# Initialize Mistral client
client = OpenAI(
    base_url="https://router.huggingface.co/v1",
    api_key=os.environ["HF_TOKEN"],
)

# Which tab is selected
class SelectionEnum(str, Enum):
    cognitive = "cognitive"
    stress = "stress"
    cardiovascular = "cardiovascular"

# Define input schema for POST requests
class AstroData(BaseModel):
    activeEnergyBurned: float
    vo2Max: float
    lowCardioFitnessEvent: int
    height: float
    bodyMass: float
    bodyMassIndex: float
    leanBodyMass: float
    bodyFatPercentage: float
    heartRate: int
    lowHeartRateEvent: int
    highHeartRateEvent: int
    oxygenSaturation: int
    bodyTemperature: float
    bloodPressure_systolic: int
    bloodPressure_diastolic: int
    respiratoryRate: int
    sleepAnalysis_hours: float
    uvExposure_minutes: float
    selection: SelectionEnum

@app.post("/evaluate")
def evaluate_astronaut(data: AstroData):
    # Convert input to DataFrame for predictive model
    df = pd.DataFrame([data.dict(exclude={"selection"})])
    scores = model.predict(df)[0]

    # Map scores
    cognitiveScore = scores[0]
    stressScore = scores[1]
    heartRate = data.heartRate
    bpO2 = data.oxygenSaturation

    # Build dynamic prompt based on selection
    if data.selection == SelectionEnum.cardiovascular:
        prompt = f"You are a medical assistant evaluating astronaut vitals. Give a short assessment: Good or Bad. If Bad, give 3 concise tips tailored for astronauts in space. Any value outside the normal range should be considered unhealthy. HR: {heartRate}, BpO2: {bpO2}"
    elif data.selection == SelectionEnum.cognitive:
        prompt = f"You are a medical assistant evaluating an astronaut's cognitive function. Cognitive function score ranges from 0 (best) to 100 (extremely impaired). Provide concise tips if impairment is detected.\nScore: {cognitiveScore}"
    else:  # stress
        prompt = f"You are a medical assistant evaluating an astronaut's stress level. Provide a short assessment (Good/Bad) and 3 concise tips if stressed.\nScore: {stressScore}"

    # Query LLM
    completion = client.chat.completions.create(
        model="mistralai/Mistral-7B-Instruct-v0.2:featherless-ai",
        messages=[{"role": "user", "content": f"<s>[INST]{prompt}[/INST]"}],
    )

    return {
        "selection": data.selection,
        "score": {
            "cognitive": cognitiveScore,
            "stress": stressScore,
            "HR": heartRate,
            "BpO2": bpO2
        },
        "llm_output": completion.choices[0].message.content
    }
