// transcribe.js
import fs from 'fs';
import { OpenAI } from 'openai';

const openai = new OpenAI({ apiKey: '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' });

async function transcribeAudio() {
  const audioStream = fs.createReadStream('./a2.mp3');

  const transcription = await openai.audio.transcriptions.create({
    file: audioStream,
    model: 'whisper-1',
    language: 'es',
    response_format: 'text',
  });

  console.log('Transcripción:', transcription);
}

transcribeAudio().catch(console.error);
