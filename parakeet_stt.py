"""
Parakeet TDT STT Plugin for LiveKit Agents
Uses the OpenAI-compatible API of the Parakeet TDT transcription service
"""

import os
import io
import aiohttp
from typing import Optional
from livekit.agents import stt, utils


class STT(stt.STT):
    """
    Parakeet TDT Speech-to-Text implementation using OpenAI-compatible API
    """

    def __init__(
        self,
        *,
        base_url: str = "http://localhost:5092/v1",
        model: str = "parakeet-tdt-0.6b-v3",
        api_key: str = "sk-no-key-required",
        language: Optional[str] = None,  # Parakeet auto-detects language
    ):
        """
        Initialize Parakeet STT
        
        Args:
            base_url: Base URL of the Parakeet API server
            model: Model name (default: parakeet-tdt-0.6b-v3)
            api_key: API key (default: sk-no-key-required for local deployment)
            language: Language code (optional, auto-detected by default)
        """
        super().__init__(streaming_supported=False)
        self._base_url = base_url.rstrip("/")
        self._model = model
        self._api_key = api_key
        self._language = language

    async def recognize(
        self,
        buffer: utils.AudioBuffer,
        *,
        language: Optional[str] = None,
    ) -> stt.SpeechEvent:
        """
        Recognize speech from audio buffer
        
        Args:
            buffer: Audio buffer containing the speech
            language: Optional language override (auto-detected if not provided)
            
        Returns:
            SpeechEvent containing the transcription
        """
        # Merge audio frames into a single buffer
        audio_data = utils.merge_frames(buffer)
        
        # Convert to WAV format (16kHz, mono, 16-bit PCM)
        wav_data = utils.audio.AudioByteStream(
            sample_rate=buffer.sample_rate,
            num_channels=buffer.num_channels,
        )
        wav_data.write(audio_data.data.tobytes())
        wav_bytes = wav_data.flush()
        
        # Prepare the multipart form data
        form_data = aiohttp.FormData()
        form_data.add_field(
            "file",
            io.BytesIO(wav_bytes),
            filename="audio.wav",
            content_type="audio/wav",
        )
        form_data.add_field("model", self._model)
        form_data.add_field("response_format", "json")
        
        if language or self._language:
            form_data.add_field("language", language or self._language)
        
        # Make the API request
        url = f"{self._base_url}/audio/transcriptions"
        headers = {
            "Authorization": f"Bearer {self._api_key}",
        }
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.post(url, data=form_data, headers=headers) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        raise Exception(
                            f"Parakeet API error: {response.status} - {error_text}"
                        )
                    
                    result = await response.json()
                    text = result.get("text", "")
                    
                    # Create alternatives list (Parakeet doesn't provide alternatives)
                    # Language is set to empty string when not specified, as Parakeet auto-detects
                    alternatives = [
                        stt.SpeechData(
                            text=text,
                            language=self._language or "",  # Empty string for auto-detected language
                        )
                    ]
                    
                    return stt.SpeechEvent(
                        type=stt.SpeechEventType.FINAL_TRANSCRIPT,
                        alternatives=alternatives,
                    )
                    
        except Exception as e:
            # Return an error event with context
            return stt.SpeechEvent(
                type=stt.SpeechEventType.ERROR,
                error=f"Parakeet STT transcription failed: {str(e)}",
            )
