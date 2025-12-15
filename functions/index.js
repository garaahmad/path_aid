const { setGlobalOptions } = require("firebase-functions");
const { onCall } = require("firebase-functions/v2/https");
const axios = require("axios");

// الحد الأقصى للحاويات المتزامنة لكل Function
setGlobalOptions({ maxInstances: 10 });

// Function لتوليد صورة المنشأة ديناميكيًا باستخدام Vertex AI
exports.generateFacilityImage = onCall(async (req) => {
  const name = req.data.name;

  if (!name) {
    throw new Error("اسم المنشأة مطلوب");
  }

  // ضع هنا مفتاح API الخاص بك من Google Cloud
  const API_KEY = "AQ.Ab8RN6I8Wc4QQW6CvHGGZ0MzAdxGv9kKpO1Iw0aUFaiqzmjliw";
  const MODEL = "gemini-1.5-flash";

  const prompt = `Generate a realistic healthcare facility photo named: ${name}`;

  try {
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateImage?key=${API_KEY}`,
      {
        prompt: { text: prompt }
      }
    );

    const base64 = response.data.image?.base64Data;
    if (!base64) throw new Error("Vertex AI did not return an image");

    return { image: base64 }; // سيتم إرجاع Base64 إلى Flutter
  } catch (error) {
    console.error("Error generating image:", error.message);
    throw new Error("فشل توليد الصورة من Vertex AI");
  }
});
