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
    java.io.File f = new java.io.File(file());
    try {
      if (f.exists()) data = loadJSONObject(f.getAbsolutePath());
    } catch (Exception e) {
      println("Couldn't read progress (" + e.getMessage() + ") - starting fresh.");
    }
    if (data == null && f.exists()) {
      // keep the unreadable file instead of overwriting it on the next save
      java.io.File keep = new java.io.File(file() + ".broken-" + System.currentTimeMillis());
      if (f.renameTo(keep)) println("Kept the unreadable progress file as " + keep.getName());
    }
    if (data == null) data = new JSONObject();
    if (!data.hasKey("best")) data.setJSONObject("best", new JSONObject());
    if (!data.hasKey("mistakes")) data.setJSONObject("mistakes", new JSONObject());
    if (!data.hasKey("xp")) data.setInt("xp", 0);
    if (!data.hasKey("answered")) data.setInt("answered", 0);
    if (!data.hasKey("right")) data.setInt("right", 0);
  }

  // write a temp file, then swap it in, so a crash mid-save can't leave half a file
  void save() {
    try {
      java.io.File tmp = new java.io.File(file() + ".tmp");
      boolean ok = saveJSONObject(data, tmp.getAbsolutePath());
      if (ok) {
        java.nio.file.Path from = tmp.toPath(), to = new java.io.File(file()).toPath();
        try {
          java.nio.file.Files.move(from, to, java.nio.file.StandardCopyOption.REPLACE_EXISTING, java.nio.file.StandardCopyOption.ATOMIC_MOVE);
        } catch (Exception atomicFailed) {
          java.nio.file.Files.move(from, to, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        }
      }
      if (!ok && saveOk) println("Couldn't save progress.");
      saveOk = ok;
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
