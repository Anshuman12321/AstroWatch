###TIGERHACKS 2025 - AADHI SATHISHKUMAR
import os
import pandas as pd
import joblib
from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from enum import Enum
from fastapi.middleware.cors import CORSMiddleware

# Initialize FastAPI
app = FastAPI(title="Astronaut Health API")

# Put this here cuz we had a lot of trouble getting iOS to communicate via http. 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load predictive model
model = joblib.load("astro_model_realistic.pkl")

# Initialize Mistral client
client = OpenAI(
    base_url="https://router.huggingface.co/v1",
    api_key=os.environ["HF_TOKEN"],
)

# Which tab is selected determines this, can only be one of three
class SelectionEnum(str, Enum):
    cognitive = "cognitive"
    stress = "stress"
    cardiovascular = "cardiovascular"

# Define input for POST requests that correlate with the predictive model's params
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

#POST methods here
@app.post("/evaluate")
def evaluate_astronaut(data: AstroData):
    # Convert input to DataFrame for predictive model
    df = pd.DataFrame([data.dict(exclude={"selection"})])
    scores = model.predict(df)[0]

    # Map scores to variables I'll use to prompt the llm
    cognitiveScore = scores[0]
    stressScore = scores[1]
    heartRate = data.heartRate
    bpO2 = data.oxygenSaturation

    # Build dynamic prompt based on selection
    if data.selection == SelectionEnum.cardiovascular:
        prompt = f"<s>[INST]DO NOT INCLUDE NEWLINES. You are a medical assistant evaluating astronaut vitals. Give a short assessment: Good or Bad. If Bad, give 3 concise tips tailored for astronauts in space. Any value outside the normal range should be considered unhealthy. IF HEALTHY NO NEED TO GIVE TIPS, simply say the astronaut has good vitals HR: {heartRate}, BpO2: {bpO2}[/INST]</s>"
    elif data.selection == SelectionEnum.cognitive:
        prompt = f"<s>[INST]DO NOT INCLUDE NEWLINES. You are a medical assistant evaluating an astronaut's cognitive function. Cognitive function score ranges from 0 (worst) to 100 (best). Provide concise tips if impairment is detected. If cognitive score is within healthy range, DO NOT GIVE ANY TIPS. Score: {cognitiveScore}[/INST]</s>"
    else:  # stress
        prompt = f"<s>[INST]DO NOT INCLUDE NEWLINES. You are a medical assistant evaluating an astronaut's stress level. Stress score ranges from 0 (worst) to 100 (best) Provide a short assessment (Good/Bad) and 3 concise tips if stressed. If stress score is not bellow 70, do not give tips. Score: {stressScore}[/INST]</s>"

    # Query LLM
    completion = client.chat.completions.create(
        model="mistralai/Mistral-7B-Instruct-v0.2:featherless-ai",
        messages=[{"role": "user", "content": f"<s>[INST]{prompt}[/INST]"}],
    )

    llmResponse = completion.choices[0].message.content
    #return to sender!
    return llmResponse

