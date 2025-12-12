import os
from dotenv import load_dotenv

from livekit import agents
from livekit.agents import AgentSession, Agent, RoomInputOptions
from livekit.plugins import noise_cancellation, silero, deepgram, openai
from livekit.plugins.turn_detector.multilingual import MultilingualModel


load_dotenv(".env.local")


class Assistant(Agent):
    def __init__(self) -> None:
        super().__init__(
            instructions="""You are a helpful voice AI assistant.
            You eagerly assist users with their questions by providing information from your extensive knowledge.
            Your responses are concise, to the point, and without any complex formatting or punctuation including emojis, asterisks, or other symbols.
            You are curious, friendly, and have a sense of humor.""",
        )


async def entrypoint(ctx: agents.JobContext):
    # Configure LLM based on provider (supports OpenAI-compatible APIs)
    llm_provider = os.getenv("LLM_PROVIDER", "openai")
    llm_base_url = os.getenv("LLM_BASE_URL")
    llm_model = os.getenv("LLM_MODEL", "gpt-4o-mini")
    llm_api_key = os.getenv("OPENAI_API_KEY", "not-needed")
    
    # Create LLM instance (all providers use OpenAI-compatible interface)
    if llm_base_url:
        # Local providers: vLLM, Ollama, LM Studio (all OpenAI-compatible)
        llm = openai.LLM(
            model=llm_model,
            base_url=llm_base_url,
            api_key=llm_api_key,
        )
    else:
        # Default OpenAI
        llm = openai.LLM(model=llm_model)
    
    # Configure TTS (KaniTTS server with Spanish model)
    tts_base_url = os.getenv("KANI_BASE_URL", "http://localhost:8000/v1")
    tts_model = os.getenv("TTS_MODEL", "nineninesix/kani-tts-400m-es")
    tts_voice = os.getenv("TTS_VOICE", "andrew")
    
    session = AgentSession(
        stt=deepgram.STTv2(
            model="flux-general-en",
            eager_eot_threshold=0.4,
        ),
        llm=llm,
        tts=openai.TTS(
            base_url=tts_base_url,
            model=tts_model,
            voice=tts_voice,
            response_format="pcm"
        ),
        vad=silero.VAD.load(),
        turn_detection=MultilingualModel(),
    )

    await session.start(
        room=ctx.room,
        agent=Assistant(),
        room_input_options=RoomInputOptions(
            # For telephony applications, use `BVCTelephony` instead for best results
            noise_cancellation=noise_cancellation.BVC(), 
        ),
    )

    await session.generate_reply(
        instructions="Greet the user and offer your assistance."
    )


if __name__ == "__main__":
    agents.cli.run_app(agents.WorkerOptions(entrypoint_fnc=entrypoint))