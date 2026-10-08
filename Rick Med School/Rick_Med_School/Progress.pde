// Saved progress (next to the sketch): best score per topic/level, total
// Schmeckles, and the mistakes deck - every question you got wrong comes back
// in REVIEW until you've answered it right twice in a row (simple Leitner boxes).

class Progress {
  JSONObject data;
  boolean saveOk = true;

  String file() {
    return sketchPath("rick_med_progress.json");
  }

  void load() {
    data = null;
    try {
      java.io.File f = new java.io.File(file());
      if (f.exists()) data = loadJSONObject(f.getAbsolutePath());
    } catch (Exception e) {
      println("Couldn't read progress (" + e.getMessage() + ") - starting fresh.");
    }
    if (data == null) data = new JSONObject();
    if (!data.hasKey("best")) data.setJSONObject("best", new JSONObject());
    if (!data.hasKey("mistakes")) data.setJSONObject("mistakes", new JSONObject());
    if (!data.hasKey("xp")) data.setInt("xp", 0);
    if (!data.hasKey("answered")) data.setInt("answered", 0);
    if (!data.hasKey("right")) data.setInt("right", 0);
  }

  void save() {
    try {
      saveJSONObject(data, file());
      saveOk = true;
    } catch (Exception e) {
      if (saveOk) println("Couldn't save progress (" + e.getMessage() + ").");
      saveOk = false;
    }
  }

  int best(String topic, int level) {
    JSONObject b = data.getJSONObject("best");
    String k = topic + ":" + level;
    return b.hasKey(k) ? b.getInt(k) : -1;
  }

  boolean record(String topic, int level, int pct) {
    boolean better = pct > best(topic, level);
    if (better) data.getJSONObject("best").setInt(topic + ":" + level, pct);
    save();
    return better;
  }

  int stars(String topic, int level) {
    int b = best(topic, level);
    return b >= 90 ? 3 : b >= 70 ? 2 : b >= 50 ? 1 : 0;
  }

  int xp() {
    return data.getInt("xp");
  }

  void addXp(int n) {
    data.setInt("xp", xp() + n);
  }

  void answered(boolean right) {
    data.setInt("answered", data.getInt("answered") + 1);
    if (right) data.setInt("right", data.getInt("right") + 1);
  }

  // ---------------------------------------------------------------- mistakes deck
  void miss(String qid) {
    data.getJSONObject("mistakes").setInt(qid, 0);
  }

  // right answer: in review it climbs a box; at box 2 it's learned and leaves the deck
  void hit(String qid, boolean review) {
    JSONObject m = data.getJSONObject("mistakes");
    if (!m.hasKey(qid)) return;
    if (!review) return;
    int box = m.getInt(qid) + 1;
    if (box >= 2) m.remove(qid);
    else m.setInt(qid, box);
  }

  ArrayList<Question> mistakes(int level) {
    ArrayList<Question> out = new ArrayList<Question>();
    JSONObject m = data.getJSONObject("mistakes");
    for (Object o : m.keys()) {
      Question q = QUESTIONS.get((String) o);
      if (q != null && (level == 0 || q.level == level)) out.add(q);
    }
    return out;
  }
}
