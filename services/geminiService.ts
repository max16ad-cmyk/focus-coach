
import { GoogleGenAI, Type } from "@google/genai";
import { LinkAnalysisResult, TaskAnalysisResult, AnalyzedTask, VerificationResult } from "../types";

// Initialize Gemini Client
let ai: GoogleGenAI | null = null;

try {
  // Try to get API key from environment or window
  const apiKey = process.env.GEMINI_API_KEY || (window as any).process?.env?.GEMINI_API_KEY || '';
  if (apiKey) {
    ai = new GoogleGenAI({ apiKey });
  } else {
    console.warn("API Key is missing. Gemini features will use fallback mode.");
  }
} catch (error) {
  console.error("Failed to initialize GoogleGenAI:", error);
}

export const breakdownGoal = async (goal: string): Promise<string[]> => {
  if (!ai) {
    return ["Define specific steps", "Set a timeframe", "Start working"];
  }

  try {
    const model = "gemini-2.5-flash";
    
    const response = await ai.models.generateContent({
      model,
      contents: `Break down the following goal into 3-5 concrete, actionable, short-term sub-tasks. 
      Goal: "${goal}". 
      Return ONLY a JSON array of strings. Keep tasks under 6 words each.`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
            type: Type.ARRAY,
            items: { type: Type.STRING }
        }
      }
    });

    if (response.text) {
        return JSON.parse(response.text) as string[];
    }
    return [];

  } catch (error) {
    console.error("Gemini Error:", error);
    return ["Identify the first step", "Work for 25 minutes", "Take a short break"];
  }
};

export const getAiMotivation = async (penaltyCount: number): Promise<string> => {
  if (!ai) return "Focus is the key to freedom.";

  try {
    const model = "gemini-2.5-flash";
    const response = await ai.models.generateContent({
      model,
      contents: `The user is trying to unlock their distractions without finishing work. They have used the emergency unlock ${penaltyCount} times. Give them a short, witty, slightly sarcastic one-sentence reason to keep working.`,
    });

    return response.text || "Focus is the key to freedom.";
  } catch (error) {
    return "Don't give up now! Discipline equals freedom.";
  }
};

export const verifyTaskWithImage = async (taskTitle: string, base64Image: string): Promise<{ verified: boolean; feedback: string }> => {
    if (!ai) return { verified: true, feedback: "AI Offline: Auto-verified." };

    try {
        // Remove header from base64 string if present (data:image/jpeg;base64,...)
        const cleanBase64 = base64Image.split(',')[1] || base64Image;

        const model = "gemini-2.5-flash";
        const prompt = `Task: "${taskTitle}". 
        Look at this image. Does it provide reasonable proof that the task was completed or worked on?
        (e.g. if task is "gym", look for gym equipment. If "coding", look for a screen with code).
        
        Return JSON: { "verified": boolean, "feedback": "short 1 sentence reason" }`;

        const response = await ai.models.generateContent({
            model,
            contents: {
                parts: [
                    { text: prompt },
                    { inlineData: { mimeType: "image/jpeg", data: cleanBase64 } }
                ]
            },
            config: {
                responseMimeType: "application/json",
                responseSchema: {
                    type: Type.OBJECT,
                    properties: {
                        verified: { type: Type.BOOLEAN },
                        feedback: { type: Type.STRING }
                    }
                }
            }
        });

        if (response.text) {
            return JSON.parse(response.text) as { verified: boolean; feedback: string };
        }
        return { verified: false, feedback: "Could not analyze image." };

    } catch (error) {
        console.error("Image verification failed:", error);
        return { verified: true, feedback: "Verification bypassed (Error)." };
    }
};

export const analyzeUrlContent = async (url: string): Promise<LinkAnalysisResult> => {
    if (!ai) {
        // Fallback simulation
        const isTube = url.includes('youtube') || url.includes('netflix');
        return {
            isProductive: !isTube,
            category: isTube ? 'Entertainment' : 'Work',
            reason: "AI unavailable - Basic URL check.",
            suggestedName: "New Link"
        };
    }

    try {
        const model = "gemini-2.5-flash";
        const prompt = `Analyze this URL: "${url}".
        Determine if this content is likely "Productive/Educational" (e.g. coding tutorial, AI research, documentation, news) OR "Distraction/Entertainment" (e.g. gaming, social media, funny videos).
        
        Return JSON:
        {
            "isProductive": boolean,
            "category": string (e.g. "Coding", "Social Media", "AI", "Gaming"),
            "reason": string (short explanation),
            "suggestedName": string (short title for the link)
        }
        `;

        const response = await ai.models.generateContent({
            model,
            contents: prompt,
            config: {
                responseMimeType: "application/json",
                responseSchema: {
                    type: Type.OBJECT,
                    properties: {
                        isProductive: { type: Type.BOOLEAN },
                        category: { type: Type.STRING },
                        reason: { type: Type.STRING },
                        suggestedName: { type: Type.STRING }
                    }
                }
            }
        });

        if (response.text) {
            return JSON.parse(response.text) as LinkAnalysisResult;
        }
        throw new Error("Empty response");

    } catch (error) {
        console.error("Analysis failed", error);
        return {
            isProductive: false,
            category: "Unknown",
            reason: "Could not analyze content.",
            suggestedName: "Unknown Link"
        };
    }
}

// =============================================
// FOCUS COACH: TASK ANALYSIS
// =============================================

export const analyzeTasks = async (userInput: string): Promise<TaskAnalysisResult> => {
    if (!ai) {
        // Fallback: Simple parsing
        const tasks = userInput.split(/[.,;]/).filter(t => t.trim()).slice(0, 5).map((t, i) => ({
            id: `task-${i}`,
            title: t.trim(),
            category: 'Erledigung' as const,
            duration: 60,
            requiresProof: false,
            proofType: null as const,
            proofDescription: '',
            suggestedStartTime: `${9 + i}:00`,
            suggestedEndTime: `${10 + i}:00`,
        }));
        return {
            tasks,
            coachMessage: "Plan erstellt. Bitte überprüfe die Aufgaben."
        };
    }

    try {
        const model = "gemini-2.5-flash";
        const prompt = `Du bist ein strenger Produktivitäts-Coach. Analysiere die folgenden Aufgaben und erstelle einen strukturierten Tagesplan.

EINGABE: "${userInput}"

Für jede erkannte Aufgabe, liefere:

1. Aufgabenname (kurz, klar)
2. Kategorie (Lernen, Haushalt, Erledigung, Arbeit, Sport, Kreativ)
3. Geschätzte Dauer (in Minuten)
4. Ob ein Nachweis erforderlich ist (true/false)
5. Art des Nachweises wenn nötig (photo, document, screenshot)
6. Beschreibung des Nachweises
7. Vorgeschlagene Startzeit (HH:mm)
8. Vorgeschlagene Endzeit (HH:mm)

REGELN FÜR NACHWEISE:
- Lernen/Studieren → Foto von Notizen erforderlich
- Aufräumen/Putzen → Vorher/Nachher Foto erforderlich
- Sport/Training → Kein Nachweis (Ehrensystem)
- Einkaufen/Erledigungen → Kein Nachweis
- Kreative Arbeit → Screenshot oder Foto des Ergebnisses

Antworte NUR mit validem JSON:
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Aufgabenname",
      "category": "Kategorie",
      "duration": 60,
      "requiresProof": true,
      "proofType": "photo",
      "proofDescription": "Foto von deinen Mathe-Notizen",
      "suggestedStartTime": "09:00",
      "suggestedEndTime": "10:00"
    }
  ],
  "coachMessage": "Kurze Nachricht an den User über den Plan"
}`;

        const response = await ai.models.generateContent({
            model,
            contents: prompt,
            config: {
                responseMimeType: "application/json",
                responseSchema: {
                    type: Type.OBJECT,
                    properties: {
                        tasks: {
                            type: Type.ARRAY,
                            items: {
                                type: Type.OBJECT,
                                properties: {
                                    id: { type: Type.STRING },
                                    title: { type: Type.STRING },
                                    category: { type: Type.STRING },
                                    duration: { type: Type.NUMBER },
                                    requiresProof: { type: Type.BOOLEAN },
                                    proofType: { type: Type.STRING },
                                    proofDescription: { type: Type.STRING },
                                    suggestedStartTime: { type: Type.STRING },
                                    suggestedEndTime: { type: Type.STRING }
                                }
                            }
                        },
                        coachMessage: { type: Type.STRING }
                    }
                }
            }
        });

        if (response.text) {
            const result = JSON.parse(response.text) as TaskAnalysisResult;
            // Generate IDs for tasks if missing
            result.tasks = result.tasks.map((task, i) => ({
                ...task,
                id: task.id || `task-${Date.now()}-${i}`
            }));
            return result;
        }
        throw new Error("Empty response");

    } catch (error) {
        console.error("Task analysis failed:", error);
        // Fallback
        const tasks: AnalyzedTask[] = userInput.split(/[.,;]/).filter(t => t.trim()).slice(0, 5).map((t, i) => ({
            id: `task-${Date.now()}-${i}`,
            title: t.trim(),
            category: 'Erledigung' as const,
            duration: 60,
            requiresProof: false,
            proofType: null,
            proofDescription: '',
            suggestedStartTime: `${9 + i}:00`,
            suggestedEndTime: `${10 + i}:00`,
        }));
        return {
            tasks,
            coachMessage: "Plan erstellt. Bitte überprüfe die Aufgaben."
        };
    }
};

// =============================================
// FOCUS COACH: PROOF VERIFICATION
// =============================================

export const verifyProof = async (
    taskTitle: string,
    taskCategory: string,
    proofDescription: string,
    base64Image: string
): Promise<VerificationResult> => {
    if (!ai) {
        return {
            accepted: true,
            confidence: 0.5,
            reason: "AI offline - Auto-verifiziert",
            detectedElements: [],
            coachMessage: "Nachweis akzeptiert (AI offline)"
        };
    }

    try {
        const cleanBase64 = base64Image.split(',')[1] || base64Image;
        const model = "gemini-2.5-flash";
        
        const prompt = `Du bist ein strenger Produktivitäts-Coach. Prüfe, ob dieses Bild als Nachweis für die folgende Aufgabe ausreicht.

AUFGABE: "${taskTitle}"
KATEGORIE: "${taskCategory}"
ERWARTETER NACHWEIS: "${proofDescription}"

PRÜFKRITERIEN:
- Ist relevanter Inhalt erkennbar?
- Passt das Bild zur Aufgabe?
- Ist es ein echtes Foto (kein Screenshot von Google)?
- Zeigt es tatsächliche Arbeit/Ergebnis?

SEI STRENG aber FAIR. Kein Gaming des Systems erlauben.

Antworte NUR mit validem JSON:
{
  "accepted": true/false,
  "confidence": 0.0-1.0,
  "reason": "Begründung auf Deutsch",
  "detectedElements": ["Was du erkennst"],
  "coachMessage": "Direkte Nachricht an den User"
}`;

        const response = await ai.models.generateContent({
            model,
            contents: {
                parts: [
                    { text: prompt },
                    { inlineData: { mimeType: "image/jpeg", data: cleanBase64 } }
                ]
            },
            config: {
                responseMimeType: "application/json",
                responseSchema: {
                    type: Type.OBJECT,
                    properties: {
                        accepted: { type: Type.BOOLEAN },
                        confidence: { type: Type.NUMBER },
                        reason: { type: Type.STRING },
                        detectedElements: { type: Type.ARRAY, items: { type: Type.STRING } },
                        coachMessage: { type: Type.STRING }
                    }
                }
            }
        });

        if (response.text) {
            return JSON.parse(response.text) as VerificationResult;
        }
        throw new Error("Empty response");

    } catch (error) {
        console.error("Proof verification failed:", error);
        return {
            accepted: false,
            confidence: 0,
            reason: "Fehler bei der Analyse",
            detectedElements: [],
            coachMessage: "Konnte den Nachweis nicht prüfen. Bitte versuche es erneut."
        };
    }
};
