import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import OpenAI from "openai";

admin.initializeApp();
const db = admin.firestore();

type QuestionStep = {
  stepNumber: number;
  title: string;
  explanation: string;
  result: string;
};

type QuestionAnalysis = {
  lesson: string;
  category: string;
  generalMethod: string;
  steps: QuestionStep[];
  finalAnswer: string;
};


function setCors(res: any) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

async function getUidFromRequest(req: any): Promise<string> {
  const authHeader = req.headers.authorization || req.headers.Authorization;
  if (!authHeader || typeof authHeader !== "string") {
    throw new Error("Authorization header eksik.");
  }

  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    throw new Error("Geçersiz Authorization formatı.");
  }

  const idToken = match[1];
  const decoded = await admin.auth().verifyIdToken(idToken);

  if (!decoded?.uid) {
    throw new Error("Geçersiz kullanıcı kimliği.");
  }

  return decoded.uid;
}

function sanitizeAnalysis(data: any): QuestionAnalysis {
  const steps: QuestionStep[] = Array.isArray(data?.steps)
    ? data.steps
        .slice(0, 12)
        .map((step: any, index: number) => ({
          stepNumber:
            typeof step?.stepNumber === "number" ? step.stepNumber : index + 1,
          title: typeof step?.title === "string" ? step.title.trim() : "",
          explanation:
            typeof step?.explanation === "string"
              ? step.explanation.trim().slice(0, 120)
              : "",
          result: typeof step?.result === "string" ? step.result.trim() : "",
        }))
        .filter(
          (step: QuestionStep) => step.title || step.explanation || step.result
        )
    : [];

  return {
    lesson: typeof data?.lesson === "string" ? data.lesson.trim() : "",
    category: typeof data?.category === "string" ? data.category.trim() : "",
    generalMethod:
      typeof data?.generalMethod === "string"
        ? data.generalMethod.trim().slice(0, 150)
        : "",
    steps,
    finalAnswer:
      typeof data?.finalAnswer === "string" ? data.finalAnswer.trim() : "",
  };
}



function looksLikeIntermediateAnswer(answer: string): boolean {
  const a = answer.trim().toLowerCase();

  if (!a) return true;

  return (
    a.startsWith("x=") ||
    a.startsWith("x =") ||
    a.startsWith("y=") ||
    a.startsWith("y =") ||
    a.startsWith("n=") ||
    a.startsWith("n =") ||
    a.startsWith("k=") ||
    a.startsWith("k =") ||
    a.startsWith("m=") ||
    a.startsWith("m =") ||
    a.startsWith("v=") ||
    a.startsWith("v =") ||
    a.startsWith("p(") ||
    a.includes("olasılık") ||
    a.includes("oran") ||
    a.includes("denklem") ||
    a.includes("eşitlik") ||
    a.includes("kök") ||
    a.includes("bulunur") ||
    a.includes("olur") ||
    (a.includes("=") && !/^[-\d\s.,/]+$/.test(a))
  );
}



function extractNumericCandidate(text: string): string | null {
  const cleaned = text.trim();

  const direct = cleaned.match(/^-?\d+([.,]\d+)?(\/\d+)?$/);
  if (direct) return direct[0];

  const endNumber = cleaned.match(/(-?\d+([.,]\d+)?(\/\d+)?)\s*$/);
  if (endNumber) return endNumber[1];

  return null;
}

function normalizeFinalAnswer(analysis: QuestionAnalysis): QuestionAnalysis {
  const finalAnswer = analysis.finalAnswer?.trim() ?? "";

const currentAnswer = extractNumericCandidate(finalAnswer) ?? finalAnswer;
const isCurrentValid =
  currentAnswer.length > 0 &&
  !looksLikeIntermediateAnswer(currentAnswer);

  if (isCurrentValid) {
    analysis.finalAnswer = currentAnswer;
    return analysis;
  }

  for (let i = analysis.steps.length - 1; i >= 0; i--) {
    const rawCandidate = analysis.steps[i]?.result?.trim() ?? "";
    if (!rawCandidate) continue;

    const candidate = extractNumericCandidate(rawCandidate) ?? rawCandidate;

    if (!candidate) continue;
    if (looksLikeIntermediateAnswer(candidate)) continue;

    analysis.finalAnswer = candidate;
    return analysis;
  }

  return analysis;
}

function isValidAnalysis(analysis: QuestionAnalysis): boolean {
  return (
    analysis.lesson.length > 0 &&
    analysis.finalAnswer.length > 0 &&
    analysis.steps.length >= 3
  );
}

export const helloWorld = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "512MiB",
    secrets: ["OPENAI_API_KEY"],
  },
  async (req, res) => {
    setCors(res);

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({
        success: false,
        error: "Sadece POST desteklenir.",
      });
      return;
    }

    try {
      const uid = await getUidFromRequest(req);
      const { questionId, imageUrl } = req.body ?? {};

      if (!questionId || !imageUrl) {
        res.status(400).json({
          success: false,
          error: "questionId ve imageUrl zorunludur.",
        });
        return;
      }

      if (!process.env.OPENAI_API_KEY) {
        res.status(500).json({
          success: false,
          error: "OPENAI_API_KEY bulunamadı.",
        });
        return;
      }

      const client = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY,
      });

      const questionRef = db.collection("questions").doc(String(questionId));
      const userRef = db.collection("users").doc(uid);

      const existingQuestionSnap = await questionRef.get();

      const baseQuestionData: Record<string, any> = {
        userId: uid,
        imageUrl: String(imageUrl),
        status: "processing",
        errorMessage: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (!existingQuestionSnap.exists) {
        baseQuestionData.createdAt = admin.firestore.FieldValue.serverTimestamp();
        baseQuestionData.creditCharged = false;
      }

      await questionRef.set(baseQuestionData, { merge: true });

      const prompt = `
Görseldeki soruyu çöz ve yalnızca geçerli JSON döndür.

Kurallar:
- Yalnızca görseldeki bilgileri kullan.
- lesson yalnızca: Matematik, Fizik, Kimya, Biyoloji.
- category yalnızca konu adı olsun.
- Çözüm lise düzeyinde ve en kısa yöntemle olsun.
- Gereksiz değişken, tekrar eden işlem veya uzun açıklama kullanma.
- Soruyu sonuca kadar çöz; ara sonuçta bırakma.
- Şıklı sorularda gerçek sonucu bul; şık harfi yazma.
- En fazla 8 adım kullan.
- Her adım kısa olsun: title 2-4 kelime, explanation tek kısa cümle, result yalnızca sonuç.
- Son adım sorunun istediği nihai sonucu içersin.
- finalAnswer son step.result ile aynı olsun.
- finalAnswer yalnızca sonuç olsun. Örnek: "5/24", yanlış: "x = 5/24"
- generalMethod tek kısa cümle olsun.

Derslere göre:
- Matematikte türev, integral, limit kullanma.
- Üslü sayılarda uygunsa tabanları eşitle.
- Fizikte yatay ve düşey hareketleri ayrı düşün.
- Kimyada mol, oran ve korunum kullan.
- Biyolojide yalnızca verilen bilgiye dayan.

JSON:
{
  "lesson": "",
  "category": "",
  "generalMethod": "",
  "steps": [
    {
      "stepNumber": 1,
      "title": "",
      "explanation": "",
      "result": ""
    }
  ],
  "finalAnswer": ""
}
`;

      const response = await client.chat.completions.create({
        model: "gpt-5-mini",
        response_format: { type: "json_object" },
        messages: [
          {
            role: "system",
            content: prompt,
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "Bu soru görselini çöz ve yalnızca JSON döndür.",
              },
              {
                type: "image_url",
                image_url: {
                  url: String(imageUrl),
                },
              },
            ] as any,
          },
        ],
      });

      const raw = response.choices[0]?.message?.content ?? "{}";
      const parsed = JSON.parse(raw);
      const analysis = normalizeFinalAnswer(sanitizeAnalysis(parsed));

      if (!isValidAnalysis(analysis)) {
        throw new Error("Geçerli çözüm üretilemedi.");
      }

      let remainingCredits = 0;

      await db.runTransaction(async (tx) => {
        const [userSnap, questionSnap] = await Promise.all([
          tx.get(userRef),
          tx.get(questionRef),
        ]);

        if (!userSnap.exists) {
          throw new Error("Kullanıcı dokümanı bulunamadı.");
        }

        if (!questionSnap.exists) {
          throw new Error("Soru dokümanı bulunamadı.");
        }

        const userData = userSnap.data() || {};
        const questionData = questionSnap.data() || {};

        const alreadyCharged = Boolean(questionData.creditCharged);
        const currentCredits = Number(userData.credits || 0);

        if (!alreadyCharged) {
          if (currentCredits <= 0) {
            throw new Error("Yeterli analiz hakkı yok.");
          }

          remainingCredits = currentCredits - 1;

          tx.update(userRef, {
            credits: admin.firestore.FieldValue.increment(-1),
            totalAnalyses: admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          remainingCredits = currentCredits;
        }

        tx.set(
          questionRef,
          {
            userId: uid,
            imageUrl: String(imageUrl),
            status: "completed",
            creditCharged: true,
            lesson: analysis.lesson,
            category: analysis.category,
            generalMethod: analysis.generalMethod,
            steps: analysis.steps,
            finalAnswer: analysis.finalAnswer,
            errorMessage: null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      });

      res.status(200).json({
        success: true,
        questionId,
        remainingCredits,
        data: analysis,
      });
    } catch (error: any) {
      logger.error("helloWorld analyze error", error);

      const { questionId } = req.body ?? {};
      if (questionId) {
        await db
          .collection("questions")
          .doc(String(questionId))
          .set(
            {
              status: "failed",
              errorMessage: error?.message ?? "Bilinmeyen hata",
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
      }

      const message = error?.message ?? "Bilinmeyen hata";
      const lower = String(message).toLowerCase();

      const statusCode =
        lower.includes("authorization") || lower.includes("token")
          ? 401
          : lower.includes("zorunludur")
          ? 400
          : lower.includes("yeterli analiz hakkı yok")
          ? 409
          : 500;

      res.status(statusCode).json({
        success: false,
        error: message,
      });
    }
  }
);

export const rewardUserForAd = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (req, res) => {
    setCors(res);

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({
        success: false,
        error: "Sadece POST desteklenir.",
      });
      return;
    }

    try {
      const uid = await getUidFromRequest(req);

      const {
        eventId,
        rewardAmount = 1,
        rewardType = "credit",
        platform = "unknown",
        adUnit = "rewarded_credit",
        sourceScreen = "credits_dialog",
      } = req.body ?? {};

      if (!eventId || String(eventId).trim().length < 5) {
        res.status(400).json({
          success: false,
          error: "Geçerli bir eventId zorunludur.",
        });
        return;
      }

      if (rewardType !== "credit") {
        res.status(400).json({
          success: false,
          error: "Geçersiz rewardType.",
        });
        return;
      }

      if (Number(rewardAmount) !== 1) {
        res.status(400).json({
          success: false,
          error: "Şimdilik yalnızca 1 hak verilebilir.",
        });
        return;
      }

      const userRef = db.collection("users").doc(uid);
      const rewardRef = db.collection("rewards").doc(String(eventId));

      let newCredits = 0;
      let duplicate = false;

      await db.runTransaction(async (tx) => {
        const [userSnap, rewardSnap] = await Promise.all([
          tx.get(userRef),
          tx.get(rewardRef),
        ]);

        if (!userSnap.exists) {
          throw new Error("Kullanıcı dokümanı bulunamadı.");
        }

        const userData = userSnap.data() || {};
        const currentCredits = Number(userData.credits || 0);

        if (rewardSnap.exists) {
          duplicate = true;
          newCredits = currentCredits;
          return;
        }

        newCredits = currentCredits + 1;

        tx.update(userRef, {
          credits: admin.firestore.FieldValue.increment(1),
          rewardedAdsWatched: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        tx.set(rewardRef, {
          userId: uid,
          type: "rewarded_ad",
          rewardType: "credit",
          rewardAmount: 1,
          status: "earned",
          platform: String(platform),
          adUnit: String(adUnit),
          sourceScreen: String(sourceScreen),
          eventId: String(eventId),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      res.status(200).json({
        success: true,
        duplicate,
        addedCredits: duplicate ? 0 : 1,
        credits: newCredits,
      });
    } catch (error: any) {
      logger.error("rewardUserForAd error", error);

      const message = error?.message ?? "Bilinmeyen hata";
      const lower = String(message).toLowerCase();

      const statusCode =
        lower.includes("authorization") || lower.includes("token")
          ? 401
          : lower.includes("eventid") || lower.includes("geçersiz")
          ? 400
          : 500;

      res.status(statusCode).json({
        success: false,
        error: message,
      });
    }
  }
);