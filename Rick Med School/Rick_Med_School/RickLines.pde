// Rick's general-purpose lines (topic-specific ones come with the content).

String pick(String[] a) {
  return a[(int) random(a.length)];
}

final String[][] DIFF_HOVER = { {},
  { "Baby steps. Literally. We'll start with 'this is a bone'. *burp*", "Picture-book mode. I'll try not to fall asleep. No promises." },
  { "Pre-med. Ah, the age of overconfidence and energy drinks.", "High-school biology. You probably slept through it the first time." },
  { "Med school level. Hope you like memorising things that hate you.", "Real anatomy. Brace yourself, it's mostly Latin and regret." },
  { "Rick mode?! *burp* Oh, I'm gonna enjoy watching this.", "Board-exam level. Even I had to read a textbook once. ONCE." } };

final String[] DIFF_ENTER = {
  "Pick a difficulty. And don't pick baby mode, it's embarrassing. *burp* For both of us.",
  "Choose wisely. Or don't. I'm drunk either way.",
  "Four levels. One genius. One... you. Pick."
};

final String[] TOPIC_ENTER = {
  "Pick a body system. They're all gross. That's the fun part.",
  "Which pile of meat do you want to learn about today?",
  "Choose a system. Bonus points if it's not the one you're failing."
};

HashMap<String, String[]> TOPIC_HOVER = new HashMap<String, String[]>();

void loadTopicHovers() {
  TOPIC_HOVER.put("cells", new String[] { "Cells. Tiny wet factories. You're about 30 trillion of them pretending to be one idiot." });
  TOPIC_HOVER.put("bones", new String[] { "Bones. The coat hanger your meat hangs on. 206 of them. Don't lose any." });
  TOPIC_HOVER.put("muscles", new String[] { "Muscles. The only reason you can lift that drink. Respect them." });
  TOPIC_HOVER.put("nervous", new String[] { "The nervous system. Electricity in a meat suit. My favourite kind of wiring." });
  TOPIC_HOVER.put("heart", new String[] { "The heart. A pump. Not a feelings organ. *burp* Grow up." });
  TOPIC_HOVER.put("lungs", new String[] { "Lungs. Two wet balloons doing gas exchange. Try not to hyperventilate." });
  TOPIC_HOVER.put("digestion", new String[] { "Digestion. A nine-metre tube that turns pizza into regret." });
  TOPIC_HOVER.put("kidneys", new String[] { "Kidneys. Blood filters shaped like beans. Nature has no imagination." });
  TOPIC_HOVER.put("hormones", new String[] { "Hormones. Chemical text messages your glands send. Mostly drama." });
  TOPIC_HOVER.put("immune", new String[] { "The immune system. A tiny army that occasionally shoots its own guys." });
}

final String[] LESSON_START = {
  "Lesson time. Read the board. I'll be over here. Drinking.",
  "Okay, listen up, this is the part where you learn stuff.",
  "Pay attention. There's a quiz, and I WILL judge you."
};

final String[] QUIZ_START = {
  "Quiz time! Let's see if anything stuck in there.",
  "Okay, test time. Try not to embarrass the whole species.",
  "Pop quiz. Except it's not a pop quiz, I told you. *burp* Whatever."
};

final String[] CORRECT = {
  "Correct. Don't let it go to your head. There's not much room up there.",
  "Right! Huh. Didn't see that coming.",
  "Yep. Even a Meeseeks could've got that, but still. Nice.",
  "Correct. Your neurons fired. Both of them.",
  "Look at you, knowing things.",
  "Right answer. I'm almost proud. Almost. *burp*",
  "Correct! Write that down. No wait, you'll lose it.",
  "Yes. Good. Moving on before you get cocky."
};

final String[] WRONG = {
  "Wrong. So wrong it looped around the multiverse and came back wrong.",
  "Nope. That's a Jerry answer.",
  "Wrong. Read the explanation, genius. Slowly. Move your lips if it helps.",
  "Oof. No. *burp* Learn from it.",
  "Wrong! Somewhere a med school just burned down.",
  "Nope. But hey, that's what the review pile is for.",
  "Incorrect. I'd say 'nice try' but I don't lie. Much."
};

final String[] STREAK = {
  "Three in a row? Who are you and what did you do with the idiot?",
  "Five straight! Okay, okay, settle down, Doctor House.",
  "EIGHT in a row?! I need a drink. I always need a drink, but now for a reason."
};

final String[] HINT_LINES = {
  "A hint? Fine. Half points, though. Charity has a price.",
  "Hint mode. Training wheels on. *burp*",
  "Here. I made it easier. You're welcome. Half points."
};

final String[] TIMEOUT_LINES = {
  "Time's up! Patients don't wait, genius.",
  "Too slow. The patient died of old age.",
  "Clock ran out. Thinking is allowed, but like... faster."
};

final String[] LABEL_WRONG = {
  "That's the %s. Not even close, Columbus.",
  "You clicked the %s. Bold. Wrong, but bold.",
  "That's the %s, genius. Look again."
};

final String[][] RESULT_LINES = {
  { "Wow. I've seen smarter results from a Plumbus. Do the review.", "That was a disaster. A beautiful, educational disaster. Again." },
  { "Below average. Like a Jerry, but with homework.", "Not great. But not dead either. Review your mistakes." },
  { "Passable. A C is still a degree, right? *burp* Right?", "Mid. Very mid. You can do better, I've seen your potential. Barely." },
  { "Solid. I'd let you near a patient. Supervised. From a distance.", "Good work. Don't tell anyone I said that." },
  { "Okay, that was actually impressive. Who taught you? Oh right. ME.", "Genius level! For a human. Which is a low bar, but you CLEARED it." } };

final String[] REVIEW_EMPTY = {
  "No mistakes in the pile. Either you're a genius or you haven't played. Suspicious.",
  "Mistake pile's empty. Go make some mistakes first. You're good at that."
};

final String[] EXPLORE_ENTER = {
  "Study mode. Point at stuff, learn what it is. Like a toddler, but with a med school debt.",
  "Hover over things. I'll tell you what they are. Press L for all the labels, lazy."
};
