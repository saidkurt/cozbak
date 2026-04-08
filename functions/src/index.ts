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
  recognizedQuestion: string;
  generalMethod: string;
  steps: QuestionStep[];
  finalAnswer: string;
  commonMistake: string;
  tips: string;
  similarQuestion: string;
};

type ExpectedAnswerType = "number" | "option" | "name" | "set" | "unknown";

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
    recognizedQuestion:
      typeof data?.recognizedQuestion === "string"
        ? data.recognizedQuestion.trim()
        : "",
    generalMethod:
      typeof data?.generalMethod === "string"
        ? data.generalMethod.trim().slice(0, 150)
        : "",
    steps,
    finalAnswer:
      typeof data?.finalAnswer === "string" ? data.finalAnswer.trim() : "",
    commonMistake:
      typeof data?.commonMistake === "string"
        ? data.commonMistake.trim().slice(0, 120)
        : "",
    tips:
      typeof data?.tips === "string" ? data.tips.trim().slice(0, 120) : "",
    similarQuestion:
      typeof data?.similarQuestion === "string"
        ? data.similarQuestion.trim().slice(0, 120)
        : "",
  };
}

function detectExpectedAnswerType(question: string): ExpectedAnswerType {
  const q = question.toLowerCase();

  if (
    q.includes("kaçtır") ||
    q.includes("kaç top") ||
    q.includes("kaç kişi") ||
    q.includes("kaç sayı") ||
    q.includes("kaç mol") ||
    q.includes("kaç gram") ||
    q.includes("kaç kg") ||
    q.includes("kaç metre") ||
    q.includes("kaç cm") ||
    q.includes("kaç m") ||
    q.includes("kaç derece") ||
    q.includes("kaç saat") ||
    q.includes("kaç dakika") ||
    q.includes("kaç saniye") ||
    q.includes("toplam kaç") ||
    q.includes("en az kaç") ||
    q.includes("en çok kaç") ||
    q.includes("kaç olur") ||
    q.includes("sonuç kaç")
  ) {
    return "number";
  }

  if (
    q.includes("hangisidir") ||
    q.includes("hangi seçen") ||
    q.includes("doğru seçenek") ||
    q.includes("yanlış seçenek")
  ) {
    return "option";
  }

  if (q.includes("hangileri")) {
    return "set";
  }

  if (
    q.includes("hangi madde") ||
    q.includes("hangi bileşik") ||
    q.includes("hangi element") ||
    q.includes("hangi gezegen") ||
    q.includes("hangi yapı")
  ) {
    return "name";
  }

  return "unknown";
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

function isPureNumberAnswer(answer: string): boolean {
  const a = answer.trim();
  return /^-?\d+([.,]\d+)?(\/\d+)?$/.test(a);
}

function matchesExpectedAnswerType(question: string, answer: string): boolean {
  const expected = detectExpectedAnswerType(question);
  const a = answer.trim();

  switch (expected) {
    case "number":
      return isPureNumberAnswer(a);

    case "option":
      return /^[abcde]\)?$/i.test(a) || /^[1-5]\)?$/.test(a) || a.length <= 20;

    case "name":
      return a.length > 0 && !looksLikeIntermediateAnswer(a);

    case "set":
      return a.length > 0;

    default:
      return a.length > 0;
  }
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
  const question = analysis.recognizedQuestion?.trim() ?? "";
  const finalAnswer = analysis.finalAnswer?.trim() ?? "";

  const currentAnswer =
    detectExpectedAnswerType(question) === "number"
      ? extractNumericCandidate(finalAnswer) ?? finalAnswer
      : finalAnswer;

  const isCurrentValid =
    currentAnswer.length > 0 &&
    !looksLikeIntermediateAnswer(currentAnswer) &&
    matchesExpectedAnswerType(question, currentAnswer);

  if (isCurrentValid) {
    analysis.finalAnswer = currentAnswer;
    return analysis;
  }

  for (let i = analysis.steps.length - 1; i >= 0; i--) {
    const rawCandidate = analysis.steps[i]?.result?.trim() ?? "";
    if (!rawCandidate) continue;

    const candidate =
      detectExpectedAnswerType(question) === "number"
        ? extractNumericCandidate(rawCandidate) ?? rawCandidate
        : rawCandidate;

    if (!candidate) continue;
    if (looksLikeIntermediateAnswer(candidate)) continue;
    if (!matchesExpectedAnswerType(question, candidate)) continue;

    analysis.finalAnswer = candidate;
    return analysis;
  }

  return analysis;
}

function isValidAnalysis(analysis: QuestionAnalysis): boolean {
  return (
    analysis.lesson.length > 0 &&
    analysis.recognizedQuestion.length > 5 &&
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
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

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

    const { questionId, imageUrl, userId } = req.body ?? {};

    if (!questionId || !imageUrl || !userId) {
      res.status(400).json({
        success: false,
        error: "questionId, imageUrl ve userId zorunludur.",
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
    const userRef = db.collection("users").doc(String(userId));

    try {
      await questionRef.set(
        {
          userId: String(userId),
          imageUrl: String(imageUrl),
          status: "processing",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    const prompt = `
Görseldeki soruyu çöz ve yalnızca geçerli JSON döndür.

Kurallar:
- Yalnızca görseldeki bilgileri kullan.
- lesson yalnızca: Matematik, Fizik, Kimya, Biyoloji.
- category yalnızca konu adı olsun.
- recognizedQuestion soruyu eksiksiz ve temiz biçimde yazsın.
- Çözüm lise düzeyinde olsun.
- Soruda istenen sonuca kadar çöz; ara sonuçta bırakma.
- Mümkün olan en kısa, en doğal ve öğrencinin sınavda uygulayacağı yöntemi tercih et.
- Gereksiz değişken, genel formül veya karmaşık sembol tanımlama.
- Önce basit ilişki, uzaklık, oran, eşitlik veya şekil bilgisiyle çözülebiliyorsa onu kullan.
- Şıklı sorularda önce gerçek sonucu bul; finalAnswer yalnızca doğru sonuç olsun, şık harfi yazma.
- Steps genelde 3-8, gerekirse en fazla 12 adım olsun.
- Her step bir öncekinin mantıklı devamı olsun.
- Aynı bilgiyi tekrar eden veya gereksiz adım oluşturma.
- title 2-5 kelime, kısa ve doğal olsun.
- explanation tamamlanmış tek kısa cümle olsun; yarım cümle yazma.
- result yalnızca o adımda elde edilen kısa sonuç olsun.
- result sayı, kesir, denklem, ifade veya kısa kısa cümle olabilir.
- Son step.result yalnızca soruda istenen nihai sonucu içersin.
- Son adım başlığı "Nihai sonuç", "Aranan değer", "Yarıçap", "Olasılık", "Hız", "Kütle" gibi doğal bir başlık olsun; "Doğru seçenek" yazma.
- finalAnswer son step.result ile tamamen aynı olmalıdır.
- finalAnswer içinde "=", açıklama, işlem, birim dışı metin veya ara sonuç bulunamaz.
- Soru sayı, kesir, oran, aralık, kök, ifade veya sembol istiyorsa finalAnswer yalnızca o sonucu içersin.
- generalMethod, commonMistake ve tips yalnızca 1 kısa cümle olsun.
- similarQuestion aynı konudan kısa bir örnek soru olsun.

Derslere göre:
- Matematikte yalnızca gerekli temel yöntemleri kullan; türev, integral, limit kullanma.
- Olasılıkta durumları ayrı hesaplayıp topla; toplam olasılık 1'dir.
- Geometri ve analitikte mümkünse önce şekilden veya doğrular arası uzaklıktan yararlan; gereksiz değişken tanımlama.
- Üslü sayılarda uygun ise tabanları eşitle.
- Kök sorularında köklerin toplamı ve çarpımını doğru kullan.
- Karmaşık sayılarda i² = -1.
- Minimum/maksimum sorularında önce sonucun hangi durumda oluştuğunu belirle.
- Fizikte yatay ve düşey hareketleri ayrı düşün; verilen bağıntıyı doğrudan kullan.
- Kimyada tepkime, mol, oran ve korunum ilişkilerini kullan.
- Biyolojide yalnızca verilen bilgiye dayan.

Doğru örnek:
"result": "5/24"
"finalAnswer": "5/24"

Yanlış örnek:
"result": "x = 5/24"
"finalAnswer": "x = 5/24"

JSON:
{
  "lesson": "",
  "category": "",
  "recognizedQuestion": "",
  "generalMethod": "",
  "steps": [
    {
      "stepNumber": 1,
      "title": "",
      "explanation": "",
      "result": ""
    }
  ],
  "finalAnswer": "",
  "commonMistake": "",
  "tips": "",
  "similarQuestion": ""
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

      await questionRef.set(
        {
          userId: String(userId),
          imageUrl: String(imageUrl),
          status: "completed",
          lesson: analysis.lesson,
          category: analysis.category,
          recognizedQuestion: analysis.recognizedQuestion,
          generalMethod: analysis.generalMethod,
          steps: analysis.steps,
          finalAnswer: analysis.finalAnswer,
          commonMistake: analysis.commonMistake,
          tips: analysis.tips,
          similarQuestion: analysis.similarQuestion,
          errorMessage: null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      await userRef.set(
        {
          totalAnalyses: admin.firestore.FieldValue.increment(1),
          credits: admin.firestore.FieldValue.increment(-1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      res.status(200).json({
        success: true,
        questionId,
        data: analysis,
      });
    } catch (error: any) {
      logger.error("helloWorld analyze error", error);

      await questionRef.set(
        {
          status: "failed",
          errorMessage: error?.message ?? "Bilinmeyen hata",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      res.status(500).json({
        success: false,
        error: error?.message ?? "Bilinmeyen hata",
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
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

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
      const {
        uid,
        rewardAmount = 1,
        rewardType = "credit",
        platform = "unknown",
        adUnit = "rewarded_credit",
        sourceScreen = "credits_dialog",
      } = req.body ?? {};

      if (!uid) {
        res.status(400).json({
          success: false,
          error: "uid zorunludur.",
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

      const userRef = db.collection("users").doc(String(uid));
      const rewardRef = db.collection("rewards").doc();

      let newCredits = 0;

      await db.runTransaction(async (tx) => {
        const userSnap = await tx.get(userRef);

        if (!userSnap.exists) {
          throw new Error("Kullanıcı dokümanı bulunamadı.");
        }

        const userData = userSnap.data() || {};
        const currentCredits = Number(userData.credits || 0);
        newCredits = currentCredits + 1;

        tx.update(userRef, {
          credits: admin.firestore.FieldValue.increment(1),
          rewardedAdsWatched: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        tx.set(rewardRef, {
          userId: String(uid),
          type: "rewarded_ad",
          rewardType: "credit",
          rewardAmount: 1,
          status: "earned",
          platform: String(platform),
          adUnit: String(adUnit),
          sourceScreen: String(sourceScreen),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      res.status(200).json({
        success: true,
        addedCredits: 1,
        credits: newCredits,
      });
    } catch (error: any) {
      logger.error("rewardUserForAd error", error);

      res.status(500).json({
        success: false,
        error: error?.message ?? "Bilinmeyen hata",
      });
    }
  }
);
