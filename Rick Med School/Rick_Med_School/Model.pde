// The study material: topics (body systems) x 4 difficulty levels.
// Content.pde (generated from the fact-checked content files) fills these in.

final String[] LEVEL_NAMES = { "", "BABY STEPS", "PRE-MED", "MED SCHOOL", "RICK MODE" };
final String[] LEVEL_SUBS = { "",
  "Names and jobs. Like a picture book, but grosser.",
  "High-school bio with extra intestines.",
  "Real anatomy. Real pain. Real student debt.",
  "Board-exam brain melters. You'll cry. I'll drink." };
final int[] LEVEL_COLS = { 0, #7CFF6B, #5FD3FF, #FFB547, #FF4F6D };

final String[] TOPIC_ORDER = { "cells", "bones", "muscles", "nervous", "heart", "lungs", "digestion", "kidneys", "hormones", "immune" };
HashMap<String, Topic> TOPICS = new HashMap<String, Topic>();
HashMap<String, Question> QUESTIONS = new HashMap<String, Question>();
HashMap<String, PartInfo> PART_INFO = new HashMap<String, PartInfo>();

class Topic {
  String key, title;
  String[] diagrams;
  Level[] levels = new Level[5];

  Topic(String key, String title, String[] diagrams) {
    this.key = key;
    this.title = title;
    this.diagrams = diagrams;
    for (int i = 1; i <= 4; i++) levels[i] = new Level(this, i);
  }

  String mainDiagram() {
    return diagrams.length > 0 ? diagrams[0] : "";
  }
}

class Level {
  Topic topic;
  int n;
  ArrayList<Lesson> lessons = new ArrayList<Lesson>();
  ArrayList<Question> questions = new ArrayList<Question>();

  Level(Topic t, int n) {
    topic = t;
    this.n = n;
  }
}

class Lesson {
  String id, title, fact, rick, diagram, part;
}

class Question {
  String id, type, q, explain, rick, diagram, part;
  String[] choices;
  int answer;
  Topic topic;
  int level;

  boolean isLabel() {
    return type.equals("label");
  }

  String answerText() {
    if (isLabel()) return partName(diagram, part);
    return choices[answer];
  }
}

class PartInfo {
  String diagram, id, name, desc, rick;
}

String partName(String dia, String pid) {
  PartInfo pi = PART_INFO.get(dia + ":" + pid);
  if (pi != null) return pi.name;
  Diagram d = diagram(dia);
  Part p = d == null ? null : d.part(pid);
  return p != null ? p.name : pid.replace('_', ' ');
}

// ---------------------------------------------------------------- builders used by Content.pde
Topic curTopic;
Level curLevel;

void topic(String key, String title, String... diagrams) {
  curTopic = new Topic(key, title, diagrams);
  TOPICS.put(key, curTopic);
}

void level(int n) {
  curLevel = curTopic.levels[n];
}

void lesson(String id, String title, String fact, String rick, String dia, String part) {
  Lesson l = new Lesson();
  l.id = id;
  l.title = title;
  l.fact = fact;
  l.rick = rick;
  l.diagram = dia;
  l.part = part;
  curLevel.lessons.add(l);
}

void mcq(String id, String q, String[] choices, int answer, String explain, String rick) {
  Question k = newQuestion(id, "mcq", q, explain, rick);
  k.choices = choices;
  k.answer = answer;
}

void label(String id, String dia, String part, String q, String explain, String rick) {
  Question k = newQuestion(id, "label", q, explain, rick);
  k.diagram = dia;
  k.part = part;
}

Question newQuestion(String id, String type, String q, String explain, String rick) {
  Question k = new Question();
  k.id = id;
  k.type = type;
  k.q = q;
  k.explain = explain;
  k.rick = rick;
  k.topic = curTopic;
  k.level = curLevel.n;
  curLevel.questions.add(k);
  QUESTIONS.put(id, k);
  return k;
}

void partInfo(String dia, String id, String name, String desc, String rick) {
  PartInfo p = new PartInfo();
  p.diagram = dia;
  p.id = id;
  p.name = name;
  p.desc = desc;
  p.rick = rick;
  PART_INFO.put(dia + ":" + id, p);
}
