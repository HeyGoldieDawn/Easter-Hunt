import type { SupabaseClient } from "@supabase/supabase-js";
import type { Question, QuestionForClient } from "./types";

export async function drawQuestion(
  db: SupabaseClient,
  topics: string[],
  audience: string,
  excludeIds: number[]
): Promise<Question | null> {
  if (topics.length === 0) return null;

  let query = db
    .from("question_bank")
    .select("*")
    .in("topic", topics)
    .eq("audience", audience);

  if (excludeIds.length > 0) {
    query = query.not("id", "in", `(${excludeIds.join(",")})`);
  }

  const { data, error } = await query;
  if (error || !data || data.length === 0) return null;

  // Random selection in JS (Supabase doesn't expose ORDER BY RANDOM() easily)
  return data[Math.floor(Math.random() * data.length)] as Question;
}

export function questionForClient(q: Question): QuestionForClient {
  return {
    id: q.id,
    topic: q.topic,
    question: q.question,
    options: { a: q.option_a, b: q.option_b, c: q.option_c, d: q.option_d },
  };
}

export async function checkAnswer(
  db: SupabaseClient,
  questionId: number,
  answer: string
): Promise<boolean> {
  const { data } = await db
    .from("question_bank")
    .select("correct")
    .eq("id", questionId)
    .single();
  return data?.correct === answer;
}
