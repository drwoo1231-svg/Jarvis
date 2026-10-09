// RICK MED SCHOOL - single-file edition (generated from the tabbed sketch by
// tools/make_single_file.py). Paste this whole file into an empty Processing
// 4.5.6 sketch (Java mode) and press Run. No libraries, no data folder.

import javax.sound.sampled.*;

// ======================================================================
// TAB: Rick_Med_School.pde
// ======================================================================
// RICK MED SCHOOL
// Anatomy & physiology, very basic to expert, taught by a drunk, burping,
// sarcastic genius scientist who would rather be anywhere else.
//
// Processing 4.5.6 (Java mode). No libraries, no data folder: every picture
// and sound is made in code. Progress is saved next to the sketch.
//
//   mouse ........ everything          1-4 / A-D ... answer
//   SPACE/ENTER .. next                H ........... hint (half points)
//   ESC .......... back                M ........... mute
//   L ............ labels (study mode)

final int W = 1280, H = 720;

Scene scene, pending;
float T, dt;
int lastMs;
float transT = -1;              // portal wipe: -1 = idle, 0..1 closing, 1..2 opening
boolean transSwapped;

Sfx sfx;
SpaceBg space;
Rick rick;
Progress progress;

void settings() {
  size(1280, 720);
  pixelDensity(displayDensity());
  smooth(8);
}

void setup() {
  surface.setTitle("Rick Med School");
  frameRate(60);
  setupFonts();
  sfx = new Sfx();
  loadContent();
  registerDiagrams();
  makeDrillQuestions();
  loadTopicHovers();
  space = new SpaceBg();
  rick = new Rick();
  progress = new Progress();
  progress.load();
  scene = new IntroScene();
  scene.enter();
  lastMs = millis();
}

void draw() {
  int now = millis();
  dt = constrain((now - lastMs) / 1000.0, 0.0005, 0.05);
  lastMs = now;
  T += dt;
  if (transT < 0 || transSwapped) scene.update(dt);    // the scene being left freezes during the wipe
  rick.update(dt);
  scene.draw();
  drawTransition();
  if (sfx.muted) {
    textFont(fMono);
    textAlign(RIGHT, TOP);
    fill(C_DIM);
    text("MUTED (M)", W - 12, H - 24);
  }
  if (!progress.saveOk) {
    textFont(fMono);
    textAlign(LEFT, TOP);
    fill(C_RED);
    text("PROGRESS NOT SAVING - the sketch folder is read-only", 12, H - 22);
  }
}

// ---------------------------------------------------------------- scenes
abstract class Scene {
  ArrayList<Button> buttons = new ArrayList<Button>();

  void enter() {}
  void update(float dt) {}
  abstract void draw();
  void clicked(Button b) {}
  void mouse() {}                       // a click that didn't hit a button
  void key(char k, int code) {}
  void back() {}                        // BACK buttons
  void escape() {                       // ESC (scenes can ask for a second press)
    back();
  }

  Button button(String id, String label, float x, float y, float w, float h) {
    Button b = new Button(id, label, x, y, w, h);
    buttons.add(b);
    return b;
  }

  void drawButtons() {
    for (Button b : buttons) b.draw();
  }

  boolean clickButtons() {
    for (Button b : buttons) {
      if (b.over()) {
        sfx.play(sfx.click, 0.5);
        clicked(b);
        return true;
      }
    }
    return false;
  }
}

// switch scenes through a green portal wipe
void go(Scene s) {
  if (transT >= 0 && !transSwapped) {
    pending = s;
    return;
  }
  pending = s;
  transT = 0;
  transSwapped = false;
  sfx.play(sfx.whoosh, 0.6);
}

void drawTransition() {
  if (transT < 0) return;
  transT += dt * 2.6;
  if (transT >= 1 && !transSwapped) {
    transSwapped = true;
    scene = pending;
    pending = null;
    rick.quiet();
    scene.enter();
  }
  if (transT >= 2) {
    transT = -1;
    return;
  }
  float k = transT < 1 ? transT : 2 - transT;      // 0 -> 1 -> 0
  k = k * k * (3 - 2 * k);
  float r = k * 1600;
  drawPortal(W / 2, H / 2, r, r * 0.92, T * 3, 255);
  if (k > 0.85) {
    noStroke();
    fill(#103A12, (k - 0.85) / 0.15 * 255);
    rect(0, 0, W, H);
  }
}

// ---------------------------------------------------------------- input
void mousePressed() {
  if (transT >= 0) return;
  rick.clickSkip();
  if (!scene.clickButtons()) scene.mouse();
}

// hovering and reading count as studying, not idling
void mouseMoved() {
  rick.clickSkip();
}

void mouseDragged() {
  rick.clickSkip();
}

// build the diagram images a little at a time while nothing else is going on
void prebuildDiagrams() {
  if (transT >= 0) return;
  for (String id : DIAGRAM_ORDER) {
    Diagram d = diagram(id);
    if (d != null && d.thumb == null) {
      d.thumb();
      return;
    }
  }
}

// which level's body-system grid the study mode was opened from (0 = the difficulty screen)
int studyFromLevel = 0;

void keyPressed() {
  rick.clickSkip();              // any input resets Rick's idle nagging
  if (key == ESC) {
    key = 0;                     // don't quit - go back instead
    if (transT < 0) scene.escape();
    return;
  }
  if (transT >= 0) return;
  char k = Character.toLowerCase(key);
  if (k == 'm') {
    sfx.muted = !sfx.muted;
    return;
  }
  for (Button b : scene.buttons) {
    if (b.visible && b.enabled && b.hotkey != null && b.hotkey.length() == 1 && Character.toLowerCase(b.hotkey.charAt(0)) == k) {
      sfx.play(sfx.click, 0.5);
      scene.clicked(b);
      return;
    }
  }
  scene.key(k, keyCode);
}


// ======================================================================
// TAB: Content.pde
// ======================================================================
// GENERATED by tools/build_content.py from the fact-checked study content in content/*.json.
// Edit the JSON and re-run the script rather than editing this file.

void loadContent() {
  content_cells();
  content_bones();
  content_muscles();
  content_nervous();
  content_heart();
  content_lungs();
  content_digestion();
  content_kidneys();
  content_hormones();
  content_immune();
  parts_brain();
  parts_cell();
  parts_digestive();
  parts_heart();
  parts_lungs();
  parts_muscles();
  parts_nephron();
  parts_neuron();
  parts_organ_map();
  parts_skeleton();
}

void content_cells() {
  topic("cells", "CELLS", "cell");
  level(1);
  lesson("cells-1-L1", "Cells: the units of life", "The cell is the smallest unit of life; you are made of roughly 30 trillion of them. Inside the cell membrane is the cytoplasm: jelly-like cytosol plus organelles, the cell's 'little organs'. Human cells are eukaryotic: their DNA sits in a nucleus (mature red blood cells lose theirs). Bacteria are prokaryotic: no nucleus at all.", "30 trillion cells, and every one of them is working harder right now than you did all semester, genius.", "cell", "cytoplasm");
  lesson("cells-1-L2", "The cell membrane", "The cell membrane (plasma membrane) is a double layer of phospholipids studded with proteins. It surrounds the cell and is selectively permeable: it decides what gets in and out. Animal cells have no rigid cell wall; plant cells and bacteria do.", "A bouncer made of fat. Lets the good stuff in, keeps the garbage out. Unlike your brain, which lets *burp* everything leak out.", "cell", "cell_membrane");
  lesson("cells-1-L3", "The nucleus", "The nucleus is the control center. It stores most of the cell's DNA, the instruction manual for building proteins, inside a double membrane called the nuclear envelope, which has pores. Inside it, the nucleolus helps build ribosomes. Mature red blood cells throw their nucleus out.", "The nucleus is the cell's brain. Yes, cells have one. More than I can say for some people in this room, Morty-brain.", "cell", "nucleus");
  lesson("cells-1-L4", "Power, factories, trash cans", "Mitochondria are the power plants: they use O2 to burn fuel and make ATP, the cell's energy currency, releasing CO2 and H2O. Ribosomes are tiny factories that build proteins. Lysosomes are recycling bins full of enzymes that digest waste and worn-out parts.", "Mitochondria make the energy, ribosomes make the proteins, lysosomes eat the trash. Basically my garage, but organized.", "cell", "mitochondrion");
  mcq("cells-1-01", "Which part of the cell holds most of its DNA?", new String[] { "Mitochondrion", "Nucleus", "Lysosome", "Cell membrane" }, 1, "The nucleus stores the chromosomes, the cell's DNA instruction manual. Mitochondria carry a tiny DNA of their own (37 genes), but nearly all your genes live in the nucleus.", "The nucleus. It's where the instructions are. You know, the thing you never read before *burp* breaking stuff.");
  mcq("cells-1-02", "Which organelle makes most of the cell's usable energy (ATP)?", new String[] { "Ribosome", "Golgi apparatus", "Nucleus", "Mitochondrion" }, 3, "Mitochondria run aerobic respiration, using O2 to turn fuel into ATP. Ribosomes USE energy to build proteins; they don't make it.", "Mitochondria, the powerhouse of the cell. Congrats, you've reached meme-level biology.");
  mcq("cells-1-03", "What is the main job of the cell membrane?", new String[] { "Building proteins", "Storing the DNA", "Controlling what enters and leaves the cell", "Digesting worn-out organelles" }, 2, "The membrane is a selectively permeable barrier: it lets some substances through and blocks others. Proteins are built by ribosomes; DNA sits in the nucleus.", "It's a door with a guest list, genius. Doors. You've seen doors.");
  mcq("cells-1-04", "What do ribosomes build?", new String[] { "Proteins", "Lipids for the membrane", "DNA", "Glucose" }, 0, "Ribosomes read mRNA and link amino acids into proteins. Lipids are made mainly by the smooth ER, and DNA is copied in the nucleus.", "Proteins. Tiny factories, millions per cell, working 24/7 without whining. Take notes, Morty-brain.");
  mcq("cells-1-05", "Which organelle is the cell's recycling center, using enzymes to digest waste?", new String[] { "Centrosome", "Lysosome", "Nucleolus", "Ribosome" }, 1, "Lysosomes are membrane sacs of digestive enzymes that break down worn-out organelles, engulfed bacteria and other junk so the parts can be reused.", "Lysosomes. Little acid trash compactors. I wish I had one for this conversation.");
  mcq("cells-1-06", "Which kind of organism has NO nucleus in any of its cells?", new String[] { "Humans", "Mushrooms", "Oak trees", "Bacteria" }, 3, "Bacteria are prokaryotes: their DNA floats in the cytoplasm with no nuclear envelope. Animals, plants and fungi are eukaryotes, whose cells have a nucleus (human red blood cells lose theirs as they mature, an exception).", "Bacteria. No nucleus, no brain, and they still out-breed you by a factor of a *burp* billion.");
  mcq("cells-1-07", "Roughly how many cells make up an adult human body?", new String[] { "About 30 million", "About 30 billion", "About 30 trillion", "About 30 quadrillion" }, 2, "Estimates are around 30 trillion human cells, most of them red blood cells. You also carry a similar number of bacteria, mostly in your gut.", "30 trillion. And not one of them can do your homework for you. I checked.");
  mcq("cells-1-08", "The cell membrane is built mainly from a double layer of:", new String[] { "Cellulose", "Phospholipids", "DNA", "Starch" }, 1, "A phospholipid bilayer: water-loving heads face outward, water-fearing tails hide inside. Cellulose builds plant cell WALLS, which animal cells don't have.", "Phospholipids. Your cells are wrapped in fancy grease, genius. Respect the grease.");
  label("cells-1-09", "cell", "cell_membrane", "Click the cell membrane.", "The cell membrane is the thin outer boundary of the cell, a phospholipid bilayer that controls what gets in and out.", "The edge. The outer line. The thing holding the whole cell together. Unlike you, emotionally.");
  label("cells-1-10", "cell", "nucleus", "Click the nucleus.", "The nucleus is the large round control center that stores the DNA, wrapped in a double membrane with pores.", "Big round thing, Einstein. Miss this one and I'm portaling to a dimension with smarter students.");
  label("cells-1-11", "cell", "mitochondrion", "Click a mitochondrion.", "Mitochondria are bean-shaped organelles with a folded inner membrane (cristae); they make most of the cell's ATP using O2.", "The bean with the wrinkly insides. That's where your energy comes from. Clearly yours are on strike.");
  level(2);
  lesson("cells-2-L1", "The protein export line", "Proteins for export or for membranes are built by ribosomes on the rough ER, threaded into it and folded. Vesicles carry them to the Golgi apparatus, which modifies them (e.g. adds sugars), then sorts and packages them into new vesicles for the membrane, lysosomes, or secretion by exocytosis.", "Rough ER builds it, Golgi gift-wraps it, vesicle ships it. Like a delivery company, except it actually *burp* delivers.", "cell", "rough_er");
  lesson("cells-2-L2", "Smooth ER and lysosomes", "Smooth ER has no ribosomes. It makes lipids and steroid hormones, detoxifies drugs (huge in liver cells) and stores Ca2+ (in muscle it's called the sarcoplasmic reticulum). Lysosomes hold acid hydrolases that work best at about pH 5 and digest worn-out organelles and engulfed material.", "My liver cells have so much smooth ER they deserve a medal. A whole trophy case, honestly.", "cell", "smooth_er");
  lesson("cells-2-L3", "Crossing the membrane", "O2 and CO2 slip through the lipid bilayer by simple diffusion, down their gradient. Water moves by osmosis toward more solute, often via aquaporins; in pure water an animal cell swells and may burst. Facilitated diffusion (e.g. GLUT for glucose) needs no ATP. Active transport does: the Na+/K+ ATPase pumps 3 Na+ out, 2 K+ in.", "Downhill is free, uphill costs ATP. Physics doesn't do favors, and neither do I.", "cell", "cell_membrane");
  lesson("cells-2-L4", "DNA, genes and division", "Human body cells have 46 chromosomes (23 pairs); eggs and sperm have 23. In the nucleus, DNA is transcribed into mRNA; in the cytoplasm, ribosomes translate mRNA into protein. The nucleolus builds ribosome subunits. Mitosis makes 2 identical body cells; meiosis makes haploid eggs and sperm.", "DNA -> RNA -> protein. The central dogma. Retroviruses cheat at it, but you're not a retrovirus. Probably.", "cell", "nucleolus");
  mcq("cells-2-01", "Which organelle modifies, sorts and packages proteins received from the rough ER?", new String[] { "Smooth ER", "Golgi apparatus", "Lysosome", "Nucleolus" }, 1, "The Golgi receives proteins from the rough ER, modifies them (adds or trims sugars, adds tags), then sorts them into vesicles for secretion, the cell membrane or lysosomes.", "The Golgi. The cell's post office. Stamps, sorting, shipping. Less bureaucracy, more efficiency.");
  mcq("cells-2-02", "What makes rough ER look 'rough' under the electron microscope?", new String[] { "Attached ribosomes", "Embedded lysosomes", "Cholesterol crystals", "Coiled DNA strands" }, 0, "Ribosomes stud its outer surface while they make secretory and membrane proteins. Smooth ER lacks them, so it looks smooth.", "Ribosomes stuck all over it. Like crumbs on Morty's shirt, but *burp* productive.");
  mcq("cells-2-03", "Which organelle is abundant in liver cells for detoxifying drugs and in adrenal cells for making steroids?", new String[] { "Rough ER", "Nucleolus", "Smooth ER", "Centrosome" }, 2, "Smooth ER makes lipids and steroids and holds drug-metabolizing enzymes, so it's plentiful in hepatocytes and steroid-making cells. Rough ER makes proteins, not steroids.", "Smooth ER. Mine has detoxed enough booze to float a small planet. That is NOT a study technique.");
  mcq("cells-2-04", "Lysosomal enzymes work best at about which pH?", new String[] { "About 2, like stomach acid", "About 7.4, like blood", "About 9, alkaline", "About 5, mildly acidic" }, 3, "Lysosomes pump in H+ to keep their inside near pH 4.5-5. Their acid hydrolases barely work at the cytosol's neutral pH, which protects the cell if a lysosome leaks.", "About 5. Acidic enough to digest junk, not the whole cell. It's called a safety feature. Look it up.");
  mcq("cells-2-05", "Each cycle of the Na+/K+ ATPase uses 1 ATP to move:", new String[] { "3 Na+ in and 2 K+ out", "2 Na+ out and 3 K+ in", "3 Na+ out and 2 K+ in", "1 Na+ out and 1 K+ in" }, 2, "It pumps 3 Na+ out and 2 K+ in, both against their gradients. This keeps Na+ high outside and K+ high inside, and the pump is electrogenic (net 1 positive charge out per cycle).", "3 out, 2 in. It's on every exam in every *burp* dimension. I've checked like 40 of them.");
  mcq("cells-2-06", "A red blood cell is placed in pure water. What happens?", new String[] { "It shrinks (crenates)", "It swells and may burst (lyses)", "Nothing changes", "It divides by mitosis" }, 1, "Pure water is hypotonic to the cell, so water rushes in by osmosis and the RBC swells until it may burst. In a hypertonic (very salty) solution it would shrink instead.", "Pop! Water rushes toward the solute. Osmosis, genius. Like your head, but with actual contents.");
  mcq("cells-2-07", "How many chromosomes are in a normal human body (somatic) cell?", new String[] { "46", "23", "44", "92" }, 0, "46 chromosomes in 23 pairs: 22 pairs of autosomes plus XX or XY. Eggs and sperm carry 23 (haploid), so fertilization restores 46.", "46. Two sets of 23, from two people who probably had no idea what they were doing.");
  mcq("cells-2-08", "Copying DNA into mRNA is called ___ and happens in the ___.", new String[] { "Translation; cytoplasm", "Replication; Golgi", "Transcription; ribosome", "Transcription; nucleus" }, 3, "Transcription (DNA -> mRNA) happens in the nucleus. Translation (mRNA -> protein) happens on ribosomes in the cytoplasm. Replication copies DNA into DNA before division.", "Transcription, in the nucleus. Translation comes after. Two different words, Morty-brain. Keep 'em apart.");
  label("cells-2-09", "cell", "golgi", "Click the organelle that sorts and packages proteins into vesicles for export.", "That's the Golgi apparatus, the stack of flattened sacs that modifies proteins from the rough ER and ships them out in vesicles.", "The Golgi. The stack of sacs. The cell's shipping department. Not the nucleus, not the ER. The stack.");
  label("cells-2-10", "cell", "rough_er", "Click the rough ER.", "The rough ER is the ribosome-studded membrane network continuous with the nuclear envelope, where secretory and membrane proteins are made.", "The bumpy folds next to the nucleus. Bumps are ribosomes. Bumps mean proteins. Got it? Good.");
  label("cells-2-11", "cell", "lysosome", "Click a lysosome.", "Lysosomes are small round membrane sacs of acid enzymes that digest worn-out organelles and engulfed material.", "The little acid bubble. A stomach the size of nothing. Click it before it digests your grade.");
  level(3);
  lesson("cells-3-L1", "Inside the mitochondrion", "Mitochondria have 2 membranes. The matrix runs the Krebs (TCA) cycle and fatty acid beta-oxidation. The folded inner membrane (cristae) holds the electron transport chain, which pumps H+ into the intermembrane space; H+ flows back through ATP synthase to make ATP: roughly 30-32 ATP per glucose.", "A proton waterfall spinning a turbine that makes ATP. Nature built a *burp* hydroelectric dam in your cells.", "cell", "mitochondrion");
  lesson("cells-3-L2", "Protein targeting", "Secretory (and many membrane) proteins carry an N-terminal signal peptide; the signal recognition particle (SRP) docks the ribosome on the rough ER. N-linked glycosylation begins in the RER; the Golgi does O-linked glycosylation and tags lysosomal enzymes with mannose-6-phosphate. The nucleolus makes rRNA (RNA pol I).", "Signal peptide is the shipping label, SRP is the forklift. No label and your protein stays in the cytosol forever.", "cell", "rough_er");
  lesson("cells-3-L3", "Cell cycle control", "G1 -> S (DNA replication) -> G2 -> M (mitosis); resting cells exit from G1 into G0. Cyclin-CDK complexes drive the cycle. Hypophosphorylated Rb binds E2F and blocks entry into S; p53 senses DNA damage and induces p21 to halt the cycle. In M phase the 2 centrosomes organize the mitotic spindle.", "Rb and p53 are the brakes. Cancer is a cell that cut its own brake lines. Idiot cells.", "cell", "centrosome");
  lesson("cells-3-L4", "Cytoskeleton and junctions", "Microtubules (tubulin) form the spindle, cilia (9+2) and tracks for motors: kinesin walks to the + end (anterograde), dynein to the - end (retrograde). Desmosomes (desmoglein, a cadherin) bind cells together; hemidesmosomes (integrins) anchor cells to basement membrane; gap junctions (connexins) pass ions.", "Kinesin goes out, dynein comes back. Like me at a bar, except dynein *burp* remembers the way home.", "", "");
  mcq("cells-3-01", "Where in the mitochondrion are the electron transport chain and ATP synthase located?", new String[] { "Outer membrane", "Inner membrane (cristae)", "Matrix", "Intermembrane space" }, 1, "Both sit in the inner membrane, folded into cristae for surface area. The ETC pumps H+ into the intermembrane space; the matrix hosts the Krebs cycle and beta-oxidation.", "Inner membrane, folded up to cram in more machinery. Nature figured out origami before you did.");
  mcq("cells-3-02", "How is a newly made secretory protein targeted to the rough ER?", new String[] { "An N-terminal signal peptide bound by SRP", "A mannose-6-phosphate tag", "A C-terminal KDEL sequence", "Attachment of ubiquitin" }, 0, "SRP recognizes the N-terminal signal peptide as it emerges and docks the ribosome on the RER. KDEL retrieves ER-resident proteins from the Golgi; M6P targets lysosomes; ubiquitin marks proteins for the proteasome.", "Signal peptide plus SRP. The other three are real tags with different jobs. Learn all four, it's cheaper than failing.");
  mcq("cells-3-03", "Where does N-linked glycosylation of proteins begin?", new String[] { "Golgi apparatus", "Lysosome", "Rough ER", "Nucleolus" }, 2, "The core N-linked oligosaccharide (built on dolichol) is attached to asparagine in the rough ER lumen during translation; the Golgi then trims and modifies it. O-linked glycosylation happens in the Golgi.", "Rough ER starts it, Golgi finishes it. Teamwork. A concept you, lone wolf, know nothing about.");
  mcq("cells-3-04", "In G1, hypophosphorylated Rb blocks entry into S phase by binding which transcription factor?", new String[] { "p53", "E2F", "Myc", "NF-kB" }, 1, "Rb holds E2F, which drives S-phase genes. Cyclin D-CDK4/6 phosphorylate Rb and release E2F. p53 is a separate brake that acts by inducing p21 after DNA damage.", "E2F. Rb sits on it like I sit on my portal gun. Phosphorylate Rb and E2F runs wild.");
  mcq("cells-3-05", "From which phase do cells leave the cycle to enter the resting G0 state?", new String[] { "G1", "S", "G2", "M" }, 0, "Cells exit from G1 into G0, the quiescent state (e.g. resting hepatocytes; most neurons stay there permanently). G1 is also the phase whose length varies most between cell types.", "G1. G0 is where cells go to chill. Permanently, for neurons. Kinda like you in lectures.");
  mcq("cells-3-06", "Kinesin moves cargo along microtubules in which direction?", new String[] { "Toward the - end (retrograde)", "Along actin filaments instead", "Toward the + end (anterograde)", "Into the nucleus through its pores" }, 2, "Kinesin walks toward the + end, i.e. from a neuron's cell body out to the axon terminal (anterograde). Dynein walks toward the - end (retrograde). Myosin, not kinesin, runs on actin.", "Plus end. Kinesin hauls stuff out, dynein drags it back. Same thing happens with me and the *burp* liquor store.");
  mcq("cells-3-07", "Pemphigus vulgaris is caused by autoantibodies against desmoglein, a component of:", new String[] { "Hemidesmosomes", "Gap junctions", "Tight junctions", "Desmosomes" }, 3, "Desmoglein (a cadherin) holds keratinocytes together in desmosomes; attacking it gives flaccid intraepidermal blisters. Bullous pemphigoid targets hemidesmosomes, giving tense subepidermal blisters.", "Desmosomes. Pemphigus pops cells apart from EACH OTHER; pemphigoid pops them off the floor. Learn the difference.");
  mcq("cells-3-08", "Gap junctions, which let ions pass directly between neighboring cells, are made of:", new String[] { "Connexins", "Claudins", "Cadherins", "Integrins" }, 0, "Six connexins form a connexon; connexons from two neighboring cells join into a channel. Claudins seal tight junctions, cadherins form adherens junctions and desmosomes, and integrins bind the matrix.", "Connexins. They connect. It's literally in the name, genius. Biology rarely gives you a freebie like this.");
  label("cells-3-09", "cell", "smooth_er", "Click the ribosome-free ER that makes steroids and holds cytochrome P450 drug enzymes.", "Smooth ER: tubular ER with no ribosomes. It makes lipids and steroids, metabolizes drugs via cytochrome P450 (abundant in hepatocytes) and stores Ca2+ in muscle.", "Smooth ER. No ribosomes, all chemistry. The part of my liver that's earned overtime pay.");
  label("cells-3-10", "cell", "nucleolus", "Click the dense spot inside the nucleus where rRNA is made.", "The nucleolus is a membrane-less region in the nucleus where RNA polymerase I transcribes rRNA and ribosomal subunits are assembled before export through nuclear pores.", "The nucleolus. A dot inside the nucleus that builds ribosome parts. Click the dot, genius.");
  label("cells-3-11", "cell", "centrosome", "Click the main microtubule-organizing center of the cell.", "The centrosome, a pair of centrioles in pericentriolar material, nucleates microtubules. It duplicates during S phase, and the two centrosomes become the poles of the mitotic spindle.", "Centrosome. Spindle boss. Mess it up and chromosomes split like my family at Thanksgiving.");
  label("cells-3-12", "cell", "ribosome", "Click a free ribosome, where cytosolic proteins are made.", "Free ribosomes float in the cytosol and make proteins that stay in the cytosol, nucleus or mitochondria; ER-bound ones make secreted and membrane proteins. Same ribosome, different destination.", "A ribosome. Tiny dot, huge job. You're the exact opposite.");
  level(4);
  lesson("cells-4-L1", "Golgi and lysosome disasters", "I-cell disease: the Golgi enzyme N-acetylglucosamine-1-phosphotransferase is missing, so lysosomal enzymes get no mannose-6-phosphate tag and are secreted: high plasma enzymes, coarse facies, early death. Tay-Sachs: hexosaminidase A deficiency -> GM2 ganglioside builds up; cherry-red macula, no hepatosplenomegaly.", "No mannose-6-phosphate tag, no delivery. Lysosomes starve while the enzymes party in the *burp* bloodstream.", "cell", "golgi");
  lesson("cells-4-L2", "Mitochondrial genes and poisons", "mtDNA comes only from the mother: an affected mother passes the mutation to all her children, an affected father to none. Heteroplasmy (mixed normal and mutant mtDNA) makes severity vary (e.g. MELAS). Cyanide and CO block complex IV; uncouplers such as 2,4-dinitrophenol let H+ leak back, making heat instead of ATP.", "Dad's mitochondria get trashed right after fertilization. Brutal, efficient, and on every exam ever.", "cell", "mitochondrion");
  lesson("cells-4-L3", "Apoptosis", "Intrinsic pathway: DNA damage or lost survival signals -> BAX/BAK permeabilize the outer mitochondrial membrane -> cytochrome c released -> apoptosome activates caspase-9 -> caspases 3/7. BCL-2 blocks this; t(14;18) overexpresses BCL-2 in follicular lymphoma. Extrinsic: Fas ligand or TNF -> caspase-8.", "Apoptosis is a tidy self-destruct: shrink, bleb, get eaten, no inflammation. Necrosis is the messy *burp* version.", "cell", "mitochondrion");
  lesson("cells-4-L4", "Cilia, microtubules, misfolding", "Primary ciliary dyskinesia: defective dynein arms -> immotile cilia and sperm: sinusitis, bronchiectasis, male infertility; about half have situs inversus (Kartagener syndrome). Colchicine and vinca alkaloids block microtubule polymerization; taxanes stabilize them. Cystic fibrosis: F508del CFTR misfolds and is kept in the ER.", "Broken dynein and your heart can end up on the wrong side. Biology's version of a portal accident.", "cell", "centrosome");
  mcq("cells-4-01", "A 1-year-old has coarse facies, gingival hyperplasia, stiff joints and very high plasma levels of lysosomal enzymes. Which step is defective?", new String[] { "Making hexosaminidase A", "Adding mannose-6-phosphate in the Golgi", "Acidifying the lysosome lumen", "Starting N-linked glycosylation in the RER" }, 1, "I-cell disease (mucolipidosis II): N-acetylglucosamine-1-phosphotransferase fails, so there is no M6P tag. Enzymes are secreted instead of reaching lysosomes, hence high plasma levels and inclusion-filled cells.", "The Golgi forgot the address label. Enzymes end up in the blood, lysosomes stay full of junk. Classic.");
  mcq("cells-4-02", "A 6-month-old has an exaggerated startle response, lost milestones and a cherry-red macula; liver and spleen are normal size. What accumulates?", new String[] { "Sphingomyelin", "Glucocerebroside", "GM2 ganglioside", "Galactocerebroside" }, 2, "Tay-Sachs: hexosaminidase A deficiency -> GM2 ganglioside. Niemann-Pick (sphingomyelin) also has a cherry-red spot but WITH hepatosplenomegaly; Gaucher (glucocerebroside) has hepatosplenomegaly and no cherry-red spot.", "Normal liver and spleen plus cherry-red spot = Tay-Sachs. Pattern recognition, genius. It's the whole exam.");
  mcq("cells-4-03", "A man with MELAS (a mitochondrial DNA mutation) and an unaffected woman have 4 children. How many inherit his mutation?", new String[] { "All 4", "About 2", "Only the sons", "None" }, 3, "Embryo mitochondria come from the egg; sperm mitochondria are destroyed after fertilization. So an affected father passes mtDNA disease to no children; an affected mother passes it to all, with variable severity (heteroplasmy).", "Zero. Sperm mitochondria get recycled right after fertilization. Dads contribute DNA and not much else.");
  mcq("cells-4-04", "A man rescued from a house fire has severe lactic acidosis and unusually high venous O2 saturation. Which component is most likely inhibited?", new String[] { "ATP synthase", "Complex IV (cytochrome c oxidase)", "Complex I (NADH dehydrogenase)", "Pyruvate kinase" }, 1, "Burning plastics release cyanide (and CO), and both block complex IV. Cells can't use O2, so venous blood stays oxygenated and cells switch to anaerobic glycolysis -> lactic acidosis.", "Complex IV. The O2 is right there and the cells can't use it. Like a buffet you're banned from.");
  mcq("cells-4-05", "A bodybuilder takes an illegal 'fat burner' and develops dangerous hyperthermia. Like thermogenin in brown fat, the drug most likely:", new String[] { "Blocks ATP synthase directly", "Blocks complex IV", "Inhibits the Krebs cycle", "Lets H+ leak into the matrix, bypassing ATP synthase" }, 3, "2,4-dinitrophenol is an uncoupler: H+ leaks back across the inner membrane, so O2 use and electron flow rise while ATP synthesis falls, and the energy is lost as heat. Oligomycin, by contrast, blocks ATP synthase.", "Uncoupling: the dam leaks, no electricity, just heat. Brown fat does it on purpose. Idiots do it with *burp* pills.");
  mcq("cells-4-06", "Follicular lymphoma with t(14;18) overexpresses a protein that normally does what?", new String[] { "Phosphorylates Rb", "Activates caspase-8", "Degrades p53", "Prevents cytochrome c release from mitochondria" }, 3, "t(14;18) moves BCL-2 next to the IgH locus, so it is overexpressed. BCL-2 holds BAX/BAK in check, blocking cytochrome c release and the intrinsic apoptosis pathway, so B cells that should die survive.", "BCL-2: the 'don't kill me' button stuck ON. Immortal B cells. Not the cool kind of immortal.");
  mcq("cells-4-07", "A man has chronic sinusitis, bronchiectasis, infertility with immotile sperm, and dextrocardia. Which structure is most likely defective?", new String[] { "Dynein arms of microtubules", "CFTR chloride channel", "Keratin intermediate filaments", "Kinesin motor heads" }, 0, "Primary ciliary dyskinesia (Kartagener): faulty dynein arms -> immotile cilia and sperm flagella; embryonic nodal cilia fail, so organ sidedness is random. CF also causes sinusitis and infertility but not situs inversus.", "Heart on the wrong side is your clue. CF can't flip organs. Broken dynein can, by *burp* slacking off.");
  mcq("cells-4-08", "Which drug for acute gout binds tubulin and blocks microtubule polymerization in neutrophils?", new String[] { "Allopurinol", "Paclitaxel", "Colchicine", "Methotrexate" }, 2, "Colchicine binds tubulin and prevents polymerization, so neutrophils can't migrate and degranulate in the joint. Paclitaxel does the opposite (stabilizes microtubules); allopurinol lowers uric acid production.", "Colchicine. Freezes the neutrophils' scaffolding so they can't storm the joint. Molecular crowd control.");
  label("cells-4-09", "cell", "golgi", "Click the organelle where lysosomal enzymes get their mannose-6-phosphate tag.", "The Golgi (cis-Golgi) adds mannose-6-phosphate to lysosomal enzymes; M6P receptors in the trans-Golgi then send them to lysosomes. Without it (I-cell disease) the enzymes are secreted.", "The Golgi. The address-label printer. Break it and every package goes to the wrong *burp* universe.");
  label("cells-4-10", "cell", "lysosome", "Click the organelle that fills with GM2 ganglioside in Tay-Sachs disease.", "GM2 ganglioside piles up inside neuronal lysosomes because hexosaminidase A, a lysosomal enzyme, is missing. Every lysosomal storage disease follows this 'undigested substrate' logic.", "Lysosome. Storage disease means stuff goes in and never comes out. Like my fridge.");
  label("cells-4-11", "cell", "mitochondrion", "Click the organelle that releases cytochrome c to trigger intrinsic apoptosis.", "In intrinsic apoptosis, BAX/BAK permeabilize the outer mitochondrial membrane; cytochrome c escapes to the cytosol, binds APAF-1 to form the apoptosome and activates caspase-9.", "Mitochondria power the cell AND hold the self-destruct button. Great design, honestly.");
  label("cells-4-12", "cell", "rough_er", "Click the ribosome-studded organelle that makes CFTR and retains misfolded F508del CFTR.", "CFTR is made on the rough ER. F508del misfolds, fails ER quality control and is retained there, then sent to proteasomes (ER-associated degradation), so little CFTR reaches the apical membrane.", "Rough ER quality control: misfolded? Rejected. Harsh, but that's half of cystic fibrosis.");
}

void content_bones() {
  topic("bones", "BONES", "skeleton");
  level(1);
  lesson("bones-1-L1", "What bones are for", "Your skeleton has five big jobs: SUPPORT (it holds you up), PROTECTION (the skull guards the brain, the rib cage guards the heart and lungs), MOVEMENT (muscles pull on bones like levers), BLOOD CELL production (in red bone marrow) and STORAGE of minerals, mainly calcium and phosphate.", "Bones: the scaffolding that keeps you from being a puddle of *burp* Morty-goo on the floor. You're welcome, evolution.", "skeleton", "skull");
  lesson("bones-1-L2", "206 and counting", "An adult has about 206 bones. A newborn has roughly 270-300 bony pieces that fuse as it grows (for example in the skull, sacrum and hip bones). The femur (thigh bone) is the longest and strongest bone; the smallest is the stapes, a tiny bone in the middle ear.", "Babies have more bones than you and contribute about as much to science. The femur's the big one, genius. Remember it.", "skeleton", "femur");
  lesson("bones-1-L3", "Skull, spine and rib cage", "The skull protects the brain; its lower jaw, the mandible, is the only skull bone that moves freely (chewing, talking). The vertebral column (spine) is a stack of vertebrae that protects the spinal cord. 12 pairs of ribs plus the sternum (breastbone) form the rib cage around the heart and lungs.", "Your rib cage is literally a cage for your heart. Romantic. Also the only thing between your lungs and my portal gun.", "skeleton", "ribs");
  lesson("bones-1-L4", "Arm and leg bones", "Arm: humerus (upper arm), then radius (thumb side) and ulna (pinky side) in the forearm, then carpals (wrist), metacarpals (palm) and phalanges (fingers). Leg: femur (thigh), patella (kneecap), tibia (shin, carries the weight) and fibula (thin outer bone), then tarsals, metatarsals and phalanges.", "Radius on the thumb side, ulna on the pinky side. A Mr. Meeseeks gets that on the first try. Be the Meeseeks.", "skeleton", "tibia");
  mcq("bones-1-01", "About how many bones does an adult human skeleton have?", new String[] { "106", "206", "306", "412" }, 1, "Adults have about 206 bones. Newborns start with roughly 270-300 bony pieces, but many fuse during growth (for example in the skull, sacrum and hip bones), so the count goes DOWN with age, not up.", "Two hundred and six. Not 'a lot', not 'like, a bunch'. 206. Write it on your hand, Morty-brain.");
  mcq("bones-1-02", "Which bone is the longest and strongest in the human body?", new String[] { "Humerus", "Tibia", "Fibula", "Femur" }, 3, "The femur (thigh bone) is the longest and strongest bone. The tibia is the second longest and the main weight-bearing bone of the lower leg; the humerus is the longest bone of the arm.", "Femur. The bone holding up your whole body while you stand there not knowing what a femur is.");
  mcq("bones-1-03", "Which structure protects the heart and lungs?", new String[] { "The rib cage (ribs and sternum)", "The pelvis", "The skull", "The clavicles" }, 0, "The rib cage - 12 pairs of ribs, the sternum in front and the thoracic vertebrae behind - surrounds the heart and lungs. The pelvis protects pelvic organs like the bladder; the skull protects the brain.", "Ribs: nature's airbag, except it's always deployed and it cracks if you fall off a *burp* hoverboard.");
  mcq("bones-1-04", "What does red bone marrow make?", new String[] { "Blood cells", "Bile", "Insulin", "Synovial (joint) fluid" }, 0, "Red bone marrow makes blood cells - red cells, white cells and platelets - a process called hematopoiesis. Bile is made by the liver, insulin by the pancreas, and joint fluid by the synovial membrane.", "Your bones are tiny blood factories. Inside every skeleton there's a stem cell sweatshop. Science is gross.");
  mcq("bones-1-05", "Bones store most of the body's supply of which mineral?", new String[] { "Iron", "Sodium", "Calcium", "Iodine" }, 2, "About 99% of the body's calcium is stored in bone as hydroxyapatite (a calcium phosphate crystal). Most iron is in hemoglobin, iodine is used by the thyroid, and sodium is mostly in body fluids.", "Calcium. Your skeleton is a calcium bank, and your blood robs it whenever it feels like it.");
  mcq("bones-1-06", "What is the proper name for the kneecap?", new String[] { "Fibula", "Patella", "Femur", "Pelvis" }, 1, "The patella (kneecap) sits in front of the knee inside the quadriceps tendon and helps the thigh muscles straighten the knee more efficiently. The femur is the thigh bone; the fibula is the thin outer leg bone.", "Patella. Sounds like a pasta. It's a kneecap. Don't eat it.");
  mcq("bones-1-07", "Which skull bone forms the movable lower jaw?", new String[] { "Maxilla", "Frontal bone", "Occipital bone", "Mandible" }, 3, "The mandible is the lower jaw and the only skull bone with a freely movable joint (the temporomandibular joint). The maxilla is the upper jaw, which does not move.", "The mandible: the bone you flap to say wrong answers. The maxilla's smarter. It stays still.");
  mcq("bones-1-08", "Which structure surrounds and protects the spinal cord?", new String[] { "Sternum", "Pelvis", "Vertebral column", "Clavicle" }, 2, "The spinal cord runs through the vertebral canal, the tunnel formed by the stacked vertebrae of the vertebral column (spine). The sternum is the breastbone in the front of the chest.", "Your spine is armor for the cable that runs your whole body. Nice to know one part of you has a backbone.");
  label("bones-1-09", "skeleton", "skull", "Click the skull.", "The skull is the bony case of the head. It protects the brain and holds the eyes, inner ears and teeth; its only freely movable bone is the mandible (lower jaw).", "It's the round thing on top. The one with nothing in it, in your case.");
  label("bones-1-10", "skeleton", "femur", "Click the femur (thigh bone).", "The femur is the single bone of the thigh, running from the hip to the knee. It is the longest and strongest bone in the body.", "Biggest bone in the body and you still have to look for it. *burp* Unbelievable.");
  label("bones-1-11", "skeleton", "ribs", "Click the ribs.", "The 12 pairs of ribs curve around the chest from the spine toward the front, forming the rib cage that protects the heart and lungs and moves when you breathe.", "Curvy bones around the chest. Like a xylophone, if xylophones kept your lungs from falling out.");
  level(2);
  lesson("bones-2-L1", "Axial vs appendicular", "AXIAL skeleton (80 bones): skull, vertebral column, ribs and sternum, plus the hyoid and ear ossicles. APPENDICULAR skeleton (126): the limbs plus their girdles - pectoral (clavicle, scapula) and pelvic (hip bones). The spine has 7 cervical, 12 thoracic and 5 lumbar vertebrae, then the sacrum (5 fused) and coccyx.", "Axial is the trunk, appendicular is the dangly bits. It's not rocket science. Rocket science is easier, actually.", "skeleton", "vertebral_column");
  lesson("bones-2-L2", "Inside a long bone", "A long bone has a shaft (diaphysis) and two ends (epiphyses), covered by periosteum except at the cartilage-capped joints. Shaft wall = compact bone made of osteons: rings of bone around a central canal with vessels. Ends hold spongy (trabecular) bone with red marrow; the medullary cavity holds yellow, fatty marrow in adults.", "Compact outside, spongy inside. Like a Szechuan nugget, except this one holds up your *burp* body.", "skeleton", "humerus");
  lesson("bones-2-L3", "Bone cells and growth", "OsteoBlasts Build bone: they secrete osteoid (mostly type I collagen) that then mineralizes. Osteoblasts trapped in their own matrix become osteocytes, which sense mechanical strain. OsteoClasts are big multinucleated cells that resorb bone. Long bones grow in length at the epiphyseal (growth) plate, which closes after puberty.", "Blasts build, clasts crush. Your skeleton gets torn down and rebuilt nonstop. Like my garage after Morty touches stuff.", "skeleton", "femur");
  lesson("bones-2-L4", "Ribs and joints", "Ribs 1-7 are true ribs (own costal cartilage to the sternum); 8-12 are false: 8-10 join the cartilage above, 11-12 'float' (no front attachment). Joints: fibrous (skull sutures, nearly immovable), cartilaginous (intervertebral discs, pubic symphysis), synovial (freely movable: hinge like the elbow, ball-and-socket like the hip).", "Floating ribs: the ones too lazy to reach the sternum. Relatable, I'm sure.", "skeleton", "sternum");
  mcq("bones-2-01", "How many cervical (neck) vertebrae do humans have?", new String[] { "7", "5", "8", "12" }, 0, "There are 7 cervical vertebrae (almost all mammals, even giraffes, have 7). Don't confuse them with the 8 cervical spinal NERVES. There are 12 thoracic and 5 lumbar vertebrae.", "Seven. Same as a giraffe. The giraffe just used theirs better.");
  mcq("bones-2-02", "Which cell resorbs (breaks down) bone?", new String[] { "Osteoblast", "Osteocyte", "Osteoclast", "Chondrocyte" }, 2, "Osteoclasts are large multinucleated cells of the monocyte/macrophage lineage that dissolve bone mineral and digest matrix. Osteoblasts build bone, osteocytes maintain it, and chondrocytes make cartilage.", "Osteo-CLAST. Clast like 'crash'. They demolish bone. My kind of cell.");
  mcq("bones-2-03", "Which cell secretes new bone matrix (osteoid)?", new String[] { "Osteoclast", "Osteocyte", "Chondroblast", "Osteoblast" }, 3, "Osteoblasts secrete osteoid (mostly type I collagen), which then mineralizes with calcium phosphate (hydroxyapatite). Once surrounded by their own matrix they become osteocytes. Chondroblasts make cartilage, not bone.", "Blast builds. Mix it up with clast on an exam and I'm portaling you to a dimension made of *burp* flashcards.");
  mcq("bones-2-04", "Which bone belongs to the APPENDICULAR skeleton?", new String[] { "Sternum", "Scapula", "Sacrum", "Hyoid" }, 1, "The scapula is part of the pectoral girdle, which attaches the arm to the trunk, so it is appendicular. The sternum, the sacrum (part of the vertebral column) and the hyoid are all axial.", "Scapula hangs off the trunk to hold your arm. Appendage-ular. The sacrum's in your spine, Morty-brain.");
  mcq("bones-2-05", "Where does a child's long bone grow in LENGTH?", new String[] { "Epiphyseal (growth) plate", "Periosteum", "Medullary cavity", "Articular cartilage" }, 0, "Length comes from cartilage cells multiplying at the epiphyseal plate, then being replaced by bone. The periosteum adds bone to the OUTSIDE, making bones wider (appositional growth), not longer.", "Growth plates. They fuse after puberty, which is why you're stuck at this height and this IQ.");
  mcq("bones-2-06", "What is the basic structural unit of compact bone?", new String[] { "Trabecula", "Lacuna", "Sarcomere", "Osteon (Haversian system)" }, 3, "An osteon is a cylinder of concentric bone layers (lamellae) around a central (Haversian) canal carrying vessels and nerves. Trabeculae are the struts of spongy bone; lacunae are the tiny cavities that hold osteocytes.", "Osteons: tiny tree-ring tubes. Compact bone is a bundle of them. Like *burp* a fistful of straws, but useful.");
  mcq("bones-2-07", "Which rib pairs are the 'floating' ribs?", new String[] { "1 and 2", "8 to 10", "11 and 12", "6 and 7" }, 2, "Ribs 11-12 have no anterior attachment, so they 'float'. Ribs 1-7 are true ribs (own cartilage to the sternum). Ribs 8-12 are all false ribs: 8-10 attach via the cartilage of the rib above, and 11-12 are the floating subset of the false ribs.", "Two floating pairs, 11 and 12. They just hang out in the back doing nothing. Like you in lectures.");
  mcq("bones-2-08", "What type of joint is the hip?", new String[] { "Synovial hinge joint", "Synovial ball-and-socket joint", "Fibrous suture", "Cartilaginous symphysis" }, 1, "The rounded head of the femur sits in the cup-shaped acetabulum of the pelvis: a ball-and-socket synovial joint that moves in many directions. The elbow is a hinge joint; skull sutures are fibrous; the pubic symphysis is cartilaginous.", "Ball in a socket. Moves every which way. Unlike your brain, which only moves toward snacks.");
  label("bones-2-09", "skeleton", "sternum", "Click the sternum (breastbone), where the true ribs attach.", "The sternum is the flat bone in the middle of the chest. The costal cartilages of ribs 1-7 attach directly to it, and it joins the clavicles at the sternoclavicular joints.", "Flat bone in the middle of your chest. The thing CPR pushes on. Hard. Very hard.");
  label("bones-2-10", "skeleton", "clavicle", "Click the clavicle (collarbone).", "The clavicle is an S-shaped strut between the sternum and the acromion of the scapula. It holds the arm out away from the trunk and is one of the most commonly fractured bones.", "The collarbone: holds your shoulder out like a coat hanger. Snaps easily. Like your attention span.");
  label("bones-2-11", "skeleton", "fibula", "Click the thin bone on the outer (lateral) side of the leg.", "The fibula runs alongside the tibia on the lateral side of the leg. It carries little body weight but anchors muscles and forms the bump on the outside of the ankle (lateral malleolus).", "Fibula: the tibia's skinny sidekick. Carries almost no weight. Like Morty on an adventure.");
  level(3);
  lesson("bones-3-L1", "Two ways to make bone", "Intramembranous ossification: mesenchyme becomes bone directly - flat bones of the skull vault, much of the face and most of the clavicle. Endochondral ossification: a hyaline cartilage model is replaced by bone - long bones, vertebrae, pelvis and skull base. Primary centers form in the shaft, secondary ones in the epiphyses.", "Skull goes membrane-to-bone directly; long bones take the cartilage detour. Both still faster than you learning this.", "skeleton", "skull");
  lesson("bones-3-L2", "Calcium control", "PTH (parathyroid glands) raises blood Ca2+: it increases bone resorption, increases kidney Ca2+ reabsorption and phosphate excretion, and stimulates 1-alpha-hydroxylase to make calcitriol (active vitamin D), which boosts gut Ca2+ and phosphate absorption. Calcitonin (thyroid C cells) lowers Ca2+ by inhibiting osteoclasts.", "PTH pumps calcium up, calcitonin nudges it down - barely. Calcitonin's the Jerry of hormones. *burp* Technically there.", "", "");
  lesson("bones-3-L3", "Fractures that bite back", "FOOSH (fall on outstretched hand) + snuffbox pain = scaphoid fracture; blood enters distally, so the proximal pole risks avascular necrosis. Midshaft humerus: radial nerve (wrist drop). Surgical neck: axillary nerve. Femoral neck: medial circumflex femoral artery (head necrosis). Fibular neck: common fibular nerve (foot drop).", "Break the wrong bone and you wreck the nerve next to it too. Two-for-one deal. Biology's Black Friday.", "skeleton", "carpals");
  lesson("bones-3-L4", "Bone disease basics", "Osteoporosis: too LITTLE bone, normally mineralized. Typical after menopause (estrogen loss -> more osteoclast activity); vertebral compression, hip and wrist fractures; Ca2+, phosphate, PTH and ALP normal; DEXA T-score -2.5 or lower. Osteomalacia (rickets in kids): poorly MINERALIZED bone, usually from vitamin D deficiency.", "Osteoporosis: not enough bone. Osteomalacia: bone that's too soft. Different problems, same crappy ending: snap.", "skeleton", "vertebral_column");
  mcq("bones-3-01", "Which bones form mainly by intramembranous ossification?", new String[] { "Femur and tibia", "Vertebrae", "Flat bones of the skull vault", "Phalanges" }, 2, "In intramembranous ossification, mesenchyme becomes bone directly (skull vault, much of the face, most of the clavicle). Long bones, vertebrae and phalanges form by endochondral ossification, replacing a cartilage model.", "Skull vault. No cartilage middleman. Even your bones cut corners better than you do.");
  mcq("bones-3-02", "After a fall on an outstretched hand, a 22-year-old has tenderness in the anatomical snuffbox. Which bone is most likely fractured?", new String[] { "Scaphoid", "Lunate", "Hamate", "Pisiform" }, 0, "The scaphoid is the most commonly fractured carpal, typically after a FOOSH, with snuffbox tenderness; early X-rays may be normal. Its blood enters distally, so the proximal pole risks avascular necrosis. The lunate is the most commonly DISLOCATED carpal.", "Snuffbox pain means scaphoid until proven otherwise. Miss it and the bone dies. Like your social life.");
  mcq("bones-3-03", "A midshaft fracture of the humerus is most likely to injure which nerve?", new String[] { "Axillary nerve", "Radial nerve", "Ulnar nerve", "Median nerve" }, 1, "The radial nerve runs in the radial (spiral) groove on the back of the humeral shaft. Injury causes wrist drop (weak wrist and finger extension). The axillary nerve is at risk in surgical neck fractures; the ulnar nerve behind the medial epicondyle.", "Radial groove, radial nerve, wrist drop. The bone LITERALLY tells you. *burp* Read the bone.");
  mcq("bones-3-04", "Which effect does PTH have on the kidney?", new String[] { "Less Ca2+ reabsorption, less phosphate excretion", "More reabsorption of both Ca2+ and phosphate", "Inhibits 1-alpha-hydroxylase, lowering calcitriol", "More Ca2+ reabsorption, more phosphate excretion" }, 3, "PTH increases Ca2+ reabsorption in the distal tubule and decreases phosphate reabsorption in the proximal tubule (phosphaturia). It also stimulates 1-alpha-hydroxylase, raising calcitriol. Net effect: blood Ca2+ up, phosphate down.", "PTH keeps the calcium and dumps the phosphate. Picky. Like me at a bar.");
  mcq("bones-3-05", "Calcitonin is secreted by which cells?", new String[] { "Parafollicular (C) cells of the thyroid", "Chief cells of the parathyroid", "Follicular cells of the thyroid", "Osteoblasts" }, 0, "Calcitonin comes from the parafollicular C cells of the thyroid (neural crest origin) and lowers blood Ca2+ by inhibiting osteoclasts. Parathyroid chief cells make PTH; thyroid follicular cells make T3 and T4.", "C cells make Calcitonin. C for Calcium-lowering. I'm basically doing your homework at this point.");
  mcq("bones-3-06", "A 68-year-old woman has a vertebral compression fracture. Serum Ca2+, phosphate, PTH and alkaline phosphatase are all normal. Most likely diagnosis?", new String[] { "Osteomalacia", "Primary hyperparathyroidism", "Osteoporosis", "Paget disease of bone" }, 2, "Osteoporosis reduces bone mass, but the remaining bone is normally mineralized, so labs are typically normal. Osteomalacia gives low phosphate with high ALP and PTH; primary hyperparathyroidism high Ca2+ and PTH; Paget disease a high ALP.", "Normal labs, broken spine, postmenopausal. Osteoporosis. The labs are fine, she's not. *burp* Classic.");
  mcq("bones-3-07", "A displaced femoral neck fracture risks avascular necrosis of the femoral head, mainly by disrupting which artery?", new String[] { "Obturator artery", "Medial circumflex femoral artery", "Superior gluteal artery", "Popliteal artery" }, 1, "Most blood to the femoral head comes from retinacular branches of the medial circumflex femoral artery running up the femoral neck. The small artery of the ligamentum teres (from the obturator artery) contributes little in adults.", "Snap the neck of the femur, kill the head. Sounds like a mob movie. It's just plumbing.");
  mcq("bones-3-08", "A fracture of the fibular neck causes foot drop by injuring which nerve?", new String[] { "Tibial nerve", "Femoral nerve", "Obturator nerve", "Common fibular (peroneal) nerve" }, 3, "The common fibular nerve wraps around the neck of the fibula just under the skin. Damage weakens dorsiflexion and eversion: foot drop and a high-stepping gait. The tibial nerve runs deep in the back of the leg and drives plantarflexion.", "That nerve's wrapped around the fibula like a cheap scarf. Whack it and your foot flops. Physics, Morty-brain.");
  label("bones-3-09", "skeleton", "carpals", "Click the group of bones that contains the scaphoid.", "The 8 carpals sit in two rows between the forearm and the metacarpals: scaphoid, lunate, triquetrum, pisiform (proximal) and trapezium, trapezoid, capitate, hamate (distal).", "Eight tiny pebbles in your wrist. The scaphoid's the one that breaks and then dies. Charming.");
  label("bones-3-10", "skeleton", "patella", "Click the largest sesamoid bone in the body.", "The patella is a sesamoid bone (a bone that develops inside a tendon), here the quadriceps tendon. It increases the leverage of the quadriceps for knee extension and protects the front of the knee.", "Sesamoid: a bone grown inside a tendon, like a seed. The kneecap's the biggest. *burp* Plant that in your brain.");
  label("bones-3-11", "skeleton", "scapula", "Click the bone that bears the glenoid cavity.", "The glenoid cavity is the shallow socket on the lateral scapula that receives the head of the humerus at the shoulder joint. The scapula also bears the acromion and the coracoid process.", "Shallow socket, huge range of motion, dislocates if you look at it wrong. Shoulder design by committee.");
  label("bones-3-12", "skeleton", "sacrum", "Click the bone formed by 5 fused vertebrae.", "The sacrum is a triangular bone of 5 fused sacral vertebrae. It sits between the hip bones at the sacroiliac joints and passes body weight from the spine to the pelvis.", "Five vertebrae fused into one. Teamwork! Something you've never experienced.");
  level(4);
  lesson("bones-4-L1", "RANKL: the remodeling switch", "Osteoblast-lineage cells make RANKL, which binds RANK on osteoclast precursors (with M-CSF) to drive osteoclast formation; OPG is a decoy receptor for RANKL. PTH raises RANKL and lowers OPG; estrogen does the opposite, so menopause speeds resorption. Denosumab = anti-RANKL antibody; bisphosphonates cause osteoclast apoptosis.", "Osteoclasts can't even switch on without a permission slip from osteoblasts. Bone bureaucracy. *burp* I hate it.", "", "");
  lesson("bones-4-L2", "Read the labs", "Pattern = Ca2+ / phosphate / ALP / PTH. Osteoporosis: all normal. Vitamin D-deficient osteomalacia: low-normal / low / high / high. Primary hyperparathyroidism: high / low / normal-high / high. Paget disease: normal / normal / very high / normal. Paget = chaotic osteoclast then osteoblast activity -> thick, weak 'mosaic' bone.", "Four numbers, four diseases. Can't read a lab panel? Go be a *burp* vibes-based healer somewhere else.", "skeleton", "skull");
  lesson("bones-4-L3", "Broken blueprints", "Osteogenesis imperfecta: defective type I collagen (COL1A1/2) -> fractures, blue sclerae, hearing loss, bad teeth. Achondroplasia (autosomal dominant): activating FGFR3 mutation slows endochondral growth -> short limbs, relatively large head. Osteopetrosis: osteoclasts can't resorb -> dense, brittle bone, marrow failure.", "One bad gene and the whole skeleton's a disaster. Like the multiverse version of you that's even dumber.", "skeleton", "femur");
  lesson("bones-4-L4", "Bone tumors by address", "Osteosarcoma: teens, METAPHYSIS around the knee, sunburst pattern and Codman triangle; risk with Rb mutations and Paget disease. Ewing sarcoma: children, DIAPHYSIS (or metadiaphysis) of long bones or pelvis, onion-skin periosteal reaction, t(11;22). Giant cell tumor: age 20-40, EPIPHYSIS around the knee, 'soap-bubble' X-ray.", "Bone tumors pick neighborhoods like real estate agents. Metaphysis, diaphysis, epiphysis. Location, location, tumor.", "skeleton", "tibia");
  mcq("bones-4-01", "Denosumab reduces fracture risk in osteoporosis by which mechanism?", new String[] { "Binds hydroxyapatite and induces osteoclast apoptosis", "Recombinant PTH analog given intermittently", "Monoclonal antibody that blocks RANKL", "Selective estrogen receptor modulator in bone" }, 2, "Denosumab binds RANKL (acting like OPG), so precursors can't become active osteoclasts and resorption falls. Bisphosphonates bind hydroxyapatite and induce osteoclast apoptosis; teriparatide is a PTH analog; raloxifene is a SERM.", "Block the signal, no osteoclasts. Denosumab's the bouncer at osteoclast club. Ends in -mab: antibody, genius.");
  mcq("bones-4-02", "Osteoclasts have essentially no PTH receptors, yet PTH increases bone resorption. Which mechanism best explains this?", new String[] { "Osteoblast-lineage cells raise RANKL and lower OPG", "PTH binds calcitonin receptors on osteoclasts", "Osteoblasts secrete more OPG, which activates RANK", "PTH directly inhibits osteoclast apoptosis" }, 0, "PTH binds PTH1R on osteoblast-lineage cells (osteoblasts and osteocytes), which increase RANKL and decrease OPG. More RANKL-RANK binding drives osteoclast formation and activity. OPG is a decoy that BLOCKS RANKL, so more OPG would reduce resorption.", "PTH can't talk to osteoclasts, so it whispers to osteoblasts. Bone telephone. *burp* Very mature.");
  mcq("bones-4-03", "A 70-year-old man has bone pain, a hat that no longer fits and hearing loss. Ca2+, phosphate and PTH are normal; ALP is very high. Diagnosis?", new String[] { "Osteomalacia", "Primary hyperparathyroidism", "Osteoporosis", "Paget disease of bone" }, 3, "Paget disease: localized, disordered remodeling (osteoclast overactivity, then chaotic osteoblast activity) makes thick but weak 'mosaic' bone. Isolated high ALP is typical. Skull enlargement can compress cranial nerves (hearing loss); osteosarcoma risk rises.", "Hat doesn't fit, ALP through the roof, everything else normal. Paget. His skull's growing. Mine's just full.");
  mcq("bones-4-04", "Which lab pattern fits osteomalacia caused by vitamin D deficiency?", new String[] { "High Ca2+, low phosphate, high PTH", "Low phosphate, high PTH, high ALP, low-normal Ca2+", "Ca2+, phosphate, ALP and PTH all normal", "Isolated, very high ALP" }, 1, "Low vitamin D -> less gut Ca2+ and phosphate absorption -> secondary hyperparathyroidism. PTH keeps Ca2+ near normal but wastes phosphate in urine; poor mineralization raises ALP. High Ca2+ with high PTH suggests PRIMARY hyperparathyroidism.", "Vitamin D's gone, PTH panics, phosphate gets flushed. Hormonal dominoes. Watch them fall.");
  mcq("bones-4-05", "A 6-year-old has had several fractures from minor falls, blue sclerae and discolored, fragile teeth. A defect in which protein is most likely?", new String[] { "Type I collagen", "Type II collagen", "Fibrillin-1", "FGFR3" }, 0, "Osteogenesis imperfecta usually comes from COL1A1/COL1A2 mutations that reduce or distort type I collagen, the main protein of bone, sclera and dentin (child abuse must still be excluded). Type II collagen is cartilage; fibrillin-1 is Marfan; FGFR3 is achondroplasia.", "Bones like chalk, blue sclerae, crumbly teeth. Type I collagen. Bone's made of it. Respect it.");
  mcq("bones-4-06", "Achondroplasia is best explained by which defect?", new String[] { "Loss of FGFR3 impairing intramembranous ossification", "Type I collagen defect weakening osteoid", "Activating FGFR3 mutation impairing endochondral ossification", "Osteoclast failure from carbonic anhydrase II loss" }, 2, "A gain-of-function FGFR3 mutation inhibits chondrocyte proliferation in growth plates, so endochondral bones (limbs) are short while the intramembranous skull vault is spared and the head looks large. Autosomal dominant; most cases are new mutations linked to older fathers.", "The gene's stuck ON and tells growth plates to stop. An overachieving gene. The opposite of you.");
  mcq("bones-4-07", "An infant has diffusely dense but brittle bones, anemia, thrombocytopenia, hepatosplenomegaly and vision loss. What is the core defect?", new String[] { "Osteoblasts cannot mineralize osteoid", "Type I collagen is abnormal", "PTH secretion is excessive", "Osteoclasts cannot resorb bone" }, 3, "Osteopetrosis: defective osteoclast acid secretion (e.g. carbonic anhydrase II mutations) means bone is never remodeled. It gets dense but brittle, crowds out marrow (cytopenias, extramedullary hematopoiesis) and narrows foramina (cranial nerve palsies).", "No demolition crew, so bone piles up and crushes the marrow out. Hoarding, but with calcium.");
  mcq("bones-4-08", "A 15-year-old boy has knee pain and a destructive lesion of the distal femoral metaphysis with a 'sunburst' pattern and Codman triangle. Diagnosis?", new String[] { "Ewing sarcoma", "Osteosarcoma", "Giant cell tumor", "Osteochondroma" }, 1, "Osteosarcoma is the most common primary malignant bone tumor of teens, classically in the metaphysis around the knee with sunburst and Codman triangle. Ewing sarcoma favors the diaphysis (onion-skin); giant cell tumor the epiphysis at age 20-40.", "Teen, knee, metaphysis, sunburst. If you said Ewing, you get an onion-skin of shame. *burp*");
  label("bones-4-09", "skeleton", "tarsals", "Click the bone group containing the talus, a bone with no muscle attachments.", "The 7 tarsals form the ankle and rear foot: talus, calcaneus, navicular, cuboid and three cuneiforms. The talus makes the ankle joint with the tibia and fibula and has no muscle attachments; the calcaneus is the heel bone.", "Seven tarsals, eight carpals. Feet got one fewer. Evolution ran out of budget.");
  label("bones-4-10", "skeleton", "radius", "Click the bone whose distal end breaks in a Colles fracture.", "A Colles fracture is a distal radius fracture with dorsal displacement of the fragment ('dinner fork' deformity), classically after a fall on an outstretched hand in an older adult with osteoporosis.", "Fall on your hand, radius snaps, wrist looks like a dinner fork. Bon appetit, genius.");
  label("bones-4-11", "skeleton", "ulna", "Click the bone broken in a 'nightstick' fracture (forearm raised to block a blow).", "A nightstick fracture is an isolated fracture of the ulnar shaft, which lies just under the skin along the medial (pinky) border of the forearm when it is raised to shield the face. The ulna's olecranon forms the point of the elbow.", "Block a club with your forearm and the ulna takes the hit. Next time try ducking. Or a *burp* portal.");
  label("bones-4-12", "skeleton", "metatarsals", "Click the bones where 'march' stress fractures classically occur.", "The metatarsals are the 5 long bones of the forefoot. Repetitive loading (marching, running) causes stress fractures, classically of the 2nd metatarsal shaft; the base of the 5th metatarsal is another classic fracture site.", "Soldiers march, metatarsals crack. Repetition breaks things. Like my patience with you.");
}

void content_muscles() {
  topic("muscles", "MUSCLES", "muscles");
  level(1);
  lesson("muscles-1-L1", "Three kinds of muscle", "SKELETAL muscle moves bones; it is striated (striped) and voluntary. CARDIAC muscle is found only in the heart; it is striated but involuntary. SMOOTH muscle forms the walls of hollow organs and blood vessels (stomach, intestines, bladder, arteries); it is not striated and is involuntary. You have more than 600 skeletal muscles.", "Three muscle types and you're struggling with one. The thumb muscle for scrolling doesn't count, Morty-brain.", "muscles", "pectoralis_major");
  lesson("muscles-1-L2", "Muscles only pull", "A muscle can only pull: it contracts (shortens) and tugs on a bone through a tendon. It can't push, so muscles work in opposing pairs. The biceps brachii bends (flexes) the elbow; the triceps on the back of the arm straightens (extends) it. When one contracts, its partner relaxes.", "Muscles can't push. Ever. Like you can't push yourself to study. At least they have an excuse.", "muscles", "biceps_brachii");
  lesson("muscles-1-L3", "Famous muscles", "Deltoid: caps the shoulder and lifts the arm out to the side. Pectoralis major: the big chest muscle. Rectus abdominis: the 'six-pack', bends the trunk forward. Quadriceps femoris: front of the thigh, straightens the knee. Gastrocnemius: the calf, points the foot down so you can stand on tiptoe.", "Six-pack, pecs, quads. Your gym-bro vocabulary is now *burp* anatomically correct. Congrats, you're insufferable.", "muscles", "quadriceps_femoris");
  lesson("muscles-1-L4", "Tendons and ligaments", "Tendons join muscle to bone; ligaments join bone to bone. The calcaneal (Achilles) tendon is the thickest and strongest tendon: it joins the calf muscles to the heel bone. Muscles also make heat - shivering is rapid, involuntary muscle contraction that warms you up.", "Tendon: muscle to bone. Ligament: bone to bone. Mix them up and Achilles comes back to kick you.", "muscles", "gastrocnemius");
  mcq("muscles-1-01", "Which type of muscle is found only in the heart?", new String[] { "Skeletal muscle", "Smooth muscle", "Cardiac muscle", "Voluntary striated muscle" }, 2, "Cardiac muscle exists only in the heart wall (myocardium). It is striated like skeletal muscle but involuntary: it keeps beating on its own rhythm without you thinking about it.", "Cardiac muscle. Beats about 100,000 times a day without your input. Thank God, honestly.");
  mcq("muscles-1-02", "Which type of muscle can you control voluntarily?", new String[] { "Skeletal muscle", "Cardiac muscle", "Smooth muscle of the intestine", "Smooth muscle of arteries" }, 0, "Skeletal muscle is voluntary: you decide to move it, and motor nerves carry the command. Cardiac and smooth muscle are involuntary, run by the heart's own pacemaker, the autonomic nervous system and hormones.", "Skeletal muscle obeys you. Apparently something has to.");
  mcq("muscles-1-03", "What connects a muscle to a bone?", new String[] { "Ligament", "Cartilage", "Nerve", "Tendon" }, 3, "Tendons are tough cords of dense connective tissue joining muscle to bone. Ligaments connect bone to bone at joints; cartilage cushions joint surfaces; nerves carry signals.", "Tendon: muscle to bone. Ligament: bone to bone. Two words. You can handle two words. Probably.");
  mcq("muscles-1-04", "How do muscles move bones?", new String[] { "By lengthening and pushing them away", "By contracting and pulling on them", "By pumping fluid into the joints", "By making the bones bend" }, 1, "Muscles can only pull. They shorten (contract) and pull on bones through tendons. To move a joint back, an opposing muscle on the other side has to pull - which is why muscles work in pairs.", "Pull. Only pull. Muscles are like your relationships: all take, no push.");
  mcq("muscles-1-05", "Which muscle bends (flexes) the elbow?", new String[] { "Biceps brachii", "Triceps brachii", "Deltoid", "Gastrocnemius" }, 0, "The biceps brachii on the front of the upper arm flexes the elbow (and turns the palm up). Its antagonist, the triceps brachii on the back of the arm, extends the elbow.", "Biceps flexes. The muscle gym bros kiss in mirrors. *burp* Now you know what they're kissing.");
  mcq("muscles-1-06", "Where is smooth muscle found?", new String[] { "Attached to the bones of the arm", "Only in the heart", "In the tongue and lips", "Walls of the stomach, intestines and blood vessels" }, 3, "Smooth muscle forms the walls of hollow organs and tubes - stomach, intestines, bladder, uterus, airways and blood vessels - squeezing them slowly and automatically. The tongue and lips are skeletal muscle; the heart is cardiac muscle.", "Smooth muscle squeezes your lunch along without asking. Your gut works harder than you do.");
  mcq("muscles-1-07", "Which muscle forms the 'six-pack' on the front of the abdomen?", new String[] { "External oblique", "Pectoralis major", "Rectus abdominis", "Trapezius" }, 2, "The rectus abdominis runs vertically from the pubis up to the rib cartilages and sternum; bands of tendon crossing it make the 'six-pack' look. It bends the trunk forward, as in a sit-up. The external oblique covers the sides of the abdomen.", "Everybody has a six-pack. Yours is just in witness protection under the *burp* snacks.");
  mcq("muscles-1-08", "Which calf muscle lets you rise up onto your tiptoes?", new String[] { "Tibialis anterior", "Gastrocnemius", "Quadriceps femoris", "Sartorius" }, 1, "The gastrocnemius (with the deeper soleus) pulls on the heel through the calcaneal (Achilles) tendon, pointing the foot down (plantarflexion). The tibialis anterior on the shin does the opposite: it lifts the foot up.", "Gastrocnemius. Ballet dancers, sprinters, and you reaching for the top shelf. Same muscle.");
  label("muscles-1-09", "muscles", "biceps_brachii", "Click the biceps brachii.", "The biceps brachii lies on the front of the upper arm. It flexes the elbow and supinates the forearm (turns the palm up).", "The 'gun show' muscle. Point at it. No, not yours. Yours is a cap gun.");
  label("muscles-1-10", "muscles", "pectoralis_major", "Click the pectoralis major (chest muscle).", "The pectoralis major is the large fan-shaped chest muscle running from the clavicle and sternum to the humerus. It pulls the arm across the body (adduction) and rotates it inward.", "Pecs. The bench-press muscle. It pulls your arm across your chest so your hand can shove stuff. *burp* Ironic.");
  label("muscles-1-11", "muscles", "quadriceps_femoris", "Click the quadriceps femoris on the front of the thigh.", "The quadriceps femoris is four muscles (rectus femoris and three vasti) that join into one tendon over the patella. It extends (straightens) the knee.", "Quad means four. Four muscles, one main job: straighten the knee. Even they can count.");
  level(2);
  lesson("muscles-2-L1", "Muscle, zoomed in", "Whole muscle (wrapped in epimysium) -> fascicles, bundles of fibers (perimysium) -> muscle fibers, long multinucleated cells (endomysium) -> myofibrils -> sarcomeres, the repeating contractile units. The fiber's membrane is the sarcolemma; its specialized ER, the sarcoplasmic reticulum (SR), stores Ca2+.", "Epi, peri, endo: outside, around, inside. Greek prefixes. The cheat codes you never bothered to learn.", "muscles", "deltoid");
  lesson("muscles-2-L2", "The sarcomere", "A sarcomere runs from one Z disc to the next. Thin filaments (actin) attach to the Z discs; thick filaments (myosin) sit in the middle. A band = length of the thick filaments; I band = thin filaments only; H zone = thick only. In contraction the filaments slide: the I band and H zone shrink, the A band stays the same.", "The filaments don't shrink, genius. They just *burp* slide past each other. Sliding filament theory. Like your grades: down.", "", "");
  lesson("muscles-2-L3", "From nerve to contraction", "A motor neuron releases acetylcholine (ACh) at the neuromuscular junction -> the muscle fiber fires an action potential that runs down T-tubules -> the SR releases Ca2+ -> Ca2+ binds troponin -> tropomyosin shifts off actin's binding sites -> myosin heads bind actin and pull, powered by ATP.", "Nerve, ACh, calcium, troponin, tropomyosin, myosin. Six steps. A Meeseeks could do it, and be happier about it.", "muscles", "biceps_brachii");
  lesson("muscles-2-L4", "Movement words", "Flexion decreases a joint angle; extension increases it. Abduction moves a limb away from the midline; adduction brings it back. The muscle doing the move is the agonist; the one opposing it is the antagonist. Deltoid abducts the arm; the adductors pull the thigh in; tibialis anterior lifts the foot (dorsiflexion).", "AB-duct: take away. Your arm leaves the midline, like Morty leaves any room where I explain things.", "muscles", "tibialis_anterior");
  mcq("muscles-2-01", "What is the basic contractile unit of a skeletal muscle fiber?", new String[] { "Fascicle", "Sarcolemma", "Motor end plate", "Sarcomere" }, 3, "The sarcomere, from Z disc to Z disc, is the repeating unit that actually shortens. Myofibrils are chains of sarcomeres; a fascicle is a bundle of fibers; the sarcolemma is the fiber's cell membrane.", "Sarcomere. The little engine. Thousands in a row make a myofibril. Thousands of you couldn't make a thought.");
  mcq("muscles-2-02", "Which ion released from the sarcoplasmic reticulum triggers skeletal muscle contraction?", new String[] { "Na+", "Ca2+", "K+", "Cl-" }, 1, "Depolarization makes the sarcoplasmic reticulum release Ca2+, which binds troponin and exposes binding sites on actin. Na+ entry creates the action potential, but Ca2+ is the direct trigger for contraction.", "Calcium. Bones store it, muscles use it as an on-switch. The Swiss army ion.");
  mcq("muscles-2-03", "Which neurotransmitter do motor neurons release at the neuromuscular junction?", new String[] { "Acetylcholine", "Norepinephrine", "Dopamine", "GABA" }, 0, "Motor neurons release acetylcholine, which binds nicotinic receptors on the motor end plate and depolarizes the muscle fiber. Acetylcholinesterase then breaks it down to end the signal.", "ACh. Acetylcholine. If you said dopamine, that's just your phone addiction talking.");
  mcq("muscles-2-04", "During contraction, which part of the sarcomere stays the SAME length?", new String[] { "I band", "H zone", "A band", "Distance between Z discs" }, 2, "The A band equals the length of the thick (myosin) filaments, which don't change length. As thin filaments slide toward the center, the I band and H zone narrow and the Z discs move closer together.", "A band stays, I and H shrink. The filaments themselves never shrink. Neither does your ego.");
  mcq("muscles-2-05", "To which protein does Ca2+ bind to start skeletal muscle contraction?", new String[] { "Troponin", "Tropomyosin", "Myosin", "Calmodulin" }, 0, "Ca2+ binds troponin C; the troponin complex then shifts tropomyosin, uncovering myosin-binding sites on actin. Calmodulin is the Ca2+-binding protein that does this job in smooth muscle instead.", "Troponin. Tropomyosin's the curtain, troponin pulls the rope. *burp* Theater for idiots.");
  mcq("muscles-2-06", "Which connective tissue layer surrounds a fascicle?", new String[] { "Epimysium", "Endomysium", "Periosteum", "Perimysium" }, 3, "Perimysium wraps each fascicle (bundle of fibers). Epimysium wraps the whole muscle; endomysium wraps each individual fiber. Periosteum covers bone.", "Peri means around. Around the bundle. Greek's so easy even ancient Greek toddlers spoke it.");
  mcq("muscles-2-07", "Raising your arm out to the side, away from the body's midline, is called:", new String[] { "Adduction", "Abduction", "Flexion", "Pronation" }, 1, "Abduction moves a limb away from the midline; adduction brings it back toward it. Flexion decreases the angle at a joint (like bending the elbow); pronation turns the palm down.", "AB-duction: taken AWAY. Like when aliens abduct you. They'd bring you back, though. Too dumb to keep.");
  mcq("muscles-2-08", "What does the quadriceps femoris do at the knee?", new String[] { "Flexes (bends) it", "Abducts it", "Extends (straightens) it", "Rotates it medially" }, 2, "All four parts of the quadriceps insert via the patella and patellar ligament onto the tibial tuberosity, so they extend the knee. The hamstrings on the back of the thigh flex it.", "Quads straighten, hamstrings bend. Front kicks, back curls. I'm basically your personal trainer now.");
  label("muscles-2-09", "muscles", "deltoid", "Click the main muscle that abducts the arm at the shoulder.", "The deltoid caps the shoulder, running from the clavicle, acromion and spine of the scapula to the humerus. Its middle fibers abduct the arm after the supraspinatus starts the movement.", "Shoulder pad you're born with. Raise your arm like you know the answer. You don't, but practice.");
  label("muscles-2-10", "muscles", "adductors", "Click the muscle group that pulls the thigh toward the midline.", "The adductors (adductor longus, brevis and magnus, plus gracilis and pectineus) fill the medial thigh and adduct the hip, pulling the legs together.", "Adductors: squeeze your thighs together. The groin muscles you pull trying to do a split. *burp* Don't.");
  label("muscles-2-11", "muscles", "tibialis_anterior", "Click the muscle that lifts the foot upward (dorsiflexion).", "The tibialis anterior runs down the front of the shin to the inner side of the foot. It dorsiflexes and inverts the foot, keeping your toes from catching the ground when you walk.", "Shin muscle. Lifts your toes so you don't faceplant. Clearly yours needs work.");
  level(3);
  lesson("muscles-3-L1", "Fiber types and motor units", "Motor unit = one motor neuron + all fibers it supplies. Small units give fine control (eye muscles); large ones give power. Type I (slow oxidative): red, rich in mitochondria and myoglobin, fatigue-resistant, posture. Type II (fast): more glycolytic, powerful, tire sooner. Small units are recruited first (size principle).", "Type I: marathoner. Type II: sprinter who pukes after ten seconds. *burp* Guess which one you are.", "muscles", "gastrocnemius");
  lesson("muscles-3-L2", "The cross-bridge cycle", "In T-tubules, the dihydropyridine receptor (DHPR, a voltage sensor) is mechanically linked to the ryanodine receptor (RyR1), which releases SR Ca2+. Cycle: ATP binds myosin -> head lets go of actin; ATP hydrolysis cocks the head; head binds actin; Pi release -> power stroke; ADP leaves. No ATP = rigor. SERCA pumps Ca2+ back.", "ATP is what makes myosin LET GO. No ATP, no release: rigor mortis. Corpses are just really bad at letting go.", "", "");
  lesson("muscles-3-L3", "Length, frequency, force", "Active tension peaks at an optimal sarcomere length, where thick and thin filaments overlap so the most myosin heads can bind; overstretched or overshortened muscle is weaker. Firing faster lets twitches summate before Ca2+ is pumped away; high frequency gives fused tetanus. Recruiting more motor units also adds force.", "Too stretched or too squished, muscle's weak. Goldilocks with actin. Also you, mentally.", "muscles", "quadriceps_femoris");
  lesson("muscles-3-L4", "When muscle breaks", "Myasthenia gravis: antibodies to postsynaptic nicotinic ACh receptors -> weakness that worsens with use, ptosis, diplopia. Lambert-Eaton: antibodies to presynaptic voltage-gated Ca2+ channels -> weakness that eases with repeated effort; small cell lung cancer link. Duchenne: X-linked loss of dystrophin -> boys with Gowers sign.", "MG gets worse the more you use it; Lambert-Eaton gets better. Like *burp* my hangovers versus my genius.", "", "");
  mcq("muscles-3-01", "Compared with type II fibers, type I (slow oxidative) fibers have:", new String[] { "Fewer mitochondria; rely on glycolysis", "Faster myosin ATPase; fatigue quickly", "More mitochondria and myoglobin; resist fatigue", "Larger motor units, recruited last" }, 2, "Type I fibers are red from myoglobin and dense capillaries; their many mitochondria run aerobic metabolism, so they resist fatigue (posture muscles like soleus). Fast glycolytic (type IIx) fibers are pale, fast, powerful and tire quickly.", "Myoglobin makes them red, like duck leg meat. *burp* Now I'm hungry. Focus.");
  mcq("muscles-3-02", "As force demand slowly rises, which motor units are recruited first?", new String[] { "Small units with slow, fatigue-resistant fibers", "Large units with fast, powerful fibers", "All motor units at once", "Whichever units lie closest to the skin" }, 0, "Henneman's size principle: small motor neurons have the lowest threshold, so small, slow (type I) units fire first; larger, fast, powerful units join as force needs rise. This grades force smoothly.", "Small guys first, big guns later. Same strategy I use on the Council of Ricks.");
  mcq("muscles-3-03", "What causes rigor mortis?", new String[] { "Excess ATP locking myosin heads", "No ATP, so myosin cannot detach from actin", "Ca2+ pumped back into the SR too fast", "ACh piling up at the end plate" }, 1, "ATP binding is what releases myosin from actin. After death, ATP runs out while Ca2+ leaks from the SR, so cross-bridges form and stay locked, stiffening muscles until proteins break down.", "Dead muscle can't let go because it's out of ATP. Clingy. Like Morty with my portal gun.");
  mcq("muscles-3-04", "In skeletal muscle, which T-tubule protein is the voltage sensor mechanically linked to RyR1?", new String[] { "Nicotinic acetylcholine receptor", "IP3 receptor", "SERCA pump", "Dihydropyridine receptor (L-type Ca2+ channel)" }, 3, "The DHPR in the T-tubule membrane senses depolarization and changes shape, mechanically opening RyR1 on the adjacent SR to release Ca2+. Nicotinic receptors sit at the end plate; SERCA pumps Ca2+ back into the SR for relaxation.", "DHPR flips, RyR1 opens, calcium floods out. A Rube Goldberg machine, but one that works.");
  mcq("muscles-3-05", "High-frequency stimulation produces a smooth, sustained contraction (fused tetanus) because:", new String[] { "Ca2+ stays high, so twitches summate", "Each stimulus recruits a new fiber type", "The muscle runs out of ATP and locks", "Acetylcholine release stops" }, 0, "At high firing rates, the next action potential arrives before the SR has pumped Ca2+ back, so cytosolic Ca2+ stays high and twitches fuse into a stronger sustained contraction. This is unrelated to the disease tetanus (a toxin).", "Fire fast enough and twitches merge. Summation. Like my burps merging into one *burp* continuous one.");
  mcq("muscles-3-06", "At which sarcomere length does a skeletal muscle generate its greatest active tension?", new String[] { "Maximal stretch, filaments barely overlapping", "Maximal shortening, filaments colliding", "Length with optimal actin-myosin overlap", "Tension does not depend on length" }, 2, "Active tension depends on how many myosin heads can reach actin. At the optimal length (near normal resting length) overlap is ideal. Overstretching reduces overlap; overshortening makes filaments collide and interfere.", "Goldilocks length. Not too long, not too short. The universe runs on porridge logic, apparently.");
  mcq("muscles-3-07", "A 30-year-old woman has drooping eyelids and double vision that worsen through the day and improve with rest. Her antibodies most likely target:", new String[] { "Presynaptic voltage-gated Ca2+ channels", "Postsynaptic nicotinic ACh receptors", "Acetylcholinesterase", "Muscarinic ACh receptors" }, 1, "Myasthenia gravis: autoantibodies block and destroy nicotinic ACh receptors at the motor end plate, so weakness worsens with repeated use, often starting in eye muscles. It is associated with thymic abnormalities (thymoma, hyperplasia).", "Eyes droop by evening, perk up after a nap. Antibodies eating ACh receptors. MG. Easy. *burp* Easy.");
  mcq("muscles-3-08", "A 4-year-old boy pushes on his thighs with his hands to stand up and has enlarged calves. Which protein is most likely absent?", new String[] { "Titin", "Troponin T", "Myotonic dystrophy protein kinase", "Dystrophin" }, 3, "Duchenne muscular dystrophy: X-linked frameshift deletions abolish dystrophin, which anchors the cytoskeleton to the membrane. Fibers tear and are replaced by fat and fibrous tissue (calf pseudohypertrophy). Gowers sign = proximal weakness; CK is very high.", "Gowers sign: climbing up your own legs to stand. Dystrophin's missing. Fake-big calves, real problem.");
  label("muscles-3-09", "muscles", "sternocleidomastoid", "Click the neck muscle that is fibrosed and shortened in congenital muscular torticollis (wry neck).", "The sternocleidomastoid runs from the sternum and clavicle to the mastoid process. Alone it tilts the head to its own side and turns the face away; a short, fibrosed SCM in an infant holds the head that way (torticollis). Nerve: accessory (CN XI).", "Sterno-cleido-mastoid. The name IS the directions: sternum, clavicle, mastoid. Lazy naming. Useful, though.");
  label("muscles-3-10", "muscles", "trapezius", "Click the muscle that shrugs (elevates) the shoulders.", "The trapezius is a large flat muscle (the pair forms a diamond) from the skull and spine to the clavicle and scapula. Upper fibers elevate the scapula (shrug); it also retracts and rotates the scapula. Nerve: accessory (CN XI).", "Trapezius: the shrug muscle. Your most-used muscle, judging by how you answer questions.");
  label("muscles-3-11", "muscles", "sartorius", "Click the longest muscle in the body.", "The sartorius is a strap muscle running diagonally from the anterior superior iliac spine to the medial tibia. It flexes, abducts and laterally rotates the hip and flexes the knee ('tailor' sitting). Nerve: femoral.", "Sartorius: the tailor's muscle. Longest muscle you've got, shortest attention span to match.");
  label("muscles-3-12", "muscles", "external_oblique", "Click the muscle whose aponeurosis forms the inguinal ligament.", "The external oblique is the most superficial lateral abdominal muscle; its fibers run down and medially ('hands in pockets'). The lower edge of its aponeurosis, from the ASIS to the pubic tubercle, forms the inguinal ligament.", "Hands-in-pockets fibers. Its lower edge becomes the inguinal ligament. Hernia country. Watch your step.");
  level(4);
  lesson("muscles-4-L1", "Smooth muscle switches", "Smooth muscle has no troponin. Ca2+ (entering via L-type channels or released from SR by IP3) binds calmodulin -> activates myosin light-chain kinase (MLCK) -> phosphorylated myosin binds actin. Myosin light-chain phosphatase reverses it. NO -> guanylyl cyclase -> cGMP -> activates the phosphatase -> relaxation (vasodilation).", "No troponin in smooth muscle. It's calmodulin and kinases. Different franchise, same calcium. *burp* Reboot energy.", "", "");
  lesson("muscles-4-L2", "E-C coupling gone wrong", "Skeletal: DHPR mechanically opens RyR1, so no extracellular Ca2+ is needed. Cardiac: Ca2+ entering via L-type channels triggers RyR2 (Ca2+-induced Ca2+ release). Malignant hyperthermia: usually RYR1 mutation; volatile anesthetics or succinylcholine -> massive Ca2+ release -> rigidity, high CO2, fever. Dantrolene blocks RyR1.", "Anesthetic gas + bad RyR1 = patient becomes a space heater. Dantrolene shuts the gate. Anesthesiologists' favorite nightmare.", "", "");
  lesson("muscles-4-L3", "Hacking the junction", "Succinylcholine activates nicotinic receptors and keeps the end plate depolarized, so nearby Na+ channels stay inactivated (fasciculations, then paralysis). Rocuronium is a competitive, nondepolarizing blocker. Lambert-Eaton: antibodies to presynaptic P/Q-type Ca2+ channels; strength and reflexes improve briefly with exercise.", "Succinylcholine kicks the door open and jams it. Rocuronium just stands in the doorway. Either way: no muscle party.", "", "");
  lesson("muscles-4-L4", "Nerve injury -> weak muscle", "Axillary (humeral surgical neck) -> deltoid: weak abduction past ~15 degrees. Musculocutaneous -> biceps: weak elbow flexion, supination. Median -> most forearm flexors. Obturator -> adductors. Fibular neck: common -> deep fibular -> tibialis anterior: foot drop. CN XI -> SCM, trapezius; a posterior triangle cut spares SCM.", "Name the nerve, name the muscle, name the bone that snapped. Three-hit combo. Mortal Kombat for nerds.", "muscles", "deltoid");
  mcq("muscles-4-01", "In smooth muscle, a rise in cytosolic Ca2+ triggers contraction mainly by binding:", new String[] { "Troponin C, which shifts tropomyosin", "Myosin light-chain phosphatase, activating it", "RyR1, which opens to the extracellular fluid", "Calmodulin, which activates myosin light-chain kinase" }, 3, "Smooth muscle lacks troponin. Ca2+-calmodulin activates MLCK, which phosphorylates the regulatory myosin light chain so cross-bridges cycle. Myosin light-chain phosphatase dephosphorylates it to relax the muscle.", "Calmodulin, not troponin. Write it on your hand. Smooth muscle plays by different rules. Like me.");
  mcq("muscles-4-02", "Nitric oxide relaxes vascular smooth muscle mainly by:", new String[] { "Raising cGMP, which activates myosin light-chain phosphatase", "Raising IP3, which releases SR Ca2+", "Activating MLCK via calmodulin", "Blocking nicotinic ACh receptors" }, 0, "NO diffuses into smooth muscle and activates soluble guanylyl cyclase. cGMP activates protein kinase G, which activates myosin light-chain phosphatase and lowers Ca2+, so myosin is dephosphorylated and the vessel dilates. IP3 and MLCK promote contraction.", "NO -> cGMP -> relax. Same pathway nitroglycerin uses. Explosive AND a vasodilator. Love it.");
  mcq("muscles-4-03", "During anesthesia with sevoflurane and succinylcholine, a patient develops rigidity, rising end-tidal CO2 and fever. Ca2+ floods out through:", new String[] { "Nicotinic ACh receptors of the motor end plate", "IP3 receptors of smooth muscle SR", "Ryanodine receptor (RyR1) of the sarcoplasmic reticulum", "Presynaptic P/Q-type Ca2+ channels" }, 2, "Malignant hyperthermia is usually an autosomal dominant RYR1 mutation. Triggers open the abnormal RyR1, flooding the cytosol with Ca2+: sustained contraction, hypermetabolism (CO2, heat), rhabdomyolysis and hyperkalemia. Dantrolene blocks RyR1 Ca2+ release.", "Hot, stiff, hypercarbic. RyR1's leaking calcium like a cheap *burp* fusion reactor. Dantrolene, stat.");
  mcq("muscles-4-04", "Removing extracellular Ca2+ quickly stops cardiac contraction, but skeletal muscle keeps contracting. Why?", new String[] { "Skeletal muscle uses calmodulin instead of troponin", "Skeletal DHPR opens RyR1 mechanically, without Ca2+ influx", "Cardiac muscle has no sarcoplasmic reticulum", "Skeletal muscle stores contraction Ca2+ in mitochondria" }, 1, "In skeletal muscle, a voltage-driven shape change of DHPR physically opens RyR1. Cardiac muscle needs Ca2+ influx through L-type channels to trigger RyR2 (Ca2+-induced Ca2+ release). Both use troponin, and cardiac muscle does have SR.", "Skeletal muscle's hard-wired. The heart needs a calcium spark. That's why Ca2+ channel blockers hit the heart, not your biceps.");
  mcq("muscles-4-05", "A 62-year-old smoker has proximal weakness that briefly improves with repeated effort, dry mouth and reduced reflexes. Antibodies most likely target:", new String[] { "Presynaptic P/Q-type voltage-gated Ca2+ channels", "Postsynaptic nicotinic ACh receptors", "Acetylcholinesterase", "Muscle-specific kinase (MuSK)" }, 0, "Lambert-Eaton syndrome: antibodies against presynaptic P/Q-type Ca2+ channels reduce ACh release. Repeated activation builds up presynaptic Ca2+, so strength improves briefly. Autonomic signs (dry mouth) are common; it is often paraneoplastic with small cell lung cancer.", "Smoker, gets stronger with effort, dry mouth. Lambert-Eaton. Now go find the small cell cancer, genius.");
  mcq("muscles-4-06", "Succinylcholine produces paralysis by:", new String[] { "Competitively blocking ACh receptors without depolarizing", "Blocking ACh release from the nerve terminal", "Blocking Ca2+ release through RyR1", "Persistently depolarizing the end plate, inactivating Na+ channels" }, 3, "Succinylcholine is a nicotinic agonist that acetylcholinesterase can't break down. The end plate stays depolarized: brief fasciculations, then flaccid paralysis as nearby Na+ channels stay inactivated. Rocuronium competes without depolarizing; botulinum toxin blocks ACh release.", "Succinylcholine floors the gas till the engine floods. Twitch, twitch, *burp* nothing. Neat trick.");
  mcq("muscles-4-07", "After a surgical neck fracture of the humerus, a patient cannot abduct the arm from about 15 to 90 degrees. Which nerve and muscle are affected?", new String[] { "Suprascapular nerve; supraspinatus", "Radial nerve; triceps brachii", "Axillary nerve; deltoid", "Musculocutaneous nerve; biceps brachii" }, 2, "The axillary nerve wraps around the surgical neck with the posterior circumflex humeral artery and supplies the deltoid and teres minor plus skin over the lateral shoulder. The supraspinatus (suprascapular nerve) starts the first ~15 degrees of abduction.", "Surgical neck, axillary nerve, flat deltoid. Can't raise your hand. Not that you'd know the answer anyway.");
  mcq("muscles-4-08", "During a lymph node biopsy in the posterior triangle of the neck, the accessory nerve (CN XI) is cut. The most likely deficit is:", new String[] { "Weak face-turning to the opposite side only (SCM)", "Drooping shoulder and weak shrug (trapezius)", "Winged scapula from serratus anterior palsy", "Loss of elbow flexion (biceps brachii)" }, 1, "In the posterior triangle, CN XI has already supplied the sternocleidomastoid and is heading to the trapezius, so injury there usually spares the SCM but weakens the trapezius: the shoulder droops and shrugging weakens. Serratus anterior is the long thoracic nerve.", "One 'tiny' biopsy nick and the shoulder sags forever. Surgeons. *burp* Amateurs.");
  label("muscles-4-09", "muscles", "forearm_flexors", "Click the muscle group arising from the medial epicondyle, mostly supplied by the median nerve.", "The superficial forearm flexors share a common origin on the medial epicondyle of the humerus; the group flexes the wrist and fingers. Most are median nerve; flexor carpi ulnaris and half of FDP are ulnar. Overuse causes golfer's elbow (medial epicondylitis).", "Golfer's elbow lives here. A rich-guy injury. You'll never get it, don't worry.");
  label("muscles-4-10", "muscles", "biceps_brachii", "Click the muscle supplied by the musculocutaneous nerve that is the strongest forearm supinator.", "The biceps brachii (musculocutaneous nerve, C5-C6) flexes the elbow and is the most powerful supinator, especially with the elbow bent. Its tendon inserts on the radial tuberosity; the biceps reflex tests C5-C6.", "Biceps: flexor AND the strongest supinator. It's how you turn a screwdriver. Or open my *burp* flask.");
  label("muscles-4-11", "muscles", "tibialis_anterior", "Click the muscle whose paralysis causes foot drop after a fibular neck fracture.", "The tibialis anterior is the main dorsiflexor of the foot, supplied by the deep fibular nerve (a branch of the common fibular nerve, which wraps around the fibular neck). Its paralysis causes foot drop and a high-stepping gait.", "Fibular neck snaps, nerve dies, foot flops. Slap, slap, slap down the hallway. Very dignified.");
  label("muscles-4-12", "muscles", "adductors", "Click the muscle group supplied mainly by the obturator nerve.", "The obturator nerve (L2-L4) leaves the pelvis through the obturator canal to supply the medial-thigh adductors; injury weakens hip adduction. (The hamstring part of adductor magnus is supplied by the tibial part of the sciatic nerve.)", "Obturator nerve, adductors, medial thigh. Lose it and your legs splay like a newborn giraffe.");
}

void content_nervous() {
  topic("nervous", "NERVOUS SYSTEM", "neuron", "brain");
  level(1);
  lesson("nervous-1-L1", "Your body's wiring", "The nervous system is your body's fast messaging network. The brain and spinal cord form the central nervous system (CNS), the boss. Nerves branching out to the rest of the body form the peripheral nervous system (PNS). It senses what is happening, decides what to do, and tells muscles and glands to act.", "Brain and spinal cord are HQ, nerves are the cables. Yours is mostly *burp* buffering, but the hardware's standard.", "brain", "spinal_cord");
  lesson("nervous-1-L2", "Meet the neuron", "Neurons are nerve cells. Dendrites are branches that receive signals. The cell body (soma) holds the nucleus. One long axon carries the electrical signal away from the cell body to the axon terminals. There the signal crosses a synapse to the next cell using chemical messengers called neurotransmitters.", "Dendrites listen, axon talks. Like me at parties, except the axon has something worth saying.", "neuron", "axon");
  lesson("nervous-1-L3", "The big brain parts", "The cerebrum is the largest part, split into left and right hemispheres, each with 4 main lobes: frontal (planning, movement, personality), parietal (touch), temporal (hearing, memory) and occipital (vision). The cerebellum at the back handles balance and coordination. The brainstem regulates breathing and heart rate.", "Frontal lobe: decisions. Yours clearly called in sick. Cerebellum: balance. Mine's pickled, hence the wobble.", "brain", "frontal_lobe");
  lesson("nervous-1-L4", "Spinal cord and reflexes", "The spinal cord runs inside the backbone and carries messages between brain and body. Sensory nerves bring information in; motor nerves send commands out to muscles. Touch a hot stove and a spinal reflex pulls your hand back before your brain even feels the pain. The skull and vertebrae protect it all.", "Reflexes skip the brain entirely. Explains how you've survived this long, genius.", "brain", "spinal_cord");
  mcq("nervous-1-01", "Which two organs make up the central nervous system (CNS)?", new String[] { "Brain and peripheral nerves", "Brain and spinal cord", "Spinal cord and heart", "Nerves and muscles" }, 1, "The CNS is the brain plus the spinal cord. The nerves that branch out to the rest of the body form the peripheral nervous system (PNS), not the CNS.", "Brain plus spinal cord. Two parts. TWO. Even a Meeseeks could hold that in memory before poofing.");
  mcq("nervous-1-02", "What is the main signaling cell of the nervous system called?", new String[] { "Nephron", "Erythrocyte", "Neuron", "Osteocyte" }, 2, "Neurons carry electrical and chemical signals. A nephron is the kidney's filtering unit, an erythrocyte is a red blood cell and an osteocyte is a bone cell.", "Neuron. Nephron is kidney. Two letters apart, a whole *burp* universe of difference, Morty-brain.");
  mcq("nervous-1-03", "Which part of a neuron carries the signal AWAY from the cell body?", new String[] { "Axon", "Dendrite", "Nucleus", "Ribosome" }, 0, "The axon conducts the signal away from the cell body toward the axon terminals. Dendrites do the opposite: they bring incoming signals toward the cell body.", "Axon: away. Both start with A. I'm literally spoon-feeding you mnemonics here.");
  mcq("nervous-1-04", "Which part of the brain mainly coordinates balance and smooth movement?", new String[] { "Occipital lobe", "Temporal lobe", "Spinal cord", "Cerebellum" }, 3, "The cerebellum, tucked at the back under the cerebrum, coordinates balance, posture and smooth movement. The occipital lobe handles vision and the temporal lobe hearing and memory.", "Cerebellum. Why do drunks wobble? Booze messes with it. I'm conducting ongoing field research.");
  mcq("nervous-1-05", "Which lobe of the brain mainly processes vision?", new String[] { "Frontal lobe", "Temporal lobe", "Occipital lobe", "Parietal lobe" }, 2, "The primary visual cortex sits in the occipital lobe at the back of the head. Your eyes are at the front, but the signals travel all the way to the back.", "Eyes in front, vision in the back. Your body's wiring is almost as dumb as your questions. Occipital.");
  mcq("nervous-1-06", "Neurons pass signals across a synapse using chemicals called:", new String[] { "Neurotransmitters", "Hormones", "Antibodies", "Enzymes" }, 0, "Neurotransmitters (like acetylcholine or dopamine) are released into the tiny synaptic gap and act on the next cell within milliseconds. Hormones are chemical messengers too, but they travel in the blood.", "Neurotransmitters. Hormones go by blood, the slow mail. Synapses use the express portal.");
  mcq("nervous-1-07", "Which part of the brain controls automatic functions like breathing and heart rate?", new String[] { "Cerebellum", "Frontal lobe", "Occipital lobe", "Brainstem" }, 3, "The brainstem (midbrain, pons and medulla) connects the brain to the spinal cord and runs vital automatic functions such as breathing, heart rate and blood pressure.", "Brainstem. Keeps you breathing without your help. Thank god, because your help is *burp* useless.");
  mcq("nervous-1-08", "You touch a hot stove and pull your hand away before you feel pain. Why?", new String[] { "The skin contracts the arm muscles directly, without nerves", "A spinal cord reflex acts before the brain registers pain", "The occipital lobe sees the heat and reacts first", "The arm muscles sense the heat and decide to move" }, 1, "In a reflex arc the sensory nerve signals the spinal cord, which directly activates motor neurons to the muscle. The message to the brain, where pain is actually felt, arrives a moment later.", "Your spinal cord yanked your hand while your brain was still loading. Let the cord do more of your thinking.");
  label("nervous-1-09", "neuron", "dendrite", "Click the dendrites, the branches that receive incoming signals.", "Dendrites are the branching extensions around the cell body. They collect signals from other neurons and pass them toward the cell body.", "Dendrites: the antennae. Like Wi-Fi, except it actually picks up a signal. Unlike you.");
  label("nervous-1-10", "brain", "cerebellum", "Click the cerebellum.", "The cerebellum ('little brain') sits at the back, below the occipital lobe and behind the brainstem. It coordinates balance and smooth movement.", "Back and bottom, the wrinkly little cauliflower. Your balance computer. Mine's on backup power.");
  label("nervous-1-11", "brain", "frontal_lobe", "Click the frontal lobe.", "The frontal lobe is the front part of each cerebral hemisphere, in front of the central sulcus. It handles planning, decisions, personality and voluntary movement.", "Front of the brain. Frontal. Scientists named it slowly, for people like you, genius.");
  level(2);
  lesson("nervous-2-L1", "Divisions of the system", "The PNS has 12 pairs of cranial nerves and 31 pairs of spinal nerves. The somatic system controls voluntary skeletal muscle. The autonomic system runs smooth muscle, heart muscle and glands: sympathetic = fight or flight (faster heart, dilated pupils), parasympathetic = rest and digest (slower heart, digestion).", "Sympathetic: flee the Galactic Federation. Parasympathetic: digest your Szechuan sauce afterwards.", "", "");
  lesson("nervous-2-L2", "The action potential", "At rest the inside of a neuron is about -70 mV, kept by K+ leak channels and the Na+/K+ pump (3 Na+ out, 2 K+ in per ATP). At threshold (about -55 mV) voltage-gated Na+ channels open, Na+ rushes in and the inside goes positive (about +30 mV). Then K+ flows out to repolarize. It's all-or-none.", "All-or-none, like my commitment to science. Hit threshold or *burp* go home.", "neuron", "axon");
  lesson("nervous-2-L3", "Myelin and the synapse", "Myelin insulates axons: Schwann cells make it in the PNS, oligodendrocytes in the CNS. The impulse jumps between gaps called nodes of Ranvier (saltatory conduction), which is much faster. At the axon terminal the impulse opens Ca2+ channels; Ca2+ entry makes vesicles release neurotransmitter into the synapse.", "Saltatory conduction: the signal portal-hops node to node. I invented that. Probably. In some universe.", "neuron", "myelin_sheath");
  lesson("nervous-2-L4", "Brain regions, upgraded", "The brainstem has 3 parts: midbrain, pons and medulla. The medulla, lowest and continuous with the spinal cord, holds centers for heart rate, blood pressure and breathing. Cortex is outer gray matter (cell bodies); white matter is myelinated axons. Each cerebral hemisphere mainly controls the OPPOSITE side of the body.", "Left brain runs the right hand. Crossed wiring. Like your priorities, except it works.", "brain", "medulla");
  mcq("nervous-2-01", "What is the typical resting membrane potential of a neuron?", new String[] { "About +30 mV", "About 0 mV", "About -70 mV", "About -10 mV" }, 2, "At rest the inside of a neuron is about -70 mV relative to the outside. +30 mV is roughly the peak of an action potential, when the inside briefly turns positive.", "Minus seventy. Negative, like my outlook on your career. +30 is the spike peak, genius.");
  mcq("nervous-2-02", "During the rising (depolarization) phase of an action potential, which ion rushes INTO the neuron?", new String[] { "Na+", "K+", "Cl-", "Mg2+" }, 0, "Voltage-gated Na+ channels open and Na+ flows in down its concentration and electrical gradients, making the inside positive. K+ flowing OUT is what repolarizes the cell afterwards.", "Sodium in, potassium out. Salt goes into the cell like it goes on my margarita glass.");
  mcq("nervous-2-03", "Compared with a stimulus just above threshold, a sustained stimulus well above threshold makes a neuron fire action potentials that are:", new String[] { "Twice as large in amplitude", "Graded in size, like a dimmer switch", "The same size, but more frequent", "Slower to travel down the axon" }, 2, "Action potentials are all-or-none: once threshold (about -55 mV) is reached, every spike has the same size and shape. A stronger stimulus is coded by MORE spikes per second (frequency coding), not bigger ones. Graded potentials are the ones that vary in size.", "All-or-none, genius. Neurons don't shout louder, they just repeat themselves faster. Like me, *burp* on a bender.");
  mcq("nervous-2-04", "Which cells make myelin in the central nervous system?", new String[] { "Schwann cells", "Oligodendrocytes", "Astrocytes", "Microglia" }, 1, "Oligodendrocytes myelinate CNS axons, and one can wrap segments of many axons. Schwann cells are the PNS version, each myelinating one segment of one axon. Astrocytes support neurons; microglia are immune cells.", "Oligodendrocytes in the CNS, Schwann cells outside. Mix them up and I portal you somewhere with no textbooks.");
  mcq("nervous-2-05", "What is saltatory conduction?", new String[] { "The impulse jumping from one node of Ranvier to the next", "Neurotransmitter diffusing across the synapse", "The impulse traveling backward to the dendrites", "Salt being pumped into the axon terminal" }, 0, "In myelinated axons the action potential is regenerated only at the nodes of Ranvier, so it effectively jumps from node to node. That makes conduction much faster than in unmyelinated axons.", "Saltare is Latin for 'to jump'. Nothing to do with salt. Put down the pretzels, Morty-brain.");
  mcq("nervous-2-06", "Which effect is caused by the sympathetic (fight or flight) system?", new String[] { "Slower heart rate and constricted pupils", "More saliva and faster digestion", "Contraction of the bladder to empty it", "Faster heart rate and dilated pupils" }, 3, "Sympathetic activity raises heart rate, dilates pupils and airways, and shifts blood to muscles. Slowing the heart, constricting pupils, digestion and bladder emptying are parasympathetic (rest and digest) effects.", "Fight or flight: heart pounding, pupils huge. Basically my face every time Unity calls.");
  mcq("nervous-2-07", "How many pairs of spinal nerves does a human have?", new String[] { "12", "31", "24", "33" }, 1, "There are 31 pairs: 8 cervical, 12 thoracic, 5 lumbar, 5 sacral and 1 coccygeal. 12 is the number of cranial nerve pairs; 33 is roughly the number of vertebrae.", "Thirty-one. Twelve is the cranial nerves. Write it down, your memory's a *burp* sieve.");
  mcq("nervous-2-08", "What directly triggers release of neurotransmitter from the axon terminal?", new String[] { "K+ flowing into the terminal", "Na+ being pumped out of the terminal", "Ca2+ flowing into the terminal", "Cl- flowing out of the terminal" }, 2, "The arriving action potential opens voltage-gated Ca2+ channels. Ca2+ entry triggers synaptic vesicles to fuse with the membrane and dump neurotransmitter into the cleft.", "Calcium is the trigger. No calcium, no release. Like me without booze: zero output.");
  label("nervous-2-09", "neuron", "myelin_sheath", "Click the myelin sheath.", "Myelin is the fatty insulating wrap around the axon, made by Schwann cells (PNS) or oligodendrocytes (CNS). It speeds conduction by letting the impulse jump between nodes.", "The fatty insulation on the cable. Lose it and signals crawl. Like your reading speed.");
  label("nervous-2-10", "brain", "occipital_lobe", "Click the lobe that contains the primary visual cortex.", "The occipital lobe at the back of the cerebrum receives visual input relayed from the eyes through the thalamus. Damage here can blind part of the visual field even with healthy eyes.", "Vision lives in the back of your head. Eyes in front, screen in back. Nature's a lousy engineer.");
  label("nervous-2-11", "brain", "medulla", "Click the lowest part of the brainstem, continuous with the spinal cord.", "The medulla oblongata sits below the pons and merges into the spinal cord. It holds vital centers for breathing, heart rate and blood pressure, so damage here is often fatal.", "Medulla. Break it and the lights go out. Permanently. Don't, uh, test that.");
  level(3);
  lesson("nervous-3-L1", "Channels and refractory periods", "At rest the membrane is most permeable to K+, so the resting potential sits near K+'s equilibrium potential (about -90 mV). Spikes start at the axon hillock/initial segment, rich in Na+ channels. Na+ channel inactivation causes the absolute refractory period; lingering K+ efflux causes the relative one.", "Na+ channels need a nap after firing. Absolute refractory period. You have one too: it's called your life.", "neuron", "axon_hillock");
  lesson("nervous-3-L2", "Upper vs lower motor neurons", "Upper motor neurons (UMN) in motor cortex (notably the precentral gyrus) form the corticospinal tract; most cross at the pyramidal decussation (lower medulla) to reach anterior horn lower motor neurons (LMN). UMN lesion: spastic weakness, hyperreflexia, Babinski sign. LMN lesion: flaccid weakness, atrophy, fasciculations.", "Upper motor neuron down: stiff and jumpy. Lower: floppy and twitchy. Like me before and after *burp* coffee.", "brain", "precentral_gyrus");
  lesson("nervous-3-L3", "Sensory pathways", "The postcentral gyrus is primary somatosensory cortex, mapped as a homunculus with huge face and hands. Fine touch, vibration and proprioception ascend the dorsal columns on the same side and cross in the medulla. Pain and temperature fibers cross within 1-2 segments and ascend in the spinothalamic tract.", "Dorsal columns cross high, pain crosses low. Two tracts, two rules. Your brain has room for two, right?", "brain", "postcentral_gyrus");
  lesson("nervous-3-L4", "Transmitters and receptors", "Glutamate is the brain's main excitatory transmitter; GABA the main inhibitory one (glycine in the spinal cord). Acetylcholine acts on nicotinic receptors at the neuromuscular junction and autonomic ganglia, and on muscarinic receptors at parasympathetic targets. Most sympathetic postganglionic fibers release norepinephrine.", "Glutamate floors the gas, GABA hits the brakes. Your brain's mostly brakes, apparently.", "neuron", "synapse");
  mcq("nervous-3-01", "The absolute refractory period of an action potential is mainly due to:", new String[] { "Inactivation of voltage-gated Na+ channels", "Voltage-gated K+ channels still being open", "Failure of the Na+/K+ pump", "Depletion of neurotransmitter vesicles" }, 0, "After opening, Na+ channels enter an inactivated state and cannot reopen until the membrane repolarizes, so no new spike is possible. Still-open K+ channels (hyperpolarization) explain the RELATIVE refractory period.", "Inactivated Na+ channels. K+ is the relative period. Absolute versus relative, like my genius versus yours.");
  mcq("nervous-3-02", "Why is the neuronal resting membrane potential close to the K+ equilibrium potential?", new String[] { "The Na+/K+ pump directly generates most of the voltage", "At rest the membrane is far more permeable to Na+ than to K+", "K+ is actively pumped out of the cell, leaving it negative", "At rest the membrane is far more permeable to K+ than to other ions" }, 3, "K+ leak channels make the resting membrane most permeable to K+, pulling the potential toward E(K+), about -90 mV; a small Na+ leak pulls it up to about -70 mV. The pump's direct electrogenic share is only a few mV.", "Permeability rules, genius. The pump just maintains gradients. It's the janitor, not the CEO.");
  mcq("nervous-3-03", "Right-sided spastic weakness, hyperreflexia and an upgoing plantar reflex (Babinski sign). Where is the lesion most likely?", new String[] { "Right spinal cord anterior horn", "Left internal capsule", "Right sciatic nerve", "Neuromuscular junction" }, 1, "Spasticity, hyperreflexia and Babinski are upper motor neuron signs. Corticospinal fibers in the left internal capsule have not crossed yet, so a lesion there hits the right body. Anterior horn and nerve lesions give LMN signs.", "UMN signs, opposite side, above the crossing. Left capsule, right body. Wiring 101, dummy.");
  mcq("nervous-3-04", "Where do most corticospinal tract fibers cross to the opposite side?", new String[] { "Internal capsule", "Cerebral peduncles of the midbrain", "Pyramidal decussation in the lower medulla", "Anterior white commissure at each spinal level" }, 2, "About 85-90% of corticospinal fibers cross in the pyramidal decussation at the medulla-spinal cord junction, then descend as the lateral corticospinal tract. The internal capsule and peduncles carry them before they cross.", "Most cross at the pyramids. Ancient Egypt reference, free of charge. You're welcome.");
  mcq("nervous-3-05", "Pain and temperature from the LEFT foot ascend the spinal cord mainly in which tract and on which side?", new String[] { "Spinothalamic tract, left side", "Dorsal columns, left side", "Dorsal columns, right side", "Spinothalamic tract, right side" }, 3, "Pain and temperature fibers synapse in the dorsal horn, and the second-order axons cross within about 1-2 segments to ascend in the contralateral spinothalamic tract. Dorsal columns carry touch and vibration on the same side.", "Pain crosses early. Left foot, right cord. Like you, it switches sides at the first sign of *burp* trouble.");
  mcq("nervous-3-06", "Autoimmune destruction of CNS myelin (made by oligodendrocytes) is the hallmark of which disease?", new String[] { "Guillain-Barre syndrome", "Multiple sclerosis", "Amyotrophic lateral sclerosis", "Myasthenia gravis" }, 1, "Multiple sclerosis is immune-mediated demyelination of the CNS. Guillain-Barre targets PERIPHERAL myelin (Schwann cells), ALS kills motor neurons, and myasthenia gravis attacks ACh receptors at the neuromuscular junction.", "MS: CNS myelin. Guillain-Barre: PNS myelin. Same crime, different jurisdiction.");
  mcq("nervous-3-07", "Most sympathetic postganglionic neurons release which neurotransmitter onto their targets?", new String[] { "Acetylcholine", "Dopamine", "Norepinephrine", "Epinephrine" }, 2, "Sympathetic postganglionic fibers mostly release norepinephrine onto adrenergic receptors (exception: sweat glands get ACh). The adrenal medulla, not the neurons, secretes mostly epinephrine into the blood.", "Norepinephrine. Epinephrine is the adrenal medulla's job. Different employees, genius.");
  mcq("nervous-3-08", "What is the main inhibitory neurotransmitter in the brain?", new String[] { "GABA", "Glutamate", "Glycine", "Acetylcholine" }, 0, "GABA is the main inhibitory transmitter in the brain; glycine plays that role mainly in the spinal cord and brainstem. Glutamate is the main excitatory transmitter.", "GABA. Benzos and booze boost it. Which explains *burp* a lot about me, actually.");
  label("nervous-3-09", "neuron", "axon_hillock", "Click the cone-shaped region where the axon leaves the cell body.", "The axon hillock leads into the initial segment, which is packed with voltage-gated Na+ channels, so this hillock/initial-segment trigger zone is where summed inputs usually reach threshold and the spike starts.", "The trigger zone. Every input gets summed here, then it fires or doesn't. Decisive. Unlike you.");
  label("nervous-3-10", "neuron", "node_of_ranvier", "Click a gap in the myelin where the action potential is regenerated.", "Nodes of Ranvier are short unmyelinated gaps packed with voltage-gated Na+ channels. The spike regenerates at each node and jumps to the next (saltatory conduction).", "The gaps are the point. Signal hops node to node, like me hopping dimensions dodging warrants.");
  label("nervous-3-11", "brain", "precentral_gyrus", "Click the primary motor cortex.", "The primary motor cortex is the precentral gyrus, the ridge just in front of the central sulcus in the frontal lobe. Its upper motor neurons drive voluntary movement of the opposite side of the body.", "Precentral gyrus. In FRONT of the central sulcus. Motor up front, sensory behind. Get it tattooed.");
  label("nervous-3-12", "brain", "postcentral_gyrus", "Click the primary somatosensory cortex.", "The primary somatosensory cortex is the postcentral gyrus, just behind the central sulcus in the parietal lobe. It maps touch, pain, temperature and position from the opposite side of the body.", "Behind the central sulcus. Where you feel things. Like shame, hopefully, if you clicked the wrong gyrus.");
  level(4);
  lesson("nervous-4-L1", "Stroke syndromes", "MCA stroke: contralateral face and arm weakness and numbness (more than leg), plus aphasia if the dominant (usually left) side, neglect if nondominant. ACA: contralateral leg more than arm. PCA: contralateral homonymous hemianopia with macular sparing. Basilar artery occlusion infarcting the ventral pons: locked-in syndrome.", "Know the artery, know the deficit. The brain's a map, and strokes are me spilling *burp* whiskey on it.", "brain", "pons");
  lesson("nervous-4-L2", "Aphasias", "Broca aphasia (dominant inferior frontal gyrus): non-fluent, effortful speech, comprehension largely intact. Wernicke aphasia (posterior superior temporal gyrus): fluent but meaningless speech, poor comprehension, often unaware. Conduction aphasia (arcuate fasciculus): fluent, comprehends, but can't repeat.", "Broca: broken speech. Wernicke: wordy nonsense. Conduction: can't repeat. Kind of like you in lecture.", "brain", "broca_area");
  lesson("nervous-4-L3", "Spinal cord lesions", "Brown-Sequard (hemisection), below the lesion: same-side spastic weakness and loss of vibration/position sense, opposite-side loss of pain and temperature. Syringomyelia: bilateral cape-like pain/temperature loss. B12 deficiency: dorsal columns plus lateral corticospinal tracts. ALS: UMN and LMN signs, no sensory loss.", "Hemisect a cord and the symptoms split sides. Like a breakup: each side keeps different stuff.", "brain", "spinal_cord");
  lesson("nervous-4-L4", "Toxins at the synapse", "Botulinum toxin cleaves SNARE proteins and blocks ACh release: descending flaccid paralysis. Tetanus toxin blocks GABA and glycine release from spinal inhibitory interneurons: spastic paralysis, lockjaw. Lambert-Eaton: antibodies to presynaptic Ca2+ channels. Myasthenia gravis: antibodies to postsynaptic nicotinic ACh receptors.", "Botox floppy, tetanus stiff. Same SNARE trick, different neurons. Nature's a sadistic chemist.", "neuron", "axon_terminal");
  mcq("nervous-4-01", "Sudden right face and arm weakness; she speaks in short, effortful phrases but follows commands. Which artery is most likely occluded?", new String[] { "Left anterior cerebral artery", "Right middle cerebral artery", "Left posterior cerebral artery", "Left middle cerebral artery" }, 3, "Face and arm more than leg points to MCA territory on the lateral cortex; non-fluent speech with intact comprehension is Broca aphasia, so it's the dominant (left) hemisphere. ACA would hit the leg; PCA causes visual field loss.", "Face, arm, Broca: left MCA. The most common stroke on the exam, and you still hesitated?");
  mcq("nervous-4-02", "Sudden weakness and numbness of the right leg, with the face and arm largely spared. Which artery is most likely occluded?", new String[] { "Left middle cerebral artery", "Left anterior cerebral artery", "Right anterior cerebral artery", "Basilar artery" }, 1, "The leg and foot areas of motor and sensory cortex lie on the medial surface of the hemisphere, supplied by the ACA. Right leg means left hemisphere. MCA strokes hit face and arm more than leg.", "Leg area's on the medial surface, ACA turf. Left artery, right leg. Crossed wires, as always, genius.");
  mcq("nervous-4-03", "A patient speaks fluently and understands well but cannot repeat a phrase. Damage to which structure is most likely?", new String[] { "Broca area", "Wernicke area", "Arcuate fasciculus", "Precentral gyrus" }, 2, "Conduction aphasia: the arcuate fasciculus linking Wernicke and Broca areas is damaged, so repetition fails while fluency and comprehension are relatively spared. Broca gives non-fluent speech; Wernicke gives poor comprehension.", "Can talk, can understand, can't repeat. The cable between the two speech areas is cut. Like your attention span.");
  mcq("nervous-4-04", "A stab wound hemisects the LEFT half of the spinal cord at T10. Which deficit is expected below the lesion?", new String[] { "Loss of pain and temperature on the right", "Loss of vibration sense on the right", "Loss of pain and temperature on the left", "Flaccid paralysis of both legs" }, 0, "Brown-Sequard: the spinothalamic tract has already crossed, so pain and temperature are lost on the OPPOSITE (right) side. Dorsal columns and the lateral corticospinal tract are uncrossed here, so vibration and motor loss are on the left.", "Pain switches sides, vibration stays home. Left cut, right numb to pain. Classic Step 1 bait.");
  mcq("nervous-4-05", "An infant fed honey develops constipation, poor feeding and descending flaccid paralysis. What is the toxin's mechanism?", new String[] { "Antibodies blocking postsynaptic ACh receptors", "Cleaving SNARE proteins to block ACh release", "Blocking GABA and glycine release from interneurons", "Blocking voltage-gated Na+ channels in axons" }, 1, "Infant botulism: Clostridium botulinum toxin cleaves SNARE proteins in cholinergic terminals, so ACh is not released and muscles go flaccid. Blocking GABA/glycine release is tetanus (spastic); blocking Na+ channels is tetrodotoxin.", "Honey spores, baby gut, no ACh release: floppy baby. The toxin snips SNAREs like I snip *burp* red tape.");
  mcq("nervous-4-06", "A farmer with a dirty puncture wound and no tetanus shots develops lockjaw and painful spasms. The toxin blocks transmitter release mainly from:", new String[] { "Alpha motor neurons at the neuromuscular junction", "Dorsal root ganglion sensory neurons", "Postganglionic parasympathetic neurons", "Inhibitory spinal interneurons, such as Renshaw cells" }, 3, "Tetanus toxin enters motor nerve terminals, travels retrogradely to the spinal cord and cleaves synaptobrevin in inhibitory interneurons, blocking GABA and glycine release. Motor neurons fire unchecked: lockjaw, spasms. Botulinum toxin acts at the neuromuscular junction instead.", "Tetanus cuts the brake lines, not the engine. Motor neurons floor it nonstop. Get your *burp* booster, genius.");
  mcq("nervous-4-07", "Serum K+ acutely rises to 7 mEq/L. What happens to a neuron's resting membrane potential?", new String[] { "It depolarizes (becomes less negative)", "It hyperpolarizes (becomes more negative)", "It stays unchanged because the pump compensates", "It reverses to about +30 mV" }, 0, "The resting potential is set mainly by the K+ gradient. Raising extracellular K+ shrinks that gradient, so E(K+) and the resting potential become less negative. Sustained depolarization then inactivates Na+ channels and reduces excitability.", "Smaller K+ gradient, less negative potential. That's why high K+ wrecks hearts too. Nernst, baby. Look it up.");
  mcq("nervous-4-08", "A strict vegan has macrocytic anemia, lost vibration and position sense in the legs, and spastic weakness. Which cord regions are damaged?", new String[] { "Anterior horn cells and lateral corticospinal tracts", "Dorsal columns only", "Spinothalamic fibers crossing in the anterior white commissure", "Dorsal columns and lateral corticospinal tracts" }, 3, "B12 deficiency causes subacute combined degeneration: demyelination of dorsal columns (vibration, proprioception), lateral corticospinal tracts (spasticity) and spinocerebellar tracts. Anterior horns + corticospinal = ALS (no sensory loss); dorsal columns alone = tabes dorsalis.", "B12 deficiency: dorsal columns plus corticospinal. Subacute combined degeneration. Cobalamin matters, *burp* genius.");
  label("nervous-4-09", "brain", "broca_area", "Click the area damaged in a patient with effortful, non-fluent speech but good comprehension.", "Broca area is in the inferior frontal gyrus of the dominant (usually left) hemisphere, just above the lateral sulcus. Damage causes expressive (Broca) aphasia: halting speech, intact comprehension, impaired repetition.", "Broken speech, Broca. Inferior frontal gyrus, left side. 'Broca: broken.' Even you can manage that.");
  label("nervous-4-10", "brain", "wernicke_area", "Click the area damaged in a patient with fluent 'word salad' and poor comprehension.", "Wernicke area lies in the posterior superior temporal gyrus of the dominant hemisphere. Damage gives receptive (Wernicke) aphasia: fluent but meaningless speech, poor comprehension and repetition, often without awareness.", "Word salad with zero croutons of meaning. Wernicke. Sounds like my *burp* grant proposals.");
  label("nervous-4-11", "brain", "pons", "Click the structure whose ventral damage causes locked-in syndrome.", "Basilar artery occlusion can infarct the ventral pons, destroying corticospinal and corticobulbar tracts: quadriplegia and loss of speech, with consciousness, blinking and vertical eye movements preserved.", "Ventral pons gone: awake, aware, can only blink. Worst sitcom premise ever. Pons.");
  label("nervous-4-12", "brain", "central_sulcus", "Click the groove that separates the primary motor cortex from the primary somatosensory cortex.", "The central sulcus divides the frontal from the parietal lobe; the precentral (motor) gyrus lies in front of it and the postcentral (sensory) gyrus behind. The lateral sulcus instead separates off the temporal lobe.", "Central sulcus. The border wall between move and feel. Unlike Earth borders, it's actually useful.");
}

void content_heart() {
  topic("heart", "HEART & BLOOD", "heart");
  level(1);
  lesson("heart-1-L1", "Meet the pump", "The heart is a muscular pump about the size of a fist. It sits in the middle of the chest between the lungs, behind the sternum, tilted to the left. At rest it beats about 60-100 times a minute, pushing blood through the blood vessels to deliver O2 and nutrients and carry away CO2 and wastes.", "A meat pump the size of your fist. Beats about 100,000 times a day and never takes a day off. Unlike Jerry.", "heart", "left_ventricle");
  lesson("heart-1-L2", "Four chambers, two pumps", "The heart has 4 chambers. The two upper ones, the atria, RECEIVE blood. The two lower ones, the ventricles, PUMP it out. The right side sends O2-poor blood to the lungs; the left side sends O2-rich blood to the whole body, so the left ventricle has the thickest, strongest wall.", "Two pumps glued together, genius. Right side does lungs, left side does everything else. Even you can count to four.", "heart", "right_atrium");
  lesson("heart-1-L3", "Arteries, veins, capillaries", "Arteries carry blood AWAY from the heart; veins carry it back TOWARD the heart. Capillaries are microscopic vessels with walls one cell thick, where O2 and nutrients leave the blood and wastes enter it. The aorta is the biggest artery. Arteries usually carry O2-rich blood; the pulmonary arteries are the main exception.", "Arteries: Away. Both start with A. That's the whole trick, Morty-brain. I *burp* just saved you a semester.", "heart", "aorta");
  lesson("heart-1-L4", "What blood is made of", "An adult has about 5 liters of blood. About 55% is plasma: water carrying proteins, salts, nutrients and hormones. The rest is mostly cells: red blood cells carry O2 using hemoglobin, white blood cells fight infection, and platelets (tiny cell fragments) plug leaks and help blood clot.", "Five liters of red soup. Red cells deliver, white cells fight, platelets patch holes. Better run than the Citadel.", "", "");
  mcq("heart-1-01", "How many chambers does the human heart have?", new String[] { "Two", "Three", "Four", "Six" }, 2, "Four: two atria on top that receive blood and two ventricles below that pump it out. A muscular wall, the septum, keeps the right side's O2-poor blood separate from the left side's O2-rich blood.", "Four. Not two, not 'a lot'. Four. I've met Meeseeks with better retention than you.");
  mcq("heart-1-02", "Which blood vessels carry blood AWAY from the heart?", new String[] { "Arteries", "Veins", "Capillaries", "Lymph vessels" }, 0, "Arteries carry blood away from the heart under high pressure, so they have thick, muscular, elastic walls. Veins bring blood back and have thinner walls and valves. It's about direction, not oxygen: the pulmonary arteries carry O2-poor blood.", "A for Arteries, A for Away. If that's too hard, interdimensional cable is always hiring.");
  mcq("heart-1-03", "Where do O2 and nutrients actually pass from the blood into the tissues?", new String[] { "Arteries", "Veins", "Aorta", "Capillaries" }, 3, "Capillary walls are only one cell thick, so O2, nutrients and wastes can diffuse across them. Arteries, veins and the aorta have walls far too thick for exchange; they are the delivery and return pipes.", "Capillaries. The tiny pipes where the actual work happens. Like grad students.");
  mcq("heart-1-04", "Which blood cells carry oxygen?", new String[] { "Red blood cells", "White blood cells", "Platelets", "Plasma cells" }, 0, "Red blood cells are packed with hemoglobin, an iron-containing protein that binds O2. White blood cells defend against infection, platelets help clotting, and plasma cells are immune cells that make antibodies.", "Red cells. Little red frisbees full of hemoglobin. The color was a *burp* hint, genius.");
  mcq("heart-1-05", "What is the main job of platelets?", new String[] { "Carrying CO2", "Making antibodies", "Helping blood clot", "Fighting bacteria" }, 2, "Platelets are small cell fragments that stick to damaged vessel walls and to each other, forming a plug, and help the clotting process that seals the leak. Fighting infection is the job of white blood cells.", "Platelets are the duct tape of your blood. Cheap, tiny, and holding your whole sorry life together.");
  mcq("heart-1-06", "Where does the RIGHT ventricle pump blood?", new String[] { "To the whole body", "To the lungs", "To the brain only", "Into the left ventricle" }, 1, "The right ventricle pumps O2-poor blood through the pulmonary trunk to the lungs to pick up O2. The LEFT ventricle pumps blood to the rest of the body through the aorta. In a normal heart the two sides never mix.", "Right side, lungs. Left side, everything else. It's a two-pump system, not a riddle.");
  mcq("heart-1-07", "Which heart chamber has the thickest muscular wall?", new String[] { "Right atrium", "Left atrium", "Right ventricle", "Left ventricle" }, 3, "The left ventricle must push blood through the entire body at high pressure, so its wall is roughly three times thicker than the right ventricle's, which only pumps to the nearby, low-pressure lungs. The atria have the thinnest walls.", "The left ventricle. It does the heavy lifting, so it hits the gym. The atria are just the warm-up act.");
  mcq("heart-1-08", "A normal resting heart rate for an adult is about:", new String[] { "20-40 beats per minute", "60-100 beats per minute", "120-160 beats per minute", "180-220 beats per minute" }, 1, "Most adults rest at about 60-100 beats per minute. Below 60 is called bradycardia and above 100 tachycardia, although very fit athletes often rest in the 40s or 50s quite normally.", "60 to 100. If yours is 180 right now, it's because I'm in the room. Understandable.");
  label("heart-1-09", "heart", "left_ventricle", "Click the left ventricle.", "The left ventricle is the big, thick-walled lower chamber that forms the heart's tip (apex). It pumps O2-rich blood into the aorta and out to the whole body. On a front view it is on the viewer's RIGHT, because the patient's left is your right.", "The left ventricle. The heart's muscle car. Patient's left, your right: you're facing them, not a mirror.");
  label("heart-1-10", "heart", "right_atrium", "Click the chamber that receives O2-poor blood returning from the body.", "The right atrium is the upper right chamber. The superior and inferior venae cavae empty used, O2-poor blood from the body into it, and it passes the blood through the tricuspid valve to the right ventricle.", "Right atrium: the heart's lobby. All the tired, used blood checks in here first.");
  label("heart-1-11", "heart", "aorta", "Click the aorta, the body's largest artery.", "The aorta leaves the left ventricle, arches up and over the heart and runs down through the chest and abdomen, branching to deliver O2-rich blood to every organ. It's roughly 2.5-3 cm wide at its root.", "The aorta. Biggest artery you've got. The garden hose of life, *burp* under serious pressure.");
  level(2);
  lesson("heart-2-L1", "The route, step by step", "Body -> venae cavae -> right atrium -> tricuspid valve -> right ventricle -> pulmonary valve -> pulmonary trunk -> lungs (gain O2, lose CO2) -> pulmonary veins -> left atrium -> mitral valve -> left ventricle -> aortic valve -> aorta -> body. Pulmonary arteries carry O2-poor blood; pulmonary veins carry O2-rich blood.", "Memorize the loop. It's a circle, Morty-brain. The shape you've been running in your whole life.", "heart", "pulmonary_veins");
  lesson("heart-2-L2", "Valves and heart sounds", "Four valves keep blood moving one way. The atrioventricular (AV) valves - tricuspid (right) and mitral, or bicuspid (left) - are tethered by chordae tendineae to papillary muscles. The semilunar valves - pulmonary and aortic - guard the exits. S1 'lub' = AV valves closing; S2 'dub' = semilunar valves closing.", "Lub-dub is just doors slamming. Four doors, one direction. Even a Meeseeks could run this.", "heart", "tricuspid_valve");
  lesson("heart-2-L3", "The heart's wiring", "The SA node in the right atrium is the natural pacemaker. Its impulse spreads over both atria, is delayed at the AV node so the ventricles can fill, then runs down the bundle of His, bundle branches and Purkinje fibers. ECG: P wave = atrial depolarization, QRS = ventricular depolarization, T wave = ventricular repolarization.", "Self-wiring meat with a built-in *burp* metronome. Honestly? One of evolution's better hacks.", "heart", "sa_node");
  lesson("heart-2-L4", "Output, red cells, blood types", "Cardiac output = heart rate x stroke volume: about 70/min x 70 mL, roughly 5 L/min at rest. Red cells come from red bone marrow (driven by EPO from the kidneys), have no nucleus and live about 120 days. ABO: plasma has antibodies against the A/B antigens your red cells lack, so type O has anti-A and anti-B; type AB has neither.", "Five liters a minute, every minute, forever. And you get tired walking to the fridge.", "", "");
  mcq("heart-2-01", "Which valve lies between the LEFT atrium and the LEFT ventricle?", new String[] { "Tricuspid valve", "Mitral valve", "Aortic valve", "Pulmonary valve" }, 1, "The mitral (bicuspid) valve has two cusps and sits between the left atrium and left ventricle. The tricuspid is its right-side twin. The aortic and pulmonary valves are semilunar valves at the ventricle exits.", "Mitral. Named after a bishop's hat. Some anatomist had *burp* way too much free time.");
  mcq("heart-2-02", "Which vessels carry O2-rich blood from the lungs to the heart?", new String[] { "Pulmonary arteries", "Venae cavae", "Pulmonary veins", "Coronary arteries" }, 2, "The pulmonary veins (usually four) return freshly oxygenated blood from the lungs to the left atrium. They break the 'veins carry O2-poor blood' habit because vessels are named by direction - toward the heart - not by oxygen content.", "Veins full of oxygen. Rules are for people who don't read the fine print.");
  mcq("heart-2-03", "What is the heart's natural pacemaker?", new String[] { "AV node", "Bundle of His", "Purkinje fibers", "SA node" }, 3, "The sinoatrial (SA) node fires spontaneously the fastest, about 60-100 times a minute, so it sets the pace. If it fails, the AV node can take over, but at a slower intrinsic rate of about 40-60 per minute.", "SA node. The tiny drummer in your right atrium. Fire him and the whole band plays slower.");
  mcq("heart-2-04", "On an ECG, the QRS complex represents:", new String[] { "Atrial depolarization", "Ventricular depolarization", "Ventricular repolarization", "The delay in the AV node" }, 1, "QRS = ventricular depolarization, which triggers ventricular contraction. The P wave is atrial depolarization, the T wave is ventricular repolarization, and the AV-node delay falls within the PR interval. Atrial repolarization is hidden inside the QRS.", "QRS: the big spike. The ventricles yelling 'GO'. You've seen it on every hospital show, genius.");
  mcq("heart-2-05", "The first heart sound (S1, 'lub') is caused by:", new String[] { "Closing of the mitral and tricuspid valves", "Closing of the aortic and pulmonary valves", "Opening of the mitral and tricuspid valves", "Blood hitting the aortic wall" }, 0, "S1 happens when the ventricles start to contract and their rising pressure snaps the AV valves (mitral, tricuspid) shut. S2 'dub' is the aortic and pulmonary valves closing as the ventricles relax. Healthy valves are silent when they open.", "Lub = AV valves slam. Dub = semilunar valves slam. Your heart's a *burp* door-slamming teenager.");
  mcq("heart-2-06", "Heart rate is 70 beats/min and stroke volume is 70 mL. Cardiac output is about:", new String[] { "0.5 L/min", "1 L/min", "4.9 L/min", "49 L/min" }, 2, "Cardiac output = heart rate x stroke volume = 70 x 70 mL = 4,900 mL/min, about 4.9 L/min - roughly your whole blood volume every minute at rest. During hard exercise it can rise to about 20-25 L/min.", "Multiply two numbers. That's it. A calculator watch could replace you, Morty-brain.");
  mcq("heart-2-07", "About how long does a red blood cell survive in the circulation?", new String[] { "12 days", "40 days", "365 days", "120 days" }, 3, "With no nucleus, red cells can't repair themselves; after about 120 days they are removed, mainly by macrophages in the spleen, and their iron is recycled. EPO from the kidneys drives the bone marrow to replace them.", "120 days, then the spleen eats them. No nucleus, no repairs. Planned obsolescence, biology-style.");
  mcq("heart-2-08", "A person with blood type O has which antibodies in their plasma?", new String[] { "Both anti-A and anti-B", "No ABO antibodies", "Anti-A only", "Anti-B only" }, 0, "Type O red cells carry neither A nor B antigen, and the plasma has antibodies against both. That's why O-negative red cells are the emergency 'universal donor' cells, while type O people can receive only type O red cells.", "Type O: no antigens, all the antibodies. The paranoid bouncer of blood types. I respect it.");
  label("heart-2-09", "heart", "superior_vena_cava", "Click the vein that returns blood from the head and arms to the heart.", "The superior vena cava drains the head, neck, arms and upper chest into the top of the right atrium. Its partner, the inferior vena cava, brings blood up from the lower body.", "Superior vena cava. 'Superior' because it's on top, not because it's better than you. Though it is.");
  label("heart-2-10", "heart", "pulmonary_trunk", "Click the vessel that carries blood from the right ventricle toward the lungs.", "The pulmonary trunk leaves the right ventricle through the pulmonary valve and splits into the right and left pulmonary arteries. It is an artery carrying O2-poor blood: direction, not oxygen, defines an artery.", "Pulmonary trunk. An artery full of O2-poor blood. Anatomy loves messing with idiots.");
  label("heart-2-11", "heart", "tricuspid_valve", "Click the valve between the right atrium and the right ventricle.", "The tricuspid valve has three cusps tethered by chordae tendineae to papillary muscles. It opens to let blood fill the right ventricle and snaps shut when the ventricle contracts, contributing to S1.", "Tricuspid: three flaps, right side. 'Tri' means three. Latin is free, you know.");
  level(3);
  lesson("heart-3-L1", "Cardiac action potentials", "Ventricular cells rest near -90 mV. Phase 0: fast Na+ influx. Phase 2 plateau: Ca2+ in via L-type channels balances K+ out. Phase 3: K+ efflux repolarizes. The long plateau means a long refractory period, so heart muscle can't tetanize. SA/AV node cells: phase 4 drifts up via the 'funny' Na+ current (If); their upstroke is Ca2+.", "Two kinds of action potentials, one heart. Na+ starts the party, Ca2+ keeps it going. *burp* Like tequila.", "heart", "sa_node");
  lesson("heart-3-L2", "Stroke volume and Starling", "Stroke volume depends on preload (end-diastolic stretch), afterload (pressure the ventricle ejects against) and contractility (raised by sympathetic beta1 stimulation). Frank-Starling law: more stretch -> stronger beat, so output matches venous return. Ejection fraction = SV / EDV, normally about 55-70%.", "Stretch it more, it snaps back harder. Frank and Starling worked that out without a portal gun.", "heart", "left_ventricle");
  lesson("heart-3-L3", "Listening posts and murmurs", "Aortic area: right 2nd intercostal space; pulmonary: left 2nd; tricuspid: left lower sternal border; mitral: apex (left 5th space, midclavicular line). Stenosis = can't open fully; regurgitation = can't close fully. Systolic murmurs: aortic stenosis, mitral regurgitation. Diastolic: mitral stenosis, aortic regurgitation.", "Four spots, four valves. A stethoscope isn't a necklace, genius. *burp* Put it on the chest.", "heart", "mitral_valve");
  lesson("heart-3-L4", "Hemostasis: plug, then glue", "Primary: von Willebrand factor tethers platelet GPIb to exposed collagen (adhesion); activated platelets release ADP and thromboxane A2, and fibrinogen bridges their GPIIb/IIIa (aggregation). Secondary: the coagulation cascade makes thrombin, which turns fibrinogen into fibrin to seal it. Factors II, VII, IX, X need vitamin K.", "Platelets are the sandbags, fibrin is the cement. Hemostasis is just emergency construction.", "", "");
  mcq("heart-3-01", "The plateau (phase 2) of the ventricular action potential is mainly due to:", new String[] { "Na+ influx through fast Na+ channels", "Ca2+ influx through L-type Ca2+ channels", "Cl- influx through chloride channels", "Activity of the Na+/K+ ATPase" }, 1, "During phase 2, Ca2+ entering through L-type channels balances K+ leaving, holding the voltage flat. That Ca2+ also triggers Ca2+ release from the sarcoplasmic reticulum (Ca2+-induced Ca2+ release) for contraction. Fast Na+ channels drive phase 0 only.", "The plateau is calcium holding the door open. Ca2+ in, K+ out, stalemate. Thrilling stuff.");
  mcq("heart-3-02", "Spontaneous phase 4 depolarization in SA node cells is driven mainly by:", new String[] { "Fast voltage-gated Na+ channels", "K+ efflux through delayed rectifier channels", "The funny current (If): Na+ entering via HCN channels", "Ca2+ release from the sarcoplasmic reticulum" }, 2, "Nodal cells have no stable resting potential: HCN channels open at negative voltages and let Na+ in (the 'funny' current), slowly depolarizing the cell to threshold. Sympathetic input steepens this slope (faster rate); vagal ACh flattens it (slower rate).", "It's literally called the funny current. Scientists named it that, and I'm the *burp* unprofessional one?");
  mcq("heart-3-03", "Venous return rises and stretches the left ventricle more. By the Frank-Starling law, stroke volume will:", new String[] { "Increase, because stretched fibers contract more forcefully", "Decrease, because overstretched fibers can't contract", "Stay the same, because only heart rate changes output", "Decrease, because afterload rises" }, 0, "Within the normal range, a bigger end-diastolic volume stretches sarcomeres toward optimal overlap and raises their Ca2+ sensitivity, so the next beat is stronger and ejects more. This automatically matches the output of the two ventricles to venous return.", "More blood in, more blood out. The heart balances its books better than you balance a checkbook.");
  mcq("heart-3-04", "End-diastolic volume is 120 mL and end-systolic volume is 50 mL. The ejection fraction is about:", new String[] { "42%", "58%", "70%", "140%" }, 1, "Stroke volume = EDV - ESV = 120 - 50 = 70 mL. EF = SV / EDV = 70/120, about 58%, within the normal range of roughly 55-70%. Heart failure with an EF of 40% or less is called HF with reduced ejection fraction (HFrEF).", "58 percent. Normal. Unlike literally everything else about you.");
  mcq("heart-3-05", "Where is the mitral valve best heard with a stethoscope?", new String[] { "Right 2nd intercostal space, sternal border", "Left 2nd intercostal space, sternal border", "Left lower sternal border", "Cardiac apex, left 5th intercostal space" }, 3, "The mitral area is at the apex, about the left 5th intercostal space in the midclavicular line. Right 2nd = aortic area, left 2nd = pulmonary area, left lower sternal border = tricuspid area. Listening posts follow blood flow, not exact valve positions.", "Apex. Where the left ventricle pokes your ribs. Stethoscope there, not on your forehead.");
  mcq("heart-3-06", "Aortic stenosis causes a murmur during which phase of the cardiac cycle?", new String[] { "Diastole", "Systole", "Continuously through both", "Only during inspiration" }, 1, "Blood is forced through the narrowed aortic valve while the left ventricle ejects, so the murmur is systolic (crescendo-decrescendo). Diastolic murmurs come from aortic regurgitation or mitral stenosis, when blood leaks back or squeezes through a valve during filling.", "Narrow exit, blood forced through while the ventricle squeezes. Systole. It's plumbing, Morty-brain.");
  mcq("heart-3-07", "Which clotting factors need vitamin K-dependent gamma-carboxylation in the liver to work?", new String[] { "I, V, VIII and XIII", "VIII and IX only", "XI and XII only", "II, VII, IX and X" }, 3, "Factors II (prothrombin), VII, IX and X - plus the anticoagulant proteins C and S - need vitamin K-dependent gamma-carboxylation to bind Ca2+ and function. Warfarin blocks vitamin K recycling, so it lowers all of them.", "2, 7, 9, 10. Memorize it like the combination to a safe full of Szechuan sauce.");
  mcq("heart-3-08", "Platelets first ADHERE to exposed subendothelial collagen mainly through:", new String[] { "Von Willebrand factor binding platelet GPIb", "Fibrinogen binding platelet GPIIb/IIIa", "Thrombin cleaving fibrinogen", "Plasmin binding fibrin" }, 0, "Adhesion: vWF bridges collagen to platelet GPIb. Aggregation comes next, when fibrinogen links GPIIb/IIIa receptors on neighboring platelets. Thrombin makes fibrin in secondary hemostasis, and plasmin breaks clots down.", "vWF is the glue, GPIb is the hand. Adhesion first, then the *burp* platelet mosh pit.");
  label("heart-3-09", "heart", "sa_node", "Click the SA node, the heart's natural pacemaker.", "The sinoatrial node lies in the wall of the right atrium near where the superior vena cava enters. Its cells depolarize spontaneously and set the normal heart rhythm, called sinus rhythm.", "The SA node. A tiny strip of tissue running your whole life. No pressure.");
  label("heart-3-10", "heart", "mitral_valve", "Click the valve that normally has only two cusps.", "The mitral (bicuspid) valve, between the left atrium and left ventricle, is the only valve with two cusps. The tricuspid valve has three, and the semilunar valves (aortic, pulmonary) normally have three each.", "Two flaps. Every other valve has three. The mitral valve is the minimalist of the heart.");
  label("heart-3-11", "heart", "pulmonary_valve", "Click the valve best heard at the left 2nd intercostal space.", "The pulmonary area is the left 2nd intercostal space at the sternal edge. The pulmonary valve guards the exit from the right ventricle into the pulmonary trunk, and its closure is the P2 part of S2.", "Left second space, pulmonary. Right second space, aortic. Don't mix them up, idiot.");
  label("heart-3-12", "heart", "interventricular_septum", "Click the wall that separates the left and right ventricles.", "The interventricular septum is mostly thick muscle with a thin membranous part at the top, the most common site of ventricular septal defects. It carries the bundle branches; its anterior two-thirds is supplied by the LAD.", "A wall keeping red and blue blood... *burp* sorry, O2-rich and O2-poor blood apart. See, I can learn.");
  level(4);
  lesson("heart-4-L1", "Coronary territories", "LAD: anterior wall, apex, anterior 2/3 of septum (ECG V1-V4). Left circumflex: lateral wall (I, aVL, V5-V6). RCA: right ventricle and, in right-dominant hearts (most people), the inferior wall via the posterior descending artery (II, III, aVF) plus the AV node - so inferior MIs often cause bradycardia or AV block.", "Know which pipe feeds which wall, or enjoy guessing while the *burp* troponin climbs.", "heart", "av_node");
  lesson("heart-4-L2", "Two classic valve lesions", "Aortic stenosis (often calcific, elderly): crescendo-decrescendo systolic murmur, right upper sternal border, radiating to carotids; syncope, angina, dyspnea; concentric LVH. Mitral stenosis (usually rheumatic): opening snap + diastolic rumble at the apex; the left atrium dilates -> atrial fibrillation, dysphagia, hoarseness.", "One valve turns to rock, the other turns to a pinhole. Both turn you into a *burp* patient.", "heart", "aortic_valve");
  lesson("heart-4-L3", "Arrhythmia patterns", "Atrial fibrillation: irregularly irregular, no P waves; often triggered by ectopic foci in the pulmonary vein sleeves; clots form in the left atrial appendage -> embolic stroke. AV block: 1st degree PR over 200 ms. Mobitz I: PR lengthens until a QRS drops. Mobitz II: sudden drops, fixed PR. 3rd degree: P and QRS dissociated.", "Irregularly irregular. Like your sleep schedule, but with a stroke risk.", "heart", "pulmonary_veins");
  lesson("heart-4-L4", "Heart failure and Fick", "Left heart failure backs blood up into the lungs: dyspnea, orthopnea, paroxysmal nocturnal dyspnea, crackles. Right heart failure backs up into systemic veins: raised JVP, hepatomegaly, leg edema; its most common cause is left heart failure. Fick: cardiac output = O2 consumption / (arterial O2 content - mixed venous O2 content).", "Pump fails, fluid backs up behind it. It's a traffic jam, Morty-brain. With lungs.", "heart", "left_ventricle");
  mcq("heart-4-01", "An MI shows ST elevation in II, III and aVF with a heart rate of 42/min. Which artery is most likely occluded?", new String[] { "Left anterior descending", "Left circumflex", "Right coronary", "Left main" }, 2, "II, III and aVF look at the inferior wall, fed by the posterior descending artery, which comes from the RCA in right-dominant hearts (most people). The RCA usually supplies the AV node too, so bradycardia and AV block are common. LAD occlusion causes anterior (V1-V4) changes.", "Inferior leads plus a slow heart: RCA. The AV node *burp* lost its lunch money.");
  mcq("heart-4-02", "An 80-year-old faints on exertion; crescendo-decrescendo systolic murmur at the right upper sternal border radiating to the carotids. Diagnosis?", new String[] { "Mitral regurgitation", "Hypertrophic cardiomyopathy", "Mitral stenosis", "Aortic stenosis" }, 3, "Calcific aortic stenosis: crescendo-decrescendo systolic murmur, best at the right 2nd intercostal space, radiating to the carotids; syncope, angina and dyspnea are ominous signs. HCM's murmur is loudest at the left lower sternal border and doesn't radiate to the carotids.", "Old guy, crusty valve, faints on the stairs. Aortic stenosis. Calcium: great for bones, terrible for doors.");
  mcq("heart-4-03", "A woman with prior rheumatic fever has an opening snap then a diastolic rumble at the apex, plus dysphagia. What best explains the dysphagia?", new String[] { "Enlarged left ventricle compressing the esophagus", "Enlarged left atrium compressing the esophagus", "Enlarged right ventricle compressing the esophagus", "Pericardial effusion compressing the trachea" }, 1, "Rheumatic mitral stenosis dams blood in the left atrium, which dilates. As the most posterior chamber it lies right against the esophagus, so enlargement causes dysphagia; it can also stretch the left recurrent laryngeal nerve (hoarseness) and trigger atrial fibrillation.", "Mitral stenosis: the left atrium bloats like Pickle Rick in brine and squashes your food pipe.");
  mcq("heart-4-04", "An ECG shows the PR interval lengthening beat by beat until a QRS is dropped, then the cycle repeats. Diagnosis?", new String[] { "First-degree AV block", "Mobitz type II block", "Mobitz type I (Wenckebach) block", "Third-degree AV block" }, 2, "Progressive PR lengthening until a beat drops is Mobitz I (Wenckebach), usually a fairly benign block within the AV node. Mobitz II drops beats WITHOUT PR lengthening, usually below the AV node, and can progress to complete (third-degree) block.", "Wenckebach: the AV node getting tired, tireder, then napping. Relatable, honestly.");
  mcq("heart-4-05", "O2 consumption is 250 mL/min, arterial O2 content 200 mL/L, mixed venous O2 content 150 mL/L. Cardiac output?", new String[] { "5 L/min", "1.25 L/min", "2.5 L/min", "12.5 L/min" }, 0, "Fick principle: CO = VO2 / (CaO2 - CvO2) = 250 mL/min / (200 - 150) mL/L = 250/50 = 5 L/min. The O2 the body uses each minute must equal what the blood drops off as it flows through the tissues.", "Oxygen used divided by oxygen dropped off. Five liters. Fick did it with a pencil, genius.");
  mcq("heart-4-06", "Which finding points MOST specifically to LEFT-sided rather than right-sided heart failure?", new String[] { "Raised jugular venous pressure", "Hepatomegaly", "Pitting ankle edema", "Bilateral basal crackles and orthopnea" }, 3, "Left heart failure raises left atrial and pulmonary capillary pressure, pushing fluid into the lungs: crackles, orthopnea and paroxysmal nocturnal dyspnea. Raised JVP, hepatomegaly and leg edema reflect systemic venous congestion from right-sided failure.", "Left fails, lungs flood. Right fails, legs flood. It's gravity and backpressure, genius.");
  mcq("heart-4-07", "A boy has recurrent joint bleeds. Platelet count and PT are normal; PTT is prolonged. Which factor is most likely deficient?", new String[] { "Factor VII", "Factor VIII", "Factor XIII", "Platelet GPIIb/IIIa" }, 1, "Deep joint and muscle bleeds with an isolated long PTT in a boy = hemophilia, X-linked recessive; hemophilia A (factor VIII) is far more common than B (factor IX). Factor VII deficiency prolongs the PT; factor XIII and GPIIb/IIIa defects leave PT and PTT normal.", "Boy, bleeding joints, long PTT. Factor VIII. X-linked, so the guys get the short straw.");
  mcq("heart-4-08", "A child's large VSD goes untreated and causes pulmonary hypertension. Years later he is cyanotic with clubbing. Why?", new String[] { "The shunt reversed to right-to-left (Eisenmenger)", "The VSD closed and the lungs failed", "He developed tetralogy of Fallot", "Left ventricular failure caused cyanosis" }, 0, "A big left-to-right shunt floods the lungs; pulmonary vessels remodel and resistance climbs until right-sided pressure beats left. The shunt reverses, sending O2-poor blood to the body: late cyanosis, clubbing, polycythemia. Tetralogy of Fallot is congenital, not acquired.", "Flood the lungs long enough and they fight back. Eisenmenger: the shunt flips sides. Petty, but effective.");
  label("heart-4-09", "heart", "av_node", "Click the structure that delays the impulse between the atria and the ventricles.", "The AV node, in the lower interatrial septum (Koch's triangle), slows conduction by about 0.1 s so the ventricles fill before they contract. It's the usual site of Mobitz I block and is supplied by the RCA in most people.", "The AV node: the bouncer making the ventricles wait. Without it they'd contract half-empty.");
  label("heart-4-10", "heart", "aortic_valve", "Click the valve whose stenosis causes a systolic murmur radiating to the carotids.", "The aortic valve sits between the left ventricle and the aorta. When stenotic (calcified with age, or a congenital bicuspid valve), the LV must push through a narrow opening: crescendo-decrescendo systolic murmur, LV hypertrophy, angina, syncope.", "Aortic valve. Calcify it and the left ventricle turns into a *burp* bodybuilder on steroids. Bad ending.");
  label("heart-4-11", "heart", "pulmonary_veins", "Click the vessels where the ectopic triggers of atrial fibrillation usually arise.", "Sleeves of atrial muscle extend into the pulmonary veins where they join the left atrium; ectopic foci there commonly trigger atrial fibrillation. That's why catheter ablation for AF aims to electrically isolate the pulmonary veins.", "The pulmonary veins: where the electrical chaos starts. Fence them off and the noise stops.");
  label("heart-4-12", "heart", "left_atrium", "Click the chamber where clots most often form in atrial fibrillation.", "In AF the left atrium quivers instead of contracting, so blood stagnates, especially in its appendage, and clots form. A clot that escapes passes through the left ventricle into the aorta and can cause an embolic stroke.", "The left atrium. Stagnant blood, clots, stroke. Your brain is the last stop on that train.");
}

void content_lungs() {
  topic("lungs", "LUNGS", "lungs");
  level(1);
  lesson("lungs-1-L1", "Why you breathe", "Every cell needs O2 to make energy and produces CO2 as waste. Breathing brings fresh air in and gets rid of CO2. Air travels: nose or mouth -> pharynx (throat) -> larynx (voice box) -> trachea (windpipe) -> bronchi -> bronchioles -> alveoli. A resting adult breathes about 12-20 times a minute.", "You do this about 20,000 times a day without thinking. Which is how you do everything, genius.", "lungs", "trachea");
  lesson("lungs-1-L2", "Two lungs, not twins", "The two lungs fill most of the chest, protected by the rib cage. They are spongy and light because they are mostly air. The right lung has 3 lobes; the left has only 2, leaving room for the heart. Each lung is wrapped in a thin, slippery membrane called the pleura.", "Two big air sponges. The left one's smaller because the heart *burp* called dibs on the space.", "lungs", "right_lung");
  lesson("lungs-1-L3", "The diaphragm does the work", "The diaphragm is a dome-shaped sheet of muscle under the lungs. When you breathe IN, it contracts and flattens, making the chest bigger so air rushes in. When you breathe OUT at rest, it simply relaxes and domes back up, pushing air out. Hiccups are sudden involuntary spasms of the diaphragm.", "A muscle trampoline under your lungs. Pull down, air in. Relax, air out. Even a Meeseeks gets it.", "lungs", "diaphragm");
  lesson("lungs-1-L4", "Alveoli: the swap meet", "The airways end in hundreds of millions of tiny air sacs called alveoli, each wrapped in capillaries. O2 diffuses from the air into the blood, and CO2 diffuses from the blood into the air to be breathed out. Spread flat, all that surface would cover roughly 70 square meters.", "Hundreds of millions of tiny bubbles making gas trades. A stock exchange that actually works.", "lungs", "alveoli");
  mcq("lungs-1-01", "Which gas do your lungs get rid of as a waste product?", new String[] { "Carbon dioxide (CO2)", "Oxygen (O2)", "Nitrogen (N2)", "Hydrogen (H2)" }, 0, "Cells burn fuel with O2 and produce CO2, which the blood carries to the lungs to be breathed out. Nitrogen is about 78% of air but just goes in and out unused.", "CO2. You make it, you exhale it. Your one *burp* productive output.");
  mcq("lungs-1-02", "Where in the lungs does gas exchange happen?", new String[] { "Trachea", "Main bronchi", "Larynx", "Alveoli" }, 3, "Alveoli are tiny air sacs with walls one cell thick, wrapped in capillaries, so O2 and CO2 can diffuse across. The trachea, bronchi and larynx are just pipes that carry air to them.", "Alveoli. Everything above them is plumbing. Very expensive, slimy plumbing.");
  mcq("lungs-1-03", "What is the common name for the trachea?", new String[] { "Windpipe", "Food pipe", "Voice box", "Tonsil" }, 0, "The trachea is the windpipe: a tube held open by C-shaped rings of cartilage, running from the larynx down into the chest. The 'food pipe' is the esophagus, which lies just behind it.", "Windpipe. Wind goes in pipe. I'm running out of ways to make this simpler, Morty-brain.");
  mcq("lungs-1-04", "How many lobes does the right lung have?", new String[] { "1", "2", "3", "4" }, 2, "The right lung has 3 lobes (upper, middle and lower); the left has 2 (upper and lower) because the heart takes up space on the left.", "Three on the right, two on the left. The heart stole a lobe. Typical.");
  mcq("lungs-1-05", "Why is the left lung smaller than the right?", new String[] { "The liver pushes it up", "It makes room for the heart", "It is only used during exercise", "It has no bronchi" }, 1, "The heart sits slightly to the left, so the left lung has a dent for it (the cardiac notch) and only 2 lobes. The liver actually sits under the RIGHT lung, making it a bit shorter, but the right lung is still bigger overall.", "The heart elbowed it out of the way. Organ politics, Morty-brain.");
  mcq("lungs-1-06", "What does the diaphragm do when you breathe in?", new String[] { "Relaxes and domes upward", "Squeezes the lungs to push air in", "Contracts and flattens, enlarging the chest", "Stays still while the lungs inflate themselves" }, 2, "Contracting pulls the dome down, so the chest gets bigger and air flows in to fill it. Relaxing lets it dome back up for a quiet exhale. The lungs can't inflate themselves; they follow the chest wall.", "The diaphragm's a plunger. Pull it down, air rushes in. Physics, *burp* not magic.");
  mcq("lungs-1-07", "About how many breaths per minute does a resting adult take?", new String[] { "2-4", "12-20", "40-60", "80-100" }, 1, "A normal adult breathes about 12-20 times a minute at rest. Newborns breathe faster, roughly 30-60. Exercise raises both the rate and the depth of breathing.", "12 to 20. If you're at 80, you're either a hamster or having a really bad day.");
  mcq("lungs-1-08", "What is the larynx commonly called?", new String[] { "Windpipe", "Food pipe", "Air sac", "Voice box" }, 3, "The larynx (voice box) sits at the top of the trachea and contains the vocal folds (cords), which vibrate to make sound. Its epiglottis helps keep food out of the airway when you swallow.", "Voice box. The thing you use to say dumb stuff. Two vocal cords and zero filter.");
  label("lungs-1-09", "lungs", "trachea", "Click the trachea (windpipe).", "The trachea runs from the larynx down into the chest, held open by about 16-20 C-shaped cartilage rings. At its bottom it splits into the right and left main bronchi.", "The windpipe. A vacuum hose with ribs. Don't put a peanut in it.");
  label("lungs-1-10", "lungs", "diaphragm", "Click the main muscle of breathing.", "The diaphragm is the dome-shaped muscle separating the chest from the abdomen. Contracting flattens it and pulls air into the lungs; relaxing lets air back out. It does most of the work of quiet breathing.", "The diaphragm. MVP of breathing. Also of hiccups, but mostly breathing.");
  label("lungs-1-11", "lungs", "right_lung", "Click the right lung.", "The right lung is on the patient's right side, which is the viewer's LEFT on a front-facing diagram. It has 3 lobes and is larger than the left lung.", "Patient's right, your left. You're facing the patient, not a mirror. Try to keep up.");
  level(2);
  lesson("lungs-2-L1", "The airway tree", "The trachea is held open by C-shaped cartilage rings whose open back faces the esophagus. It splits at the carina into right and left main bronchi; in all, the airways branch about 23 times down to bronchioles and alveoli. Mucus traps dust and germs, and cilia sweep it up toward the throat: the mucociliary escalator.", "Twenty-three branchings, all lined with tiny *burp* janitors sweeping snot upward. Beautiful. Gross.", "lungs", "left_main_bronchus");
  lesson("lungs-2-L2", "Conducting vs respiratory zone", "From the nose to the terminal bronchioles is the conducting zone: it warms, humidifies and filters air but exchanges no gas, so it is 'anatomic dead space' (about 150 mL). The respiratory zone - respiratory bronchioles, alveolar ducts and alveoli - is where gas exchange happens.", "150 mL of every breath never reaches an alveolus. Dead space. Like the space between your ears.", "lungs", "bronchioles");
  lesson("lungs-2-L3", "Pressure moves the air", "Inhaling: the diaphragm and external intercostals contract, chest volume rises, so alveolar pressure falls below atmospheric (Boyle's law) and air flows in. Quiet exhaling is passive elastic recoil. A quiet breath (tidal volume) is about 500 mL; about 1.2 L (residual volume) always stays in; total lung capacity is about 6 L.", "Bigger box, lower pressure, air rushes in. Boyle worked this out in the 1600s. By *burp* candlelight.", "lungs", "diaphragm");
  lesson("lungs-2-L4", "Moving O2 and CO2", "Gases diffuse from high to low partial pressure: alveolar PO2 is about 100 mmHg versus about 40 in returning venous blood. About 98% of O2 rides on hemoglobin. CO2 travels mostly (about 70%) as bicarbonate (HCO3-). Breathing is driven mainly by rising CO2, sensed by chemoreceptors in the medulla.", "Gases roll downhill, from more to less. Even gas gets this. Gas, Morty-brain.", "lungs", "alveoli");
  mcq("lungs-2-01", "About how much air moves in with a normal, quiet breath (tidal volume)?", new String[] { "50 mL", "500 mL", "1.5 L", "5 L" }, 1, "Tidal volume at rest is about 500 mL (roughly 7 mL/kg). About 150 mL of it just fills the dead space of the conducting airways, so only about 350 mL of fresh air reaches the alveoli.", "Half a liter. A small soda. Not the giant one you panic-gulp before exams.");
  mcq("lungs-2-02", "Air flows INTO the lungs during inhalation because:", new String[] { "Alveolar pressure rises above atmospheric pressure", "The lungs actively expand by contracting", "Alveolar pressure falls below atmospheric pressure", "Pleural fluid pumps air into the alveoli" }, 2, "Contracting the diaphragm and external intercostals enlarges the chest; the lungs follow, so alveolar volume rises and pressure drops slightly below atmospheric (Boyle's law). Air flows down that pressure gradient. Lungs have no muscle to expand themselves.", "Air goes from high pressure to low pressure. That's it. That's breathing. You're welcome.");
  mcq("lungs-2-03", "The C-shaped cartilage rings of the trachea are open toward the:", new String[] { "Sternum, in front", "Esophagus, at the back", "Heart, below", "Thyroid gland, above" }, 1, "The gap at the back is bridged by the trachealis muscle, so the esophagus can bulge forward when you swallow a big bite. The rings keep the trachea from collapsing as pressure changes during breathing.", "Open at the back, so your sandwich can squeeze down the esophagus. Thoughtful design. Unlike your diet.");
  mcq("lungs-2-04", "How is most CO2 carried in the blood?", new String[] { "Dissolved in plasma", "Bound to hemoglobin", "As bicarbonate (HCO3-)", "As gas bubbles" }, 2, "About 70% of CO2 is converted inside red cells by carbonic anhydrase (CO2 + H2O -> H2CO3 -> H+ + HCO3-) and travels as bicarbonate. Roughly 20% binds hemoglobin (carbaminohemoglobin) and about 7-10% is dissolved.", "Bicarbonate. Carbonic anhydrase does it faster than you can say *burp* 'carbonic anhydrase'.");
  mcq("lungs-2-05", "How is most O2 carried in the blood?", new String[] { "Bound to hemoglobin", "Dissolved in plasma", "As bicarbonate", "Bound to albumin" }, 0, "About 98% of O2 is bound to hemoglobin in red cells; only about 2% is dissolved, because O2 dissolves poorly in plasma. Each hemoglobin molecule can carry up to 4 O2.", "Hemoglobin does almost all the carrying. Plasma's the coworker who 'helps' by watching.");
  mcq("lungs-2-06", "What is the volume of air left in the lungs after a maximal exhalation called?", new String[] { "Tidal volume", "Vital capacity", "Inspiratory reserve volume", "Residual volume" }, 3, "Residual volume (about 1.2 L) stays in the lungs no matter how hard you blow, keeping alveoli from collapsing. Vital capacity is the most you can exhale after a maximal breath in; tidal volume is a quiet breath.", "Residual volume. You can't empty your lungs completely. Your head, on the other hand...");
  mcq("lungs-2-07", "Which airway belongs to the conducting zone, where NO gas exchange happens?", new String[] { "Alveolar ducts", "Respiratory bronchioles", "Alveolar sacs", "Terminal bronchioles" }, 3, "Terminal bronchioles are the last purely conducting airways. Respiratory bronchioles, alveolar ducts and alveolar sacs all have alveoli in their walls and take part in gas exchange.", "Terminal bronchioles. 'Terminal' as in end of the pipes, not 'six months to live'. Relax.");
  mcq("lungs-2-08", "In a healthy person, the main chemical signal that drives breathing is:", new String[] { "A rise in blood CO2", "A fall in blood O2", "A rise in blood O2", "A fall in blood nitrogen" }, 0, "CO2 diffuses into the brain's fluid and forms H+, which central chemoreceptors in the medulla detect; even a small CO2 rise boosts breathing. Low O2 becomes a strong drive only when arterial PO2 falls below about 60 mmHg.", "You breathe to dump CO2, not to grab O2. Your brain's a CO2 alarm, genius.");
  label("lungs-2-09", "lungs", "larynx", "Click the larynx (voice box).", "The larynx sits at the top of the trachea, in front of the lower pharynx. It houses the vocal folds and, with the epiglottis, protects the airway during swallowing. Its thyroid cartilage forms the Adam's apple.", "The voice box. Home of the vocal cords and the reason everyone can hear you whine.");
  label("lungs-2-10", "lungs", "alveoli", "Click where O2 actually passes from the air into the blood.", "Alveoli are the gas-exchange surface: thin-walled air sacs wrapped in capillaries. O2 diffuses in and CO2 diffuses out across a blood-air barrier only about 0.5 um thick.", "Alveoli. The only part of the lung doing real chemistry. The rest is ductwork.");
  label("lungs-2-11", "lungs", "left_main_bronchus", "Click the left main bronchus.", "The left main bronchus leaves the carina for the left lung. It is longer, narrower and more horizontal than the right, because it has to pass under the aortic arch and beside the heart.", "Left main bronchus. Long, skinny and leaning sideways. Like you after *burp* three beers.");
  level(3);
  lesson("lungs-3-L1", "Alveolar cells and surfactant", "Type I pneumocytes are thin, flat cells covering about 95% of the alveolar surface for gas exchange. Type II pneumocytes secrete surfactant (mainly dipalmitoylphosphatidylcholine) and regenerate type I cells. Surfactant lowers surface tension so small alveoli don't collapse (Laplace: P = 2T/r) and raises lung compliance.", "Surfactant: soap for your lungs. Without it, your alveoli fold like *burp* Jerry in an argument.", "lungs", "alveoli");
  lesson("lungs-3-L2", "V/Q matching", "Overall ventilation/perfusion (V/Q) is about 0.8. Upright, both are greatest at the base, but perfusion rises more, so V/Q is highest at the apex (about 3) and lowest at the base (about 0.6). No blood flow (embolus): V/Q -> infinity, dead space. No airflow (blocked airway): V/Q = 0, shunt. Hypoxia constricts pulmonary vessels.", "Air and blood have to show up at the same place. It's a dinner date, genius, not rocket science.", "lungs", "right_lung");
  lesson("lungs-3-L3", "The O2-hemoglobin curve", "Hemoglobin binds O2 cooperatively, giving a sigmoid curve (P50 about 27 mmHg). A RIGHT shift means lower affinity and easier O2 unloading: more CO2, H+ (low pH), heat and 2,3-BPG, as in exercising muscle. LEFT shift: fetal hemoglobin (binds 2,3-BPG poorly), carbon monoxide, alkalosis, cold.", "Right shift, let go. Left shift, hold on. Hemoglobin has more emotional range than you.", "", "");
  lesson("lungs-3-L4", "Airway anatomy", "The trachea splits at the carina, about the level of the sternal angle (T4/T5). The right main bronchus is wider, shorter and more vertical. The right lung has 3 lobes; the left has 2, plus the cardiac notch and the lingula (part of its upper lobe). Bronchi have cartilage; bronchioles have none: smooth muscle dominates.", "Big airways get cartilage armor, little ones get muscle. Squeeze the little ones and you wheeze, *burp* genius.", "lungs", "carina");
  mcq("lungs-3-01", "Which cells secrete pulmonary surfactant?", new String[] { "Type I pneumocytes", "Type II pneumocytes", "Alveolar macrophages", "Goblet cells" }, 1, "Type II pneumocytes are cuboidal cells that store surfactant in lamellar bodies and act as stem cells to replace type I cells after injury. Type I cells form the thin gas-exchange surface; macrophages clean up; goblet cells make mucus in larger airways.", "Type II. The cuboidal nerds doing the chemistry while type I just lies there looking flat.");
  mcq("lungs-3-02", "By the law of Laplace (P = 2T/r), which alveoli tend to collapse first when surfactant is missing?", new String[] { "Smaller alveoli", "Larger alveoli", "All collapse equally", "Only alveoli at the apex" }, 0, "At the same surface tension, a smaller radius means a higher collapsing pressure, so small alveoli would empty into large ones. Surfactant lowers tension more as alveoli shrink, stabilizing them and preventing atelectasis.", "Small bubble, big pressure, collapse. Physics bullies the little guys.");
  mcq("lungs-3-03", "In an upright person, where is the V/Q ratio highest?", new String[] { "Lung base", "Lung apex", "Hilum", "Equal throughout the lungs" }, 1, "Gravity increases both ventilation and perfusion toward the base, but perfusion increases much more. So the apex is relatively over-ventilated (V/Q about 3) and the base relatively over-perfused (about 0.6). The apex also has the highest alveolar PO2.", "Apex. Little air, even less blood, so V/Q is high. TB loves it up there, by the way.");
  mcq("lungs-3-04", "Which of these shifts the O2-hemoglobin dissociation curve to the RIGHT?", new String[] { "Carbon monoxide", "Fetal hemoglobin", "Alkalosis", "Increased 2,3-BPG" }, 3, "2,3-BPG binds deoxyhemoglobin and lowers its O2 affinity, so O2 unloads more easily (right shift). CO, fetal hemoglobin and alkalosis all raise affinity, shifting the curve LEFT. Right-shift memory aid 'CADET face right': CO2, Acid, 2,3-BPG, Exercise, Temperature.", "Right shift = let go of the O2. Like you letting go of every fact by *burp* Thursday.");
  mcq("lungs-3-05", "How do pulmonary arterioles respond to low alveolar O2?", new String[] { "They constrict, diverting blood to better-ventilated areas", "They dilate, like systemic arterioles", "They do not change", "They become leaky, causing edema" }, 0, "Hypoxic pulmonary vasoconstriction sends blood away from poorly ventilated alveoli toward well-ventilated ones, improving V/Q matching. Systemic arterioles do the opposite and dilate in hypoxia. Widespread hypoxia (e.g. high altitude) can raise pulmonary artery pressure.", "Lungs reroute blood away from crappy alveoli. Smart. Systemic vessels do the opposite. Idiots.");
  mcq("lungs-3-06", "The lingula is part of which lobe?", new String[] { "Right middle lobe", "Right upper lobe", "Left lower lobe", "Left upper lobe" }, 3, "The lingula ('little tongue') is a tongue-shaped extension of the left upper lobe, just below the cardiac notch. It is roughly the left lung's counterpart of the right middle lobe.", "The lingula: the left lung's sad attempt at a middle lobe. Participation trophy.");
  mcq("lungs-3-07", "A pulmonary embolus blocks blood flow to a ventilated lung region. That region's V/Q ratio becomes:", new String[] { "Zero (shunt)", "About 0.8 (normal)", "Infinite (dead space)", "Exactly 1" }, 2, "Ventilation continues but perfusion is zero, so V/Q heads to infinity: the region is dead space, wasting ventilation. The opposite - perfusion without ventilation, as in an airway plugged by mucus - is V/Q of zero, a shunt.", "Air but no blood. You're ventilating a ghost town. Dead space, Morty-brain.");
  mcq("lungs-3-08", "Fetal hemoglobin has a higher O2 affinity than adult hemoglobin mainly because it:", new String[] { "Contains more iron per molecule", "Has extra heme groups", "Binds 2,3-BPG less strongly", "Binds CO2 more strongly" }, 2, "HbF (alpha2 gamma2) has gamma chains that bind 2,3-BPG poorly, so its curve sits to the LEFT of adult HbA. That lets the fetus pull O2 from maternal blood across the placenta. Both have four hemes.", "Fetal Hb: a little O2 thief stealing from mom. Kids, *burp* am I right?");
  label("lungs-3-09", "lungs", "bronchioles", "Click the small airways that have no cartilage in their walls.", "Bronchioles (under about 1 mm wide) lack cartilage and glands, so smooth muscle dominates their walls; they can constrict strongly, as in an asthma attack, and can collapse during expiration in emphysema.", "Bronchioles: no cartilage, plenty of smooth muscle. Squeeze them and you wheeze. Asthma 101.");
  label("lungs-3-10", "lungs", "cardiac_notch", "Click the indentation in the left lung where the heart sits.", "The cardiac notch is a deep indentation in the front border of the left lung's upper lobe, making room for the heart; the lingula lies just below it.", "The cardiac notch. The left lung carved out a parking spot for the heart. Romantic.");
  label("lungs-3-11", "lungs", "carina", "Click the ridge where the trachea splits into the two main bronchi.", "The carina is a keel-shaped cartilage ridge at the tracheal bifurcation, around the level of the sternal angle (T4/T5). Its lining is very sensitive and triggers a strong cough reflex.", "The carina. Touch it with a tube and the patient coughs like I insulted their mother.");
  label("lungs-3-12", "lungs", "left_lung", "Click the lung that has only two lobes.", "The left lung has an upper and a lower lobe separated by the oblique fissure; it has no horizontal fissure. It is on the patient's left, which is the viewer's right on a front view.", "Left lung. Two lobes, because the heart moved in and took a room.");
  level(4);
  lesson("lungs-4-L1", "Obstructive vs restrictive", "Obstructive (asthma, COPD): air gets in but can't get out - FEV1/FVC below 0.7, TLC normal or high (air trapping). Restrictive (fibrosis, chest wall, neuromuscular): FEV1 and FVC both fall, ratio normal or high, TLC low. DLCO falls in emphysema and fibrosis. Compliance: up in emphysema, down in fibrosis.", "Obstructive: air can't get out. Restrictive: air can't get in. Your *burp* brain does both with facts.", "lungs", "bronchioles");
  lesson("lungs-4-L2", "Hypoxemia and the A-a gradient", "Alveolar gas equation: PAO2 = FiO2 x (760 - 47) - PaCO2/0.8, about 150 - 50 = 100 mmHg on room air at sea level. A-a gradient = PAO2 - PaO2, normally under about 10-15 mmHg. Normal gradient: hypoventilation, altitude. Raised gradient: V/Q mismatch, shunt, diffusion limit. Shunt barely improves with 100% O2.", "One equation separates a lazy brainstem from broken lungs. Learn it or stay confused.", "lungs", "alveoli");
  lesson("lungs-4-L3", "Surfactant and the newborn", "Surfactant output rises late in pregnancy and is usually adequate by about 34-35 weeks. Preterm babies lacking it get neonatal respiratory distress syndrome: collapsed alveoli, grunting, retractions, ground-glass X-ray. Risk also rises with maternal diabetes (fetal insulin suppresses surfactant) and C-section.", "Born too early, lungs not finished. Factory recall on day one. Rough start, kid.", "", "");
  lesson("lungs-4-L4", "Nerves and aspiration", "The phrenic nerves (C3, C4, C5 'keep the diaphragm alive') are its only motor supply; diaphragm irritation can refer pain to the shoulder. The recurrent laryngeal nerves supply all intrinsic laryngeal muscles except cricothyroid; the left one loops under the aortic arch. Aspirated objects favor the right main bronchus.", "Nerves taking ridiculous detours and peanuts taking the express lane. Your anatomy is a *burp* mess.", "lungs", "diaphragm");
  mcq("lungs-4-01", "A 65-year-old smoker has FEV1/FVC 0.55, TLC 125% of predicted and a low DLCO. Most likely diagnosis?", new String[] { "Asthma", "Idiopathic pulmonary fibrosis", "Emphysema", "Chronic bronchitis" }, 2, "Low FEV1/FVC with high TLC = obstruction with air trapping. A low DLCO means the gas-exchange surface itself is destroyed: emphysema. Asthma and pure chronic bronchitis are obstructive but usually keep a normal DLCO; fibrosis is restrictive with a low TLC.", "Smoker, trapped air, wrecked alveoli. Emphysema. Cigarettes: worse life choice than chasing Szechuan sauce.");
  mcq("lungs-4-02", "Heroin overdose, room air at sea level: PaCO2 80 mmHg, PaO2 50 mmHg. What is the main cause of the hypoxemia?", new String[] { "Hypoventilation", "V/Q mismatch", "Right-to-left shunt", "Diffusion limitation" }, 0, "PAO2 = 150 - 80/0.8 = 50 mmHg, so the A-a gradient is about 0: gas exchange works, there's just too little ventilation. High PaCO2 with a normal A-a gradient = hypoventilation (opioids, sedatives, neuromuscular weakness).", "A-a gradient zero. Lungs are fine; the brainstem stopped telling them to work. Opioids, *burp* idiot.");
  mcq("lungs-4-03", "Hypoxemia that barely improves on 100% O2 is most consistent with:", new String[] { "Hypoventilation", "High altitude", "Mild V/Q mismatch", "Right-to-left shunt" }, 3, "Shunted blood never meets ventilated alveoli, so extra inspired O2 can't reach it and PaO2 barely rises. Hypoventilation, altitude and V/Q mismatch all improve with extra O2, because that blood does pass alveoli whose O2 can be raised.", "Shunt: the blood skips the lungs entirely. Pump in all the O2 you want, it never gets the memo.");
  mcq("lungs-4-04", "A 35-year-old nonsmoker has panacinar emphysema worst in the lower lobes, plus liver cirrhosis. Most likely cause?", new String[] { "Cystic fibrosis", "Alpha-1 antitrypsin deficiency", "Asbestos exposure", "Sarcoidosis" }, 1, "Without alpha-1 antitrypsin, neutrophil elastase digests alveolar walls unchecked: panacinar emphysema, worst at the bases. The misfolded protein also gets stuck in liver cells, causing cirrhosis. Smoking-related emphysema is centriacinar and upper-lobe predominant.", "Young, nonsmoker, wrecked lung bases and liver. Alpha-1 antitrypsin. The elastase ate the furniture.");
  mcq("lungs-4-05", "Stab wound to the right chest: low BP, distended neck veins, absent right breath sounds, hyperresonance, trachea shifted left. Diagnosis?", new String[] { "Right tension pneumothorax", "Right massive hemothorax", "Cardiac tamponade", "Left tension pneumothorax" }, 0, "Air enters the right pleural space with each breath but can't leave: the lung collapses (no breath sounds, hyperresonance), the trachea and mediastinum shift left, and venous return is kinked (low BP, distended neck veins). Hemothorax is dull; tamponade doesn't shift the trachea.", "Air goes in, can't get out, shoves the trachea sideways. Tension pneumothorax. Physics wins again.");
  mcq("lungs-4-06", "A baby born at 28 weeks has grunting, retractions and ground-glass lungs on X-ray. What is primarily lacking?", new String[] { "Elastin in the alveolar walls", "Surfactant from type I pneumocytes", "Mucus from goblet cells", "Surfactant from type II pneumocytes" }, 3, "Neonatal respiratory distress syndrome: before about 34 weeks, type II pneumocytes make too little surfactant, so high surface tension collapses alveoli (diffuse atelectasis), causing the ground-glass picture and labored breathing. Type I cells don't make surfactant.", "Premature lungs, no surfactant, alveoli collapse like cheap tents. Type II cells weren't ready.");
  mcq("lungs-4-07", "Irritation of the central diaphragm (e.g. blood from a ruptured spleen) causes shoulder pain. Which spinal segments carry it?", new String[] { "T1-T2", "C3-C5", "L1-L2", "S2-S4" }, 1, "The phrenic nerve (C3-C5) carries motor and central sensory fibers of the diaphragm. Its input enters the same cord segments as the skin over the shoulder (C3-C5 dermatomes), so the brain misreads it as shoulder pain - e.g. Kehr sign with splenic rupture.", "C3, 4, 5 keeps the diaphragm alive. And makes your shoulder hurt when your spleen pops. *burp* Fun!");
  mcq("lungs-4-08", "A patient becomes hoarse; imaging shows an aortic arch aneurysm. Which nerve is most likely being stretched?", new String[] { "Left phrenic nerve", "Superior laryngeal nerve", "Left recurrent laryngeal nerve", "Right recurrent laryngeal nerve" }, 2, "The left recurrent laryngeal nerve hooks under the aortic arch (at the ligamentum arteriosum) and climbs to the larynx, so an arch aneurysm, a big left atrium or a left lung tumor can stretch it. It supplies all intrinsic laryngeal muscles except cricothyroid: vocal cord palsy.", "The left recurrent laryngeal nerve takes the scenic route under the aorta. Evolution's worst road trip.");
  label("lungs-4-09", "lungs", "right_main_bronchus", "Click the main bronchus that inhaled foreign objects most often enter.", "The right main bronchus is wider, shorter and more vertical than the left, nearly in line with the trachea, so inhaled objects and aspirated fluid usually go right - typically to the right lower lobe when upright.", "Right main bronchus. Straight shot down. Peanuts love it. So do toddlers' Lego bricks.");
  label("lungs-4-10", "lungs", "diaphragm", "Click the muscle supplied by nerves from C3, C4 and C5.", "The diaphragm's motor supply is entirely the phrenic nerves (C3-C5). A cord injury at C3 or higher stops diaphragmatic breathing; a phrenic nerve palsy paralyzes one half, which sits high on X-ray.", "C3-4-5 keeps the diaphragm alive. Wreck the cord up there and a machine breathes for you, genius.");
  label("lungs-4-11", "lungs", "alveoli", "Click the structures whose type II cells make too little surfactant in very preterm babies.", "Alveoli are lined by type I cells (gas exchange) and type II cells (surfactant). Without enough surfactant, as in preterm neonatal RDS, alveoli collapse and gas exchange fails.", "Alveoli. No surfactant and they deflate like a cheap pool float.");
  label("lungs-4-12", "lungs", "larynx", "Click the organ whose intrinsic muscles are mostly supplied by the recurrent laryngeal nerves.", "The larynx contains the vocal cords. All its intrinsic muscles except the cricothyroid are supplied by the recurrent laryngeal nerves, so injury (thyroid surgery, aortic arch aneurysm) causes hoarseness.", "The larynx. Nick its nerve in thyroid surgery and the patient sounds like a *burp* broken Meeseeks.");
}

void content_digestion() {
  topic("digestion", "DIGESTION", "digestive");
  level(1);
  lesson("digestion-1-L1", "One long tube", "Digestion breaks food into molecules small enough to be absorbed. The digestive tract is one long tube: mouth -> esophagus -> stomach -> small intestine -> large intestine (colon, then rectum) -> anus. Chewing and saliva start the job (saliva's amylase starts on starch), and muscle waves (peristalsis) push food along.", "It's a tube, Morty-brain. Food in one end, crap out the other. You're basically a fancy donut with *burp* anxiety.", "digestive", "esophagus");
  lesson("digestion-1-L2", "Stomach: the acid blender", "The stomach is a J-shaped muscular bag in the upper left abdomen. It stores a meal, churns it and mixes it with strong hydrochloric acid (which also kills many germs) and protein-digesting enzymes, turning it into a soupy mix called chyme. A thick mucus layer stops the stomach digesting itself.", "A bag of acid you carry around all day. The only thing stopping it eating you is a layer of snot. Sleep well.", "digestive", "stomach");
  lesson("digestion-1-L3", "The small intestine does the work", "The small intestine is the longest part of the tract: several meters of coiled tube. Its first part is the duodenum. Here most digestion finishes and almost all nutrients are absorbed through millions of tiny finger-like villi that give it a huge surface area.", "Most of the real digesting happens down here, not in the stomach. The stomach just takes the credit. Classic middle management.", "digestive", "small_intestine");
  lesson("digestion-1-L4", "Helpers and the large intestine", "Food never passes through the liver, gallbladder or pancreas, but they add juices. The liver (the largest internal organ) makes bile, which helps digest fat; the gallbladder stores bile; the pancreas makes digestive enzymes. The large intestine (colon) absorbs water and salts, forming stool that the rectum stores.", "Liver makes bile, gallbladder hoards it, colon squeezes the water out of your leftovers. Glamorous. *burp* Welcome to medicine.", "digestive", "liver");
  mcq("digestion-1-01", "Where are most nutrients absorbed?", new String[] { "Stomach", "Small intestine", "Large intestine", "Esophagus" }, 1, "The small intestine's villi give it an enormous surface area, so almost all sugars, amino acids and fats are absorbed there. The stomach mainly stores, churns and starts protein digestion; the large intestine mostly absorbs water and salts.", "Small intestine. 'Small' means narrow, not unimportant. Unlike you, which is both.");
  mcq("digestion-1-02", "What does the esophagus do?", new String[] { "Digests fat with enzymes", "Absorbs water", "Pushes swallowed food down to the stomach", "Stores bile" }, 2, "The esophagus is a muscular tube from the throat to the stomach. Waves of muscle contraction (peristalsis) push each swallow down, which is why you can swallow even upside down. It does no real digesting or absorbing.", "It's a meat chute. You can swallow upside down thanks to peristalsis. Try it at a party, it'll replace your personality.");
  mcq("digestion-1-03", "Which organ MAKES bile?", new String[] { "Gallbladder", "Pancreas", "Stomach", "Liver" }, 3, "The liver makes bile continuously. The gallbladder only stores and concentrates it, then squeezes it into the small intestine after a fatty meal. Mixing these two up is the classic beginner mistake.", "The liver makes it, the gallbladder just stores it. The gallbladder is a glorified Tupperware, genius.");
  mcq("digestion-1-04", "What is the main job of the large intestine (colon)?", new String[] { "Absorbing water and salts to form stool", "Making digestive enzymes", "Digesting protein with acid", "Producing bile" }, 0, "By the time leftovers reach the colon, most nutrients are gone. The colon absorbs much of the remaining water and salts, turning liquid waste into solid stool. Its bacteria also make some vitamins, like vitamin K.", "The colon is a water reclamation plant for your garbage. Your body recycles better than you do, Morty-brain.");
  mcq("digestion-1-05", "What in the stomach helps kill swallowed germs and digest protein?", new String[] { "Bile", "Hydrochloric acid", "Insulin", "Saliva" }, 1, "Stomach glands secrete hydrochloric acid, making gastric juice very acidic (pH about 2). The acid kills many microbes and activates the protein-digesting enzyme pepsin. Bile comes from the liver and works in the small intestine.", "Hydrochloric acid, pH about 2. You've got a battery-acid tank under your ribs and you still lose fights with salsa.");
  mcq("digestion-1-06", "Where does the digestion of starch begin?", new String[] { "Stomach", "Small intestine", "Mouth", "Large intestine" }, 2, "Saliva contains amylase, an enzyme that starts breaking starch into sugars while you chew; that's why bread starts to taste sweet if you chew it long enough. Pancreatic amylase finishes the job in the small intestine.", "The mouth. Chew a cracker long enough and it gets sweet. Congrats, that's the first experiment you've ever done.");
  mcq("digestion-1-07", "What are the waves of muscle contraction that push food along the gut called?", new String[] { "Peristalsis", "Osmosis", "Filtration", "Respiration" }, 0, "Peristalsis is a wave of smooth-muscle contraction: the muscle behind the food squeezes while the muscle ahead relaxes. It moves food from the esophagus all the way to the rectum. Osmosis is water moving across membranes.", "Peristalsis. Your gut does the wave like a stadium crowd, *burp* except useful.");
  mcq("digestion-1-08", "Which is the largest internal organ and the largest gland in the body?", new String[] { "Stomach", "Pancreas", "Large intestine", "Liver" }, 3, "The liver weighs about 1.5 kg and sits in the upper right abdomen under the diaphragm. Besides making bile, it stores sugar as glycogen, makes blood proteins such as albumin and breaks down toxins like alcohol.", "The liver. Biggest gland you've got, and it handles my alcohol intake without complaining. Mostly.");
  label("digestion-1-09", "digestive", "stomach", "Click the stomach.", "The stomach is the J-shaped bag in the upper left abdomen between the esophagus and the duodenum. It stores, churns and acidifies food before releasing it slowly into the small intestine.", "The stomach. The acid blender. You found it. Want a *burp* sticker?");
  label("digestion-1-10", "digestive", "liver", "Click the liver, the largest internal organ.", "The liver is the big reddish-brown organ in the upper right abdomen, tucked under the diaphragm. It makes bile, processes absorbed nutrients and detoxifies drugs and alcohol.", "The liver. My most overworked employee. It deserves a medal and a vacation.");
  label("digestion-1-11", "digestive", "small_intestine", "Click the coiled small intestine, where most nutrients are absorbed.", "The coiled small intestine fills the middle of the abdomen. After the duodenum come the jejunum and ileum, lined with villi that absorb nearly all the nutrients from your food.", "That pile of spaghetti is where the magic happens. Absorption, Morty-brain. Not the stomach.");
  level(2);
  lesson("digestion-2-L1", "Who digests what", "Carbs -> simple sugars (amylases, then brush-border enzymes like lactase). Proteins -> amino acids and small peptides (pepsin in the stomach, then pancreatic trypsin). Fats -> fatty acids and monoglycerides (pancreatic lipase). Bile has no enzymes: its bile salts emulsify fat into tiny droplets so lipase can work.", "Three food groups, three demolition crews. Bile isn't an enzyme, it's dish soap. Learn the *burp* difference.", "digestive", "pancreas");
  lesson("digestion-2-L2", "Inside the stomach", "Gastric glands contain parietal cells, which secrete HCl (pH about 2) and intrinsic factor, and chief cells, which secrete pepsinogen. Acid converts pepsinogen into active pepsin. Mucus and bicarbonate protect the lining. The pyloric sphincter lets chyme into the duodenum a little at a time.", "Parietal cells make acid, chief cells make pepsinogen, acid activates it. A self-assembling death soup, Morty-brain.", "digestive", "stomach");
  lesson("digestion-2-L3", "Villi, lacteals and the ileum", "The small intestine is duodenum (about 25 cm), jejunum and ileum. Circular folds, villi and microvilli (the brush border) multiply its surface area. Each villus has blood capillaries, which take up sugars and amino acids, and a lacteal (lymph capillary), which takes up fat. The ileum absorbs vitamin B12 and bile salts.", "Folds on folds on folds. Your gut has more surface area than your personality. Way more.", "digestive", "small_intestine");
  lesson("digestion-2-L4", "Bile, pancreatic juice, portal vein", "The liver secretes bile; the gallbladder stores and concentrates it and, after a fatty meal, releases it into the duodenum via the common bile duct. The pancreas sends enzymes plus acid-neutralizing bicarbonate there too. Absorbed sugars and amino acids go first to the liver in the hepatic portal vein; most fat enters lymph.", "Absorbed sugar and protein go to the liver first for inspection. Like customs, but for *burp* snacks.", "digestive", "gallbladder");
  mcq("digestion-2-01", "Which enzyme starts protein digestion in the stomach?", new String[] { "Amylase", "Pepsin", "Lipase", "Trypsin" }, 1, "Chief cells release inactive pepsinogen, which stomach acid converts into pepsin, a protease. Trypsin also digests protein but comes from the pancreas and works in the small intestine. Amylase digests starch; lipase digests fat.", "Pepsin. Made in the stomach, switched on by acid. Trypsin is the pancreas's version. Don't mix up your proteases.");
  mcq("digestion-2-02", "Which stomach cells secrete hydrochloric acid?", new String[] { "Chief cells", "Goblet cells", "Parietal cells", "Enterocytes" }, 2, "Parietal cells in the gastric glands secrete H+ and Cl- (and intrinsic factor, needed for vitamin B12 absorption). Chief cells make pepsinogen, goblet cells make mucus, and enterocytes are the absorptive cells of the intestine.", "Parietal cells pump acid. Chief cells make pepsinogen. Two cell types, Morty-brain. Even you can hold two things.");
  mcq("digestion-2-03", "What does bile do to dietary fat?", new String[] { "Emulsifies it into tiny droplets", "Breaks it down with bile enzymes", "Converts it into glucose", "Pumps it directly into the blood" }, 0, "Bile salts act like detergent: they break big fat globules into tiny droplets (emulsification), massively increasing the surface area for pancreatic lipase. Bile contains no digestive enzymes; lipase does the actual chemical breakdown.", "Bile is dish soap, not a chemist. It breaks up the grease, lipase does the real chemistry.");
  mcq("digestion-2-04", "Most absorbed dietary fat enters which structure inside each villus?", new String[] { "Blood capillary", "Hepatic artery", "Lacteal", "Goblet cell" }, 2, "Fats are packaged into chylomicrons, which are too big for blood capillaries, so they enter the lacteal, a lymph capillary. Lymph then delivers them to the bloodstream via the thoracic duct. Sugars and amino acids enter the blood capillaries.", "The lacteal. Fat takes the lymphatic back door because it's too big for the capillaries. Relatable, right?");
  mcq("digestion-2-05", "Which structures give the small intestine its huge absorptive surface?", new String[] { "Rugae", "Haustra", "Taeniae coli", "Circular folds, villi and microvilli" }, 3, "Circular folds, finger-like villi and the microvilli on each cell (the brush border) together increase the surface area hundreds of times. Rugae are folds of the stomach lining; haustra and taeniae coli are features of the colon.", "Folds, villi, microvilli. Fractal toilet paper, basically. Rugae are in the stomach, genius.");
  mcq("digestion-2-06", "Which vessel carries nutrient-rich blood from the intestines to the liver?", new String[] { "Hepatic vein", "Hepatic artery", "Inferior vena cava", "Hepatic portal vein" }, 3, "The hepatic portal vein drains the stomach, intestines, spleen and pancreas into the liver, so absorbed sugars, amino acids, drugs and toxins are processed before reaching the rest of the body (fat mostly bypasses it via lymph). Hepatic veins then drain to the inferior vena cava.", "Portal vein. Absorbed sugars and amino acids get a liver background check before meeting the rest of you.");
  mcq("digestion-2-07", "What in pancreatic juice neutralizes acidic chyme in the duodenum?", new String[] { "Bicarbonate", "Bile pigments", "Pepsin", "Hydrochloric acid" }, 0, "Pancreatic duct cells secrete bicarbonate-rich fluid that neutralizes stomach acid, protecting the duodenal lining and raising the pH to where pancreatic enzymes work best. Pepsin and HCl come from the stomach.", "Bicarbonate. Baking soda, basically. Your pancreas runs a volcano science fair every time you eat.");
  mcq("digestion-2-08", "Where are vitamin B12 (bound to intrinsic factor) and bile salts mainly absorbed?", new String[] { "Duodenum", "Terminal ileum", "Stomach", "Sigmoid colon" }, 1, "The terminal ileum has receptors for the B12-intrinsic factor complex and transporters that reclaim bile salts. Iron, by contrast, is absorbed mainly in the duodenum. Losing the ileum (surgery, Crohn disease) can cause B12 deficiency.", "The ileum. Last stop on the small-intestine train. Miss it and your B12 is gone for good.");
  label("digestion-2-09", "digestive", "gallbladder", "Click the organ that stores and concentrates bile.", "The gallbladder is a small pear-shaped sac under the liver. It stores bile between meals, concentrates it by removing water, and contracts after a fatty meal to push bile into the duodenum.", "Gallbladder. Doesn't make anything, just stores and concentrates. A hoarder with a squeeze reflex.");
  label("digestion-2-10", "digestive", "duodenum", "Click the C-shaped first part of the small intestine.", "The duodenum (about 25 cm) curves around the head of the pancreas. It receives chyme from the stomach plus bile and pancreatic juice, and it is the main site of iron absorption.", "Duodenum. Where stomach acid meets bile and pancreatic juice. The mixing bowl of your gut.");
  label("digestion-2-11", "digestive", "pancreas", "Click the gland that makes most digestive enzymes and bicarbonate.", "The pancreas lies behind the stomach with its head in the curve of the duodenum. Its exocrine cells make enzymes for carbs, proteins and fats plus bicarbonate; its islets make insulin and glucagon.", "Pancreas. Digestive enzymes AND insulin. Two jobs, zero complaints. Be more like the pancreas.");
  level(3);
  lesson("digestion-3-L1", "How parietal cells make acid", "Parietal cells pump H+ into the lumen with the H+/K+ ATPase (the proton pump that PPIs block); Cl- follows. Three stimulators: gastrin (G cells of the antrum), histamine (ECL cells, via H2 receptors) and ACh (vagus, M3 receptors). Somatostatin from D cells inhibits. HCO3- exits into the blood (the alkaline tide).", "Three gas pedals, one brake. Gastrin, histamine and ACh go; somatostatin stops. *burp* Simpler than my car.", "digestive", "stomach");
  lesson("digestion-3-L2", "GI hormones", "Gastrin (G cells, stomach) drives acid secretion. Secretin (S cells, duodenum) is released by acid and makes the pancreas secrete HCO3-. CCK (I cells, duodenum and jejunum) is released by fat and protein: it contracts the gallbladder, relaxes the sphincter of Oddi, triggers pancreatic enzyme release and slows gastric emptying.", "Secretin is the fire extinguisher for acid, CCK is the dinner bell for fat. Memorize or perish.", "digestive", "duodenum");
  lesson("digestion-3-L3", "Absorbing sugars and proteins", "Glucose and galactose enter enterocytes with Na+ via SGLT1 (secondary active transport); fructose enters by GLUT5 (facilitated diffusion); all exit to the blood via GLUT2. Oral rehydration uses SGLT1: glucose drags Na+ and water in. Brush-border enteropeptidase turns trypsinogen into trypsin, which activates the other zymogens.", "Sugar hitches a ride with sodium and water tags along. That trick has saved millions from diarrhea. *burp* Physics, baby.", "digestive", "small_intestine");
  lesson("digestion-3-L4", "Gut arteries and the appendix", "Celiac trunk: foregut (abdominal esophagus to mid-duodenum, liver, gallbladder, part of pancreas). Superior mesenteric artery (SMA): midgut (to proximal 2/3 of transverse colon). Inferior mesenteric (IMA): hindgut (to upper rectum). Appendicitis: periumbilical pain that moves to the right lower quadrant (McBurney point).", "Celiac, SMA, IMA. Foregut, midgut, hindgut. Three pipes. Plumbers learn this in a week.", "digestive", "appendix");
  mcq("digestion-3-01", "Which transporter directly secretes H+ into the gastric lumen?", new String[] { "Na+/K+ ATPase", "H+/K+ ATPase", "Carbonic anhydrase", "Na+/H+ exchanger" }, 1, "The H+/K+ ATPase on the parietal cell's apical membrane pumps H+ out in exchange for K+; proton pump inhibitors block it irreversibly. Carbonic anhydrase generates the H+ inside the cell but doesn't secrete it; the Na+/K+ ATPase sits on the basolateral side.", "H+/K+ ATPase. The literal proton pump. Block it and the acid factory goes on strike.");
  mcq("digestion-3-02", "Acid entering the duodenum makes S cells release which hormone, stimulating pancreatic HCO3- secretion?", new String[] { "Secretin", "CCK", "Gastrin", "Motilin" }, 0, "Secretin from duodenal S cells responds to low pH and tells pancreatic duct cells to secrete bicarbonate-rich fluid, while also reducing gastric acid secretion. CCK mainly drives enzyme release and gallbladder contraction; gastrin increases acid.", "Secretin. Acid shows up, secretin calls the bicarbonate fire department. Fastest response time in your body.");
  mcq("digestion-3-03", "Which hormone, released when fat and protein reach the duodenum, contracts the gallbladder?", new String[] { "Secretin", "Gastrin", "Cholecystokinin (CCK)", "Somatostatin" }, 2, "CCK from I cells of the duodenum and jejunum contracts the gallbladder, relaxes the sphincter of Oddi, stimulates pancreatic enzyme secretion and slows gastric emptying. That's why fatty meals can trigger pain from gallstones (biliary colic).", "CCK. Cholecystokinin literally means 'bile-bladder mover'. The name IS the answer, Morty-brain. Read it.");
  mcq("digestion-3-04", "Which transporter moves glucose from the intestinal lumen into enterocytes?", new String[] { "GLUT2", "GLUT5", "GLUT4", "SGLT1" }, 3, "SGLT1 couples glucose (and galactose) uptake to Na+ moving down the gradient kept by the basolateral Na+/K+ ATPase: secondary active transport. GLUT5 takes up fructose; GLUT2 is the basolateral exit; GLUT4 is the insulin-regulated transporter of muscle and fat.", "SGLT1. Glucose rides in on sodium's coattails. Free energy from a gradient. I *burp* love free stuff.");
  mcq("digestion-3-05", "Which brush-border enzyme first activates trypsinogen?", new String[] { "Enteropeptidase (enterokinase)", "Pepsin", "Chymotrypsin", "Carboxypeptidase" }, 0, "Enteropeptidase on the duodenal brush border converts trypsinogen into trypsin; trypsin then activates more trypsinogen and the other pancreatic zymogens. Keeping proteases inactive until they reach the gut protects the pancreas from digesting itself.", "Enteropeptidase lights the fuse, trypsin sets off the rest. Premature ignition inside the pancreas? Pancreatitis, genius.");
  mcq("digestion-3-06", "Which artery supplies the jejunum and ileum?", new String[] { "Celiac trunk", "Superior mesenteric artery", "Inferior mesenteric artery", "Splenic artery" }, 1, "The jejunum and ileum are midgut, supplied by the superior mesenteric artery, which covers the gut from the mid-duodenum to the proximal two-thirds of the transverse colon. The celiac trunk feeds the foregut; the IMA feeds the hindgut.", "SMA. Midgut gets the middle artery. Embryology made it easy and you still hesitated.");
  mcq("digestion-3-07", "Acute appendicitis pain typically starts around the umbilicus and then moves where?", new String[] { "Left lower quadrant", "Epigastrium", "Right lower quadrant (McBurney point)", "Right upper quadrant" }, 2, "Early visceral pain from the inflamed appendix is poorly localized and referred to the periumbilical area (T10). Once inflammation irritates the parietal peritoneum, pain localizes to the right lower quadrant at McBurney point, 1/3 of the way from the ASIS to the umbilicus.", "Starts vague at the belly button, then parks itself in the right lower quadrant. Rude, but predictable.");
  mcq("digestion-3-08", "Bile salts reabsorbed in the terminal ileum return to the liver by which route?", new String[] { "Thoracic duct", "Hepatic artery", "Inferior vena cava", "Portal vein (enterohepatic circulation)" }, 3, "About 95% of bile salts are reabsorbed in the terminal ileum, carried back to the liver in portal blood and re-secreted into bile: the enterohepatic circulation, which recycles the pool several times a day. Ileal disease breaks this loop and causes fat malabsorption.", "Your body recycles bile salts better than you've ever recycled anything. Embarrassing for you.");
  label("digestion-3-09", "digestive", "cecum", "Click the blind pouch where the ileum empties into the large intestine.", "The cecum is the first part of the large intestine, in the right lower quadrant. The ileum enters it through the ileocecal valve, and the appendix hangs from its posteromedial wall.", "Cecum. A dead-end pouch with a worm attached. Evolution's cul-de-sac.");
  label("digestion-3-10", "digestive", "appendix", "Click the structure classically inflamed when pain settles at McBurney point.", "The vermiform appendix is a narrow blind tube off the cecum, rich in lymphoid tissue. Obstruction (e.g. by a fecalith or lymphoid hyperplasia) leads to inflammation, appendicitis, with pain at McBurney point.", "The appendix. Tiny, full of lymphoid tissue, and occasionally tries to kill you. Like a Meeseeks with a grudge.");
  label("digestion-3-11", "digestive", "transverse_colon", "Click the segment of colon that crosses the upper abdomen on its own mesentery.", "The transverse colon runs from the hepatic flexure (right) to the splenic flexure (left), hung on the transverse mesocolon, so it's intraperitoneal and mobile. Proximal 2/3: SMA blood; distal 1/3: IMA blood.", "Transverse colon. Hangs across your belly like a hammock full of *burp* regrets.");
  label("digestion-3-12", "digestive", "descending_colon", "Click the colon segment that runs DOWN the left flank, fixed to the back wall.", "The descending colon runs down the left side from the splenic flexure to the sigmoid colon. Like the ascending colon, it's retroperitoneal; it's supplied by the inferior mesenteric artery.", "Descending colon. Left side, going down, stuck to the back wall. The name does the work, genius.");
  level(4);
  lesson("digestion-4-L1", "Peptic ulcer disease", "Ulcers: acid and pepsin beat mucosal defenses. Causes: H. pylori (urease makes ammonia to buffer acid) and NSAIDs (COX block -> less protective prostaglandin). Posterior duodenal ulcers can erode the gastroduodenal artery. Gastrinoma (Zollinger-Ellison): multiple, refractory or jejunal ulcers; gastrin RISES after IV secretin.", "A bacterium that survives an acid bath by brewing its own ammonia. H. pylori, you magnificent little weirdo.", "digestive", "duodenum");
  lesson("digestion-4-L2", "Malabsorption", "Celiac disease: gluten (gliadin) triggers immune attack; HLA-DQ2/DQ8; IgA anti-tissue transglutaminase. Biopsy: villous atrophy, crypt hyperplasia, intraepithelial lymphocytes, mostly distal duodenum/proximal jejunum. Linked to dermatitis herpetiformis, iron deficiency. Losing terminal ileum -> B12 deficiency, bile acid loss.", "Celiac: your immune system nukes your own villi over a slice of bread. *burp* Overreaction of the century.", "digestive", "small_intestine");
  lesson("digestion-4-L3", "Diarrhea: osmotic vs secretory", "Osmotic diarrhea (e.g. lactose intolerance): unabsorbed solute holds water in the gut; it stops with fasting; stool osmotic gap is high. Secretory diarrhea: active Cl- secretion; it persists while fasting; gap under about 50 mOsm/kg. Cholera toxin locks Gs on -> high cAMP -> CFTR opens -> Cl- and water pour out.", "Cholera floors the cAMP accelerator and your gut turns into a fire hose. Science is beautiful and disgusting.", "digestive", "small_intestine");
  lesson("digestion-4-L4", "Bilirubin and jaundice", "Heme -> biliverdin -> unconjugated bilirubin (on albumin). The liver conjugates it (UDP-glucuronosyltransferase, UGT) and excretes it in bile; gut bacteria make urobilinogen; stercobilin makes stool brown. Gilbert: mildly low UGT -> unconjugated jaundice on fasting or stress. Duct blockage: conjugated, dark urine, pale stool.", "Gilbert syndrome: you turn yellow when you skip lunch. Harmless. Embarrassing. Very you.", "digestive", "liver");
  mcq("digestion-4-01", "Recurrent ulcers, one in the jejunum, plus diarrhea. Serum gastrin RISES after IV secretin. Most likely diagnosis?", new String[] { "Gastrinoma (Zollinger-Ellison syndrome)", "H. pylori gastritis", "VIPoma", "Chronic NSAID use" }, 0, "Secretin normally suppresses gastrin release, but gastrinoma cells paradoxically release more. Excess gastrin drives huge acid output: multiple or jejunal ulcers, and diarrhea as acid inactivates pancreatic lipase. Tumors usually sit in the duodenum or pancreas; think MEN1.", "Gastrinoma. Secretin should shut gastrin up, and the tumor does the opposite. Rebellious little neoplasm.");
  mcq("digestion-4-02", "Iron-deficiency anemia, chronic diarrhea and itchy vesicles on the elbows. A duodenal biopsy most likely shows what?", new String[] { "Noncaseating granulomas", "Villous atrophy with crypt hyperplasia", "PAS-positive foamy macrophages", "Normal villi" }, 1, "Dermatitis herpetiformis plus malabsorption points to celiac disease: villous atrophy, crypt hyperplasia and intraepithelial lymphocytes. Iron deficiency follows duodenal damage (iron's main absorption site). Granulomas suggest Crohn disease; PAS+ macrophages, Whipple disease.", "Itchy elbows plus bad poop? Gluten. The villi got flattened like Jerry's ego.");
  mcq("digestion-4-03", "Cholera toxin causes massive watery diarrhea mainly by which mechanism?", new String[] { "Destroying the villi so nothing is absorbed", "ADP-ribosylating Gi (the pertussis toxin mechanism)", "ADP-ribosylating Gs: cAMP rises, CFTR secretes Cl-", "Blocking SGLT1 so glucose stays in the lumen" }, 2, "Cholera toxin locks Gs alpha in its active state, so adenylyl cyclase keeps making cAMP; PKA opens CFTR and Cl- (with Na+ and water) floods the lumen. The villi stay intact and SGLT1 still works, which is why oral glucose-salt rehydration saves lives.", "Gs stuck on, cAMP through the roof, CFTR wide open. The villi are fine, so sugar-salt water still gets absorbed.");
  mcq("digestion-4-04", "Which feature suggests OSMOTIC rather than secretory diarrhea?", new String[] { "Stool osmotic gap below 50 mOsm/kg", "Large-volume stools continue during a 48 h fast", "Caused by a toxin that raises enterocyte cAMP", "Diarrhea stops when the patient fasts" }, 3, "Osmotic diarrhea is driven by unabsorbed solute (lactose, sorbitol, magnesium), so it stops when intake stops, and the stool osmotic gap is high because of unmeasured solute. Secretory diarrhea comes from active ion secretion, persists while fasting and has a gap under about 50.", "Stop eating, diarrhea stops? Osmotic. Keeps going anyway? Secretory. Even a Meeseeks could solve this one.");
  mcq("digestion-4-05", "A newborn hasn't passed meconium by 48 h. Rectal suction biopsy shows no ganglion cells. What is the underlying cause?", new String[] { "CFTR mutation with thick, sticky meconium", "Failed migration of neural crest cells", "Hypertrophy of pyloric smooth muscle", "In-utero vascular accident causing atresia" }, 1, "Hirschsprung disease: neural crest cells fail to migrate down the gut, so the distal segment (always including the rectum) lacks Meissner and Auerbach plexuses, can't relax and acts as an obstruction. Linked to RET mutations and Down syndrome. CFTR mutations cause meconium ileus.", "No ganglion cells, no relaxation, no poop. The neural crest got lost on the way. Should've *burp* used a portal.");
  mcq("digestion-4-06", "After resection of the terminal ileum for Crohn disease, a patient is MOST at risk of which deficiency?", new String[] { "Iron", "Folate", "Vitamin B12", "Vitamin C" }, 2, "The terminal ileum is the only site of B12-intrinsic factor uptake and also reclaims bile acids. Losing it causes B12 deficiency, fat malabsorption and calcium oxalate stones (fat binds Ca2+, so free oxalate is absorbed). Iron is absorbed in the duodenum, folate in the jejunum.", "Cut out the ileum and B12 has no door to walk through. Megaloblastic anemia, here we come.");
  mcq("digestion-4-07", "A patient with a posterior duodenal ulcer vomits blood. Which artery has most likely been eroded?", new String[] { "Left gastric artery", "Splenic artery", "Superior mesenteric artery", "Gastroduodenal artery" }, 3, "The gastroduodenal artery runs right behind the first part of the duodenum, so a posterior duodenal ulcer can erode it and bleed massively. Ulcers on the lesser curvature of the stomach tend to erode the left gastric artery instead.", "Gastroduodenal artery. Sits right behind the duodenum, waiting for an ulcer to chew through. Location, location, location.");
  mcq("digestion-4-08", "A healthy 20-year-old gets mildly yellow when fasting or ill. Only unconjugated bilirubin is high; no hemolysis. Cause?", new String[] { "Mildly reduced UGT activity (Gilbert syndrome)", "Absent UGT activity (Crigler-Najjar type I)", "Defective excretion of conjugated bilirubin (Dubin-Johnson)", "Obstruction of the common bile duct" }, 0, "Gilbert syndrome is common and benign: reduced UDP-glucuronosyltransferase activity, so fasting, stress or illness causes mild unconjugated hyperbilirubinemia. Crigler-Najjar type I causes severe neonatal jaundice; Dubin-Johnson and duct obstruction raise CONJUGATED bilirubin.", "Gilbert. Skip lunch, turn yellow, panic, be totally fine. You're the *burp* Jerry of livers.");
  label("digestion-4-09", "digestive", "esophagus", "Click the organ where chronic acid reflux can cause Barrett metaplasia.", "In Barrett esophagus, chronic GERD replaces the distal esophagus's stratified squamous epithelium with intestinal-type columnar epithelium with goblet cells. It raises the risk of esophageal adenocarcinoma.", "Esophagus. Bathe it in acid long enough and it starts cosplaying as intestine. Then it flirts with cancer.");
  label("digestion-4-10", "digestive", "sigmoid_colon", "Click the segment most often affected by diverticulosis in Western adults.", "Diverticula are pouches of mucosa and submucosa pushed through weak spots where vessels pierce the muscle wall. High pressure inside the lumen (linked to low-fiber diets) makes the sigmoid colon the commonest site in Western countries.", "Sigmoid colon. Highest pressure, most blowouts. Low fiber turns it into *burp* bubble wrap.");
  label("digestion-4-11", "digestive", "rectum", "Click the segment that is ALWAYS involved in Hirschsprung disease.", "In Hirschsprung disease the aganglionic segment starts at the anal end and extends upward a variable distance, so the rectum is always involved; normal, dilated colon lies above it. Diagnosis is by rectal suction biopsy.", "The rectum. Hirschsprung always starts at the exit and works its way up. Worst traffic jam in the multiverse.");
  label("digestion-4-12", "digestive", "pancreas", "Click the organ whose head tumor causes painless jaundice with a palpable gallbladder.", "Carcinoma of the pancreatic head compresses the common bile duct, causing painless obstructive (conjugated) jaundice and an enlarged, nontender gallbladder (Courvoisier sign). Body and tail tumors present later.", "Pancreas head. Squeezes the bile duct, you turn yellow, the gallbladder balloons. Painless is not good news.");
}

void content_kidneys() {
  topic("kidneys", "KIDNEYS", "nephron", "organ_map");
  level(1);
  lesson("kidneys-1-L1", "Meet your kidneys", "You have two bean-shaped kidneys, each roughly fist-sized (about 11 cm long). They sit at the back of the upper abdomen, one on each side of the spine, partly shielded by the lower ribs. Their main job is to filter the blood, removing wastes (mainly urea) plus extra water and salt as urine.", "Two beans that clean your blood 24/7. They do more work in a day than you've done in your *burp* whole life.", "organ_map", "kidneys");
  lesson("kidneys-1-L2", "The urinary tract", "Urine made by the kidneys flows down two thin muscular tubes, the ureters, into the bladder, a stretchy muscular bag in the pelvis that stores it. When you urinate, it leaves through a single tube, the urethra. The urethra is much shorter in females, one reason bladder infections are more common in women.", "Kidney, ureter, bladder, urethra. Plumbing, Morty-brain. Ureter comes first, alphabetically AND anatomically.", "organ_map", "bladder");
  lesson("kidneys-1-L3", "Nephrons: the tiny filters", "Each kidney contains about a million nephrons, its microscopic working units. In each one, blood is filtered at the glomerulus, a tiny ball of capillaries, into a cup called Bowman's capsule. The fluid then flows through a long tubule that takes back what the body needs (water, glucose, salts) and leaves wastes behind.", "A million filters per kidney. Filter everything, then take back the good stuff. Wasteful? No, it's genius.", "nephron", "glomerulus");
  lesson("kidneys-1-L4", "More than plumbing", "Every day the kidneys filter about 180 L of fluid out of the blood but make only about 1-2 L of urine, because they reabsorb about 99% of it. They also balance salts and acid, help control blood pressure, make erythropoietin (EPO) to boost red blood cell production, and activate vitamin D.", "180 liters filtered, 99% taken back. Best recycling program in the known multiverse. Way better than the Citadel's.", "", "");
  mcq("kidneys-1-01", "What is the main job of the kidneys?", new String[] { "Filtering blood and making urine", "Digesting food", "Pumping blood", "Making bile" }, 0, "The kidneys filter the blood, removing wastes such as urea plus extra water and salts, which leave the body as urine. They also adjust blood volume, salt and acid levels. Digestion, pumping blood and making bile belong to other organs.", "Filter blood, make pee. That's the whole elevator pitch. Took you a full question to get there.");
  mcq("kidneys-1-02", "Which tubes carry urine from the kidneys to the bladder?", new String[] { "Urethra", "Ureters", "Renal veins", "Bile ducts" }, 1, "Each kidney has one ureter, a muscular tube about 25-30 cm long that moves urine to the bladder by peristalsis. The urethra is the single tube that carries urine from the bladder out of the body. Mixing them up is the classic mistake.", "Ureters, plural, kidney to bladder. Urethra, single, bladder to the outside world. Write it on your hand.");
  mcq("kidneys-1-03", "Where is urine stored until you urinate?", new String[] { "Kidneys", "Urethra", "Bladder", "Gallbladder" }, 2, "The urinary bladder is a hollow, stretchy muscular organ in the pelvis. Its wall muscle (the detrusor) relaxes as it fills and contracts to empty it. The gallbladder stores bile, not urine, despite the name.", "The bladder. Not the gallbladder, genius. One holds pee, one holds bile. Don't mix those up at a *burp* dinner party.");
  mcq("kidneys-1-04", "Where are the kidneys located?", new String[] { "Low in the front of the pelvis", "In the chest, just above the diaphragm", "Just behind the belly button, in front of the intestines", "At the back of the upper abdomen, either side of the spine" }, 3, "The kidneys lie against the back wall of the abdomen, roughly from the 12th thoracic to the 3rd lumbar vertebra, behind the peritoneum. The right one sits a little lower because the liver is above it. The bladder is the organ low in the pelvis.", "Back of your belly, either side of the spine. That's why a kidney punch hurts. Don't ask how *burp* I know.");
  mcq("kidneys-1-05", "What are the microscopic filtering units of the kidney called?", new String[] { "Neurons", "Nephrons", "Alveoli", "Villi" }, 1, "Each kidney has about a million nephrons. Each nephron has a glomerulus (the filter) plus a tubule that fine-tunes the fluid into urine. Neurons are nerve cells, alveoli are air sacs in the lungs and villi line the small intestine.", "Nephrons. 'Nephro' means kidney. Neurons are the things you're allegedly using right now.");
  mcq("kidneys-1-06", "What is the glomerulus?", new String[] { "A tiny ball of capillaries that filters blood", "The tube that carries urine out of the body", "A gland on top of the kidney", "A muscle that empties the bladder" }, 0, "The glomerulus is a knot of leaky capillaries inside Bowman's capsule. Blood pressure pushes water and small molecules out of these capillaries into the capsule, the first step in making urine. Blood cells and most proteins stay in the blood.", "A ball of capillaries working as a sieve. Biology invented the coffee filter before coffee existed.");
  mcq("kidneys-1-07", "Which waste, made from protein breakdown, is the main nitrogen waste in urine?", new String[] { "Glucose", "Cholesterol", "Urea", "Hemoglobin" }, 2, "When amino acids are broken down, their nitrogen becomes ammonia, which the liver converts into less toxic urea. The kidneys excrete the urea in urine. Glucose is normally kept in the blood; glucose in urine is a sign of disease such as diabetes.", "Urea. Your liver turns toxic ammonia into urea and your kidneys flush it. Teamwork. Unlike your group projects.");
  mcq("kidneys-1-08", "Which hormone do the kidneys make to boost red blood cell production?", new String[] { "Insulin", "Adrenaline", "Thyroxine", "Erythropoietin (EPO)" }, 3, "When kidney cells sense low O2 delivery, they release erythropoietin (EPO), which tells the bone marrow to make more red blood cells. That's why people with chronic kidney disease often become anemic.", "EPO. The same stuff cheating cyclists inject. Your kidneys are running a tiny doping lab.");
  label("kidneys-1-09", "organ_map", "kidneys", "Click the kidneys.", "The two bean-shaped kidneys sit against the back of the upper abdomen on either side of the spine. Together they filter about 180 L of fluid a day and turn about 1-2 L of it into urine.", "The kidneys. You've got two and can live with one. Doesn't mean you should gamble with either.");
  label("kidneys-1-10", "organ_map", "bladder", "Click the urinary bladder.", "The bladder sits low in the pelvis behind the pubic bone. It stores urine arriving from the ureters, and its detrusor muscle contracts to empty it through the urethra.", "Bladder. The holding tank. Its whole job is waiting until there's a bathroom. Respect the patience.");
  label("kidneys-1-11", "nephron", "glomerulus", "Click the glomerulus, the ball of capillaries that filters blood.", "The glomerulus is a tuft of capillaries inside Bowman's capsule. Blood pressure pushes plasma water and small solutes through its walls; blood cells and most proteins stay behind in the blood.", "Glomerulus. Fancy word for capillary ball. Say it three times and you'll *burp* sound like a doctor.");
  level(2);
  lesson("kidneys-2-L1", "Inside a kidney", "The kidney has an outer cortex (glomeruli and convoluted tubules) and an inner medulla of renal pyramids (loops of Henle and collecting ducts). Urine drains from each papilla into minor calyces -> major calyces -> renal pelvis -> ureter. The kidneys get about 20% of the cardiac output, roughly 1 L of blood per minute.", "Cortex outside, medulla inside, pelvis is the drain. A kidney is a fancy colander, Morty-brain.", "organ_map", "kidneys");
  lesson("kidneys-2-L2", "Filter, reabsorb, secrete", "Urine = filtration (glomerulus -> Bowman's capsule), reabsorption (tubule -> blood) and secretion (blood -> tubule). Normal GFR is about 125 mL/min (180 L/day). Filtrate is like plasma without most of its proteins. The proximal tubule reabsorbs about 2/3 of the filtered Na+ and water and normally all the glucose and amino acids.", "Filter, reabsorb, secrete. Three verbs. A Meeseeks could learn them, and it only lives for one task.", "nephron", "proximal_tubule");
  lesson("kidneys-2-L3", "Loop of Henle and ADH", "The loop of Henle makes the medulla salty: the descending limb lets water out but little salt; the thick ascending limb pumps NaCl out but is waterproof. With recycled urea, the deep medulla reaches about 1200 mOsm/kg. ADH (posterior pituitary) inserts aquaporin-2 into the collecting duct, so water exits into the salty medulla.", "Make the neighborhood salty, then open the water gates. Concentrated urine. That's how desert rats survive, genius.", "nephron", "ascending_limb");
  lesson("kidneys-2-L4", "Hormones that steer the kidney", "Aldosterone (adrenal cortex) makes the late distal tubule and collecting duct reabsorb Na+ and secrete K+. ADH saves water. When blood pressure falls, juxtaglomerular cells release renin, starting the renin-angiotensin-aldosterone system. ANP from stretched heart atria does the opposite: the kidney excretes more Na+ and water.", "Aldosterone hoards salt, ANP dumps it. Your hormones argue more than Beth and Jerry.", "nephron", "collecting_duct");
  mcq("kidneys-2-01", "What is a typical adult glomerular filtration rate (GFR)?", new String[] { "About 12 mL/min", "About 125 mL/min", "About 1.2 L/min", "About 5 L/min" }, 1, "GFR is about 125 mL/min, roughly 180 L per day. Renal blood flow is about 1-1.2 L/min and resting cardiac output about 5 L/min. A GFR around 12 mL/min would mean kidney failure.", "125 mL/min. 180 liters a day. Your whole plasma volume gets filtered about 60 times daily. *burp* Show-offs.");
  mcq("kidneys-2-02", "Which segment reabsorbs the largest share of filtered Na+ and water?", new String[] { "Proximal convoluted tubule", "Loop of Henle", "Distal convoluted tubule", "Collecting duct" }, 0, "The proximal tubule reabsorbs about 65% of filtered Na+ and water, plus essentially all glucose and amino acids and most bicarbonate. Its cells have a brush border and loads of mitochondria to power the Na+/K+ ATPase. Later segments fine-tune the rest.", "Proximal tubule. The workhorse. Does two-thirds of the job while the collecting duct takes the credit.");
  mcq("kidneys-2-03", "When blood pressure falls, what do the kidneys release to start the cascade that makes angiotensin II and aldosterone?", new String[] { "Erythropoietin (EPO)", "Renin", "Antidiuretic hormone (ADH)", "Atrial natriuretic peptide (ANP)" }, 1, "Juxtaglomerular cells in the afferent arteriole release renin when renal perfusion falls. Renin turns angiotensinogen into angiotensin I; ACE then makes angiotensin II, which constricts vessels and releases aldosterone. EPO drives red cell production; ANP opposes this system.", "Renin. The kidneys sense low pressure and pull the fire alarm. The whole RAAS conga line starts with them.");
  mcq("kidneys-2-04", "Which segment actively pumps NaCl out of the tubule but is impermeable to water?", new String[] { "Thin descending limb", "Collecting duct", "Proximal tubule", "Thick ascending limb" }, 3, "The thick ascending limb moves Na+, K+ and Cl- out with the NKCC2 cotransporter but has no water channels. That dilutes the tubular fluid and makes the medullary interstitium salty, the key to concentrating urine. The descending limb does the reverse: water out, little salt.", "Thick ascending limb: pumps salt, refuses water. Stubborn. Essential. Like me.");
  mcq("kidneys-2-05", "Which substance is freely filtered but normally fully reabsorbed, so urine has essentially none?", new String[] { "Urea", "Glucose", "Creatinine", "K+" }, 1, "Glucose is freely filtered, then the proximal tubule reabsorbs all of it with SGLT transporters. If blood glucose is so high that the transporters saturate (as in uncontrolled diabetes), glucose spills into the urine. Urea and creatinine are wastes that get excreted.", "Glucose. Your kidneys reabsorb every molecule. Sugar in urine means the system's overwhelmed. Diabetes, usually.");
  mcq("kidneys-2-06", "Which plasma component is normally almost entirely kept OUT of the glomerular filtrate?", new String[] { "Albumin", "Glucose", "Na+", "Urea" }, 0, "The glomerular filter holds back albumin mainly because of its size (close to the filter's cutoff), helped by its negative charge. Small solutes like glucose, Na+ and urea pass freely. Albumin in the urine (albuminuria) is an early sign of glomerular damage, e.g. from diabetes.", "Albumin's too big and too negative to get through. Like me at a family dinner.");
  mcq("kidneys-2-07", "Which adrenal cortex hormone increases Na+ reabsorption and K+ secretion in the kidney?", new String[] { "ADH", "ANP", "Epinephrine", "Aldosterone" }, 3, "Aldosterone, from the zona glomerulosa of the adrenal cortex, acts on principal cells of the late distal tubule and collecting duct: more Na+ channels and Na+/K+ ATPase, so more Na+ is reabsorbed and K+ secreted. High K+ and angiotensin II trigger its release.", "Aldosterone. Grab sodium, dump potassium. The salt-hoarding hormone. Pickle Rick runs on it.");
  mcq("kidneys-2-08", "After leaving the collecting ducts at the papillae, urine drains in which order?", new String[] { "Renal pelvis -> major calyx -> minor calyx -> ureter", "Major calyx -> minor calyx -> ureter -> renal pelvis", "Minor calyx -> major calyx -> renal pelvis -> ureter", "Minor calyx -> renal pelvis -> major calyx -> urethra" }, 2, "Collecting ducts open at the tip of each renal pyramid (papilla) into a minor calyx. Several minor calyces join into a major calyx, the major calyces merge into the funnel-shaped renal pelvis, and the pelvis narrows into the ureter.", "Minor, major, pelvis, ureter. Small pipes into big pipes. Even the sewer rats get this.");
  label("kidneys-2-09", "nephron", "bowmans_capsule", "Click Bowman's capsule, the cup that catches the filtrate.", "Bowman's capsule surrounds the glomerulus. Its inner layer is made of podocytes that wrap the capillaries; filtrate collects in Bowman's space and flows straight into the proximal tubule.", "Bowman's capsule. A cup catching whatever the glomerulus squeezes out. Named after a guy, not a bowling ball.");
  label("kidneys-2-10", "nephron", "proximal_tubule", "Click the segment that reabsorbs about two-thirds of the filtered Na+ and water.", "The proximal convoluted tubule follows Bowman's capsule. Its brush-border cells reabsorb about 65% of filtered Na+ and water, all the glucose and amino acids, and most bicarbonate.", "Proximal tubule. Two-thirds of the work, zero fame. The Morty of the nephron.");
  label("kidneys-2-11", "nephron", "collecting_duct", "Click the collecting duct, where ADH adjusts how much water is saved.", "Collecting ducts receive fluid from many nephrons and run through the medulla to the papillae. With ADH, aquaporins let water out into the salty medulla, so the urine becomes concentrated.", "Collecting duct. Final checkpoint. ADH decides here whether you pee a *burp* puddle or a thimble.");
  level(3);
  lesson("kidneys-3-L1", "What sets GFR", "GFR = Kf x [(P_GC - P_BS) - (pi_GC - pi_BS)]: glomerular capillary pressure pushes fluid out; Bowman's space pressure and plasma oncotic pressure oppose it. Afferent constriction lowers P_GC, GFR and RPF. Efferent constriction raises P_GC and GFR but lowers RPF, so filtration fraction (GFR/RPF, about 20%) rises.", "Squeeze the inlet, flow and filtration both drop. Squeeze the outlet, pressure builds. It's a *burp* garden hose, Morty-brain.", "nephron", "efferent_arteriole");
  lesson("kidneys-3-L2", "Clearance", "Clearance = (U x V) / P = plasma volume cleared of a substance per minute. Inulin is freely filtered and neither reabsorbed nor secreted, so its clearance equals GFR. Creatinine slightly overestimates GFR because a little is secreted. PAH is filtered and secreted almost completely, so its clearance estimates renal plasma flow.", "UV over P. Sounds like a sunscreen. It's the single most useful equation in renal physiology. Tattoo it somewhere.", "nephron", "glomerulus");
  lesson("kidneys-3-L3", "Transporters by segment", "PCT: Na+/H+ exchanger, SGLT for glucose, carbonic anhydrase to reclaim HCO3-. Thick ascending limb: NKCC2 (loop diuretic target); its lumen-positive voltage drives paracellular Ca2+ and Mg2+ reabsorption. DCT: Na+-Cl- cotransporter (thiazide target) and PTH-regulated Ca2+ reabsorption. Collecting duct: ENaC in principal cells.", "Every segment, its own transporter, its own drug. Learn the map now or cry on *burp* exam day.", "nephron", "ascending_limb");
  lesson("kidneys-3-L4", "Renin-angiotensin-aldosterone", "Juxtaglomerular cells in the afferent arteriole release renin when renal perfusion falls, sympathetic beta1 input rises or the macula densa senses low NaCl. Renin: angiotensinogen -> angiotensin I. ACE (mainly in lung capillaries) -> angiotensin II, which constricts arterioles, releases aldosterone and ADH and drives thirst.", "Liver makes the precursor, kidney cuts it, lungs finish it. A three-organ conspiracy to raise your blood pressure.", "nephron", "afferent_arteriole");
  mcq("kidneys-3-01", "Clearance of which substance equals GFR because it is freely filtered and neither reabsorbed nor secreted?", new String[] { "Creatinine", "PAH", "Inulin", "Glucose" }, 2, "Inulin, a plant polysaccharide, is freely filtered and untouched by the tubule, so its clearance equals GFR. Creatinine is slightly secreted (overestimates GFR); PAH is secreted (measures renal plasma flow); glucose is reabsorbed (clearance near 0).", "Inulin. Not insulin, genius. One letter different, completely different universe.");
  mcq("kidneys-3-02", "Constricting only the EFFERENT arteriole has what effect?", new String[] { "GFR down, RPF down, filtration fraction unchanged", "GFR up, RPF down, filtration fraction up", "GFR up, RPF up, filtration fraction unchanged", "GFR down, RPF up, filtration fraction down" }, 1, "Efferent constriction backs blood up in the glomerulus: P_GC and GFR rise while plasma flow through the kidney (RPF) falls, so FF = GFR/RPF increases. Afferent constriction lowers both GFR and RPF, leaving FF about the same.", "Pinch the exit, pressure builds upstream. GFR up, flow down. Plumbing 101, Morty-brain.");
  mcq("kidneys-3-03", "Furosemide and other loop diuretics inhibit which transporter?", new String[] { "Na+-Cl- cotransporter in the DCT", "ENaC in the collecting duct", "Carbonic anhydrase in the PCT", "Na+-K+-2Cl- cotransporter (NKCC2) in the thick ascending limb" }, 3, "Loop diuretics block NKCC2 in the thick ascending limb, so a large share of filtered NaCl escapes reabsorption and the medullary gradient collapses. The lumen-positive voltage is lost too, so Ca2+ and Mg2+ are wasted. Thiazides block the DCT's Na+-Cl- cotransporter.", "Loop diuretics act on the loop. The universe occasionally names things sensibly. Cherish it.");
  mcq("kidneys-3-04", "Which cells secrete renin?", new String[] { "Macula densa cells", "Juxtaglomerular (granular) cells of the afferent arteriole", "Podocytes", "Zona glomerulosa cells of the adrenal cortex" }, 1, "Renin comes from juxtaglomerular cells, modified smooth muscle cells in the afferent arteriole wall. The macula densa only SENSES NaCl in the tubule and signals the JG cells. The zona glomerulosa makes aldosterone, further down the cascade.", "JG cells release it, the macula densa just snitches. Macula densa never makes renin itself. It *burp* tattles.");
  mcq("kidneys-3-05", "Urine inulin is 30 mg/mL, plasma inulin 0.25 mg/mL and urine flow 1 mL/min. What is the GFR?", new String[] { "7.5 mL/min", "30 mL/min", "120 mL/min", "250 mL/min" }, 2, "Clearance = (U x V) / P = (30 mg/mL x 1 mL/min) / 0.25 mg/mL = 120 mL/min. Because inulin clearance equals GFR, the GFR is 120 mL/min, a normal value. 7.5 comes from multiplying by P instead of dividing.", "120. UV over P. If you got 7.5, you multiplied. Go stand in the corner of the multiverse.");
  mcq("kidneys-3-06", "What does angiotensin-converting enzyme (ACE) do?", new String[] { "Converts angiotensin I to angiotensin II", "Converts angiotensinogen to angiotensin I", "Converts angiotensin II to aldosterone", "Converts prorenin to renin" }, 0, "ACE, found mostly on lung capillary endothelium, converts angiotensin I to angiotensin II and also breaks down bradykinin (why ACE inhibitors can cause a dry cough). Renin makes angiotensin I from angiotensinogen; aldosterone is a steroid made by the adrenal cortex.", "ACE turns angiotensin I into II. Block it and bradykinin piles up. Cough, cough. *burp* Pardon me.");
  mcq("kidneys-3-07", "Parathyroid hormone increases Ca2+ reabsorption mainly in which segment?", new String[] { "Distal convoluted tubule", "Proximal convoluted tubule", "Thin descending limb", "Collecting duct" }, 0, "PTH boosts Ca2+ reabsorption in the distal convoluted tubule. In the proximal tubule it does something else: it inhibits phosphate reabsorption and activates 1-alpha-hydroxylase to make active vitamin D (calcitriol). Net result: blood Ca2+ up, phosphate down.", "PTH keeps calcium at the DCT and dumps phosphate at the PCT. 'Phosphate Trashing Hormone.' You're welcome.");
  mcq("kidneys-3-08", "Fluid leaving the thick ascending limb (entering the DCT) is normally:", new String[] { "Isotonic to plasma", "Hypertonic, about 1200 mOsm/kg", "Identical to the final urine", "Hypotonic, about 100 mOsm/kg" }, 3, "The thick ascending limb removes NaCl without water, so the fluid leaving it is dilute (about 100 mOsm/kg) whatever your hydration: it's the 'diluting segment'. Fluid at the hairpin tip is hypertonic. Final urine concentration depends on ADH in the collecting duct.", "Diluting segment. Always dilute coming out, no matter how dehydrated you are. Consistent. Unlike you.");
  label("kidneys-3-09", "nephron", "afferent_arteriole", "Click the vessel that carries blood INTO the glomerulus and contains the renin-secreting cells.", "The afferent arteriole delivers blood to the glomerulus. Its wall holds juxtaglomerular cells that secrete renin. Dilating it raises glomerular pressure and GFR; constricting it lowers both GFR and RPF.", "Afferent: Arrives. Efferent: Exits. A before E, in the alphabet and in the blood. Mnemonics, people.");
  label("kidneys-3-10", "nephron", "efferent_arteriole", "Click the vessel draining the glomerulus, which angiotensin II preferentially constricts.", "The efferent arteriole carries blood out of the glomerulus into the peritubular capillaries and vasa recta. Angiotensin II constricts it more than the afferent, raising glomerular pressure to protect GFR when perfusion is low.", "Efferent arteriole. The exit door. Angiotensin II narrows it so the glomerulus keeps its pressure. Clever hack.");
  label("kidneys-3-11", "nephron", "descending_limb", "Click the limb of the loop of Henle that is permeable to water but not to NaCl.", "The thin descending limb has aquaporin-1 water channels but low NaCl permeability. As it dips into the salty medulla, water leaves by osmosis and the tubular fluid becomes more and more concentrated toward the hairpin.", "Descending limb. Lets water out, keeps salt in. By the bottom it's brine. Pickle Rick approves.");
  label("kidneys-3-12", "nephron", "ascending_limb", "Click the segment where loop diuretics block NKCC2.", "The thick part of the ascending limb reabsorbs Na+, K+ and 2 Cl- through NKCC2 while staying impermeable to water. Blocking NKCC2 with furosemide wipes out the medullary gradient and causes a strong diuresis.", "Ascending limb. Salt pump, waterproof. Shut it down with furosemide and you pee like a broken fire hydrant.");
  level(4);
  lesson("kidneys-4-L1", "Diuretics: site and side effects", "Acetazolamide (PCT carbonic anhydrase): normal anion gap metabolic acidosis. Loop diuretics (NKCC2): hypokalemic metabolic alkalosis, Ca2+ loss. Thiazides (DCT Na+-Cl- cotransporter): hypokalemic alkalosis but Ca2+ retention. Spironolactone (aldosterone receptor) and amiloride (ENaC): K+-sparing; risk hyperkalemia and acidosis.", "Loops lose calcium, thiazides keep it. Memorize that or I'll replace you with a *burp* Meeseeks.", "nephron", "distal_tubule");
  lesson("kidneys-4-L2", "Nephrotic vs nephritic", "Nephrotic: podocyte damage -> proteinuria >3.5 g/day, low albumin, edema, hyperlipidemia, fatty casts. Kids: usually minimal change disease (normal light microscopy, effaced foot processes on EM, steroid-responsive). Nephritic: inflamed glomeruli -> hematuria with RBC casts, hypertension, oliguria; e.g. post-strep GN (low C3).", "Nephrotic: protein pours out. Nephritic: blood and inflammation. One letter apart, two different disasters.", "nephron", "glomerulus");
  lesson("kidneys-4-L3", "Water balance gone wrong", "Central diabetes insipidus (DI): no ADH; dilute polyuria; desmopressin works. Nephrogenic DI: collecting duct ignores ADH (lithium, hypercalcemia); desmopressin fails. SIADH: excess ADH (e.g. small cell lung cancer) -> euvolemic hyponatremia, inappropriately concentrated urine. Primary polydipsia: dilute urine, low-normal Na+.", "No ADH, deaf to ADH, or way too much ADH. Three ways to screw up one *burp* hormone. Impressive.", "nephron", "collecting_duct");
  lesson("kidneys-4-L4", "Angiotensin II protects GFR", "When renal perfusion falls, angiotensin II constricts the efferent arteriole to hold glomerular pressure and GFR up, while prostaglandins dilate the afferent arteriole. So ACE inhibitors or ARBs can cause acute kidney injury in bilateral renal artery stenosis, and NSAIDs can do the same in a volume-depleted patient.", "Take away the efferent squeeze and GFR craters. ACE inhibitors: great drug, wrong patient.", "nephron", "efferent_arteriole");
  mcq("kidneys-4-01", "A patient on high-dose furosemide is most likely to develop which acid-base and K+ pattern?", new String[] { "Hyperkalemic metabolic acidosis", "Hypokalemic metabolic alkalosis", "Normal anion gap metabolic acidosis", "Respiratory alkalosis with normal K+" }, 1, "More Na+ reaches the collecting duct and volume loss activates aldosterone, so K+ and H+ are secreted: hypokalemia with metabolic alkalosis (plus contraction alkalosis). Hyperkalemic acidosis fits K+-sparing diuretics; normal anion gap acidosis fits acetazolamide.", "Furosemide flushes K+ and H+. Low potassium, high pH. Two problems for the price of one.");
  mcq("kidneys-4-02", "A patient has recurrent calcium kidney stones from idiopathic hypercalciuria. Which diuretic LOWERS urinary Ca2+?", new String[] { "Furosemide", "Acetazolamide", "Hydrochlorothiazide", "Mannitol" }, 2, "Thiazides block the DCT Na+-Cl- cotransporter; lower Na+ inside the cell speeds basolateral Na+/Ca2+ exchange, so more Ca2+ is reabsorbed and urinary Ca2+ falls. Loop diuretics do the opposite. Acetazolamide alkalinizes the urine, favoring calcium phosphate stones.", "Thiazides hold on to calcium. Loops throw it away. Pick wrong and you're farming kidney stones.");
  mcq("kidneys-4-03", "A 4-year-old has periorbital edema, heavy proteinuria and low albumin. Biopsy light microscopy is normal. What does EM show?", new String[] { "Effacement of podocyte foot processes", "Subepithelial humps", "Spike-and-dome basement membrane", "Split, basket-weave basement membrane" }, 0, "Minimal change disease, the commonest cause of nephrotic syndrome in children, looks normal on light microscopy; EM shows effaced (flattened) podocyte foot processes. It usually responds to corticosteroids. Humps: post-strep GN; spike-and-dome: membranous; basket-weave: Alport.", "Normal under light, wrecked under EM. Minimal change: minimal on the slide, not minimal for the kid.");
  mcq("kidneys-4-04", "A 7-year-old has cola-colored urine, hypertension and puffy eyes 2 weeks after strep throat. Which urine finding is typical?", new String[] { "Fatty casts (oval fat bodies)", "WBC casts", "Muddy brown granular casts", "RBC casts" }, 3, "Post-streptococcal glomerulonephritis is a nephritic syndrome: immune complexes inflame the glomeruli, red cells leak and form RBC casts in the tubules; C3 is low. Fatty casts suggest nephrotic syndrome, WBC casts pyelonephritis or interstitial nephritis, muddy brown casts ATN.", "RBC casts: red cells molded inside the tubules. Proof the bleeding started up in the *burp* glomerulus.");
  mcq("kidneys-4-05", "A man on long-term lithium has polyuria with dilute urine. After desmopressin the urine stays dilute. What is the defect?", new String[] { "No ADH release from the posterior pituitary", "Excess ADH secretion", "Collecting duct cells unresponsive to ADH", "Excess water drinking with normal ADH action" }, 2, "Lithium enters principal cells through ENaC and disrupts ADH (V2 receptor) signaling and aquaporin-2 expression: nephrogenic diabetes insipidus. Since the problem is the kidney's response, desmopressin (an ADH analog) doesn't concentrate the urine; in central DI it would.", "The kidney's ignoring ADH. Shout desmopressin at it all day, nothing. Lithium made it deaf.");
  mcq("kidneys-4-06", "A woman drinks about 10 L of water a day. Na+ 134 mEq/L, urine 70 mOsm/kg. After water restriction her urine rises to 600 mOsm/kg. Diagnosis?", new String[] { "Central diabetes insipidus", "Nephrogenic diabetes insipidus", "Primary polydipsia", "SIADH" }, 2, "Primary polydipsia: heavy drinking suppresses ADH, so urine is maximally dilute and Na+ is low-normal. ADH release and the kidney's response are intact, so urine concentrates once intake stops. In DI urine stays dilute despite restriction; SIADH makes concentrated urine.", "Her kidneys are fine; her drinking habit isn't. Turn off the tap and the urine concentrates. *burp* Case closed.");
  mcq("kidneys-4-07", "A climber takes acetazolamide to prevent altitude sickness. Which acid-base disturbance does it cause?", new String[] { "Hypokalemic metabolic alkalosis", "Normal anion gap (hyperchloremic) metabolic acidosis", "High anion gap metabolic acidosis", "Respiratory acidosis" }, 1, "Blocking proximal tubule carbonic anhydrase stops HCO3- reabsorption, so HCO3- is lost in urine and Cl- rises: a normal anion gap metabolic acidosis. No unmeasured anion is added, so the gap stays normal. The acidosis drives breathing, which helps at altitude.", "Dump bicarbonate, blood goes acidic, you breathe harder up the mountain. Chemistry beats altitude.");
  mcq("kidneys-4-08", "A man with bilateral renal artery stenosis starts an ACE inhibitor and his creatinine jumps. Main mechanism?", new String[] { "Afferent arteriole constriction", "Direct toxic injury to podocytes", "Increased renin release", "Loss of angiotensin II constriction of the efferent arteriole" }, 3, "With low renal perfusion, GFR depends on angiotensin II squeezing the efferent arteriole to keep glomerular pressure up. An ACE inhibitor removes that squeeze, so glomerular pressure and GFR fall and creatinine rises. Renin does rise on ACE inhibitors, but that doesn't lower GFR.", "No angiotensin II, no efferent squeeze, no filtration pressure. Your kidney just *burp* gave up. Physics wins.");
  label("kidneys-4-09", "nephron", "macula_densa", "Click the cells that sense tubular NaCl and drive tubuloglomerular feedback.", "The macula densa is a plaque of cells at the end of the thick ascending limb where it touches its own glomerulus's arterioles. High NaCl delivery -> afferent constriction (GFR falls); low NaCl -> afferent dilation and renin release.", "Macula densa. A salt sensor bolted onto its own glomerulus. Self-regulating plumbing. I'm almost impressed.");
  label("kidneys-4-10", "nephron", "distal_tubule", "Click the segment where thiazides block the Na+-Cl- cotransporter.", "The distal convoluted tubule reabsorbs NaCl via the Na+-Cl- cotransporter (NCC), the thiazide target, and Ca2+ under PTH control. Its early part is water-impermeable, so it dilutes the tubular fluid further.", "DCT. Thiazides hit here, and PTH saves your calcium here. Small segment, huge exam yield.");
  label("kidneys-4-11", "nephron", "collecting_duct", "Click where ADH inserts aquaporin-2, the site lithium makes deaf to ADH.", "Principal cells of the collecting duct insert aquaporin-2 under ADH (V2 receptors) and reabsorb Na+ via ENaC under aldosterone; intercalated cells secrete H+ or HCO3-. Lithium blunts the ADH response: nephrogenic DI.", "Collecting duct. ADH's turf. Lithium makes it deaf and you pee buckets.");
  label("kidneys-4-12", "nephron", "proximal_tubule", "Click the segment where acetazolamide acts and all filtered glucose is reabsorbed.", "The proximal convoluted tubule reclaims about 80% of filtered HCO3- using carbonic anhydrase (blocked by acetazolamide) plus all glucose via SGLT2 and SGLT1. Generalized PCT failure is called Fanconi syndrome.", "Proximal tubule. Glucose, amino acids, bicarb, all reclaimed. Break it and you get Fanconi: *burp* everything leaks.");
}

void content_hormones() {
  topic("hormones", "HORMONES", "organ_map");
  level(1);
  lesson("hormones-1-L1", "Chemical messengers", "Hormones are chemical messengers made by endocrine glands and released into the blood. They travel everywhere, but only cells with the matching receptor respond. Hormones act more slowly than nerve signals, but their effects usually last longer. Main glands: pituitary, thyroid, adrenal glands, pancreas, ovaries or testes.", "Hormones are spam mail through the blood. Only cells with the right receptor bother to open it.", "", "");
  lesson("hormones-1-L2", "The master gland", "The pituitary is a pea-sized gland hanging below the brain. It is called the master gland because its hormones control other glands, like the thyroid and adrenals. It also makes growth hormone, which drives growth in childhood. The pituitary itself takes orders from the hypothalamus, a brain area just above it.", "The pituitary bosses everyone around but takes orders from the hypothalamus. Middle management. *burp* Classic.", "organ_map", "pituitary");
  lesson("hormones-1-L3", "Thyroid and adrenals", "The butterfly-shaped thyroid in the front of the neck makes thyroid hormone, which sets your metabolic rate (how fast cells burn energy); it needs iodine. The adrenal glands sit on top of the kidneys. They make adrenaline (epinephrine) for fight or flight, and cortisol, a stress hormone.", "Thyroid sets your metabolic speed. Yours idles at sloth. Adrenals sit on the kidneys like little party hats.", "organ_map", "thyroid");
  lesson("hormones-1-L4", "Sugar and sex hormones", "The pancreas makes insulin, which lowers blood sugar by helping cells take in glucose, and glucagon, which raises it. Diabetes mellitus means high blood sugar: type 1 = little or no insulin made; type 2 = cells respond poorly to insulin and the pancreas can't keep up. Testes make testosterone; ovaries, estrogen and progesterone.", "Insulin puts sugar away, glucagon pulls it back out. Teamwork. Something you've never experienced.", "organ_map", "pancreas");
  mcq("hormones-1-01", "How do most hormones travel from their gland to their target cells?", new String[] { "Along nerve fibers", "Through the blood", "Through the digestive tract", "Through the air in the lungs" }, 1, "Endocrine glands release hormones into the bloodstream, which carries them throughout the body. Only cells with the matching receptor respond. Nerve signals, by contrast, travel along nerve fibers.", "Through the blood. It's called the circulatory system, genius. It circulates.");
  mcq("hormones-1-02", "Which hormone lowers blood sugar?", new String[] { "Glucagon", "Adrenaline (epinephrine)", "Insulin", "Cortisol" }, 2, "Insulin from the pancreas helps cells take up and store glucose, lowering blood sugar. Glucagon, adrenaline and cortisol all RAISE blood sugar.", "Insulin, the main sugar-lowering hormone. The other three raise it. Like you raise my *burp* blood pressure.");
  mcq("hormones-1-03", "Which gland is nicknamed the master gland?", new String[] { "Pituitary gland", "Thyroid gland", "Adrenal gland", "Pancreas" }, 0, "The pituitary releases hormones that control other glands, such as TSH for the thyroid and ACTH for the adrenal cortex. It is itself controlled by the hypothalamus.", "Pituitary. Pea-sized, runs the show. Proof that size isn't everything, Morty-brain.");
  mcq("hormones-1-04", "Which mineral is needed to make thyroid hormone?", new String[] { "Iron", "Calcium", "Potassium", "Iodine" }, 3, "Thyroid hormones T4 and T3 contain 4 and 3 iodine atoms. Too little dietary iodine can cause hypothyroidism and an enlarged thyroid (goiter), which is why table salt is often iodized.", "Iodine. The 4 and 3 in T4 and T3 literally count iodines. It's in the *burp* NAME.");
  mcq("hormones-1-05", "In a scary situation your adrenal glands release adrenaline. What does it do?", new String[] { "Makes you sleepy and slows your heart", "Lowers your blood sugar for storage", "Raises heart rate and readies you for action", "Slows your breathing to save oxygen" }, 2, "Adrenaline (epinephrine) drives the fight-or-flight response: faster and stronger heartbeat, wider airways, and more glucose in the blood for energy.", "Fight or flight. Heart races, sugar spikes. My natural state, thanks to the Galactic Federation and you.");
  mcq("hormones-1-06", "Where are the adrenal glands?", new String[] { "On top of the kidneys", "In the front of the neck", "At the base of the brain", "Inside the pancreas" }, 0, "Ad-renal means 'near the kidney': one adrenal gland sits on top of each kidney. The thyroid is in the neck and the pituitary at the base of the brain.", "Ad-renal. Near the kidney. Latin did the work for you and you STILL needed a quiz.");
  mcq("hormones-1-07", "Which hormone drives bone and muscle growth in children?", new String[] { "Melatonin", "Glucagon", "Antidiuretic hormone", "Growth hormone" }, 3, "Growth hormone from the pituitary promotes growth of bones and muscles, largely through IGF-1 made in the liver. Melatonin regulates sleep, glucagon raises blood sugar and ADH saves water.", "Growth hormone. Named after what it does. A rare courtesy from scientists. Not from me, though.");
  mcq("hormones-1-08", "What causes type 1 diabetes?", new String[] { "The pancreas makes too much insulin", "The pancreas makes little or no insulin", "The thyroid makes too little hormone", "Eating too much salt" }, 1, "In type 1 diabetes the immune system destroys the insulin-making beta cells of the pancreas, so insulin is lacking and blood sugar rises. In type 2 the body still makes insulin but responds poorly to it.", "Type 1: no insulin factory. Type 2: factory's fine, customers ignore the product. Got it?");
  label("hormones-1-09", "organ_map", "pituitary", "Click the pituitary gland.", "The pituitary hangs below the brain, just beneath the hypothalamus, in a bony pocket of the skull. It controls many other glands.", "Little pea under the brain. Clicked the whole brain? Close, but no *burp* Szechuan sauce for you.");
  label("hormones-1-10", "organ_map", "thyroid", "Click the thyroid gland.", "The thyroid is the butterfly-shaped gland in the front of the neck, below the larynx (Adam's apple). It makes thyroid hormone, which sets metabolic rate.", "Butterfly in the neck. Not the thymus, that's lower in the chest. T-words: still your nemesis.");
  label("hormones-1-11", "organ_map", "pancreas", "Click the organ that makes insulin.", "The pancreas lies behind the stomach. Clusters of cells called islets of Langerhans release insulin and glucagon straight into the blood.", "Pancreas, behind the stomach. Half digestion, half hormones. A multitasker. Try it sometime.");
  level(2);
  lesson("hormones-2-L1", "Hypothalamus and pituitary", "The hypothalamus controls the pituitary. The anterior pituitary makes GH, TSH, ACTH, FSH, LH and prolactin. The posterior pituitary releases two hormones made by hypothalamic neurons: ADH (antidiuretic hormone, makes the kidneys save water) and oxytocin (uterine contractions in labor, milk let-down).", "Anterior makes its own stuff, posterior just stores the hypothalamus's stuff. Glorified *burp* storage unit.", "organ_map", "pituitary");
  lesson("hormones-2-L2", "Feedback loops", "Most hormones are controlled by negative feedback, like a thermostat. Example: hypothalamus TRH -> pituitary TSH -> thyroid T4 and T3. When T4/T3 rise, they inhibit TRH and TSH release, so output drops. Positive feedback is rarer: during labor, oxytocin drives contractions that trigger even more oxytocin.", "Negative feedback: the system shuts itself up when it's had enough. Try it sometime.", "", "");
  lesson("hormones-2-L3", "Steroid vs peptide hormones", "Peptide hormones (insulin, glucagon, ADH) are water-soluble and bind cell-surface receptors, many working via second messengers like cAMP. Steroid hormones (cortisol, aldosterone, estrogen, testosterone) are made from cholesterol, cross the membrane and bind receptors inside the cell to change gene transcription.", "Peptides ring the doorbell. Steroids walk right in and rewrite your DNA's to-do list. Rude, but effective.", "", "");
  lesson("hormones-2-L4", "Adrenals, kidneys and calcium", "Adrenal cortex: aldosterone (kidneys keep Na+, excrete K+) and cortisol (stress, raises glucose). Adrenal medulla: epinephrine and norepinephrine. Kidneys release EPO, which boosts red blood cell production, and renin. Parathyroid hormone (PTH) raises blood Ca2+; calcitonin from the thyroid lowers it.", "PTH pulls calcium up, calcitonin tones it down. Like me and my liver: opposing forces.", "organ_map", "adrenal_glands");
  mcq("hormones-2-01", "Which hormone is released from the POSTERIOR pituitary?", new String[] { "TSH", "Growth hormone", "Oxytocin", "Prolactin" }, 2, "The posterior pituitary releases oxytocin and ADH, both made by neurons in the hypothalamus. TSH, growth hormone and prolactin are made by the anterior pituitary.", "Posterior: oxytocin and ADH. That's it. Two. Like your functioning *burp* brain cells.");
  mcq("hormones-2-02", "Which hormone makes the kidneys reabsorb more water, producing concentrated urine?", new String[] { "ADH (vasopressin)", "Oxytocin", "Calcitonin", "Glucagon" }, 0, "ADH (vasopressin) makes the collecting ducts permeable to water, so more water returns to the blood and urine becomes concentrated. Alcohol suppresses ADH, which is why drinking makes you urinate more.", "ADH: anti-diuretic, anti-peeing. Booze blocks it. I've done extensive personal research.");
  mcq("hormones-2-03", "High blood levels of T4 and T3 normally cause:", new String[] { "Increased TSH secretion", "Increased TRH secretion", "Increased iodine uptake by the thyroid", "Decreased TSH secretion" }, 3, "Thyroid hormone feeds back negatively on the hypothalamus and anterior pituitary, lowering TRH and TSH. Less TSH means less stimulation of the thyroid, so output falls back toward normal.", "High T4, low TSH. The thermostat turns the heater off. Basic household appliance logic.");
  mcq("hormones-2-04", "Steroid hormones such as cortisol and estrogen are made from:", new String[] { "Chains of amino acids", "Cholesterol", "Glucose", "Iodinated tyrosine" }, 1, "All steroid hormones (cortisol, aldosterone, estrogen, progesterone, testosterone) are built from cholesterol. Peptide hormones are amino-acid chains, and thyroid hormone is made from iodinated tyrosine.", "Cholesterol. That greasy stuff is the raw material for your whole hormonal personality.");
  mcq("hormones-2-05", "How do peptide hormones like glucagon usually act on target cells?", new String[] { "Bind a surface receptor, often triggering a second messenger", "Enter the nucleus and bind DNA directly", "Dissolve through the membrane into the cytoplasm", "Get broken down inside the cell to make ATP" }, 0, "Peptide hormones are water-soluble and can't cross the lipid membrane, so they bind cell-surface receptors; many then activate second messengers such as cAMP. Steroid and thyroid hormones act on intracellular receptors.", "Peptides can't pass the greasy membrane, so they knock. The second messenger opens the door.");
  mcq("hormones-2-06", "Which hormone RAISES blood calcium?", new String[] { "Calcitonin", "Antidiuretic hormone (ADH)", "Aldosterone", "Parathyroid hormone (PTH)" }, 3, "PTH from the parathyroid glands raises blood Ca2+ by releasing it from bone, saving it in the kidney and activating vitamin D. Calcitonin from thyroid C cells has the opposite, weaker effect.", "PTH raises calcium. Calcitonin TONES it down. The name is literally a hint. Read the names!");
  mcq("hormones-2-07", "Erythropoietin (EPO) from the kidneys stimulates:", new String[] { "Platelet production", "Red blood cell production", "Stomach acid secretion", "Urine production" }, 1, "When O2 delivery to the kidney drops (anemia, high altitude), kidney cells release EPO, which tells the bone marrow to make more red blood cells. Platelet production is driven mainly by thrombopoietin from the liver.", "EPO: more red cells. Cyclists cheat with it. I just portal to a universe where I already won.");
  mcq("hormones-2-08", "Which is a classic example of POSITIVE feedback in the endocrine system?", new String[] { "High T4 and T3 lowering TSH secretion", "Oxytocin release during labor contractions", "High blood glucose triggering insulin release", "High blood Ca2+ suppressing PTH release" }, 1, "In labor, the baby pressing on the cervix triggers oxytocin release; oxytocin strengthens contractions, which press harder and release more oxytocin, until delivery ends the loop. The other three are negative feedback: the response switches off its own trigger.", "Positive feedback: a loop that floors it until something gives. Usually a baby. Rarely a good *burp* idea otherwise.");
  label("hormones-2-09", "organ_map", "adrenal_glands", "Click the glands that make cortisol and aldosterone.", "The adrenal glands sit on top of the kidneys. Their outer cortex makes cortisol, aldosterone and androgens; the inner medulla makes epinephrine and norepinephrine.", "On top of the kidneys. Two tiny hats full of stress juice. Very *burp* fashionable.");
  label("hormones-2-10", "organ_map", "kidneys", "Click the organ that makes most of the body's erythropoietin (EPO).", "Specialized cells in the kidney cortex make most adult EPO (roughly 90%) when O2 delivery falls; the liver makes the rest. That's why chronic kidney disease often causes anemia.", "Kidneys. Not just pee machines. Kidney failure, then anemia. Connect the dots, Morty-brain.");
  label("hormones-2-11", "organ_map", "thyroid", "Click the gland that makes calcitonin.", "Calcitonin comes from the parafollicular (C) cells of the thyroid. It lowers blood Ca2+ by inhibiting bone resorption, but in adult humans it plays only a minor role.", "Thyroid again, different cells. C cells, C for calcitonin. Mnemonics this easy should be illegal.");
  level(3);
  lesson("hormones-3-L1", "Making thyroid hormone", "Thyroid follicular cells take up iodide via a Na+/I- symporter. Thyroid peroxidase oxidizes it, attaches it to tyrosines on thyroglobulin and couples them into T4 (mostly) and T3. Tissues convert T4 to the more active T3 with deiodinases. T3 raises metabolic rate and heat production and sensitizes the heart to catecholamines.", "T4 is the prohormone, T3 does the real work. Like you and your *burp* lab partner.", "organ_map", "thyroid");
  lesson("hormones-3-L2", "The adrenal cortex zones", "Outside to inside: zona glomerulosa makes aldosterone (driven by angiotensin II and high K+); zona fasciculata makes cortisol (driven by ACTH); zona reticularis makes androgens such as DHEA. Mnemonic: salt, sugar, sex. The medulla's chromaffin cells make catecholamines, mostly epinephrine.", "Glomerulosa, fasciculata, reticularis: G-F-R, like the kidney. Salt, sugar, sex. Memorize or perish.", "organ_map", "adrenal_glands");
  lesson("hormones-3-L3", "Insulin, glucagon, cortisol", "In beta cells, glucose is metabolized, ATP rises, ATP-sensitive K+ channels close, the cell depolarizes, Ca2+ enters and insulin is released. Insulin moves GLUT4 into muscle and fat cell membranes. Alpha cells make glucagon. Cortisol raises glucose (gluconeogenesis), breaks down muscle protein and suppresses immunity.", "Close the K+ channel, out comes insulin. Sulfonylurea drugs do exactly that. Pharmacology's just cheating.", "organ_map", "pancreas");
  lesson("hormones-3-L4", "Hormones from surprise organs", "Heart: stretched atria release ANP -> Na+ excretion, vasodilation. Kidney: renin, EPO, and calcitriol (active vitamin D, via 1-alpha-hydroxylase). Liver: IGF-1 in response to GH. Stomach: gastrin (G cells) and ghrelin (hunger). Small intestine: secretin, CCK, GIP. Fat tissue: leptin (satiety).", "Everything's a gland if you're desperate enough. The heart makes hormones. Even your fat has opinions.", "organ_map", "heart");
  mcq("hormones-3-01", "Which enzyme oxidizes iodide and attaches it to tyrosines on thyroglobulin?", new String[] { "Thyroid peroxidase", "Deiodinase", "Tyrosine kinase", "1-alpha-hydroxylase" }, 0, "Thyroid peroxidase (TPO) oxidizes iodide, iodinates tyrosine residues and couples them into T3 and T4. Deiodinases work in tissues, converting T4 to T3. Anti-TPO antibodies are typical of Hashimoto thyroiditis.", "TPO. Drugs like methimazole block it and the factory stalls. Pharmacology bonus, *burp* free of charge.");
  mcq("hormones-3-02", "Graves disease causes hyperthyroidism because of antibodies that:", new String[] { "Destroy thyroid peroxidase", "Block the TSH receptor", "Neutralize circulating T4", "Stimulate the TSH receptor" }, 3, "In Graves disease IgG antibodies mimic TSH and switch on the TSH receptor, driving hormone production and gland growth while real TSH is suppressed. Anti-TPO antibodies are typical of Hashimoto, which causes HYPOthyroidism.", "Antibodies cosplaying as TSH. The thyroid can't tell. Neither could you, apparently.");
  mcq("hormones-3-03", "Which zone of the adrenal cortex makes aldosterone?", new String[] { "Zona fasciculata", "Zona glomerulosa", "Zona reticularis", "Adrenal medulla" }, 1, "The zona glomerulosa, the outermost layer, makes aldosterone. Zona fasciculata makes cortisol, zona reticularis makes androgens, and the medulla makes catecholamines.", "Outermost layer, salt hormone. Salt, sugar, sex, outside in. I gave you the mnemonic. Use it.");
  mcq("hormones-3-04", "What is the main stimulus for cortisol secretion?", new String[] { "Angiotensin II", "TSH", "ACTH", "High plasma K+" }, 2, "ACTH from the anterior pituitary drives cortisol release from the zona fasciculata. Angiotensin II and high K+ are the main drivers of aldosterone, not cortisol.", "ACTH: adrenocorticotropic hormone. Adrenal and cortex, right in the name. Read the label.");
  mcq("hormones-3-05", "In pancreatic beta cells, how does rising glucose trigger insulin release?", new String[] { "More ATP opens K+(ATP) channels, hyperpolarizing the cell", "Glucose binds a surface receptor that raises cAMP", "Glucose directly fuses insulin vesicles with the membrane", "More ATP closes K+(ATP) channels, depolarizing the cell" }, 3, "Glucose enters the beta cell and is metabolized; ATP rises and closes ATP-sensitive K+ channels. The cell depolarizes, voltage-gated Ca2+ channels open, and Ca2+ triggers insulin exocytosis. Sulfonylureas close the same channels.", "Close K+ channels, depolarize, calcium, insulin. A domino chain even a Meeseeks could follow.");
  mcq("hormones-3-06", "Insulin increases glucose uptake into skeletal muscle and fat mainly by:", new String[] { "Moving GLUT2 transporters into the cell membrane", "Moving GLUT4 transporters into the cell membrane", "Activating SGLT1 Na+-glucose cotransporters", "Increasing gluconeogenesis in those cells" }, 1, "Insulin signaling moves GLUT4 from intracellular vesicles to the membrane of muscle and fat cells. GLUT2 (liver, gut, kidney) works without insulin, and SGLT1 absorbs glucose in the small intestine.", "GLUT4, the insulin-sensitive one. Exercise moves it too, by the way. Not that you'd *burp* know.");
  mcq("hormones-3-07", "Atrial natriuretic peptide (ANP) is released in response to:", new String[] { "Low blood volume sensed by the kidneys", "High blood glucose after a meal", "Stretch of the atria from high blood volume", "Low plasma Ca2+ sensed by the parathyroids" }, 2, "Volume overload stretches the atrial walls, and atrial muscle cells release ANP. It increases Na+ and water excretion, dilates vessels and opposes the renin-angiotensin-aldosterone system.", "Heart gets overstretched, tells the kidneys to dump salt. Smartest thing in your chest, honestly.");
  mcq("hormones-3-08", "Which is a typical effect of cortisol?", new String[] { "Increased gluconeogenesis in the liver", "Increased lymphocyte proliferation", "Increased protein synthesis in muscle", "Lower blood glucose" }, 0, "Cortisol raises blood glucose by boosting hepatic gluconeogenesis and breaking down muscle protein for amino acids. It suppresses the immune system (fewer circulating lymphocytes), which is why glucocorticoids are anti-inflammatory.", "Cortisol: sugar up, muscle down, immune system nerfed. Chronic stress in a molecule. Basically me.");
  label("hormones-3-09", "organ_map", "heart", "Click the organ that releases atrial natriuretic peptide (ANP).", "Atrial muscle cells in the heart release ANP when stretched by high blood volume. ANP promotes Na+ and water excretion by the kidneys and relaxes blood vessels.", "The heart. A pump with a side hustle in endocrinology. Show-off.");
  label("hormones-3-10", "organ_map", "stomach", "Click the organ that makes most of the body's ghrelin, the hunger hormone.", "Ghrelin is made mainly by cells in the stomach (mostly the fundus). Levels rise before meals and stimulate appetite and growth hormone release. The stomach's G cells also secrete gastrin.", "Ghrelin: your stomach growling at your brain. Mine's mostly growling for *burp* Szechuan sauce.");
  label("hormones-3-11", "organ_map", "liver", "Click the organ that makes most circulating IGF-1 in response to growth hormone.", "Growth hormone acts on the liver to make insulin-like growth factor 1 (IGF-1), which carries out much of GH's growth effect on bone and cartilage. The liver is the main source of circulating IGF-1.", "Liver. GH sends the order, the liver does the actual work. Typical management structure.");
  level(4);
  lesson("hormones-4-L1", "Cushing syndrome", "Cortisol excess: central obesity, moon face, purple striae, high glucose, hypertension. Most common cause: glucocorticoid drugs (low ACTH). Endogenous: pituitary ACTH adenoma (Cushing disease), ectopic ACTH (e.g. small cell lung cancer), adrenal tumor (low ACTH). High-dose dexamethasone suppresses pituitary but not ectopic ACTH.", "Dexamethasone test: pituitary adenomas still obey feedback, ectopic tumors don't. Rebels without a *burp* receptor.", "organ_map", "adrenal_glands");
  lesson("hormones-4-L2", "Adrenal failure and Conn", "Primary adrenal insufficiency (Addison): low cortisol and aldosterone -> hypotension, low Na+, high K+; high ACTH darkens the skin. Secondary (pituitary, e.g. Sheehan postpartum infarction): low ACTH, no darkening, aldosterone near normal. Conn (primary hyperaldosteronism): hypertension, low K+, low renin.", "Dark skin plus high K+? Adrenals dead, ACTH screaming. Pituitary problem? Paler, quieter. Labs tell stories.", "organ_map", "pituitary");
  lesson("hormones-4-L3", "Water: DI vs SIADH", "ADH binds V2 receptors in the collecting duct, inserting aquaporin-2. Diabetes insipidus = lots of dilute urine: central (no ADH; urine concentrates after desmopressin) or nephrogenic (kidney resistant, e.g. lithium; no response). SIADH (e.g. small cell lung cancer): too much ADH, concentrated urine, euvolemic hyponatremia.", "DI: pee like a firehose. SIADH: hoard water till sodium drowns. Opposite disasters, same *burp* hormone.", "organ_map", "kidneys");
  lesson("hormones-4-L4", "Calcium and insulin pearls", "PTH raises Ca2+ (bone resorption, distal tubule Ca2+ reabsorption, renal 1-alpha-hydroxylase -> calcitriol) and lowers phosphate. Insulin drives K+ into cells, so DKA shows normal-high serum K+ despite total-body K+ loss. Proinsulin splits into insulin + C-peptide: C-peptide is high in insulinoma, low after injected insulin.", "Calcium, potassium, C-peptide: three exam traps, one lesson. I'm basically doing your homework.", "organ_map", "kidneys");
  mcq("hormones-4-01", "Weight gain, purple striae, high cortisol and high ACTH. High-dose dexamethasone suppresses cortisol. Most likely cause?", new String[] { "Ectopic ACTH from small cell lung cancer", "Cortisol-secreting adrenal adenoma", "Long-term prednisone therapy", "ACTH-secreting pituitary adenoma" }, 3, "High ACTH means ACTH-dependent disease; suppression by high-dose dexamethasone means the source still obeys feedback: a pituitary adenoma (Cushing disease). Ectopic ACTH does not suppress; adrenal tumors and prednisone give LOW ACTH.", "High ACTH that still suppresses: pituitary. The adenoma's a little obedient. Ectopic tumors obey nobody.");
  mcq("hormones-4-02", "Fatigue, low blood pressure and darkening skin; Na+ 128 mEq/L, K+ 6.0 mEq/L. Most likely diagnosis?", new String[] { "Secondary adrenal insufficiency (pituitary)", "Primary adrenal insufficiency (Addison disease)", "Primary hyperaldosteronism (Conn syndrome)", "Syndrome of inappropriate ADH (SIADH)" }, 1, "Low aldosterone gives low Na+, high K+ and hypotension; high ACTH (POMC, which also yields MSH) darkens skin. Secondary insufficiency has low ACTH: no darkening and usually normal K+. SIADH does not raise K+.", "Tan without a beach plus high K+? The adrenals are toast. Addison. *burp* Next.");
  mcq("hormones-4-03", "Hypertension, hypokalemia, metabolic alkalosis, high aldosterone and LOW plasma renin. Most likely cause?", new String[] { "Renal artery stenosis (renovascular)", "Primary adrenal insufficiency (Addison)", "Primary hyperaldosteronism (Conn syndrome)", "Licorice (glycyrrhizin) excess" }, 2, "Autonomous aldosterone (adenoma or bilateral hyperplasia) retains Na+, wastes K+ and H+, and suppresses renin. Renal artery stenosis has HIGH renin; licorice lets cortisol act on aldosterone receptors, so aldosterone is LOW; Addison causes hypotension.", "High aldo, low renin: the adrenal's freelancing. Conn. If renin is high, check the kidney's plumbing instead.");
  mcq("hormones-4-04", "After head trauma: polyuria; urine stays dilute (100 mOsm/kg) despite water restriction but rises to 450 mOsm/kg after desmopressin. Diagnosis?", new String[] { "Central diabetes insipidus", "Nephrogenic diabetes insipidus", "Primary polydipsia", "SIADH" }, 0, "In central DI the hypothalamus/posterior pituitary fails to release ADH, so urine stays dilute with water restriction, but the kidney responds to desmopressin (synthetic ADH). Nephrogenic DI does not respond; primary polydipsia concentrates with restriction.", "Responds to desmopressin, so the kidneys work. The ADH supply chain's broken. Central. Easy.");
  mcq("hormones-4-05", "A patient with small cell lung cancer has Na+ 122 mEq/L, normal volume status and inappropriately concentrated urine. Diagnosis?", new String[] { "Central diabetes insipidus", "SIADH", "Primary polydipsia", "Primary hyperaldosteronism" }, 1, "Small cell lung cancer can secrete ADH ectopically. Excess ADH makes the kidneys retain free water: euvolemic hyponatremia with concentrated urine. DI gives dilute urine and high-normal Na+; primary polydipsia gives maximally dilute urine.", "Tumor pumping ADH, kidneys hoarding water, sodium diluted. SIADH. Small cell: paraneoplastic overachiever.");
  mcq("hormones-4-06", "A patient with end-stage chronic kidney disease most likely has which pattern of serum values?", new String[] { "High Ca2+, low phosphate, high PTH", "High Ca2+, high phosphate, low PTH", "Low Ca2+, high phosphate, high PTH", "Low Ca2+, high phosphate, low PTH" }, 2, "Failing kidneys retain phosphate and make little calcitriol (less 1-alpha-hydroxylase), so Ca2+ falls and the parathyroids overwork: secondary hyperparathyroidism (renal osteodystrophy). High Ca2+ + low phosphate + high PTH is primary; low Ca2+ + low PTH is hypoparathyroidism.", "Dead kidneys hoard phosphate and skip the vitamin D. The parathyroids panic. Secondary hyperparathyroidism, *burp* genius.");
  mcq("hormones-4-07", "In diabetic ketoacidosis, why is serum K+ often normal or high even though total-body K+ is depleted?", new String[] { "Insulin lack and hyperosmolality shift K+ out of cells", "The kidneys stop excreting K+ during ketoacidosis", "High insulin levels push K+ out of cells", "Ketones block K+ excretion in the urine" }, 0, "Insulin normally drives K+ into cells via the Na+/K+-ATPase; without it, and with hyperosmolality pulling water and K+ out, K+ leaves cells. Meanwhile osmotic diuresis wastes K+ in urine, so total-body K+ is low and falls fast once insulin is given.", "Insulin is the K+ bouncer: shoves it into cells. Fire the bouncer, K+ floods the plasma. Rehire him, it crashes.");
  mcq("hormones-4-08", "A hypoglycemic nurse has high serum insulin but LOW C-peptide. What is the most likely cause?", new String[] { "Insulinoma", "Sulfonylurea use", "Primary adrenal insufficiency", "Injection of exogenous insulin" }, 3, "Beta cells release insulin and C-peptide in equal amounts, so insulinoma and sulfonylureas raise both. Pharmaceutical insulin contains no C-peptide, and the high insulin suppresses the patient's own secretion, so C-peptide is low.", "No C-peptide, no pancreas involved. Somebody's been *burp* injecting. Medicine's a detective show, genius.");
  label("hormones-4-09", "organ_map", "pituitary", "Click the gland that infarcts in Sheehan syndrome after severe postpartum hemorrhage.", "The pituitary enlarges in pregnancy and is vulnerable to low blood flow. Massive blood loss at delivery can infarct it: often the first sign is failure to lactate (no prolactin), then hypothyroidism and adrenal insufficiency.", "Pituitary. Pregnancy makes it big and hungry for blood. Cut the supply and the whole empire falls.");
  label("hormones-4-10", "organ_map", "kidneys", "Click the organ where 1-alpha-hydroxylase makes active vitamin D (calcitriol).", "The liver makes 25-hydroxyvitamin D; the kidney's proximal tubule adds the second hydroxyl via 1-alpha-hydroxylase (stimulated by PTH). That's why chronic kidney disease causes low calcitriol and secondary hyperparathyroidism.", "Kidneys finish vitamin D. Liver starts it, kidney closes. Kidneys fail, calcium chaos. Elementary.");
  label("hormones-4-11", "organ_map", "small_intestine", "Click the organ whose S cells release secretin when stomach acid arrives.", "S cells in the duodenum, the first part of the small intestine, release secretin in response to acid. Secretin makes the pancreas secrete bicarbonate-rich fluid to neutralize it.", "Duodenum, small intestine. Acid arrives, secretin calls the pancreas for baking soda. Chemistry, Morty-brain.");
}

void content_immune() {
  topic("immune", "IMMUNE SYSTEM", "organ_map");
  level(1);
  lesson("immune-1-L1", "Your defense force", "The immune system defends you against pathogens: bacteria, viruses, fungi and parasites. The first barriers are skin and mucous membranes, plus tears, mucus and stomach acid. Behind them are white blood cells (leukocytes), made in the bone marrow, which hunt down anything that gets through.", "Skin, snot and stomach acid. Your first line of defense is basically gross. Respect the *burp* gross.", "", "");
  lesson("immune-1-L2", "Innate vs adaptive", "Innate immunity is fast (minutes to hours) and not specific: neutrophils and macrophages eat invaders (phagocytosis) and cause inflammation (redness, heat, swelling, pain). Adaptive immunity is slower (days) but specific and has memory: T cells and B cells. B cells make antibodies, Y-shaped proteins.", "Innate is a bouncer with a bat who hits everyone. Adaptive is a sniper who remembers faces. Learn both, idiot.", "", "");
  lesson("immune-1-L3", "Thymus and spleen", "The thymus sits in the chest behind the breastbone, in front of and above the heart. T cells mature there (T for thymus); it is largest in childhood and shrinks after puberty. The spleen, in the upper left abdomen, filters blood: it removes old red blood cells and fights germs in the bloodstream.", "Thymus trains T cells, spleen filters blood. The thymus shrinks with age. Mine's a raisin. Worth it.", "organ_map", "thymus");
  lesson("immune-1-L4", "Lymph nodes and vaccines", "Lymph nodes are bean-sized filters along lymph vessels, clustered in the neck, armpits and groin. They swell when fighting a nearby infection ('swollen glands'). Vaccines show your immune system a harmless piece or weakened form of a germ, so it makes memory cells and responds faster next time.", "Vaccines are a training montage for your immune system. Same germ shows up later, gets *burp* destroyed.", "organ_map", "lymph_nodes");
  mcq("immune-1-01", "Which cells are the main soldiers of the immune system?", new String[] { "Red blood cells", "White blood cells", "Platelets", "Fat cells" }, 1, "White blood cells (leukocytes) detect and destroy invaders. Red blood cells carry O2 and platelets help blood clot; neither is a main immune cell.", "White blood cells. Red ones carry oxygen, platelets plug holes. It's color-coded, genius.");
  mcq("immune-1-02", "T cells are named after the organ where they mature. Which organ?", new String[] { "Thyroid", "Tonsils", "Thymus", "Testes" }, 2, "T cells are born in the bone marrow but mature in the thymus, the gland in the chest above the heart. The thyroid is a hormone gland in the neck with a confusingly similar name.", "Thymus. Not thyroid, not tonsils. Four T-words and you need a *burp* coin flip? Pathetic.");
  mcq("immune-1-03", "What are antibodies?", new String[] { "Cells that swallow bacteria", "Proteins that stick to specific invaders", "Hormones that cause fever", "A kind of weakened virus" }, 1, "Antibodies are Y-shaped proteins made by B cells (as plasma cells). Each binds one specific target (antigen), tagging it for destruction or blocking it. Cells that swallow bacteria are phagocytes.", "Proteins. Little Y-shaped sticky tags. Antibodies point, other cells shoot.");
  mcq("immune-1-04", "What is the body's FIRST line of defense against germs?", new String[] { "Antibodies", "T cells", "Lymph nodes", "Skin and mucous membranes" }, 3, "Physical and chemical barriers come first: intact skin, mucous membranes, mucus, tears and stomach acid stop most germs before any immune cell is needed.", "Skin. A big waterproof bag. Keep it intact, Morty-brain, no matter what portal you fall through.");
  mcq("immune-1-05", "What is a main job of the spleen?", new String[] { "Filtering blood and removing old red blood cells", "Producing bile for digestion", "Making insulin", "Filtering blood to make urine" }, 0, "The spleen filters blood: it removes old or damaged red blood cells and traps germs in the bloodstream. Bile comes from the liver, insulin from the pancreas, urine from the kidneys.", "Blood filter and red-cell graveyard. The spleen works quietly. Unlike you, *burp* whining about one quiz.");
  mcq("immune-1-06", "Why do lymph nodes in your neck often swell during a throat infection?", new String[] { "They fill with excess saliva", "They store extra red blood cells", "Immune cells inside multiply to fight the germs", "They absorb heat from the fever" }, 2, "Germs and debris drain to the nearest lymph nodes. Lymphocytes there recognize them and multiply rapidly, so the node enlarges and is often tender. Swelling means immune activity.", "Lymphocytes multiplying. Your neck turns into a barracks. Swollen glands mean the army's mobilized.");
  mcq("immune-1-07", "How does a vaccine protect you?", new String[] { "It kills bacteria directly, like an antibiotic", "It trains the immune system to make memory cells", "It replaces your white blood cells", "It coats your skin to block germs" }, 1, "A vaccine safely exposes the adaptive immune system to a harmless piece or weakened form of a germ, so memory B and T cells respond fast if the real germ shows up. Antibiotics kill bacteria; vaccines don't.", "Training, not killing. A vaccine is a fire drill. An antibiotic is a fire extinguisher. Different things, idiot.");
  mcq("immune-1-08", "Which defense acts within minutes to hours and attacks many kinds of germs the same way?", new String[] { "Innate immunity", "Adaptive immunity", "Antibody memory", "Vaccination" }, 0, "Innate immunity (barriers, neutrophils, macrophages, inflammation) is fast and non-specific. Adaptive immunity (T and B cells) takes days the first time but is specific and remembers.", "Innate. Fast and dumb, like a guard dog. Adaptive is slow and smart, like me. Mostly like me.");
  label("immune-1-09", "organ_map", "spleen", "Click the spleen.", "The spleen sits in the upper left abdomen, behind the stomach, under the ribs. It filters blood, removes old red blood cells and fights blood-borne infections.", "Upper left, tucked behind the stomach. If you clicked the liver, wrong side, genius. Patient's left!");
  label("immune-1-10", "organ_map", "thymus", "Click the thymus.", "The thymus lies in the upper chest behind the breastbone, above the heart. T cells mature there; it's big in children and is mostly replaced by fat in adults.", "Chest, above the heart. T-cell boot camp. It's practically in the name.");
  level(2);
  lesson("immune-2-L1", "The white blood cell lineup", "Neutrophils are most common (about 40-70% of WBCs) and first to attack bacteria; dead ones form pus. Lymphocytes (about 20-40%) are T, B and NK cells. Monocytes become macrophages in tissues. Eosinophils fight parasitic worms; basophils, the rarest, release histamine. Normal count: about 4,000-11,000/uL.", "Never Let Monkeys Eat Bananas: neutrophils, lymphocytes, monocytes, eosinophils, basophils. Most to least.", "", "");
  lesson("immune-2-L2", "Antibodies", "Plasma cells (activated B cells) secrete antibodies (immunoglobulins): 2 heavy + 2 light chains, with variable tips that bind antigen. IgM is made first (a pentamer). IgG is most abundant in blood and crosses the placenta. IgA guards mucus, tears and breast milk. IgE drives allergy and fights worms.", "IgM first, IgG most, IgA in your spit, IgE makes you sneeze. Memorize it or I'm *burp* replacing you with a Meeseeks.", "", "");
  lesson("immune-2-L3", "Helper and killer T cells", "Helper T cells (CD4+) direct the response: their cytokines activate B cells and macrophages. HIV infects and destroys them. Cytotoxic T cells (CD8+) kill virus-infected and cancer cells. T cells can't see free antigen; they only recognize peptides shown on MHC molecules (called HLA in humans).", "CD4 gives the orders, CD8 does the killing. Like me and Morty. Except Morty mostly screams.", "organ_map", "thymus");
  lesson("immune-2-L4", "Lymph, gut and passive immunity", "Lymph (leaked tissue fluid) flows via lymphatics and lymph nodes back to the blood, mostly through the thoracic duct (left neck). Peyer patches in the small intestine (ileum) sample gut antigens and promote IgA. Passive immunity = borrowed antibodies: natural (maternal IgG, breast-milk IgA) or artificial (antibody injections).", "Borrowed antibodies work, but they expire. Like my library books. Which I never *burp* return.", "organ_map", "lymph_nodes");
  mcq("immune-2-01", "Which white blood cell is the most abundant in normal adult blood?", new String[] { "Lymphocyte", "Monocyte", "Neutrophil", "Eosinophil" }, 2, "Neutrophils make up about 40-70% of WBCs and are first responders to bacterial infection. Lymphocytes are second (about 20-40%).", "Neutrophils. The grunts. Show up first, die in droves, become pus. Heroes, honestly.");
  mcq("immune-2-02", "Which white blood cell is classically increased in parasitic worm infections?", new String[] { "Neutrophil", "Eosinophil", "Monocyte", "Basophil" }, 1, "Eosinophils attack helminths (worms) too big to eat, releasing toxic granule proteins such as major basic protein. They also rise in allergies and asthma.", "Eosinophils. Worm killers. Good, 'cause the multiverse is *burp* crawling with parasites.");
  mcq("immune-2-03", "Monocytes that leave the blood and settle in tissues become:", new String[] { "Plasma cells", "Neutrophils", "Mast cells", "Macrophages" }, 3, "Monocytes migrate into tissues and differentiate into macrophages, long-lived phagocytes that eat microbes and debris and present antigen. Plasma cells come from B cells.", "Macrophages. Means 'big eaters'. A monocyte moves into tissue and gets fat. Relatable.");
  mcq("immune-2-04", "Which antibody class crosses the placenta to protect the fetus?", new String[] { "IgG", "IgM", "IgA", "IgE" }, 0, "Only IgG crosses the placenta (carried by FcRn receptors), giving newborns months of passive protection. IgM is a big pentamer and can't cross; IgA reaches the baby through breast milk.", "IgG. Mom ships antibodies across the placenta. Free protection. Best gift she ever gave you, guaranteed.");
  mcq("immune-2-05", "Which antibody class is made FIRST in a new infection?", new String[] { "IgG", "IgE", "IgM", "IgA" }, 2, "IgM (secreted as a pentamer) is the first antibody of a primary response. Later, helper T cells drive class switching to IgG, IgA or IgE. A high specific IgM suggests a recent infection.", "IgM. Big clumsy pentamer shows up first, the refined IgG sniper comes later. Like a first draft.");
  mcq("immune-2-06", "HIV mainly infects and depletes which cells?", new String[] { "CD8+ cytotoxic T cells", "CD4+ helper T cells", "B cells", "Neutrophils" }, 1, "HIV binds CD4 (plus CCR5 or CXCR4) and destroys CD4+ helper T cells. With too few helpers the adaptive response collapses; AIDS is defined by a count below 200/uL or an AIDS-defining illness.", "CD4 helpers. Kill the generals and the army falls apart. Sneaky little *burp* virus.");
  mcq("immune-2-07", "Which cells directly kill virus-infected body cells?", new String[] { "CD8+ cytotoxic T cells", "Plasma cells", "Eosinophils", "CD4+ helper T cells" }, 0, "CD8+ T cells recognize viral peptides on MHC class I and kill the cell with perforin and granzymes. Helper T cells coordinate rather than kill; plasma cells make antibodies.", "CD8s. Assassins. Find an infected cell, punch holes, done. Efficient. I like 'em.");
  mcq("immune-2-08", "A baby receiving antibodies through breast milk is an example of:", new String[] { "Natural active immunity", "Artificial active immunity", "Artificial passive immunity", "Natural passive immunity" }, 3, "Passive = receiving ready-made antibodies, so no memory forms. Natural = not from a medical product. Active immunity is when your own body makes antibodies, after infection (natural) or vaccination (artificial).", "Passive. Borrowed. Temporary. The baby didn't earn those antibodies, just like you didn't earn this degree.");
  label("immune-2-09", "organ_map", "lymph_nodes", "Click the lymph nodes.", "Lymph nodes are small bean-shaped filters along lymph vessels, clustered in the neck, armpits and groin. Lymphocytes inside meet antigens draining in from the tissues.", "Little beans along the vessels. They're all over the place, so try not to miss.");
  label("immune-2-10", "organ_map", "small_intestine", "Click the organ whose wall contains Peyer patches.", "Peyer patches are lymphoid follicles in the wall of the small intestine, mostly the ileum. M cells sample gut antigens and the patches drive IgA production.", "Small intestine. Your gut guards its own border while you shovel garbage into it.");
  level(3);
  lesson("immune-3-L1", "MHC and antigen presentation", "MHC class I (HLA-A, -B, -C) is on all nucleated cells and shows peptides made inside the cell (e.g. viral) to CD8+ T cells. MHC class II (HLA-DP, -DQ, -DR) is on antigen-presenting cells (dendritic cells, macrophages, B cells) and shows peptides from engulfed material to CD4+ T cells.", "Class I: 'here's what's inside me.' Class II: 'here's what I ate.' Rule of 8: 1x8, 2x4. Cells are *burp* gossips.", "", "");
  lesson("immune-3-L2", "T-cell boot camp: the thymus", "In the thymic cortex, positive selection keeps T cells whose receptors can bind self-MHC. In the medulla, negative selection deletes T cells that bind self-antigens too strongly (AIRE helps display tissue proteins). Naive T cells need 2 signals: TCR binding MHC-peptide plus costimulation (B7 on APC binds CD28).", "Cortex: can you see MHC? Medulla: will you attack your own body? Fail either and you die. Tough school.", "organ_map", "thymus");
  lesson("immune-3-L3", "Complement", "Complement is a cascade of plasma proteins, mostly made by the liver. Triggers: classical pathway (IgG or IgM bound to antigen), alternative (microbe surfaces) and lectin (mannose-binding lectin). C3b opsonizes; C3a and C5a drive inflammation (C5a calls neutrophils); C5b-9 forms the membrane attack complex.", "C3b tags it, C5a yells for backup, the MAC punches holes. Complement is a mob. A very organized mob.", "organ_map", "liver");
  lesson("immune-3-L4", "Hypersensitivity types", "Type I: IgE on mast cells, immediate (anaphylaxis, hay fever). Type II: antibodies against cell-surface or matrix antigens (autoimmune hemolytic anemia, Graves). Type III: immune complex deposition (SLE, post-strep glomerulonephritis). Type IV: delayed, T-cell mediated (TB skin test, poison ivy).", "ACID: Allergic, Cytotoxic, Immune complex, Delayed. Four types, one mnemonic. Even you can *burp* manage that.", "", "");
  mcq("immune-3-01", "Peptides from a virus replicating inside a cell are presented to CD8+ T cells on:", new String[] { "MHC class II", "MHC class I", "CD4", "Toll-like receptor 4" }, 1, "MHC I presents endogenous (cytosolic) peptides, cut by the proteasome and loaded in the ER via TAP, to CD8+ T cells. MHC II presents engulfed, exogenous peptides to CD4+ T cells.", "Class I, to CD8. Rule of 8: 1 times 8, 2 times 4. Multiplication. You've heard of it?");
  mcq("immune-3-02", "Which cells mainly express MHC class II, presenting antigen to CD4+ T cells?", new String[] { "All nucleated cells", "Red blood cells and platelets", "Dendritic cells, macrophages and B cells", "CD8+ T cells and NK cells" }, 2, "MHC II is mainly on professional antigen-presenting cells: dendritic cells, macrophages and B cells. MHC I is on all nucleated cells (and platelets); red blood cells lack both.", "Professional presenters only. Dendritic cells, macrophages, B cells. Everyone else is an amateur.");
  mcq("immune-3-03", "Negative selection, which deletes strongly self-reactive T cells, occurs mainly in the:", new String[] { "Thymic cortex", "Bone marrow", "Lymph node paracortex", "Thymic medulla" }, 3, "The thymic medulla deletes T cells that bind self-antigen too strongly, with AIRE helping display tissue proteins. Positive selection, which tests for self-MHC binding, happens earlier in the cortex.", "Medulla. Cortex checks you're useful, medulla checks you won't attack your own body. Ideal hiring process.");
  mcq("immune-3-04", "For naive T-cell activation, B7 (CD80/86) on the APC must bind which stimulatory T-cell molecule?", new String[] { "CD28", "CTLA-4", "CD40", "CD3" }, 0, "Signal 2 is B7 binding CD28. CTLA-4 also binds B7 but INHIBITS T cells. CD40 on APCs and B cells binds CD40L; CD3 carries signal 1 from the TCR. Signal 1 without signal 2 -> anergy.", "CD28. CTLA-4 grabs the same B7 and slams the brakes. Same key, opposite door. Classic trap.");
  mcq("immune-3-05", "Which complement fragment is the main opsonin?", new String[] { "C5a", "C3b", "C3a", "C5b-9" }, 1, "C3b coats microbes so phagocytes with complement receptors can grab them (IgG is the other key opsonin). C3a and C5a are anaphylatoxins; C5b-9 is the membrane attack complex.", "C3b. A 'kick me' sign for bacteria. Phagocytes love it.");
  mcq("immune-3-06", "Which complement pathway is triggered by IgG or IgM bound to antigen?", new String[] { "Alternative pathway", "Lectin pathway", "Extrinsic pathway", "Classical pathway" }, 3, "The classical pathway starts when C1q binds antibody (IgM or IgG) on an antigen. The alternative pathway triggers on microbial surfaces, the lectin pathway via mannose-binding lectin. 'Extrinsic' is coagulation.", "Classical. Antibodies call in complement. Old school, like me, but less handsome.");
  mcq("immune-3-07", "A positive tuberculin (PPD) skin test read at 48-72 hours is which type of hypersensitivity?", new String[] { "Type IV", "Type I", "Type II", "Type III" }, 0, "Type IV is delayed and T-cell mediated: memory Th1 cells recruit macrophages to the injection site, causing induration after 48-72 hours. No antibodies are involved.", "Type IV. Delayed. The T cells take two days to show up. Like me to my own *burp* birthday party.");
  mcq("immune-3-08", "Which disease is a classic type III (immune complex) hypersensitivity?", new String[] { "Poison ivy contact dermatitis", "Peanut anaphylaxis", "Systemic lupus erythematosus", "Autoimmune hemolytic anemia" }, 2, "In SLE, antigen-antibody complexes deposit in kidneys, skin and joints and activate complement. Poison ivy dermatitis is type IV, anaphylaxis type I, and autoimmune hemolytic anemia type II.", "Lupus. Complexes clog the filters, complement trashes the place. Type III is basically immune littering.");
  label("immune-3-09", "organ_map", "liver", "Click the organ that makes most complement proteins and C-reactive protein.", "Hepatocytes make most complement proteins and acute-phase proteins such as CRP, fibrinogen and serum amyloid A, ramping them up when IL-6 rises during inflammation.", "Liver. Of course. It does everything. The real MVP of your abused body.");
  label("immune-3-10", "organ_map", "thymus", "Click the organ where T cells undergo positive and negative selection.", "The thymus: positive selection in the cortex, negative selection in the medulla. Only a small fraction of thymocytes survive both and leave as mature naive T cells.", "Thymus. Most applicants die. Brutal admissions. Your med school wishes it were this picky.");
  level(4);
  lesson("immune-4-L1", "B- and T-cell deficiencies", "Bruton agammaglobulinemia: X-linked BTK defect -> no mature B cells; boys get bacterial infections after about 6 months, as maternal IgG fades. DiGeorge (22q11.2 deletion): 3rd/4th pharyngeal pouches fail -> thymic hypoplasia (T-cell deficit), hypocalcemia, heart defects. Hyper-IgM: CD40L defect, no class switch.", "No B cells, no thymus, no switching. Three ways to break an immune system. Nature's creative like that.", "organ_map", "thymus");
  lesson("immune-4-L2", "Phagocyte failures", "Chronic granulomatous disease: NADPH oxidase defect -> no respiratory burst; infections with catalase-positive organisms (S. aureus, Aspergillus, Serratia, Burkholderia); abnormal dihydrorhodamine test. Leukocyte adhesion deficiency 1: CD18 integrin defect -> neutrophils can't leave vessels: late cord separation, no pus.", "CGD: catalase-positive bugs destroy their own H2O2, so the crippled phagocyte has nothing to *burp* borrow.", "", "");
  lesson("immune-4-L3", "No spleen, no MAC", "Asplenia (splenectomy, or autosplenectomy in sickle cell disease) -> risk of overwhelming sepsis from encapsulated bacteria: S. pneumoniae, H. influenzae type b, N. meningitidis. The smear shows Howell-Jolly bodies (nuclear remnants the spleen normally removes). Terminal complement (C5-C9) loss -> Neisseria.", "Capsules hide bacteria from phagocytes; the spleen catches them anyway. No spleen, no catch. Simple.", "organ_map", "spleen");
  lesson("immune-4-L4", "Cytokines and lymph nodes", "IL-1, IL-6 and TNF-alpha cause fever. IL-12 drives Th1 cells, whose IFN-gamma activates macrophages (key against TB). IL-4 drives Th2 cells and IgE switching; IL-5 boosts eosinophils. In lymph nodes, B cells sit in cortical follicles and T cells in the paracortex, which expands in viral infections.", "IL-12 calls Th1, IFN-gamma wakes the macrophages. Cytokines are just cells texting. Badly, mostly.", "organ_map", "lymph_nodes");
  mcq("immune-4-01", "A 9-month-old boy has recurrent otitis and pneumonia, normal T cells, almost no CD19+ B cells and very low IgG, IgA and IgM. Which gene is mutated?", new String[] { "CD40LG", "BTK", "ADA", "WAS" }, 1, "X-linked (Bruton) agammaglobulinemia: BTK tyrosine kinase is needed for pre-B cells to mature. Infections start after about 6 months as maternal IgG wanes. CD40L defects give hyper-IgM with normal B cells; ADA-SCID also lacks T cells.", "BTK. Boy, 6 months, no B cells. The X chromosome strikes again. Thanks, Mom's side.");
  mcq("immune-4-02", "A newborn has seizures from hypocalcemia, truncus arteriosus and no thymic shadow on chest X-ray. What is the most likely cause?", new String[] { "Adenosine deaminase deficiency", "X-linked BTK mutation", "22q11.2 microdeletion", "Trisomy 21" }, 2, "DiGeorge: 3rd/4th pharyngeal pouches fail -> absent parathyroids (hypocalcemia) and thymic hypoplasia (T-cell deficit), plus conotruncal heart defects. ADA-SCID also lacks a thymic shadow but has no hypocalcemia or heart defect.", "CATCH-22: Cardiac, Abnormal face, Thymic aplasia, Cleft palate, Hypocalcemia, chromosome 22. Write it down.");
  mcq("immune-4-03", "A 4-year-old has recurrent S. aureus abscesses and Aspergillus pneumonia. A dihydrorhodamine test shows no oxidative burst. Which enzyme is deficient?", new String[] { "Myeloperoxidase", "Superoxide dismutase", "Adenosine deaminase", "NADPH oxidase" }, 3, "CGD: NADPH oxidase can't make superoxide (no respiratory burst), so phagocytes can't kill catalase-positive organisms. Myeloperoxidase acts one step later (H2O2 -> HOCl); its deficiency leaves the burst intact and is usually mild (sometimes Candida).", "NADPH oxidase. No respiratory burst, no kill. The phagocytes just hug the bacteria. *burp* Useless.");
  mcq("immune-4-04", "A newborn's umbilical cord is still attached at 5 weeks. He has skin infections without pus and marked neutrophilia. Which molecule is defective?", new String[] { "CD18 (beta-2 integrin)", "NADPH oxidase", "CD40 ligand", "C5" }, 0, "LAD type 1: the CD18 defect blocks firm adhesion of neutrophils to endothelium, so they can't leave the blood: neutrophilia but no pus, and delayed cord separation. In CGD neutrophils migrate fine but can't kill.", "CD18. Neutrophils everywhere in the blood and none at the party. Stuck in traffic like idiots.");
  mcq("immune-4-05", "A woman with sickle cell disease has Howell-Jolly bodies on her blood smear. She is at greatest risk of sepsis from which organism?", new String[] { "Pseudomonas aeruginosa", "Streptococcus pneumoniae", "Candida albicans", "Cytomegalovirus" }, 1, "Howell-Jolly bodies signal a nonfunctional spleen (autosplenectomy). The spleen clears encapsulated bacteria (S. pneumoniae, H. influenzae type b, N. meningitidis), so asplenic patients risk overwhelming sepsis.", "Encapsulated bugs, and pneumococcus is the king. No spleen, no defense. Capsule wins.");
  mcq("immune-4-06", "A 19-year-old has her second episode of meningococcal meningitis. Deficiency of which component(s) is most likely?", new String[] { "C1 esterase inhibitor", "Decay-accelerating factor (CD55)", "C5-C9 (membrane attack complex)", "Myeloperoxidase" }, 2, "Neisseria are mainly killed by the membrane attack complex, so terminal complement (C5-C9) deficiency causes recurrent Neisseria infections. C1-INH deficiency causes hereditary angioedema; DAF loss causes PNH.", "No MAC, no holes, and Neisseria keeps coming back. Recurrent meningococcus = check the *burp* complement.");
  mcq("immune-4-07", "A boy has recurrent sinopulmonary infections and Pneumocystis pneumonia. Serum IgM is high, but IgG, IgA and IgE are very low. What is defective?", new String[] { "CD40 ligand on helper T cells", "BTK in B cells", "IL-2 receptor gamma chain", "MHC class I expression" }, 0, "Class switching needs CD40L on helper T cells to bind CD40 on B cells. Without it B cells stay stuck making IgM (X-linked hyper-IgM), and macrophage activation also suffers, so opportunists like Pneumocystis appear.", "CD40L. B cells waiting for a 'switch' signal that never comes. Stuck on IgM forever.");
  mcq("immune-4-08", "Which cytokine, made by Th1 cells, activates macrophages to kill intracellular Mycobacterium tuberculosis?", new String[] { "IL-4", "IL-10", "IL-5", "Interferon-gamma" }, 3, "IL-12 from macrophages drives Th1 cells, which secrete IFN-gamma to activate macrophages and build granulomas. IL-4 and IL-5 are Th2 cytokines; IL-10 is anti-inflammatory. Defects in the IL-12/IFN-gamma axis invite mycobacteria.", "IFN-gamma. Th1 wakes the macrophages. Without it, TB moves in and redecorates your lungs.");
  label("immune-4-09", "organ_map", "spleen", "Click the organ whose loss causes Howell-Jolly bodies and sepsis risk from encapsulated bacteria.", "The spleen's red pulp removes damaged RBCs and nuclear remnants (Howell-Jolly bodies); its macrophages and marginal-zone B cells clear encapsulated bacteria. Asplenic patients get vaccines against them.", "Spleen. Small, purple, underrated. Lose it and pneumococcus throws a *burp* party in your blood.");
  label("immune-4-10", "organ_map", "lymph_nodes", "Click the organs that filter lymph and whose paracortex (T-cell zone) expands in viral infections.", "Lymph nodes: cortical follicles hold B cells (germinal centers), the paracortex holds T cells and high endothelial venules, and medullary sinuses drain lymph. The spleen filters blood, not lymph.", "Lymph nodes. Cortex for B, paracortex for T. Organized. More than your notes, genius.");
}

void parts_brain() {
  partInfo("brain", "frontal_lobe", "Frontal Lobe", "Front of each hemisphere, ahead of the central sulcus. Planning, judgment, personality and voluntary movement (motor cortex); on the dominant side, speech production (Broca area).", "Planning, judgment, personality. Yours is apparently on *burp* airplane mode.");
  partInfo("brain", "parietal_lobe", "Parietal Lobe", "Between the central sulcus and the occipital lobe. Processes touch, pain, temperature and body position (somatosensory cortex) and spatial awareness.", "Touch and spatial sense. It knows where your hand is. Wish it knew where your brain was.");
  partInfo("brain", "temporal_lobe", "Temporal Lobe", "Below the lateral sulcus. Hearing (primary auditory cortex), language comprehension (Wernicke area on the dominant side) and memory (hippocampus on its inner side).", "Hearing and memory. Remember this, would you? It's literally the memory lobe.");
  partInfo("brain", "occipital_lobe", "Occipital Lobe", "Back of the cerebrum. Contains the primary visual cortex, which receives input from the eyes relayed through the thalamus.", "Vision, at the back of your head. Your eyes are the front end, this is the server room.");
  partInfo("brain", "cerebellum", "Cerebellum", "Below the occipital lobes, behind the brainstem. Coordinates movement, balance and posture and helps motor learning; damage causes clumsy movement (ataxia) on the same side.", "Coordination central. Booze messes with it, which is why I *burp* lean like this. Scientific.");
  partInfo("brain", "pons", "Pons", "Middle part of the brainstem, between midbrain and medulla. Relays signals from cerebrum to cerebellum, helps regulate breathing, and holds nuclei of cranial nerves V, VI, VII (and part of VIII).", "Pons means bridge. Cerebrum to cerebellum, the messages cross here. Latin, genius.");
  partInfo("brain", "medulla", "Medulla Oblongata", "Lowest part of the brainstem, continuous with the spinal cord. Holds cardiovascular and respiratory centers, and the pyramids; most corticospinal fibers cross at their lower end.", "Breathing and heart-rate control. The one part of your brain I'd ask you not to break.");
  partInfo("brain", "spinal_cord", "Spinal Cord", "Continues from the medulla down the vertebral canal to about L1-L2 in adults. Carries ascending sensory and descending motor tracts, runs reflexes, and gives off 31 pairs of spinal nerves.", "The main data cable. Snap it and everything below goes offline. Back up your *burp* spine, genius.");
  partInfo("brain", "central_sulcus", "Central Sulcus", "Deep groove separating the frontal lobe from the parietal lobe, and the precentral (motor) gyrus from the postcentral (sensory) gyrus.", "Big groove between moving and feeling. The brain's own border wall.");
  partInfo("brain", "lateral_sulcus", "Lateral Sulcus", "Also called the Sylvian fissure. Deep groove separating the temporal lobe below from the frontal and parietal lobes above; the insula lies hidden deep inside it.", "Sylvian fissure. Temporal lobe below, everything else above. The insula's hide-and-seek spot.");
  partInfo("brain", "precentral_gyrus", "Precentral Gyrus", "Ridge just in front of the central sulcus: the primary motor cortex. Its upper motor neurons send axons down the corticospinal tract to move the opposite side of the body.", "Motor cortex. Every voluntary twitch starts here. Even your bad *burp* dance moves.");
  partInfo("brain", "postcentral_gyrus", "Postcentral Gyrus", "Ridge just behind the central sulcus: the primary somatosensory cortex. Receives touch, pain, temperature and position from the opposite side, mapped as the sensory homunculus.", "Sensory cortex. Giant lips and hands on the homunculus. Ugly little guy. Looks like Jerry.");
  partInfo("brain", "broca_area", "Broca Area", "Inferior frontal gyrus of the dominant (usually left) hemisphere. Speech production; damage causes non-fluent (expressive) aphasia with fairly intact comprehension.", "Speech production. Break it and words come out like rusty gears grinding.");
  partInfo("brain", "wernicke_area", "Wernicke Area", "Posterior superior temporal gyrus of the dominant hemisphere. Language comprehension; damage causes fluent but meaningless speech with poor comprehension.", "Comprehension. Damage it and you talk fluent nonsense. So, you know, a *burp* podcast.");
}

void parts_cell() {
  partInfo("cell", "cell_membrane", "Cell Membrane", "Phospholipid bilayer with proteins and cholesterol that encloses the cell and controls what enters and leaves (selectively permeable). Carries receptors, channels and pumps.", "A greasy force field with doormen. Still better security than my garage.");
  partInfo("cell", "cytoplasm", "Cytoplasm", "Everything inside the membrane except the nucleus: watery cytosol (where glycolysis runs and free ribosomes work) plus the organelles and cytoskeleton.", "Cell soup. Organelles floating in it like croutons. Smarter croutons than you, though.");
  partInfo("cell", "nucleus", "Nucleus", "Holds the chromosomes (DNA) inside a double-membrane nuclear envelope with pores. DNA is replicated and transcribed into RNA here.", "The vault with the blueprints. Every protein you'll ever make starts in here. Most of you, anyway.");
  partInfo("cell", "nucleolus", "Nucleolus", "Dense, membrane-less region inside the nucleus where rRNA is made by RNA polymerase I and ribosomal subunits are assembled.", "Ribosome factory inside the control room. Efficient. Unlike anything you've ever organized.");
  partInfo("cell", "mitochondrion", "Mitochondrion", "Double-membrane power plant: Krebs cycle in the matrix, electron transport chain and ATP synthase on the inner membrane (cristae). Has its own maternally inherited DNA.", "Ancient bacteria your cells swallowed and enslaved. Billions of years later, they still pay rent in ATP.");
  partInfo("cell", "rough_er", "Rough ER", "Ribosome-studded membrane network continuous with the nuclear envelope. Makes secretory and membrane proteins and starts N-linked glycosylation. Prominent in plasma cells.", "Protein assembly line. Plasma cells are packed with it because they pump out antibodies nonstop.");
  partInfo("cell", "smooth_er", "Smooth ER", "Ribosome-free ER that makes lipids and steroid hormones, detoxifies drugs (cytochrome P450, abundant in liver) and stores Ca2+ (sarcoplasmic reticulum in muscle).", "Lipids, steroids, detox. Basically the cell's pharmacy and booze filter. My favorite organelle.");
  partInfo("cell", "golgi", "Golgi Apparatus", "Stack of flattened sacs that modifies proteins from the rough ER (O-linked glycosylation, mannose-6-phosphate tags), then sorts them into vesicles for secretion, membrane or lysosomes.", "The post office. Receives, stamps, ships. If packages go missing, blame the Golgi. Everyone does.");
  partInfo("cell", "ribosome", "Ribosome", "rRNA-protein machine (80S in human cytosol: 60S + 40S subunits) that translates mRNA into protein. Free ones make cytosolic proteins; ER-bound ones make secreted and membrane proteins.", "Reads the code, spits out protein. Millions of them per cell. No union, no breaks.");
  partInfo("cell", "lysosome", "Lysosome", "Membrane sac of acid hydrolases that work at about pH 5 and digest worn-out organelles and engulfed material. Enzyme defects cause lysosomal storage diseases.", "Acid garbage disposal. When one enzyme's missing, the trash piles up and you get a *burp* named disease.");
  partInfo("cell", "centrosome", "Centrosome", "Main microtubule-organizing center near the nucleus: a pair of centrioles (9 microtubule triplets each). It duplicates and forms the poles of the mitotic spindle.", "Spindle commander. Pulls chromosomes apart during division. Two little barrels running the whole show.");
}

void parts_digestive() {
  partInfo("digestive", "esophagus", "Esophagus", "Muscular tube about 25 cm long from the pharynx, behind the trachea and heart, through the diaphragm to the stomach. Moves food by peristalsis. Chronic acid reflux can cause Barrett esophagus.", "A meat chute. Food goes down, and if it comes back up, that's reflux, Morty-brain.");
  partInfo("digestive", "stomach", "Stomach", "J-shaped muscular sac in the upper left abdomen. Stores food, churns it with HCl and pepsin into chyme and releases it slowly through the pyloric sphincter. Parietal cells also make intrinsic factor.", "Your personal acid vat. pH about 2. Show some respect.");
  partInfo("digestive", "liver", "Liver", "Largest internal organ, upper right abdomen under the diaphragm. Makes bile, processes nutrients from the hepatic portal vein, stores glycogen, makes plasma proteins like albumin and detoxifies drugs and alcohol.", "The liver. Regenerates, detoxifies, never complains. My liver deserves a *burp* Nobel Prize.");
  partInfo("digestive", "gallbladder", "Gallbladder", "Small pear-shaped sac under the liver. Stores and concentrates bile, then squeezes it through the cystic and common bile ducts into the duodenum when CCK signals that fat has arrived.", "Bile storage. Concentrate too much and you grow gallstones. Rocks. Inside you.");
  partInfo("digestive", "pancreas", "Pancreas", "Gland behind the stomach, its head in the C-loop of the duodenum. Exocrine part sends enzymes and HCO3- to the duodenum; islets release insulin and glucagon. A head tumor can block the bile duct.", "Half enzyme factory, half hormone lab. The overachiever of your abdomen.");
  partInfo("digestive", "duodenum", "Duodenum", "First, C-shaped part of the small intestine, about 25 cm long. Receives chyme from the stomach plus bile and pancreatic juice at the major duodenal papilla. Main site of iron absorption.", "Duodenum. Where acid meets bile and bicarbonate. A chemical bar fight, every meal.");
  partInfo("digestive", "small_intestine", "Small Intestine", "Jejunum and ileum: meters of coiled tube lined with circular folds, villi and microvilli where most nutrients are absorbed. The terminal ileum absorbs vitamin B12 and bile salts.", "Meters of spaghetti doing all the real absorbing. Stomach gets the fame, this does the work.");
  partInfo("digestive", "cecum", "Cecum", "Blind pouch at the start of the large intestine in the right lower quadrant. Receives contents from the ileum through the ileocecal valve; the appendix hangs from it.", "A cul-de-sac with a worm attached. Evolution was *burp* drunk that day.");
  partInfo("digestive", "appendix", "Appendix", "Narrow, blind-ended tube (vermiform appendix) attached to the cecum, rich in lymphoid tissue. Obstruction and inflammation cause appendicitis, classically with pain over McBurney point.", "Tiny, lymphoid, and occasionally explosive. The surgeon's favorite piece of you.");
  partInfo("digestive", "ascending_colon", "Ascending Colon", "Rises up the right side of the abdomen from the cecum to the hepatic (right colic) flexure under the liver. Retroperitoneal. Absorbs water and salts from the liquid leftovers.", "Ascending colon. Goes up on the right. If you need a hint beyond the name, I can't help you.");
  partInfo("digestive", "transverse_colon", "Transverse Colon", "Crosses the upper abdomen from the hepatic flexure to the splenic flexure, hung on its own mesentery (the transverse mesocolon). Absorbs water and electrolytes; supplied by both SMA and IMA.", "The hammock of your gut. Swings across the belly full of tomorrow's problems.");
  partInfo("digestive", "descending_colon", "Descending Colon", "Runs down the left side of the abdomen from the splenic flexure to the sigmoid colon. Retroperitoneal; supplied by the IMA. Stool gets firmer here as water is absorbed.", "Going down on the left. Stool's almost finished. Like a product nearing shipping.");
  partInfo("digestive", "sigmoid_colon", "Sigmoid Colon", "S-shaped loop in the lower left abdomen linking the descending colon to the rectum, on its own mesentery. Common site of diverticulosis and, in adults, of volvulus.", "S-shaped, floppy and prone to twisting. The drama queen of the colon.");
  partInfo("digestive", "rectum", "Rectum", "Final straight part of the large intestine, in the pelvis just above the anal canal. Stores stool; stretching its wall triggers the urge to defecate. Always involved in Hirschsprung disease.", "The waiting room before the exit. Stretch receptors tell you when it's time. Listen to them.");
}

void parts_heart() {
  partInfo("heart", "right_atrium", "Right Atrium", "Upper right chamber. Receives O2-poor blood from the superior and inferior venae cavae and the coronary sinus, and passes it through the tricuspid valve to the right ventricle. Contains the SA and AV nodes.", "The heart's waiting room for used blood. Grim, but somebody has to do it.");
  partInfo("heart", "right_ventricle", "Right Ventricle", "Lower right chamber, forming most of the heart's front surface behind the sternum. Pumps O2-poor blood through the pulmonary valve to the lungs at low pressure (about 25 mmHg systolic).", "A thin-walled pump for a short trip. The lungs are right next door, genius.");
  partInfo("heart", "left_atrium", "Left Atrium", "Upper left chamber and the most posterior part of the heart, lying against the esophagus. Receives O2-rich blood from the pulmonary veins and passes it through the mitral valve to the left ventricle.", "Left atrium: hides at the back like a kid who didn't do the *burp* homework.");
  partInfo("heart", "left_ventricle", "Left Ventricle", "Thick-walled lower left chamber that forms the apex. Pumps O2-rich blood through the aortic valve into the aorta at high pressure (about 120 mmHg systolic) to supply the whole body.", "The left ventricle. The only part of you that actually works out.");
  partInfo("heart", "superior_vena_cava", "Superior Vena Cava", "Large vein returning O2-poor blood from the head, neck, upper limbs and upper chest into the top of the right atrium.", "The upper drain. Everything from the neck up flows here, including whatever's left of your brain.");
  partInfo("heart", "inferior_vena_cava", "Inferior Vena Cava", "Largest vein in the body. Carries O2-poor blood from the legs, pelvis and abdomen up through the diaphragm (at about T8) into the bottom of the right atrium.", "Biggest vein you've got. Hauls blood uphill from your legs. Gravity hates it.");
  partInfo("heart", "aorta", "Aorta", "Largest artery. Rises from the left ventricle, arches over the heart and descends through the chest and abdomen, branching to deliver O2-rich blood to every organ.", "The main highway out of the heart. Every organ is an exit.");
  partInfo("heart", "pulmonary_trunk", "Pulmonary Trunk", "Short, wide artery leaving the right ventricle through the pulmonary valve. Splits into the right and left pulmonary arteries, which carry O2-poor blood to the lungs.", "An artery full of O2-poor blood. Anatomy's way of trolling first-years.");
  partInfo("heart", "pulmonary_veins", "Pulmonary Veins", "Usually four veins (two from each lung) returning O2-rich blood to the left atrium. Muscle sleeves around their openings are the usual trigger site of atrial fibrillation.", "Veins with oxygen in them. Break the rules, Morty-brain. Just not on the exam.");
  partInfo("heart", "tricuspid_valve", "Tricuspid Valve", "Right atrioventricular valve with three cusps, tethered by chordae tendineae to papillary muscles. Lets blood into the right ventricle and closes during systole (part of S1).", "Three flaps on parachute strings. Better engineering than Earth's entire aerospace industry.");
  partInfo("heart", "pulmonary_valve", "Pulmonary Valve", "Semilunar valve with three cusps between the right ventricle and the pulmonary trunk. Stops backflow into the right ventricle; heard best at the left 2nd intercostal space.", "The exit door for lung-bound blood. Closes with a click you call P2.");
  partInfo("heart", "mitral_valve", "Mitral Valve", "Left atrioventricular (bicuspid) valve with two cusps, between the left atrium and left ventricle. Anchored by chordae tendineae; heard best at the apex. Classic target of rheumatic fever.", "Two cusps, named after a bishop's hat. Medicine's naming committee was *burp* drunk. And I'd know.");
  partInfo("heart", "aortic_valve", "Aortic Valve", "Semilunar valve with three cusps between the left ventricle and the aorta. The coronary arteries arise just above it. Heard best at the right 2nd intercostal space.", "Guards the most important doorway in your body. Treat it better than your apartment door.");
  partInfo("heart", "interventricular_septum", "Interventricular Septum", "Wall between the ventricles: thick muscle plus a thin upper membranous part, the usual VSD site. Carries the bundle branches; its anterior two-thirds is supplied by the LAD.", "The wall between two pumps. Like the wall between me and caring about your feelings.");
  partInfo("heart", "sa_node", "SA Node", "Sinoatrial node: pacemaker tissue in the right atrial wall near the superior vena cava opening. Fires spontaneously about 60-100 times a minute and sets the normal sinus rhythm.", "Your built-in metronome. Let it quit and somebody has to wire a battery into your chest.");
  partInfo("heart", "av_node", "AV Node", "Atrioventricular node in the lower interatrial septum. Delays the impulse about 0.1 s so the ventricles can fill, then passes it to the bundle of His. Backup pacemaker at about 40-60/min.", "The AV node: professional procrastinator. For once, procrastinating *burp* saves lives.");
}

void parts_lungs() {
  partInfo("lungs", "larynx", "Larynx", "Voice box at the top of the trachea (about C3-C6). Its cartilages include the thyroid cartilage (Adam's apple); it houses the vocal folds and guards the airway with the epiglottis during swallowing.", "Voice box. Turns air into words. In your case, mostly *burp* the wrong words.");
  partInfo("lungs", "trachea", "Trachea", "Windpipe from the larynx (about C6) to the carina (about T4/T5), roughly 10-12 cm long. Held open by C-shaped cartilage rings that are open at the back, where the esophagus lies.", "A ribbed hose to your lungs. Respect the hose.");
  partInfo("lungs", "carina", "Carina", "Keel-shaped ridge at the bottom of the trachea where it splits into the two main bronchi, near the sternal angle (T4/T5). Its very sensitive lining triggers a strong cough.", "The fork in the road. Left or right, your peanut has a choice to make.");
  partInfo("lungs", "right_main_bronchus", "Right Main Bronchus", "Airway from the carina to the right lung. Wider, shorter and more vertical than the left, so aspirated objects usually end up on this side.", "The express lane to the right lung. Every foreign object's favorite slide.");
  partInfo("lungs", "left_main_bronchus", "Left Main Bronchus", "Airway from the carina to the left lung. Longer, narrower and more horizontal than the right; passes under the aortic arch and in front of the esophagus.", "Longer and skinnier, because the aorta is sitting on it. Rough neighborhood.");
  partInfo("lungs", "bronchioles", "Bronchioles", "Small airways (under about 1 mm) beyond the bronchi, with no cartilage; smooth muscle dominates their walls. Terminal bronchioles end the conducting zone; respiratory bronchioles begin gas exchange.", "Tiny tubes with no cartilage, all muscle and attitude. Squeeze too hard and you wheeze.");
  partInfo("lungs", "alveoli", "Alveoli", "Hundreds of millions of tiny air sacs wrapped in capillaries: the site of gas exchange. Lined by type I cells (thin exchange surface) and type II cells (surfactant).", "Where the actual magic happens. Everything else is just pipes, Morty-brain.");
  partInfo("lungs", "right_lung", "Right Lung", "Larger lung with 3 lobes (upper, middle, lower) divided by the horizontal and oblique fissures. A bit shorter than the left because the liver pushes the diaphragm up on the right.", "Three lobes. The overachiever. Basically the Rick of lungs.");
  partInfo("lungs", "left_lung", "Left Lung", "Smaller lung with 2 lobes (upper and lower) divided by the oblique fissure. Its upper lobe carries the cardiac notch and the lingula, making room for the heart.", "Two lobes and a heart-shaped dent. Sentimental little organ.");
  partInfo("lungs", "cardiac_notch", "Cardiac Notch", "Indentation in the front border of the left lung's upper lobe where the heart lies closest to the chest wall; the lingula sits just below it.", "A dent made just for the heart. Romantic, if lungs had feelings. They don't. Neither do I.");
  partInfo("lungs", "diaphragm", "Diaphragm", "Dome-shaped muscle separating the thorax from the abdomen; the main muscle of breathing. Contracts and flattens to inhale. Motor supply: the phrenic nerves (C3-C5).", "The plunger under your lungs. C3-4-5 keeps it alive. *burp* Write that on your hand.");
}

void parts_muscles() {
  partInfo("muscles", "sternocleidomastoid", "Sternocleidomastoid", "Neck muscle from the sternum and clavicle to the mastoid process. One side tilts the head to the same side and turns the face to the opposite side; both flex the neck. Nerve: CN XI. Short in torticollis.", "Turn your head to look at me. That's this muscle. Also the one that seizes up when you sleep weird.");
  partInfo("muscles", "trapezius", "Trapezius", "Large flat upper-back muscle (the pair forms a diamond) from the skull and spine to the clavicle and scapula. Elevates (shrugs), retracts and rotates the scapula. Nerve: CN XI.", "Shrug muscle. Your default response to every question I ask.");
  partInfo("muscles", "deltoid", "Deltoid", "Triangular muscle capping the shoulder, from the clavicle, acromion and scapular spine to the humerus. Main abductor of the arm (beyond about 15 degrees). Nerve: axillary.", "Shoulder cap. Shaped like a Greek delta, hence deltoid. Even the alphabet's smarter than you.");
  partInfo("muscles", "pectoralis_major", "Pectoralis major", "Fan-shaped chest muscle from the clavicle, sternum and costal cartilages to the humerus. Adducts and medially rotates the arm; its clavicular head helps flex it.", "Pecs. Bros worship them. I just see a big flappy *burp* lever.");
  partInfo("muscles", "biceps_brachii", "Biceps brachii", "Two-headed muscle on the front of the upper arm, inserting on the radial tuberosity. Flexes the elbow and is the strongest supinator of the forearm. Nerve: musculocutaneous.", "Two heads, one muscle. Two more heads than your whole study group combined.");
  partInfo("muscles", "forearm_flexors", "Forearm flexors", "Anterior forearm muscles; the superficial ones share a common origin on the medial epicondyle. They flex the wrist and fingers; mostly median nerve, partly ulnar. Overuse causes golfer's elbow.", "Grip muscles. Hold a test tube, hold a flask. Mostly the flask.");
  partInfo("muscles", "rectus_abdominis", "Rectus abdominis", "Paired vertical muscle from the pubis to the xiphoid and costal cartilages 5-7, crossed by tendinous intersections (the six-pack). Flexes the trunk and compresses the abdomen.", "Six-pack. Everyone's got one. Most are hiding under a layer of *burp* life choices.");
  partInfo("muscles", "external_oblique", "External oblique", "Most superficial lateral abdominal muscle; fibers run down and medially. Flexes and rotates the trunk; the lower edge of its aponeurosis forms the inguinal ligament.", "Side abs. The twisting muscle. Also builds the inguinal ligament, aka hernia highway.");
  partInfo("muscles", "quadriceps_femoris", "Quadriceps femoris", "Four muscles on the front of the thigh (rectus femoris, vastus lateralis, medialis, intermedius) joining via the patella and patellar ligament. Extends the knee; rectus femoris also flexes the hip. Nerve: femoral.", "Four heads, one tendon, one main job: kick. The knee-jerk reflex tests it. Tap, kick, done.");
  partInfo("muscles", "adductors", "Adductors", "Medial thigh muscle group (adductor longus, brevis, magnus, plus gracilis and pectineus). Pulls the thigh toward the midline. Nerve: mainly obturator.", "Groin muscles. The ones you pull trying to look cool on a dance floor.");
  partInfo("muscles", "sartorius", "Sartorius", "Longest muscle in the body: a strap from the anterior superior iliac spine to the medial tibia. Flexes, abducts and laterally rotates the hip; flexes the knee. Nerve: femoral.", "Tailor's muscle. Sit cross-legged and it's working. Unlike you.");
  partInfo("muscles", "tibialis_anterior", "Tibialis anterior", "Muscle on the front of the shin, inserting on the medial foot. Main dorsiflexor and an inverter of the foot. Nerve: deep fibular; its paralysis causes foot drop.", "Lifts your toes so you don't trip. Foot drop is what happens when it quits. Slap, slap.");
  partInfo("muscles", "gastrocnemius", "Gastrocnemius", "Two-headed superficial calf muscle from the femoral condyles to the calcaneus via the calcaneal (Achilles) tendon. Plantarflexes the foot and helps flex the knee. Nerve: tibial.", "Calf muscle. Tiptoes, jumping, running from your problems. Very versatile.");
}

void parts_nephron() {
  partInfo("nephron", "afferent_arteriole", "Afferent Arteriole", "Arteriole that brings blood INTO the glomerulus. Its wall contains the renin-secreting juxtaglomerular cells; dilating it raises glomerular pressure and GFR.", "The inlet valve. Open it, more filtering. Close it, less. Even you can run a faucet.");
  partInfo("nephron", "efferent_arteriole", "Efferent Arteriole", "Carries blood OUT of the glomerulus into the peritubular capillaries and vasa recta. Constricting it (e.g. by angiotensin II) raises glomerular pressure and filtration fraction.", "The outlet valve. Squeeze it and pressure backs up into the glomerulus. *burp* Hydraulics, baby.");
  partInfo("nephron", "glomerulus", "Glomerulus", "Tuft of fenestrated capillaries inside Bowman's capsule where plasma is filtered. The filter (endothelium, basement membrane, podocytes) holds back blood cells and most proteins.", "About a million of these capillary hairballs per kidney, filtering 180 liters a day. Gross and magnificent.");
  partInfo("nephron", "bowmans_capsule", "Bowman's Capsule", "Double-walled cup around the glomerulus. Its inner layer is made of podocytes; filtrate collects in Bowman's space and flows into the proximal tubule.", "The catcher's mitt for filtrate. Named after a Victorian guy. Not a bowling pun.");
  partInfo("nephron", "proximal_tubule", "Proximal Tubule", "First tubule segment, lined with brush-border cells packed with mitochondria. Reabsorbs about 2/3 of filtered Na+ and water, nearly all glucose and amino acids, and most HCO3-.", "The nephron's workhorse. Takes back the good stuff before you pee it away.");
  partInfo("nephron", "descending_limb", "Descending Limb", "Thin descending limb of the loop of Henle, dipping into the medulla. Permeable to water but not much NaCl, so water leaves and the fluid gets more concentrated.", "Water out, salt stays. Brine by the bottom. Pickle Rick's favorite tube.");
  partInfo("nephron", "ascending_limb", "Ascending Limb", "Ascending limb of the loop of Henle. Its thick part pumps out NaCl via NKCC2 but is water-tight, diluting the fluid and salting the medulla. Target of loop diuretics.", "Salt pump, waterproof walls. Builds the gradient that lets you make concentrated pee.");
  partInfo("nephron", "distal_tubule", "Distal Tubule", "Distal convoluted tubule. Reabsorbs NaCl via the Na+-Cl- cotransporter (blocked by thiazides) and Ca2+ under PTH control; its early part is water-impermeable.", "Fine-tuning department. Thiazides and PTH both meddle here.");
  partInfo("nephron", "macula_densa", "Macula Densa", "Plaque of tightly packed cells at the end of the thick ascending limb, touching its own glomerulus's arterioles. Senses tubular NaCl to adjust GFR (tubuloglomerular feedback) and renin.", "A salt sensor that snitches to the arterioles. Your nephron has *burp* internal affairs.");
  partInfo("nephron", "collecting_duct", "Collecting Duct", "Final tubes draining many nephrons to the renal papilla. Principal cells reabsorb Na+ (aldosterone) and water (ADH via aquaporin-2); intercalated cells handle acid-base.", "Last chance to tweak the urine. ADH and aldosterone fight over what you keep here.");
}

void parts_neuron() {
  partInfo("neuron", "dendrite", "Dendrites", "Branched extensions of the neuron that receive incoming signals, mostly at synapses on their surface, and carry them toward the cell body.", "Dendrites: the listening branches. More receptive than you'll ever be.");
  partInfo("neuron", "soma", "Soma (Cell Body)", "The neuron's cell body. Contains the nucleus and most organelles, including clumps of rough ER (Nissl substance), and integrates the incoming signals.", "The cell body. Where the neuron keeps its nucleus and its *burp* priorities.");
  partInfo("neuron", "nucleus", "Nucleus", "Holds the neuron's DNA. Mature neurons generally do not divide. Typically large and pale with a prominent nucleolus, reflecting heavy protein synthesis.", "DNA headquarters. Neurons mostly never divide again. Commitment issues? Not them.");
  partInfo("neuron", "axon_hillock", "Axon Hillock", "Cone-shaped region where the axon leaves the soma. The initial segment just beyond it is packed with voltage-gated Na+ channels, so action potentials usually start in this zone.", "Trigger zone. All the inputs get summed here, then it decides: fire or not. Binary. Respect.");
  partInfo("neuron", "axon", "Axon", "The single long process that conducts action potentials away from the cell body to the axon terminals. Some axons are about 1 m long, from the spinal cord to the foot.", "The long cable. Some run from your spine to your toes. Longer than your attention span, easily.");
  partInfo("neuron", "myelin_sheath", "Myelin Sheath", "Fatty insulating wrap made by Schwann cells (PNS) or oligodendrocytes (CNS). It raises membrane resistance and lowers capacitance, so impulses jump node to node much faster.", "Fatty insulation. Makes signals fast. Fat being useful for once, Morty-brain.");
  partInfo("neuron", "node_of_ranvier", "Node of Ranvier", "Short gaps between myelin segments, packed with voltage-gated Na+ channels. The action potential regenerates here and jumps from node to node (saltatory conduction).", "Gaps where the spike recharges and hops. Portal tech, biological edition.");
  partInfo("neuron", "axon_terminal", "Axon Terminal", "Swollen end of an axon branch filled with neurotransmitter vesicles. Ca2+ entering through voltage-gated channels triggers vesicle fusion and transmitter release.", "Where the electrical signal turns chemical. Calcium pulls the *burp* trigger.");
  partInfo("neuron", "synapse", "Synapse", "Junction where a neuron passes its signal to another cell: presynaptic terminal, a narrow synaptic cleft (roughly 20-40 nm), and a postsynaptic membrane with receptors.", "The gap where neurons talk without touching. Like you and social skills.");
}

void parts_organ_map() {
  partInfo("organ_map", "brain", "Brain", "Control center of the nervous system. Its hypothalamus is also an endocrine organ: it makes releasing and inhibiting hormones for the pituitary plus ADH and oxytocin. The pineal gland makes melatonin.", "The hypothalamus is in here pulling the pituitary's strings. Yours has strings, I've just never seen them move.");
  partInfo("organ_map", "pituitary", "Pituitary Gland", "Pea-sized gland below the hypothalamus in a bony pocket (sella turcica). Anterior lobe: GH, TSH, ACTH, FSH, LH, prolactin. Posterior lobe releases ADH and oxytocin.", "Pea-sized dictator under the brain. Respect the pea.");
  partInfo("organ_map", "thyroid", "Thyroid Gland", "Butterfly-shaped gland in front of the trachea, below the larynx. Follicular cells make T4 and T3 (metabolic rate); parafollicular C cells make calcitonin.", "Neck butterfly. Sets your idle speed. Yours idles at Jerry.");
  partInfo("organ_map", "thymus", "Thymus", "Gland in the upper chest behind the sternum, where T cells mature and learn self-tolerance. Large in children, mostly replaced by fat in adults; makes thymic hormones (thymosins).", "T-cell boot camp. Shrinks with age, like your excuses should.");
  partInfo("organ_map", "heart", "Heart", "Muscular pump in the middle of the chest. Also endocrine: stretched atria release atrial natriuretic peptide (ANP), which promotes Na+ and water excretion.", "Pump with a hormone side gig. Overfill it and it yells ANP at the kidneys.");
  partInfo("organ_map", "lungs", "Lungs", "Paired gas-exchange organs in the chest. Their capillary endothelium is rich in angiotensin-converting enzyme (ACE), a major site where angiotensin I becomes angiotensin II.", "Air bags with an ACE up their sleeve. Literally. Angiotensin I in, angiotensin II out.");
  partInfo("organ_map", "liver", "Liver", "Largest internal organ, upper right abdomen. Stores glycogen, makes bile and plasma proteins. Hormone-wise it makes IGF-1 (in response to GH), angiotensinogen and hepcidin.", "The body's chemical plant. Mine's been working *burp* overtime since roughly forever.");
  partInfo("organ_map", "stomach", "Stomach", "J-shaped organ in the upper left abdomen. Secretes acid and pepsinogen; G cells make gastrin (boosts acid), and the stomach is the main source of ghrelin, the hunger hormone.", "Acid pit that growls for food via ghrelin. Mine growls for Szechuan sauce.");
  partInfo("organ_map", "spleen", "Spleen", "Upper left abdomen, behind the stomach. Largest lymphoid organ: filters blood, removes old red blood cells and fights blood-borne bacteria, especially encapsulated ones.", "Blood filter and red-cell graveyard. Lose it and encapsulated bacteria throw a party.");
  partInfo("organ_map", "pancreas", "Pancreas", "Behind the stomach. The exocrine part makes digestive enzymes; the islets of Langerhans make insulin (beta cells), glucagon (alpha cells) and somatostatin (delta cells).", "Enzymes out one door, insulin out the other. Two jobs, zero complaints. Learn from it.");
  partInfo("organ_map", "adrenal_glands", "Adrenal Glands", "One on top of each kidney. Cortex: aldosterone, cortisol and androgens. Medulla: epinephrine and norepinephrine.", "Tiny hats on the kidneys pumping stress hormones. Mine are *burp* permanently maxed.");
  partInfo("organ_map", "kidneys", "Kidneys", "Paired organs at the back of the upper abdomen. They filter blood into urine and release renin, erythropoietin (EPO) and active vitamin D (calcitriol).", "Filters that moonlight as hormone factories: renin, EPO, vitamin D. Overachievers.");
  partInfo("organ_map", "small_intestine", "Small Intestine", "Several meters of tube (duodenum, jejunum, ileum) where most digestion and absorption happen. Its cells release gut hormones such as secretin, CCK and GIP.", "Where food actually gets absorbed. Meters of gut doing your nutritional *burp* homework.");
  partInfo("organ_map", "large_intestine", "Large Intestine", "Cecum, colon and rectum. Absorbs water and electrolytes, houses gut bacteria (some make vitamin K), and forms and stores feces.", "Water reclaimer and bacteria hotel. Also the end of the line. Like this conversation, soon.");
  partInfo("organ_map", "bladder", "Urinary Bladder", "Hollow muscular sac in the pelvis that stores urine from the ureters. Its detrusor muscle contracts (parasympathetic) to empty it through the urethra.", "A stretchy bag for pee. Not complicated. Even you got this one, right?");
  partInfo("organ_map", "lymph_nodes", "Lymph Nodes", "Bean-shaped filters along lymphatic vessels, clustered in the neck, armpits, groin and abdomen. B and T cells meet antigens here; nodes swell during infections.", "Immune checkpoints. Swollen nodes mean the immune system's busy. Busier than you, anyway.");
}

void parts_skeleton() {
  partInfo("skeleton", "skull", "Skull", "Bony case of the head: cranial and facial bones joined by sutures, plus the movable mandible. Protects the brain and houses the eyes, inner ears and teeth.", "A helmet you can't take off, protecting the most underused organ you own.");
  partInfo("skeleton", "mandible", "Mandible", "The lower jaw, the largest and strongest facial bone. It holds the lower teeth and is the only skull bone with a freely movable joint (the temporomandibular joint).", "Jaw bone. Used for chewing and for saying things I didn't ask about.");
  partInfo("skeleton", "clavicle", "Clavicle", "The collarbone: an S-shaped strut from the sternum to the acromion of the scapula. Holds the arm out from the trunk; one of the most commonly fractured bones.", "Collarbone. The coat hanger your arm dangles from. Snaps when you fall off stuff. Like you will.");
  partInfo("skeleton", "scapula", "Scapula", "The flat, triangular shoulder blade on the back of the rib cage. Its glenoid cavity forms the shoulder joint with the humerus; it anchors the rotator cuff muscles.", "Shoulder blade. Wings for people who never evolved actual wings. *burp* Sad.");
  partInfo("skeleton", "sternum", "Sternum", "The flat breastbone in the front of the chest (manubrium, body, xiphoid process). The clavicles and the costal cartilages of ribs 1-7 attach to it.", "Your chest's front door. CPR knocks on it. Hard.");
  partInfo("skeleton", "ribs", "Ribs", "12 pairs of curved bones joined to the thoracic vertebrae. Pairs 1-7 are true ribs; 8-12 are false ribs, of which 11-12 float. With the sternum they form the rib cage around the heart and lungs.", "A cage for your heart and lungs that flexes every time you breathe. A prison with a gym.");
  partInfo("skeleton", "humerus", "Humerus", "The long bone of the upper arm, from shoulder to elbow. The axillary nerve wraps its surgical neck; the radial nerve runs in a groove on its shaft.", "The 'funny bone' is your ulnar nerve, not a bone. 'Humerus' is just a pun. *burp* Hilarious.");
  partInfo("skeleton", "radius", "Radius", "The lateral (thumb-side) forearm bone. It rotates around the ulna to turn the palm up and down; its distal end is the site of the classic Colles fracture.", "Radius rolls around the ulna so you can flip your palm. Like flipping off physics.");
  partInfo("skeleton", "ulna", "Ulna", "The medial (pinky-side) forearm bone. Its olecranon forms the point of the elbow, and its trochlear notch makes the hinge joint with the humerus.", "Ulna: the elbow's pointy end. Bang it and your ulnar nerve screams. Good times.");
  partInfo("skeleton", "carpals", "Carpals", "The 8 wrist bones in two rows: scaphoid, lunate, triquetrum, pisiform; trapezium, trapezoid, capitate, hamate. They form the floor of the carpal tunnel.", "Eight pebbles in a bag of ligaments, and you type on them all day like they owe you money.");
  partInfo("skeleton", "metacarpals", "Metacarpals", "The 5 long bones of the palm, numbered 1 (thumb) to 5 (little finger). Punching can break the neck of the 5th metacarpal (boxer's fracture).", "Boxer's fracture: break your 5th metacarpal punching a wall. The wall wins. Always.");
  partInfo("skeleton", "phalanges_hand", "Phalanges (hand)", "The 14 finger bones: two in the thumb (proximal, distal) and three in each other finger (proximal, middle, distal).", "Fourteen finger bones. Count them. Use your fingers. That's what they're for.");
  partInfo("skeleton", "vertebral_column", "Vertebral column", "The spine: 7 cervical, 12 thoracic and 5 lumbar vertebrae plus the sacrum and coccyx, cushioned by intervertebral discs. Supports the trunk and protects the spinal cord.", "About 33 vertebrae stacked like *burp* poker chips, guarding your spinal cord. Mostly.");
  partInfo("skeleton", "pelvis", "Pelvis", "Bony basin of the two hip bones (each a fused ilium, ischium and pubis) with the sacrum and coccyx. Carries weight to the legs and protects pelvic organs; its acetabulum holds the femoral head.", "A bony bowl that keeps your guts in and your legs on. Engineering, baby.");
  partInfo("skeleton", "sacrum", "Sacrum", "Triangular bone of 5 fused sacral vertebrae at the base of the spine. It joins the hip bones at the sacroiliac joints and passes body weight to the pelvis.", "Five vertebrae that gave up their independence and fused. Strength in numbers.");
  partInfo("skeleton", "femur", "Femur", "The thigh bone, longest and strongest in the body. Its head sits in the acetabulum (hip joint) and its condyles form the knee with the tibia. The femoral neck is a common fracture site in older adults.", "Biggest bone you own. Snap it and you're not walking anywhere for a while, champ.");
  partInfo("skeleton", "patella", "Patella", "The kneecap, the largest sesamoid bone, embedded in the quadriceps tendon. It improves the leverage of the quadriceps for knee extension and shields the knee joint.", "A bone that grew inside a tendon. Like a pearl, but for your knee.");
  partInfo("skeleton", "tibia", "Tibia", "The shin bone: the medial, weight-bearing bone of the leg. It forms the knee above and the ankle (with its medial malleolus) below; its front edge lies just under the skin.", "Shin bone. You find it with the coffee table in the dark. Every time.");
  partInfo("skeleton", "fibula", "Fibula", "The thin lateral bone of the leg. It bears little weight but anchors muscles and forms the lateral malleolus of the ankle. The common fibular nerve wraps around its neck.", "Skinny and barely carries weight, but whack its neck and your foot flops. Underrated, like me.");
  partInfo("skeleton", "tarsals", "Tarsals", "The 7 bones of the ankle and rear foot: talus, calcaneus, navicular, cuboid and three cuneiforms. The talus forms the ankle joint; the calcaneus is the heel.", "Seven tarsals, and the calcaneus takes all the abuse. Heel bone. Achilles tendon's anchor.");
  partInfo("skeleton", "metatarsals", "Metatarsals", "The 5 long bones of the forefoot between the tarsals and the toes. Classic sites of stress ('march') fractures and of fractures at the base of the 5th metatarsal.", "Long foot bones. Run too much and they crack. Exercise: *burp* overrated.");
  partInfo("skeleton", "phalanges_foot", "Phalanges (foot)", "The 14 toe bones: two in the big toe (hallux) and three in each of the other toes.", "Toe bones. Same count as fingers, way less useful. Unless you're a monkey. Are you?");
}


// ======================================================================
// TAB: Dia_Brain.pde
// ======================================================================
// Brain, LEFT lateral view: the front of the brain faces the viewer's LEFT.
// Cerebrum with its four lobes (frontal blue, parietal yellow, temporal green,
// occipital pink), the central sulcus between frontal and parietal, the lateral
// (Sylvian) fissure above the temporal lobe, the precentral (motor) and
// postcentral (sensory) gyri in deeper shades of their lobes, Broca's and
// Wernicke's language areas in orange, the cerebellum tucked under the occipital
// lobe, and the brainstem (pons, medulla) continuing into the spinal cord.
// All geometry is built once in design units, then shifted by (OX, OY) for both
// the art and the hit polygons so they always match.

class BrainDiagram extends Diagram {
  final float OX = 2, OY = -8;

  final int C_FRONT = #A9C7EF, C_PRE = #7C9FE6, C_PARI = #F6DA8C, C_POST = #EDB94F;
  final int C_TEMP = #AEDAA4, C_OCC = #F4AEC1, C_LANG = #F5965F, C_LANG_DK = #B9541F;
  final int C_CBL = #CDB5E8, C_CBL_DK = #8D70B6;
  final int C_PONS = #EDC5A4, C_MED = #E3B290, C_STEM_DK = #A9775A, C_CORD = #F3DDA9, C_CORD_DK = #C9A866;

  float[] OUT, LAT, CEN, CENX, PRE_S, POST_S, PO, PT, STS, ITS;
  float[] frontalP, parietalP, temporalP, occipitalP, preP, postP, brocaP, wernP;
  float[] cblP, ponsP, medP, cordC, cordP;
  float[][] minor;      // secondary sulci (decoration)
  int lAsc;             // LAT index where the anterior ascending ramus leaves

  BrainDiagram() {
    super("brain", "Brain (left side)");
    build();
    add("spinal_cord", "Spinal Cord").poly(band(cordC, 34, 30)).anchor(358, 560);
    add("medulla", "Medulla Oblongata").poly(cp(medP)).anchor(348, 494);
    add("pons", "Pons").poly(cp(ponsP)).anchor(332, 436);
    add("cerebellum", "Cerebellum").poly(cp(cblP)).anchor(474, 428);
    add("frontal_lobe", "Frontal Lobe").poly(cp(frontalP)).anchor(150, 152);
    add("parietal_lobe", "Parietal Lobe").poly(cp(parietalP)).anchor(410, 142);
    add("temporal_lobe", "Temporal Lobe").poly(cp(temporalP)).anchor(236, 352);
    add("occipital_lobe", "Occipital Lobe").poly(cp(occipitalP)).anchor(510, 268);
    // the three neighbouring landmarks get anchors staggered top / middle / lower so their tags don't stack
    float[] a = mid(PRE_S, CEN, 0.28);
    add("precentral_gyrus", "Precentral Gyrus").poly(cp(preP)).anchor(a[0], a[1]);
    float[] b = mid(POST_S, CEN, 0.66);
    add("postcentral_gyrus", "Postcentral Gyrus").poly(cp(postP)).anchor(b[0], b[1]);
    add("broca_area", "Broca's Area").poly(cp(brocaP)).anchor(184, 248);
    add("wernicke_area", "Wernicke's Area").poly(cp(wernP)).anchor(350, 288);
    float[] cs = cat(CEN, new float[] { CENX[CENX.length - 2], CENX[CENX.length - 1] });
    int nc = CEN.length / 2;
    add("central_sulcus", "Central Sulcus").poly(band(extend(CEN, 1, 0), 18, 18)).anchor(CEN[(nc / 2) * 2], CEN[(nc / 2) * 2 + 1]);
    int nl = LAT.length / 2;
    add("lateral_sulcus", "Lateral Sulcus").poly(band(extend(LAT, 0, 3), 18, 16)).anchor(LAT[(nl * 2 / 5) * 2], LAT[(nl * 2 / 5) * 2 + 1]);
    // every hit polygon (and anchor) moves with the artwork
    for (Part p : parts) {
      for (float[] s : p.shapes) for (int i = 0; i < s.length; i += 2) {
        s[i] += OX;
        s[i + 1] += OY;
      }
      if (p.ax >= 0) {
        p.ax += OX;
        p.ay += OY;
      }
    }
  }

  // ------------------------------------------------------------ geometry (design units)
  void build() {
    OUT = crC(new float[] { 46, 232, 56, 168, 92, 112, 150, 76, 225, 56, 305, 52, 385, 64, 455, 96, 510, 145, 543, 205, 552, 258, 540, 302,
      508, 336, 458, 360, 400, 382, 335, 398, 268, 402, 205, 394, 160, 375, 132, 348, 134, 322, 150, 307, 128, 301, 96, 293, 66, 276 }, 14);
    OUT = bumpy(OUT);
    int iN0 = nearest(OUT, 150, 307), iCT = nearest(OUT, 322, 54), iPreT = nearest(OUT, 282, 53), iPostT = nearest(OUT, 362, 58);
    int iPO0 = nearest(OUT, 478, 106), iPO1 = nearest(OUT, 450, 364);
    LAT = crO(new float[] { OUT[iN0 * 2], OUT[iN0 * 2 + 1], 176, 297, 200, 291, 260, 280, 320, 270, 365, 262, 384, 250, 392, 232 }, 10);
    CEN = wig(crO(new float[] { OUT[iCT * 2], OUT[iCT * 2 + 1], 314, 82, 306, 104, 302, 128, 291, 156, 284, 182, 270, 208, 258, 236, 245, 262 }, 8), 1.4, 44, 0.5);
    int lC2 = nearest(LAT, 241, 283), lPb = nearest(LAT, 200, 291), lQb = nearest(LAT, 284, 276), lL2 = nearest(LAT, 365, 262);
    int lB0 = nearest(LAT, 166, 299), lW0 = nearest(LAT, 300, 273);
    lAsc = nearest(LAT, 182, 295);
    CENX = new float[] { CEN[CEN.length - 2], CEN[CEN.length - 1], LAT[lC2 * 2], LAT[lC2 * 2 + 1] };
    PRE_S = crO(new float[] { OUT[iPreT * 2], OUT[iPreT * 2 + 1], 274, 82, 266, 108, 260, 134, 250, 160, 242, 186, 228, 212, 216, 240, 205, 266,
      LAT[lPb * 2], LAT[lPb * 2 + 1] }, 8);
    PRE_S = wig(PRE_S, 1.2, 38, 2.1);
    POST_S = crO(new float[] { OUT[iPostT * 2], OUT[iPostT * 2 + 1], 354, 84, 347, 110, 342, 136, 332, 162, 324, 188, 311, 214, 299, 240, 289, 262,
      LAT[lQb * 2], LAT[lQb * 2 + 1] }, 8);
    POST_S = wig(POST_S, 1.2, 38, 4.0);
    PO = crO(new float[] { OUT[iPO0 * 2], OUT[iPO0 * 2 + 1], 473, 160, 467, 215, 461, 275, 455, 325, OUT[iPO1 * 2], OUT[iPO1 * 2 + 1] }, 10);
    int jPO = nearest(PO, 461, 276);
    PT = crO(new float[] { LAT[lL2 * 2], LAT[lL2 * 2 + 1], 395, 266, 428, 272, PO[jPO * 2], PO[jPO * 2 + 1] }, 10);
    STS = wig(crO(new float[] { 160, 334, 220, 323, 280, 315, 330, 307, 378, 298, 410, 285, 428, 262 }, 10), 1.3, 34, 1.0);
    ITS = wig(crO(new float[] { 182, 368, 240, 363, 300, 358, 360, 350, 412, 338 }, 8), 1.3, 32, 2.5);
    int nP = PO.length / 2, nT = PT.length / 2, nC = CEN.length / 2, nPre = PRE_S.length / 2, nPost = POST_S.length / 2;

    frontalP = cat(arcF(OUT, iN0, iCT), CEN, CENX, seg(LAT, lC2, 0));
    parietalP = cat(arcF(OUT, iCT, iPO0), seg(PO, 0, jPO), seg(PT, nT - 1, 0), seg(LAT, lL2, lC2), rev(CENX), seg(CEN, nC - 1, 0));
    temporalP = cat(seg(LAT, 0, lL2), PT, seg(PO, jPO, nP - 1), arcF(OUT, iPO1, iN0));
    occipitalP = cat(arcF(OUT, iPO0, iPO1), seg(PO, nP - 1, 0));
    preP = cat(arcF(OUT, iPreT, iCT), CEN, CENX, seg(LAT, lC2, lPb), seg(PRE_S, nPre - 1, 0));
    postP = cat(arcF(OUT, iCT, iPostT), POST_S, seg(LAT, lQb, lC2), rev(CENX), seg(CEN, nC - 1, 0));
    int pTop = nearest(PRE_S, 229, 212);
    brocaP = cat(seg(LAT, lB0, lPb), seg(PRE_S, nPre - 1, pTop), crO(new float[] { 222, 216, 200, 215, 174, 214, 152, 221, 140, 244, 146, 270, 158, 291 }, 4));
    int s1 = nearest(STS, 394, 293), s0 = nearest(STS, 300, 312), t1 = nearest(PT, 396, 266);
    wernP = cat(seg(LAT, lW0, lL2), seg(PT, 0, t1), new float[] { 404, 278 }, seg(STS, s1, s0));

    cblP = crC(new float[] { 370, 414, 386, 384, 420, 360, 470, 344, 515, 326, 542, 318, 556, 344, 556, 396, 534, 440, 496, 464, 450, 474, 410, 466, 384, 446 }, 8);
    ponsP = crC(new float[] { 318, 386, 298, 402, 292, 426, 300, 450, 324, 463, 356, 466, 382, 452, 390, 424, 382, 396, 352, 384 }, 6);
    medP = crC(new float[] { 330, 452, 324, 474, 329, 496, 338, 514, 345, 530, 367, 530, 373, 513, 380, 490, 382, 468, 378, 452 }, 6);
    cordC = new float[] { 356, 518, 359, 552, 362, 584 };
    cordP = band(cordC, 27, 24);

    float[][] mc = {
      // frontal: superior + inferior frontal sulci and their side branches, middle frontal minors, frontal pole, orbital
      { 262, 98, 222, 104, 176, 100, 132, 112, 100, 138 }, { 196, 102, 200, 80 }, { 142, 108, 130, 88 },
      { 230, 201, 192, 206, 152, 201, 112, 212, 84, 236 }, { 168, 203, 172, 184 },
      { 220, 150, 190, 160, 160, 150, 128, 162 }, { 92, 172, 112, 184, 108, 196 }, { 238, 120, 226, 136 },
      { 64, 196, 80, 206, 72, 226 }, { 84, 268, 114, 283 }, { 102, 248, 124, 254 },
      // anterior horizontal + ascending rami of the lateral sulcus (frame Broca's area)
      { LAT[lB0 * 2], LAT[lB0 * 2 + 1], 146, 291, 124, 290 },
      { LAT[lAsc * 2], LAT[lAsc * 2 + 1], 180, 268, 174, 246 },
      // parietal: intraparietal sulcus, superior parietal minors, supramarginal + angular arcs
      { 340, 150, 370, 168, 404, 168, 438, 180, 456, 204 }, { 378, 106, 404, 120, 432, 114 }, { 420, 140, 446, 150 },
      { 366, 228, 388, 212, 412, 218, 420, 240 }, { 436, 214, 452, 236, 446, 258 }, { 404, 86, 428, 98 },
      // temporal: minors between the superior and inferior temporal sulci, inferior surface
      { 196, 346, 236, 341 }, { 290, 338, 330, 332 }, { 368, 330, 396, 324 }, { 230, 384, 270, 386 }, { 330, 382, 360, 376 },
      // occipital
      { 480, 236, 506, 231, 536, 245 }, { 474, 302, 500, 292, 528, 304 }, { 490, 160, 518, 186 }, { 508, 330, 528, 316 }
    };
    minor = new float[mc.length + 4][];
    for (int i = 0; i < mc.length; i++) minor[i] = wig(crO(mc[i], 6), 1.2, 30, i * 1.7);
    minor[mc.length] = STS;
    minor[mc.length + 1] = ITS;
    minor[mc.length + 2] = PRE_S;
    minor[mc.length + 3] = POST_S;
  }

  float[] mid(float[] a, float[] b, float f) {
    float[] p = ptAt(a, f), q = ptAt(b, f);
    return new float[] { (p[0] + q[0]) / 2, (p[1] + q[1]) / 2 };
  }

  float[] ptAt(float[] a, float f) {
    int i = round(f * (a.length / 2 - 1));
    return new float[] { a[i * 2], a[i * 2 + 1] };
  }

  // ------------------------------------------------------------ art
  void drawArt(PGraphics g) {
    g.pushMatrix();
    g.translate(OX, OY);
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    // soft drop shadow of the whole brain
    g.noStroke();
    g.fill(0, 0, 0, 22);
    g.pushMatrix();
    g.translate(5, 7);
    shp(g, OUT);
    shp(g, cblP);
    shp(g, ponsP);
    shp(g, medP);
    shp(g, cordP);
    g.popMatrix();
    drawStem(g);
    drawCerebellum(g);
    drawCerebrum(g);
    g.popMatrix();
  }

  void drawStem(PGraphics g) {
    // spinal cord
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_CORD);
    shp(g, cordP);
    g.noStroke();
    g.fill(255, 255, 255, 80);
    shp(g, band(shiftP(cordC, -5, 0), 6, 5));
    g.noFill();
    g.stroke(C_CORD_DK);
    g.strokeWeight(1.3);
    pl(g, shiftP(cordC, 6, 0));
    // cut end of the cord with its butterfly of grey matter
    float ex = cordC[4], ey = cordC[5];
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(lerpColor(C_CORD, #FFFFFF, 0.35));
    g.ellipse(ex, ey, 25, 9);
    g.noStroke();
    g.fill(#D9B9A6);
    g.ellipse(ex - 4.5, ey, 7, 5);
    g.ellipse(ex + 4.5, ey, 7, 5);
    g.rect(ex - 4, ey - 1, 8, 2);
    // medulla, with its olive bulge
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_MED);
    shp(g, medP);
    rim(g, medP, 8, 60, 70);
    g.stroke(C_STEM_DK);
    g.strokeWeight(1.4);
    g.fill(lerpColor(C_MED, #FFFFFF, 0.28));
    g.ellipse(358, 486, 14, 32);
    g.noFill();
    pl(g, crO(new float[] { 340, 458, 337, 480, 340, 502, 346, 522 }, 6));
    // pons: a rounded anterior bulge with transverse fibres
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_PONS);
    shp(g, ponsP);
    g.stroke(lerpColor(C_PONS, C_STEM_DK, 0.55));
    g.strokeWeight(1.3);
    for (float y = 398; y < 462; y += 8) {
      float[] xs = spanAt(ponsP, y);
      if (xs == null) continue;
      g.beginShape();
      for (int i = 0; i <= 10; i++) {
        float x = lerp(xs[0] + 4, xs[1] - 4, i / 10.0);
        g.vertex(x, y + 3 * sin(PI * i / 10.0));
      }
      g.endShape();
    }
    rim(g, ponsP, 9, 60, 80);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    shp(g, ponsP);
  }

  void drawCerebellum(PGraphics g) {
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_CBL);
    shp(g, cblP);
    // folia: thin leaves converging toward the anterior tip (the peduncle side) and fanning out to meet the
    // posterior margin, the horizontal fissure the deepest of them
    int iA = nearest(cblP, 370, 414), iB = nearest(cblP, 542, 318), iC = nearest(cblP, 548, 424);
    float[] top = resample(arcF(cblP, iA, iB), 70), bot = resample(rev(arcF(cblP, iC, iA)), 70);
    float[] back = resample(arcF(cblP, iB, iC), 40);
    for (float f = 0.12; f < 0.95; f += 0.075) {
      boolean fissure = abs(f - 0.42) < 0.03;    // the horizontal fissure
      float[] ln = new float[140], hi = new float[140];
      int bi = constrain(round(f * 39), 0, 39);
      for (int i = 0; i < 70; i++) {
        float t = i / 69.0, e = t * t * (3 - 2 * t);
        float cx = lerp(top[138], bot[138], f), cy = lerp(top[139], bot[139], f);
        float ex = (back[bi * 2] - cx) * e, ey = (back[bi * 2 + 1] - cy) * e;
        ln[i * 2] = lerp(top[i * 2], bot[i * 2], f) + ex;
        ln[i * 2 + 1] = lerp(top[i * 2 + 1], bot[i * 2 + 1], f) + ey;
        hi[i * 2] = lerp(top[i * 2], bot[i * 2], f - 0.022) + ex;
        hi[i * 2 + 1] = lerp(top[i * 2 + 1], bot[i * 2 + 1], f - 0.022) + ey;
      }
      g.noFill();
      g.stroke(255, 255, 255, 85);
      g.strokeWeight(1.3);
      pl(g, seg(hi, 3, 65));
      g.stroke(fissure ? lerpColor(C_CBL_DK, D_INK, 0.45) : C_CBL_DK);
      g.strokeWeight(fissure ? 2.6 : 1.4);
      pl(g, seg(ln, 3, 65));
    }
    rim(g, cblP, 10, 70, 60);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    shp(g, cblP);
  }

  // n points evenly spaced by arc length along an open polyline
  float[] resample(float[] p, int n) {
    int m = p.length / 2;
    float[] cum = new float[m];
    for (int i = 1; i < m; i++) cum[i] = cum[i - 1] + dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
    float[] q = new float[n * 2];
    int k = 1;
    for (int i = 0; i < n; i++) {
      float s = cum[m - 1] * i / (n - 1);
      while (k < m - 1 && cum[k] < s) k++;
      float f = (s - cum[k - 1]) / max(1e-4, cum[k] - cum[k - 1]);
      q[i * 2] = lerp(p[k * 2 - 2], p[k * 2], constrain(f, 0, 1));
      q[i * 2 + 1] = lerp(p[k * 2 - 1], p[k * 2 + 1], constrain(f, 0, 1));
    }
    return q;
  }

  void drawCerebrum(PGraphics g) {
    g.noStroke();
    g.fill(C_FRONT);
    shp(g, frontalP);
    g.fill(C_PARI);
    shp(g, parietalP);
    g.fill(C_TEMP);
    shp(g, temporalP);
    g.fill(C_OCC);
    shp(g, occipitalP);
    g.fill(C_PRE);
    shp(g, preP);
    g.fill(C_POST);
    shp(g, postP);
    // language areas: orange, stippled
    for (float[] p : new float[][] { brocaP, wernP }) {
      g.noStroke();
      g.fill(C_LANG);
      shp(g, p);
      stipple(g, p, lerpColor(C_LANG, C_LANG_DK, 0.6));
    }
    // volume: light from the upper left, shade toward the lower right
    rim(g, OUT, 12, 80, 90);
    // the opercula overhang the temporal lobe: shadow under the lateral fissure
    g.noFill();
    g.stroke(0, 0, 0, 34);
    g.strokeWeight(9);
    pl(g, shiftP(seg(LAT, 0, nearest(LAT, 372, 258)), 0, 5));
    // secondary sulci: groove + gyral highlight
    for (float[] s : minor) sulcus(g, s, 1.8, 4.6);
    // imaginary lobe boundaries (parieto-occipital line, parieto-temporal line): dashed
    g.stroke(D_INK);
    g.strokeWeight(1.5);
    dashedPl(g, PO, 7, 5);
    dashedPl(g, PT, 7, 5);
    // the two big landmarks: central sulcus and lateral (Sylvian) fissure
    sulcus(g, CEN, 3.0, 8);
    sulcus(g, LAT, 3.4, 9);
    // language areas: dashed borders
    g.stroke(C_LANG_DK);
    g.strokeWeight(1.8);
    dashedPl(g, closeP(brocaP), 5, 4);
    dashedPl(g, closeP(wernP), 5, 4);
    // outline
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.8);
    shp(g, OUT);
  }

  void sulcus(PGraphics g, float[] p, float w, float shadow) {
    g.noFill();
    g.stroke(0, 0, 0, 30);
    g.strokeWeight(shadow);
    pl(g, shiftP(p, 0.8, 1.6));
    g.stroke(255, 255, 255, 72);
    g.strokeWeight(min(2.2, w * 0.8));
    pl(g, shiftP(p, -w * 0.6 - 0.8, -w * 0.7 - 1));
    g.stroke(lerpColor(D_INK, #3B3550, 0.4));
    g.strokeWeight(w);
    pl(g, p);
  }

  void stipple(PGraphics g, float[] p, int col) {
    g.noStroke();
    g.fill(col, 150);
    float x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
    for (int i = 0; i < p.length; i += 2) {
      x0 = min(x0, p[i]);
      x1 = max(x1, p[i]);
      y0 = min(y0, p[i + 1]);
      y1 = max(y1, p[i + 1]);
    }
    int row = 0;
    for (float y = y0 + 3; y < y1; y += 6.5, row++) {
      for (float x = x0 + 3 + (row % 2) * 3.5; x < x1; x += 7) {
        if (insidePoly(p, x, y) && edgeDist(p, x, y) > 3.5) g.ellipse(x, y, 2.2, 2.2);
      }
    }
  }

  // shade a band just inside a closed outline: dark where it faces down-right, light where it faces up-left
  void rim(PGraphics g, float[] p, float depth, float dark, float light) {
    int n = p.length / 2;
    float area = 0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += p[i * 2] * p[j * 2 + 1] - p[j * 2] * p[i * 2 + 1];
    }
    float sgn = area > 0 ? 1 : -1;
    float[] nx = new float[n], ny = new float[n];
    for (int i = 0; i < n; i++) {
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      // inward normal
      nx[i] = -ty / L * sgn;
      ny[i] = tx / L * sgn;
    }
    g.noStroke();
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      float ox = -(nx[i] + nx[j]) / 2, oy = -(ny[i] + ny[j]) / 2;
      float d = ox * 0.55 + oy * 0.83;     // outward normal vs the shade direction (down-right)
      if (d > 0) g.fill(0, 0, 0, dark * d);
      else g.fill(255, 255, 255, light * -d);
      for (int s = 0; s < 3; s++) {
        float d0 = 1.5 + depth * s / 3.0, d1 = 1.5 + depth * (s + 1) / 3.0;
        float k = 1 - s / 3.0;
        if (d > 0) g.fill(0, 0, 0, dark * d * k * 0.6);
        else g.fill(255, 255, 255, light * -d * k * 0.6);
        g.beginShape();
        g.vertex(p[i * 2] + nx[i] * d0, p[i * 2 + 1] + ny[i] * d0);
        g.vertex(p[j * 2] + nx[j] * d0, p[j * 2 + 1] + ny[j] * d0);
        g.vertex(p[j * 2] + nx[j] * d1, p[j * 2 + 1] + ny[j] * d1);
        g.vertex(p[i * 2] + nx[i] * d1, p[i * 2 + 1] + ny[i] * d1);
        g.endShape(CLOSE);
      }
    }
  }

  // ------------------------------------------------------------ helpers (local to this class)
  // ripple an open polyline sideways (ends stay put): makes sulci look hand-drawn and organic
  float[] wig(float[] p, float amp, float period, float ph) {
    int n = p.length / 2;
    float[] s = new float[n];
    for (int i = 1; i < n; i++) s[i] = s[i - 1] + dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
    float L = max(1e-3, s[n - 1]);
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], T = max(1e-3, sqrt(tx * tx + ty * ty));
      float env = min(1, min(s[i], L - s[i]) / 8);
      float o = amp * env * sin(TWO_PI * s[i] / period + ph);
      q[i * 2] = p[i * 2] - ty / T * o;
      q[i * 2 + 1] = p[i * 2 + 1] + tx / T * o;
    }
    return q;
  }

  // gentle gyral bumps along a closed outline
  float[] bumpy(float[] p) {
    int n = p.length / 2;
    float[] q = new float[p.length];
    float s = 0;
    for (int i = 0; i < n; i++) {
      if (i > 0) s += dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], T = max(1e-3, sqrt(tx * tx + ty * ty));
      float o = 1.5 * sin(TWO_PI * s / 46) + 0.5 * sin(TWO_PI * s / 27 + 1.3);
      q[i * 2] = p[i * 2] - ty / T * o;
      q[i * 2 + 1] = p[i * 2 + 1] + tx / T * o;
    }
    return q;
  }

  float[] spanAt(float[] p, float y) {
    float lo = 1e9, hi = -1e9;
    int n = p.length / 2;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      float yi = p[i * 2 + 1], yj = p[j * 2 + 1];
      if ((yi > y) != (yj > y)) {
        float x = p[i * 2] + (y - yi) / (yj - yi) * (p[j * 2] - p[i * 2]);
        lo = min(lo, x);
        hi = max(hi, x);
      }
    }
    return lo < hi ? new float[] { lo, hi } : null;
  }

  float edgeDist(float[] p, float x, float y) {
    float best = 1e9;
    int n = p.length / 2;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      float ax = p[j * 2], ay = p[j * 2 + 1], bx = p[i * 2], by = p[i * 2 + 1];
      float dx = bx - ax, dy = by - ay, L2 = dx * dx + dy * dy;
      float t = L2 < 1e-6 ? 0 : constrain(((x - ax) * dx + (y - ay) * dy) / L2, 0, 1);
      best = min(best, dist(x, y, ax + dx * t, ay + dy * t));
    }
    return best;
  }

  void dashedPl(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    int n = p.length / 2;
    for (int i = 0; i < n - 1; i++) {
      float x0 = p[i * 2], y0 = p[i * 2 + 1], x1 = p[i * 2 + 2], y1 = p[i * 2 + 3];
      float L = dist(x0, y0, x1, y1), t = 0;
      while (t < L) {
        float lim = draw ? on : off;
        float step = min(lim - acc, L - t);
        if (draw) g.line(lerp(x0, x1, t / L), lerp(y0, y1, t / L), lerp(x0, x1, (t + step) / L), lerp(y0, y1, (t + step) / L));
        t += step;
        acc += step;
        if (acc >= lim - 1e-4) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  float[] closeP(float[] p) {
    float[] q = new float[p.length + 2];
    arrayCopy(p, q);
    q[p.length] = p[0];
    q[p.length + 1] = p[1];
    return q;
  }

  float[] cp(float[] p) {
    return p.clone();
  }

  int nearest(float[] p, float x, float y) {
    int best = 0;
    float bd = 1e9;
    for (int i = 0; i < p.length / 2; i++) {
      float d = sq(p[i * 2] - x) + sq(p[i * 2 + 1] - y);
      if (d < bd) {
        bd = d;
        best = i;
      }
    }
    return best;
  }

  // closed polyline: points i .. j going forward (wrapping)
  float[] arcF(float[] p, int i, int j) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    int k = i;
    while (true) {
      q.append(p[k * 2]);
      q.append(p[k * 2 + 1]);
      if (k == j) break;
      k = (k + 1) % n;
    }
    return q.array();
  }

  // open polyline: points i .. j (reversed when j < i)
  float[] seg(float[] p, int i, int j) {
    int st = j >= i ? 1 : -1;
    FloatList q = new FloatList();
    for (int k = i; ; k += st) {
      q.append(p[k * 2]);
      q.append(p[k * 2 + 1]);
      if (k == j) break;
    }
    return q.array();
  }

  float[] rev(float[] p) {
    return seg(p, p.length / 2 - 1, 0);
  }

  float[] cat(float[]... a) {
    FloatList q = new FloatList();
    for (float[] p : a) for (float v : p) q.append(v);
    return q.array();
  }

  // lengthen an open polyline by e0 units at its start and e1 at its end
  float[] extend(float[] p, float e0, float e1) {
    int n = p.length / 2;
    float dx0 = p[0] - p[2], dy0 = p[1] - p[3], L0 = max(1e-3, sqrt(dx0 * dx0 + dy0 * dy0));
    float dx1 = p[n * 2 - 2] - p[n * 2 - 4], dy1 = p[n * 2 - 1] - p[n * 2 - 3], L1 = max(1e-3, sqrt(dx1 * dx1 + dy1 * dy1));
    return cat(new float[] { p[0] + dx0 / L0 * e0, p[1] + dy0 / L0 * e0 }, p, new float[] { p[n * 2 - 2] + dx1 / L1 * e1, p[n * 2 - 1] + dy1 / L1 * e1 });
  }

  float[] shiftP(float[] p, float dx, float dy) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = p[i] + dx;
      q[i + 1] = p[i + 1] + dy;
    }
    return q;
  }

  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] q = new float[n * 4];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) max(1, n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      q[i * 2] = c[i * 2] + nx;
      q[i * 2 + 1] = c[i * 2 + 1] + ny;
      q[(2 * n - 1 - i) * 2] = c[i * 2] - nx;
      q[(2 * n - 1 - i) * 2 + 1] = c[i * 2 + 1] - ny;
    }
    return q;
  }

  void shp(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void pl(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  float[] crO(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float[] crC(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      int i0 = (i + n - 1) % n, i2 = (i + 1) % n, i3 = (i + 2) % n;
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    return q.array();
  }
}


// ======================================================================
// TAB: Dia_Cell.pde
// ======================================================================
// Generic animal cell, cross-section. Phospholipid-bilayer membrane around
// blue cytoplasm; nucleus (double envelope with pores, chromatin, nucleolus);
// rough ER cisternae wrapped around the nucleus and studded with ribosomes;
// smooth ER tubules (no ribosomes); a Golgi stack with vesicles; mitochondria
// with cristae; free ribosomes (polysomes); lysosomes; a centrosome (two
// centrioles at right angles). Hit polygons are built from the same geometry.

class CellDiagram extends Diagram {
  final float CX = 300, CY = 302, RX = 266, RY = 250;      // cell outline
  final float NX = 248, NY = 272, NRX = 94, NRY = 84, NA = -0.12;   // nucleus
  final float GX = 446, GY = 262, GA = -0.10;              // golgi centre + tilt
  final float SX = 430, SY = 432;                          // smooth ER centre
  final float CEX = 358, CEY = 178;                        // centrosome (juxtanuclear, between nucleus and Golgi)

  final int MEM = #F4C49C, MEM_HEAD = #E3895F, MEM_TAIL = #E9B08A;
  final int NUC_IN = #CDC2EC, NUC_ENV = #7462B2, CHROM = #A595D6, NUCLEOLUS = #57438F;
  final int ER_DK = #3E7EAE, RIBO = #2C356E;
  final int SER = #86D0BC, SER_DK = #3F9580;
  final int GOLGI_DK = #B57A22;
  final int MITO_DK = #C2582F, MITO_IN = #F9C2A2;
  final int LYSO = #E58BB0, LYSO_DK = #A9466F;
  final int CENT = #8A97AE, CENT_DK = #4F5B73, PCM = #E7E1F2;

  // geometry
  float[][] rer = new float[3][];          // rough ER centre lines
  float[] rerW = { 11, 12, 11 };
  float[][] serTubes;                      // smooth ER tube centre lines
  float[][] mitos = { { 166, 147, 50, 23, -0.42 }, { 462, 362, 42, 20, 0.22 }, { 262, 499, 48, 22, 0.06 }, { 123, 428, 40, 20, 1.02 } };
  float[][] lysos = { { 268, 104, 17 }, { 366, 503, 15 }, { 184, 474, 15 } };
  float[][] polys = { { 338, 74, 0.1 }, { 384, 332, 0.6 }, { 300, 452, 0.15 }, { 126, 206, 0.35 }, { 458, 162, -0.7 } };

  CellDiagram() {
    super("cell", "Animal Cell");
    build();
    add("cytoplasm", "Cytoplasm").poly(outline(13, 120)).anchor(390, 118);
    add("cell_membrane", "Cell Membrane").poly(ring(-7, 19, 120)).anchor(CX + memX(-0.25, 6), CY + memY(-0.25, 6));
    add("nucleus", "Nucleus").poly(ell(NX, NY, NRX + 3, NRY + 3, NA, 36)).anchor(NX - 40, NY + 30);
    add("rough_er", "Rough ER").poly(rerHit()).anchor(NX + cos(2.35) * (NRX + 38), NY + sin(2.35) * (NRY + 38));
    add("smooth_er", "Smooth ER").poly(serHit()).anchor(SX + 4, SY);
    add("golgi", "Golgi Apparatus").poly(golgiHit()).anchor(GX, GY);
    Part m = add("mitochondrion", "Mitochondrion");
    for (float[] k : mitos) m.poly(ell(k[0], k[1], k[2] + 3, k[3] + 3, k[4], 28));
    m.anchor(mitos[0][0], mitos[0][1]);
    Part l = add("lysosome", "Lysosome");
    for (float[] k : lysos) l.poly(ell(k[0], k[1], k[2] + 4, k[2] + 4, 0, 20));
    l.anchor(lysos[0][0], lysos[0][1]);
    add("centrosome", "Centrosome").poly(ell(CEX, CEY, 30, 25, -0.3, 24)).anchor(CEX, CEY);
    Part r = add("ribosome", "Ribosome");
    for (float[] k : polys) r.poly(ell(k[0], k[1], 22, 13, k[2], 20));
    r.anchor(polys[0][0], polys[0][1]);
    add("nucleolus", "Nucleolus").poly(ell(NX + 16, NY - 8, 33, 28, 0.3, 24)).anchor(NX + 16, NY - 8);
  }

  // ------------------------------------------------------------ geometry
  float wob(float t) {
    return 1 + 0.03 * sin(3 * t + 0.7) + 0.018 * sin(5 * t + 2.1) + 0.012 * cos(2 * t + 0.4);
  }

  float memX(float t, float d) {
    return (RX * wob(t) - d) * cos(t);
  }

  float memY(float t, float d) {
    return (RY * wob(t) - d) * sin(t);
  }

  // closed outline of the cell, d units inside the outer membrane surface
  float[] outline(float d, int n) {
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n;
      p[i * 2] = CX + memX(t, d);
      p[i * 2 + 1] = CY + memY(t, d);
    }
    return p;
  }

  // a ring polygon (outer loop + inner loop joined by a seam): even-odd fill makes it hollow
  float[] ring(float d0, float d1, int n) {
    float[] p = new float[(n + 1) * 4];
    int k = 0;
    for (int i = 0; i <= n; i++) {
      float t = TWO_PI * i / n;
      p[k++] = CX + memX(t, d0);
      p[k++] = CY + memY(t, d0);
    }
    for (int i = n; i >= 0; i--) {
      float t = TWO_PI * i / n;
      p[k++] = CX + memX(t, d1);
      p[k++] = CY + memY(t, d1);
    }
    return p;
  }

  // a point at polar angle a, "off" units outside the nucleus outline
  float nuX(float a, float off) {
    float x = cos(a) * (NRX + off), y = sin(a) * (NRY + off);
    return NX + x * cos(NA) - y * sin(NA);
  }

  float nuY(float a, float off) {
    float x = cos(a) * (NRX + off), y = sin(a) * (NRY + off);
    return NY + x * sin(NA) + y * cos(NA);
  }

  final float RER_A0 = 0.95, RER_A1 = 3.55;
  final float[] RER_OFF = { 20, 39, 58 };

  void build() {
    for (int c = 0; c < 3; c++) {
      float a0 = RER_A0 + 0.05 * c, a1 = RER_A1 - 0.06 * c;
      int n = 60;
      float[] p = new float[n * 2];
      for (int i = 0; i < n; i++) {
        float a = lerp(a0, a1, i / (float) (n - 1));
        float off = RER_OFF[c] + 3.2 * sin(a * 9 + c * 1.7);   // gently folded sheets
        p[i * 2] = nuX(a, off);
        p[i * 2 + 1] = nuY(a, off);
      }
      if (c == 0) {
        // the innermost sheet bends into the nuclear envelope: the RER lumen is continuous with it
        float[] q = new float[p.length + 4];
        arrayCopy(p, q);
        q[p.length] = nuX(a1 + 0.1, 10);
        q[p.length + 1] = nuY(a1 + 0.1, 10);
        q[p.length + 2] = nuX(a1 + 0.16, 0);
        q[p.length + 3] = nuY(a1 + 0.16, 0);
        p = q;
      }
      rer[c] = p;
    }
    float[][] t = {
      { -62, -22, -40, -30, -16, -22, 6, -32, 30, -22, 54, -30, 70, -18 },
      { -64, 8, -42, 2, -20, 12, 4, 4, 28, 14, 50, 6, 68, 16 },
      { -50, 36, -28, 40, -6, 34, 18, 42, 40, 36 },
      { -40, -30, -42, 2 }, { -16, -22, -20, 12 }, { 6, -32, 4, 4 }, { 30, -22, 28, 14 }, { 54, -30, 50, 6 },
      { -42, 2, -28, 40 }, { 4, 4, -6, 34 }, { 28, 14, 18, 42 }, { 50, 6, 40, 36 },
      { -64, 8, -92, 2, -118, -14 }
    };
    serTubes = new float[t.length][];
    for (int i = 0; i < t.length; i++) {
      float[] q = t[i].length > 4 ? crO(t[i], 6) : t[i];
      float[] w = new float[q.length];
      for (int k = 0; k < q.length; k += 2) {
        w[k] = SX + q[k];
        w[k + 1] = SY + q[k + 1];
      }
      serTubes[i] = w;
    }
  }

  float[] rerHit() {
    int n = 40;
    float[] p = new float[n * 4];
    for (int i = 0; i < n; i++) {
      float a = lerp(RER_A0 - 0.06, RER_A1 + 0.05, i / (float) (n - 1));
      p[i * 2] = nuX(a, 9);
      p[i * 2 + 1] = nuY(a, 9);
      float b = lerp(RER_A1 + 0.05, RER_A0 - 0.06, i / (float) (n - 1));
      p[n * 2 + i * 2] = nuX(b, 70);
      p[n * 2 + i * 2 + 1] = nuY(b, 70);
    }
    return p;
  }

  float[] serHit() {
    float[] q = { -76, -36, -40, -44, 0, -46, 40, -40, 78, -30, 84, 0, 80, 22, 60, 46, 20, 56, -20, 54, -60, 50, -76, 26, -96, 14, -126, -2, -128, -22, -110, -22, -88, -12 };
    for (int k = 0; k < q.length; k += 2) {
      q[k] += SX;
      q[k + 1] += SY;
    }
    return q;
  }

  // golgi cisterna i in local coordinates: an arc concave toward +x (the trans face)
  final float[] G_LEN = { 66, 82, 92, 86, 70 };

  float[] golgiArc(int i) {
    float x0 = -30 + 14 * i, R = 78;
    float h = G_LEN[i] / (2 * R);
    int n = 18;
    float[] p = new float[n * 2];
    for (int k = 0; k < n; k++) {
      float f = lerp(-h, h, k / (float) (n - 1));
      float lx = x0 + R - R * cos(f), ly = R * sin(f);
      p[k * 2] = GX + lx * cos(GA) - ly * sin(GA);
      p[k * 2 + 1] = GY + lx * sin(GA) + ly * cos(GA);
    }
    return p;
  }

  float[] golgiHit() {
    float[] q = { -44, -10, -40, -36, -24, -50, 2, -56, 26, -54, 48, -46, 66, -34, 70, -6, 70, 18, 64, 40, 46, 52, 22, 58, -2, 56, -26, 48, -40, 32 };
    return loc(q, GX, GY, GA);
  }

  float[] loc(float[] q, float x, float y, float a) {
    float[] p = new float[q.length];
    for (int k = 0; k < q.length; k += 2) {
      p[k] = x + q[k] * cos(a) - q[k + 1] * sin(a);
      p[k + 1] = y + q[k] * sin(a) + q[k + 1] * cos(a);
    }
    return p;
  }

  // ------------------------------------------------------------ art
  void drawArt(PGraphics g) {
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    drawCellBody(g);
    drawSER(g);
    drawRER(g);
    drawNucleus(g);
    for (float[] m : mitos) drawMito(g, m[0], m[1], m[2], m[3], m[4]);
    drawGolgi(g);
    for (float[] l : lysos) drawLyso(g, l[0], l[1], l[2]);
    drawCentrosome(g);
    for (float[] p : polys) drawPolysome(g, p[0], p[1], p[2]);
  }

  void drawCellBody(PGraphics g) {
    // soft drop shadow
    g.noStroke();
    g.fill(0, 0, 0, 22);
    float[] sh = outline(-2, 120);
    for (int k = 0; k < sh.length; k += 2) {
      sh[k] += 5;
      sh[k + 1] += 7;
    }
    shp(g, sh);
    // membrane band (lipid tails)
    g.fill(MEM);
    shp(g, outline(-1, 160));
    // cytoplasm with a slightly deeper rim
    g.fill(lerpColor(D_CYTO, #7FB6CF, 0.35));
    shp(g, outline(13, 160));
    for (int i = 0; i < 6; i++) {
      g.fill(lerpColor(lerpColor(D_CYTO, #7FB6CF, 0.35), D_CYTO, (i + 1) / 6.0));
      shp(g, outline(16 + i * 4.5, 160));
    }
    // faint cytoskeleton filaments
    g.noFill();
    g.stroke(#9CC9DD);
    g.strokeWeight(1.1);
    float[][] fil = { { 70, 210, 110, 240, 136, 300 }, { 372, 318, 400, 330, 420, 318 }, { 220, 440, 200, 470, 216, 510 },
      { 410, 96, 436, 116, 470, 112 }, { 318, 128, 340, 120, 356, 132 }, { 70, 360, 76, 396 }, { 438, 492, 466, 484, 490, 466 } };
    for (float[] f : fil) pl(g, crO(f, 6));
    // bilayer: tails between two rows of heads
    int n = 330;
    g.stroke(MEM_TAIL);
    g.strokeWeight(0.9);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * (i + 0.5) / n;
      g.line(CX + memX(t, 2.5), CY + memY(t, 2.5), CX + memX(t, 5.6), CY + memY(t, 5.6));
      g.line(CX + memX(t, 7.4), CY + memY(t, 7.4), CX + memX(t, 10.5), CY + memY(t, 10.5));
    }
    g.noStroke();
    g.fill(MEM_HEAD);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n;
      g.ellipse(CX + memX(t, 1.4), CY + memY(t, 1.4), 4.4, 4.4);
      g.ellipse(CX + memX(t, 11.6), CY + memY(t, 11.6), 4.4, 4.4);
    }
    // a few transmembrane proteins
    float[] prot = { -2.2, -0.9, 0.35, 1.25, 2.55 };
    for (float t : prot) {
      float x = CX + memX(t, 6.5), y = CY + memY(t, 6.5);
      g.pushMatrix();
      g.translate(x, y);
      g.rotate(atan2(memY(t + 0.01, 6.5) - memY(t - 0.01, 6.5), memX(t + 0.01, 6.5) - memX(t - 0.01, 6.5)));
      g.stroke(D_INK);
      g.strokeWeight(1.4);
      g.fill(#9F8FD8);
      g.rect(-9, -11, 8, 22, 4);
      g.rect(1, -11, 8, 22, 4);
      g.popMatrix();
    }
    // outer + inner membrane edges
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    shp(g, outline(-1.2, 160));
    g.stroke(lerpColor(D_INK, MEM, 0.45));
    g.strokeWeight(1.2);
    shp(g, outline(13.2, 160));
  }

  void drawSER(PGraphics g) {
    g.noFill();
    for (int pass = 0; pass < 3; pass++) {
      g.stroke(pass == 0 ? D_INK : pass == 1 ? SER_DK : SER);
      g.strokeWeight(pass == 0 ? 11.5 : pass == 1 ? 8.6 : 5.4);
      for (float[] t : serTubes) pl(g, t);
    }
    g.stroke(255, 255, 255, 120);
    g.strokeWeight(1.6);
    for (float[] t : serTubes) {
      float[] q = new float[t.length];
      for (int k = 0; k < t.length; k += 2) {
        q[k] = t[k] - 0.8;
        q[k + 1] = t[k + 1] - 1.4;
      }
      pl(g, q);
    }
  }

  void drawRER(PGraphics g) {
    // connection from the inner cisterna to the nuclear envelope
    g.noFill();
    for (int c = 2; c >= 0; c--) {
      float[] p = rer[c];
      float w = rerW[c];
      g.stroke(D_INK);
      g.strokeWeight(w + 3.4);
      pl(g, p);
      g.stroke(ER_DK);
      g.strokeWeight(w);
      pl(g, p);
      g.stroke(D_ER);
      g.strokeWeight(w * 0.55);
      pl(g, p);
      g.stroke(255, 255, 255, 90);
      g.strokeWeight(1.4);
      pl(g, p);
    }
    // ribosomes studding both faces
    g.noStroke();
    g.fill(RIBO);
    for (int c = 0; c < 3; c++) {
      float[] p = rer[c];
      int n = p.length / 2;
      for (int i = 1; i < n - 1; i++) {
        float tx = p[(i + 1) * 2] - p[(i - 1) * 2], ty = p[(i + 1) * 2 + 1] - p[(i - 1) * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        float nx = -ty / L, ny = tx / L, o = rerW[c] / 2 + 3.6;
        if (i % 2 == 0) g.ellipse(p[i * 2] + nx * o, p[i * 2 + 1] + ny * o, 4.4, 4.4);
        else g.ellipse(p[i * 2] - nx * o, p[i * 2 + 1] - ny * o, 4.4, 4.4);
      }
    }
  }

  void drawNucleus(PGraphics g) {
    g.noStroke();
    g.fill(0, 0, 0, 25);
    shp(g, ell(NX + 4, NY + 6, NRX + 2, NRY + 2, NA, 60));
    // envelope (double membrane)
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(NUC_ENV);
    shp(g, ell(NX, NY, NRX, NRY, NA, 72));
    g.noStroke();
    g.fill(lerpColor(NUC_ENV, NUC_IN, 0.55));
    shp(g, ell(NX, NY, NRX - 3.2, NRY - 3.2, NA, 72));
    g.stroke(lerpColor(NUC_ENV, D_INK, 0.2));
    g.strokeWeight(1.6);
    g.fill(NUC_IN);
    shp(g, ell(NX, NY, NRX - 6.5, NRY - 6.5, NA, 72));
    // nuclear pores: gaps through the envelope
    g.strokeWeight(2.2);
    for (int i = 0; i < 14; i++) {
      float a = TWO_PI * i / 14 + 0.2;
      g.stroke(NUC_IN);
      g.line(nuX(a, -7.5), nuY(a, -7.5), nuX(a, 1.2), nuY(a, 1.2));
      g.stroke(D_INK);
      g.strokeWeight(1.3);
      g.line(nuX(a - 0.035, -6.5), nuY(a - 0.035, -6.5), nuX(a - 0.035, 0.5), nuY(a - 0.035, 0.5));
      g.line(nuX(a + 0.035, -6.5), nuY(a + 0.035, -6.5), nuX(a + 0.035, 0.5), nuY(a + 0.035, 0.5));
      g.strokeWeight(2.2);
    }
    // soft highlight
    g.noStroke();
    g.fill(255, 255, 255, 50);
    shp(g, ell(NX - 26, NY - 30, 42, 24, NA - 0.3, 30));
    // chromatin threads
    g.noFill();
    g.stroke(CHROM);
    g.strokeWeight(2.2);
    float[][] ch = { { -60, 10, -44, -6, -50, -24, -34, -40, -16, -46 }, { -62, 34, -40, 30, -30, 46, -10, 52, 6, 40 },
      { 24, 36, 42, 46, 58, 30, 66, 10, 54, -6 }, { -14, 14, -2, 2, -20, -10 }, { 40, -40, 56, -30, 62, -46 }, { 18, 58, 34, 62 } };
    for (float[] c : ch) pl(g, crO(loc(c, NX, NY, NA), 5));
    g.noStroke();
    g.fill(CHROM);
    float[] dots = { -36, -8, -26, 22, 30, 52, -48, 50, 70, -18, -4, -60, 50, 12, 12, -28 };
    for (int k = 0; k < dots.length; k += 2) {
      float[] q = loc(new float[] { dots[k], dots[k + 1] }, NX, NY, NA);
      g.ellipse(q[0], q[1], 5, 5);
    }
    // nucleolus
    float ox = NX + 16, oy = NY - 8;
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(NUCLEOLUS);
    shp(g, crC(new float[] { ox - 26, oy - 4, ox - 16, oy - 22, ox + 4, oy - 26, ox + 22, oy - 16, ox + 28, oy + 4, ox + 18, oy + 20, ox - 2, oy + 24, ox - 20, oy + 16 }, 5));
    g.noStroke();
    g.fill(lerpColor(NUCLEOLUS, #FFFFFF, 0.25));
    for (int i = 0; i < 9; i++) g.ellipse(ox - 12 + (i % 3) * 11 + (i / 3) * 2, oy - 10 + (i / 3) * 10, 5, 5);
    g.fill(255, 255, 255, 70);
    g.ellipse(ox - 9, oy - 13, 14, 7);
  }

  void drawMito(PGraphics g, float x, float y, float rx, float ry, float a) {
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(a);
    g.noStroke();
    g.fill(0, 0, 0, 25);
    g.ellipse(3, 5, rx * 2, ry * 2);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    g.fill(D_MITO);
    g.ellipse(0, 0, rx * 2, ry * 2);
    g.noStroke();
    g.fill(MITO_IN);
    g.ellipse(0, 0, rx * 2 - 9, ry * 2 - 9);
    // cristae: folds of the inner membrane, alternating from each side
    g.noFill();
    g.stroke(MITO_DK);
    g.strokeWeight(2.4);
    int n = max(4, round(rx / 9));
    for (int i = 0; i < n; i++) {
      float fx = -rx + 12 + (2 * rx - 24) * i / (float) (n - 1);
      float edge = (ry - 4.5) * sqrt(max(0, 1 - sq(fx / (rx - 4.5))));
      float s = i % 2 == 0 ? -1 : 1;
      g.beginShape();
      g.vertex(fx - 2.5, s * edge);
      g.vertex(fx - 2.5, s * (edge - ry * 1.05));
      g.vertex(fx + 2.5, s * (edge - ry * 1.05));
      g.vertex(fx + 2.5, s * edge);
      g.endShape();
    }
    g.stroke(lerpColor(MITO_DK, D_MITO, 0.3));
    g.strokeWeight(1.3);
    g.ellipse(0, 0, rx * 2 - 8, ry * 2 - 8);
    g.noStroke();
    g.fill(255, 255, 255, 70);
    g.ellipse(-rx * 0.3, -ry * 0.55, rx * 0.8, ry * 0.3);
    g.popMatrix();
  }

  void drawGolgi(PGraphics g) {
    g.noFill();
    for (int i = 0; i < 5; i++) {
      float[] p = golgiArc(i);
      float w = 8.5;
      g.stroke(D_INK);
      g.strokeWeight(w + 3.4);
      pl(g, p);
      int n = p.length / 2;
      g.fill(D_INK);
      g.noStroke();
      g.ellipse(p[0], p[1], w + 7.5, w + 7.5);
      g.ellipse(p[(n - 1) * 2], p[(n - 1) * 2 + 1], w + 7.5, w + 7.5);
      g.noFill();
      g.stroke(GOLGI_DK);
      g.strokeWeight(w);
      pl(g, p);
      g.noStroke();
      g.fill(GOLGI_DK);
      g.ellipse(p[0], p[1], w + 4, w + 4);
      g.ellipse(p[(n - 1) * 2], p[(n - 1) * 2 + 1], w + 4, w + 4);
      g.noFill();
      g.stroke(D_GOLGI);
      g.strokeWeight(w * 0.55);
      pl(g, p);
      g.noStroke();
      g.fill(D_GOLGI);
      g.ellipse(p[0], p[1], w, w);
      g.ellipse(p[(n - 1) * 2], p[(n - 1) * 2 + 1], w, w);
      g.noFill();
    }
    // vesicles: small transport vesicles on the cis face, bigger secretory ones on the trans face
    float[] v = { -46, -22, 4.6, -48, 6, 4.2, -42, 30, 4.4, 70, -42, 6.5, 74, -14, 7.5, 76, 16, 6.8, 64, 42, 6, 92, -30, 8, 100, 4, 8.5, 96, 34, 7.5,
      28, -60, 5.5, 30, 58, 5.5 };
    for (int k = 0; k < v.length; k += 3) {
      float[] q = loc(new float[] { v[k], v[k + 1] }, GX, GY, GA);
      vesicle(g, q[0], q[1], v[k + 2], k / 3 == 6 || k / 3 == 7 || k / 3 == 8 ? D_GOLGI : D_GOLGI);
    }
    // a secretory vesicle fusing with the plasma membrane (exocytosis)
    float t = -0.02;
    float ex = CX + memX(t, 16), ey = CY + memY(t, 16);
    vesicle(g, ex, ey, 8, D_GOLGI);
  }

  void vesicle(PGraphics g, float x, float y, float r, int c) {
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(c);
    g.ellipse(x, y, r * 2, r * 2);
    g.noStroke();
    g.fill(255, 255, 255, 110);
    g.ellipse(x - r * 0.3, y - r * 0.35, r * 0.7, r * 0.5);
  }

  void drawLyso(PGraphics g, float x, float y, float r) {
    g.noStroke();
    g.fill(0, 0, 0, 25);
    g.ellipse(x + 2, y + 4, r * 2, r * 2);
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.fill(LYSO);
    g.ellipse(x, y, r * 2, r * 2);
    g.noStroke();
    g.fill(LYSO_DK);
    float[] d = { -0.4, -0.2, 0.3, -0.45, 0.45, 0.15, -0.1, 0.45, -0.5, 0.35, 0.05, 0.05, 0.2, -0.05 };
    for (int k = 0; k < d.length; k += 2) g.ellipse(x + d[k] * r, y + d[k + 1] * r, r * 0.22, r * 0.22);
    g.fill(255, 255, 255, 90);
    g.ellipse(x - r * 0.35, y - r * 0.45, r * 0.7, r * 0.4);
  }

  void drawCentrosome(PGraphics g) {
    g.pushMatrix();
    g.translate(CEX, CEY);
    g.rotate(-0.3);
    // pericentriolar material
    g.noStroke();
    g.fill(PCM);
    g.ellipse(0, 0, 54, 42);
    g.stroke(lerpColor(PCM, CENT_DK, 0.35));
    g.strokeWeight(1.2);
    g.noFill();
    g.ellipse(0, 0, 54, 42);
    // centriole 1: side view, a barrel with microtubule stripes
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(CENT);
    g.rect(-20, -13, 26, 13, 3);
    g.stroke(CENT_DK);
    g.strokeWeight(1.3);
    for (int i = 0; i < 3; i++) g.line(-17, -10 + i * 3.6, 3, -10 + i * 3.6);
    // centriole 2: end-on, nine microtubule triplets in a ring, at right angles to the first
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(CENT);
    g.ellipse(8, 9, 22, 22);
    g.noStroke();
    g.fill(CENT_DK);
    for (int i = 0; i < 9; i++) {
      float a = TWO_PI * i / 9;
      g.pushMatrix();
      g.translate(8 + cos(a) * 7, 9 + sin(a) * 7);
      g.rotate(a + 0.5);
      g.rect(-1, -2.6, 2.2, 5.2);
      g.popMatrix();
    }
    g.fill(PCM);
    g.ellipse(8, 9, 6, 6);
    g.popMatrix();
  }

  void drawPolysome(PGraphics g, float x, float y, float a) {
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(a);
    g.noFill();
    g.stroke(#7E7AA8);
    g.strokeWeight(1.1);
    g.beginShape();
    for (int i = 0; i <= 12; i++) g.vertex(-17 + i * 34 / 12.0, 4 * sin(i * 0.9));
    g.endShape();
    g.noStroke();
    g.fill(RIBO);
    for (int i = 0; i < 6; i++) {
      float px = -15 + i * 6, py = 4 * sin((px + 17) / (34 / 12.0) * 0.9);
      g.ellipse(px, py, 5.4, 5.4);
      g.ellipse(px + 1, py - 3, 3.6, 3.6);
    }
    g.popMatrix();
  }

  // ------------------------------------------------------------ helpers (local to this class)
  float[] ell(float cx, float cy, float rx, float ry, float ang, int n) {
    float[] p = new float[n * 2];
    float ca = cos(ang), sa = sin(ang);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * ca - y * sa;
      p[i * 2 + 1] = cy + x * sa + y * ca;
    }
    return p;
  }

  void shp(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void pl(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  // open Catmull-Rom through the points
  float[] crO(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  // closed Catmull-Rom through the points
  float[] crC(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      int i0 = (i + n - 1) % n, i2 = (i + 1) % n, i3 = (i + 2) % n;
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    return q.array();
  }
}


// ======================================================================
// TAB: Dia_Digestive.pde
// ======================================================================
// Digestive system, anterior view (subject's right = viewer's left).
// Liver upper viewer-left with the gallbladder beneath it; stomach viewer-right;
// pancreas head in the C of the duodenum, body under the stomach; small intestine
// coiled centrally, framed by the large intestine: cecum + appendix lower left,
// ascending up the left, transverse across, descending down the right, sigmoid
// curving into the rectum.

class DigestiveDiagram extends Diagram {
  final int ESO = #D9827E, ESO_SH = #B35E5B, ESO_LT = #F2B3AD;
  final int STO = D_STOMACH, STO_SH = #C66F6E, STO_LT = #F8C9C4;
  final int LIV = D_LIVER, LIV_SH = #692A20, LIV_LT = #B65E4E;
  final int GB = #6DAE58, GB_SH = #4A873C, GB_LT = #A9D891, BILE = #4E9440;
  final int PAN = #F2C47E, PAN_SH = #CF9A53, PAN_LT = #FAE0B2;
  final int DUO = #EE9E86, DUO_SH = #C9775F, DUO_LT = #F8C7B6;
  final int GUT = D_GUT, GUT_SH = #CF8A74, GUT_LT = #F9D3C5;
  final int COL = D_COLON, COL_SH = #B0664B, COL_LT = #EDB59D;

  final float[] LIVER_C = { 58, 200, 72, 150, 112, 112, 176, 96, 250, 95, 306, 103, 346, 121, 373, 144, 382, 165, 356, 178, 310, 196, 262, 218, 222, 236, 185, 252, 140, 265, 95, 266, 66, 245 };
  final float[] GB_C = { 194, 234, 212, 236, 226, 256, 229, 278, 218, 293, 202, 292, 192, 274, 189, 252 };
  final float[] STO_C = { 352, 160, 356, 134, 380, 114, 418, 107, 458, 121, 488, 151, 501, 198, 495, 246, 469, 284, 424, 305, 378, 305, 340, 293, 316, 281, 305, 266, 315, 251, 341, 251, 367, 237, 379, 210, 378, 182, 374, 162 };
  final float[] PAN_C = { 262, 284, 296, 292, 330, 302, 380, 300, 430, 293, 468, 284, 484, 292, 472, 307, 430, 318, 380, 328, 336, 332, 306, 338, 290, 346, 264, 348, 248, 332, 246, 306 };
  final float[] ESO_C = { 316, 10, 318, 50, 326, 95, 342, 132, 366, 164 };
  final float[] DUO_C = { 314, 266, 286, 265, 258, 271, 238, 287, 229, 311, 238, 334, 266, 346, 300, 347, 326, 342, 340, 340 };
  // large intestine centreline: ascending (from the cecum) -> transverse -> descending -> sigmoid -> rectum
  final float[] LI_C = { 132, 468, 128, 430, 124, 380, 124, 330, 133, 303, 158, 296, 186, 320, 214, 356, 252, 384, 300, 395, 360, 393, 412, 378, 448, 352, 470, 322, 487, 297, 507, 285, 525, 295, 533, 322, 531, 360, 524, 410, 516, 462, 508, 496, 486, 516, 448, 520, 408, 508, 374, 503, 346, 508, 327, 521, 316, 540, 310, 564, 308, 590 };
  final float[] CEC_C = { 112, 462, 132, 458, 152, 462, 168, 480, 162, 503, 140, 515, 116, 508, 104, 484 };
  final float[] APP_C = { 152, 508, 160, 528, 170, 547, 166, 561, 156, 558 };

  float[] liver, gb, sto, pan, eso, duo, li, si, app, cec;
  float sHep, sSpl, sSig, sRect, sEnd;   // arc lengths along the large intestine

  DigestiveDiagram() {
    super("digestive", "Digestive System");
    liver = cr(LIVER_C, true, 8);
    gb = cr(GB_C, true, 8);
    sto = cr(STO_C, true, 8);
    pan = cr(PAN_C, true, 8);
    eso = cr(ESO_C, false, 10);
    duo = cr(DUO_C, false, 10);
    li = cr(LI_C, false, 10);
    si = coil();
    app = cr(APP_C, false, 8);
    cec = cr(CEC_C, true, 8);
    sEnd = len(li);
    sHep = arcNear(li, 142, 297);        // hepatic flexure
    sSpl = arcNear(li, 512, 286);        // splenic flexure
    sSig = arcAtY(li, 470, false);       // pelvic brim: descending -> sigmoid
    sRect = arcNear(li, 318, 536);       // rectosigmoid junction (midline): the rectum runs straight down from here

    // the liver's left lobe lies IN FRONT of the abdominal esophagus and the cardia:
    // stomach and esophagus go first so the liver wins the clicks where it covers them
    add("pancreas", "Pancreas").poly(pan).anchor(400, 318);
    add("stomach", "Stomach").poly(minus(sto, liver)).anchor(440, 210);   // minus the cardia hidden under the liver
    // visible part only: the tube cut along the liver's upper edge (line through (306,106) and (346,124))
    add("esophagus", "Esophagus").poly(clipAbove(tubePoly(sub(eso, 0, arcAtY(eso, 140, false)), 30), 306, 106, 346, 124)).anchor(320, 60);
    add("liver", "Liver").poly(liver).anchor(170, 170);
    add("duodenum", "Duodenum").poly(tubePoly(sub(duo, 4, 999), 28)).anchor(231, 312);
    Part s = add("small_intestine", "Small Intestine");
    s.poly(150, 430, 200, 410, 300, 416, 400, 402, 470, 404, 496, 440, 496, 492, 460, 512, 360, 528, 300, 532, 240, 530, 190, 522, 168, 500, 150, 462);
    s.poly(tubePoly(sub(si, 0, 60), 28));
    s.anchor(310, 470);
    add("gallbladder", "Gallbladder").poly(gb).anchor(212, 272);
    add("ascending_colon", "Ascending Colon").poly(tubePoly(sub(li, 0, sHep), 48)).anchor(124, 380);
    add("transverse_colon", "Transverse Colon").poly(tubePoly(sub(li, sHep, sSpl), 48)).anchor(300, 394);
    add("descending_colon", "Descending Colon").poly(tubePoly(sub(li, sSpl, sSig), 48)).anchor(528, 400);
    add("sigmoid_colon", "Sigmoid Colon").poly(tubePoly(sub(li, sSig, sRect), 40)).anchor(428, 520);
    add("rectum", "Rectum").poly(tubePoly(sub(li, sRect, sEnd), 48)).anchor(312, 560);
    add("cecum", "Cecum").poly(scaled(cec, 136, 480, 1.08, 0, 0)).anchor(136, 484);
    add("appendix", "Appendix").poly(tubePoly(app, 20)).anchor(164, 540);
  }

  // outline a with the region covered by b cut away (one overlap; both outlines dense)
  float[] minus(float[] a, float[] b) {
    int n = a.length / 2, m = b.length / 2;
    boolean[] ain = new boolean[n], bin = new boolean[m];
    for (int i = 0; i < n; i++) ain[i] = insidePoly(b, a[i * 2], a[i * 2 + 1]);
    for (int i = 0; i < m; i++) bin[i] = insidePoly(a, b[i * 2], b[i * 2 + 1]);
    int enter = -1, exit = -1, bs = -1, be = -1, runsA = 0, runsB = 0;
    for (int i = 0; i < n; i++) {
      if (!ain[(i - 1 + n) % n] && ain[i]) { enter = i; runsA++; }
      if (ain[(i - 1 + n) % n] && !ain[i]) exit = i;
    }
    for (int i = 0; i < m; i++) {
      if (!bin[(i - 1 + m) % m] && bin[i]) { bs = i; runsB++; }
      if (bin[i] && !bin[(i + 1) % m]) be = i;
    }
    if (runsA != 1 || runsB != 1) return a;
    FloatList run = new FloatList();
    for (int k = bs; ; k = (k + 1) % m) {
      run.append(b[k * 2]);
      run.append(b[k * 2 + 1]);
      if (k == be) break;
    }
    float px = a[((enter - 1 + n) % n) * 2], py = a[((enter - 1 + n) % n) * 2 + 1];
    boolean rev = dist(px, py, run.get(0), run.get(1)) > dist(px, py, run.get(run.size() - 2), run.get(run.size() - 1));
    FloatList o = new FloatList();
    for (int k = exit; k != enter; k = (k + 1) % n) {
      o.append(a[k * 2]);
      o.append(a[k * 2 + 1]);
    }
    int r = run.size() / 2;
    for (int q = 0; q < r; q++) {
      int idx = rev ? r - 1 - q : q;
      o.append(run.get(idx * 2));
      o.append(run.get(idx * 2 + 1));
    }
    return o.array();
  }

  // keep the part of polygon p lying above the line through (x0,y0)-(x1,y1) (one Sutherland-Hodgman pass)
  float[] clipAbove(float[] p, float x0, float y0, float x1, float y1) {
    FloatList o = new FloatList();
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      float ax = p[i * 2], ay = p[i * 2 + 1], bx = p[j * 2], by = p[j * 2 + 1];
      float da = (x1 - x0) * (ay - y0) - (y1 - y0) * (ax - x0), db = (x1 - x0) * (by - y0) - (y1 - y0) * (bx - x0);
      if (da <= 0) {
        o.append(ax);
        o.append(ay);
      }
      if ((da < 0) != (db < 0) && da != db) {
        float t = da / (da - db);
        o.append(ax + (bx - ax) * t);
        o.append(ay + (by - ay) * t);
      }
    }
    return o.array();
  }

  // arc length where the path first crosses height y (rising = going up the page)
  float arcAtY(float[] p, float y, boolean rising) {
    float acc = 0;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float y0 = p[i + 1], y1 = p[i + 3], d = dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
      if (rising ? (y0 >= y && y1 < y) : (y0 < y && y1 >= y)) return acc + d * (y0 - y) / (y0 - y1);
      acc += d;
    }
    return acc;
  }

  float arcNear(float[] p, float x, float y) {
    float acc = 0, best = 1e9, at = 0;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float d = dist(p[i], p[i + 1], x, y);
      if (d < best) {
        best = d;
        at = acc;
      }
      acc += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    }
    return at;
  }

  // jejunum + ileum: rows of overlapping loops from the duodenojejunal flexure to the cecum
  float[] coil() {
    FloatList p = new FloatList();
    float[] lead = { 340, 340, 352, 356, 372, 384, 410, 406, 446, 424 };
    for (float v : lead) p.append(v);
    coilRow(p, 446, 190, 440, -1);
    coilRow(p, 190, 470, 474, 1);
    coilRow(p, 470, 196, 508, -1);
    float[] tail = { 184, 500, 174, 488, 166, 474 };
    for (float v : tail) p.append(v);
    return p.array();
  }

  void coilRow(FloatList p, float xa, float xb, float yc, int dir) {
    float span = abs(xb - xa), b = 12;
    int loops = max(1, round(span / 48));
    float a = span / (loops * TWO_PI);
    for (int i = 1; i <= loops * 20; i++) {
      float t = i * TWO_PI / 20;
      p.append(xa + dir * (a * t - b * 0.9 * sin(t)));
      p.append(yc - b * cos(t) - 4);
    }
  }

  void drawArt(PGraphics g) {
    // ---- bile ducts (behind the duodenum) and pancreas
    g.stroke(D_INK);
    g.strokeWeight(8);
    g.noFill();
    g.bezier(236, 226, 236, 246, 240, 270, 244, 318);
    g.bezier(206, 240, 214, 250, 226, 252, 236, 252);
    g.stroke(BILE);
    g.strokeWeight(5);
    g.bezier(236, 226, 236, 246, 240, 270, 244, 318);
    g.bezier(206, 240, 214, 250, 226, 252, 236, 252);
    shaded(g, pan, PAN, PAN_SH, PAN_LT, 0.9, 2.4);
    lobules(g, pan, PAN_SH, 11);
    // main pancreatic duct
    g.noFill();
    g.stroke(PAN_SH);
    g.strokeWeight(2.4);
    g.bezier(470, 294, 420, 306, 330, 316, 250, 320);

    // ---- stomach + esophagus (both pass behind the liver's left lobe)
    tube(g, eso, 26, ESO, ESO_SH, ESO_LT, true);
    cutEnd(g, eso, true, 26, ESO_SH);
    // longitudinal muscle lines on the esophagus
    g.stroke(ESO_SH, 140);
    g.strokeWeight(1.2);
    polyline(g, offset(sub(eso, 4, len(eso) - 6), 5));
    shadedPlain(g, sto, STO, STO_SH, 2.8);
    g.noStroke();
    g.fill(STO_LT, 150);
    g.pushMatrix();
    g.translate(436, 170);
    g.rotate(0.5);
    g.ellipse(0, 0, 70, 44);
    g.popMatrix();
    g.fill(255, 120);
    g.ellipse(418, 146, 20, 11);
    // gastric rugae
    g.noFill();
    g.stroke(STO_SH, 170);
    g.strokeWeight(1.8);
    polyline(g, cr(new float[] { 398, 132, 450, 140, 478, 182, 474, 236, 444, 274, 396, 288 }, false, 8));
    polyline(g, cr(new float[] { 392, 156, 436, 168, 455, 206, 448, 246, 420, 270, 380, 278 }, false, 8));
    polyline(g, cr(new float[] { 398, 196, 420, 220, 410, 250, 380, 264, 346, 270 }, false, 8));
    // pyloric sphincter
    g.stroke(STO_SH);
    g.strokeWeight(5);
    g.line(316, 254, 318, 279);
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.line(312, 253, 313, 280);
    g.line(321, 253, 323, 280);

    // ---- liver: its left lobe covers the abdominal esophagus and the cardia
    shaded(g, liver, LIV, LIV_SH, LIV_LT, 0.94, 2.8);
    // falciform ligament + round ligament
    g.noFill();
    g.stroke(LIV_SH);
    g.strokeWeight(2.4);
    g.bezier(292, 98, 296, 140, 286, 180, 276, 210);
    g.stroke(#E8C9A8);
    g.strokeWeight(1.4);
    g.bezier(294, 100, 298, 140, 288, 180, 278, 210);

    // ---- duodenum (C around the pancreatic head)
    tube(g, duo, 24, DUO, DUO_SH, DUO_LT, false);
    folds(g, duo, 24, DUO_SH, 9, 6, 6);

    // ---- small intestine coils (jejunum -> ileum -> cecum)
    gutTube(g, si, 24, GUT, GUT_SH, GUT_LT);

    // ---- large intestine: one sacculated tube from cecum to anal canal
    colon(g);
    // appendix
    tube(g, app, 11, COL, COL_SH, COL_LT, true);
    // ---- gallbladder (fundus peeks below the liver edge)
    shaded(g, gb, GB, GB_SH, GB_LT, 0.86, 2.4);
  }

  // the colon: sacculated tube (haustra) with a taenia stripe, cecum pouch at the bottom
  void colon(PGraphics g) {
    float[] body = sub(li, 0, sEnd);
    float L = len(body);
    float[] poly = sacc(body);
    // cecum pouch (blind end) below the ascending colon
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(COL);
    polygon(g, cec);
    g.noStroke();
    g.fill(COL);
    polygon(g, poly);
    g.fill(COL_SH, 120);
    g.beginShape();
    for (int i = 0; i < cec.length; i += 2) if (cec[i + 1] > 470) g.vertex(cec[i], cec[i + 1]);
    g.endShape(CLOSE);
    g.strokeCap(SQUARE);
    g.noFill();
    g.stroke(COL_SH, 150);
    g.strokeWeight(7);
    polyline(g, offset(sub(body, 6, sRect + 6), -11));
    g.stroke(lerpColor(#C97C61, COL_SH, 0.5));
    g.strokeWeight(9);
    polyline(g, offset(sub(body, sRect + 8, L - 14), -10));
    g.strokeCap(ROUND);
    // haustral folds (none on the rectum)
    g.stroke(COL_SH);
    g.strokeWeight(2);
    for (float d = 27; d < sRect; d += 17) {
      float w = widthAt(d);
      float[] a = sub(body, d - 0.5, d + 0.5);
      float x = a[0], y = a[1], dx = a[a.length - 2] - a[0], dy = a[a.length - 1] - a[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
      float nx = -dy / m * w * 0.44, ny = dx / m * w * 0.44;
      g.bezier(x + nx, y + ny, x + nx * 0.4 + dx / m * 4, y + ny * 0.4 + dy / m * 4, x - nx * 0.4 + dx / m * 4, y - ny * 0.4 + dy / m * 4, x - nx, y - ny);
    }
    g.bezier(112, 486, 126, 494, 148, 494, 164, 484);
    // taenia coli
    g.stroke(COL_LT, 220);
    g.strokeWeight(4);
    polyline(g, offset(sub(body, 0, sRect), 6));
    g.line(140, 470, 142, 500);
    // transverse rectal folds + anal opening
    g.stroke(COL_SH);
    g.strokeWeight(2);
    g.noFill();
    g.arc(320, 553, 24, 9, 0.2, PI - 0.4);
    g.arc(302, 568, 22, 8, 0.4, PI - 0.2);
    g.noStroke();
    g.fill(#8E4A36);
    g.ellipse(308, 590, 11, 4);
    // outlines (open at the top of the cecum so pouch and colon read as one)
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    polyline(g, poly);   // open at the cecum end (first and last points are the two start corners)
    g.beginShape();
    for (int i = 0; i < cec.length; i += 2) if (cec[i + 1] > 468) g.vertex(cec[i], cec[i + 1]);
    g.endShape();
  }

  float widthAt(float acc) {
    if (acc < sSig) return 42;
    if (acc < sRect) return lerp(42, 34, constrain((acc - sSig) / 40, 0, 1));
    if (acc < sEnd - 18) return lerp(34, 42, constrain((acc - sRect) / 30, 0, 1));   // rectal ampulla
    return lerp(42, 14, constrain((acc - (sEnd - 18)) / 18, 0, 1));                 // anal canal
  }

  // tube polygon whose edges bulge between haustral folds; inner-corner loops are dropped
  float[] sacc(float[] p) {
    int n = p.length / 2;
    FloatList l = new FloatList(), r = new FloatList();
    float acc = 0;
    for (int i = 0; i < n; i++) {
      if (i > 0) acc += dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      float bulge = 2.2 * abs(sin((acc - 10) / 17 * PI)) * constrain((sRect - acc) / 14, 0, 1);   // haustra fade out at the rectum
      float w = widthAt(acc) / 2 + bulge;
      keep(l, p[i * 2] - dy / L * w, p[i * 2 + 1] + dx / L * w, dx, dy);
      keep(r, p[i * 2] + dy / L * w, p[i * 2 + 1] - dx / L * w, dx, dy);
    }
    float[] o = new float[l.size() + r.size()];
    for (int i = 0; i < l.size(); i++) o[i] = l.get(i);
    for (int i = 0; i < r.size() / 2; i++) {
      o[l.size() + i * 2] = r.get(r.size() - 2 - i * 2);
      o[l.size() + i * 2 + 1] = r.get(r.size() - 1 - i * 2);
    }
    return o;
  }

  void keep(FloatList side, float x, float y, float tx, float ty) {
    int k = side.size();
    if (k >= 2 && (x - side.get(k - 2)) * tx + (y - side.get(k - 1)) * ty <= 0) return;
    side.append(x);
    side.append(y);
  }

  // circular folds across a tube
  void folds(PGraphics g, float[] path, float w, int col, float step, float a, float b) {
    float L = len(path);
    g.noFill();
    g.stroke(col, 170);
    g.strokeWeight(1.5);
    for (float d = a; d < L - b; d += step) {
      float[] s = sub(path, d - 0.5, d + 0.5);
      float x = s[0], y = s[1], dx = s[s.length - 2] - s[0], dy = s[s.length - 1] - s[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
      float nx = -dy / m * w * 0.36, ny = dx / m * w * 0.36;
      g.line(x + nx, y + ny, x - nx, y - ny);
    }
  }

  // an overlapping coil drawn in short chunks so later loops lie on top of earlier ones
  void gutTube(PGraphics g, float[] path, float w, int col, int sh, int lt) {
    float L = len(path), step = 26;
    int shO = lerpColor(col, sh, 0.65), ltO = lerpColor(col, lt, 0.9), fold = lerpColor(col, sh, 0.45);
    for (float s = 0; s < L; s += step) {
      float e = min(L, s + step);
      float[] ink = sub(path, s, e);
      float[] fil = sub(path, max(0, s - 12), e);
      g.noFill();
      g.stroke(D_INK);
      g.strokeWeight(w + 5);
      polyline(g, ink);
      g.stroke(col);
      g.strokeWeight(w);
      polyline(g, fil);
      g.stroke(shO);
      g.strokeWeight(w * 0.22);
      polyline(g, offset(fil, -w * 0.28));
      g.stroke(ltO);
      g.strokeWeight(w * 0.16);
      polyline(g, offset(fil, w * 0.2));
      // circular folds (plicae) hint
      g.stroke(fold);
      g.strokeWeight(1.3);
      for (float d = s + 6; d < e - 2; d += 13) {
        float[] q = sub(path, d - 0.5, d + 0.5);
        float x = q[0], y = q[1], dx = q[q.length - 2] - q[0], dy = q[q.length - 1] - q[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
        float nx = -dy / m * w * 0.18, ny = dx / m * w * 0.18;
        g.line(x + nx * 0.2, y + ny * 0.2, x - nx * 1.6, y - ny * 1.6);
      }
    }
  }

  // darker rim + body fill without the offset highlight (for strongly concave shapes)
  void shadedPlain(PGraphics g, float[] p, int base, int sh, float sw) {
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, offsetClosed(p, 7));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  // closed polygon shrunk inward by d (points listed clockwise on screen)
  float[] offsetClosed(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = (i - 1 + n) % n, b = (i + 1) % n;
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  // bumpy glandular texture inside a shape
  void lobules(PGraphics g, float[] p, int col, int seed) {
    java.util.Random rnd = new java.util.Random(seed);
    g.noFill();
    g.stroke(col, 140);
    g.strokeWeight(1.2);
    float x0 = minX(p), y0 = minY(p);
    for (int i = 0; i < 90; i++) {
      float x = x0 + rnd.nextFloat() * 260, y = y0 + rnd.nextFloat() * 80;
      if (insideM(p, x, y, 6)) g.arc(x, y, 9, 7, PI * 0.1, PI * 1.1);
    }
  }

  boolean insideM(float[] p, float x, float y, float m) {
    return insidePoly(p, x, y) && insidePoly(p, x + m, y) && insidePoly(p, x - m, y) && insidePoly(p, x, y + m) && insidePoly(p, x, y - m);
  }

  // a vessel-like tube: fill, shade stripe, highlight stripe, ink outline
  void tube(PGraphics g, float[] path, float w, int col, int sh, int lt, boolean hlLeft) {
    float[] poly = tubePoly(path, w);
    g.noStroke();
    g.fill(col);
    polygon(g, poly);
    float L = len(path), trim = min(w * 0.35, L * 0.2);
    float[] inner = sub(path, trim, L - trim);
    float s = hlLeft ? 1 : -1;
    g.noFill();
    g.strokeCap(SQUARE);
    g.stroke(sh, 150);
    g.strokeWeight(w * 0.2);
    polyline(g, offset(inner, -s * w * 0.3));
    g.stroke(lt, 210);
    g.strokeWeight(w * 0.14);
    polyline(g, offset(inner, s * w * 0.2));
    g.strokeCap(ROUND);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    polygon(g, poly);
  }

  void cutEnd(PGraphics g, float[] path, boolean atStart, float w, int sh) {
    int n = path.length / 2;
    int i0 = atStart ? 0 : n - 1, i1 = atStart ? 1 : n - 2;
    float x = path[i0 * 2], y = path[i0 * 2 + 1];
    float ang = atan2(path[i0 * 2 + 1] - path[i1 * 2 + 1], path[i0 * 2] - path[i1 * 2]);
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(ang);
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(sh);
    g.ellipse(0, 0, w * 0.32, w - 1);
    g.popMatrix();
  }

  // ------------------------------------------------------------ helpers
  void shaded(PGraphics g, float[] p, int base, int sh, int lt, float k, float sw) {
    float[] c = centroid(p);
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, scaled(p, c[0], c[1], k, -3, -4));
    g.fill(lt, 80);
    polygon(g, scaled(p, c[0] - 0.25 * (c[0] - minX(p)), c[1] - 0.3 * (c[1] - minY(p)), 0.5, 0, 0));
    g.fill(lt, 90);
    polygon(g, scaled(p, c[0] - 0.3 * (c[0] - minX(p)), c[1] - 0.38 * (c[1] - minY(p)), 0.28, 0, 0));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  void dashed(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3];
      float d = dist(x0, y0, x1, y1), t = 0;
      while (t < d) {
        float lim = (draw ? on : off) - acc, step = min(lim, d - t);
        if (draw) g.line(x0 + (x1 - x0) * t / d, y0 + (y1 - y0) * t / d, x0 + (x1 - x0) * (t + step) / d, y0 + (y1 - y0) * (t + step) / d);
        t += step;
        acc += step;
        if (acc >= (draw ? on : off) - 0.001) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  float[] cr(float[] c, boolean closed, int seg) {
    int n = c.length / 2, segs = closed ? n : n - 1;
    float[] r = new float[(segs * seg + (closed ? 0 : 1)) * 2];
    int k = 0;
    for (int i = 0; i < segs; i++) {
      int i0 = closed ? (i - 1 + n) % n : max(i - 1, 0), i2 = closed ? (i + 1) % n : i + 1, i3 = closed ? (i + 2) % n : min(i + 2, n - 1);
      for (int s = 0; s < seg; s++) {
        float t = s / (float) seg;
        r[k++] = crv(c[i0 * 2], c[i * 2], c[i2 * 2], c[i3 * 2], t);
        r[k++] = crv(c[i0 * 2 + 1], c[i * 2 + 1], c[i2 * 2 + 1], c[i3 * 2 + 1], t);
      }
    }
    if (!closed) {
      r[k++] = c[(n - 1) * 2];
      r[k++] = c[(n - 1) * 2 + 1];
    }
    return r;
  }

  float crv(float p0, float p1, float p2, float p3, float t) {
    return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
  }

  float len(float[] p) {
    float L = 0;
    for (int i = 0; i + 3 < p.length; i += 2) L += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    return L;
  }

  float[] sub(float[] p, float a, float b) {
    ArrayList<Float> o = new ArrayList<Float>();
    float acc = 0;
    b = min(b, len(p));
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3], d = dist(x0, y0, x1, y1);
      if (d < 1e-4) continue;
      float s0 = acc, s1 = acc + d;
      if (s1 >= a && s0 <= b) {
        float ta = max(0, (a - s0) / d), tb = min(1, (b - s0) / d);
        if (o.size() == 0) {
          o.add(lerp(x0, x1, ta));
          o.add(lerp(y0, y1, ta));
        }
        o.add(lerp(x0, x1, tb));
        o.add(lerp(y0, y1, tb));
      }
      acc = s1;
    }
    float[] r = new float[o.size()];
    for (int i = 0; i < r.length; i++) r[i] = o.get(i);
    return r;
  }

  float[] offset(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  float[] tubePoly(float[] p0, float w) {
    float[] p = clean(p0);
    float[] l = offset(p, w / 2), rr = offset(p, -w / 2);
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      r[i * 2] = l[i * 2];
      r[i * 2 + 1] = l[i * 2 + 1];
      r[(2 * n - 1 - i) * 2] = rr[i * 2];
      r[(2 * n - 1 - i) * 2 + 1] = rr[i * 2 + 1];
    }
    return r;
  }

  // drop points closer than 1 unit to their neighbour (they make wild normals / miter spikes)
  float[] clean(float[] p) {
    FloatList o = new FloatList();
    for (int i = 0; i < p.length; i += 2) {
      int k = o.size();
      boolean last = i == p.length - 2;
      if (k >= 2 && dist(o.get(k - 2), o.get(k - 1), p[i], p[i + 1]) < 1) {
        if (last && k >= 4) {
          o.set(k - 2, p[i]);
          o.set(k - 1, p[i + 1]);
        }
        continue;
      }
      o.append(p[i]);
      o.append(p[i + 1]);
    }
    return o.array();
  }

  float[] centroid(float[] p) {
    float x = 0, y = 0;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      x += p[i * 2];
      y += p[i * 2 + 1];
    }
    return new float[] { x / n, y / n };
  }

  float minX(float[] p) {
    float m = 1e9;
    for (int i = 0; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float minY(float[] p) {
    float m = 1e9;
    for (int i = 1; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float[] scaled(float[] p, float cx, float cy, float k, float dx, float dy) {
    float[] r = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      r[i] = cx + (p[i] - cx) * k + dx;
      r[i + 1] = cy + (p[i + 1] - cy) * k + dy;
    }
    return r;
  }

  void polygon(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void polyline(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }
}


// ======================================================================
// TAB: Dia_Heart.pde
// ======================================================================
// Heart: anterior view of a frontal section, all four chambers open.
// Subject's right = viewer's left. Oxygen-poor blood blue, oxygen-rich red.
// The great arteries twist: the pulmonary trunk leaves the RV outflow and
// crosses IN FRONT of the ascending aorta, splitting under the aortic arch.

class HeartDiagram extends Diagram {
  final int MYO = #E9A28E, MYO_SH = #C7735F, MYO_LT = #F7CDBE;
  final int BB = #7EA0E6, BB_SH = #4F72C2, BB_LT = #B3C8F4;     // oxygen-poor blood
  final int RB = #E0595A, RB_SH = #AE3438, RB_LT = #F4979A;     // oxygen-rich blood
  final int VEIN_LT = #8FB0EE, ART_LT = #F08E8E;
  final int VALVE = #FFF7E6, VALVE_SH = #DCCBA8;

  // control points (closed / open Catmull-Rom splines)
  final float[] OUT_C = { 215, 224, 262, 236, 300, 250, 340, 256, 378, 240, 425, 229, 470, 239, 497, 277, 503, 335, 500, 390, 488, 445, 462, 500, 425, 546, 388, 571, 352, 566, 300, 546, 252, 513, 212, 474, 190, 428, 158, 399, 121, 372, 103, 315, 110, 262, 135, 231, 166, 223 };
  final float[] RA_C = { 150, 247, 190, 243, 238, 249, 257, 276, 259, 325, 251, 368, 222, 385, 176, 384, 141, 362, 124, 316, 128, 272 };
  final float[] RV_C = { 210, 405, 262, 401, 274, 372, 274, 314, 279, 274, 317, 272, 322, 306, 314, 338, 306, 368, 320, 410, 338, 468, 350, 520, 340, 538, 306, 530, 264, 504, 228, 471, 208, 437 };
  final float[] LA_C = { 388, 254, 430, 246, 469, 256, 485, 290, 478, 325, 446, 337, 402, 336, 383, 302 };
  final float[] LV_C = { 333, 306, 373, 303, 390, 336, 396, 351, 458, 352, 467, 395, 457, 450, 433, 500, 401, 527, 383, 521, 368, 465, 352, 400, 341, 350 };
  final float[] AO_C = { 351, 302, 342, 252, 321, 202, 305, 152, 307, 110, 331, 82, 375, 71, 420, 80, 450, 110, 460, 160, 460, 233 };
  final float[] PT_C = { 298, 276, 305, 238, 324, 207, 353, 187, 388, 177 };
  final float[] LPA_C = { 380, 177, 430, 170, 480, 168, 525, 172, 566, 180 };
  final float[] LPA2_C = { 520, 174, 545, 192, 566, 214 };
  final float[] RPA_C = { 386, 179, 330, 176, 260, 176, 190, 179, 120, 183, 42, 189 };
  final float[] RPA2_C = { 92, 186, 70, 202, 46, 216 };
  final float[] SVC_C = { 190, 18, 190, 120, 190, 250 };
  final float[] IVC_C = { 160, 352, 160, 470, 160, 580 };
  final float[] BC_C = { 326, 92, 314, 52, 304, 16 };
  final float[] LCC_C = { 368, 76, 368, 40, 368, 14 };
  final float[] LSC_C = { 410, 82, 422, 46, 432, 16 };
  final float[] PVR1_C = { 140, 246, 90, 240, 40, 238 };
  final float[] PVR2_C = { 132, 288, 85, 288, 38, 292 };
  final float[] PVL1_C = { 470, 268, 520, 258, 566, 254 };
  final float[] PVL2_C = { 478, 312, 525, 318, 568, 326 };

  final float W_AO = 44, W_PT = 46, W_PA = 30, W_PA2 = 16, W_CAVA = 48, W_PV = 22, W_BR = 20;

  float[] outline, raCav, rvCav, laCav, lvCav;
  float[] ao, pt, lpa, lpa2, rpa, rpa2, svc, ivc, bc, lcc, lsc, pvr1, pvr2, pvl1, pvl2;

  HeartDiagram() {
    super("heart", "Heart (front view)");
    outline = cr(OUT_C, true, 10);
    raCav = cr(RA_C, true, 10);
    rvCav = cr(RV_C, true, 10);
    laCav = cr(LA_C, true, 10);
    lvCav = cr(LV_C, true, 10);
    ao = cr(AO_C, false, 12);
    pt = cr(PT_C, false, 10);
    lpa = cr(LPA_C, false, 10);
    lpa2 = cr(LPA2_C, false, 10);
    rpa = cr(RPA_C, false, 10);
    rpa2 = cr(RPA2_C, false, 10);
    svc = cr(SVC_C, false, 10);
    ivc = cr(IVC_C, false, 10);
    bc = cr(BC_C, false, 8);
    lcc = cr(LCC_C, false, 8);
    lsc = cr(LSC_C, false, 8);
    pvr1 = cr(PVR1_C, false, 8);
    pvr2 = cr(PVR2_C, false, 8);
    pvl1 = cr(PVL1_C, false, 8);
    pvl2 = cr(PVL2_C, false, 8);

    // chambers first (each = its cavity + surrounding wall)
    add("right_atrium", "Right Atrium")
      .poly(166, 223, 135, 231, 110, 262, 102, 315, 120, 372, 158, 399, 200, 398, 267, 400, 267, 300, 267, 246, 262, 236, 215, 224)
      .anchor(190, 312);
    add("right_ventricle", "Right Ventricle")
      .poly(196, 404, 267, 400, 267, 290, 274, 263, 324, 263, 327, 304, 320, 340, 312, 368, 326, 410, 343, 468, 356, 522, 360, 548, 352, 566, 300, 546, 252, 513, 212, 474, 189, 428)
      .anchor(262, 455);
    add("left_atrium", "Left Atrium")
      .poly(380, 240, 425, 228, 470, 238, 497, 276, 504, 338, 462, 347, 392, 344, 378, 302)
      .anchor(436, 292);
    add("left_ventricle", "Left Ventricle")
      .poly(330, 306, 378, 301, 392, 343, 462, 347, 504, 340, 500, 390, 488, 445, 462, 500, 425, 546, 388, 572, 362, 567, 374, 550, 384, 525, 368, 465, 352, 400, 338, 345)
      .anchor(412, 450);
    add("interventricular_septum", "Interventricular Septum")
      .poly(305, 350, 340, 338, 354, 398, 370, 463, 386, 524, 376, 553, 350, 542, 335, 470, 318, 412, 302, 372)
      .anchor(343, 440);
    // great vessels
    add("superior_vena_cava", "Superior Vena Cava")
      .poly(165, 14, 215, 14, 215, 229, 165, 229)
      .anchor(190, 120);
    add("inferior_vena_cava", "Inferior Vena Cava")
      .poly(135, 386, 160, 400, 185, 419, 185, 582, 135, 582)
      .anchor(160, 510);
    Part a = add("aorta", "Aorta");
    a.poly(tubePoly(sub(ao, 0, 9999), W_AO));
    a.poly(tubePoly(bc, W_BR + 4)).poly(tubePoly(lcc, W_BR + 2)).poly(tubePoly(lsc, W_BR + 4));
    a.anchor(375, 72);
    Part p = add("pulmonary_trunk", "Pulmonary Trunk");
    p.poly(tubePoly(pt, W_PT)).poly(tubePoly(lpa, W_PA)).poly(tubePoly(lpa2, W_PA2 + 4));
    p.poly(tubePoly(sub(rpa, 98, 172), W_PA)); // between SVC and aorta
    p.poly(tubePoly(sub(rpa, 222, 9999), W_PA)).poly(tubePoly(rpa2, W_PA2 + 4)); // left of the SVC
    p.anchor(322, 222);
    add("pulmonary_veins", "Pulmonary Veins")
      .poly(tubePoly(sub(pvr1, len(pvr1) - 78, len(pvr1)), W_PV + 4))
      .poly(tubePoly(sub(pvr2, len(pvr2) - 76, len(pvr2)), W_PV + 4))
      .poly(tubePoly(sub(pvl1, 22, len(pvl1)), W_PV + 4))
      .poly(tubePoly(sub(pvl2, 22, len(pvl2)), W_PV + 4))
      .anchor(528, 259);
    // valves and nodes on top
    add("tricuspid_valve", "Tricuspid Valve")
      .poly(196, 384, 236, 380, 270, 388, 262, 418, 250, 442, 230, 444, 210, 440, 198, 414)
      .anchor(232, 405);
    add("pulmonary_valve", "Pulmonary Valve").ellipse(298, 274, 29, 13);
    add("mitral_valve", "Mitral Valve")
      .poly(392, 332, 430, 330, 466, 336, 458, 370, 448, 398, 428, 402, 410, 400, 396, 372)
      .anchor(428, 360);
    add("aortic_valve", "Aortic Valve").ellipse(351, 302, 29, 13);
    add("sa_node", "SA Node").ellipse(168, 238, 14, 12);
    add("av_node", "AV Node").ellipse(263, 381, 13, 13);
  }

  void drawArt(PGraphics g) {
    // ---- vessels behind the heart
    tube(g, rpa2, W_PA2, BB, BB_SH, VEIN_LT, true);
    tube(g, rpa, W_PA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, rpa, false, W_PA, BB_SH);   // open end at the right lung hilum (its start is hidden under the trunk)
    cutEnd(g, rpa2, false, W_PA2, BB_SH);
    tube(g, pvr1, W_PV, RB, RB_SH, ART_LT, true);
    tube(g, pvr2, W_PV, RB, RB_SH, ART_LT, true);
    tube(g, pvl1, W_PV, RB, RB_SH, ART_LT, true);
    tube(g, pvl2, W_PV, RB, RB_SH, ART_LT, true);
    cutEnd(g, pvr1, false, W_PV, RB_SH);
    cutEnd(g, pvr2, false, W_PV, RB_SH);
    cutEnd(g, pvl1, false, W_PV, RB_SH);
    cutEnd(g, pvl2, false, W_PV, RB_SH);
    tube(g, ivc, W_CAVA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, ivc, false, W_CAVA, BB_SH);
    tube(g, svc, W_CAVA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, svc, true, W_CAVA, BB_SH);
    // aorta: branches, arch, descending (root is redrawn over the heart later)
    tube(g, bc, W_BR, RB, RB_SH, ART_LT, true);
    tube(g, lcc, W_BR - 2, RB, RB_SH, ART_LT, true);
    tube(g, lsc, W_BR, RB, RB_SH, ART_LT, true);
    cutEnd(g, bc, false, W_BR, RB_SH);
    cutEnd(g, lcc, false, W_BR - 2, RB_SH);
    cutEnd(g, lsc, false, W_BR, RB_SH);
    tube(g, ao, W_AO, RB, RB_SH, ART_LT, false);

    // ---- heart wall (myocardium)
    shaded(g, outline, MYO, MYO_SH, MYO_LT, 0.95, 2.8);
    // faint muscle fibre arcs in the thick LV wall and the septum
    g.noFill();
    g.stroke(MYO_SH, 110);
    g.strokeWeight(1.4);
    polyline(g, cr(new float[] { 484, 372, 477, 440, 450, 500, 410, 540 }, false, 8));
    polyline(g, cr(new float[] { 492, 395, 478, 458, 446, 512, 408, 552 }, false, 8));
    polyline(g, cr(new float[] { 326, 372, 340, 430, 356, 490, 366, 532 }, false, 8));
    polyline(g, cr(new float[] { 196, 444, 220, 486, 260, 520, 300, 538 }, false, 8));

    // ---- chambers (blood)
    // openings between atria and ventricles (blood continuous through the valves)
    g.noStroke();
    g.fill(BB);
    quad4(g, 206, 380, 252, 372, 266, 404, 208, 410);
    g.fill(RB);
    quad4(g, 400, 330, 450, 332, 460, 358, 396, 356);
    shaded(g, raCav, BB, BB_SH, BB_LT, 0.9, 2.2);
    shaded(g, rvCav, BB, BB_SH, BB_LT, 0.9, 2.2);
    shaded(g, laCav, RB, RB_SH, RB_LT, 0.9, 2.2);
    shaded(g, lvCav, RB, RB_SH, RB_LT, 0.9, 2.2);
    // repaint the valve openings over the cavity outlines
    g.noStroke();
    g.fill(BB);
    quad4(g, 212, 378, 248, 372, 260, 406, 214, 408);
    g.fill(RB);
    quad4(g, 404, 328, 448, 330, 456, 360, 400, 358);
    // orifices of the venae cavae in the right atrium
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(BB_SH);
    g.ellipse(190, 256, 38, 12);
    g.ellipse(165, 372, 36, 12);

    // papillary muscles + chordae tendineae
    papillary(g, 248, 491, 238, 462, 13);
    papillary(g, 335, 456, 308, 442, 12);
    papillary(g, 414, 518, 414, 470, 15);
    papillary(g, 459, 446, 440, 428, 14);
    g.stroke(#FFFBF0);
    g.strokeWeight(1.4);
    g.line(220, 432, 238, 462);
    g.line(232, 434, 238, 462);
    g.line(246, 436, 308, 442);
    g.line(246, 436, 238, 462);
    g.line(416, 392, 414, 470);
    g.line(424, 394, 414, 470);
    g.line(440, 390, 440, 428);
    g.line(446, 388, 440, 428);

    // crisp outline of the heart (before the great arteries, which sit in front)
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.8);
    polygon(g, outline);

    // ---- aortic root (in front, opened) + aortic valve
    float[] root = sub(ao, 0, 92);
    tube(g, root, W_AO, RB, RB_SH, ART_LT, false);
    semilunar(g, 351, 302, W_AO - 4, 0);

    // ---- pulmonary trunk + arteries (anterior, crossing the aorta)
    tube(g, lpa2, W_PA2, BB, BB_SH, VEIN_LT, true);
    tube(g, lpa, W_PA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, lpa, false, W_PA, BB_SH);
    cutEnd(g, lpa2, false, W_PA2, BB_SH);
    tube(g, pt, W_PT, BB, BB_SH, VEIN_LT, true);
    semilunar(g, 298, 274, W_PT - 4, 0);

    // ---- atrioventricular valves (leaflets hang into the ventricles)
    leaflet(g, 206, 386, 234, 384, 220, 434);
    leaflet(g, 236, 384, 264, 392, 246, 438);
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.noFill();
    g.line(203, 384, 266, 392);
    leaflet(g, 398, 333, 430, 332, 418, 396);
    leaflet(g, 430, 332, 460, 338, 444, 390);
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.line(396, 333, 462, 338);

    // ---- conduction nodes (with a faint internodal pathway)
    g.noFill();
    g.stroke(D_NERVE, 200);
    g.strokeWeight(2);
    dashed(g, cr(new float[] { 176, 242, 230, 244, 256, 262, 264, 320, 263, 372 }, false, 10), 5, 5);
    node(g, 168, 238, 11, 8);
    node(g, 263, 381, 9, 9);
  }

  // ------------------------------------------------------------ drawing helpers
  void node(PGraphics g, float x, float y, float rx, float ry) {
    g.noStroke();
    g.fill(D_NERVE, 90);
    g.ellipse(x, y, rx * 2 + 9, ry * 2 + 9);
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(D_NERVE);
    g.ellipse(x, y, rx * 2, ry * 2);
    g.noStroke();
    g.fill(255, 240, 190);
    g.ellipse(x - rx * 0.3, y - ry * 0.35, rx * 0.7, ry * 0.6);
  }

  // a papillary muscle growing out of the wall at (bx, by) with its tip at (tx, ty)
  void papillary(PGraphics g, float bx, float by, float tx, float ty, float w) {
    float dx = tx - bx, dy = ty - by, L = sqrt(dx * dx + dy * dy);
    float ux = dx / L, uy = dy / L, nx = -uy * w / 2, ny = ux * w / 2;
    float ex = bx - ux * 7, ey = by - uy * 7;   // base buried in the wall
    g.noStroke();
    g.fill(MYO);
    g.beginShape();
    g.vertex(ex + nx * 1.6, ey + ny * 1.6);
    g.vertex(bx + nx * 1.5, by + ny * 1.5);
    g.bezierVertex(bx + nx * 0.9 + ux * L * 0.4, by + ny * 0.9 + uy * L * 0.4, tx + nx, ty + ny, tx + ux * w * 0.5, ty + uy * w * 0.5);
    g.bezierVertex(tx - nx, ty - ny, bx - nx * 0.9 + ux * L * 0.4, by - ny * 0.9 + uy * L * 0.4, bx - nx * 1.5, by - ny * 1.5);
    g.vertex(ex - nx * 1.6, ey - ny * 1.6);
    g.endShape(CLOSE);
    g.stroke(MYO_LT);
    g.strokeWeight(w * 0.25);
    g.line(bx + ux * L * 0.3 + nx * 0.3, by + uy * L * 0.3 + ny * 0.3, tx - ux * 3 + nx * 0.3, ty - uy * 3 + ny * 0.3);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.beginShape();
    g.vertex(bx + nx * 1.5, by + ny * 1.5);
    g.bezierVertex(bx + nx * 0.9 + ux * L * 0.4, by + ny * 0.9 + uy * L * 0.4, tx + nx, ty + ny, tx + ux * w * 0.5, ty + uy * w * 0.5);
    g.bezierVertex(tx - nx, ty - ny, bx - nx * 0.9 + ux * L * 0.4, by - ny * 0.9 + uy * L * 0.4, bx - nx * 1.5, by - ny * 1.5);
    g.endShape();
  }

  // an atrioventricular cusp: hinge from (x0,y0)-(x1,y1), free tip at (tx,ty)
  void leaflet(PGraphics g, float x0, float y0, float x1, float y1, float tx, float ty) {
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(VALVE);
    g.beginShape();
    g.vertex(x0, y0);
    g.bezierVertex(x0 + 2, y0 + (ty - y0) * 0.5, tx - 6, ty - 8, tx, ty);
    g.bezierVertex(tx + 6, ty - 8, x1 - 2, y1 + (ty - y1) * 0.5, x1, y1);
    g.endShape(CLOSE);
    g.stroke(VALVE_SH);
    g.strokeWeight(1.2);
    g.line((x0 + x1) / 2, (y0 + y1) / 2 + 4, tx, ty - 6);
  }

  // three semilunar cusps across a vessel base centred at (cx, cy)
  void semilunar(PGraphics g, float cx, float cy, float w, float ang) {
    float cw = w / 3;
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    for (int i = 0; i < 3; i++) {
      float x0 = cx - w / 2 + i * cw;
      g.fill(VALVE);
      g.beginShape();
      g.vertex(x0, cy);
      g.bezierVertex(x0 + 1, cy - 12, x0 + cw - 1, cy - 12, x0 + cw, cy);
      g.bezierVertex(x0 + cw * 0.7, cy - 4, x0 + cw * 0.3, cy - 4, x0, cy);
      g.endShape(CLOSE);
    }
    g.strokeWeight(2.4);
    g.line(cx - w / 2 - 2, cy, cx + w / 2 + 2, cy);
  }

  void quad4(PGraphics g, float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3) {
    g.quad(x0, y0, x1, y1, x2, y2, x3, y3);
  }

  // fill a closed shape with a darker rim, lighter body and a soft highlight, then outline it
  void shaded(PGraphics g, float[] p, int base, int sh, int lt, float k, float sw) {
    float[] c = centroid(p);
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, scaled(p, c[0], c[1], k, -2.5, -3));
    g.fill(lt, 120);
    polygon(g, scaled(p, c[0] - 0.18 * (c[0] - minX(p)), c[1] - 0.2 * (c[1] - minY(p)), 0.45, 0, 0));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  // a vessel: filled tube with a shade stripe, a highlight stripe and an ink outline
  void tube(PGraphics g, float[] path, float w, int col, int sh, int lt, boolean hlLeft) {
    float[] poly = tubePoly(path, w);
    g.noStroke();
    g.fill(col);
    polygon(g, poly);
    float L = len(path), trim = min(w * 0.35, L * 0.2);
    float[] inner = sub(path, trim, L - trim);
    float s = hlLeft ? 1 : -1;
    g.noFill();
    g.strokeCap(SQUARE);
    g.stroke(sh, 150);
    g.strokeWeight(w * 0.2);
    polyline(g, offset(inner, -s * w * 0.3));
    g.stroke(lt, 210);
    g.strokeWeight(w * 0.14);
    polyline(g, offset(inner, s * w * 0.2));
    g.strokeCap(ROUND);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    polygon(g, poly);
  }

  // the cut end of a vessel (lumen seen end-on)
  void cutEnd(PGraphics g, float[] path, boolean atStart, float w, int sh) {
    int n = path.length / 2;
    int i0 = atStart ? 0 : n - 1, i1 = atStart ? 1 : n - 2;
    float x = path[i0 * 2], y = path[i0 * 2 + 1];
    float ang = atan2(path[i0 * 2 + 1] - path[i1 * 2 + 1], path[i0 * 2] - path[i1 * 2]);
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(ang);
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(sh);
    g.ellipse(0, 0, w * 0.32, w - 1);
    g.popMatrix();
  }

  void dashed(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3];
      float d = dist(x0, y0, x1, y1), t = 0;
      while (t < d) {
        float lim = (draw ? on : off) - acc, step = min(lim, d - t);
        if (draw) g.line(x0 + (x1 - x0) * t / d, y0 + (y1 - y0) * t / d, x0 + (x1 - x0) * (t + step) / d, y0 + (y1 - y0) * (t + step) / d);
        t += step;
        acc += step;
        if (acc >= (draw ? on : off) - 0.001) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  // ------------------------------------------------------------ geometry helpers
  float[] cr(float[] c, boolean closed, int seg) {
    int n = c.length / 2, segs = closed ? n : n - 1;
    float[] r = new float[(segs * seg + (closed ? 0 : 1)) * 2];
    int k = 0;
    for (int i = 0; i < segs; i++) {
      int i0 = closed ? (i - 1 + n) % n : max(i - 1, 0), i2 = closed ? (i + 1) % n : i + 1, i3 = closed ? (i + 2) % n : min(i + 2, n - 1);
      for (int s = 0; s < seg; s++) {
        float t = s / (float) seg;
        r[k++] = crv(c[i0 * 2], c[i * 2], c[i2 * 2], c[i3 * 2], t);
        r[k++] = crv(c[i0 * 2 + 1], c[i * 2 + 1], c[i2 * 2 + 1], c[i3 * 2 + 1], t);
      }
    }
    if (!closed) {
      r[k++] = c[(n - 1) * 2];
      r[k++] = c[(n - 1) * 2 + 1];
    }
    return r;
  }

  float crv(float p0, float p1, float p2, float p3, float t) {
    return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
  }

  float len(float[] p) {
    float L = 0;
    for (int i = 0; i + 3 < p.length; i += 2) L += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    return L;
  }

  // the part of a polyline between arc lengths a and b
  float[] sub(float[] p, float a, float b) {
    ArrayList<Float> o = new ArrayList<Float>();
    float acc = 0;
    b = min(b, len(p));
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3], d = dist(x0, y0, x1, y1);
      if (d < 1e-4) continue;
      float s0 = acc, s1 = acc + d;
      if (s1 >= a && s0 <= b) {
        float ta = max(0, (a - s0) / d), tb = min(1, (b - s0) / d);
        if (o.size() == 0) {
          o.add(lerp(x0, x1, ta));
          o.add(lerp(y0, y1, ta));
        }
        o.add(lerp(x0, x1, tb));
        o.add(lerp(y0, y1, tb));
      }
      acc = s1;
    }
    float[] r = new float[o.size()];
    for (int i = 0; i < r.length; i++) r[i] = o.get(i);
    return r;
  }

  float[] offset(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  float[] tubePoly(float[] p0, float w) {
    float[] p = clean(p0);
    float[] l = offset(p, w / 2), rr = offset(p, -w / 2);
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      r[i * 2] = l[i * 2];
      r[i * 2 + 1] = l[i * 2 + 1];
      r[(2 * n - 1 - i) * 2] = rr[i * 2];
      r[(2 * n - 1 - i) * 2 + 1] = rr[i * 2 + 1];
    }
    return r;
  }

  // drop points closer than 1 unit to their neighbour (they make wild normals / miter spikes)
  float[] clean(float[] p) {
    FloatList o = new FloatList();
    for (int i = 0; i < p.length; i += 2) {
      int k = o.size();
      boolean last = i == p.length - 2;
      if (k >= 2 && dist(o.get(k - 2), o.get(k - 1), p[i], p[i + 1]) < 1) {
        if (last && k >= 4) {
          o.set(k - 2, p[i]);
          o.set(k - 1, p[i + 1]);
        }
        continue;
      }
      o.append(p[i]);
      o.append(p[i + 1]);
    }
    return o.array();
  }

  float[] centroid(float[] p) {
    float x = 0, y = 0;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      x += p[i * 2];
      y += p[i * 2 + 1];
    }
    return new float[] { x / n, y / n };
  }

  float minX(float[] p) {
    float m = 1e9;
    for (int i = 0; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float minY(float[] p) {
    float m = 1e9;
    for (int i = 1; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float[] scaled(float[] p, float cx, float cy, float k, float dx, float dy) {
    float[] r = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      r[i] = cx + (p[i] - cx) * k + dx;
      r[i + 1] = cy + (p[i + 1] - cy) * k + dy;
    }
    return r;
  }

  void polygon(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void polyline(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }
}


// ======================================================================
// TAB: Dia_Lungs.pde
// ======================================================================
// Lungs + respiratory tree, anterior view (subject's right = viewer's left).
// Right lung: 3 lobes (horizontal + oblique fissures). Left lung: 2 lobes, cardiac
// notch with the heart peeking out behind it. Right main bronchus wider, shorter,
// more vertical. Bronchioles branch inside both lungs; alveoli in a magnified inset.

class LungsDiagram extends Diagram {
  final int AIR = #E7EDF4, AIR_SH = #AFC0D4, AIR_RING = #C3CFDE, AIR_LT = #FFFFFF;
  final int LUNG = #F09CAA, LUNG_SH = #D27A8C, LUNG_LT = #F9C9D1;
  final int ALV = #F5B0BC, ALV_SH = #D8818F;

  final float[] RL_C = { 196, 98, 228, 114, 250, 156, 261, 218, 265, 284, 258, 312, 262, 345, 263, 400, 260, 452, 256, 473, 228, 466, 160, 459, 105, 469, 72, 490, 56, 506, 47, 445, 47, 350, 60, 258, 96, 168, 148, 115 };
  final float[] LL_C = { 404, 98, 452, 116, 502, 170, 537, 250, 552, 340, 554, 430, 546, 514, 520, 494, 452, 478, 400, 484, 360, 490, 351, 474, 370, 455, 402, 438, 408, 400, 392, 366, 352, 345, 341, 322, 344, 296, 337, 232, 345, 162, 370, 116 };
  final float[] DIA_TOP = { 30, 566, 48, 520, 90, 483, 160, 465, 230, 474, 300, 494, 370, 491, 452, 484, 522, 499, 556, 530, 572, 572 };
  final float[] RL_HFIS = { 263, 290, 200, 292, 130, 296, 56, 302 };
  final float[] RL_OFIS = { 53, 268, 64, 312, 100, 380, 150, 430, 196, 462 };
  final float[] LL_OFIS = { 537, 262, 532, 320, 496, 390, 456, 446, 428, 481 };
  // airway: trachea x 281..319 down to y 236, then two straight main bronchi
  final float TR_L = 281, TR_R = 319, TR_TOP = 108, TR_BOT = 236;
  final float[] RMB = { 293, 250, 252, 330 };   // wide (30), short, steep
  final float[] LMB = { 309, 250, 392, 318 };   // narrow (23), long, more horizontal
  final float W_RMB = 30, W_LMB = 23;

  float[] rl, ll, diaTop, diaBot, dia, rmb, lmb;
  float[] yOut1, yOut2, yOut3, yPoly;   // airway silhouette (3 open outline runs + filled polygon)
  float carX, carY;
  ArrayList<float[]> segs = new ArrayList<float[]>();   // x0, y0, x1, y1, width, lobe, depth
  final float BUB_X = 524, BUB_Y = 76, BUB_R = 55;

  LungsDiagram() {
    super("lungs", "Respiratory Tree");
    rl = cr(RL_C, true, 8);
    ll = cr(LL_C, true, 8);
    diaTop = cr(DIA_TOP, false, 10);
    diaBot = offset(diaTop, 28);
    dia = new float[diaTop.length * 2];
    int n = diaTop.length / 2;
    for (int i = 0; i < n; i++) {
      dia[i * 2] = diaTop[i * 2];
      dia[i * 2 + 1] = diaTop[i * 2 + 1];
      dia[(2 * n - 1 - i) * 2] = diaBot[i * 2];
      dia[(2 * n - 1 - i) * 2 + 1] = min(DIA - 4, diaBot[i * 2 + 1]);
    }
    rmb = RMB;
    lmb = LMB;
    buildAirway();

    // ---- bronchial tree (lobar -> segmental -> bronchioles), kept inside each lung
    // right lung: upper lobe, middle lobe, lower lobe
    grow(262, 318, radians(-128), 52, 13, 0, 3, rl, 0);
    grow(255, 338, radians(122), 50, 12, 0, 3, rl, 1);
    grow(252, 336, radians(146), 70, 12, 0, 3, rl, 2);
    // left lung: upper lobe, lingula, lower lobe
    grow(390, 318, radians(-62), 58, 11, 0, 3, ll, 3);
    grow(394, 326, radians(52), 70, 11, 0, 3, ll, 5);

    add("right_lung", "Right Lung").poly(rl).anchor(100, 232);   // plain upper-lobe tissue, clear of the bronchiole hulls
    add("left_lung", "Left Lung").poly(ll).anchor(470, 300);
    add("diaphragm", "Diaphragm").poly(dia).anchor(96, 504);
    add("cardiac_notch", "Cardiac Notch")
      .poly(342, 338, 372, 348, 400, 366, 418, 400, 412, 444, 376, 462, 352, 470, 336, 452, 330, 400, 332, 360)
      .anchor(392, 408);
    Part b = add("bronchioles", "Bronchioles");
    for (int lobe = 0; lobe < 6; lobe++) {
      float[] h = hullOfLobe(lobe, 2, 6);
      if (h != null) b.poly(h);
    }
    b.anchor(176, 228);
    add("trachea", "Trachea").rect(279, 108, 42, 134).anchor(300, 175);
    add("larynx", "Larynx").poly(260, 26, 340, 26, 342, 50, 338, 70, 330, 94, 325, 109, 275, 109, 270, 94, 262, 70, 258, 50).anchor(300, 62);
    add("right_main_bronchus", "Right Main Bronchus").poly(tubePoly(sub(rmb, 4, 999), W_RMB + 6)).anchor(272, 292);
    add("left_main_bronchus", "Left Main Bronchus").poly(tubePoly(sub(lmb, 4, 999), W_LMB + 6)).anchor(352, 286);
    add("carina", "Carina").ellipse(carX, carY - 6, 15, 13);
    // the magnified bubble + the ringed spot in the lung it magnifies (a bronchiole tip ending in alveoli)
    add("alveoli", "Alveoli").ellipse(BUB_X, BUB_Y, BUB_R + 2, BUB_R + 2).ellipse(470, 205, 13, 13).anchor(BUB_X, BUB_Y);
  }

  // recursive airway branching; each child is shortened until it stays inside the lung
  void grow(float x, float y, float ang, float L, float w, int depth, int maxD, float[] lung, int lobe) {
    float x1 = 0, y1 = 0;
    int tries = 0;
    for (; tries < 6; tries++) {
      x1 = x + cos(ang) * L;
      y1 = y + sin(ang) * L;
      if (insideM(lung, x1, y1, 9)) break;
      L *= 0.75;
    }
    if (tries >= 6 || L < 7) return;
    segs.add(new float[] { x, y, x1, y1, w, lobe, depth });
    if (depth >= maxD) return;
    float sp = 0.42 + 0.05 * depth;
    grow(x1, y1, ang - sp, L * 0.74, w * 0.62, depth + 1, maxD, lung, lobe);
    grow(x1, y1, ang + sp * 0.85, L * 0.7, w * 0.62, depth + 1, maxD, lung, lobe);
  }

  boolean insideM(float[] p, float x, float y, float m) {
    return insidePoly(p, x, y) && insidePoly(p, x + m, y) && insidePoly(p, x - m, y) && insidePoly(p, x, y + m) && insidePoly(p, x, y - m);
  }

  // convex hull (inflated) around the bronchiole-level segments of one lobe
  float[] hullOfLobe(int lobe, int minDepth, float pad) {
    ArrayList<float[]> pts = new ArrayList<float[]>();
    for (float[] s : segs) {
      if ((int) s[5] != lobe || s[6] < minDepth) continue;
      for (int k = 0; k < 8; k++) {
        float a = TWO_PI * k / 8;
        pts.add(new float[] { s[0] + cos(a) * pad, s[1] + sin(a) * pad });
        pts.add(new float[] { s[2] + cos(a) * pad, s[3] + sin(a) * pad });
      }
    }
    if (pts.size() < 3) return null;
    java.util.Collections.sort(pts, new java.util.Comparator<float[]>() {
      public int compare(float[] a, float[] b) {
        return a[0] != b[0] ? Float.compare(a[0], b[0]) : Float.compare(a[1], b[1]);
      }
    });
    int n = pts.size(), k = 0;
    float[][] h = new float[2 * n][];
    for (int i = 0; i < n; i++) {
      while (k >= 2 && crossZ(h[k - 2], h[k - 1], pts.get(i)) <= 0) k--;
      h[k++] = pts.get(i);
    }
    for (int i = n - 2, t = k + 1; i >= 0; i--) {
      while (k >= t && crossZ(h[k - 2], h[k - 1], pts.get(i)) <= 0) k--;
      h[k++] = pts.get(i);
    }
    float[] r = new float[(k - 1) * 2];
    for (int i = 0; i < k - 1; i++) {
      r[i * 2] = h[i][0];
      r[i * 2 + 1] = h[i][1];
    }
    return r;
  }

  float crossZ(float[] o, float[] a, float[] b) {
    return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  }

  void drawArt(PGraphics g) {
    // ---- heart peeking out behind the cardiac notch (no part: context only)
    g.stroke(D_INK, 110);
    g.strokeWeight(2);
    g.fill(D_HEART, 80);
    g.beginShape();
    g.vertex(282, 384);
    g.bezierVertex(300, 360, 340, 350, 372, 352);
    g.bezierVertex(398, 352, 418, 372, 424, 404);
    g.bezierVertex(430, 440, 436, 470, 440, 492);
    g.bezierVertex(400, 500, 330, 500, 290, 494);
    g.bezierVertex(268, 470, 266, 414, 282, 384);
    g.endShape(CLOSE);
    g.noFill();
    g.stroke(D_HEART, 120);
    g.strokeWeight(2.4);
    g.bezier(352, 356, 360, 400, 392, 450, 430, 488);
    // ---- diaphragm
    g.noStroke();
    g.fill(D_MUSCLE);
    polygon(g, dia);
    // central tendon
    g.fill(D_TENDON);
    g.beginShape();
    for (int i = 0; i < diaTop.length; i += 2) if (diaTop[i] > 215 && diaTop[i] < 395) g.vertex(diaTop[i], diaTop[i + 1]);
    for (int i = diaBot.length - 2; i >= 0; i -= 2) if (diaBot[i] > 235 && diaBot[i] < 375) g.vertex(diaBot[i], diaBot[i + 1]);
    g.endShape(CLOSE);
    // muscle fibres
    g.stroke(#A8423B, 150);
    g.strokeWeight(1.3);
    for (int i = 0; i < diaTop.length; i += 6) {
      float x = diaTop[i];
      if (x > 205 && x < 400) continue;
      g.line(diaTop[i], diaTop[i + 1] + 3, diaBot[i], diaBot[i + 1] - 3);
    }
    g.stroke(D_MUSCLE_LT, 200);
    g.strokeWeight(3);
    g.noFill();
    polyline(g, sub(offset(diaTop, 6), 8, len(diaTop) - 8));
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.noFill();
    polygon(g, dia);

    // ---- lungs
    shaded(g, rl, LUNG, LUNG_SH, LUNG_LT, 0.93, 2.8);
    shaded(g, ll, LUNG, LUNG_SH, LUNG_LT, 0.93, 2.8);
    // lobule texture
    g.noStroke();
    g.fill(LUNG_SH, 60);
    java.util.Random rnd = new java.util.Random(7);   // local RNG: never touch the sketch's random()
    for (int i = 0; i < 260; i++) {
      float x = 40 + rnd.nextFloat() * 520, y = 90 + rnd.nextFloat() * 420;
      if ((insideM(rl, x, y, 6) || insideM(ll, x, y, 6)) && !(x > BUB_X - BUB_R - 10 && y < BUB_Y + BUB_R + 10)) g.ellipse(x, y, 3.2, 3.2);
    }

    // ---- bronchial tree inside the lungs
    g.stroke(D_INK);
    for (float[] s : segs) {
      g.strokeWeight(s[4] + 2.6);
      g.line(s[0], s[1], s[2], s[3]);
    }
    for (float[] s : segs) {
      g.stroke(s[6] >= 2 ? #F4F0F7 : AIR);
      g.strokeWeight(s[4]);
      g.line(s[0], s[1], s[2], s[3]);
    }
    g.stroke(AIR_LT, 200);
    for (float[] s : segs) {
      if (s[4] < 5) continue;
      g.strokeWeight(s[4] * 0.28);
      g.line(lerp(s[0], s[2], 0.15) - 1, lerp(s[1], s[3], 0.15) - 1, lerp(s[0], s[2], 0.85) - 1, lerp(s[1], s[3], 0.85) - 1);
    }

    // ---- fissures (drawn on the lung surface)
    g.noFill();
    g.stroke(#8E3F52);
    g.strokeWeight(2.6);
    polyline(g, cr(RL_HFIS, false, 8));
    polyline(g, cr(RL_OFIS, false, 8));
    polyline(g, cr(LL_OFIS, false, 8));
    g.stroke(LUNG_LT);
    g.strokeWeight(1.2);
    polyline(g, offset(cr(RL_HFIS, false, 8), 2.5));
    polyline(g, offset(cr(RL_OFIS, false, 8), 2.5));
    polyline(g, offset(cr(LL_OFIS, false, 8), 2.5));

    // ---- airway: trachea + main bronchi as one Y, then the larynx on top
    airwayY(g);
    larynx(g);

    // ---- alveoli: magnified inset
    alveoliInset(g);
  }

  // offset line of a straight segment: {x0, y0, x1, y1} shifted along its left normal
  float[] edge(float[] seg, float off) {
    float dx = seg[2] - seg[0], dy = seg[3] - seg[1], L = sqrt(dx * dx + dy * dy);
    float nx = -dy / L * off, ny = dx / L * off;
    return new float[] { seg[0] + nx, seg[1] + ny, seg[2] + nx, seg[3] + ny };
  }

  float[] intersect(float[] a, float[] b) {
    float x1 = a[0], y1 = a[1], x2 = a[2], y2 = a[3], x3 = b[0], y3 = b[1], x4 = b[2], y4 = b[3];
    float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / d;
    return new float[] { x1 + t * (x2 - x1), y1 + t * (y2 - y1) };
  }

  void buildAirway() {
    float[] rLat = edge(RMB, W_RMB / 2), rMed = edge(RMB, -W_RMB / 2);   // RMB runs down-left: +normal = lateral
    float[] lMed = edge(LMB, W_LMB / 2), lLat = edge(LMB, -W_LMB / 2);   // LMB runs down-right: +normal = medial
    float[] c = intersect(rMed, lMed);
    carX = c[0];
    carY = c[1];
    yOut1 = new float[] { TR_L, TR_TOP, TR_L, TR_BOT - 6, TR_L - 0.5, TR_BOT, rLat[0] + 0.5, rLat[1] - 2, rLat[2], rLat[3] };
    yOut2 = new float[] { rMed[2], rMed[3], carX - 3, carY + 5, carX, carY, carX + 3, carY + 4, lMed[2], lMed[3] };
    yOut3 = new float[] { lLat[2], lLat[3], lLat[0] - 0.5, lLat[1] - 2, TR_R + 0.5, TR_BOT, TR_R, TR_BOT - 6, TR_R, TR_TOP };
    yPoly = new float[yOut1.length + yOut2.length + yOut3.length];
    System.arraycopy(yOut1, 0, yPoly, 0, yOut1.length);
    System.arraycopy(yOut2, 0, yPoly, yOut1.length, yOut2.length);
    System.arraycopy(yOut3, 0, yPoly, yOut1.length + yOut2.length, yOut3.length);
  }

  // rings across a straight airway between arc lengths a..b
  void rings(PGraphics g, float[] seg, float w, float a, float b, float step) {
    float dx = seg[2] - seg[0], dy = seg[3] - seg[1], L = sqrt(dx * dx + dy * dy);
    float ux = dx / L, uy = dy / L, nx = -uy * w * 0.4, ny = ux * w * 0.4;
    for (float d = a; d < min(b, L - 3); d += step) {
      float x = seg[0] + ux * d, y = seg[1] + uy * d;
      g.line(x + nx, y + ny, x - nx, y - ny);
    }
  }

  void airwayY(PGraphics g) {
    g.noStroke();
    g.fill(AIR);
    polygon(g, yPoly);
    // shading on the subject's-left side of each tube, highlight on the other
    g.strokeCap(SQUARE);
    g.stroke(AIR_SH, 160);
    g.strokeWeight(7);
    g.line(TR_R - 5, TR_TOP + 2, TR_R - 5, TR_BOT - 4);
    float[] rs = edge(RMB, -W_RMB * 0.3), ls = edge(LMB, -W_LMB * 0.3);
    g.strokeWeight(W_RMB * 0.2);
    g.line(lerp(rs[0], rs[2], 0.25), lerp(rs[1], rs[3], 0.25), rs[2], rs[3]);
    g.strokeWeight(W_LMB * 0.2);
    g.line(lerp(ls[0], ls[2], 0.15), lerp(ls[1], ls[3], 0.15), ls[2], ls[3]);
    // cartilage rings
    g.stroke(AIR_RING);
    g.strokeWeight(3.2);
    for (float y = TR_TOP + 8; y < TR_BOT - 2; y += 10) g.line(TR_L + 3, y, TR_R - 3, y);
    rings(g, RMB, W_RMB, 22, 999, 10);
    rings(g, LMB, W_LMB, 20, 999, 10);
    g.strokeCap(ROUND);
    g.stroke(AIR_LT, 230);
    g.strokeWeight(4);
    g.line(TR_L + 7, TR_TOP + 4, TR_L + 7, TR_BOT - 6);
    // carina: the keel-shaped ridge seen through the wall at the split
    g.noStroke();
    g.fill(AIR_SH, 200);
    g.beginShape();
    g.vertex(carX - 9, carY - 1);
    g.bezierVertex(carX - 5, carY - 12, carX + 5, carY - 12, carX + 9, carY - 1);
    g.bezierVertex(carX + 4, carY - 5, carX - 4, carY - 5, carX - 9, carY - 1);
    g.endShape(CLOSE);
    // outline (bronchus ends left open: they continue into the lungs)
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    polyline(g, yOut1);
    polyline(g, yOut2);
    polyline(g, yOut3);
  }

  void larynx(PGraphics g) {
    // hyoid bone (context, above the larynx)
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.fill(D_BONE);
    g.beginShape();
    g.vertex(254, 14);
    g.bezierVertex(272, 23, 328, 23, 346, 14);
    g.vertex(349, 21);
    g.bezierVertex(330, 31, 270, 31, 251, 21);
    g.endShape(CLOSE);
    // thyrohyoid membrane
    g.fill(#D9E1EA);
    g.strokeWeight(1.8);
    g.quad(266, 26, 334, 26, 337, 40, 263, 40);
    // cricothyroid membrane
    g.rect(284, 84, 32, 14);
    // cricoid cartilage ring
    g.strokeWeight(2.4);
    g.fill(AIR);
    g.beginShape();
    g.vertex(278, 95);
    g.bezierVertex(290, 92, 310, 92, 322, 95);
    g.vertex(323, TR_TOP + 1);
    g.bezierVertex(310, TR_TOP - 2, 290, TR_TOP - 2, 277, TR_TOP + 1);
    g.endShape(CLOSE);
    g.stroke(AIR_SH);
    g.strokeWeight(2);
    g.line(282, 103, 318, 103);
    // thyroid cartilage: shield of two laminae meeting at the laryngeal prominence
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(AIR);
    g.beginShape();
    g.vertex(264, 36);
    g.vertex(291, 35);
    g.vertex(300, 48);          // superior thyroid notch
    g.vertex(309, 35);
    g.vertex(336, 36);
    g.bezierVertex(339, 52, 338, 66, 330, 78);
    g.vertex(327, 92);          // inferior horn
    g.vertex(321, 90);
    g.vertex(320, 84);
    g.bezierVertex(312, 87, 306, 88, 300, 88);
    g.bezierVertex(294, 88, 288, 87, 280, 84);
    g.vertex(279, 90);
    g.vertex(273, 92);          // inferior horn
    g.vertex(270, 78);
    g.bezierVertex(262, 66, 261, 52, 264, 36);
    g.endShape(CLOSE);
    // shade the far lamina, highlight the near one, ridge of the prominence
    g.noStroke();
    g.fill(AIR_SH, 150);
    g.beginShape();
    g.vertex(302, 50);
    g.vertex(310, 39);
    g.vertex(333, 40);
    g.bezierVertex(335, 54, 333, 66, 326, 76);
    g.bezierVertex(316, 83, 308, 85, 302, 85);
    g.endShape(CLOSE);
    g.fill(AIR_LT, 220);
    g.ellipse(276, 56, 8, 22);
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.line(300, 50, 300, 86);
  }

  void alveoliInset(PGraphics g) {
    // zoom leader from a bronchiole tip in the left upper lobe
    float zx = 470, zy = 205;
    g.stroke(#7D6F52, 200);
    g.strokeWeight(1.5);
    dashed(g, new float[] { zx - 8, zy - 6, BUB_X - BUB_R * 0.95, BUB_Y + BUB_R * 0.3 }, 5, 4);
    dashed(g, new float[] { zx + 9, zy - 4, BUB_X + BUB_R * 0.2, BUB_Y + BUB_R * 0.98 }, 5, 4);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.ellipse(zx, zy, 22, 22);
    // bubble
    g.noStroke();
    g.fill(0, 30);
    g.ellipse(BUB_X + 3, BUB_Y + 4, BUB_R * 2, BUB_R * 2);
    g.fill(#FFF8F5);
    g.ellipse(BUB_X, BUB_Y, BUB_R * 2, BUB_R * 2);
    // terminal bronchiole -> alveolar ducts
    g.stroke(D_INK);
    g.strokeWeight(12);
    g.line(BUB_X - 46, BUB_Y + 30, BUB_X - 18, BUB_Y + 10);
    g.strokeWeight(8);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 8, BUB_Y - 14);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X + 14, BUB_Y + 4);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 2, BUB_Y + 30);
    g.stroke(AIR);
    g.strokeWeight(9);
    g.line(BUB_X - 46, BUB_Y + 30, BUB_X - 18, BUB_Y + 10);
    g.strokeWeight(5);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 8, BUB_Y - 14);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X + 14, BUB_Y + 4);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 2, BUB_Y + 30);
    // grape-like alveolar sacs
    sac(g, BUB_X - 6, BUB_Y - 28, 10);
    sac(g, BUB_X + 26, BUB_Y + 2, 10);
    sac(g, BUB_X + 6, BUB_Y + 32, 9.5);
    // capillary net
    g.noFill();
    g.strokeWeight(1.6);
    g.stroke(D_ARTERY, 190);
    g.bezier(BUB_X - 30, BUB_Y - 30, BUB_X - 10, BUB_Y - 50, BUB_X + 20, BUB_Y - 20, BUB_X + 42, BUB_Y - 6);
    g.bezier(BUB_X + 40, BUB_Y + 20, BUB_X + 20, BUB_Y + 30, BUB_X + 20, BUB_Y + 46, BUB_X - 6, BUB_Y + 50);
    g.stroke(D_VEIN, 190);
    g.bezier(BUB_X - 26, BUB_Y - 14, BUB_X - 2, BUB_Y - 4, BUB_X + 10, BUB_Y - 46, BUB_X + 30, BUB_Y - 36);
    g.bezier(BUB_X + 8, BUB_Y + 12, BUB_X + 34, BUB_Y + 18, BUB_X + 46, BUB_Y + 30, BUB_X + 30, BUB_Y + 44);
    // rim
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(3);
    g.ellipse(BUB_X, BUB_Y, BUB_R * 2, BUB_R * 2);
    g.stroke(255, 160);
    g.strokeWeight(2);
    g.arc(BUB_X, BUB_Y, BUB_R * 2 - 9, BUB_R * 2 - 9, PI * 1.05, PI * 1.45);
  }

  // a cluster of alveoli around (cx, cy)
  void sac(PGraphics g, float cx, float cy, float r) {
    float[][] o = { { 0, 0 }, { -1.5, -0.6 }, { -0.3, -1.6 }, { 1.4, -0.9 }, { 1.6, 0.8 }, { 0.2, 1.6 }, { -1.4, 1.0 } };
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    for (int i = o.length - 1; i >= 0; i--) {
      float x = cx + o[i][0] * r, y = cy + o[i][1] * r;
      g.fill(i == 0 ? ALV_SH : ALV);
      g.ellipse(x, y, r * 1.9, r * 1.9);
    }
    g.noStroke();
    g.fill(255, 150);
    for (int i = 1; i < o.length; i++) g.ellipse(cx + o[i][0] * r - r * 0.3, cy + o[i][1] * r - r * 0.3, r * 0.6, r * 0.5);
  }

  // ------------------------------------------------------------ helpers
  void shaded(PGraphics g, float[] p, int base, int sh, int lt, float k, float sw) {
    float[] c = centroid(p);
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, scaled(p, c[0], c[1], k, -3, -4));
    g.fill(lt, 80);
    polygon(g, scaled(p, c[0] - 0.25 * (c[0] - minX(p)), c[1] - 0.3 * (c[1] - minY(p)), 0.5, 0, 0));
    g.fill(lt, 90);
    polygon(g, scaled(p, c[0] - 0.3 * (c[0] - minX(p)), c[1] - 0.38 * (c[1] - minY(p)), 0.28, 0, 0));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  void dashed(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3];
      float d = dist(x0, y0, x1, y1), t = 0;
      while (t < d) {
        float lim = (draw ? on : off) - acc, step = min(lim, d - t);
        if (draw) g.line(x0 + (x1 - x0) * t / d, y0 + (y1 - y0) * t / d, x0 + (x1 - x0) * (t + step) / d, y0 + (y1 - y0) * (t + step) / d);
        t += step;
        acc += step;
        if (acc >= (draw ? on : off) - 0.001) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  float[] cr(float[] c, boolean closed, int seg) {
    int n = c.length / 2, segs = closed ? n : n - 1;
    float[] r = new float[(segs * seg + (closed ? 0 : 1)) * 2];
    int k = 0;
    for (int i = 0; i < segs; i++) {
      int i0 = closed ? (i - 1 + n) % n : max(i - 1, 0), i2 = closed ? (i + 1) % n : i + 1, i3 = closed ? (i + 2) % n : min(i + 2, n - 1);
      for (int s = 0; s < seg; s++) {
        float t = s / (float) seg;
        r[k++] = crv(c[i0 * 2], c[i * 2], c[i2 * 2], c[i3 * 2], t);
        r[k++] = crv(c[i0 * 2 + 1], c[i * 2 + 1], c[i2 * 2 + 1], c[i3 * 2 + 1], t);
      }
    }
    if (!closed) {
      r[k++] = c[(n - 1) * 2];
      r[k++] = c[(n - 1) * 2 + 1];
    }
    return r;
  }

  float crv(float p0, float p1, float p2, float p3, float t) {
    return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
  }

  float len(float[] p) {
    float L = 0;
    for (int i = 0; i + 3 < p.length; i += 2) L += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    return L;
  }

  float[] sub(float[] p, float a, float b) {
    ArrayList<Float> o = new ArrayList<Float>();
    float acc = 0;
    b = min(b, len(p));
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3], d = dist(x0, y0, x1, y1);
      if (d < 1e-4) continue;
      float s0 = acc, s1 = acc + d;
      if (s1 >= a && s0 <= b) {
        float ta = max(0, (a - s0) / d), tb = min(1, (b - s0) / d);
        if (o.size() == 0) {
          o.add(lerp(x0, x1, ta));
          o.add(lerp(y0, y1, ta));
        }
        o.add(lerp(x0, x1, tb));
        o.add(lerp(y0, y1, tb));
      }
      acc = s1;
    }
    float[] r = new float[o.size()];
    for (int i = 0; i < r.length; i++) r[i] = o.get(i);
    return r;
  }

  float[] offset(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  float[] tubePoly(float[] p0, float w) {
    float[] p = clean(p0);
    float[] l = offset(p, w / 2), rr = offset(p, -w / 2);
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      r[i * 2] = l[i * 2];
      r[i * 2 + 1] = l[i * 2 + 1];
      r[(2 * n - 1 - i) * 2] = rr[i * 2];
      r[(2 * n - 1 - i) * 2 + 1] = rr[i * 2 + 1];
    }
    return r;
  }

  // drop points closer than 1 unit to their neighbour (they make wild normals / miter spikes)
  float[] clean(float[] p) {
    FloatList o = new FloatList();
    for (int i = 0; i < p.length; i += 2) {
      int k = o.size();
      boolean last = i == p.length - 2;
      if (k >= 2 && dist(o.get(k - 2), o.get(k - 1), p[i], p[i + 1]) < 1) {
        if (last && k >= 4) {
          o.set(k - 2, p[i]);
          o.set(k - 1, p[i + 1]);
        }
        continue;
      }
      o.append(p[i]);
      o.append(p[i + 1]);
    }
    return o.array();
  }

  float[] centroid(float[] p) {
    float x = 0, y = 0;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      x += p[i * 2];
      y += p[i * 2 + 1];
    }
    return new float[] { x / n, y / n };
  }

  float minX(float[] p) {
    float m = 1e9;
    for (int i = 0; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float minY(float[] p) {
    float m = 1e9;
    for (int i = 1; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float[] scaled(float[] p, float cx, float cy, float k, float dx, float dy) {
    float[] r = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      r[i] = cx + (p[i] - cx) * k + dx;
      r[i + 1] = cy + (p[i + 1] - cy) * k + dy;
    }
    return r;
  }

  void polygon(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void polyline(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }
}


// ======================================================================
// TAB: Dia_Muscles.pde
// ======================================================================
// Superficial muscles, anterior view (subject's right on the viewer's left).
// Labelled muscles are saturated reds with fibre lines; unlabelled neighbours
// (brachioradialis, serratus, TFL, soleus ...) are a muted tone so the testable
// ones stand out. Each muscle's outline is both its art and its hit polygon.
//
// Proportions: shapes are authored in a compact "sketch" space and mapped into
// the final figure (about 7.5 heads tall, legs half the height) before they are
// used for BOTH art and hit polygons:
//  - T() / tp(): head, trunk and legs - a vertical remap (KY -> KYN) plus a
//    per-height narrowing about the midline (KX / KXS) and a small leg spread;
//  - the arm chain is rigid: the sketch frames S_* are moved by one similarity
//    (ARM_*) into the final frames F_*, which P() uses directly;
//  - around the shoulder T() blends toward that same arm motion, so the deltoid,
//    acromion and pec insertion travel with the arm.

class MusclesDiagram extends Diagram {
  final int BASE = #8C3A36, BASE_SH = #7A302D;           // deep layer seen in the grooves
  final int FILL = #D4A196, FILL_FIB = #B5837A;          // unlabelled muscles
  final int FIB = #9C3B35, FIB_LT = #EE9A8E;             // fibre lines / sheen

  // limb frames { local axis length, x0, y0, x1, y1 [, width factor at x0, at x1] } for the viewer's-left arm, in sketch space ...
  final float[] S_UA = { 100, 212, 138, 193, 240 };
  final float[] S_FA = { 82, 193, 240, 171, 322, 0.88, 1 };   // forearm slimmed below the elbow
  final float[] S_HD = { 58, 171, 323, 156, 378 };
  float[] F_UA, F_FA, F_HD;                               // ... and in the final figure (set in build)

  // ---- sketch -> final mapping (see the header)
  final float[] KY = { 12, 81, 120, 166, 207, 293, 341, 358, 443, 455, 545 };       // sketch y ...
  final float[] KYN = { 18, 93, 122, 158, 190, 252, 302, 317, 409, 421, 561 };      // ... final y
  final float FOOT_K = 0.65;                                                         // feet: uniform scale below the ankle
  final float[] KX = { 60, 74, 84, 95, 106, 120, 166, 202, 250, 290, 330, 360, 390, 415, 436, 452, 470, 490, 512, 532, 545 };
  final float[] KXS = { 1.1, 1.04, 1.06, 0.98, 0.85, 0.76, 0.7, 0.68, 0.68, 0.7, 0.68, 0.69, 0.685, 0.68, 0.68, 0.68, 0.66, 0.62, 0.58, 0.56, 0.65 };
  final float[] KS = { 358, 443, 545 }, KSV = { 0, 3.5, 6 };                           // legs drift apart a little
  final float ARM_SX = 212, ARM_SY = 138, ARM_TX = 235, ARM_TY = 137;                // shoulder: sketch -> final
  final float ARM_ROT = radians(-4), ARM_K = 0.96;                                   // arm closer to the body, a bit smaller

  float[] head, earL, body, handL, footL, clavL;
  float[] trapL, scmL, deltL, pecL, bicL, flexL, rectus, eoL, eoFleshL, quadL, sartC, sartL, addL, taL, gmedL, glatL;
  ArrayList<float[]> fillers = new ArrayList<float[]>();     // unlabelled muscles (viewer's left)
  ArrayList<float[]> tendons = new ArrayList<float[]>();     // tendons / aponeuroses (viewer's left)
  ArrayList<float[]> bones = new ArrayList<float[]>();       // subcutaneous bone (viewer's left)

  MusclesDiagram() {
    super("muscles", "Major Muscles (front)");
    build();
    at(add("rectus_abdominis", "Rectus Abdominis").poly(rectus), 300, 245);
    at(add("external_oblique", "External Oblique").poly(eoL).poly(mir(eoL)), 246, 245);
    at(add("pectoralis_major", "Pectoralis Major").poly(pecL).poly(mir(pecL)), 265, 165);
    at(add("trapezius", "Trapezius").poly(trapL).poly(mir(trapL)), 248, 110);
    at(add("sternocleidomastoid", "Sternocleidomastoid").poly(scmL).poly(mir(scmL)), 287, 100);
    at(add("deltoid", "Deltoid").poly(deltL).poly(mir(deltL)), 212, 150);
    float[] ba = mir(P(new float[] { 0, 58 }, F_UA)), fa = mir(P(new float[] { 4, 36 }, F_FA));   // final space already
    add("biceps_brachii", "Biceps Brachii").poly(bicL).poly(mir(bicL)).anchor(ba[0], ba[1]);
    add("forearm_flexors", "Forearm Flexors").poly(flexL).poly(mir(flexL)).anchor(fa[0], fa[1]);
    at(add("adductors", "Adductors").poly(addL).poly(mir(addL)), 286, 368);
    at(add("quadriceps_femoris", "Quadriceps Femoris").poly(quadL).poly(mir(quadL)), 246, 385);
    at(add("sartorius", "Sartorius").poly(sartL).poly(mir(sartL)), 262, 360);
    at(add("tibialis_anterior", "Tibialis Anterior").poly(taL).poly(mir(taL)), 264, 490);
    at(add("gastrocnemius", "Gastrocnemius").poly(gmedL).poly(glatL).poly(mir(gmedL)).poly(mir(glatL)), 292, 488);
  }

  // label anchor given in sketch space
  Part at(Part p, float x, float y) {
    float[] q = tp(x, y);
    return p.anchor(q[0], q[1]);
  }

  // =============================================================== geometry (viewer's left; mirrored for the right)
  // Numbers are sketch-space: trunk/leg/head arrays go through T(), arm parts through P() with the final frames.
  void build() {
    F_UA = armFrame(S_UA);
    F_FA = armFrame(S_FA);
    F_HD = armFrame(S_HD);
    head = sym(T(new float[] { 300, 12, 285, 15, 276, 25, 273, 40, 275, 55, 279, 66, 287, 76, 300, 81 }));
    earL = T(new float[] { 275, 42, 270, 40, 268, 47, 270, 55, 275, 57 });

    // ---- body outline: neck + shoulder, arm (local frames), trunk, leg, foot
    FloatList b = new FloatList();
    addPts(b, T(new float[] { 300, 74, 284, 74, 284, 84, 272, 92, 254, 99, 236, 106, 221, 113, 211, 121, 204, 128 }));
    addPts(b, P(new float[] { -16, 4, -17, 19, -16, 36, -15, 55, -14, 75, -15, 92 }, F_UA));
    addPts(b, P(new float[] { -16, 0, -18, 12, -17, 26, -14, 45, -11, 62, -9, 80 }, F_FA));
    addPts(b, P(new float[] { 8, 80, 10, 62, 13, 42, 16, 22, 16, 6 }, F_FA));
    addPts(b, P(new float[] { 15, 92, 14, 75, 15, 55, 17, 36, 17, 26 }, F_UA));
    // torso, leg, foot
    addPts(b, T(new float[] { 229, 166, 227, 182, 228, 202, 231, 226, 235, 250, 236, 270, 233, 290, 226, 308,
      220, 330, 219, 360, 224, 390, 233, 415, 241, 436, 243, 452, 240, 470, 237, 490, 240, 512, 249, 532 }));
    addPts(b, T(reversePts(footOutline())));
    addPts(b, T(new float[] { 289, 530, 295, 510, 297, 488, 293, 466, 290, 452, 291, 430, 294, 405, 297, 380, 298, 366, 300, 358 }));
    body = symClosed(b.array());
    handL = P(new float[] { -9, -2, -13, 8, -18, 16, -24, 26, -26, 31, -22, 32, -14, 26, -12, 36, -12, 50, -11, 58, -7, 60, -4, 52,
      -2, 62, 2, 63, 4, 54, 6, 61, 10, 60, 10, 50, 13, 52, 15, 48, 13, 36, 11, 20, 9, -2 }, F_HD);
    FloatList fl = new FloatList();
    addPts(fl, T(footOutline()));
    addPts(fl, T(new float[] { 257, 544.6, 270, 544.2, 282, 544.6 }));     // across the front of the ankle
    footL = fl.array();

    clavL = cr(T(new float[] { 297, 122, 281, 123, 263, 121, 245, 119, 228, 120, 214, 124 }), 4);

    // ---- labelled muscles
    trapL = T(new float[] { 284, 84, 272, 92, 254, 99, 236, 106, 221, 113, 211, 122, 222, 123, 238, 121, 255, 120, 264, 111, 274, 102, 283, 94 });
    scmL = T(new float[] { 275, 70, 282, 67, 288, 82, 294, 100, 299, 114, 298, 122, 291, 122, 289, 113, 284, 122, 276, 122, 278, 110, 279, 95, 276, 82 });
    deltL = T(new float[] { 246, 124, 230, 121, 215, 123, 203.5, 129, 195.5, 140, 191.8, 155, 190.5, 172, 194.5, 186.5, 207, 197, 212, 186, 219, 170, 227, 152, 236, 136 });
    pecL = T(new float[] { 297, 126, 297, 150, 297, 176, 296, 199, 286, 207, 270, 209, 254, 203, 240, 192, 228, 180, 220, 172, 215, 168,
      222, 160, 229, 148, 238, 134, 247, 126, 262, 125, 280, 126 });
    bicL = P(new float[] { -6, 30, 5, 28, 10, 38, 12, 52, 11, 66, 7, 80, 3, 90, 2, 98, -2, 98, -3, 90, -7, 80, -11, 66, -12, 52, -10, 38 }, F_UA);
    flexL = P(new float[] { 16, -3, 17, 12, 14, 32, 10, 52, 7, 68, 6, 80, -1, 81, -5, 72, -7, 55, -9, 40, -6, 31, -1, 19, 4, 9, 9, 1 }, F_FA);
    rectus = sym(T(new float[] { 300, 196, 289, 194, 277, 195, 266, 200, 266, 230, 268, 260, 272, 290, 279, 318, 289, 337, 300, 341 }));
    eoL = T(new float[] { 256, 201, 244, 196, 233, 200, 231, 225, 234, 250, 236, 270, 233, 290, 228, 304, 243, 316, 262, 326, 284, 338,
      293, 340, 288, 330, 279, 318, 272, 290, 268, 260, 266, 230, 265, 206 });
    eoFleshL = T(new float[] { 257, 202, 244, 196, 233, 200, 231, 225, 234, 250, 236, 270, 233, 290, 229, 302, 241, 297, 253, 292, 259, 285, 259, 262, 259, 236, 260, 212 });
    quadL = T(new float[] { 227, 328, 236, 318, 247, 322, 254, 336, 262, 352, 272, 368, 282, 384, 289, 398, 292, 418, 289, 436, 281, 441,
      270, 431, 260, 433, 251, 437, 243, 428, 233, 408, 225, 385, 222, 360, 222, 342 });
    sartC = cr(T(new float[] { 230, 306, 241, 328, 256, 350, 271, 370, 283, 390, 290, 412, 292, 436, 289, 458 }), 4);
    sartL = band(sartC, 9, 8);
    addL = T(new float[] { 289, 338, 296, 352, 298, 366, 296, 384, 293, 402, 285, 390, 277, 374, 269, 362, 263, 352, 271, 346, 280, 341 });
    taL = T(new float[] { 256, 460, 267, 458, 274, 468, 276, 490, 274, 512, 278, 530, 285, 545, 279, 549, 271, 534, 264, 516, 257, 496, 253, 476 });
    gmedL = T(new float[] { 288, 456, 294, 464, 298, 478, 299, 494, 296, 508, 290, 516, 286, 506, 285, 488, 284, 470 });
    glatL = T(new float[] { 246, 458, 252, 462, 253, 478, 251, 496, 247, 506, 241, 500, 238, 488, 239, 472 });

    // ---- unlabelled muscles (muted)
    fillers.add(T(new float[] { 283, 95, 280, 100, 279, 110, 277, 121, 266, 121, 257, 120, 265, 112, 274, 103 }));      // scalenes (posterior triangle)
    fillers.add(T(new float[] { 300, 84, 292, 84, 296, 100, 299, 114, 300, 114 }));                                    // infrahyoid strap
    fillers.add(P(new float[] { -15, 8, -9, 10, -12, 30, -15, 50, -14.5, 62, -11, 66 }, F_UA));                       // triceps lateral head
    fillers.add(P(new float[] { 12, 30, 17, 28, 17, 45, 15, 62, 14, 80, 11, 76, 12, 62 }, F_UA));                   // triceps medial
    fillers.add(P(new float[] { -13, 62, -8, 70, -6, 86, -10, 98, -15, 94, -15, 78 }, F_UA));                        // brachialis lateral
    fillers.add(P(new float[] { 9, 70, 14, 66, 15, 84, 13, 98, 7, 94 }, F_UA));                                      // brachialis medial
    fillers.add(P(new float[] { -16, -4, -10, -2, -5, 12, -4, 26, -8, 40, -8, 56, -5, 72, -8, 80, -11, 70, -14, 46, -18, 22 }, F_FA)); // brachioradialis + extensors
    fillers.add(T(new float[] { 228, 182, 238, 191, 246, 196, 240, 200, 232, 204, 229, 200 }));                         // serratus anterior
    fillers.add(T(new float[] { 227, 178, 232, 186, 230, 205, 230, 225, 228, 205 }));                                   // latissimus edge
    fillers.add(T(new float[] { 226, 309, 235, 314, 240, 323, 236, 334, 228, 342, 222, 340, 221, 326 }));               // tensor fasciae latae
    fillers.add(T(new float[] { 244, 318, 262, 327, 284, 338, 276, 344, 266, 351, 259, 343, 250, 330 }));               // iliopsoas + pectineus
    fillers.add(T(new float[] { 243, 462, 252, 462, 256, 476, 260, 500, 266, 522, 271, 537, 268, 545, 261, 541, 252, 524, 246, 500, 242, 480 })); // extensor digitorum / fibularis
    fillers.add(T(new float[] { 286, 498, 291, 512, 296, 508, 293, 526, 289, 538, 285, 528 }));                         // soleus medial
    fillers.add(T(new float[] { 242, 497, 247, 506, 250, 520, 253, 536, 250, 541, 245, 530, 240, 512 }));                // soleus lateral

    // ---- tendons / aponeuroses
    tendons.add(T(new float[] { 266, 204, 260, 212, 259, 236, 259, 262, 259, 286, 252, 293, 240, 298, 229, 303, 243, 316, 262, 326, 284, 338,
      279, 318, 272, 290, 268, 260, 266, 230 }));                                                                       // external oblique aponeurosis
    tendons.add(T(new float[] { 249, 439, 258, 434, 270, 432, 281, 440, 287, 450, 284, 461, 276, 467, 262, 467, 252, 460, 247, 450 })); // knee retinacula
    tendons.add(T(new float[] { 263, 452, 274, 452, 273, 469, 265, 469 }));                                             // patellar ligament
    tendons.add(P(new float[] { -3, 90, 3, 90, 6, 100, 12, 104, 12, 108, 1, 104, -3, 100 }, F_UA));                  // biceps tendon + aponeurosis
    bones.add(T(new float[] { 276, 471, 282, 470, 286, 498, 287, 522, 290, 536, 289, 544, 283, 543, 281, 530, 279, 518, 277, 498 })); // tibia (subcutaneous) + medial malleolus
    bones.add(T(ellPts(268, 443, 10, 7.6)));                                                                          // patella
  }

  void drawArt(PGraphics g) {
    drawFigure(g);
  }

  // =============================================================== art
  void drawFigure(PGraphics g) {
    // body base (deep layer)
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(BASE);
    blob(g, body);
    // hands, feet, head in skin
    for (int s = 0; s < 2; s++) {
      skin(g, side(handL, s));
      skin(g, side(footL, s));
      g.stroke(D_SKIN_SH);
      g.strokeWeight(1.1);
      for (int k = 0; k < 4; k++) {                                                          // toe clefts
        float cx = (TOE[k][0] + TOE[k][2] + TOE[k + 1][0] - TOE[k + 1][2]) / 2, cy = (TOE[k][1] + TOE[k + 1][1]) / 2;
        tline(g, s == 0 ? cx : DIA - cx, cy - 3.4, s == 0 ? cx : DIA - cx, cy - 0.4);
      }
    }

    for (int s = 0; s < 2; s++) {
      for (float[] f : fillers) muscle(g, side(f, s), FILL, 1.6);
      for (float[] t : tendons) flat(g, side(t, s), D_TENDON, 1.4);
      for (float[] t : bones) flat(g, side(t, s), D_BONE, 1.6);
    }
    // ---- labelled muscles, back to front
    muscle(g, rectus, #C9544B, 2);
    flat(g, T(new float[] { 298.5, 198, 301.5, 198, 302, 338, 298, 338 }), D_TENDON, 1);     // linea alba
    g.stroke(D_TENDON);
    g.strokeWeight(3);
    for (int k = 0; k < 3; k++) {                                                           // tendinous intersections
      float y = 224 + k * 28;
      tline(g, 268 + k * 0.8, y, 298, y + 2);
      tline(g, DIA - 268 - k * 0.8, y, 302, y + 2);
    }
    g.stroke(D_INK);
    g.strokeWeight(1.1);
    for (int k = 0; k < 3; k++) {
      float y = 224 + k * 28;
      tline(g, 268 + k * 0.8, y - 1.5, 298, y + 0.5);
      tline(g, 268 + k * 0.8, y + 1.5, 298, y + 3.5);
      tline(g, DIA - 268 - k * 0.8, y - 1.5, 302, y + 0.5);
      tline(g, DIA - 268 - k * 0.8, y + 1.5, 302, y + 3.5);
    }
    g.stroke(FIB, 150);
    g.strokeWeight(0.9);
    float[] fb = { 296, 316, 328, 335 };
    for (int k = 0; k < 4; k++) {
      float x = 274 + k * 6;
      tline(g, x, 210, x + 0.3, fb[k]);
      tline(g, DIA - x, 210, DIA - x - 0.3, fb[k]);
    }
    g.fill(BASE_SH);
    g.stroke(D_INK);
    g.strokeWeight(1.2);
    float[] nv = tp(300, 293);
    g.ellipse(nv[0], nv[1], 4.5, 6.5);                                                     // navel
    for (int s = 0; s < 2; s++) {
      muscle(g, side(eoFleshL, s), #BA4C47, 1.8);
      fibres(g, side(T(new float[] { 246, 198, 232, 212, 233, 262 }), s), side(T(new float[] { 259, 215, 258, 262, 238, 297 }), s), 9);
      muscle(g, side(trapL, s), #BE4E4A, 1.8);
      fibres(g, side(T(new float[] { 283, 87, 282, 92 }), s), side(T(new float[] { 216, 121, 252, 120 }), s), 7);
      muscle(g, side(scmL, s), #D0605A, 1.8);
      fibres(g, side(T(new float[] { 277, 72, 282, 70 }), s), side(T(new float[] { 279, 120, 296, 120 }), s), 4);
      muscle(g, side(pecL, s), #C14A45, 2);
      fibres(g, side(T(new float[] { 250, 127, 296, 128, 296, 196, 284, 205, 262, 205 }), s), side(T(new float[] { 225, 158, 220, 168 }), s), 13);
      muscle(g, side(deltL, s), #C9544B, 2);
      fibres(g, side(T(new float[] { 243, 125, 228, 123, 214, 125, 203, 132, 196, 146 }), s), side(T(new float[] { 207, 193, 207, 194 }), s), 9);
      muscle(g, side(bicL, s), #CF5A4E, 1.8);
      fibres(g, side(P(new float[] { -7, 36, 8, 34 }, F_UA), s), side(P(new float[] { -2, 90, 2, 90 }, F_UA), s), 5);
      muscle(g, side(flexL, s), #C65A50, 1.8);
      fibres(g, side(P(new float[] { 15, 4, 8, 4, 0, 16 }, F_FA), s), side(P(new float[] { 6, 78, 1, 78, -4, 70 }, F_FA), s), 6);
      flat(g, side(P(new float[] { -1, 64, 1, 64, 2, 81, -1, 81 }, F_FA), s), D_TENDON, 1);
      flat(g, side(P(new float[] { 3, 62, 5, 62, 5.5, 80, 3, 80 }, F_FA), s), D_TENDON, 1);
      muscle(g, side(addL, s), #B8463F, 1.8);
      fibres(g, side(T(new float[] { 282, 341, 294, 350 }), s), side(T(new float[] { 271, 364, 292, 398 }), s), 5);
      muscle(g, side(quadL, s), #C9544B, 2);
      g.stroke(D_INK);
      g.strokeWeight(1.3);
      g.noFill();
      line(g, side(T(new float[] { 246, 325, 252, 360, 258, 400, 262, 430 }), s));                // rectus femoris | vastus lateralis
      line(g, side(T(new float[] { 276, 380, 278, 400, 276, 420, 273, 432 }), s));                // vastus medialis
      fibres(g, side(T(new float[] { 238, 322, 246, 324 }), s), side(T(new float[] { 262, 430, 266, 430 }), s), 3);
      fibres(g, side(T(new float[] { 225, 345, 235, 330 }), s), side(T(new float[] { 247, 434, 258, 430 }), s), 4);
      fibres(g, side(T(new float[] { 280, 386, 289, 402 }), s), side(T(new float[] { 272, 430, 282, 438 }), s), 3);
      muscle(g, side(sartL, s), #D86A5C, 1.8);
      strapFibres(g, side(sartC, s), 3);
      muscle(g, side(gmedL, s), #B9473F, 1.6);
      muscle(g, side(glatL, s), #B9473F, 1.6);
      fibres(g, side(T(new float[] { 287, 460, 292, 460 }), s), side(T(new float[] { 288, 508, 292, 510 }), s), 3);
      muscle(g, side(taL, s), #CC5A4D, 1.8);
      fibres(g, side(T(new float[] { 257, 464, 268, 462 }), s), side(T(new float[] { 266, 510, 273, 510 }), s), 4);
      flat(g, side(T(new float[] { 272, 512, 275, 512, 285, 546, 282, 548 }), s), D_TENDON, 1);
      // clavicle on top
      flat(g, side(band(clavL, 6, 5), s), D_BONE, 1.6);
    }
    // head last: the SCM's upper end tucks behind the angle of the jaw
    skin(g, earL);
    skin(g, mir(earL));
    skin(g, head);
    g.noFill();
    g.stroke(D_SKIN_SH);
    g.strokeWeight(1.4);
    tbezier(g, 289, 50, 292, 48, 295, 48, 297, 50);   // closed eyes - he's asleep in Rick's class
    tbezier(g, 303, 50, 305, 48, 308, 48, 311, 50);
    tbezier(g, 300, 54, 298, 60, 297, 62, 301, 63);
    tbezier(g, 294, 70, 298, 72, 302, 72, 306, 70);
  }

  // toes of the viewer's-left foot seen from the front (big toe medial): { cx, cy, r }, little toe first
  final float[][] TOE = { { 254.9, 567.4, 3.4 }, { 261.9, 569.6, 3.7 }, { 269.4, 571.0, 4.0 }, { 277.4, 571.5, 4.3 }, { 288.2, 569.5, 6.4 } };

  // front view of a foot (wider than tall): medial ankle -> medial border -> round toe tips -> lateral border -> lateral ankle
  float[] footOutline() {
    FloatList q = new FloatList();
    addPts(q, new float[] { 289, 545, 291.5, 551, 294, 557.5, 295.5, 564 });
    for (int k = TOE.length - 1; k >= 0; k--) {
      for (int i = 0; i <= 4; i++) {
        float a = PI * i / 4;                         // 0 -> PI: medial side of the toe, round its tip, to the lateral side
        q.append(TOE[k][0] + cos(a) * TOE[k][2]);
        q.append(TOE[k][1] + sin(a) * TOE[k][2] * 0.62);
      }
    }
    addPts(q, new float[] { 249.5, 563, 247.5, 557, 248.5, 550.5, 250.5, 545 });
    return q.array();
  }

  // =============================================================== sketch -> final mapping
  // piecewise-linear lookup (clamped)
  float knot(float[] k, float[] v, float y) {
    if (y <= k[0]) return v[0];
    for (int i = 1; i < k.length; i++) if (y <= k[i]) return lerp(v[i - 1], v[i], (y - k[i - 1]) / (k[i] - k[i - 1]));
    return v[v.length - 1];
  }

  // the arm's rigid motion (similarity) applied to a sketch point
  float[] armPt(float x, float y) {
    float dx = (x - ARM_SX) * ARM_K, dy = (y - ARM_SY) * ARM_K, c = cos(ARM_ROT), s = sin(ARM_ROT);
    return new float[] { ARM_TX + dx * c - dy * s, ARM_TY + dx * s + dy * c };
  }

  float[] armFrame(float[] f) {
    float[] a = armPt(f[1], f[2]), b = armPt(f[3], f[4]);
    float[] q = f.clone();
    q[1] = a[0];
    q[2] = a[1];
    q[3] = b[0];
    q[4] = b[1];
    return q;
  }

  // how much a trunk point near the shoulder follows the arm (0 trunk .. 1 arm): lateral to the deltopectoral line
  float armWeight(float x, float y) {
    float ax = 246, ay = 112, ux = -0.36, uy = 0.933;                 // line along the deltopectoral groove
    float sd = -(x - ax) * uy + (y - ay) * ux;                         // + = lateral of it
    float w = smoothstep(-26, 12, sd) * smoothstep(80, 100, y) * (1 - smoothstep(168, 192, y));   // shoulder band only
    return max(w, smoothstep(74, 84, 300 - x));                      // anything far lateral is arm
  }

  float smoothstep(float a, float b, float v) {
    float t = constrain((v - a) / (b - a), 0, 1);
    return t * t * (3 - 2 * t);
  }

  // one sketch point -> final figure (symmetric about the midline)
  float[] tp(float x, float y) {
    boolean r = x > 300;
    if (r) x = DIA - x;
    float d = 300 - x;
    float ny = y <= KY[KY.length - 1] ? knot(KY, KYN, y) : KYN[KYN.length - 1] + (y - KY[KY.length - 1]) * FOOT_K;
    float nx = 300 - (d * knot(KX, KXS, y) + knot(KS, KSV, y));
    float w = armWeight(x, y);
    if (w > 0) {
      float[] a = armPt(x, y);
      nx = lerp(nx, a[0], w);
      ny = lerp(ny, a[1], w);
    }
    return new float[] { r ? DIA - nx : nx, ny };
  }

  float[] T(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      float[] a = tp(p[i], p[i + 1]);
      q[i] = a[0];
      q[i + 1] = a[1];
    }
    return q;
  }

  // a sketch-space straight line, drawn through the mapping
  void tline(PGraphics g, float x0, float y0, float x1, float y1) {
    float[] q = new float[10];
    for (int i = 0; i < 5; i++) {
      q[i * 2] = lerp(x0, x1, i / 4.0);
      q[i * 2 + 1] = lerp(y0, y1, i / 4.0);
    }
    g.noFill();
    line(g, T(q));
  }

  void tbezier(PGraphics g, float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3) {
    float[] q = T(new float[] { x0, y0, x1, y1, x2, y2, x3, y3 });
    g.bezier(q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7]);
  }

  // =============================================================== drawing helpers
  void muscle(PGraphics g, float[] p, int c, float sw) {
    g.noStroke();
    g.fill(lerpColor(c, #000000, 0.18));
    blob(g, p);
    g.fill(c);
    blob(g, inner(p, 2.2));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }

  void flat(PGraphics g, float[] p, int c, float sw) {
    g.fill(c);
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }

  void skin(PGraphics g, float[] p) {
    g.noStroke();
    g.fill(D_SKIN_SH);
    blob(g, p);
    g.fill(D_SKIN);
    blob(g, inner(p, 2.5));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2);
    blob(g, p);
  }

  // fibre lines between two edges (origin polyline a, insertion polyline b)
  void fibres(PGraphics g, float[] a, float[] b, int n) {
    g.strokeWeight(0.9);
    for (int i = 1; i < n; i++) {
      float t = i / (float) n;
      float[] pa = along(a, t), pb = along(b, t);
      float x0 = lerp(pa[0], pb[0], 0.07), y0 = lerp(pa[1], pb[1], 0.07), x1 = lerp(pa[0], pb[0], 0.93), y1 = lerp(pa[1], pb[1], 0.93);
      g.stroke(FIB, 140);
      g.line(x0, y0, x1, y1);
      if (i % 2 == 1) {
        g.stroke(FIB_LT, 110);
        g.line(lerp(x0, x1, 0.2), lerp(y0, y1, 0.2), lerp(x0, x1, 0.55), lerp(y0, y1, 0.55));
      }
    }
  }

  void strapFibres(PGraphics g, float[] c, int n) {
    g.noFill();
    g.strokeWeight(0.9);
    g.stroke(FIB, 140);
    for (int k = 0; k < n; k++) {
      float off = (k - (n - 1) / 2.0) * 2.4;
      float[] q = new float[c.length - 8];
      for (int i = 2; i < c.length / 2 - 2; i++) {
        int a = max(0, i - 1), bb = min(c.length / 2 - 1, i + 1);
        float tx = c[bb * 2] - c[a * 2], ty = c[bb * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        q[(i - 2) * 2] = c[i * 2] - ty / L * off;
        q[(i - 2) * 2 + 1] = c[i * 2 + 1] + tx / L * off;
      }
      line(g, q);
    }
  }

  // point at fraction t along a polyline (by length)
  float[] along(float[] p, float t) {
    int n = p.length / 2;
    float total = 0;
    for (int i = 1; i < n; i++) total += dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
    float want = t * total;
    for (int i = 1; i < n; i++) {
      float d = dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
      if (want <= d || i == n - 1) {
        float u = d < 1e-4 ? 0 : constrain(want / d, 0, 1);
        return new float[] { lerp(p[i * 2 - 2], p[i * 2], u), lerp(p[i * 2 - 1], p[i * 2 + 1], u) };
      }
      want -= d;
    }
    return new float[] { p[0], p[1] };
  }

  // =============================================================== geometry helpers (local to this class)
  float[] reversePts(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = p[p.length - 2 - i];
      q[i + 1] = p[p.length - 1 - i];
    }
    return q;
  }

  void addPts(FloatList l, float[] p) {
    for (float v : p) l.append(v);
  }

  float[] mir(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = DIA - p[i];
      q[i + 1] = p[i + 1];
    }
    return q;
  }

  float[] side(float[] p, int s) {
    return s == 0 ? p : mir(p);
  }

  // half outline from the midline down the viewer's left back to the midline -> full outline
  float[] sym(float[] half) {
    int n = half.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    for (int i = n - 2; i >= 1; i--) {
      q.append(DIA - half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    return q.array();
  }

  // like sym() but keeps both midline end points
  float[] symClosed(float[] half) {
    int n = half.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    for (int i = n - 1; i >= 0; i--) {
      q.append(DIA - half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    return q.array();
  }

  float[] ellPts(float cx, float cy, float rx, float ry) {
    float[] p = new float[32];
    for (int i = 0; i < 16; i++) {
      p[i * 2] = cx + cos(TWO_PI * i / 16) * rx;
      p[i * 2 + 1] = cy + sin(TWO_PI * i / 16) * ry;
    }
    return p;
  }

  float[] P(float[] loc, float[] f) {
    float dx = f[3] - f[1], dy = f[4] - f[2], len = sqrt(dx * dx + dy * dy), s = len / f[0];
    float ux = dx / len, uy = dy / len, px = uy, py = -ux;
    float[] q = new float[loc.length];
    for (int i = 0; i < loc.length; i += 2) {
      float lx = loc[i] * (f.length > 6 ? lerp(f[5], f[6], constrain(loc[i + 1] / f[0], 0, 1)) : 1);
      q[i] = f[1] + (loc[i + 1] * ux + lx * px) * s;
      q[i + 1] = f[2] + (loc[i + 1] * uy + lx * py) * s;
    }
    return q;
  }

  float[] cr(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] lx = new float[n], ly = new float[n], rx = new float[n], ry = new float[n];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) (n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      lx[i] = c[i * 2] + nx;
      ly[i] = c[i * 2 + 1] + ny;
      rx[i] = c[i * 2] - nx;
      ry[i] = c[i * 2 + 1] - ny;
    }
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(lx[i]);
      q.append(ly[i]);
    }
    float ex = c[(n - 1) * 2] - c[(n - 2) * 2], ey = c[(n - 1) * 2 + 1] - c[(n - 2) * 2 + 1], eL = max(1e-3, sqrt(ex * ex + ey * ey));
    q.append(c[(n - 1) * 2] + ex / eL * w1 * 0.4);
    q.append(c[(n - 1) * 2 + 1] + ey / eL * w1 * 0.4);
    for (int i = n - 1; i >= 0; i--) {
      q.append(rx[i]);
      q.append(ry[i]);
    }
    float sx = c[0] - c[2], sy = c[1] - c[3], sL = max(1e-3, sqrt(sx * sx + sy * sy));
    q.append(c[0] + sx / sL * w0 * 0.4);
    q.append(c[1] + sy / sL * w0 * 0.4);
    return q.array();
  }

  void blob(PGraphics g, float[] p) {
    int n = p.length / 2;
    g.beginShape();
    for (int i = 0; i <= n + 2; i++) {
      int k = (i + n - 1) % n;
      g.curveVertex(p[k * 2], p[k * 2 + 1]);
    }
    g.endShape(CLOSE);
  }

  void line(PGraphics g, float[] p) {
    g.beginShape();
    g.curveVertex(p[0], p[1]);
    for (int i = 0; i < p.length; i += 2) g.curveVertex(p[i], p[i + 1]);
    g.curveVertex(p[p.length - 2], p[p.length - 1]);
    g.endShape();
  }

  float[] inner(float[] p, float d) {
    int n = p.length / 2;
    float area = 0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += p[i * 2] * p[j * 2 + 1] - p[j * 2] * p[i * 2 + 1];
    }
    float sg = area > 0 ? 1 : -1;
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float nx = ty / L * sg, ny = -tx / L * sg;
      float k = d * (0.25 + 0.75 * max(0, nx * 0.55 + ny * 0.83));
      q[i * 2] = p[i * 2] - nx * k;
      q[i * 2 + 1] = p[i * 2 + 1] - ny * k;
    }
    return q;
  }
}


// ======================================================================
// TAB: Dia_Nephron.pde
// ======================================================================
// Nephron: classic schematic. Afferent arteriole -> glomerulus inside Bowman's capsule
// -> efferent arteriole. Filtrate: proximal convoluted tubule -> descending limb ->
// (hairpin in the medulla) -> ascending limb -> macula densa where the tubule touches
// its own glomerulus' vascular pole -> distal convoluted tubule -> collecting duct.
// Cortex = upper band, medulla = lower band.

class NephronDiagram extends Diagram {
  final int CORTEX = #F5E4CB, MEDULLA = #F0D5CF;
  final int CAPS = #E7C886, CAPS_SH = #C9A35A, URINE = #FFF5D6;
  final int PCT = #EBC271, DESC = #F4DDA4, ASC = #E2AE5C, DCT = #F0C894, MD = #D99A44;
  final int LUMEN = #FFF8E6;
  final int CD = #7FC6B6, CD_SH = #569F8E, CD_LT = #B9E4D9;
  final int ART_SH = #A72A2E, ART_LT = #F08A86;

  final float GX = 205, GY = 196;               // renal corpuscle centre
  final float R_CAPS = 64, R_SPACE = 55, R_GLOM = 42;
  final float[] RAD_C = { 16, 350, 40, 348, 54, 330, 56, 200, 56, 16 };    // arcuate -> cortical radiate artery
  final float[] AFF_C = { 60, 92, 110, 92, 168, 104, 212, 124, 238, 146 };
  final float[] EFF_C = { 256, 158, 282, 170, 306, 184 };
  final float[] VR_C = { 306, 184, 318, 240, 322, 330, 323, 460, 326, 540, 344, 566, 372, 572, 398, 562, 412, 530, 413, 420, 414, 300, 420, 214, 432, 188 };
  final float[] PCT_C = { 168, 226, 152, 246, 146, 268, 156, 294, 190, 302, 214, 278, 244, 290, 256, 316, 290, 316, 306, 292, 334, 294, 346, 318, 348, 348 };
  final float[] DESC_C = { 348, 342, 348, 440, 349, 506, 354, 532, 368, 546, 382, 536 };
  final float[] DIST_C = { 382, 536, 385, 470, 388, 380, 390, 280, 390, 210, 384, 168, 360, 144, 322, 134, 290, 137, 268, 141, 254, 131, 258, 113, 280, 105, 314, 104, 340, 92, 356, 66, 382, 48, 410, 56, 420, 86, 444, 104, 470, 94, 478, 66, 496, 46, 526, 54 };
  final float[] CD_C = { 540, 16, 540, 200, 538, 400, 534, 586 };

  float[] rad, aff, eff, vr, pct, desc, dist, cdp, tub;
  float sPctEnd, sDescEnd;
  float sAscEnd, sMdEnd, sDescTurn, sThick;

  NephronDiagram() {
    super("nephron", "Nephron");
    rad = cr(RAD_C, false, 10);
    aff = cr(AFF_C, false, 10);
    eff = cr(EFF_C, false, 10);
    vr = cr(VR_C, false, 10);
    pct = cr(PCT_C, false, 10);
    desc = cr(DESC_C, false, 10);
    dist = cr(DIST_C, false, 10);
    cdp = cr(CD_C, false, 10);
    sAscEnd = arcNear(dist, 288, 137);   // thick ascending limb ends ...
    sMdEnd = arcNear(dist, 262, 110);    // ... macula densa (the bend touching the vascular pole) ...
    sDescTurn = arcNear(desc, 368, 546); // bottom of the hairpin
    sThick = arcNear(dist, 386, 440);    // thin -> thick ascending limb
    // the whole tubule as one path (for seamless drawing): PCT + descending limb + rest
    float[] dd = sub(desc, 6, 9999);
    tub = new float[pct.length + dd.length + dist.length - 4];
    System.arraycopy(pct, 0, tub, 0, pct.length);
    System.arraycopy(dd, 2, tub, pct.length, dd.length - 2);
    System.arraycopy(dist, 2, tub, pct.length + dd.length - 2, dist.length - 2);
    sPctEnd = len(pct);
    sDescEnd = len(sub(tub, 0, 9999)) - len(dist);

    add("bowmans_capsule", "Bowman's Capsule").poly(ring(GX, GY, R_CAPS + 4, R_GLOM + 1, 32)).anchor(GX - 50, GY + 30);
    add("glomerulus", "Glomerulus").ellipse(GX, GY, R_GLOM + 3, R_GLOM + 3).anchor(GX - 4, GY + 4);
    add("proximal_tubule", "Proximal Tubule").poly(tubePoly(sub(pct, 22, 9999), 32)).anchor(246, 292);
    add("descending_limb", "Descending Limb of Henle").poly(tubePoly(sub(desc, 6, sDescTurn), 28)).anchor(348, 450);
    add("ascending_limb", "Ascending Limb of Henle").poly(tubePoly(sub(dist, 0, sAscEnd), 30)).anchor(389, 360);
    add("distal_tubule", "Distal Convoluted Tubule").poly(tubePoly(sub(dist, sMdEnd, 9999), 30)).anchor(420, 84);
    add("collecting_duct", "Collecting Duct").poly(taperPoly(cdp, 38, 50)).anchor(538, 330);
    add("afferent_arteriole", "Afferent Arteriole").poly(tubePoly(sub(aff, 0, len(aff) - 4), 28)).anchor(140, 98);
    add("efferent_arteriole", "Efferent Arteriole").poly(tubePoly(eff, 24)).anchor(284, 172);
    add("macula_densa", "Macula Densa").ellipse(262, 126, 20, 19).anchor(258, 128);
  }

  // annulus as one polygon: outer circle one way, inner circle back the other way (a hole for
  // both the even-odd hit test and non-zero filling)
  float[] ring(float cx, float cy, float ro, float ri, int n) {
    float[] r = new float[(n + 1) * 4];
    for (int i = 0; i <= n; i++) {
      float a = TWO_PI * i / n;
      r[i * 2] = cx + ro * cos(a);
      r[i * 2 + 1] = cy + ro * sin(a);
      r[(2 * n + 1 - i) * 2] = cx + ri * cos(a);
      r[(2 * n + 1 - i) * 2 + 1] = cy + ri * sin(a);
    }
    return r;
  }

  float arcNear(float[] p, float x, float y) {
    float acc = 0, best = 1e9, at = 0;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float d = dist(p[i], p[i + 1], x, y);
      if (d < best) {
        best = d;
        at = acc;
      }
      acc += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    }
    return at;
  }

  void drawArt(PGraphics g) {
    // ---- kidney zones: cortex (top) and medulla (bottom, striated)
    g.noStroke();
    g.fill(CORTEX);
    g.beginShape();
    g.vertex(16, 30);
    g.bezierVertex(16, 20, 22, 14, 32, 14);
    g.vertex(568, 14);
    g.bezierVertex(578, 14, 584, 20, 584, 30);
    g.vertex(584, 332);
    for (float x = 584; x >= 16; x -= 8) g.vertex(x, 336 + 5 * sin(x * 0.045));
    g.endShape(CLOSE);
    g.fill(MEDULLA);
    g.beginShape();
    for (float x = 16; x <= 584; x += 8) g.vertex(x, 336 + 5 * sin(x * 0.045));
    g.vertex(584, 570);
    g.bezierVertex(584, 580, 578, 586, 568, 586);
    g.vertex(32, 586);
    g.bezierVertex(22, 586, 16, 580, 16, 570);
    g.endShape(CLOSE);
    g.stroke(#E3BFB8);
    g.strokeWeight(1.4);
    for (float x = 40; x < 580; x += 26) g.line(x, 352 + 5 * sin(x * 0.045), x + (x - 300) * 0.04, 574);
    g.stroke(#C9A98A);
    g.strokeWeight(1.6);
    g.noFill();
    dashedWave(g);

    // ---- context vessels (no parts): arcuate -> cortical radiate artery, vasa recta
    tube(g, rad, 22, #B9343A, ART_SH, ART_LT, true);
    cutEnd(g, rad, true, 22, ART_SH);
    cutEnd(g, rad, false, 22, ART_SH);
    vasaRecta(g);

    // ---- collecting duct (distinct teal), widening as it descends
    float[] cdPoly = taperPoly(cdp, 30, 42);
    g.noStroke();
    g.fill(CD);
    polygon(g, cdPoly);
    g.strokeCap(SQUARE);
    g.stroke(CD_SH, 160);
    g.strokeWeight(7);
    g.line(551, 22, 549, 580);
    g.strokeCap(ROUND);
    g.stroke(#E8F6F2);
    g.strokeWeight(7);
    g.line(538, 22, 532, 578);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    g.noFill();
    polygon(g, cdPoly);
    cutEnd(g, cdp, true, 30, CD_SH);
    cutEnd(g, cdp, false, 42, CD_SH);

    // ---- tubule: descending limb (thin), PCT (thick), ascending limb (thin -> thick) -> macula densa -> DCT
    wholeTubule(g);
    brushBorder(g, sub(pct, 30, len(pct) - 4), 22);

    // ---- Bowman's capsule: parietal wall + urinary space
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(CAPS);
    g.ellipse(GX, GY, R_CAPS * 2, R_CAPS * 2);
    g.noStroke();
    g.fill(CAPS_SH, 140);
    g.arc(GX, GY, R_CAPS * 2 - 3, R_CAPS * 2 - 3, 0.1, PI - 0.1);
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(URINE);
    g.ellipse(GX, GY, R_SPACE * 2, R_SPACE * 2);
    // neck: the urinary space opens into the PCT at the urinary pole
    g.strokeCap(SQUARE);
    g.stroke(PCT);
    g.strokeWeight(22);
    polyline(g, sub(pct, 4, 30));
    g.strokeCap(ROUND);
    g.stroke(LUMEN);
    g.strokeWeight(7);
    polyline(g, sub(pct, 0, 30));

    // ---- glomerulus: knot of capillary loops
    glomerulus(g);

    // ---- arterioles at the vascular pole (afferent wider than efferent)
    tube(g, aff, 18, D_ARTERY, ART_SH, ART_LT, true);
    cutEnd(g, aff, true, 18, ART_SH);
    tube(g, eff, 12, #C7383C, ART_SH, ART_LT, false);
    // juxtaglomerular (granular) cells in the afferent wall
    g.noStroke();
    g.fill(#F6D7A0);
    float[] jg = sub(aff, len(aff) - 34, len(aff) - 10);
    for (int i = 0; i < jg.length; i += 4) g.ellipse(jg[i] + 4, jg[i + 1] - 5, 4, 4);

    // ---- macula densa: crowded tall cells on the tubule wall facing the pole
    float[] mdp = sub(dist, sAscEnd + 2, sMdEnd);
    float[] wall = offset(mdp, -6);
    g.stroke(D_INK);
    g.strokeWeight(1);
    g.fill(#7A4A1C);
    for (int i = 0; i < wall.length; i += 2) g.ellipse(wall[i], wall[i + 1], 4.2, 4.2);

    // ---- flow chevrons
    g.stroke(#FFFFFF, 220);
    g.strokeWeight(2);
    chevron(g, pct, 120, 4.5);
    chevron(g, desc, 80, 4);
    chevron(g, desc, 150, 4);
    chevron(g, dist, 60, 3.5);
    chevron(g, dist, 250, 4.5);
    chevron(g, dist, sMdEnd + 150, 4.5);
    chevron(g, cdp, 300, 7);
    chevron(g, cdp, 440, 7);
  }

  // the tubule in three passes (ink, colour, lumen) so segments join without seams
  float tubW(float s) {
    if (s < sPctEnd - 10) return 22;
    if (s < sDescEnd) return lerp(22, 13, constrain((s - (sPctEnd - 10)) / 30, 0, 1));
    float d = s - sDescEnd;
    if (d < sAscEnd) return lerp(13, 19, constrain((d - (sThick - 18)) / 36, 0, 1));
    if (d < sMdEnd) return 19;
    return 18;
  }

  int tubCol(float s) {
    if (s < sPctEnd - 4) return PCT;
    if (s < sPctEnd + 16) return lerpColor(PCT, DESC, (s - (sPctEnd - 4)) / 20);
    float d = s - sDescEnd;
    if (d < 0) return DESC;
    if (d < 14) return lerpColor(DESC, ASC, d / 14);
    if (d < sAscEnd) return ASC;
    if (d < sMdEnd) return MD;
    return DCT;
  }

  void wholeTubule(PGraphics g) {
    float L = len(tub), st = 4;
    g.noFill();
    for (int pass = 0; pass < 4; pass++) {
      for (float s = 8; s < L; s += st) {
        float[] seg = sub(tub, s, min(L, s + st + 1));
        float w = tubW(s);
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(w + 4.6);
        } else if (pass == 1) {
          g.stroke(tubCol(s));
          g.strokeWeight(w);
        } else if (pass == 2) {
          g.stroke(lerpColor(tubCol(s), #FFFFFF, 0.3));
          g.strokeWeight(w * 0.2);
          seg = offset(seg, w * 0.26);
        } else {
          g.stroke(LUMEN);
          g.strokeWeight(max(2.5, w * 0.3));
          seg = offset(seg, -w * 0.06);
        }
        polyline(g, seg);
      }
    }
  }

  // vasa recta: thin capillary hairpin from the efferent arteriole (red -> blue)
  void vasaRecta(PGraphics g) {
    float L = len(vr);
    g.noFill();
    g.stroke(D_INK, 200);
    g.strokeWeight(7.4);
    polyline(g, vr);
    g.strokeWeight(5);
    for (float s = 0; s < L; s += 6) {
      g.stroke(lerpColor(#D9474B, #5A7FD6, constrain((s - L * 0.35) / (L * 0.35), 0, 1)));
      polyline(g, sub(vr, s, min(L, s + 7)));
    }
    cutEnd(g, vr, false, 6, #3E5FAE);
  }

  // stroke tube whose width ramps from w0 to w1 around arc length sMid
  void strokeTubeVar(PGraphics g, float[] p, float a, float b, float w0, float w1, float sMid, int col) {
    for (int pass = 0; pass < 3; pass++) {
      for (float s = a; s < b; s += 4) {
        float w = lerp(w0, w1, constrain((s - (sMid - 18)) / 36, 0, 1));
        float[] seg = sub(p, s, min(b, s + 5));
        g.noFill();
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(w + 4.6);
        } else if (pass == 1) {
          g.stroke(col);
          g.strokeWeight(w);
        } else {
          g.stroke(LUMEN);
          g.strokeWeight(max(2.5, w * 0.3));
          seg = offset(seg, -w * 0.06);
        }
        polyline(g, seg);
      }
    }
  }

  void dashedWave(PGraphics g) {
    boolean on = true;
    for (float x = 16; x < 584; x += 8) {
      if (on) g.line(x, 336 + 5 * sin(x * 0.045), x + 8, 336 + 5 * sin((x + 8) * 0.045));
      on = !on;
    }
  }

  // small chevron inside a tube at arc length d pointing along the flow
  void chevron(PGraphics g, float[] p, float d, float s) {
    float[] a = sub(p, d - 1, d + 1);
    float x = a[0], y = a[1], dx = a[a.length - 2] - a[0], dy = a[a.length - 1] - a[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
    dx /= m;
    dy /= m;
    g.noFill();
    g.line(x - dx * s - dy * s, y - dy * s + dx * s, x, y);
    g.line(x - dx * s + dy * s, y - dy * s - dx * s, x, y);
  }

  // glomerulus: a tangled knot of capillary loops fed by the afferent and drained by the efferent
  void glomerulus(PGraphics g) {
    g.noStroke();
    g.fill(#EFA3A0);
    g.ellipse(GX, GY, R_GLOM * 2 - 6, R_GLOM * 2 - 6);
    FloatList k = new FloatList();
    k.append(GX + 40);
    k.append(GY - 50);
    k.append(GX + 26);
    k.append(GY - 30);
    for (float t = 0; t < TWO_PI * 3; t += 0.09) {
      float r = 25 + 12 * sin(2.55 * t + 0.6);
      k.append(GX + r * cos(t - 1.2));
      k.append(GY + r * sin(t - 1.2) * 0.96);
    }
    k.append(GX + 30);
    k.append(GY - 28);
    k.append(GX + 48);
    k.append(GY - 44);
    float[] p = k.array();
    float L = len(p), step = 22;
    for (float s = 0; s < L; s += step) {
      float e = min(L, s + step);
      g.noFill();
      g.stroke(D_INK);
      g.strokeWeight(12.5);
      polyline(g, sub(p, s, e));
      g.stroke(#D5454A);
      g.strokeWeight(9);
      polyline(g, sub(p, max(0, s - 8), e));
      g.stroke(#F6A3A0);
      g.strokeWeight(2.4);
      polyline(g, offset(sub(p, max(0, s - 8), e), 2));
    }
  }

  // tubule drawn as a stroke: ink outline, colour, pale lumen line
  void strokeTube(PGraphics g, float[] p, float w, int col) {
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(w + 4.6);
    polyline(g, p);
    g.stroke(col);
    g.strokeWeight(w);
    polyline(g, p);
    g.stroke(lerpColor(col, #FFFFFF, 0.25));
    g.strokeWeight(w * 0.22);
    polyline(g, offset(p, w * 0.24));
    g.stroke(LUMEN);
    g.strokeWeight(max(2.5, w * 0.3));
    polyline(g, offset(p, -w * 0.06));
  }

  // fuzzy brush-border ticks along the PCT lumen
  void brushBorder(PGraphics g, float[] p, float w) {
    g.stroke(lerpColor(PCT, #8A5A1E, 0.35));
    g.strokeWeight(1);
    for (int i = 0; i + 3 < p.length; i += 2) {
      float dx = p[i + 2] - p[i], dy = p[i + 3] - p[i + 1], m = max(1e-4, sqrt(dx * dx + dy * dy));
      float nx = -dy / m, ny = dx / m;
      float x = p[i] - nx * w * 0.06, y = p[i + 1] - ny * w * 0.06;
      g.line(x + nx * 3, y + ny * 3, x + nx * 5.5, y + ny * 5.5);
      g.line(x - nx * 3, y - ny * 3, x - nx * 5.5, y - ny * 5.5);
    }
  }

  float[] taperPoly(float[] p, float w0, float w1) {
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      float w = lerp(w0, w1, i / (float) (n - 1)) / 2;
      r[i * 2] = p[i * 2] - dy / L * w;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * w;
      r[(2 * n - 1 - i) * 2] = p[i * 2] + dy / L * w;
      r[(2 * n - 1 - i) * 2 + 1] = p[i * 2 + 1] - dx / L * w;
    }
    return r;
  }

  void tube(PGraphics g, float[] path, float w, int col, int sh, int lt, boolean hlLeft) {
    float[] poly = tubePoly(path, w);
    g.noStroke();
    g.fill(col);
    polygon(g, poly);
    float L = len(path), trim = min(w * 0.35, L * 0.2);
    float[] inner = sub(path, trim, L - trim);
    float s = hlLeft ? 1 : -1;
    g.noFill();
    g.strokeCap(SQUARE);
    g.stroke(sh, 150);
    g.strokeWeight(w * 0.2);
    polyline(g, offset(inner, -s * w * 0.3));
    g.stroke(lt, 210);
    g.strokeWeight(w * 0.14);
    polyline(g, offset(inner, s * w * 0.2));
    g.strokeCap(ROUND);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    polygon(g, poly);
  }

  void cutEnd(PGraphics g, float[] path, boolean atStart, float w, int sh) {
    int n = path.length / 2;
    int i0 = atStart ? 0 : n - 1, i1 = atStart ? 1 : n - 2;
    float x = path[i0 * 2], y = path[i0 * 2 + 1];
    float ang = atan2(path[i0 * 2 + 1] - path[i1 * 2 + 1], path[i0 * 2] - path[i1 * 2]);
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(ang);
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(sh);
    g.ellipse(0, 0, w * 0.32, w - 1);
    g.popMatrix();
  }

  // ------------------------------------------------------------ helpers
  void shaded(PGraphics g, float[] p, int base, int sh, int lt, float k, float sw) {
    float[] c = centroid(p);
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, scaled(p, c[0], c[1], k, -3, -4));
    g.fill(lt, 80);
    polygon(g, scaled(p, c[0] - 0.25 * (c[0] - minX(p)), c[1] - 0.3 * (c[1] - minY(p)), 0.5, 0, 0));
    g.fill(lt, 90);
    polygon(g, scaled(p, c[0] - 0.3 * (c[0] - minX(p)), c[1] - 0.38 * (c[1] - minY(p)), 0.28, 0, 0));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  void dashed(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3];
      float d = dist(x0, y0, x1, y1), t = 0;
      while (t < d) {
        float lim = (draw ? on : off) - acc, step = min(lim, d - t);
        if (draw) g.line(x0 + (x1 - x0) * t / d, y0 + (y1 - y0) * t / d, x0 + (x1 - x0) * (t + step) / d, y0 + (y1 - y0) * (t + step) / d);
        t += step;
        acc += step;
        if (acc >= (draw ? on : off) - 0.001) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  float[] cr(float[] c, boolean closed, int seg) {
    int n = c.length / 2, segs = closed ? n : n - 1;
    float[] r = new float[(segs * seg + (closed ? 0 : 1)) * 2];
    int k = 0;
    for (int i = 0; i < segs; i++) {
      int i0 = closed ? (i - 1 + n) % n : max(i - 1, 0), i2 = closed ? (i + 1) % n : i + 1, i3 = closed ? (i + 2) % n : min(i + 2, n - 1);
      for (int s = 0; s < seg; s++) {
        float t = s / (float) seg;
        r[k++] = crv(c[i0 * 2], c[i * 2], c[i2 * 2], c[i3 * 2], t);
        r[k++] = crv(c[i0 * 2 + 1], c[i * 2 + 1], c[i2 * 2 + 1], c[i3 * 2 + 1], t);
      }
    }
    if (!closed) {
      r[k++] = c[(n - 1) * 2];
      r[k++] = c[(n - 1) * 2 + 1];
    }
    return r;
  }

  float crv(float p0, float p1, float p2, float p3, float t) {
    return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
  }

  float len(float[] p) {
    float L = 0;
    for (int i = 0; i + 3 < p.length; i += 2) L += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    return L;
  }

  float[] sub(float[] p, float a, float b) {
    ArrayList<Float> o = new ArrayList<Float>();
    float acc = 0;
    b = min(b, len(p));
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3], d = dist(x0, y0, x1, y1);
      if (d < 1e-4) continue;
      float s0 = acc, s1 = acc + d;
      if (s1 >= a && s0 <= b) {
        float ta = max(0, (a - s0) / d), tb = min(1, (b - s0) / d);
        if (o.size() == 0) {
          o.add(lerp(x0, x1, ta));
          o.add(lerp(y0, y1, ta));
        }
        o.add(lerp(x0, x1, tb));
        o.add(lerp(y0, y1, tb));
      }
      acc = s1;
    }
    float[] r = new float[o.size()];
    for (int i = 0; i < r.length; i++) r[i] = o.get(i);
    return r;
  }

  float[] offset(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  float[] tubePoly(float[] p0, float w) {
    float[] p = clean(p0);
    float[] l = offset(p, w / 2), rr = offset(p, -w / 2);
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      r[i * 2] = l[i * 2];
      r[i * 2 + 1] = l[i * 2 + 1];
      r[(2 * n - 1 - i) * 2] = rr[i * 2];
      r[(2 * n - 1 - i) * 2 + 1] = rr[i * 2 + 1];
    }
    return r;
  }

  // drop points closer than 1 unit to their neighbour (they make wild normals / miter spikes)
  float[] clean(float[] p) {
    FloatList o = new FloatList();
    for (int i = 0; i < p.length; i += 2) {
      int k = o.size();
      boolean last = i == p.length - 2;
      if (k >= 2 && dist(o.get(k - 2), o.get(k - 1), p[i], p[i + 1]) < 1) {
        if (last && k >= 4) {
          o.set(k - 2, p[i]);
          o.set(k - 1, p[i + 1]);
        }
        continue;
      }
      o.append(p[i]);
      o.append(p[i + 1]);
    }
    return o.array();
  }

  float[] centroid(float[] p) {
    float x = 0, y = 0;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      x += p[i * 2];
      y += p[i * 2 + 1];
    }
    return new float[] { x / n, y / n };
  }

  float minX(float[] p) {
    float m = 1e9;
    for (int i = 0; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float minY(float[] p) {
    float m = 1e9;
    for (int i = 1; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float[] scaled(float[] p, float cx, float cy, float k, float dx, float dy) {
    float[] r = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      r[i] = cx + (p[i] - cx) * k + dx;
      r[i + 1] = cy + (p[i + 1] - cy) * k + dy;
    }
    return r;
  }

  void polygon(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void polyline(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }
}


// ======================================================================
// TAB: Dia_Neuron.pde
// ======================================================================
// Multipolar (motor-type) neuron. Dendrites branch from the soma (top left);
// the axon leaves through the axon hillock, runs right under a chain of myelin
// sheaths (Schwann cells, with nodes of Ranvier between them), curves down the
// right side and splits into axon terminals (bottom). One terminal bouton forms
// a synapse on the long dendrite of a second (lavender) neuron at the lower left,
// whose dendrites, soma and nucleus count as the same parts; the circle in the
// middle is that synapse magnified (vesicles, cleft, receptors).

class NeuronDiagram extends Diagram {
  final float SX = 150, SY = 196;                 // soma centre
  final float ICX = 360, ICY = 360, IR = 100;     // synapse inset
  final float AX_W = 9, MY_W = 28, GAP = 14, INIT = 48, TAIL = 48;
  final int NERVE_DK = #C99A24, NISSL = #B98A2A, POST = #CDB8E8, POST_DK = #8E74B8;
  final int MY_DK = #D8C07A, SCHWANN = #9C88CF, NT = #E2563F, RECEPT = #47A99A;

  ArrayList<float[]> dPts = new ArrayList<float[]>();    // dendrite segments (polyline)
  ArrayList<float[]> dWid = new ArrayList<float[]>();    // {w0, w1}
  float[] axonC, axonS;                                  // axon centre line + cumulative length
  float axonLen, sheathL;
  int NSHEATH = 7;
  float[][] term;                                        // terminal branches
  float[][] bout;                                        // bouton centres {x, y, r}
  float[][] post;                                        // second neuron dendrites
  final float JX = 425, JY = 523;                        // the synapse junction on the main figure

  NeuronDiagram() {
    super("neuron", "Neuron");
    build();
    Part d = add("dendrite", "Dendrites");
    for (int i = 0; i < dPts.size(); i++) d.poly(band(dPts.get(i), max(dWid.get(i)[0], dWid.get(i)[1]) + 10, dWid.get(i)[1] + 11));
    // the second (postsynaptic) neuron's dendrites, soma and nucleus are the same structures
    for (int i = 0; i < post.length; i++) d.poly(band(post[i], POST_SW[i] + 10, POST_EW[i] + 11));
    d.anchor(dPts.get(0)[dPts.get(0).length - 2], dPts.get(0)[dPts.get(0).length - 1]);
    add("soma", "Soma (Cell Body)").poly(somaShape(4)).poly(postSoma(4)).anchor(SX - 22, SY + 24);
    add("nucleus", "Nucleus").poly(ell(SX - 6, SY - 3, 22, 20, 0, 24)).poly(ell(PSX + 1, PSY + 1, 14, 13, 0, 20)).anchor(SX - 6, SY - 3);
    add("axon_hillock", "Axon Hillock").poly(SX + 30, SY - 21, SX + 52, SY - 13, SX + 80, SY - 10, SX + 80, SY + 10, SX + 52, SY + 13, SX + 30, SY + 21).anchor(SX + 60, SY);
    Part a = add("axon", "Axon");
    a.poly(band(sub(1, INIT - 1), 22, 22)).poly(band(sub(axonLen - TAIL + 1, axonLen + 4), 22, 22));
    float[] am = at(INIT * 0.5);
    a.anchor(am[0], am[1]);
    Part m = add("myelin_sheath", "Myelin Sheath");
    for (int k = 0; k < NSHEATH; k++) m.poly(band(sub(sheath0(k) + 1, sheath0(k) + sheathL - 1), MY_W + 6, MY_W + 6));
    float[] mm = at(sheath0(2) + sheathL / 2);
    m.anchor(mm[0], mm[1] - 4);
    Part n = add("node_of_ranvier", "Node of Ranvier");
    for (int k = 0; k < NSHEATH - 1; k++) {
      float s0 = sheath0(k) + sheathL;
      n.poly(band(sub(s0 - 4, s0 + GAP + 4), 36, 36));
    }
    float[] nm = at(sheath0(1) + sheathL + GAP / 2);
    n.anchor(nm[0], nm[1]);
    Part t = add("axon_terminal", "Axon Terminal");
    for (float[] b : term) t.poly(band(b, 18, 18));
    for (float[] b : bout) t.poly(ell(b[0], b[1], b[2] + 5, b[2] + 5, 0, 18));
    t.anchor(bout[2][0], bout[2][1]);
    add("synapse", "Synapse").poly(ell(JX, JY, 17, 16, 0, 22)).poly(ell(ICX, ICY, IR + 3, IR + 3, 0, 40)).anchor(ICX, ICY + 12);
  }

  // ------------------------------------------------------------ geometry
  float hash(float i) {
    float v = sin(i * 12.9898 + 4.1) * 43758.5453;
    return v - floor(v);
  }

  void build() {
    // dendrite tree: six primary dendrites, each forking twice
    float[][] prim = { { 198, 45 }, { 152, 45 }, { 238, 47 }, { 282, 42 }, { 112, 45 }, { 66, 37 } };
    for (int i = 0; i < prim.length; i++) {
      float a = radians(prim[i][0]);
      branch(SX + cos(a) * 30, SY + sin(a) * 30, a, prim[i][1], 14, 8, 0, i * 7 + 1);
    }
    // axon centre line
    float[] c = { SX + 76, SY, 300, SY + 2, 400, SY + 6, 470, SY + 20, 522, SY + 60, 547, SY + 120, 545, SY + 190, 522, SY + 245, 486, SY + 282 };
    axonC = crO(c, 10);
    int n = axonC.length / 2;
    axonS = new float[n];
    for (int i = 1; i < n; i++) axonS[i] = axonS[i - 1] + dist(axonC[i * 2 - 2], axonC[i * 2 - 1], axonC[i * 2], axonC[i * 2 + 1]);
    axonLen = axonS[n - 1];
    sheathL = (axonLen - INIT - TAIL - (NSHEATH - 1) * GAP) / NSHEATH;
    // terminal arborization
    float ex = axonC[(n - 1) * 2], ey = axonC[(n - 1) * 2 + 1];
    term = new float[][] {
      crO(new float[] { ex, ey, ex - 22, ey + 16, JX + 14, JY - 6 }, 6),
      crO(new float[] { ex, ey, ex - 10, ey + 26, ex - 22, ey + 50, ex - 26, ey + 66 }, 6),
      crO(new float[] { ex, ey, ex + 10, ey + 24, ex + 14, ey + 52, ex + 8, ey + 70 }, 6),
      crO(new float[] { ex + 10, ey + 24, ex + 28, ey + 36, ex + 44, ey + 46 }, 6)
    };
    bout = new float[][] { { JX + 9, JY - 3, 9 }, { ex - 26, ey + 70, 9 }, { ex + 8, ey + 74, 9 }, { ex + 48, ey + 49, 8.5 } };
    // second neuron (partial, lower left): a smaller multipolar cell whose longest dendrite reaches right to
    // the synapse; side branches and tapering make it read as a dendrite, not an axon
    post = new float[][] {
      crO(new float[] { 226, 516, 272, 517, 318, 521, 362, 525, 398, 527, JX - 6, JY + 4 }, 6),
      crO(new float[] { 300, 519, 306, 502, 316, 488 }, 6),
      crO(new float[] { 352, 524, 360, 541, 373, 554 }, 6),
      crO(new float[] { 198, 496, 190, 472, 184, 448 }, 6),
      crO(new float[] { 190, 472, 204, 456, 220, 446 }, 6),
      crO(new float[] { 184, 505, 156, 491, 128, 484 }, 6),
      crO(new float[] { 156, 491, 147, 472, 142, 455 }, 6),
      crO(new float[] { 178, 526, 146, 532, 110, 528 }, 6),
      crO(new float[] { 146, 532, 128, 548, 114, 560 }, 6),
      crO(new float[] { 192, 535, 168, 556, 146, 574 }, 6),
      crO(new float[] { 210, 545, 216, 562, 213, 580 }, 6)
    };
  }

  final float[] POST_SW = { 10, 5, 5, 9, 5, 8, 4.5, 8, 4, 7, 7 };
  final float[] POST_EW = { 6, 2.5, 2.5, 4, 2.5, 3.5, 2.2, 3, 2, 3, 3 };
  final float PSX = 205, PSY = 520;                      // second neuron's soma centre

  float[] postSoma(float grow) {
    float[] ang = { 0, 40, 80, 120, 160, 200, 240, 280, 320 };
    float[] rad = { 27, 22, 26, 22, 27, 23, 27, 22, 25 };
    float[] p = new float[ang.length * 2];
    for (int i = 0; i < ang.length; i++) {
      float a = radians(ang[i]);
      p[i * 2] = PSX + cos(a) * (rad[i] + grow);
      p[i * 2 + 1] = PSY + sin(a) * (rad[i] + grow) * 0.9;
    }
    return crC(p, 4);
  }

  void branch(float x, float y, float a, float len, float w0, float w1, int depth, float seed) {
    float ex = x + cos(a) * len, ey = y + sin(a) * len;
    float bend = (hash(seed) - 0.5) * 0.5 * len;
    float mx = (x + ex) / 2 - sin(a) * bend, my = (y + ey) / 2 + cos(a) * bend;
    dPts.add(crO(new float[] { x, y, mx, my, ex, ey }, 6));
    dWid.add(new float[] { w0, w1 });
    if (depth >= 2) return;
    float spread = depth == 0 ? 0.5 : 0.42;
    float j = (hash(seed + 3) - 0.5) * 0.3;
    branch(ex, ey, a - spread + j, len * (0.74 + 0.12 * hash(seed + 5)), w1, w1 * 0.55, depth + 1, seed * 3 + 1);
    branch(ex, ey, a + spread + j, len * (0.70 + 0.12 * hash(seed + 9)), w1 * 0.9, w1 * 0.5, depth + 1, seed * 3 + 2);
  }

  float sheath0(int k) {
    return INIT + k * (sheathL + GAP);
  }

  // point on the axon at arc length s
  float[] at(float s) {
    int n = axonS.length;
    s = constrain(s, 0, axonLen);
    for (int i = 1; i < n; i++) {
      if (axonS[i] >= s) {
        float f = (s - axonS[i - 1]) / max(1e-3, axonS[i] - axonS[i - 1]);
        return new float[] { lerp(axonC[i * 2 - 2], axonC[i * 2], f), lerp(axonC[i * 2 - 1], axonC[i * 2 + 1], f) };
      }
    }
    return new float[] { axonC[(n - 1) * 2], axonC[(n - 1) * 2 + 1] };
  }

  // the axon centre line between arc lengths s0 and s1 (extrapolated past the ends if needed)
  float[] sub(float s0, float s1) {
    int k = max(2, ceil((s1 - s0) / 3));
    float[] p = new float[(k + 1) * 2];
    for (int i = 0; i <= k; i++) {
      float s = lerp(s0, s1, i / (float) k);
      float[] q;
      if (s > axonLen) {
        float[] e = at(axonLen), e2 = at(axonLen - 4);
        float dx = e[0] - e2[0], dy = e[1] - e2[1], L = max(1e-3, sqrt(dx * dx + dy * dy));
        q = new float[] { e[0] + dx / L * (s - axonLen), e[1] + dy / L * (s - axonLen) };
      } else q = at(s);
      p[i * 2] = q[0];
      p[i * 2 + 1] = q[1];
    }
    return p;
  }

  // soma outline: a rounded star, swelling toward each primary dendrite and the hillock
  float[] somaShape(float grow) {
    float[] ang = { 0, 32, 66, 90, 112, 132, 152, 175, 198, 218, 238, 260, 282, 310, 336 };
    float[] rad = { 40, 36, 41, 34, 42, 34, 41, 34, 42, 34, 42, 35, 41, 34, 36 };
    float[] p = new float[ang.length * 2];
    for (int i = 0; i < ang.length; i++) {
      float a = radians(ang[i]);
      p[i * 2] = SX + cos(a) * (rad[i] + grow);
      p[i * 2 + 1] = SY + sin(a) * (rad[i] + grow) * 0.92;
    }
    return crC(p, 4);
  }

  // ------------------------------------------------------------ art
  void drawArt(PGraphics g) {
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    drawPostNeuron(g);
    drawNeuronBody(g);
    drawMyelin(g);
    drawCallout(g);
    drawInset(g);
  }

  void taper(PGraphics g, float[] p, float w0, float w1, float add, int col) {
    g.stroke(col);
    g.noFill();
    int n = p.length / 2;
    for (int i = 0; i < n - 1; i++) {
      g.strokeWeight(lerp(w0, w1, i / (float) max(1, n - 2)) + add);
      g.line(p[i * 2], p[i * 2 + 1], p[i * 2 + 2], p[i * 2 + 3]);
    }
  }

  void drawNeuronBody(PGraphics g) {
    float[] ax = sub(0, axonLen);
    // soft shadow
    g.pushMatrix();
    g.translate(4, 6);
    for (int i = 0; i < dPts.size(); i++) taper(g, dPts.get(i), dWid.get(i)[0], dWid.get(i)[1], 4, g.color(0, 0, 0, 18));
    g.noStroke();
    g.fill(0, 0, 0, 18);
    shp(g, somaShape(2));
    g.popMatrix();
    // pass 1: ink silhouette; pass 2: body colour; pass 3: highlight
    for (int pass = 0; pass < 3; pass++) {
      int col = pass == 0 ? D_INK : pass == 1 ? D_NERVE : g.color(255, 255, 255, 80);
      float add = pass == 0 ? 4.6 : 0;
      for (int i = 0; i < dPts.size(); i++) {
        float[] p = dPts.get(i);
        if (pass < 2) taper(g, p, dWid.get(i)[0], dWid.get(i)[1], add, col);
        else taper(g, shift(p, -0.8, -1.2), dWid.get(i)[0] * 0.3, dWid.get(i)[1] * 0.25, 0, col);
      }
      float aw = pass == 2 ? AX_W * 0.3 : AX_W + add;
      g.stroke(col);
      g.strokeWeight(aw);
      g.noFill();
      pl(g, pass == 2 ? shift(ax, -0.6, -1.4) : ax);
      for (float[] t : term) {
        g.strokeWeight(pass == 2 ? 2 : 6.5 + add);
        pl(g, pass == 2 ? shift(t, -0.5, -1) : t);
      }
      g.noStroke();
      if (pass < 2) {
        g.fill(col);
        for (float[] b : bout) g.ellipse(b[0], b[1], b[2] * 2 + add, b[2] * 2 + add);
        // the hillock cone
        float[] hill = { SX + 26, SY - 22, SX + 50, SY - 12, SX + 78, SY - AX_W / 2, SX + 78, SY + AX_W / 2, SX + 50, SY + 12, SX + 26, SY + 22 };
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(add);
        }
        shp(g, crO(hill, 4));
        g.noStroke();
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(add);
        }
        shp(g, somaShape(0));
      } else {
        for (float[] b : bout) g.ellipse(b[0] - b[2] * 0.3, b[1] - b[2] * 0.35, b[2] * 0.8, b[2] * 0.6);
      }
    }
    // soma shading + Nissl bodies
    g.noStroke();
    g.fill(lerpColor(D_NERVE, #FFFFFF, 0.35));
    shp(g, ell(SX - 14, SY - 16, 22, 13, -0.4, 24));
    g.fill(NISSL);
    float[] nis = { -28, 14, -20, 26, -2, 26, 14, 20, 24, 6, 22, -14, 8, -26, -24, -20, -32, -4, 30, -6, -12, 30 };
    for (int k = 0; k < nis.length; k += 2) g.ellipse(SX + nis[k], SY + nis[k + 1], 4.2, 3.2);
    // hillock: subtle lighter tone (no Nissl bodies there)
    g.fill(lerpColor(D_NERVE, #FFF6D8, 0.45));
    shp(g, crO(new float[] { SX + 34, SY - 13, SX + 52, SY - 8, SX + 70, SY - 3, SX + 70, SY + 2, SX + 52, SY + 7, SX + 34, SY + 12 }, 4));
    // nucleus + nucleolus
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.fill(D_NUCLEUS);
    g.ellipse(SX - 6, SY - 3, 38, 35);
    g.noStroke();
    g.fill(lerpColor(D_NUCLEUS, #FFFFFF, 0.3));
    g.ellipse(SX - 11, SY - 9, 16, 9);
    g.fill(#4E3C86);
    g.ellipse(SX - 1, SY + 1, 11, 11);
    // a few dendritic spines on the outer branches
    g.stroke(D_INK);
    g.strokeWeight(1.3);
    g.fill(D_NERVE);
    for (int i = 0; i < dPts.size(); i++) {
      if (dWid.get(i)[0] > 7) continue;
      float[] p = dPts.get(i);
      int n = p.length / 2;
      for (int k = 3; k < n - 2; k += 4) {
        float tx = p[k * 2 + 2] - p[k * 2 - 2], ty = p[k * 2 + 3] - p[k * 2 - 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        float s = (k / 4) % 2 == 0 ? 1 : -1, w = lerp(dWid.get(i)[0], dWid.get(i)[1], k / (float) n) / 2;
        float bx = p[k * 2] - ty / L * s * (w + 3.5), by = p[k * 2 + 1] + tx / L * s * (w + 3.5);
        g.line(p[k * 2] - ty / L * s * w, p[k * 2 + 1] + tx / L * s * w, bx, by);
        g.ellipse(bx, by, 3.4, 3.4);
      }
    }
  }

  void drawMyelin(PGraphics g) {
    for (int k = 0; k < NSHEATH; k++) {
      float s0 = sheath0(k), s1 = s0 + sheathL, r = MY_W / 2;
      float[] c = sub(s0 + r, s1 - r);
      g.noFill();
      g.stroke(0, 0, 0, 20);
      g.strokeWeight(MY_W);
      pl(g, shift(c, 3, 5));
      g.stroke(D_INK);
      g.strokeWeight(MY_W + 4.6);
      pl(g, c);
      g.stroke(MY_DK);
      g.strokeWeight(MY_W);
      pl(g, c);
      g.stroke(D_MYELIN);
      g.strokeWeight(MY_W * 0.62);
      pl(g, shift(c, -1, -2.4));
      g.stroke(255, 255, 255, 120);
      g.strokeWeight(MY_W * 0.18);
      pl(g, shift(c, -2, -6));
      // wrapped lamellae
      g.stroke(lerpColor(MY_DK, D_INK, 0.25));
      g.strokeWeight(1.2);
      for (float s = s0 + 7; s < s1 - 5; s += 6.5) {
        float[] p = at(s), q = at(s + 1);
        float tx = q[0] - p[0], ty = q[1] - p[1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        float nx = -ty / L, ny = tx / L;
        float h = r - 2.6;
        if (s < s0 + 12 || s > s1 - 12) h *= 0.72;
        g.line(p[0] + nx * h + tx / L * 2, p[1] + ny * h + ty / L * 2, p[0] - nx * h - tx / L * 2, p[1] - ny * h - ty / L * 2);
      }
      // Schwann cell nucleus on the outer side
      float[] mid = at(s0 + sheathL * 0.55), mq = at(s0 + sheathL * 0.55 + 1);
      float tx = mq[0] - mid[0], ty = mq[1] - mid[1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float side = k < 3 ? -1 : 1;
      float nx = -ty / L * side, ny = tx / L * side;
      g.pushMatrix();
      g.translate(mid[0] + nx * (r - 1), mid[1] + ny * (r - 1));
      g.rotate(atan2(ty, tx));
      g.stroke(D_INK);
      g.strokeWeight(1.8);
      g.fill(SCHWANN);
      g.ellipse(0, 0, 20, 9);
      g.noStroke();
      g.fill(255, 255, 255, 80);
      g.ellipse(-3, -1.5, 8, 3);
      g.popMatrix();
    }
  }

  void drawPostNeuron(PGraphics g) {
    // soft shadow
    g.pushMatrix();
    g.translate(4, 6);
    for (int i = 0; i < post.length; i++) taper(g, post[i], POST_SW[i], POST_EW[i], 3, g.color(0, 0, 0, 18));
    g.noStroke();
    g.fill(0, 0, 0, 18);
    shp(g, postSoma(1));
    g.popMatrix();
    for (int pass = 0; pass < 3; pass++) {
      int col = pass == 0 ? D_INK : pass == 1 ? POST : g.color(255, 255, 255, 80);
      float add = pass == 0 ? 4.4 : 0;
      for (int i = 0; i < post.length; i++) {
        if (pass < 2) taper(g, post[i], POST_SW[i], POST_EW[i], add, col);
        else taper(g, shift(post[i], -0.6, -1), POST_SW[i] * 0.3, POST_EW[i] * 0.3, 0, col);
      }
      g.noStroke();
      if (pass < 2) {
        g.fill(col);
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(add);
        }
        shp(g, postSoma(0));
        g.noStroke();
        // spine head facing the bouton
        g.ellipse(JX - 4, JY + 4, 13 + add, 13 + add);
      }
    }
    // soma shading, nucleus + nucleolus
    g.noStroke();
    g.fill(lerpColor(POST, #FFFFFF, 0.35));
    shp(g, ell(PSX - 9, PSY - 9, 13, 7, -0.4, 20));
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(POST_DK);
    g.ellipse(PSX + 1, PSY + 1, 22, 20);
    g.noStroke();
    g.fill(#5B4790);
    g.ellipse(PSX + 4, PSY + 3, 7, 7);
  }

  void drawCallout(PGraphics g) {
    // dashed ring around the junction + two dashed lines to the magnified view
    g.noFill();
    g.stroke(#6B6250);
    g.strokeWeight(1.6);
    dashedEll(g, JX + 2, JY, 20, 18);
    float a1 = radians(52), a2 = radians(100);
    dashed(g, JX + 2 + cos(-0.4) * 20, JY + sin(-0.4) * 18 - 4, ICX + cos(a1) * IR, ICY + sin(a1) * IR);
    dashed(g, JX + 2 + cos(-2.6) * 20, JY + sin(-2.6) * 18, ICX + cos(a2) * IR, ICY + sin(a2) * IR);
  }

  void drawInset(PGraphics g) {
    float R = IR;
    g.noStroke();
    g.fill(0, 0, 0, 26);
    g.ellipse(ICX + 4, ICY + 6, R * 2, R * 2);
    g.fill(#FFFCF4);
    g.ellipse(ICX, ICY, R * 2, R * 2);
    // presynaptic terminal (top) and postsynaptic membrane (bottom), parabolic faces
    float[] pre = cap(R - 1.5, -2, 0.0062, true);
    float[] postR = cap(R - 1.5, 16, 0.0062, false);
    g.fill(D_NERVE);
    shp(g, loc(pre));
    g.fill(lerpColor(D_NERVE, #FFFFFF, 0.3));
    shp(g, loc(cap(R - 14, -40, 0.0062, true)));
    g.fill(POST);
    shp(g, loc(postR));
    g.fill(lerpColor(POST, #FFFFFF, 0.3));
    shp(g, loc(cap(R - 14, 50, 0.0062, false)));
    // membranes
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    pl(g, loc(parab(-2, 0.0062, R - 1.5)));
    pl(g, loc(parab(16, 0.0062, R - 1.5)));
    // postsynaptic density
    g.stroke(POST_DK);
    g.strokeWeight(5);
    pl(g, loc(parab(21, 0.0062, 44)));
    // receptors straddling the postsynaptic membrane
    for (int i = -3; i <= 3; i++) {
      float x = i * 13, y = 16 - 0.0062 * x * x;
      float ang = atan(-2 * 0.0062 * x);
      g.pushMatrix();
      g.translate(ICX + x, ICY + y);
      g.rotate(ang);
      g.stroke(D_INK);
      g.strokeWeight(1.4);
      g.fill(RECEPT);
      g.rect(-4.5, -4.5, 4, 10, 1.5);
      g.rect(0.5, -4.5, 4, 10, 1.5);
      g.popMatrix();
    }
    // mitochondrion in the bouton
    g.pushMatrix();
    g.translate(ICX - 48, ICY - 56);
    g.rotate(-0.35);
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(D_MITO);
    g.ellipse(0, 0, 44, 20);
    g.noFill();
    g.stroke(#C2582F);
    g.strokeWeight(1.6);
    for (int i = -1; i <= 1; i++) g.line(i * 10, -6 * (i % 2 == 0 ? 1 : -1), i * 10, 2 * (i % 2 == 0 ? 1 : -1));
    g.popMatrix();
    // synaptic vesicles full of neurotransmitter
    float[] v = { -22, -38, 4, -46, 30, -40, 52, -54, -2, -64, 26, -70, 58, -26, -36, -14, -10, -18, 22, -20, 8, -36 };
    for (int k = 0; k < v.length; k += 2) vesicle(g, ICX + v[k], ICY + v[k + 1], 7.5);
    // a vesicle fusing with the membrane (exocytosis), spilling transmitter into the cleft
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(#FFF6CF);
    g.arc(ICX + 2, ICY - 3, 17, 17, PI + 0.35, TWO_PI - 0.35);
    g.noStroke();
    g.fill(NT);
    float[] nt = { -10, 8, -2, 11, 8, 7, 14, 10, 20, 6, -18, 9, 2, 4, -4, 5, 26, 10, -26, 11, 12, 3 };
    for (int k = 0; k < nt.length; k += 2) g.ellipse(ICX + nt[k], ICY + nt[k + 1], 3.6, 3.6);
    // border
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(3);
    g.ellipse(ICX, ICY, R * 2, R * 2);
    g.stroke(#B8AC90);
    g.strokeWeight(1.2);
    g.ellipse(ICX, ICY, R * 2 + 8, R * 2 + 8);
  }

  void vesicle(PGraphics g, float x, float y, float r) {
    g.stroke(D_INK);
    g.strokeWeight(1.5);
    g.fill(#FFF6CF);
    g.ellipse(x, y, r * 2, r * 2);
    g.noStroke();
    g.fill(NT);
    g.ellipse(x - 2, y - 1.5, 3, 3);
    g.ellipse(x + 2.2, y - 0.5, 3, 3);
    g.ellipse(x, y + 2.4, 3, 3);
  }

  // parabola y = a - b x^2 (inset-local), x within the circle of radius R
  float[] parab(float a, float b, float R) {
    float xi = capX(R, a, b);
    int n = 30;
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float x = lerp(-xi, xi, i / (float) (n - 1));
      p[i * 2] = x;
      p[i * 2 + 1] = a - b * x * x;
    }
    return p;
  }

  float capX(float R, float a, float b) {
    float lo = 0, hi = R;
    for (int i = 0; i < 40; i++) {
      float m = (lo + hi) / 2, y = a - b * m * m;
      if (m * m + y * y < R * R) lo = m;
      else hi = m;
    }
    return lo;
  }

  // the part of the circle above (top = true) or below the parabola
  float[] cap(float R, float a, float b, boolean top) {
    float xi = capX(R, a, b), yi = a - b * xi * xi, ai = atan2(yi, xi);
    FloatList q = new FloatList();
    int n = 30;
    if (top) {
      for (int i = 0; i < n; i++) {
        float x = lerp(-xi, xi, i / (float) (n - 1));
        q.append(x);
        q.append(a - b * x * x);
      }
      for (int i = 1; i < n; i++) {
        float t = lerp(ai, -PI - ai, i / (float) n);
        q.append(cos(t) * R);
        q.append(sin(t) * R);
      }
    } else {
      for (int i = 0; i < n; i++) {
        float x = lerp(xi, -xi, i / (float) (n - 1));
        q.append(x);
        q.append(a - b * x * x);
      }
      for (int i = 1; i < n; i++) {
        float t = lerp(PI - ai, ai, i / (float) n);
        q.append(cos(t) * R);
        q.append(sin(t) * R);
      }
    }
    return q.array();
  }

  float[] loc(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = p[i] + ICX;
      q[i + 1] = p[i + 1] + ICY;
    }
    return q;
  }

  void dashed(PGraphics g, float x0, float y0, float x1, float y1) {
    float L = dist(x0, y0, x1, y1);
    int n = max(1, round(L / 9));
    for (int i = 0; i < n; i += 2) {
      float f0 = i / (float) n, f1 = min(1, (i + 1) / (float) n);
      g.line(lerp(x0, x1, f0), lerp(y0, y1, f0), lerp(x0, x1, f1), lerp(y0, y1, f1));
    }
  }

  void dashedEll(PGraphics g, float cx, float cy, float rx, float ry) {
    int n = 22;
    for (int i = 0; i < n; i += 2) {
      float t0 = TWO_PI * i / n, t1 = TWO_PI * (i + 1) / n;
      g.line(cx + cos(t0) * rx, cy + sin(t0) * ry, cx + cos(t1) * rx, cy + sin(t1) * ry);
    }
  }

  // ------------------------------------------------------------ helpers (local to this class)
  float[] shift(float[] p, float dx, float dy) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = p[i] + dx;
      q[i + 1] = p[i + 1] + dy;
    }
    return q;
  }

  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] q = new float[n * 4];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) max(1, n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      q[i * 2] = c[i * 2] + nx;
      q[i * 2 + 1] = c[i * 2 + 1] + ny;
      q[(2 * n - 1 - i) * 2] = c[i * 2] - nx;
      q[(2 * n - 1 - i) * 2 + 1] = c[i * 2 + 1] - ny;
    }
    return q;
  }

  float[] ell(float cx, float cy, float rx, float ry, float ang, int n) {
    float[] p = new float[n * 2];
    float ca = cos(ang), sa = sin(ang);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * ca - y * sa;
      p[i * 2 + 1] = cy + x * sa + y * ca;
    }
    return p;
  }

  void shp(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void pl(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  float[] crO(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float[] crC(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      int i0 = (i + n - 1) % n, i2 = (i + 1) % n, i3 = (i + 2) % n;
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    return q.array();
  }
}


// ======================================================================
// TAB: Dia_OrganMap.pde
// ======================================================================
// Organ map: neutral front-view body (head to upper thighs) with the major organs
// in their anatomical places, stylised and slightly spread so each is clickable.
// Subject's right on the viewer's left (liver left, stomach + spleen right).

class OrganMapDiagram extends Diagram {
  final int BODY = #E1E6EE, BODY_SH = #C8D0DC;
  final int THYMUS = #EFBE86, SPLEEN = #8A3A5C, PANCREAS = #F2CC6B, BLADDER = #F3DCA2, AIRWAY = #DCE6EA;

  float[] body, brain, lungR, lungL, heart, liver, stomach, spleen, pancreas, duodC, duod, colonC, colon, smallMass, bladder;
  float[] kidneyR, kidneyL, adrenalR, adrenalL, thyroid, thymus, appendix, appC, rectC, rectum;

  OrganMapDiagram() {
    super("organ_map", "Organ Map");
    build();
    add("lungs", "Lungs").poly(lungR).poly(lungL).anchor(247, 262);
    add("liver", "Liver").poly(liver).anchor(256, 350);
    add("stomach", "Stomach").poly(stomach).anchor(362, 356);
    add("small_intestine", "Small Intestine").poly(smallMass).poly(duod).anchor(300, 488);
    add("large_intestine", "Large Intestine").poly(colon).poly(appendix).poly(rectum).anchor(247, 478);
    add("kidneys", "Kidneys").poly(kidneyR).poly(kidneyL);
    add("brain", "Brain").poly(brain).anchor(300, 50);
    add("heart", "Heart").poly(heart).anchor(318, 278);
    add("spleen", "Spleen").poly(spleen);
    add("pancreas", "Pancreas").poly(pancreas).anchor(330, 401);
    add("thymus", "Thymus").poly(thymus);
    add("thyroid", "Thyroid Gland").poly(thyroid).anchor(300, 159);
    add("adrenal_glands", "Adrenal Glands").poly(ellPts(213, 393, 12, 9, 0)).poly(ellPts(388, 385, 12, 9, 0));
    add("bladder", "Urinary Bladder").poly(bladder);
    add("pituitary", "Pituitary Gland").ellipse(300, 96, 11, 10);
    add("lymph_nodes", "Lymph Nodes").ellipse(280, 131, 9, 14).ellipse(320, 131, 9, 14).ellipse(209, 221, 12, 12).ellipse(391, 221, 12, 12)
      .ellipse(246, 562, 17, 10, 0.5).ellipse(354, 562, 17, 10, -0.5).anchor(209, 221);
  }

  // =============================================================== geometry
  void build() {
    body = symClosed(new float[] { 300, 11, 279, 14, 262, 24, 251, 40, 248, 60, 250, 80, 255, 97, 263, 110, 272, 119,
      271, 128, 270, 148, 268, 166, 254, 174, 232, 181, 210, 187, 194, 195,
      184, 210, 178, 232, 174, 262, 170, 295, 165, 330, 159, 362, 154, 395, 150, 428, 147, 456,
      142, 468, 137, 486, 136, 504, 141, 520, 151, 525, 159, 516, 162, 500, 160, 486, 164, 472,
      166, 456, 170, 428, 175, 396, 180, 364, 186, 330, 191, 296, 195, 262, 198, 240, 203, 226,
      204, 250, 203, 290, 200, 330, 198, 370, 196, 410, 194, 450, 193, 490, 194, 530, 196, 566, 198, 606, 300, 606 });
    brain = sym(new float[] { 300, 22, 283, 17, 267, 22, 256, 33, 251, 48, 251, 64, 255, 77, 263, 86, 274, 90, 283, 87, 291, 82, 297, 84, 300, 85 });
    thyroid = new float[] { 280, 147, 291, 147, 300, 153, 309, 147, 320, 147, 322, 160, 318, 172, 306, 171, 300, 167, 294, 171, 282, 172, 278, 160 };
    thymus = new float[] { 293, 187, 300, 190, 307, 187, 316, 194, 318, 210, 314, 226, 305, 230, 300, 226, 295, 230, 286, 226, 282, 210, 284, 194 };
    lungR = new float[] { 268, 190, 280, 193, 288, 204, 290, 228, 291, 256, 292, 286, 290, 312, 272, 310, 252, 309, 234, 313, 222, 317,
      217, 296, 218, 264, 221, 234, 229, 212, 243, 198, 256, 191 };
    lungL = new float[] { 332, 190, 320, 193, 312, 204, 310, 228, 312, 246, 324, 254, 336, 266, 342, 286, 343, 304, 349, 314, 366, 311,
      378, 316, 383, 296, 382, 264, 379, 234, 371, 212, 357, 198, 344, 191 };
    heart = new float[] { 290, 248, 304, 240, 320, 241, 334, 248, 344, 262, 349, 280, 349, 298, 342, 307, 322, 312, 302, 310, 290, 302,
      285, 284, 286, 264 };
    liver = new float[] { 212, 330, 232, 323, 258, 320, 282, 322, 300, 328, 318, 330, 334, 331, 339, 336, 334, 343, 318, 350, 296, 360,
      272, 370, 250, 378, 230, 380, 216, 374, 208, 358, 207, 342 };
    stomach = new float[] { 345, 330, 352, 324, 364, 322, 375, 328, 381, 342, 381, 360, 376, 376, 362, 387, 343, 391, 325, 389, 313, 384,
      309, 377, 316, 374, 328, 373, 340, 367, 347, 356, 349, 343 };
    spleen = ellPts(391, 350, 9.5, 21, 0.3);
    pancreas = new float[] { 258, 395, 270, 392, 283, 394, 300, 397, 322, 397, 344, 396, 361, 392, 372, 385, 378, 381, 381, 385, 376, 393,
      364, 400, 346, 405, 322, 407, 300, 408, 285, 411, 272, 415, 261, 411, 256, 403 };
    duodC = cr(new float[] { 309, 380, 294, 383, 274, 385, 257, 389, 249, 401, 252, 415, 265, 423, 285, 425, 304, 421, 318, 415 }, 4);
    duod = band(duodC, 11, 10);
    colonC = cr(new float[] { 248, 514, 248, 498, 247, 474, 248, 456, 253, 444, 263, 437, 278, 437, 300, 444, 322, 441, 337, 436, 348, 440,
      354, 452, 356, 478, 355, 503, 348, 519, 331, 527, 316, 531, 307, 540, 304, 552 }, 4);
    colon = band(colonC, 24, 16);
    appC = cr(new float[] { 244, 520, 240, 532, 236, 541, 240, 547 }, 3);
    appendix = band(appC, 9, 8);
    rectC = cr(new float[] { 305, 540, 303, 556, 301.5, 572, 301, 584, 301, 592 }, 3);
    rectum = band(rectC, 15, 14);
    smallMass = new float[] { 262, 456, 285, 452, 300, 457, 318, 452, 340, 456, 344, 472, 343, 492, 338, 512, 322, 520, 300, 518, 280, 522,
      262, 515, 258, 496, 259, 474 };
    kidneyR = new float[] { 212, 399, 220, 400, 224, 408, 222, 416, 225, 424, 223, 434, 214, 441, 205, 438, 200, 426, 199, 412, 203, 402 };
    kidneyL = mir(new float[] { 212, 391, 220, 392, 224, 400, 222, 408, 225, 416, 223, 426, 214, 433, 205, 430, 200, 418, 199, 404, 203, 394 });
    adrenalR = new float[] { 204, 400, 210, 387, 216, 384, 222, 392, 222, 400, 213, 397 };
    adrenalL = new float[] { 377, 392, 381, 382, 389, 377, 396, 382, 398, 392, 389, 389 };
    bladder = new float[] { 300, 547, 312, 549, 321, 556, 322, 566, 316, 575, 306, 579, 294, 579, 284, 575, 278, 566, 279, 556, 288, 549 };
  }

  // =============================================================== art
  void drawArt(PGraphics g) {
    // body
    g.noStroke();
    g.fill(BODY_SH);
    blob(g, body);
    g.fill(BODY);
    blob(g, inner(body, 6));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    blob(g, body);
    // airway + oesophagus (context, behind)
    g.stroke(D_INK);
    g.strokeWeight(1.4);
    g.fill(AIRWAY);
    g.rect(294, 140, 12, 60, 3);
    g.stroke(#AFC0C6);
    for (int k = 0; k < 9; k++) g.line(295, 149 + k * 5.5, 305, 149 + k * 5.5);
    g.stroke(D_INK);
    g.fill(AIRWAY);
    blob(g, new float[] { 290, 130, 300, 127, 310, 130, 309, 141, 300, 146, 291, 141 });           // larynx
    // ureters
    g.noFill();
    g.stroke(#C9A23A);
    g.strokeWeight(2.4);
    g.bezier(222, 420, 238, 462, 262, 520, 286, 556);
    g.bezier(378, 412, 362, 462, 338, 520, 314, 556);
    // kidneys (T12-L3, hilum at the transpyloric level) + adrenals, behind the gut
    organ(g, kidneyR, D_KIDNEY, 2);
    organ(g, kidneyL, D_KIDNEY, 2);
    g.noStroke();
    g.fill(#E7B7A8);
    blob(g, new float[] { 218, 412, 223, 414, 223, 422, 218, 423 });
    blob(g, mir(new float[] { 218, 404, 223, 406, 223, 414, 218, 415 }));
    organ(g, adrenalR, D_GLAND, 1.6);
    organ(g, adrenalL, D_GLAND, 1.6);
    // lungs
    organ(g, lungR, D_LUNG, 2.2);
    organ(g, lungL, D_LUNG, 2.2);
    g.noFill();
    g.stroke(#C9707F);
    g.strokeWeight(1.6);
    g.bezier(219, 258, 240, 255, 265, 254, 290, 255);                                              // horizontal fissure
    g.bezier(219, 262, 236, 280, 252, 296, 266, 310);                                              // oblique fissures
    g.bezier(381, 246, 370, 270, 360, 292, 352, 312);
    g.stroke(#E7808F);
    g.strokeWeight(1.1);
    for (int s = 0; s < 2; s++) {                                                                 // bronchial tree hint
      float[] t = { 288, 236, 270, 246, 252, 262, 236, 280 };
      line(g, s == 0 ? t : mir(t));
      float[] t2 = { 270, 246, 262, 226, 250, 214 };
      line(g, s == 0 ? t2 : mir(t2));
      float[] t3 = { 262, 256, 268, 282, 262, 298 };
      line(g, s == 0 ? t3 : mir(t3));
    }
    // great vessels + heart
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(D_VEIN);
    g.rect(287, 216, 9, 36, 3);                                                                     // superior vena cava
    g.fill(D_ARTERY);
    g.beginShape();                                                                                 // aortic arch
    g.vertex(300, 250);
    g.bezierVertex(298, 230, 304, 214, 318, 214);
    g.bezierVertex(328, 214, 333, 222, 332, 236);
    g.vertex(324, 236);
    g.bezierVertex(325, 226, 322, 222, 317, 222);
    g.bezierVertex(310, 222, 308, 232, 309, 250);
    g.endShape(CLOSE);
    g.fill(#5B86DD);
    g.beginShape();                                                                                 // pulmonary trunk
    g.vertex(312, 252);
    g.bezierVertex(311, 240, 316, 232, 326, 230);
    g.vertex(331, 236);
    g.bezierVertex(324, 238, 321, 244, 321, 254);
    g.endShape(CLOSE);
    organ(g, heart, D_HEART, 2.2);
    g.noFill();
    g.stroke(#8E1F2A);
    g.strokeWeight(1.5);
    g.bezier(322, 246, 330, 266, 334, 288, 336, 308);                                              // interventricular groove
    g.stroke(#F2C94C);
    g.strokeWeight(1.3);
    g.bezier(321, 247, 329, 266, 333, 288, 335, 306);
    g.stroke(#E9707A);
    g.strokeWeight(1.2);
    g.bezier(296, 258, 292, 272, 292, 290, 300, 304);
    // thymus in front of the great vessels
    organ(g, thymus, THYMUS, 1.8);
    g.stroke(#C98F5A);
    g.strokeWeight(1.2);
    g.line(300, 192, 300, 224);
    // diaphragm
    g.noFill();
    g.stroke(#B45049);
    g.strokeWeight(4);
    g.beginShape();
    g.curveVertex(212, 326);
    g.curveVertex(212, 326);
    g.curveVertex(234, 318);
    g.curveVertex(260, 315);
    g.curveVertex(284, 318);
    g.curveVertex(300, 324);
    g.curveVertex(318, 319);
    g.curveVertex(345, 316);
    g.curveVertex(370, 318);
    g.curveVertex(390, 326);
    g.curveVertex(390, 326);
    g.endShape();
    // abdominal oesophagus
    g.stroke(D_INK);
    g.strokeWeight(1.4);
    g.fill(lerpColor(D_STOMACH, #000000, 0.08));
    g.beginShape();
    g.vertex(334, 318);
    g.vertex(342, 318);
    g.vertex(352, 330);
    g.vertex(344, 334);
    g.endShape(CLOSE);
    // abdomen
    organ(g, pancreas, PANCREAS, 1.8);
    g.stroke(#C9A040);
    g.strokeWeight(1);
    for (int k = 0; k < 7; k++) {
      float x = 272 + k * 15;
      g.line(x, 398 - k * 1.5, x + 4, 407 - k * 1.5);
    }
    organ(g, spleen, SPLEEN, 2);
    organ(g, stomach, D_STOMACH, 2.2);
    g.noFill();
    g.stroke(#C97575);
    g.strokeWeight(1.2);
    g.bezier(356, 332, 366, 345, 368, 362, 360, 378);                                              // rugae hints
    g.bezier(346, 374, 352, 372, 360, 372, 366, 368);
    organ(g, liver, D_LIVER, 2.4);
    g.stroke(#6E2A20);
    g.strokeWeight(1.5);
    g.bezier(298, 330, 299, 340, 298, 350, 295, 360);                                              // falciform ligament
    g.noStroke();
    g.fill(#B25646, 120);
    blob(g, new float[] { 222, 334, 250, 327, 280, 327, 260, 334, 232, 342 });                   // sheen
    // small intestine coils
    tube(g, duodC, 11, D_GUT);
    g.noStroke();
    g.fill(lerpColor(D_GUT, #000000, 0.22));
    blob(g, smallMass);
    FloatList sp = new FloatList();                                                                 // jejunum + ileum loops
    float[] rows = { 463, 479, 495, 511 };
    for (int r = 0; r < rows.length; r++) {
      boolean ltr = r % 2 == 0;
      for (int k = 0; k <= 5; k++) {
        float x = ltr ? 272 + k * 12.8 : 336 - k * 12.8;
        sp.append(x);
        sp.append(rows[r] + (((ltr ? k : 5 - k) % 2) == 0 ? -2 : 2));
      }
      if (r < rows.length - 1) {
        sp.append(ltr ? 341 : 267);
        sp.append(rows[r] + 7.5);
      }
    }
    sp.append(260);
    sp.append(512);
    sp.append(251);
    sp.append(507);
    tube(g, sp.array(), 9, D_GUT);
    // large intestine frame (haustra)
    tube(g, rectC, 12, lerpColor(D_COLON, #000000, 0.06));          // rectum: under the sigmoid's end, behind the bladder
    tube(g, colonC, 22, D_COLON);
    tube(g, appC, 6.5, D_COLON);
    g.stroke(#B56A50);
    g.strokeWeight(1.4);
    int n = colonC.length / 2;
    for (int i = 3; i < n - 6; i += 3) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = colonC[b * 2] - colonC[a * 2], ty = colonC[b * 2 + 1] - colonC[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float nx = -ty / L * 8, ny = tx / L * 8, cx = colonC[i * 2], cy = colonC[i * 2 + 1];
      g.line(cx - nx, cy - ny, cx + nx, cy + ny);
    }
    organ(g, bladder, BLADDER, 2);
    // head: brain + pituitary
    organ(g, brain, D_BRAIN, 2.2);
    g.noFill();
    g.stroke(D_BRAIN_SH);
    g.strokeWeight(1.6);
    g.line(300, 24, 300, 82);
    for (int s = 0; s < 2; s++) {
      line(g, side(new float[] { 296, 30, 284, 28, 276, 36, 284, 42, 294, 40 }, s));
      line(g, side(new float[] { 263, 42, 272, 48, 270, 58, 280, 60, 290, 54 }, s));
      line(g, side(new float[] { 259, 64, 268, 68, 278, 72, 288, 70, 295, 74 }, s));
      line(g, side(new float[] { 270, 26, 266, 34, 260, 38 }, s));
      line(g, side(new float[] { 280, 78, 272, 80, 264, 76 }, s));
    }
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(D_GLAND);
    g.rect(298.5, 84, 3, 9);
    organ(g, ellPts(300, 98, 7, 5.5, 0), D_GLAND, 1.8);
    // thyroid
    organ(g, new float[] { 283, 150, 291, 148, 296, 156, 304, 156, 309, 148, 317, 150, 320, 160, 316, 170, 308, 170, 300, 165, 292, 170,
      284, 170, 280, 160 }, D_GLAND, 1.8);
    // lymph nodes + vessels
    float[][] nodes = { { 281, 122, 4, 3 }, { 278, 131, 4.5, 3.5 }, { 281, 140, 4, 3 }, { 205, 213, 4.5, 3.5 }, { 213, 219, 5, 4 },
      { 206, 225, 4.5, 3.5 }, { 215, 229, 4, 3.2 }, { 235, 555, 4.5, 3.2 }, { 245, 561, 5, 3.5 }, { 255, 567, 4.5, 3.2 }, { 247, 571, 3.8, 3 } };
    g.noFill();
    g.stroke(#4E9E6C);
    g.strokeWeight(1.2);
    for (int s = 0; s < 2; s++) {
      line(g, side(new float[] { 281, 118, 278, 131, 281, 140, 284, 150 }, s));
      line(g, side(new float[] { 196, 208, 205, 213, 213, 219, 215, 229, 219, 238 }, s));
      line(g, side(new float[] { 228, 550, 235, 555, 245, 561, 255, 567, 264, 574 }, s));
    }
    for (int s = 0; s < 2; s++) for (float[] q : nodes) organ(g, side(ellPts(q[0], q[1], q[2], q[3], 0), s), D_LYMPH, 1.3);
  }

  // =============================================================== helpers (local to this class)
  void organ(PGraphics g, float[] p, int c, float sw) {
    g.noStroke();
    g.fill(lerpColor(c, #000000, 0.16));
    blob(g, p);
    g.fill(c);
    blob(g, inner(p, 3));
    g.fill(255, 255, 255, 45);
    blob(g, shrink(p, 0.55, -0.12));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }

  // a soft tube along a centre line: ink rim, body colour, highlight
  void tube(PGraphics g, float[] c, float w, int col) {
    g.noFill();
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    g.stroke(D_INK);
    g.strokeWeight(w + 3.6);
    line(g, c);
    g.stroke(lerpColor(col, #000000, 0.14));
    g.strokeWeight(w);
    line(g, c);
    g.stroke(col);
    g.strokeWeight(w * 0.62);
    float[] q = new float[c.length];
    for (int i = 0; i < c.length; i += 2) {
      q[i] = c[i] - w * 0.1;
      q[i + 1] = c[i + 1] - w * 0.12;
    }
    line(g, q);
    g.stroke(255, 255, 255, 60);
    g.strokeWeight(w * 0.2);
    for (int i = 0; i < c.length; i += 2) {
      q[i] = c[i] - w * 0.2;
      q[i + 1] = c[i + 1] - w * 0.24;
    }
    line(g, q);
  }

  // scaled copy about the centroid, nudged up-left (a soft highlight)
  float[] shrink(float[] p, float k, float off) {
    float cx = 0, cy = 0, minx = 1e9, maxx = -1e9, miny = 1e9, maxy = -1e9;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      cx += p[i * 2] / n;
      cy += p[i * 2 + 1] / n;
      minx = min(minx, p[i * 2]);
      maxx = max(maxx, p[i * 2]);
      miny = min(miny, p[i * 2 + 1]);
      maxy = max(maxy, p[i * 2 + 1]);
    }
    cx += (maxx - minx) * off;
    cy += (maxy - miny) * off;
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      q[i * 2] = cx + (p[i * 2] - cx) * k;
      q[i * 2 + 1] = cy + (p[i * 2 + 1] - cy) * k;
    }
    return q;
  }

  float[] ellPts(float cx, float cy, float rx, float ry, float a) {
    int n = 18;
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * cos(a) - y * sin(a);
      p[i * 2 + 1] = cy + x * sin(a) + y * cos(a);
    }
    return p;
  }

  float[] mir(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = DIA - p[i];
      q[i + 1] = p[i + 1];
    }
    return q;
  }

  float[] side(float[] p, int s) {
    return s == 0 ? p : mir(p);
  }

  float[] sym(float[] half) {
    int n = half.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    for (int i = n - 2; i >= 1; i--) {
      q.append(DIA - half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    return q.array();
  }

  float[] symClosed(float[] half) {
    int n = half.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    for (int i = n - 1; i >= 0; i--) {
      q.append(DIA - half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    return q.array();
  }

  float[] cr(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] lx = new float[n], ly = new float[n], rx = new float[n], ry = new float[n];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) (n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      lx[i] = c[i * 2] + nx;
      ly[i] = c[i * 2 + 1] + ny;
      rx[i] = c[i * 2] - nx;
      ry[i] = c[i * 2 + 1] - ny;
    }
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(lx[i]);
      q.append(ly[i]);
    }
    float ex = c[(n - 1) * 2] - c[(n - 2) * 2], ey = c[(n - 1) * 2 + 1] - c[(n - 2) * 2 + 1], eL = max(1e-3, sqrt(ex * ex + ey * ey));
    q.append(c[(n - 1) * 2] + ex / eL * w1 * 0.4);
    q.append(c[(n - 1) * 2 + 1] + ey / eL * w1 * 0.4);
    for (int i = n - 1; i >= 0; i--) {
      q.append(rx[i]);
      q.append(ry[i]);
    }
    float sx = c[0] - c[2], sy = c[1] - c[3], sL = max(1e-3, sqrt(sx * sx + sy * sy));
    q.append(c[0] + sx / sL * w0 * 0.4);
    q.append(c[1] + sy / sL * w0 * 0.4);
    return q.array();
  }

  void blob(PGraphics g, float[] p) {
    int n = p.length / 2;
    g.beginShape();
    for (int i = 0; i <= n + 2; i++) {
      int k = (i + n - 1) % n;
      g.curveVertex(p[k * 2], p[k * 2 + 1]);
    }
    g.endShape(CLOSE);
  }

  void line(PGraphics g, float[] p) {
    g.beginShape();
    g.curveVertex(p[0], p[1]);
    for (int i = 0; i < p.length; i += 2) g.curveVertex(p[i], p[i + 1]);
    g.curveVertex(p[p.length - 2], p[p.length - 1]);
    g.endShape();
  }

  float[] inner(float[] p, float d) {
    int n = p.length / 2;
    float area = 0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += p[i * 2] * p[j * 2 + 1] - p[j * 2] * p[i * 2 + 1];
    }
    float sg = area > 0 ? 1 : -1;
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float nx = ty / L * sg, ny = -tx / L * sg;
      float k = d * (0.25 + 0.75 * max(0, nx * 0.55 + ny * 0.83));
      q[i * 2] = p[i * 2] - nx * k;
      q[i * 2 + 1] = p[i * 2 + 1] - ny * k;
    }
    return q;
  }
}


// ======================================================================
// TAB: Dia_Skeleton.pde
// ======================================================================
// Human skeleton, anterior view, anatomical position (palms forward).
// The SUBJECT'S RIGHT side is on the VIEWER'S LEFT. Geometry for the viewer's-left
// limbs is built once in local "bone frames" and mirrored across x = 300, so the
// artwork and the clickable polygons always share exactly the same points.

class SkeletonDiagram extends Diagram {
  final float FIT_K = 0.97, FIT_DY = -1.5;   // even ~20-unit top/bottom margins
  final int CART = #D9E5E7, CART_SH = #B7CBD0;   // cartilage / discs
  final int HOLE = #43373D;                      // orbits, foramina

  // bone frames: { local axis length, x0, y0, x1, y1 } (viewer's-left limb)
  final float[] F_HUM = { 84, 216, 150, 191, 234 };
  final float[] F_FORE = { 70, 191, 236, 167, 306 };
  final float[] F_HAND = { 75, 166, 307, 146, 368 };
  final float[] F_FEM = { 114, 252, 318, 265, 432 };
  final float[] F_LEG = { 94, 265, 438, 270, 532 };
  final float[] F_FOOT = { 56, 270, 533, 263, 586 };

  // shared geometry (L = viewer's left; the right side is mir(...))
  float[] skull, mandible, orbitL, nasal, sternum, manubrium, xiphoid, scapL, coracL, clavL;
  float[] humL, radL, ulnL, femL, patL, tibL, fibL, sacrum, coccyx, hipL, iliacFossaL, obturatorL, symphysis;
  ArrayList<float[]> carpL = new ArrayList<float[]>(), mcL = new ArrayList<float[]>(), phL = new ArrayList<float[]>();
  ArrayList<float[]> tarsL = new ArrayList<float[]>(), mtL = new ArrayList<float[]>(), phfL = new ArrayList<float[]>();
  ArrayList<float[]> ribL = new ArrayList<float[]>(), cartL = new ArrayList<float[]>();
  ArrayList<float[]> ribHitL = new ArrayList<float[]>();

  SkeletonDiagram() {
    super("skeleton", "Human Skeleton (front)");
    build();

    // ---- clickable parts: big / behind first, small / in front last
    add("vertebral_column", "Vertebral Column").poly(
      289, 90, 311, 90, 314, 104, 313, 128, 312, 222, 318, 224, 326, 230, 327, 280, 300, 283, 273, 280, 274, 230, 282, 224, 288, 222, 287, 128, 286, 104)
      .anchor(300, 252);
    add("scapula", "Scapula").poly(scapL).poly(mir(scapL)).poly(coracL).poly(mir(coracL)).anchor(229, 160);
    Part ribs = add("ribs", "Ribs");
    for (float[] r : ribHitL) {
      ribs.poly(r);
      ribs.poly(mir(r));
    }
    ribs.anchor(247, 185);
    add("sternum", "Sternum").poly(sternumHit()).anchor(300, 176);
    add("clavicle", "Clavicle").poly(band(clavL, 11, 10)).poly(mir(band(clavL, 11, 10))).anchor(258, 129);
    add("skull", "Skull").poly(skull).anchor(300, 32);
    add("mandible", "Mandible").poly(mandible).anchor(300, 91);
    add("pelvis", "Pelvis (Hip Bones)").poly(hipL).poly(mir(hipL)).anchor(240, 280);
    add("sacrum", "Sacrum").poly(sacrum).anchor(300, 300);
    add("humerus", "Humerus").poly(humL).poly(mir(humL));
    add("radius", "Radius").poly(radL).poly(mir(radL));
    add("ulna", "Ulna").poly(ulnL).poly(mir(ulnL));
    float[] carpHit = P(new float[] { -18, 0, -6, -2, 6, -1, 13, 2, 15, 9, 13, 17, 4, 19, -6, 19, -17, 18, -20, 9 }, F_HAND);
    float[] mcHit = P(new float[] { -18, 15, 13, 16, 17, 25, 19, 37, 9, 42, 0, 44, -11, 43, -14, 36, -21, 35, -29, 31, -22, 18 }, F_HAND);
    float[] phHit = P(new float[] { -15, 42, -4, 44, 5, 42, 14, 38, 21, 38, 24, 51, 23, 65, 14, 75, 1, 79, -13, 76, -17, 60 }, F_HAND);
    float[] thumbHit = P(new float[] { -21, 34, -28, 31, -35, 44, -37, 57, -29, 60, -25, 47 }, F_HAND);
    add("carpals", "Carpals").poly(carpHit).poly(mir(carpHit));
    add("metacarpals", "Metacarpals").poly(mcHit).poly(mir(mcHit));
    add("phalanges_hand", "Phalanges (Hand)").poly(phHit).poly(thumbHit).poly(mir(phHit)).poly(mir(thumbHit))
      .anchor(P(new float[] { 2, 62 }, F_HAND)[0], P(new float[] { 2, 62 }, F_HAND)[1]);
    add("femur", "Femur").poly(femL).poly(mir(femL));
    add("fibula", "Fibula").poly(fibL).poly(mir(fibL)).anchor(P(new float[] { -16, 50 }, F_LEG)[0], P(new float[] { -16, 50 }, F_LEG)[1]);
    add("tibia", "Tibia").poly(tibL).poly(mir(tibL));
    add("patella", "Patella").poly(patL).poly(mir(patL));
    float[] tarsHit = P(new float[] { -15, -5, 0, -4, 10, -3, 14, 7, 13, 23, 3, 23, -7, 22, -15, 19, -18, 8 }, F_FOOT);
    float[] mtHit = P(new float[] { -15, 19, -7, 22, 3, 23, 13, 23, 16, 31, 16, 40, 8, 42, 0, 42, -8, 40, -15, 37, -21, 34 }, F_FOOT);
    float[] phfHit = P(new float[] { -21, 34, -15, 37, -8, 40, 0, 42, 8, 42, 16, 40, 18, 49, 17, 58, 9, 60, 0, 60, -8, 57, -16, 53, -22, 46 }, F_FOOT);
    add("tarsals", "Tarsals").poly(tarsHit).poly(mir(tarsHit));
    add("metatarsals", "Metatarsals").poly(mtHit).poly(mir(mtHit));
    add("phalanges_foot", "Phalanges (Foot)").poly(phfHit).poly(mir(phfHit));
    fitParts();
  }

  // =============================================================== geometry
  void build() {
    // ---- skull (cranium + face, maxilla down to the upper teeth)
    skull = sym(new float[] { 300, 13, 286, 15, 274, 20, 266, 29, 263, 40, 264, 52, 266, 58, 264, 63, 268, 68, 274, 72, 279, 77, 285, 81, 300, 81 });
    mandible = new float[] { 268, 61, 266, 70, 268, 80, 273, 88, 285, 94, 300, 97, 315, 94, 327, 88, 332, 80, 334, 70, 332, 61,
      326, 62, 323, 72, 317, 79, 308, 82, 300, 82, 292, 82, 283, 79, 277, 72, 274, 62 };
    orbitL = new float[] { 276, 42, 283, 38, 292, 39, 297, 45, 297, 53, 292, 58, 282, 58, 276, 54, 274, 47 };
    nasal = sym(new float[] { 300, 58, 296, 61, 294, 67, 296, 72, 300, 73 });

    // ---- sternum
    manubrium = sym(new float[] { 300, 130, 295, 129, 289, 127, 286, 131, 287, 138, 290, 146, 291, 149, 300, 149 });
    sternum = sym(new float[] { 300, 149, 290, 149, 289, 160, 289, 175, 288, 190, 290, 203, 293, 207, 300, 207 });
    xiphoid = sym(new float[] { 300, 207, 295, 207, 296, 214, 299, 221, 300, 222 });

    // ---- clavicle (centre line) and scapula
    clavL = cr(new float[] { 291, 130, 280, 132, 266, 130, 250, 127, 235, 125, 221, 127, 210, 132 }, 4);
    scapL = new float[] { 203, 134, 210, 128, 222, 125, 240, 123, 257, 122, 271, 124, 274, 133, 271, 152, 265, 176, 255, 199, 243, 215,
      236, 214, 228, 201, 222, 185, 218, 169, 218, 161, 223, 156, 226, 147, 223, 141, 214, 139, 206, 139 };
    coracL = new float[] { 236, 129, 243, 133, 241, 140, 234, 146, 227, 148, 225, 143, 231, 139, 233, 134 };

    // ---- ribs: lateral apex (dx, y), front end of the bone (dx, y), cartilage end (dx, y), dx from the midline
    float[] aDx = { 36, 48, 56, 61, 64, 66, 67, 66, 64, 61, 57, 50 };
    float[] aY = { 127, 136, 147, 158, 170, 182, 194, 206, 218, 229, 238, 246 };
    float[] cDx = { 24, 30, 35, 38, 40, 42, 43, 46, 51, 55, 54, 46 };
    float[] cY = { 139, 152, 165, 178, 191, 204, 217, 230, 241, 251, 255, 256 };
    float[] sDx = { 12, 12, 11, 11, 11, 10, 9, 29, 39, 47 };
    float[] sY = { 136, 149, 161, 173, 184, 195, 205, 220, 231, 242 };
    for (int i = 0; i < 12; i++) {
      float ax = 300 - aDx[i], cx = 300 - cDx[i];
      float[] front = cr(new float[] { ax + 3.5, aY[i] - 5, ax, aY[i] + 1, (ax + cx) / 2 - 2, (aY[i] + cY[i]) / 2 + 3.5, cx, cY[i] }, 6);
      ribL.add(front);
      float w = i < 2 ? 6.5 : (i > 9 ? 5.5 : 7);
      ribHitL.add(band(front, w + 1, w + 1));
      if (i < 10) {
        float sx = 300 - sDx[i];
        float[] cart;
        if (i < 7) cart = cr(new float[] { cx + 1, cY[i], (cx + sx) / 2, (cY[i] + sY[i]) / 2 + (i > 3 ? 3 : 1), sx, sY[i] }, 5);
        else cart = cr(new float[] { cx + 1, cY[i], (cx + sx) / 2 + 2, (cY[i] + sY[i]) / 2 + 1, sx, sY[i] }, 5);
        cartL.add(cart);
        ribHitL.add(band(cart, 9, 9));
      }
    }

    // ---- limbs (local bone frames)
    humL = P(new float[] { -3, -11, 5, -11, 11, -6, 13, 1, 11, 8, 6, 13, 4, 20, 4, 40, 5, 60, 8, 70, 13, 77, 11, 83, 5, 86, 0, 85,
      -5, 87, -10, 84, -13, 78, -10, 70, -6, 55, -6, 35, -7, 20, -11, 12, -13, 4, -11, -5 }, F_HUM);
    radL = P(new float[] { -12, 2, -4, 2, -4, 7, -5, 10, -3, 15, -5, 24, -6, 40, -4, 56, -1, 64, 1, 70, -1, 74, -8, 75, -15, 74, -16, 68,
      -14, 58, -12, 40, -10, 24, -9, 13, -11, 9, -13, 6 }, F_FORE);
    ulnL = P(new float[] { -1, -2, 4, -7, 10, -5, 12, 2, 9, 9, 6, 15, 5, 30, 5, 50, 5, 62, 7, 68, 8, 73, 6, 77, 2, 76, 1, 70, 1, 60,
      0, 45, -1, 30, -2, 18, -3, 10, -2, 4 }, F_FORE);
    float[][] carp = { { -10, 4, 5, 3.6 }, { -1.5, 3.5, 4.2, 3.5 }, { 6.5, 4.5, 3.6, 3.4 }, { -12.5, 12, 4.2, 3.8 }, { -5.5, 12.5, 3.4, 3.6 },
      { 1, 12.5, 3.6, 4.8 }, { 8, 11.5, 4, 4.2 }, { 10.5, 7, 2.6, 2.6 } };
    for (float[] c : carp) carpL.add(P(ell(c[0], c[1], c[2], c[3]), F_HAND));
    float[][] mc = { { -15, 15, -24, 31, 5, 3.4 }, { -6, 17, -8.5, 40, 4.6, 3 }, { 0, 18, 0.5, 41, 4.6, 3 }, { 6, 17, 7.5, 39, 4.4, 2.9 },
      { 11, 15, 14.5, 36, 4.2, 2.8 } };
    for (float[] m : mc) mcL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_HAND));
    float[][] ph = { { -25, 33, -29.5, 45, 4.6, 3.2 }, { -30, 47, -32, 55, 4, 3 },
      { -9, 42, -10.5, 56, 4, 2.8 }, { -10.7, 58, -11.5, 65, 3.6, 2.6 }, { -11.6, 67, -12, 72, 3.2, 2.4 },
      { 0.6, 43, 1, 58, 4.2, 2.9 }, { 1, 60, 1.2, 68, 3.7, 2.7 }, { 1.2, 70, 1.3, 75, 3.3, 2.5 },
      { 8, 41, 9.5, 55, 4, 2.8 }, { 9.7, 57, 10.5, 65, 3.6, 2.6 }, { 10.6, 67, 11, 72, 3.2, 2.4 },
      { 15, 38, 17.5, 49, 3.6, 2.6 }, { 17.7, 51, 18.7, 57, 3.3, 2.4 }, { 18.8, 59, 19.3, 64, 3, 2.2 } };
    for (float[] m : ph) phL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_HAND));

    femL = P(new float[] { -3, -10, 4, -9.5, 9, -5, 10.5, 1, 8, 7, 3, 10.5, -2, 13, -4, 18, -2, 23, -3, 28, -7, 31, -6, 50, -3, 72, 0, 88,
      4, 99, 9, 105, 11, 111, 8, 117, 2, 118, -2, 114, -6, 118, -12, 117, -15, 111, -14, 104, -11, 97, -13, 84, -18, 60, -22, 40,
      -25, 26, -28, 14, -28, 5, -24, -1, -19, 1, -13, -3, -8, -7 }, F_FEM);
    patL = P(ell(-2, 103, 8.5, 10.5), F_FEM);
    tibL = P(new float[] { -14, 2, -6, 0, 3, 0, 12, 1, 14, 6, 11, 13, 6, 22, 4, 40, 3, 60, 4, 78, 6, 86, 8, 94, 5, 99, 0, 97, -6, 96,
      -8, 90, -6, 80, -5, 60, -5, 40, -6, 24, -10, 15, -14, 9 }, F_LEG);
    fibL = P(new float[] { -21, 6, -17, 3, -13, 5, -13, 10, -16, 14, -15, 40, -13, 70, -11, 86, -9, 96, -12, 101, -16, 98, -16, 86, -18, 70,
      -20, 40, -20, 15, -22, 10 }, F_LEG);
    float[][] tars = { { -9, 1, 5, 5 }, { 0, 3, 9, 5.5 }, { 5, 11, 6, 3.6 }, { -7, 13, 5.5, 5 }, { 8.5, 18.5, 3.8, 4 }, { 3, 18.5, 2.8, 3.5 },
      { -2.5, 18.5, 3, 3.6 } };
    for (float[] c : tars) tarsL.add(P(ell(c[0], c[1], c[2], c[3]), F_FOOT));
    float[][] mt = { { 9, 22.5, 12, 38, 6.4, 4.6 }, { 3, 22.5, 4, 40, 4.4, 3 }, { -2, 22.5, -3, 39, 4.3, 3 }, { -6, 21, -9, 37, 4.2, 2.9 },
      { -10, 19, -15, 34, 4.6, 3 } };
    for (float[] m : mt) mtL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_FOOT));
    float[][] phf = { { 12.5, 40.5, 13.5, 48, 5.8, 4.4 }, { 13.6, 50, 14, 56, 5.2, 4 },
      { 4.2, 42, 4.7, 48.5, 3.8, 2.8 }, { 4.8, 50.5, 5, 54, 3.4, 2.6 }, { 5, 55.6, 5.1, 58, 3.1, 2.5 },
      { -3.1, 41, -3.6, 47, 3.7, 2.7 }, { -3.7, 49, -3.9, 52.5, 3.3, 2.5 }, { -4, 54.1, -4, 56.5, 3, 2.4 },
      { -9.3, 39, -10.6, 45, 3.6, 2.6 }, { -10.7, 47, -11.2, 50.5, 3.2, 2.4 }, { -11.3, 52.1, -11.5, 54.5, 2.9, 2.3 },
      { -15.5, 36, -17.2, 41, 3.4, 2.5 }, { -17.4, 43, -18, 46, 3, 2.3 }, { -18.1, 47.6, -18.4, 50, 2.8, 2.2 } };
    for (float[] m : phf) phfL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_FOOT));

    // ---- pelvis
    hipL = new float[] { 280, 272, 271, 265, 258, 262, 245, 263, 234, 269, 227, 280, 224, 291, 227, 297, 229, 302, 235, 310, 237, 324,
      240, 338, 243, 350, 249, 358, 257, 360, 264, 357, 273, 351, 285, 346, 296, 343, 297, 327, 288, 323, 276, 321, 266, 316, 264, 305,
      269, 293, 277, 284, 281, 277 };
    iliacFossaL = new float[] { 277, 274, 262, 268, 248, 268, 238, 275, 234, 286, 238, 296, 250, 303, 263, 305, 268, 293, 276, 283 };
    obturatorL = ell(266, 339, 11, 7, 0.95);
    symphysis = new float[] { 296, 328, 304, 328, 304, 343, 296, 343 };
    sacrum = new float[] { 275, 283, 288, 280, 300, 279, 312, 280, 325, 283, 323, 291, 317, 301, 309, 310, 303, 317, 297, 317, 291, 310,
      283, 301, 277, 291 };
    coccyx = new float[] { 296.8, 316.5, 303.2, 316.5, 302.8, 319.5, 301.4, 322, 298.6, 322, 297.2, 319.5 };
  }

  float[] sternumHit() {
    return sym(new float[] { 300, 127, 290, 125, 284, 130, 286, 140, 289, 149, 287, 165, 287, 190, 289, 205, 294, 210, 297, 223, 300, 224 });
  }

  // ---- final placement in the 600 box: art and hit shapes get the same scale/offset (about the centre)
  void fitParts() {
    for (Part p : parts) {
      for (int i = 0; i < p.shapes.size(); i++) {
        float[] a = p.shapes.get(i), q = new float[a.length];      // copy: the art still uses the original arrays
        for (int j = 0; j < a.length; j += 2) {
          q[j] = 300 + (a[j] - 300) * FIT_K;
          q[j + 1] = 300 + (a[j + 1] - 300) * FIT_K + FIT_DY;
        }
        p.shapes.set(i, q);
      }
      if (p.ax >= 0) {
        p.ax = 300 + (p.ax - 300) * FIT_K;
        p.ay = 300 + (p.ay - 300) * FIT_K + FIT_DY;
      }
    }
  }

  void drawArt(PGraphics g) {
    g.pushMatrix();
    g.translate(300 * (1 - FIT_K), 300 * (1 - FIT_K) + FIT_DY);
    g.scale(FIT_K);
    drawFigure(g);
    g.popMatrix();
  }

  // =============================================================== art
  void drawFigure(PGraphics g) {
    // scapulae (behind the rib cage)
    for (int s = 0; s < 2; s++) {
      bone(g, side(scapL, s), lerpColor(D_BONE, D_BONE_SH, 0.2), D_BONE_SH, 2, 3);
      g.stroke(D_BONE_SH);
      g.strokeWeight(1.6);
      g.noFill();
      line(g, side(new float[] { 226, 132, 248, 129, 268, 131 }, s));
    }
    drawSpine(g);
    // ribs + costal cartilage
    for (int s = 0; s < 2; s++) {
      for (int i = 0; i < cartL.size(); i++) bone(g, side(band(cartL.get(i), 6, 5.5), s), CART, CART_SH, 1.6, 1.4);
      for (int i = ribL.size() - 1; i >= 0; i--) {
        float w = i < 2 ? 6.5 : (i > 9 ? 5.5 : 7);
        bone(g, side(band(ribL.get(i), w * 0.75, w), s), D_BONE, D_BONE_SH, 1.5, 1.8);
      }
    }
    // sternum
    bone(g, sternum, D_BONE, D_BONE_SH, 2, 2);
    bone(g, manubrium, D_BONE, D_BONE_SH, 2, 2);
    bone(g, xiphoid, D_BONE, D_BONE_SH, 1.8, 1.2);
    g.stroke(D_BONE_SH);
    g.strokeWeight(1.2);
    for (int k = 0; k < 3; k++) g.line(292, 163 + k * 14, 308, 163 + k * 14);     // fused sternebrae
    // pelvis + sacrum
    bone(g, sacrum, D_BONE, D_BONE_SH, 2, 3);
    bone(g, coccyx, D_BONE, D_BONE_SH, 1.5, 1);
    g.noStroke();
    g.fill(HOLE);
    for (int k = 0; k < 4; k++) {
      float y = 288 + k * 6.8, dx = 9.3 - k * 1.7, r = 2.5 - k * 0.3;
      g.ellipse(300 - dx, y, r * 2, r * 1.6);
      g.ellipse(300 + dx, y, r * 2, r * 1.6);
    }
    g.stroke(D_BONE_SH);
    g.strokeWeight(1.2);
    for (int k = 0; k < 3; k++) {
      float y = 291.5 + k * 6.8, dx = 8 - k * 1.8;
      g.line(300 - dx, y, 300 + dx, y);
    }
    for (int s = 0; s < 2; s++) {
      bone(g, side(hipL, s), D_BONE, D_BONE_SH, 2, 3);
      g.noStroke();
      g.fill(D_BONE_SH, 150);
      blob(g, side(iliacFossaL, s));
      g.fill(HOLE);
      g.stroke(D_INK);
      g.strokeWeight(1.6);
      blob(g, side(obturatorL, s));
    }
    bone(g, symphysis, CART, CART_SH, 1.5, 1);
    // legs
    for (int s = 0; s < 2; s++) {
      bone(g, side(femL, s), D_BONE, D_BONE_SH, 2, 3);
      shaftLine(g, side(P(new float[] { -15, 35, -9, 70, -5, 90 }, F_FEM), s));
      bone(g, side(fibL, s), D_BONE, D_BONE_SH, 1.8, 2);
      bone(g, side(tibL, s), D_BONE, D_BONE_SH, 2, 3);
      shaftLine(g, side(P(new float[] { 0, 25, -1, 50, 0, 80 }, F_LEG), s));
      g.stroke(D_BONE_SH);
      g.strokeWeight(1.3);
      g.noFill();
      line(g, side(P(new float[] { -4, 14, -1, 19, 2, 14 }, F_LEG), s));   // tibial tuberosity
      bone(g, side(patL, s), D_BONE, D_BONE_SH, 2, 2.2);
      for (float[] b : tarsL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.3, 1);
      for (float[] b : mtL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.3, 0.9);
      for (float[] b : phfL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.2, 0.7);
    }
    // arms
    for (int s = 0; s < 2; s++) {
      bone(g, side(humL, s), D_BONE, D_BONE_SH, 2, 3);
      shaftLine(g, side(P(new float[] { -3, 22, -2, 45, -1, 65 }, F_HUM), s));
      bone(g, side(ulnL, s), D_BONE, D_BONE_SH, 1.8, 2);
      bone(g, side(radL, s), D_BONE, D_BONE_SH, 1.8, 2);
      for (float[] b : carpL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.2, 0.9);
      for (float[] b : mcL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.2, 0.8);
      for (float[] b : phL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.1, 0.6);
    }
    // clavicles + coracoid (in front of the shoulder joint)
    for (int s = 0; s < 2; s++) {
      bone(g, side(coracL, s), lerpColor(D_BONE, D_BONE_SH, 0.2), D_BONE_SH, 1.6, 1.2);
      bone(g, side(band(clavL, 7.5, 6.5), s), D_BONE, D_BONE_SH, 2, 2);
    }
    drawSkull(g);
  }

  void drawSpine(PGraphics g) {
    // cervical C2-C7 (y 86..128), thoracic T1-T12 (128..222), lumbar L1-L5 (222..282)
    g.strokeWeight(1.4);
    for (int i = 0; i < 6; i++) {
      float y = 86 + i * 7, w = 8.5 + i * 0.4;
      g.stroke(D_INK);
      g.fill(D_BONE_SH);
      g.rect(300 - w - 5, y + 1.5, (w + 5) * 2, 3.2, 1.5);                 // transverse processes
      g.fill(D_BONE);
      g.rect(300 - w, y, w * 2, 5.4, 1.8);
      g.fill(CART);
      g.rect(300 - w + 1, y + 5.4, w * 2 - 2, 1.6);
    }
    for (int i = 0; i < 12; i++) {
      float y = 128 + i * 7.8, w = 9.5 + i * 0.25;
      g.stroke(D_INK);
      g.fill(D_BONE_SH);
      g.rect(300 - w - 6, y + 1.5, (w + 6) * 2, 3, 1.5);
      g.fill(D_BONE);
      g.rect(300 - w, y, w * 2, 6.2, 2);
      g.fill(CART);
      g.rect(300 - w + 1, y + 6.2, w * 2 - 2, 1.6);
    }
    for (int i = 0; i < 5; i++) {
      float y = 222.5 + i * 12, w = 12.5 + i * 0.8, tp = 22 + (i == 2 ? 3 : 0) - (i == 4 ? 2 : 0);
      g.stroke(D_INK);
      g.fill(D_BONE_SH);
      g.beginShape();
      g.vertex(300 - tp, y + 3);
      g.vertex(300 + tp, y + 3);
      g.vertex(300 + tp - 1, y + 7);
      g.vertex(300 - tp + 1, y + 7);
      g.endShape(CLOSE);
      g.fill(D_BONE);
      g.beginShape();
      g.vertex(300 - w, y);
      g.bezierVertex(300 - w / 2, y + 1.5, 300 + w / 2, y + 1.5, 300 + w, y);
      g.vertex(300 + w - 1, y + 9.3);
      g.bezierVertex(300 + w / 2, y + 8, 300 - w / 2, y + 8, 300 - w + 1, y + 9.3);
      g.endShape(CLOSE);
      g.noStroke();
      g.fill(D_BONE_SH, 150);
      g.rect(300 + w * 0.35, y + 1.5, w * 0.55, 7);
      g.stroke(D_INK);
      g.fill(CART);
      if (i < 4) g.rect(300 - w + 1.5, y + 9.4, w * 2 - 3, 2.4, 1);
    }
  }

  void drawSkull(PGraphics g) {
    // mandible behind the cheekbones, then the cranium
    bone(g, mandible, D_BONE, D_BONE_SH, 2, 2.5);
    g.stroke(D_INK);
    g.strokeWeight(1);
    g.fill(#FBF7EC);
    for (int i = 0; i < 8; i++) {                      // lower teeth
      float x = 286 + i * 3.6;
      g.rect(x, 81.5 + abs(i - 3.5) * 0.35, 3.4, 4.6, 1.2);
    }
    bone(g, skull, D_BONE, D_BONE_SH, 2.2, 3.5);
    g.noStroke();
    g.fill(D_BONE_SH, 140);
    blob(g, new float[] { 266, 58, 271, 56, 276, 60, 274, 66, 268, 66 });  // cheek shadows
    blob(g, mir(new float[] { 266, 58, 271, 56, 276, 60, 274, 66, 268, 66 }));
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(HOLE);
    blob(g, orbitL);
    blob(g, mir(orbitL));
    blob(g, nasal);
    g.noStroke();
    g.fill(#6B5A60);
    g.ellipse(287, 50, 8, 6);
    g.ellipse(313, 50, 8, 6);
    g.stroke(D_INK);
    g.strokeWeight(1);
    g.fill(#FBF7EC);
    for (int i = 0; i < 8; i++) {                      // upper teeth
      float x = 285.5 + i * 3.6;
      g.rect(x, 76.2 - abs(i - 3.5) * 0.3, 3.4, 5, 1.2);
    }
    g.noFill();
    g.stroke(D_BONE_SH);
    g.strokeWeight(1.3);
    g.bezier(268, 30, 276, 23, 286, 21, 293, 21);       // temporal lines
    g.bezier(332, 30, 324, 23, 314, 21, 307, 21);
    g.bezier(298, 61, 299, 50, 301, 50, 302, 61);
  }

  // =============================================================== helpers (local to this class)
  float[] mir(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = DIA - p[i];
      q[i + 1] = p[i + 1];
    }
    return q;
  }

  float[] side(float[] p, int s) {
    return s == 0 ? p : mir(p);
  }

  // half outline (midline -> viewer's left side -> midline) to a full symmetric outline
  float[] sym(float[] half) {
    int n = half.length / 2;
    float[] q = new float[(2 * n - 2) * 2];
    int k = 0;
    for (int i = 0; i < n; i++) {
      q[k++] = half[i * 2];
      q[k++] = half[i * 2 + 1];
    }
    for (int i = n - 2; i >= 1; i--) {
      q[k++] = DIA - half[i * 2];
      q[k++] = half[i * 2 + 1];
    }
    return q;
  }

  // local bone frame -> diagram units
  float[] P(float[] loc, float[] f) {
    float dx = f[3] - f[1], dy = f[4] - f[2], len = sqrt(dx * dx + dy * dy), s = len / f[0];
    float ux = dx / len, uy = dy / len, px = uy, py = -ux;
    float[] q = new float[loc.length];
    for (int i = 0; i < loc.length; i += 2) {
      q[i] = f[1] + (loc[i + 1] * ux + loc[i] * px) * s;
      q[i + 1] = f[2] + (loc[i + 1] * uy + loc[i] * py) * s;
    }
    return q;
  }

  float[] ell(float cx, float cy, float rx, float ry) {
    return ell(cx, cy, rx, ry, 0);
  }

  float[] ell(float cx, float cy, float rx, float ry, float a) {
    int n = 16;
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * cos(a) - y * sin(a);
      p[i * 2 + 1] = cy + x * sin(a) + y * cos(a);
    }
    return p;
  }

  // small long bone (phalanx, metacarpal): knobby ends, slim waist
  float[] stick(float x0, float y0, float x1, float y1, float wEnd, float wMid) {
    float dx = x1 - x0, dy = y1 - y0, L = sqrt(dx * dx + dy * dy);
    float ux = dx / L, uy = dy / L, nx = -uy, ny = ux, r = wEnd / 2;
    FloatList q = new FloatList();
    float[] ts = { 0.22, 0.5, 0.78 };
    float[] ws = { r * 0.92, wMid / 2, r * 0.92 };
    for (int i = 0; i < 3; i++) {
      q.append(x0 + dx * ts[i] + nx * ws[i]);
      q.append(y0 + dy * ts[i] + ny * ws[i]);
    }
    for (int i = 0; i <= 4; i++) {                       // far cap
      float a = HALF_PI - PI * i / 4;
      q.append(x1 - ux * r * 0.2 + (nx * sin(a) + ux * cos(a)) * r);
      q.append(y1 - uy * r * 0.2 + (ny * sin(a) + uy * cos(a)) * r);
    }
    for (int i = 2; i >= 0; i--) {
      q.append(x0 + dx * ts[i] - nx * ws[i]);
      q.append(y0 + dy * ts[i] - ny * ws[i]);
    }
    for (int i = 0; i <= 4; i++) {                       // near cap
      float a = -HALF_PI - PI * i / 4;
      q.append(x0 + ux * r * 0.2 + (nx * sin(a) + ux * cos(a)) * r);
      q.append(y0 + uy * r * 0.2 + (ny * sin(a) + uy * cos(a)) * r);
    }
    return q.array();
  }

  // Catmull-Rom path through points (open), sampled
  float[] cr(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(g_cr(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(g_cr(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float g_cr(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  // thick band around an open centre line, width w0 -> w1, rounded ends
  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] lx = new float[n], ly = new float[n], rx = new float[n], ry = new float[n];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) (n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      lx[i] = c[i * 2] + nx;
      ly[i] = c[i * 2 + 1] + ny;
      rx[i] = c[i * 2] - nx;
      ry[i] = c[i * 2 + 1] - ny;
    }
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(lx[i]);
      q.append(ly[i]);
    }
    float ex = c[(n - 1) * 2] - c[(n - 2) * 2], ey = c[(n - 1) * 2 + 1] - c[(n - 2) * 2 + 1], eL = max(1e-3, sqrt(ex * ex + ey * ey));
    q.append(c[(n - 1) * 2] + ex / eL * w1 * 0.4);
    q.append(c[(n - 1) * 2 + 1] + ey / eL * w1 * 0.4);
    for (int i = n - 1; i >= 0; i--) {
      q.append(rx[i]);
      q.append(ry[i]);
    }
    float sx = c[0] - c[2], sy = c[1] - c[3], sL = max(1e-3, sqrt(sx * sx + sy * sy));
    q.append(c[0] + sx / sL * w0 * 0.4);
    q.append(c[1] + sy / sL * w0 * 0.4);
    return q.array();
  }

  // smooth closed curve through the points
  void blob(PGraphics g, float[] p) {
    int n = p.length / 2;
    g.beginShape();
    for (int i = 0; i <= n + 2; i++) {
      int k = (i + n - 1) % n;
      g.curveVertex(p[k * 2], p[k * 2 + 1]);
    }
    g.endShape(CLOSE);
  }

  void line(PGraphics g, float[] p) {
    g.beginShape();
    g.curveVertex(p[0], p[1]);
    for (int i = 0; i < p.length; i += 2) g.curveVertex(p[i], p[i + 1]);
    g.curveVertex(p[p.length - 2], p[p.length - 1]);
    g.endShape();
  }

  void shaftLine(PGraphics g, float[] p) {
    g.noFill();
    g.stroke(255, 255, 255, 150);
    g.strokeWeight(1.6);
    line(g, p);
  }

  // shape pushed inward, more on the lower-right (light from the upper left)
  float[] inner(float[] p, float d) {
    int n = p.length / 2;
    float area = 0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += p[i * 2] * p[j * 2 + 1] - p[j * 2] * p[i * 2 + 1];
    }
    float sg = area > 0 ? 1 : -1;
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float nx = ty / L * sg, ny = -tx / L * sg;           // outward normal
      float k = d * (0.25 + 0.75 * max(0, nx * 0.55 + ny * 0.83));
      q[i * 2] = p[i * 2] - nx * k;
      q[i * 2 + 1] = p[i * 2 + 1] - ny * k;
    }
    return q;
  }

  // a bone: shadow fill, lighter inner fill, ink outline
  void bone(PGraphics g, float[] p, int fillC, int shadeC, float sw, float shade) {
    g.noStroke();
    g.fill(shadeC);
    blob(g, p);
    g.fill(fillC);
    blob(g, inner(p, shade));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }
}


// ======================================================================
// TAB: Diagram.pde
// ======================================================================
// Anatomy diagrams: procedural artwork + clickable parts.
//
// Every diagram lives in its own DIA x DIA box (600 x 600 "diagram units",
// origin top-left, y down). drawArt() paints the artwork once into a cached
// image. Parts are polygons in the same units: they are what the mouse hits
// and what lights up (hover / correct / wrong / lesson highlight).
// Parts added LATER sit ON TOP: add containers first, small details last.

final float DIA = 600;

// shared palette for a consistent textbook-cartoon look on a light panel
final int D_INK = #1E1C28;          // outlines
final int D_BONE = #F1E6CC, D_BONE_SH = #D3BF96;
final int D_MUSCLE = #C9544B, D_MUSCLE_LT = #E68579, D_TENDON = #EDE3D0;
final int D_SKIN = #F2D2B6, D_SKIN_SH = #D9AE8C;
final int D_ARTERY = #D63A3A, D_VEIN = #3F6FD1, D_HEART = #C7343E;
final int D_NERVE = #F2C94C, D_MYELIN = #F6E7B0;
final int D_LIVER = #8E3B2E, D_STOMACH = #E89A97, D_GUT = #F0B19D, D_COLON = #D98C6F;
final int D_LUNG = #F09CAA, D_KIDNEY = #A3473C, D_GLAND = #9B7FD1, D_LYMPH = #6CC08A;
final int D_CYTO = #CFE8F2, D_NUCLEUS = #8E7CC3, D_MITO = #F08A5D, D_ER = #6FB3D9, D_GOLGI = #F2B84B;
final int D_BRAIN = #F2B6B9, D_BRAIN_SH = #D98F97;

HashMap<String, Diagram> DIAGRAMS = new HashMap<String, Diagram>();
final String[] DIAGRAM_ORDER = { "cell", "skeleton", "muscles", "neuron", "brain", "heart", "lungs", "digestive", "nephron", "organ_map" };

void registerDiagrams() {
  addDiagram(new CellDiagram());
  addDiagram(new SkeletonDiagram());
  addDiagram(new MusclesDiagram());
  addDiagram(new NeuronDiagram());
  addDiagram(new BrainDiagram());
  addDiagram(new HeartDiagram());
  addDiagram(new LungsDiagram());
  addDiagram(new DigestiveDiagram());
  addDiagram(new NephronDiagram());
  addDiagram(new OrganMapDiagram());
}

void addDiagram(Diagram d) {
  DIAGRAMS.put(d.id, d);
}

Diagram diagram(String id) {
  return DIAGRAMS.get(id);
}

// ---------------------------------------------------------------- one clickable part
class Part {
  String id, name;
  ArrayList<float[]> shapes = new ArrayList<float[]>();   // polygons: x0, y0, x1, y1, ... in diagram units
  float ax = -1, ay = -1;                                 // where a label's leader line points

  Part(String id, String name) {
    this.id = id;
    this.name = name;
  }

  Part poly(float... xy) {
    shapes.add(xy);
    return this;
  }

  Part ellipse(float cx, float cy, float rx, float ry) {
    return poly(ellipsePts(cx, cy, rx, ry, 0, 28));
  }

  // ellipse rotated by angle (radians)
  Part ellipse(float cx, float cy, float rx, float ry, float angle) {
    return poly(ellipsePts(cx, cy, rx, ry, angle, 28));
  }

  Part rect(float x, float y, float w, float h) {
    return poly(x, y, x + w, y, x + w, y + h, x, y + h);
  }

  // a thick segment from (x0, y0) to (x1, y1), e.g. a long bone or a muscle belly
  Part bar(float x0, float y0, float x1, float y1, float thick) {
    float dx = x1 - x0, dy = y1 - y0, L = max(1e-3, sqrt(dx * dx + dy * dy));
    float nx = -dy / L * thick / 2, ny = dx / L * thick / 2;
    return poly(x0 + nx, y0 + ny, x1 + nx, y1 + ny, x1 - nx, y1 - ny, x0 - nx, y0 - ny);
  }

  Part anchor(float x, float y) {
    ax = x;
    ay = y;
    return this;
  }

  boolean contains(float x, float y) {
    for (float[] s : shapes) if (insidePoly(s, x, y)) return true;
    return false;
  }

  // label anchor: explicit, or the centre of the biggest shape
  float[] anchorPt() {
    if (ax >= 0) return new float[] { ax, ay };
    float best = -1, bx = 0, by = 0;
    for (float[] s : shapes) {
      float minx = 1e9, maxx = -1e9, miny = 1e9, maxy = -1e9;
      for (int i = 0; i < s.length; i += 2) {
        minx = min(minx, s[i]);
        maxx = max(maxx, s[i]);
        miny = min(miny, s[i + 1]);
        maxy = max(maxy, s[i + 1]);
      }
      float a = (maxx - minx) * (maxy - miny);
      if (a > best) {
        best = a;
        bx = (minx + maxx) / 2;
        by = (miny + maxy) / 2;
      }
    }
    return new float[] { bx, by };
  }
}

float[] ellipsePts(float cx, float cy, float rx, float ry, float ang, int n) {
  float[] p = new float[n * 2];
  float ca = cos(ang), sa = sin(ang);
  for (int i = 0; i < n; i++) {
    float t = TWO_PI * i / n;
    float x = cos(t) * rx, y = sin(t) * ry;
    p[i * 2] = cx + x * ca - y * sa;
    p[i * 2 + 1] = cy + x * sa + y * ca;
  }
  return p;
}

boolean insidePoly(float[] p, float x, float y) {
  boolean in = false;
  int n = p.length / 2;
  for (int i = 0, j = n - 1; i < n; j = i++) {
    float xi = p[i * 2], yi = p[i * 2 + 1], xj = p[j * 2], yj = p[j * 2 + 1];
    if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) in = !in;
  }
  return in;
}

// ---------------------------------------------------------------- a diagram
abstract class Diagram {
  String id, title;
  ArrayList<Part> parts = new ArrayList<Part>();
  PImage art, thumb;

  Diagram(String id, String title) {
    this.id = id;
    this.title = title;
  }

  Part add(String id, String name) {
    Part p = new Part(id, name);
    parts.add(p);
    return p;
  }

  Part part(String pid) {
    for (Part p : parts) if (p.id.equals(pid)) return p;
    return null;
  }

  // paint the artwork into g, in diagram units (0..DIA); g's background is transparent
  abstract void drawArt(PGraphics g);

  // the cached artwork (drawn once at high resolution)
  PImage art() {
    if (art == null) {
      int px = 1200;
      PGraphics g = createGraphics(px, px);
      g.beginDraw();
      g.clear();
      g.scale(px / DIA);
      g.strokeJoin(ROUND);
      g.strokeCap(ROUND);
      drawArt(g);
      g.endDraw();
      art = g;
    }
    return art;
  }

  PImage thumb() {
    if (thumb == null) {
      PImage a = art().copy();
      a.resize(160, 160);
      thumb = a;
    }
    return thumb;
  }

  // the top-most part under a point (diagram units)
  Part hit(float ux, float uy) {
    for (int i = parts.size() - 1; i >= 0; i--) if (parts.get(i).contains(ux, uy)) return parts.get(i);
    return null;
  }
}


// ======================================================================
// TAB: DiagramView.pde
// ======================================================================
// Draws a diagram on a "whiteboard" panel and turns the mouse into part hits.
// Marks (part -> colour) light parts up; hover outlines the part under the mouse.

class DiagramView {
  Diagram d;
  float x, y, size;
  boolean hoverOn = true, labelsOn;
  Part hover;
  HashMap<String, Integer> marks = new HashMap<String, Integer>();
  String pulse;                 // a part that pulses (lesson focus)
  int pulseCol = C_GOLD;

  void set(Diagram d, float x, float y, float size) {
    if (this.d != d) marks.clear();
    this.d = d;
    this.x = x;
    this.y = y;
    this.size = size;
  }

  float s() {
    return size / DIA;
  }

  boolean mouseIn() {
    return mouseX >= x && mouseX <= x + size && mouseY >= y && mouseY <= y + size;
  }

  void update() {
    hover = null;
    if (d != null && hoverOn && mouseIn()) hover = d.hit((mouseX - x) / s(), (mouseY - y) / s());
  }

  Part hitMouse() {
    if (d == null || !mouseIn()) return null;
    return d.hit((mouseX - x) / s(), (mouseY - y) / s());
  }

  void draw() {
    if (d == null) return;
    float pad = 14;
    noStroke();
    fill(0, 110);
    rect(x - pad + 6, y - pad + 8, size + pad * 2, size + pad * 2, 18);
    fill(C_PAPER);
    stroke(C_PAPER_EDGE);
    strokeWeight(3);
    rect(x - pad, y - pad, size + pad * 2, size + pad * 2, 18);
    // faint grid like a lab notebook
    stroke(#E6DDC6);
    strokeWeight(1);
    for (float gx = x + 30; gx < x + size; gx += 30) line(gx, y - pad + 4, gx, y + size + pad - 4);
    for (float gy = y + 30; gy < y + size; gy += 30) line(x - pad + 4, gy, x + size + pad - 4, gy);
    image(d.art(), x, y, size, size);
    for (String pid : marks.keySet()) {
      Part p = d.part(pid);
      if (p != null) drawPart(p, marks.get(pid), 120, 3.5);
    }
    if (pulse != null) {
      Part p = d.part(pulse);
      if (p != null) drawPart(p, pulseCol, 70 + 70 * (0.5 + 0.5 * sin(T * 5)), 3);
    }
    if (hover != null && !marks.containsKey(hover.id)) drawPart(hover, C_BLUE, 55, 2.5);
    if (labelsOn) drawAllLabels();
  }

  void drawPart(Part p, int c, float fillA, float sw) {
    float s = s();
    for (int pass = 0; pass < 2; pass++) {
      if (pass == 0) {
        noFill();
        stroke(c, 70);
        strokeWeight(sw + 6);
      } else {
        fill(c, fillA);
        stroke(c);
        strokeWeight(sw);
      }
      for (float[] sh : p.shapes) {
        beginShape();
        for (int i = 0; i < sh.length; i += 2) vertex(x + sh[i] * s, y + sh[i + 1] * s);
        endShape(CLOSE);
      }
    }
  }

  // a name tag next to the part, with a leader line
  void tag(Part p, String text, int c) {
    tag(p, text, c, false);
  }

  void tag(Part p, String text, int c, boolean below) {
    float[] a = p.anchorPt();
    float ax = x + a[0] * s(), ay = y + a[1] * s();
    textFont(fBodyB);
    float tw = textWidth(text) + 22;
    float tx = constrain(ax - tw / 2, x - 10, x + size + 10 - tw), ty = below ? ay + 26 : ay - 58;
    if (ty < y - 6) ty = ay + 26;
    stroke(c);
    strokeWeight(2.5);
    line(ax, ay, tx + tw / 2, ty + (ty < ay ? 34 : 0));
    noStroke();
    fill(c);
    ellipse(ax, ay, 9, 9);
    fill(#141824, 235);
    stroke(c);
    strokeWeight(2);
    rect(tx, ty, tw, 34, 10);
    fill(C_TEXT);
    textAlign(CENTER, CENTER);
    text(text, tx + tw / 2, ty + 16);
  }

  // every part labelled, in two columns beside the board (study mode)
  void drawAllLabels() {
    ArrayList<Part> left = new ArrayList<Part>(), right = new ArrayList<Part>();
    for (Part p : d.parts) {
      if (p.anchorPt()[0] < DIA / 2) left.add(p);
      else right.add(p);
    }
    drawLabelColumn(left, true);
    drawLabelColumn(right, false);
  }

  void drawLabelColumn(ArrayList<Part> ps, boolean leftSide) {
    // sort by anchor y, then spread so tags don't overlap
    java.util.Collections.sort(ps, new java.util.Comparator<Part>() {
      public int compare(Part a, Part b) {
        return Float.compare(a.anchorPt()[1], b.anchorPt()[1]);
      }
    });
    textFont(fSmall);
    float gap = 22, prev = -1e9;
    float[] ys = new float[ps.size()];
    for (int i = 0; i < ps.size(); i++) {
      float want = y + ps.get(i).anchorPt()[1] * s();
      ys[i] = max(want, prev + gap);
      prev = ys[i];
    }
    float over = prev - (y + size);
    if (over > 0) for (int i = 0; i < ys.length; i++) ys[i] -= over;
    for (int i = 0; i < ps.size(); i++) {
      Part p = ps.get(i);
      float[] a = p.anchorPt();
      float ax = x + a[0] * s(), ay = y + a[1] * s();
      float lx = leftSide ? x - 24 : x + size + 24;
      boolean hot = hover == p;
      stroke(hot ? C_GOLD : #8B7E5E, hot ? 255 : 170);
      strokeWeight(hot ? 2 : 1.2);
      line(ax, ay, lx + (leftSide ? 6 : -6), ys[i]);
      noStroke();
      fill(hot ? C_GOLD : #5A4E36);
      ellipse(ax, ay, 5, 5);
      fill(hot ? C_GOLD : C_TEXT);
      textAlign(leftSide ? RIGHT : LEFT, CENTER);
      text(partName(d.id, p.id), lx, ys[i]);
    }
  }
}


// ======================================================================
// TAB: Model.pde
// ======================================================================
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


// ======================================================================
// TAB: Portal.pde
// ======================================================================
// The green portal: a swirling ellipse of goo (intro, scene wipes, flourishes).

final int[] PORTAL_RINGS = { #145E18, #23862A, #3DBB3C, #7CFF6B, #C8FF9C, #74E46A, #2F9C31, #176A1B, #0C3F0F };

void drawPortal(float cx, float cy, float rx, float ry, float spin, float a) {
  if (rx < 1) return;
  noStroke();
  // glow
  for (int i = 7; i >= 1; i--) {
    fill(120, 255, 90, a * 0.045);
    ellipse(cx, cy, rx * 2 * (1 + i * 0.07), ry * 2 * (1 + i * 0.07));
  }
  // wobbling rim
  fill(PORTAL_RINGS[0], a);
  beginShape();
  for (int i = 0; i < 48; i++) {
    float t = TWO_PI * i / 48;
    float w = 1 + 0.045 * sin(t * 5 + spin * 2) + 0.03 * sin(t * 9 - spin * 3);
    vertex(cx + cos(t) * rx * w, cy + sin(t) * ry * w);
  }
  endShape(CLOSE);
  // liquid layers, each a little off-centre so it churns
  for (int i = 1; i < PORTAL_RINGS.length; i++) {
    float k = 1 - i / (float) PORTAL_RINGS.length;
    float ox = sin(spin * 1.3 + i) * rx * 0.03, oy = cos(spin * 1.1 + i * 2) * ry * 0.03;
    fill(PORTAL_RINGS[i], a);
    ellipse(cx + ox, cy + oy, rx * 2 * k, ry * 2 * k);
  }
  // spiral arms
  noFill();
  for (int arm = 0; arm < 6; arm++) {
    stroke(arm % 2 == 0 ? #D8FFB8 : #2E8B30, a * (arm % 2 == 0 ? 0.75 : 0.6));
    strokeWeight(max(1, rx * 0.025));
    beginShape();
    for (float t = 0.06; t <= 0.95; t += 0.03) {
      float ang = spin * 1.6 + arm * TWO_PI / 6 + t * 5.5;
      vertex(cx + cos(ang) * rx * t, cy + sin(ang) * ry * t);
    }
    endShape();
  }
  noStroke();
  fill(#E9FFD6, a * 0.8);
  ellipse(cx, cy, rx * 0.16, ry * 0.16);
}

// a portal that opens / closes over time (used in the intro)
class PortalFx {
  float x, y, rx, ry, open, target;

  PortalFx(float x, float y, float rx, float ry) {
    this.x = x;
    this.y = y;
    this.rx = rx;
    this.ry = ry;
  }

  void update(float dt) {
    open += (target - open) * min(1, dt * 6);
  }

  void draw() {
    float k = open < 0.01 ? 0 : open * (1 + 0.04 * sin(T * 9));
    drawPortal(x, y, rx * k, ry * k, T * 2.2, 255);
  }
}


// ======================================================================
// TAB: Progress.pde
// ======================================================================
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
  boolean inPile(String qid) {
    return data.getJSONObject("mistakes").hasKey(qid);
  }

  // true when this answer took the question out of the pile
  boolean hit(String qid, boolean review) {
    JSONObject m = data.getJSONObject("mistakes");
    if (!m.hasKey(qid) || !review) return false;
    int box = m.getInt(qid) + 1;
    if (box >= 2) {
      m.remove(qid);
      return true;
    }
    m.setInt(qid, box);
    return false;
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


// ======================================================================
// TAB: Rick.pde
// ======================================================================
// Rick: his face (sober / drunk / burping), his whole drunk body for the
// intro, and the cartoon speech box with a typewriter that actually burps
// when it reaches *burp*.

final int DOCK_CORNER = 0, DOCK_POINT = 1, DOCK_HIDDEN = 2;   // HIDDEN: a scene draws the text itself

class Rick {
  PImage face, faceTalk, drunk, drunkTalk, burpFace;
  String text = "";
  float age;                     // seconds since the line started
  float cps = 42;                // typewriter speed (characters per second)
  boolean showing;
  int lastSoundChar = -1;
  boolean drunkMode;             // half-closed eyes (intro / when you do badly)
  float burpT = -9;              // when the last burp happened (for the face)
  float hicT = -9;               // when the last hiccup happened (for a little hop)
  // where the box goes
  int dock = DOCK_CORNER;
  float px, py;                  // DOCK_POINT: the point the tail points at (e.g. his mouth)
  float boxW = 540;
  int lastInputMs;
  int idleCount;

  Rick() {
    face = makeRickFace(false, false, false);
    faceTalk = makeRickFace(true, false, false);
    drunk = makeRickFace(false, true, false);
    drunkTalk = makeRickFace(true, true, false);
    burpFace = makeRickFace(true, true, true);
    lastInputMs = millis();
  }

  void say(String line) {
    text = line;
    age = 0;
    showing = true;
    lastSoundChar = -1;
  }

  void quiet() {
    showing = false;
  }

  int typed() {
    return min(text.length(), (int) (age * cps));
  }

  boolean done() {
    return !showing || typed() >= text.length();
  }

  boolean talking() {
    return showing && !done() && (int) (T * 9) % 2 == 0;
  }

  // finish the line instantly; true if it was still typing
  boolean finish() {
    if (showing && !done()) {
      age = text.length() / cps + 0.01;
      return true;
    }
    return false;
  }

  String shownText() {
    return showing ? text.substring(0, typed()) : "";
  }

  void clickSkip() {
    lastInputMs = millis();
  }

  boolean burping() {
    return T - burpT < 0.7;
  }

  void burp(boolean big) {
    burpT = T;
    sfx.play(big ? sfx.bigBurp : sfx.burp, big ? 0.9 : 0.7, random(0.92, 1.08));
  }

  void update(float dt) {
    if (!showing) return;
    int before = typed();
    age += dt;
    // corner box: let it go once he's said it and you've had time to read it
    if (dock == DOCK_CORNER && age > text.length() / cps + 7 + text.length() / 25.0) showing = false;
    int now = typed();
    // sounds as the text appears: a soft blip per word, a real burp at *burp*
    for (int i = max(before, lastSoundChar + 1); i < now; i++) {
      lastSoundChar = i;
      if (text.startsWith("*burp*", i) || text.startsWith("*BURP*", i) || text.startsWith("*BUUURP*", i)) burp(text.startsWith("*BUUURP*", i));
      else if (text.startsWith("*hic*", i)) {
        sfx.play(sfx.hic, 0.7, random(0.95, 1.1));
        hicT = T;
      }
      else if (text.charAt(i) == ' ' && random(1) < 0.5) sfx.play(sfx.blip, 0.5, random(0.8, 1.3));
    }
  }

  // idle nag (the user's favourite line). Scenes that allow it call this.
  void idleCheck() {
    if (millis() - lastInputMs > 40000 && done()) {
      idleCount++;
      say(idleCount % 2 == 1 ? "Dazing off? Lazy a**." : "Dazing off? Lazy a**. The body has 206 bones and not one of yours is moving.");
      lastInputMs = millis();
    }
  }

  PImage currentFace() {
    if (burping()) return burpFace;
    boolean t = talking();
    if (drunkMode) return t ? drunkTalk : drunk;
    return t ? faceTalk : face;
  }

  // ---------------------------------------------------------------- the speech box
  void drawBox() {
    if (!showing || dock == DOCK_HIDDEN) return;
    float pop = min(1, age / 0.18);
    pop = 1 - pow(1 - pop, 3);
    textFont(fRick);
    String shown = text.substring(0, typed());
    ArrayList<String> lines = wrapText(text, boxW - 44);       // wrap the full line so words don't jump
    float lh = 28;
    float w = boxW, h = lines.size() * lh + 62;
    float bx, by, tx, ty;
    if (dock == DOCK_CORNER) {
      float cx = W - 102, cy = H - 104;
      // portrait
      pushMatrix();
      translate(cx, cy + sin(T * 3) * 2);
      scale(pop);
      noStroke();
      fill(0, 120);
      ellipse(4, 6, 172, 172);
      fill(#13233A);
      stroke(C_GREEN);
      strokeWeight(3);
      ellipse(0, 0, 166, 166);
      imageMode(CENTER);
      image(currentFace(), 0, 4, 158, 158);
      imageMode(CORNER);
      popMatrix();
      bx = cx - 100 - w;
      by = H - 22 - h;
      tx = cx - 78;
      ty = by + h * 0.62;
    } else {
      // beside the point (his mouth), on whichever side has room
      tx = px;
      ty = py;
      bx = px + 80;
      if (bx + w > W - 16) bx = px - 80 - w;
      by = constrain(py - h * 0.7, 12, H - h - 12);
    }
    boolean tailRight = tx > bx + w / 2;
    float ex = tailRight ? bx + w - 8 : bx + 8;
    float ya = constrain(ty - 22, by + 16, by + h - 52), yb = ya + 34;
    pushMatrix();
    translate(tx, ty);
    scale(pop);
    translate(-tx, -ty);
    noStroke();
    fill(0, 110);
    rect(bx + 6, by + 8, w, h, 22);
    fill(#FFFCF2);
    stroke(#1E1C28);
    strokeWeight(4);
    triangle(ex, ya, ex, yb, tx, ty);
    rect(bx, by, w, h, 22);
    noStroke();
    float ix = tailRight ? -3 : 3;
    triangle(ex + ix, ya + 3, ex + ix, yb - 3, tx + (tailRight ? -7 : 7), ty);
    textFont(fH2);
    fill(#2E8B3A);
    textAlign(LEFT, TOP);
    text("RICK:", bx + 22, by + 12);
    textFont(fRick);
    int left = shown.length();
    for (int i = 0; i < lines.size() && left > 0; i++) {
      String ln = lines.get(i);
      String part = ln.substring(0, min(ln.length(), left));
      left -= ln.length() + 1;
      richLine(part, bx + 22, by + 46 + i * lh, #1E1C28, #2E9A30);
    }
    popMatrix();
  }

  // ---------------------------------------------------------------- whole Rick (intro / big moments)
  // feet at (x, y); sway = lean in radians; flask = arm raise 0..1; tilt = head tilt
  void drawBody(float x, float y, float s, float sway, float flask, float tilt) {
    pushMatrix();
    float hop = T - hicT < 0.3 ? sin((T - hicT) / 0.3 * PI) * 16 : 0;
    translate(x, y - hop);
    scale(s);
    rotate(sway);
    strokeJoin(ROUND);
    strokeCap(ROUND);
    stroke(#1E1C28);
    strokeWeight(3);
    // shoes + legs (wobbly knees)
    float knee = sin(T * 2.3) * 4;
    fill(#6E4F33);
    quad(-30, -128, -6, -128, -8 + knee, -10, -30 + knee, -10);
    quad(6, -128, 30, -128, 30 - knee, -10, 8 - knee, -10);
    fill(#2A2A30);
    ellipse(-21 + knee, -6, 40, 16);
    ellipse(21 - knee, -6, 40, 16);
    // shirt (light blue) under the open coat
    fill(#A8D8EA);
    quad(-24, -252, 24, -252, 26, -126, -26, -126);
    // lab coat: two halves, open at the front
    fill(#F4F7FA);
    beginShape();
    vertex(-24, -254);
    vertex(-52, -246);
    vertex(-60, -170);
    vertex(-62, -96);
    vertex(-22, -92);
    vertex(-16, -170);
    endShape(CLOSE);
    beginShape();
    vertex(24, -254);
    vertex(52, -246);
    vertex(60, -170);
    vertex(62, -96);
    vertex(22, -92);
    vertex(16, -170);
    endShape(CLOSE);
    // coat shading + pocket
    noFill();
    stroke(#C5D0DA);
    strokeWeight(2.5);
    line(-44, -230, -50, -110);
    line(44, -230, 50, -110);
    stroke(#1E1C28);
    strokeWeight(2);
    rect(28, -150, 20, 16, 3);
    // lapels
    strokeWeight(3);
    line(-24, -254, -12, -214);
    line(24, -254, 12, -214);
    // left arm (hangs, swings a bit)
    float swing = sin(T * 1.9) * 0.12;
    pushMatrix();
    translate(-50, -240);
    rotate(0.12 + swing);
    fill(#F4F7FA);
    quad(-12, 0, 12, 0, 10, 96, -12, 96);
    fill(#F1D6BA);
    ellipse(-1, 104, 22, 24);
    popMatrix();
    // right arm with the flask
    pushMatrix();
    translate(50, -240);
    rotate(-0.12 - flask * 2.2 + swing * 0.5);
    fill(#F4F7FA);
    quad(-12, 0, 12, 0, 12, 96, -10, 96);
    fill(#F1D6BA);
    ellipse(1, 104, 22, 24);
    // flask
    pushMatrix();
    translate(4, 112);
    rotate(flask * 2.0);
    fill(#B9C2CC);
    rect(-11, -14, 22, 30, 6);
    fill(#8C96A3);
    rect(-5, -22, 10, 9, 2);
    noStroke();
    fill(255, 140);
    rect(-7, -10, 4, 20, 2);
    stroke(#1E1C28);
    popMatrix();
    popMatrix();
    // head
    pushMatrix();
    translate(0, -250);
    rotate(tilt);
    imageMode(CORNER);
    float hs = 1.15;
    image(currentFace(), -128 * hs, -236 * hs, 256 * hs, 256 * hs);
    popMatrix();
    popMatrix();
  }
}

// ====================================================================
// Rick's head, drawn with shapes (same design as A Piece Of Cake / Portal Lab),
// plus drunk eyelids and a burp mouth.

PImage makeRickFace(boolean talking, boolean drunk, boolean burp) {
  PGraphics g = createGraphics(256, 256);
  g.beginDraw();
  g.clear();
  g.translate(128, 232);
  g.scale(1.02);
  g.strokeJoin(ROUND);
  g.strokeCap(ROUND);
  drawRickHead(g, talking, drunk, burp);
  g.endDraw();
  return g.get();
}

void drawRickHead(PGraphics g, boolean talking, boolean drunk, boolean burp) {
  int SKIN = #F1D6BA, SKIN_SH = #D9B596, HAIR = #AEDDF5, HAIR_SH = #86BEDF, HAIR_DK = #5E93B8, INK = #1E1C28;
  g.scale(1.2);
  float cx = 0, cy = -50;
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(HAIR);
  float[] tipR = { 58, 72, 80, 78, 84, 80, 84, 78, 80, 72, 58 };
  float[] curl = { -0.16, -0.14, -0.12, -0.08, -0.04, 0, 0.04, 0.08, 0.12, 0.14, 0.16 };
  int n = tipR.length;
  float a0 = radians(166), a1 = radians(374);
  float step = (a1 - a0) / (n - 1);
  g.beginShape();
  g.vertex(cx + cos(a0 - step * 0.6) * 30, cy + sin(a0 - step * 0.6) * 42);
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float vr = 47;
    float va = a - step * 0.5, vb = a + step * 0.5;
    float tx = cx + cos(a + curl[i]) * tipR[i];
    float ty = cy + sin(a + curl[i]) * tipR[i] * 1.04;
    if (i == 0) g.vertex(cx + cos(va) * vr * 0.8, cy + sin(va) * vr);
    g.quadraticVertex(cx + cos(a - step * 0.12) * (vr + 10), cy + sin(a - step * 0.12) * (vr + 10) * 1.04, tx, ty);
    g.quadraticVertex(cx + cos(a + step * 0.2) * (vr + 8), cy + sin(a + step * 0.2) * (vr + 8) * 1.04,
                      cx + cos(vb) * vr, cy + sin(vb) * vr * 1.04);
  }
  g.vertex(cx + cos(a1 + step * 0.6) * 30, cy + sin(a1 + step * 0.6) * 42);
  g.endShape(CLOSE);
  g.stroke(HAIR_SH);
  g.noFill();
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float r1 = tipR[i] * 0.84;
    g.line(cx + cos(a) * 44, cy + sin(a) * 44 * 1.04, cx + cos(a + curl[i] * 0.8) * r1, cy + sin(a + curl[i] * 0.8) * r1 * 1.04);
  }
  // ears + neck
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(SKIN);
  g.ellipse(-31, -46, 13, 20);
  g.ellipse(31, -46, 13, 20);
  g.rect(-8.5, -12, 17, 14);
  // face
  g.strokeWeight(2.4);
  float[][] face = { { 0, -94 }, { 20, -91 }, { 31, -76 }, { 33, -56 }, { 31, -36 }, { 26, -18 }, { 14, -6 }, { 0, -3 },
    { -14, -6 }, { -26, -18 }, { -31, -36 }, { -33, -56 }, { -31, -76 }, { -20, -91 } };
  g.beginShape();
  for (int i = 0; i < face.length + 3; i++) g.curveVertex(face[i % face.length][0], face[i % face.length][1]);
  g.endShape();
  // drunk flush
  if (drunk) {
    g.noStroke();
    g.fill(#E8848A, 120);
    g.ellipse(-20, -30, 16, 9);
    g.ellipse(20, -30, 16, 9);
    g.fill(#E8848A, 160);
    g.ellipse(2, -31, 9, 7);
  }
  // hair cap
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(HAIR);
  g.beginShape();
  g.vertex(-32, -64);
  g.bezierVertex(-32, -88, -18, -100, 0, -100);
  g.bezierVertex(18, -100, 32, -88, 32, -64);
  g.vertex(26, -76);
  g.vertex(19, -71);
  g.vertex(12, -79);
  g.vertex(4, -73);
  g.vertex(-4, -80);
  g.vertex(-12, -73);
  g.vertex(-19, -79);
  g.vertex(-26, -72);
  g.endShape(CLOSE);
  // unibrow
  g.noFill();
  g.stroke(HAIR_DK);
  g.strokeWeight(5);
  g.beginShape();
  if (burp) {
    g.vertex(-26, -60);
    g.vertex(-18, -63.5);
    g.vertex(-11, -61);
    g.vertex(-4, -62.5);
    g.vertex(4, -62.5);
    g.vertex(11, -61);
    g.vertex(18, -63.5);
    g.vertex(26, -60);
  } else {
    g.vertex(-26, -57);
    g.vertex(-18, -61.5);
    g.vertex(-11, -58);
    g.vertex(-4, -60.5);
    g.vertex(4, -60.5);
    g.vertex(11, -58);
    g.vertex(18, -61.5);
    g.vertex(26, -57);
  }
  g.endShape();
  // eyes
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(255);
  g.ellipse(-11, -46, 22, 22);
  g.ellipse(11, -46, 22, 22);
  g.noStroke();
  g.fill(INK);
  if (burp) {
    // squeezed shut
    g.stroke(INK);
    g.strokeWeight(2.4);
    g.noFill();
    g.line(-19, -46, -4, -46);
    g.line(4, -46, 19, -46);
  } else if (drunk) {
    // pupils drifting apart, eyelids at half mast
    g.ellipse(-12.5, -42.5, 4.6, 4.6);
    g.ellipse(12.5, -43.5, 4.6, 4.6);
    g.fill(SKIN);
    g.stroke(INK);
    g.strokeWeight(2.2);
    g.arc(-11, -46, 22, 22, PI, TWO_PI, CHORD);
    g.arc(11, -46, 22, 22, PI, TWO_PI, CHORD);
  } else {
    g.ellipse(-8.5, -45, 4.6, 4.6);
    g.ellipse(9.5, -46.5, 4.6, 4.6);
  }
  g.noFill();
  g.stroke(SKIN_SH);
  g.strokeWeight(1.6);
  g.arc(-11, -40, 22, 16, radians(25), radians(155));
  g.arc(11, -40, 22, 16, radians(25), radians(155));
  // nose
  g.stroke(INK);
  g.strokeWeight(2);
  g.beginShape();
  g.vertex(1, -36);
  g.quadraticVertex(7, -30, 1.5, -27.5);
  g.endShape();
  // mouth
  g.strokeWeight(2.4);
  if (burp) {
    g.fill(#4A1E26);
    g.ellipse(0, -15, 26, 18);
    g.noStroke();
    g.fill(#D7616B);
    g.ellipse(1, -10, 14, 6);
  } else if (!talking) {
    g.beginShape();
    g.vertex(-18, -19);
    g.quadraticVertex(-9, -16, -1, -19.5);
    g.quadraticVertex(8, -16, 18, -19.5);
    g.endShape();
    if (drunk) {
      // a little drool
      g.noStroke();
      g.fill(#BFE6FF, 220);
      g.ellipse(14, -14, 4, 7);
    }
  } else {
    g.fill(#4A1E26);
    g.beginShape();
    g.vertex(-17, -22);
    g.quadraticVertex(0, -19, 17, -22.5);
    g.quadraticVertex(14, -6, 0, -6);
    g.quadraticVertex(-14, -6, -17, -22);
    g.endShape(CLOSE);
    g.noStroke();
    g.fill(255);
    g.rect(-12, -21.5, 24, 4, 2);
    g.fill(#D7616B);
    g.ellipse(2, -9.5, 14, 6);
  }
}


// ======================================================================
// TAB: RickLines.pde
// ======================================================================
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


// ======================================================================
// TAB: SceneExplore.pde
// ======================================================================
// Study mode: pick a diagram, hover parts to learn them, L for all labels,
// Q for a quick "click the part" drill on that diagram.

final HashMap<String, String> DIAGRAM_TOPIC = new HashMap<String, String>();

// one generated "click the X" question per diagram part (study drills / review pile)
void makeDrillQuestions() {
  String[][] owner = { { "cell", "cells" }, { "skeleton", "bones" }, { "muscles", "muscles" }, { "neuron", "nervous" }, { "brain", "nervous" },
    { "heart", "heart" }, { "lungs", "lungs" }, { "digestive", "digestion" }, { "nephron", "kidneys" }, { "organ_map", "hormones" } };
  for (String[] o : owner) DIAGRAM_TOPIC.put(o[0], o[1]);
  for (String id : DIAGRAM_ORDER) {
    Diagram d = diagram(id);
    if (d == null) continue;
    for (Part p : d.parts) {
      Question k = new Question();
      k.id = "drill-" + id + "-" + p.id;
      k.type = "label";
      k.diagram = id;
      k.part = p.id;
      PartInfo pi = PART_INFO.get(id + ":" + p.id);
      k.q = "Click the " + partName(id, p.id) + ".";
      k.explain = pi != null ? pi.desc : "That's the " + partName(id, p.id) + ".";
      k.rick = pi != null ? pi.rick : "";
      k.topic = TOPICS.get(DIAGRAM_TOPIC.get(id));
      k.level = 0;
      QUESTIONS.put(k.id, k);
    }
  }
}

class ExploreScene extends Scene {
  String diaId;
  DiagramView view = new DiagramView();
  Part pinned, shown;
  float infoT;

  ExploreScene(String diaId) {
    this.diaId = diaId == null ? DIAGRAM_ORDER[0] : diaId;
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.say(pick(EXPLORE_ENTER));
    for (int i = 0; i < DIAGRAM_ORDER.length; i++) {
      Diagram d = diagram(DIAGRAM_ORDER[i]);
      Button b = button("dia:" + DIAGRAM_ORDER[i], shortTitle(d), 24 + i * 123, 70, 116, 44).colour(C_BLUE);
      b.font = fSmall;
    }
    button("back", "< BACK", 24, 652, 126, 52).key("B");
    button("labels", "LABELS (L)", 162, 652, 196, 52).key("L").colour(C_GOLD);
    button("drill", "QUIZ ME (Q)", 370, 652, 196, 52).key("Q").colour(C_GREEN);
    select(diaId);
  }

  String shortTitle(Diagram d) {
    String[] s = { "Cell", "Skeleton", "Muscles", "Neuron", "Brain", "Heart", "Lungs", "Gut", "Nephron", "Organs" };
    for (int i = 0; i < DIAGRAM_ORDER.length; i++) if (DIAGRAM_ORDER[i].equals(d.id)) return s[i];
    return d.id;
  }

  void select(String id) {
    diaId = id;
    view.set(diagram(id), 250, 140, 480);
    view.labelsOn = view.labelsOn;
    pinned = null;
    shown = null;
  }

  void update(float dt) {
    view.update();
    if (rick.showing && (view.mouseIn() || view.labelsOn)) rick.quiet();   // his corner box sits on the board's lower right
    Part s = view.hover != null ? view.hover : pinned;
    if (s != shown) {
      shown = s;
      infoT = 0;
    }
    infoT += dt;
    for (Button b : buttons) {
      if (b.id.startsWith("dia:")) b.col = b.id.equals("dia:" + diaId) ? C_GREEN : C_BLUE;
      if (b.id.equals("labels")) b.label = view.labelsOn ? "LABELS: ON (L)" : "LABELS: OFF (L)";
    }
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    levelBadge(24, 24, 0);
    textFont(fH2);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text("STUDY DIAGRAMS  -  " + view.d.title, 110, 22);
    schmeckles(W - 20, 14);
    view.marks.clear();
    if (pinned != null) view.marks.put(pinned.id, C_GOLD);
    view.draw();
    drawInfo();
    drawButtons();
    rick.drawBox();
  }

  void drawInfo() {
    float x = 960, y = 140, w = 300, h = 400;
    panel(x, y, w, h, C_PANEL, shown != null ? C_GOLD : C_EDGE, 18);
    textAlign(LEFT, TOP);
    if (shown == null) {
      textFont(fBodyB);
      fill(C_TEXT);
      text("Hover a part.", x + 20, y + 20);
      textFont(fSmall);
      fill(C_DIM);
      textBlock("Click to pin it. L shows every label. QUIZ ME drills you on this diagram (no level, no clock).\n\n" + view.d.parts.size() + " parts on this one.", x + 20, y + 56, w - 40, 22);
      return;
    }
    PartInfo pi = PART_INFO.get(diaId + ":" + shown.id);
    textFont(fH2);
    fill(C_GOLD);
    float cy = y + 18 + textBlock(partName(diaId, shown.id), x + 20, y + 18, w - 40, 30) + 10;
    textFont(fSmall);
    fill(#DCE6F8);
    if (pi != null) {
      textFont(fBody);
      textSize(18);
      cy += textBlock(pi.desc, x + 20, cy, w - 40, 24) + 14;
      textFont(fRick);
      textSize(17);
      fill(#9BE36A);
      textBlock("RICK: " + pi.rick, x + 20, cy, w - 40, 22);
    } else {
      textBlock("(No notes for this part yet.)", x + 20, cy, w - 40, 22);
    }
  }

  void mouse() {
    Part p = view.hitMouse();
    if (p != null) {
      pinned = pinned == p ? null : p;
      sfx.play(sfx.blip, 0.6);
    }
  }

  void clicked(Button b) {
    if (b.id.startsWith("dia:")) select(b.id.substring(4));
    if (b.id.equals("back")) back();
    if (b.id.equals("labels")) view.labelsOn = !view.labelsOn;
    if (b.id.equals("drill")) drill();
  }

  void drill() {
    ArrayList<Question> qs = new ArrayList<Question>();
    for (Part p : view.d.parts) {
      Question q = QUESTIONS.get("drill-" + diaId + "-" + p.id);
      if (q != null) qs.add(q);
    }
    java.util.Collections.shuffle(qs);
    if (qs.size() > 10) qs = new ArrayList<Question>(qs.subList(0, 10));
    go(new QuizScene("DRILL: " + view.d.title.toUpperCase(), qs, 0, "explore", false));
  }

  void key(char k, int code) {
    if (code == LEFT || code == RIGHT) {
      int i = java.util.Arrays.asList(DIAGRAM_ORDER).indexOf(diaId);
      i = (i + (code == RIGHT ? 1 : DIAGRAM_ORDER.length - 1)) % DIAGRAM_ORDER.length;
      select(DIAGRAM_ORDER[i]);
    }
  }

  void back() {
    go(studyFromLevel > 0 ? new TopicScene(studyFromLevel) : new DifficultyScene());
  }
}


// ======================================================================
// TAB: SceneIntro.pde
// ======================================================================
// Scene 1: a lecture hall in some dimension. A portal tears open, Rick tumbles
// out drunk, burps, rambles, and drags you into today's lesson.

class IntroScene extends Scene {
  PortalFx portal = new PortalFx(980, 360, 120, 190);
  float t;                    // scene time
  float rx = 980, ry = 560;   // Rick's feet
  float spin;                 // tumbling out of the portal
  float sway, flask, tilt;
  int line = -1;
  float lineT;                // time since the current line finished typing
  boolean leaving;
  ArrayList<float[]> gas = new ArrayList<float[]>();    // burp cloud puffs: x, y, vx, vy, life, size
  String[] LINES = {
    "*burp* Wh- where... OH. The med school dimension. Great. Just great.",
    "I was in the middle of a very important science- *hic* -bender. Very important. There was a Gazorpazorp.",
    "But apparently YOU need to learn how the human body works. Ugh. *burp* Fine.",
    "It's meat, bones and electricity, genius. Meat. Bones. Electri- *BUUURP*",
    "Today's lesson... choose difficulty, idiot."
  };

  void enter() {
    rick.drunkMode = true;
    rick.dock = DOCK_POINT;
    rick.boxW = 560;
  }

  void update(float dt) {
    t += dt;
    portal.update(dt);
    prebuildDiagrams();
    if (t - dt <= 0.3 && t > 0.3) sfx.play(sfx.portal, 0.8);
    portal.target = t > 0.3 && t < 3.2 ? 1 : 0;
    // tumble out of the portal, land, stagger to the middle
    if (t < 1.3) {
      rx = 980;
      ry = 560;
      spin = 0;
    } else if (t < 2.1) {
      float k = (t - 1.3) / 0.8;
      rx = lerp(980, 640, k);
      ry = 560 - sin(k * PI) * 120;
      spin = -k * TWO_PI;
      if (t - dt < 1.3) sfx.play(sfx.whoosh, 0.6);
    } else {
      if (spin != 0) {
        spin = 0;
        sfx.play(sfx.thud, 0.8);
      }
      rx = 640 + sin(t * 0.9) * 26;   // can't stand still
      ry = 560;
    }
    sway = t > 2.1 ? sin(t * 1.7) * 0.07 + sin(t * 3.1) * 0.025 : 0;
    // drinking between lines
    flask = 0;
    float drinkT = t - 2.5;
    if (drinkT > 0 && drinkT < 1.4) {
      flask = sin(min(1, drinkT / 1.4) * PI);
      if (drinkT - dt <= 0.2 && drinkT > 0.2) sfx.play(sfx.slurp, 0.6);
    }
    tilt = flask * -0.35 + (rick.burping() ? -0.25 : 0) + sway * 0.6;
    // the dialogue
    if (line < 0 && t > 3.6) nextLine();
    if (line >= 0 && rick.done()) lineT += dt;
    if (line >= 0 && line < LINES.length - 1 && rick.done() && lineT > 2.4) nextLine();
    if (line == LINES.length - 1 && rick.done() && lineT > 1.6 && !leaving) finish();
    // burp gas
    if (rick.burping() && frameCount % 2 == 0) {
      float mx = rx + 18 + sin(sway) * 300, my = ry - 300;
      gas.add(new float[] { mx, my, random(30, 140), random(-90, -20), 1.4, random(18, 40) });
    }
    for (int i = gas.size() - 1; i >= 0; i--) {
      float[] g = gas.get(i);
      g[0] += g[2] * dt;
      g[1] += g[3] * dt;
      g[4] -= dt;
      g[5] += dt * 30;
      if (g[4] <= 0) gas.remove(i);
    }
    // the speech-box tail follows his mouth as he sways
    rick.px = rx + 16 + sin(sway) * 285;
    rick.py = ry - 285 * cos(sway);
  }

  void nextLine() {
    line++;
    lineT = 0;
    rick.say(LINES[line]);
  }

  void finish() {
    leaving = true;
    rick.drunkMode = false;
    go(new DifficultyScene());
  }

  void draw() {
    drawHall();
    portal.draw();
    // Rick (in front of the portal once he's out)
    if (t > 1.3) {
      pushMatrix();
      translate(rx, ry - 160);
      rotate(spin);
      translate(-rx, -(ry - 160));
      float sq = 1 + (rick.burping() ? 0.04 * sin(T * 40) : 0);
      rick.drawBody(rx, ry, 1.0 * sq, sway, flask, tilt);
      popMatrix();
    }
    // burp cloud
    noStroke();
    for (float[] g : gas) {
      fill(140, 200, 90, 90 * g[4] / 1.4);
      ellipse(g[0], g[1], g[5], g[5]);
    }
    if (rick.burping() && T - rick.burpT < 0.6) {
      float k = (T - rick.burpT) / 0.6;
      textFont(fTitle);
      textAlign(CENTER, CENTER);
      fill(#9BE36A, 255 * (1 - k));
      pushMatrix();
      translate(rx + 150, ry - 380 - k * 40);
      rotate(-0.15);
      scale(0.8 + k * 0.4);
      text("BUUURP", 0, 0);
      popMatrix();
    }
    rick.drawBox();
    // skip hint
    textFont(fSmall);
    textAlign(RIGHT, BOTTOM);
    fill(C_DIM, 160 + 80 * sin(T * 3));
    text("click: next line     ENTER: skip intro", W - 18, H - 14);
  }

  // a lecture hall: back wall, chalkboard with doodles, desk
  void drawHall() {
    noStroke();
    for (int y = 0; y < H; y += 4) {
      fill(lerpColor(#1A2238, #0E1322, y / (float) H));
      rect(0, y, W, 4);
    }
    // floor
    fill(#2A2018);
    rect(0, 560, W, 160);
    fill(#33271D);
    for (int i = 0; i < 14; i++) rect(i * 100 - 20, 560, 4, 160);
    // chalkboard
    fill(#5A3B22);
    rect(150, 90, 620, 330, 8);
    fill(#1F3A2C);
    rect(166, 106, 588, 298, 4);
    // chalk doodles (it's a med school...)
    stroke(235, 240, 230, 200);
    strokeWeight(3);
    noFill();
    textFont(fH1);
    fill(235, 240, 230, 210);
    textAlign(LEFT, TOP);
    text("ANATOMY 101", 196, 126);
    textFont(fBody);
    text("Prof: ???", 200, 178);
    text("Rule 1: don't die", 200, 210);
    text("Rule 2: see rule 1", 200, 240);
    noFill();
    // a bone
    strokeWeight(3);
    line(540, 180, 680, 180);
    ellipse(533, 172, 16, 16);
    ellipse(533, 188, 16, 16);
    ellipse(687, 172, 16, 16);
    ellipse(687, 188, 16, 16);
    // a heart
    beginShape();
    vertex(610, 330);
    bezierVertex(560, 290, 570, 245, 610, 268);
    bezierVertex(650, 245, 660, 290, 610, 330);
    endShape();
    // a little neuron
    ellipse(240, 340, 26, 26);
    line(253, 340, 380, 340);
    line(380, 340, 395, 328);
    line(380, 340, 395, 352);
    line(228, 332, 205, 318);
    line(230, 350, 206, 362);
    // a stick figure that looks unwell
    ellipse(470, 300, 22, 22);
    line(470, 311, 470, 350);
    line(470, 322, 452, 338);
    line(470, 322, 488, 338);
    line(470, 350, 456, 380);
    line(470, 350, 484, 380);
    line(462, 296, 466, 300);
    line(466, 296, 462, 300);
    line(474, 296, 478, 300);
    line(478, 296, 474, 300);
    noStroke();
    // desk
    fill(#4A3220);
    rect(80, 500, 360, 26, 4);
    fill(#3A2718);
    rect(100, 526, 20, 60);
    rect(400, 526, 20, 60);
    // a beaker on the desk
    fill(120, 220, 255, 140);
    rect(330, 462, 34, 38, 4);
    fill(120, 255, 140, 170);
    rect(330, 478, 34, 22, 3);
  }

  void mouse() {
    if (line < 0) {
      t = max(t, 3.6);
      return;
    }
    if (!rick.finish()) {
      if (line < LINES.length - 1) nextLine();
      else if (!leaving) finish();
    }
  }

  void key(char k, int code) {
    if (code == ENTER || code == RETURN || k == '\n') {
      if (!leaving) finish();
    } else if (k == ' ') mouse();
  }

  void escape() {
    if (!leaving) finish();
  }

  void back() {
    if (!leaving) finish();
  }
}


// ======================================================================
// TAB: SceneLesson.pde
// ======================================================================
// Lessons: Rick teaches the level's key facts, one card at a time, with the
// relevant part glowing on the diagram. Then: quiz.

class LessonScene extends Scene {
  Topic topic;
  int level, idx;
  Level lv;
  DiagramView view = new DiagramView();
  float cardT;

  LessonScene(Topic topic, int level) {
    this.topic = topic;
    this.level = level;
    lv = topic.levels[level];
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    button("prev", "< BACK", 40, 646, 140, 54).key("B");
    button("next", "NEXT >", 192, 646, 190, 54).key(" ");
    button("quiz", "SKIP TO QUIZ", 394, 646, 200, 54).key("Q").colour(C_GOLD);
    show(0);
  }

  void show(int i) {
    idx = i;
    cardT = 0;
    if (lv.lessons.isEmpty()) {
      rick.say("No lessons here yet. Straight to the quiz, I guess. *burp*");
      return;
    }
    Lesson l = lv.lessons.get(idx);
    String dia = l.diagram != null && l.diagram.length() > 0 ? l.diagram : topic.mainDiagram();
    view.set(diagram(dia), 70, 128, 470);
    view.marks.clear();
    view.pulse = l.part != null && l.part.length() > 0 ? l.part : null;
    view.hoverOn = true;
    rick.say(idx == 0 && l.rick.length() < 60 ? pick(LESSON_START) + " " + l.rick : l.rick);
    sfx.play(sfx.blip, 0.6);
  }

  void update(float dt) {
    cardT += dt;
    view.update();
    for (Button b : buttons) {
      if (b.id.equals("prev")) b.label = idx > 0 ? "< BACK" : "< TOPICS";
      if (b.id.equals("next")) b.label = idx >= lv.lessons.size() - 1 ? "QUIZ TIME >" : "NEXT >";
    }
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    levelBadge(40, 22, level);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text(topic.title, 40, 52);
    schmeckles(W - 20, 14);
    if (view.d != null) {
      view.draw();
      Part p = view.pulse != null ? view.d.part(view.pulse) : null;
      if (p != null) view.tag(p, partName(view.d.id, p.id), C_GOLD);
      if (view.hover != null && view.hover != p) view.tag(view.hover, partName(view.d.id, view.hover.id), C_BLUE);
      textFont(fSmall);
      fill(C_DIM);
      textAlign(LEFT, TOP);
      text(view.d.title + "  -  hover to see names", 70, 616);
    }
    if (!lv.lessons.isEmpty()) drawCard(lv.lessons.get(idx));
    drawButtons();
    rick.drawBox();
  }

  void drawCard(Lesson l) {
    float x = 600, y = 110, w = 640, h = 420;
    float k = min(1, cardT / 0.3);
    k = 1 - pow(1 - k, 3);
    pushMatrix();
    translate(0, (1 - k) * 30);
    panel(x, y, w, h, C_PANEL, LEVEL_COLS[level], 20);
    textFont(fMono);
    textAlign(LEFT, TOP);
    fill(LEVEL_COLS[level]);
    text("LESSON " + (idx + 1) + " / " + lv.lessons.size(), x + 26, y + 22);
    // progress dots
    for (int i = 0; i < lv.lessons.size(); i++) {
      noStroke();
      fill(i <= idx ? LEVEL_COLS[level] : #2A3550);
      ellipse(x + w - 30 - (lv.lessons.size() - 1 - i) * 18, y + 30, 10, 10);
    }
    textFont(fH1);
    fill(C_TEXT);
    float th = textBlock(l.title, x + 26, y + 54, w - 52, 44);
    textFont(fBody);
    fill(#DCE6F8);
    textBlock(l.fact, x + 26, y + 70 + th, w - 52, 31);
    popMatrix();
  }

  void next() {
    if (idx < lv.lessons.size() - 1) show(idx + 1);
    else startQuiz();
  }

  void startQuiz() {
    if (lv.questions.isEmpty()) {
      rick.say("There's no quiz here yet. Even I can't grade nothing. *burp*");
      return;
    }
    ArrayList<Question> qs = new ArrayList<Question>(lv.questions);
    java.util.Collections.shuffle(qs);
    go(new QuizScene(topic.title, qs, level, topic.key, false));
  }

  void clicked(Button b) {
    if (b.id.equals("prev")) {
      if (idx > 0) show(idx - 1);
      else back();
    }
    if (b.id.equals("next")) next();
    if (b.id.equals("quiz")) startQuiz();
  }

  void key(char k, int code) {
    if (code == RIGHT || code == ENTER || code == RETURN) next();
    if (code == LEFT && idx > 0) show(idx - 1);
  }

  void back() {
    go(new TopicScene(level));
  }
}


// ======================================================================
// TAB: SceneMenus.pde
// ======================================================================
// "TODAY'S LESSON: CHOOSE DIFFICULTY, IDIOT." and the body-system picker.

// ---------------------------------------------------------------- shared bits
void drawStars(float x, float y, int n, float s) {
  for (int i = 0; i < 3; i++) {
    fill(i < n ? C_GOLD : #2A3550);
    stroke(i < n ? #8A6A10 : #3A4766);
    strokeWeight(1.5);
    star(x + i * s * 1.15, y, s * 0.5, s * 0.22);
  }
}

void star(float cx, float cy, float r1, float r2) {
  beginShape();
  for (int i = 0; i < 10; i++) {
    float a = -HALF_PI + i * PI / 5;
    float r = i % 2 == 0 ? r1 : r2;
    vertex(cx + cos(a) * r, cy + sin(a) * r);
  }
  endShape(CLOSE);
}

void levelBadge(float x, float y, int level) {
  textFont(fMono);
  String s = level == 0 ? "STUDY" : "LV" + level + " " + LEVEL_NAMES[level];
  float w = textWidth(s) + 20;
  noStroke();
  fill(level == 0 ? C_BLUE : LEVEL_COLS[level]);
  rect(x, y, w, 26, 13);
  fill(#0B1020);
  textAlign(LEFT, CENTER);
  text(s, x + 10, y + 12);
}

void schmeckles(float x, float y) {
  textFont(fMono);
  textAlign(RIGHT, TOP);
  fill(C_GOLD);
  text(progress.xp() + " SCHMECKLES", x, y);
}

// ---------------------------------------------------------------- difficulty
class DifficultyScene extends Scene {
  float t;
  int hoverLv;
  float[] lift = new float[5];

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.drunkMode = false;
    rick.say(pick(DIFF_ENTER));
    button("explore", "STUDY DIAGRAMS", 60, 622, 250, 64).key("S").sub = "point at stuff, learn stuff";
    int n = progress.mistakes(0).size();
    Button r = button("review", "REVIEW MISTAKES", 326, 622, 250, 64).key("R").colour(C_GOLD);
    r.sub = n == 0 ? "nothing to review yet" : n + " question" + (n == 1 ? "" : "s") + " to fix";
    r.enabled = n > 0;
  }

  float cardX(int lv) {
    return 60 + (lv - 1) * 296;
  }

  void update(float dt) {
    t += dt;
    int h = 0;
    for (int lv = 1; lv <= 4; lv++) if (over(cardX(lv), 190, 276, 370)) h = lv;
    if (h != hoverLv && h != 0) rick.say(pick(DIFF_HOVER[h]));
    hoverLv = h;
    for (int lv = 1; lv <= 4; lv++) lift[lv] += ((lv == hoverLv ? 1 : 0) - lift[lv]) * min(1, dt * 12);
    rick.idleCheck();
    prebuildDiagrams();
  }

  void draw() {
    space.draw();
    drawPortal(W / 2, 96, 330, 70, T * 0.6, 60);
    // the title, wobbling like the man who wrote it
    textAlign(CENTER, CENTER);
    textFont(fH2);
    fill(C_GREEN);
    text("TODAY'S LESSON:", W / 2, 46);
    textFont(fTitle);
    String title = "CHOOSE DIFFICULTY, IDIOT.";
    float tw = textWidth(title), x = W / 2 - tw / 2;
    for (int i = 0; i < title.length(); i++) {
      String c = title.substring(i, i + 1);
      float cw = textWidth(c);
      pushMatrix();
      translate(x + cw / 2, 112 + sin(T * 2.4 + i * 0.5) * 5);
      rotate(sin(T * 1.7 + i * 0.8) * 0.06);
      fill(0, 150);
      text(c, 3, 4);
      fill(lerpColor(#E8FFE0, C_GREEN, 0.5 + 0.5 * sin(T * 2 + i * 0.3)));
      text(c, 0, 0);
      popMatrix();
      x += cw;
    }
    for (int lv = 1; lv <= 4; lv++) drawCard(lv);
    drawButtons();
    schmeckles(W - 20, 14);
    rick.drawBox();
  }

  void drawCard(int lv) {
    float x = cardX(lv), y = 190 - lift[lv] * 10, w = 276, h = 370;
    int c = LEVEL_COLS[lv];
    noStroke();
    fill(0, 120);
    rect(x + 6, y + 10, w, h, 22);
    fill(lerpColor(C_PANEL, c, 0.08 + 0.1 * lift[lv]));
    stroke(lerpColor(C_EDGE, c, 0.5 + 0.5 * lift[lv]));
    strokeWeight(2 + lift[lv] * 2);
    rect(x, y, w, h, 22);
    // icon
    pushMatrix();
    translate(x + w / 2, y + 108);
    scale(1 + lift[lv] * 0.08);
    rotate(sin(T * 2 + lv) * 0.05 * lift[lv]);
    levelIcon(lv);
    popMatrix();
    textAlign(CENTER, TOP);
    textFont(fMono);
    fill(c);
    text("LEVEL " + lv + "   [" + lv + "]", x + w / 2, y + 20);
    textFont(fH2);
    fill(C_TEXT);
    text(LEVEL_NAMES[lv], x + w / 2, y + 196);
    textFont(fSmall);
    fill(C_DIM);
    textBlockCentered(LEVEL_SUBS[lv], x + w / 2, y + 236, w - 40, 22);
    // progress across the ten topics
    int stars = 0, done = 0;
    for (String k : TOPIC_ORDER) {
      stars += progress.stars(k, lv);
      if (progress.best(k, lv) >= 0) done++;
    }
    fill(C_GOLD);
    stroke(#8A6A10);
    strokeWeight(1.5);
    star(x + 40, y + h - 46, 12, 5.4);
    textFont(fBodyB);
    textAlign(LEFT, CENTER);
    fill(C_TEXT);
    text(stars + " / " + TOPIC_ORDER.length * 3, x + 58, y + h - 47);
    textFont(fSmall);
    fill(C_DIM);
    textAlign(RIGHT, CENTER);
    text(done + "/" + TOPIC_ORDER.length + " systems", x + w - 22, y + h - 46);
  }

  void mouse() {
    for (int lv = 1; lv <= 4; lv++) if (over(cardX(lv), 190, 276, 370)) choose(lv);
  }

  void choose(int lv) {
    sfx.play(sfx.click, 0.5);
    go(new TopicScene(lv));
  }

  void key(char k, int code) {
    if (k >= '1' && k <= '4') choose(k - '0');
  }

  void clicked(Button b) {
    if (b.id.equals("explore")) {
      studyFromLevel = 0;
      go(new ExploreScene(null));
    }
    if (b.id.equals("review")) startReview(0);
  }

  void back() {
    rick.say("There's no escape, genius. *burp* Pick a level.");
  }
}

void textBlockCentered(String s, float cx, float y, float w, float lh) {
  ArrayList<String> ls = wrapText(s, w);
  textAlign(CENTER, TOP);
  for (int i = 0; i < ls.size(); i++) text(ls.get(i), cx, y + i * lh);
}

// little drawings on the difficulty cards
void levelIcon(int lv) {
  strokeWeight(3);
  stroke(#1E1C28);
  if (lv == 1) {               // baby bottle
    fill(#FFE7EF);
    rect(-26, -30, 52, 74, 14);
    fill(#F6C0D0);
    rect(-30, -40, 60, 14, 6);
    fill(#F2D2B6);
    beginShape();
    vertex(-12, -40);
    bezierVertex(-12, -70, 12, -70, 12, -40);
    endShape(CLOSE);
    noStroke();
    fill(255, 255, 255, 200);
    rect(-16, -18, 10, 50, 5);
    stroke(#E58FAA);
    for (int i = 0; i < 3; i++) line(10, -12 + i * 16, 22, -12 + i * 16);
  } else if (lv == 2) {        // test tube
    rotate(0.3);
    fill(#DFF6FF);
    rect(-16, -56, 32, 100, 0, 0, 16, 16);
    noStroke();
    fill(#5FD3FF);
    rect(-14, -6, 28, 48, 0, 0, 14, 14);
    fill(255, 160);
    ellipse(-4, 10, 8, 8);
    ellipse(5, 26, 6, 6);
    stroke(#1E1C28);
    noFill();
    rect(-16, -56, 32, 100, 0, 0, 16, 16);
    fill(#9AA6B5);
    rect(-20, -62, 40, 10, 4);
  } else if (lv == 3) {        // stethoscope
    noFill();
    stroke(#3A4766);
    strokeWeight(7);
    beginShape();
    vertex(-30, -50);
    bezierVertex(-36, 10, 36, 10, 30, -50);
    endShape();
    line(0, 8, 0, 30);
    stroke(#1E1C28);
    strokeWeight(3);
    fill(#C9D2DC);
    ellipse(0, 40, 36, 36);
    fill(#8C96A3);
    ellipse(0, 40, 18, 18);
    fill(#FFB547);
    ellipse(-30, -52, 12, 12);
    ellipse(30, -52, 12, 12);
  } else {                     // Rick's flask with a skull
    fill(#B9C2CC);
    rect(-30, -40, 60, 80, 12);
    fill(#8C96A3);
    rect(-10, -54, 20, 16, 4);
    noStroke();
    fill(#FF4F6D);
    ellipse(0, 0, 34, 30);
    rect(-9, 8, 18, 12, 3);
    fill(#B9C2CC);
    ellipse(-7, -2, 9, 9);
    ellipse(7, -2, 9, 9);
    rect(-5, 12, 3, 8);
    rect(2, 12, 3, 8);
  }
}

// ---------------------------------------------------------------- body systems
class TopicScene extends Scene {
  int level;
  String hoverKey = "";
  float[] lift = new float[12];

  TopicScene(int level) {
    this.level = level;
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.say(pick(TOPIC_ENTER));
    button("back", "< BACK", 54, 640, 170, 56).key("B");
    button("explore", "STUDY DIAGRAMS", 240, 640, 270, 56).key("S").colour(C_BLUE);
  }

  float[] cell(int i) {
    float w = 186, h = 206, gap = 12;
    int col = i % 6, row = i / 6;
    return new float[] { 54 + col * (w + gap), 106 + row * (h + 14), w, h };
  }

  String keyAt(int i) {
    if (i < TOPIC_ORDER.length) return TOPIC_ORDER[i];
    return i == 10 ? "mix" : "review";
  }

  void update(float dt) {
    String h = "";
    for (int i = 0; i < 12; i++) {
      float[] c = cell(i);
      boolean on = over(c[0], c[1], c[2], c[3]);
      if (on) h = keyAt(i);
      lift[i] += ((on ? 1 : 0) - lift[i]) * min(1, dt * 12);
    }
    if (!h.equals(hoverKey) && h.length() > 0) {
      if (TOPIC_HOVER.containsKey(h)) rick.say(TOPIC_HOVER.get(h)[0]);
      else if (h.equals("mix")) rick.say("Random mix. Questions from every system. Chaos. I love it.");
      else rick.say("Your mistakes. All of them. Fix them and they go away. Like my marriages.");
    }
    hoverKey = h;
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    levelBadge(54, 26, level);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text("PICK A BODY SYSTEM", 54, 56);
    schmeckles(W - 20, 14);
    for (int i = 0; i < 12; i++) drawCell(i);
    drawButtons();
    rick.drawBox();
  }

  void drawCell(int i) {
    float[] c = cell(i);
    float x = c[0], y = c[1] - lift[i] * 6, w = c[2], h = c[3];
    String k = keyAt(i);
    int col = LEVEL_COLS[level];
    noStroke();
    fill(0, 110);
    rect(x + 5, y + 8, w, h, 18);
    fill(lerpColor(C_PANEL, col, 0.06 + 0.1 * lift[i]));
    stroke(lerpColor(C_EDGE, col, 0.4 + 0.6 * lift[i]));
    strokeWeight(2 + lift[i]);
    rect(x, y, w, h, 18);
    textAlign(CENTER, TOP);
    if (i < TOPIC_ORDER.length) {
      Topic t = TOPICS.get(k);
      // thumbnail
      noStroke();
      fill(C_PAPER);
      ellipse(x + w / 2, y + 74, 116, 116);
      Diagram d = diagram(t.mainDiagram());
      if (d != null) {
        imageMode(CENTER);
        image(d.thumb(), x + w / 2, y + 74, 104, 104);
        imageMode(CORNER);
      }
      textFont(fBodyB);
      if (textWidth(t.title) > w - 16) textSize(22 * (w - 16) / textWidth(t.title));
      fill(C_TEXT);
      text(t.title, x + w / 2, y + 140);
      int b = progress.best(k, level);
      drawStars(x + w / 2 - 23, y + 190, progress.stars(k, level), 18);
      textFont(fSmall);
      fill(C_DIM);
      textAlign(CENTER, TOP);
      text(b < 0 ? "not tried" : "best " + b + "%", x + w / 2, y + 164);
      // which levels have been passed
      for (int lv = 1; lv <= 4; lv++) {
        noStroke();
        fill(progress.stars(k, lv) > 0 ? LEVEL_COLS[lv] : #2A3550);
        ellipse(x + w - 16, y + 16 + (lv - 1) * 12, 7, 7);
      }
    } else if (k.equals("mix")) {
      // dice
      pushMatrix();
      translate(x + w / 2, y + 76);
      rotate(sin(T) * 0.2);
      stroke(#1E1C28);
      strokeWeight(3);
      fill(#F6F1E4);
      rect(-34, -34, 68, 68, 12);
      noStroke();
      fill(#1E1C28);
      ellipse(-16, -16, 11, 11);
      ellipse(16, 16, 11, 11);
      ellipse(0, 0, 11, 11);
      ellipse(16, -16, 11, 11);
      ellipse(-16, 16, 11, 11);
      popMatrix();
      textFont(fBodyB);
      fill(C_TEXT);
      textAlign(CENTER, TOP);
      text("RANDOM MIX", x + w / 2, y + 140);
      textFont(fSmall);
      fill(C_DIM);
      text("12 random, all systems", x + w / 2, y + 168);
    } else {
      int n = progress.mistakes(level).size();
      textFont(fTitle);
      fill(n > 0 ? C_GOLD : C_DIM);
      textAlign(CENTER, CENTER);
      text("" + n, x + w / 2, y + 74);
      textFont(fBodyB);
      fill(C_TEXT);
      textAlign(CENTER, TOP);
      text("MISTAKES", x + w / 2, y + 140);
      textFont(fSmall);
      fill(C_DIM);
      text(n > 0 ? "right twice = gone" : "none yet at this level", x + w / 2, y + 168);
    }
  }

  void mouse() {
    for (int i = 0; i < 12; i++) {
      float[] c = cell(i);
      if (!over(c[0], c[1], c[2], c[3])) continue;
      sfx.play(sfx.click, 0.5);
      String k = keyAt(i);
      if (i < TOPIC_ORDER.length) go(new LessonScene(TOPICS.get(k), level));
      else if (k.equals("mix")) startMix(level);
      else startReview(level);
    }
  }

  void clicked(Button b) {
    if (b.id.equals("back")) back();
    if (b.id.equals("explore")) {
      studyFromLevel = level;
      go(new ExploreScene(null));
    }
  }

  void back() {
    go(new DifficultyScene());
  }
}

// ---------------------------------------------------------------- quiz launchers
void startMix(int level) {
  ArrayList<Question> all = new ArrayList<Question>();
  for (String k : TOPIC_ORDER) all.addAll(TOPICS.get(k).levels[level].questions);
  java.util.Collections.shuffle(all);
  if (all.isEmpty()) return;
  ArrayList<Question> qs = new ArrayList<Question>(all.subList(0, min(12, all.size())));
  go(new QuizScene("RANDOM MIX", qs, level, "mix", false));
}

void startReview(int level) {
  ArrayList<Question> qs = progress.mistakes(level);
  if (qs.isEmpty()) {
    rick.say(pick(REVIEW_EMPTY));
    return;
  }
  java.util.Collections.shuffle(qs);
  if (qs.size() > 12) qs = new ArrayList<Question>(qs.subList(0, 12));
  go(new QuizScene("MISTAKES REVIEW", qs, level, "review", true));
}


// ======================================================================
// TAB: SceneQuiz.pde
// ======================================================================
// The quiz: multiple choice (1-4 / click) and "click the part" on a diagram.
// Every answer shows the explanation, so a wrong answer still teaches.
// Wrong answers go to the mistakes pile (REVIEW), right answers in review
// work them back out. RICK MODE has a clock.

class QuizScene extends Scene {
  String title, topicKey;
  int level;
  boolean review;
  ArrayList<Question> qs;
  int idx;
  Question q;
  int[] order = new int[4];            // shuffled choice order: display slot -> original index
  boolean[] gone = new boolean[4];     // removed by a hint
  int chosen = -1;                     // display slot picked
  Part clicked;
  boolean answered, wasRight, hinted, timedOut;
  float hintX, hintY;                  // label hint circle (diagram units)
  int score, streak, bestStreak, right, gained;
  int xpEarned;                        // schmeckles from the answers themselves
  int cleared, climbing;               // review: questions that left the pile / moved up a box
  ArrayList<Question> missed = new ArrayList<Question>();
  float qT, answerT;
  float top;                           // where the answer area starts (below the question)
  float escT = -9;                     // ESC must be pressed twice to abandon the quiz
  float timeLimit;
  int lastTick;
  DiagramView view = new DiagramView();
  Button nextB, hintB;

  QuizScene(String title, ArrayList<Question> qs, int level, String topicKey, boolean review) {
    this.title = title;
    this.qs = qs;
    this.level = level;
    this.topicKey = topicKey;
    this.review = review;
    timeLimit = level == 4 ? 45 : 0;
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    nextB = button("next", "NEXT >", 990, 470, 230, 54).key(" ");
    hintB = button("hint", "HINT  (half points)", 760, 470, 260, 54).key("H").colour(C_GOLD);
    hintB.showKey = false;
    button("quit", "QUIT", 1110, 14, 110, 40).colour(C_RED);
    load(0);
    rick.say(pick(QUIZ_START));
  }

  void load(int i) {
    idx = i;
    q = qs.get(idx);
    answered = false;
    wasRight = false;
    hinted = false;
    timedOut = false;
    chosen = -1;
    clicked = null;
    qT = 0;
    lastTick = -1;
    rick.dock = DOCK_CORNER;
    rick.quiet();
    textFont(fH2);
    top = 100 + max(70, textBlockHeight(q.q, 1150, 34) + 30) + 16;
    hintB.x = 770;
    hintB.y = top + 240;
    for (int k = 0; k < 4; k++) {
      order[k] = k;
      gone[k] = false;
    }
    if (!q.isLabel()) {
      for (int k = 3; k > 0; k--) {
        int j = (int) random(k + 1);
        int tmp = order[k];
        order[k] = order[j];
        order[j] = tmp;
      }
    } else {
      view.set(diagram(q.diagram), 140, top + 14, 440);
      view.marks.clear();
      view.pulse = null;
      view.hoverOn = true;
    }
  }

  // ---------------------------------------------------------------- answering
  void pickChoice(int slot) {
    if (answered || q.isLabel() || gone[slot]) return;
    chosen = slot;
    finish(order[slot] == q.answer);
  }

  void pickPart(Part p) {
    if (answered || !q.isLabel() || p == null) return;
    clicked = p;
    boolean ok = p.id.equals(q.part);
    view.marks.put(q.part, C_GREEN);
    if (!ok) view.marks.put(p.id, C_RED);
    finish(ok);
  }

  void timeout() {
    if (answered) return;
    timedOut = true;
    if (q.isLabel()) view.marks.put(q.part, C_GREEN);
    finish(false);
  }

  void finish(boolean ok) {
    answered = true;
    wasRight = ok;
    answerT = 0;
    rick.dock = DOCK_HIDDEN;           // his reaction goes inside the feedback panel
    progress.answered(ok);
    if (ok) {
      right++;
      streak++;
      bestStreak = max(bestStreak, streak);
      float mult = 1 + 0.1 * min(10, streak - 1);
      gained = (int) (100 * max(1, level) * mult * (hinted ? 0.5 : 1));
      if (timeLimit > 0) gained += (int) max(0, timeLimit - qT) * 4;
      score += gained;
      progress.addXp(max(1, gained / 10));
      xpEarned += max(1, gained / 10);
      boolean inPile = progress.inPile(q.id);
      if (progress.hit(q.id, review)) cleared++;
      else if (review && inPile) climbing++;
      if (streak == 3 || streak == 5 || streak == 8) {
        sfx.play(sfx.streak, 0.6);
        rick.say(STREAK[streak == 3 ? 0 : streak == 5 ? 1 : 2]);
      } else {
        sfx.play(sfx.correct, 0.6);
        rick.say(q.rick != null && q.rick.length() > 0 && random(1) < 0.75 ? q.rick : pick(CORRECT));
      }
    } else {
      streak = 0;
      gained = 0;
      missed.add(q);
      progress.miss(q.id);
      sfx.play(sfx.wrong, 0.6);
      if (timedOut) rick.say(pick(TIMEOUT_LINES));
      else if (q.isLabel() && clicked != null) rick.say(String.format(pick(LABEL_WRONG), partName(q.diagram, clicked.id)));
      else rick.say(random(1) < 0.5 && q.rick != null && q.rick.length() > 0 ? q.rick : pick(WRONG));
    }
    progress.save();
  }

  void useHint() {
    if (answered || hinted) return;
    hinted = true;
    rick.say(pick(HINT_LINES));
    if (!q.isLabel()) {
      // knock out two wrong answers
      int removed = 0;
      for (int s = 0; s < 4 && removed < 2; s++) {
        int slot = (s + idx) % 4;
        if (order[slot] != q.answer) {
          gone[slot] = true;
          removed++;
        }
      }
    } else {
      // a circle that contains the answer (not centred on it)
      Part p = view.d.part(q.part);
      float[] a = p.anchorPt();
      float ang = random(TWO_PI);
      hintX = constrain(a[0] + cos(ang) * 40, 90, DIA - 90);
      hintY = constrain(a[1] + sin(ang) * 40, 90, DIA - 90);
    }
  }

  void next() {
    if (!answered) return;
    if (idx < qs.size() - 1) load(idx + 1);
    else go(new ResultScene(this));
  }

  // ---------------------------------------------------------------- frame
  void update(float dt) {
    if (!answered) qT += dt;
    else answerT += dt;
    if (q.isLabel()) {
      view.hoverOn = !answered;
      view.update();
    }
    if (timeLimit > 0 && !answered) {
      int left = (int) (timeLimit - qT);
      if (left < 10 && left != lastTick) {
        lastTick = left;
        sfx.play(sfx.tick, 0.5);
      }
      if (qT >= timeLimit) timeout();
    }
    nextB.visible = answered;
    nextB.label = idx < qs.size() - 1 ? "NEXT >" : "RESULTS >";
    hintB.visible = !answered;
    hintB.enabled = !hinted;
  }

  void draw() {
    space.draw();
    drawHeader();
    drawQuestion();
    if (q.isLabel()) drawLabelQ();
    else drawChoices();
    drawSide();
    drawButtons();
    rick.drawBox();
  }

  void drawHeader() {
    levelBadge(40, 20, level);
    textFont(fBodyB);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    float bw = textWidth("LV" + level + " " + (level == 0 ? "STUDY" : LEVEL_NAMES[level])) + 40;
    text(title, 40 + bw + 6, 21);
    textFont(fMono);
    textAlign(LEFT, TOP);
    fill(C_DIM);
    text("QUESTION " + (idx + 1) + " / " + qs.size(), 40, 58);
    // progress pips
    for (int i = 0; i < qs.size(); i++) {
      noStroke();
      fill(i < idx || (i == idx && answered) ? C_GREEN : i == idx ? C_TEXT : #2A3550);
      rect(250 + i * 22, 60, 16, 10, 3);
    }
    textAlign(RIGHT, TOP);
    fill(C_GOLD);
    text("SCORE " + score, 1090, 20);
    fill(streak >= 3 ? #FF9A3C : C_DIM);
    text("STREAK " + streak + (streak >= 3 ? " !!" : ""), 1090, 40);
    if (T - escT < 2) {
      textFont(fMono);
      textAlign(RIGHT, TOP);
      fill(C_RED);
      text("ESC AGAIN TO QUIT", 1090, 62);
    }
    if (timeLimit > 0 && !answered) {
      float k = constrain(1 - qT / timeLimit, 0, 1);
      noStroke();
      fill(#2A3550);
      rect(40, 84, 1200, 8, 4);
      fill(k > 0.3 ? C_GREEN : C_RED);
      rect(40, 84, 1200 * k, 8, 4);
    }
  }

  void drawQuestion() {
    textFont(fH2);
    float h = textBlockHeight(q.q, 1150, 34) + 30;
    panel(40, 100, 1200, max(70, h), C_PANEL2, C_EDGE, 16);
    fill(C_TEXT);
    textBlock(q.q, 64, 114, 1150, 34);
  }

  void drawChoices() {
    textFont(fBody);
    for (int s = 0; s < 4; s++) {
      float x = 40, y = top + s * 92, w = 680, h = 80;
      boolean hov = !answered && !gone[s] && over(x, y, w, h);
      boolean isAns = order[s] == q.answer;
      int bg = C_PANEL, edge = C_EDGE;
      if (hov) {
        bg = lerpColor(C_PANEL, C_BLUE, 0.18);
        edge = C_BLUE;
      }
      if (answered && isAns) {
        bg = lerpColor(C_PANEL, C_GREEN, 0.3);
        edge = C_GREEN;
      } else if (answered && s == chosen) {
        bg = lerpColor(C_PANEL, C_RED, 0.3);
        edge = C_RED;
      }
      float a = gone[s] ? 70 : 255;
      noStroke();
      fill(0, 100 * a / 255);
      rect(x + 4, y + 6, w, h, 14);
      fill(bg, a);
      stroke(edge, a);
      strokeWeight(hov || (answered && (isAns || s == chosen)) ? 3 : 2);
      rect(x, y, w, h, 14);
      // key cap
      noStroke();
      fill(edge, a);
      rect(x + 14, y + h / 2 - 18, 36, 36, 8);
      fill(#0B1020, a);
      textFont(fBodyB);
      textAlign(CENTER, CENTER);
      text("" + (s + 1), x + 32, y + h / 2 - 1);
      textFont(fBody);
      fill(C_TEXT, a);
      ArrayList<String> ls = wrapText(q.choices[order[s]], w - 140);
      float ty = y + h / 2 - ls.size() * 14;
      textAlign(LEFT, TOP);
      for (int i = 0; i < ls.size(); i++) text(ls.get(i), x + 66, ty + i * 28);
      if (answered && (isAns || s == chosen)) {
        textFont(fH2);
        fill(isAns ? C_GREEN : C_RED);
        textAlign(RIGHT, CENTER);
        text(isAns ? "OK" : "X", x + w - 18, y + h / 2);
      }
    }
  }

  void drawLabelQ() {
    view.draw();
    if (hinted && !answered) {
      float s = view.s();
      noFill();
      stroke(C_GOLD);
      strokeWeight(3);
      float r = 95 * s;
      float cx = view.x + hintX * s, cy = view.y + hintY * s;
      for (int i = 0; i < 24; i += 2) arc(cx, cy, r * 2, r * 2, TWO_PI * i / 24 + T, TWO_PI * (i + 1) / 24 + T);
    }
    if (answered) {
      Part ans = view.d.part(q.part);
      if (clicked != null && clicked != ans) {
        // a neighbouring part's tag would sit under the answer's, so drop it below
        boolean near = false;
        if (ans != null) {
          float[] a1 = ans.anchorPt(), a2 = clicked.anchorPt();
          near = abs(a1[1] - a2[1]) * view.s() < 44 && abs(a1[0] - a2[0]) * view.s() < 220;
        }
        view.tag(clicked, partName(q.diagram, clicked.id), C_RED, near);
      }
      if (ans != null) view.tag(ans, partName(q.diagram, q.part), C_GREEN);
    }
    textFont(fSmall);
    textAlign(LEFT, TOP);
    fill(C_DIM);
    text(answered ? view.d.title : "click the part on the diagram", 140, min(H - 22, view.y + view.size + 18));
  }

  // right column: instructions before, verdict + explanation after
  void drawSide() {
    float x = 740, y = top, w = 510;
    if (!answered) {
      panel(x, y, w, 220, C_PANEL, C_EDGE, 18);
      textFont(fBodyB);
      fill(C_TEXT);
      textAlign(LEFT, TOP);
      text(q.isLabel() ? "CLICK THE RIGHT PART" : "PICK ONE  (1 - 4)", x + 24, y + 22);
      textFont(fSmall);
      fill(C_DIM);
      String tip = q.isLabel() ? "Hover shows outlines, not names. That would be cheating. Cheating's MY thing."
        : "Click an answer or press 1-4. Wrong answers go in your mistakes pile so you can fix them later.";
      textBlock(tip, x + 24, y + 58, w - 48, 22);
      textBlock("H = hint for half points.  " + (timeLimit > 0 ? "RICK MODE: " + (int) max(0, ceil(timeLimit - qT)) + " s left." : "No clock at this level."), x + 24, y + 150, w - 48, 22);
      return;
    }
    textFont(fExplain);
    String extra = "";
    if (!wasRight) extra = q.isLabel() ? "Answer: " + partName(q.diagram, q.part) : "Answer: " + q.choices[q.answer];
    float eh = textBlockHeight(q.explain, w - 48, 24);
    textFont(fBodyB);
    float xh = extra.length() > 0 ? textBlockHeight(extra, w - 48, 26) + 8 : 0;
    textFont(fRickSmall);
    float rh = max(58, textBlockHeight("RICK: " + rick.text, w - 120, 22) + 6);
    float h = 70 + xh + eh + 14 + rh + 70;
    float k = min(1, answerT / 0.25);
    pushMatrix();
    translate((1 - k) * 40, 0);
    panel(x, y, w, h, C_PANEL, wasRight ? C_GREEN : C_RED, 18);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(wasRight ? C_GREEN : C_RED);
    text(wasRight ? "CORRECT!" : timedOut ? "TIME'S UP" : "NOPE.", x + 24, y + 16);
    if (wasRight) {
      textFont(fBodyB);
      fill(C_GOLD);
      textAlign(RIGHT, TOP);
      text("+" + gained, x + w - 24, y + 26);
    }
    float cy = y + 70;
    if (extra.length() > 0) {
      textFont(fBodyB);
      fill(C_TEXT);
      cy += textBlock(extra, x + 24, cy, w - 48, 26) + 8;
    }
    textFont(fExplain);
    fill(#C9D6EE);
    cy += textBlock(q.explain, x + 24, cy, w - 48, 24) + 14;
    // Rick's reaction
    noStroke();
    fill(#13233A);
    stroke(C_GREEN);
    strokeWeight(2);
    ellipse(x + 50, cy + 26, 52, 52);
    imageMode(CENTER);
    image(rick.currentFace(), x + 50, cy + 28, 50, 50);
    imageMode(CORNER);
    textFont(fRickSmall);
    ArrayList<String> rl = wrapText("RICK: " + rick.text, w - 120);
    int left = rick.shownText().length() + 6;
    for (int i = 0; i < rl.size() && left > 0; i++) {
      String ln = rl.get(i);
      richLine(ln.substring(0, min(ln.length(), left)), x + 90, cy + i * 22, #9BE36A, C_GOLD);
      left -= ln.length() + 1;
    }
    popMatrix();
    nextB.y = y + h - 66;
    nextB.x = x + w - nextB.w - 20;
  }

  // ---------------------------------------------------------------- input
  void mouse() {
    if (answered) return;
    if (q.isLabel()) {
      Part p = view.hitMouse();
      if (p != null) pickPart(p);
      return;
    }
    for (int s = 0; s < 4; s++) if (over(40, top + s * 92, 680, 80)) pickChoice(s);
  }

  void key(char k, int code) {
    if (!answered && !q.isLabel()) {
      if (k >= '1' && k <= '4') pickChoice(k - '1');
      if (k >= 'a' && k <= 'd') pickChoice(k - 'a');
    }
    if (answered && (k == '\n' || code == ENTER || code == RETURN || code == RIGHT)) next();
  }

  void clicked(Button b) {
    if (b.id.equals("next")) next();
    if (b.id.equals("hint")) useHint();
    if (b.id.equals("quit")) back();
  }

  void escape() {
    if (T - escT < 2) back();
    else {
      escT = T;
      sfx.play(sfx.click, 0.4);
    }
  }

  void back() {
    if (topicKey.equals("explore")) go(new ExploreScene(qs.isEmpty() ? null : qs.get(0).diagram));
    else if (level == 0) go(new DifficultyScene());
    else go(new TopicScene(level));
  }
}


// ======================================================================
// TAB: SceneResult.pde
// ======================================================================
// End of a quiz: the grade, Rick's verdict, what you missed, where to go next.

class ResultScene extends Scene {
  QuizScene quiz;
  int pct, grade, bonus;
  boolean newBest;
  float t;

  ResultScene(QuizScene q) {
    quiz = q;
    pct = q.qs.isEmpty() ? 0 : round(100.0 * q.right / q.qs.size());
    grade = pct >= 90 ? 4 : pct >= 75 ? 3 : pct >= 60 ? 2 : pct >= 40 ? 1 : 0;
  }

  boolean realTopic() {
    return TOPICS.containsKey(quiz.topicKey) && quiz.level > 0;
  }

  void enter() {
    if (realTopic()) newBest = progress.record(quiz.topicKey, quiz.level, pct) && pct > 0;
    bonus = max(1, quiz.score / 20);
    progress.addXp(bonus);
    progress.save();
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.drunkMode = grade <= 1;
    rick.say(pick(RESULT_LINES[grade]));
    sfx.play(grade >= 2 ? sfx.fanfare : sfx.sad, 0.6);
    float y = 640;
    button("retry", "RETRY", 40, y, 140, 56).key("R");
    boolean nx = realTopic() && quiz.level < 4;
    if (nx) button("nextlv", "NEXT LEVEL >", 192, y, 190, 56).key("N").colour(LEVEL_COLS[quiz.level + 1]);
    int n = progress.mistakes(quiz.level).size();
    Button rv = button("review", "REVIEW", nx ? 394 : 192, y, 190, 56).key("V").colour(C_GOLD);
    rv.enabled = n > 0;
    button("topics", "MENU", 40, 572, 170, 56).key("T").colour(C_BLUE);
  }

  void update(float dt) {
    t += dt;
  }

  String gradeLetter() {
    return new String[] { "F", "D", "C", "B", "A" }[grade];
  }

  void draw() {
    space.draw();
    levelBadge(40, 22, quiz.level);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text(quiz.title + " - RESULTS", 40, 54);
    schmeckles(W - 20, 14);
    // grade disc
    float k = min(1, t / 0.6);
    k = 1 - pow(1 - k, 3);
    int gc = grade >= 3 ? C_GREEN : grade == 2 ? C_GOLD : C_RED;
    pushMatrix();
    translate(200, 268);
    scale(k);
    rotate((1 - k) * -1.2);
    drawPortal(0, 0, 130, 130, T * 1.4, 120);
    noStroke();
    fill(#0B1020, 220);
    ellipse(0, 0, 190, 190);
    textFont(createFontOnce());
    textAlign(CENTER, CENTER);
    fill(gc);
    text(gradeLetter(), 0, -12);
    textFont(fH2);
    fill(C_TEXT);
    text(pct + "%", 0, 58);
    popMatrix();
    // stats
    float x = 40, y = 428;
    textFont(fBodyB);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text(quiz.right + " / " + quiz.qs.size() + " correct", x, y);
    fill(C_GOLD);
    text(quiz.score + " points  (+" + (quiz.xpEarned + bonus) + " schmeckles)", x, y + 32);
    fill(C_DIM);
    text("best streak " + quiz.bestStreak, x, y + 64);
    if (newBest) {
      fill(C_GREEN);
      text("NEW BEST for this level!", x, y + 96);
    }
    // what you missed
    float px = 400, py = 110, pw = 840, ph = 430;
    panel(px, py, pw, ph, C_PANEL, C_EDGE, 18);
    textFont(fH2);
    fill(C_TEXT);
    textAlign(LEFT, TOP);
    text(quiz.missed.isEmpty() ? "NOTHING MISSED. SUSPICIOUS." : "STUDY THESE (" + quiz.missed.size() + " missed)", px + 24, py + 18);
    float cy = py + 64;
    textFont(fSmall);
    int shown = 0;
    for (Question q : quiz.missed) {
      String qt = q.q, at = "-> " + q.answerText();
      float h1 = textBlockHeight(qt, pw - 48, 20), h2 = textBlockHeight(at, pw - 48, 20);
      if (cy + h1 + h2 > py + ph - (quiz.review ? 96 : 40)) {
        fill(C_DIM);
        text("... and " + (quiz.missed.size() - shown) + " more in your REVIEW pile", px + 24, cy);
        break;
      }
      fill(#C9D6EE);
      cy += textBlock(qt, px + 24, cy, pw - 48, 20);
      fill(C_GREEN);
      cy += textBlock(at, px + 24, cy, pw - 48, 20) + 10;
      shown++;
    }
    if (quiz.review) {
      textFont(fBody);
      fill(C_DIM);
      float ry = quiz.missed.isEmpty() ? cy : py + ph - 70;
      textBlock("Out of the pile for good: " + quiz.cleared + ".  Moved up a box: " + quiz.climbing
        + " (one more right answer in a later review and they're gone).", px + 24, ry, pw - 48, 28);
    } else if (quiz.missed.isEmpty()) {
      textFont(fBody);
      fill(C_DIM);
      textBlock("Everything right. Either you studied, or the multiverse glitched. Try the next level before I check the logs.", px + 24, cy, pw - 48, 30);
    }
    drawButtons();
    rick.drawBox();
  }

  void clicked(Button b) {
    if (b.id.equals("retry")) {
      ArrayList<Question> qs = new ArrayList<Question>(quiz.qs);
      java.util.Collections.shuffle(qs);
      go(new QuizScene(quiz.title, qs, quiz.level, quiz.topicKey, quiz.review));
    }
    if (b.id.equals("nextlv")) go(new LessonScene(TOPICS.get(quiz.topicKey), quiz.level + 1));
    if (b.id.equals("review")) startReview(quiz.level);
    if (b.id.equals("topics")) back();
  }

  void back() {
    if (quiz.topicKey.equals("explore")) go(new ExploreScene(quiz.qs.isEmpty() ? null : quiz.qs.get(0).diagram));
    else if (quiz.level == 0) go(new DifficultyScene());
    else go(new TopicScene(quiz.level));
  }
}

PFont bigGrade;

PFont createFontOnce() {
  if (bigGrade == null) bigGrade = createFont("SansSerif.bold", 120, true);
  return bigGrade;
}


// ======================================================================
// TAB: Sound.pde
// ======================================================================
// Synthesized sound effects (Java's built-in javax.sound - nothing to install).
// Every sound is generated into a float array at startup; a small mixer
// thread plays any number of them at once. No audio device = silent game.


class Sfx implements Runnable {
  final float SR = 44100;
  SourceDataLine line;
  boolean ok, muted;
  final ArrayList<Voice> voices = new ArrayList<Voice>();
  java.util.Random rng = new java.util.Random(77);

  float[] burp, bigBurp, hic, blip, click, correct, wrong, portal, whoosh, fanfare, sad, tick, slurp, thud, streak;

  Sfx() {
    try {
      AudioFormat fmt = new AudioFormat(SR, 16, 1, true, false);
      line = AudioSystem.getSourceDataLine(fmt);
      line.open(fmt, 4096);
      line.start();
      build();
      ok = true;
      Thread th = new Thread(this, "rick-med-audio");
      th.setDaemon(true);
      th.start();
    } catch (Exception e) {
      println("No sound (" + e.getMessage() + ") - running silently.");
    }
  }

  void play(float[] s, float vol, float pitch) {
    if (!ok || s == null) return;
    synchronized (voices) {
      if (voices.size() < 24) voices.add(new Voice(s, vol, pitch));
    }
  }

  void play(float[] s, float vol) {
    play(s, vol, 1);
  }

  public void run() {
    int N = 512;
    float[] mix = new float[N];
    byte[] out = new byte[N * 2];
    while (true) {
      java.util.Arrays.fill(mix, 0);
      synchronized (voices) {
        for (int v = voices.size() - 1; v >= 0; v--) {
          Voice vc = voices.get(v);
          for (int i = 0; i < N; i++) {
            if (vc.pos >= vc.s.length - 1) break;
            int p = (int) vc.pos;
            float f = vc.pos - p;
            mix[i] += (vc.s[p] * (1 - f) + vc.s[p + 1] * f) * vc.vol;
            vc.pos += vc.pitch;
          }
          if (vc.pos >= vc.s.length - 1) voices.remove(v);
        }
      }
      float g = muted ? 0 : 0.75;
      for (int i = 0; i < N; i++) {
        int sv = (int) (Math.tanh(mix[i] * g) * 32000);
        out[i * 2] = (byte) (sv & 0xff);
        out[i * 2 + 1] = (byte) ((sv >> 8) & 0xff);
      }
      line.write(out, 0, out.length);
    }
  }

  // ---------------------------------------------------------------- synthesis
  float[] buf(float sec) {
    return new float[(int) (sec * SR)];
  }

  float nz() {
    return rng.nextFloat() * 2 - 1;
  }

  float[] makeBurp(float sec, float f0) {
    float[] s = buf(sec);
    float ph = 0, lp = 0;
    for (int i = 0; i < s.length; i++) {
      float t = i / SR;
      float f = f0 + 25 * sin(t * 18) + 30 * (1 - t / sec) + 12 * sin(t * 7.3);
      ph += f / SR;
      lp += (nz() - lp) * 0.08;
      float saw = (ph % 1) * 2 - 1;
      float flutter = 0.6 + 0.4 * sin(t * 70 + 3 * sin(t * 11));
      s[i] = (saw * 0.6 + lp * 0.8) * flutter * sin(PI * t / sec) * 0.95;
    }
    return s;
  }

  void build() {
    burp = makeBurp(0.55, 75);
    bigBurp = makeBurp(1.25, 62);

    hic = buf(0.16);
    float ph = 0;
    for (int i = 0; i < hic.length; i++) {
      float t = i / SR;
      ph += (380 + 900 * t / 0.16) / SR;
      hic[i] = (sin(TWO_PI * ph) * 0.6 + nz() * 0.25 * exp(-t * 60)) * sin(PI * t / 0.16) * 0.8;
    }

    blip = buf(0.03);
    for (int i = 0; i < blip.length; i++) {
      float t = i / SR;
      blip[i] = sin(TWO_PI * 210 * t) * exp(-t * 120) * 0.35;
    }

    click = tones(new float[] { 990 }, 0.05, 0.35);
    correct = tones(new float[] { 523, 659, 784, 1047 }, 0.07, 0.42);
    streak = tones(new float[] { 784, 988, 1175, 1568, 1976 }, 0.055, 0.38);
    fanfare = tones(new float[] { 392, 523, 659, 784, 659, 784, 1047 }, 0.11, 0.42);

    wrong = buf(0.42);
    float p2 = 0;
    for (int i = 0; i < wrong.length; i++) {
      float t = i / SR;
      p2 += (150 - 40 * t) / SR;
      float sq = (p2 % 1) < 0.5 ? 1 : -1;
      wrong[i] = (sq * 0.35 + ((p2 * 1.5) % 1 < 0.5 ? 0.2 : -0.2)) * min(1, t * 80) * exp(-t * 4) * 0.8;
    }

    sad = buf(1.6);
    float[] sadF = { 392, 370, 349, 330 };
    ph = 0;
    for (int i = 0; i < sad.length; i++) {
      float t = i / SR;
      int k = min(3, (int) (t / 0.32));
      float local = t - k * 0.32;
      float f = sadF[k] * (k == 3 ? 1 + 0.02 * sin(local * 40) : 1);
      ph += f / SR;
      float saw = (ph % 1) * 2 - 1;
      float env = min(1, local * 30) * (k == 3 ? exp(-local * 1.6) : exp(-local * 3));
      sad[i] = saw * env * 0.35;
    }

    portal = buf(1.0);
    ph = 0;
    float p3 = 0, lp = 0;
    for (int i = 0; i < portal.length; i++) {
      float t = i / SR;
      float f = 70 + 160 * (1 - exp(-t * 5));
      ph += f / SR;
      p3 += f * 1.507 / SR;
      lp += (nz() - lp) * (0.02 + 0.1 * t);
      float env = min(1, t * 20) * exp(-t * 2.8);
      portal[i] = (sin(TWO_PI * ph) * 0.6 + sin(TWO_PI * p3) * 0.3 + lp * 1.5 + sin(TWO_PI * ph * 4) * 0.12 * sin(t * 60)) * env;
    }

    whoosh = sweep(0.5, 300, 1800, 0.5);

    tick = buf(0.04);
    for (int i = 0; i < tick.length; i++) {
      float t = i / SR;
      tick[i] = sin(TWO_PI * 1800 * t) * exp(-t * 160) * 0.4;
    }

    slurp = buf(0.6);
    lp = 0;
    for (int i = 0; i < slurp.length; i++) {
      float t = i / SR;
      lp += (nz() - lp) * (0.05 + 0.25 * (0.5 + 0.5 * sin(t * 55)));
      slurp[i] = lp * sin(PI * t / 0.6) * 0.9;
    }

    thud = buf(0.3);
    for (int i = 0; i < thud.length; i++) {
      float t = i / SR;
      thud[i] = (sin(TWO_PI * 85 * t * (1 - t)) + nz() * 0.4 * exp(-t * 80)) * exp(-t * 16);
    }
  }

  float[] tones(float[] f, float each, float vol) {
    float[] s = buf(each * f.length + 0.18);
    for (int k = 0; k < f.length; k++) {
      int off = (int) (k * each * SR);
      for (int i = 0; i < (int) ((each + 0.18) * SR) && off + i < s.length; i++) {
        float t = i / SR;
        s[off + i] += (sin(TWO_PI * f[k] * t) + 0.3 * sin(TWO_PI * f[k] * 2 * t)) * exp(-t * 12) * vol;
      }
    }
    return s;
  }

  float[] sweep(float sec, float f0, float f1, float vol) {
    float[] s = buf(sec);
    float lp = 0, bp = 0;
    for (int i = 0; i < s.length; i++) {
      float t = i / SR;
      float k = constrain(lerp(f0, f1, t / sec) / SR * 6, 0.001, 0.9);
      lp += (nz() - lp) * k;
      bp += (lp - bp) * k * 0.5;
      s[i] = (lp - bp) * sin(PI * t / sec) * vol * 3;
    }
    return s;
  }
}

class Voice {
  float[] s;
  float vol, pitch, pos;

  Voice(float[] s, float vol, float pitch) {
    this.s = s;
    this.vol = vol;
    this.pitch = pitch;
  }
}


// ======================================================================
// TAB: UI.pde
// ======================================================================
// Look and feel: colours, fonts, buttons, text wrapping, the space backdrop.

final int C_BG = #070B16, C_PANEL = #121A2E, C_PANEL2 = #1B2540, C_EDGE = #2E3E66;
final int C_GREEN = #7CFF6B, C_GREEN_DK = #2E8B3A, C_TEXT = #EAF2FF, C_DIM = #8EA0C2;
final int C_GOLD = #FFD25A, C_RED = #FF5A5F, C_BLUE = #6FD3FF, C_PAPER = #F6F1E4, C_PAPER_EDGE = #D8CDB2;

PFont fTitle, fH1, fH2, fBody, fBodyB, fSmall, fMono, fRick, fExplain, fRickSmall;

void setupFonts() {
  fTitle = createFont("SansSerif.bold", 60, true);
  fH1 = createFont("SansSerif.bold", 38, true);
  fH2 = createFont("SansSerif.bold", 26, true);
  fBody = createFont("SansSerif.plain", 22, true);
  fBodyB = createFont("SansSerif.bold", 22, true);
  fSmall = createFont("SansSerif.plain", 16, true);
  fMono = createFont("Monospaced.bold", 16, true);
  fRick = createFont("SansSerif.bold", 21, true);
  fExplain = createFont("SansSerif.plain", 19, true);
  fRickSmall = createFont("SansSerif.bold", 18, true);
}

// ---------------------------------------------------------------- text helpers
// split into lines that fit width w with the CURRENT font/size
ArrayList<String> wrapText(String s, float w) {
  ArrayList<String> out = new ArrayList<String>();
  for (String para : s.split("\n")) {
    String line = "";
    for (String word : para.split(" ")) {
      if (word.length() == 0) continue;
      String t = line.length() == 0 ? word : line + " " + word;
      if (textWidth(t) > w && line.length() > 0) {
        out.add(line);
        line = word;
      } else line = t;
    }
    out.add(line);
  }
  return out;
}

// draws wrapped text top-left at (x, y); returns the height used
float textBlock(String s, float x, float y, float w, float lh) {
  ArrayList<String> ls = wrapText(s, w);
  textAlign(LEFT, TOP);
  for (int i = 0; i < ls.size(); i++) text(ls.get(i), x, y + i * lh);
  return ls.size() * lh;
}

float textBlockHeight(String s, float w, float lh) {
  return wrapText(s, w).size() * lh;
}

// one line where *burp* / *hic* style words are drawn in another colour
void richLine(String line, float x, float y, int base, int special) {
  textAlign(LEFT, TOP);
  float cx = x;
  for (String w : line.split(" ")) {
    boolean sp = w.startsWith("*");
    fill(sp ? special : base);
    text(w, cx, y);
    cx += textWidth(w + " ");
  }
}

String ellipsize(String s, float w) {
  if (textWidth(s) <= w) return s;
  while (s.length() > 1 && textWidth(s + "...") > w) s = s.substring(0, s.length() - 1);
  return s + "...";
}

// ---------------------------------------------------------------- panels
void panel(float x, float y, float w, float h, int fillC, int edge, float r) {
  noStroke();
  fill(0, 90);
  rect(x + 5, y + 7, w, h, r);
  fill(fillC);
  stroke(edge);
  strokeWeight(2);
  rect(x, y, w, h, r);
}

boolean over(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}

// ---------------------------------------------------------------- buttons
class Button {
  String id, label, sub, hotkey;
  float x, y, w, h;
  float hov;                 // hover animation 0..1
  int col = C_GREEN;
  boolean enabled = true, visible = true, showKey = true;
  PFont font;

  Button(String id, String label, float x, float y, float w, float h) {
    this.id = id;
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    font = fBodyB;
  }

  Button key(String k) {
    hotkey = k;
    return this;
  }

  Button colour(int c) {
    col = c;
    return this;
  }

  boolean over() {
    return visible && enabled && mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void draw() {
    if (!visible) return;
    hov += ((over() ? 1 : 0) - hov) * min(1, dt * 14);
    float lift = hov * 3;
    noStroke();
    fill(0, 110);
    rect(x + 4, y + 6, w, h, 14);
    int bg = enabled ? lerpColor(C_PANEL2, col, 0.18 + 0.22 * hov) : C_PANEL;
    fill(bg);
    stroke(enabled ? lerpColor(col, #FFFFFF, hov * 0.4) : C_EDGE);
    strokeWeight(2 + hov);
    rect(x, y - lift, w, h, 14);
    textFont(font);
    textAlign(CENTER, CENTER);
    fill(enabled ? C_TEXT : C_DIM);
    float cy = y - lift + h / 2 - (sub != null ? 11 : 2);
    float lx = x + w / 2 + (hotkey != null && showKey && hotkey.trim().length() > 0 ? 9 : 0);
    text(label, lx, cy);
    if (sub != null) {
      textFont(fSmall);
      fill(enabled ? C_DIM : #55617A);
      text(sub, lx, cy + 26);
    }
    if (hotkey != null && showKey && hotkey.trim().length() > 0) {
      textFont(fMono);
      textAlign(LEFT, TOP);
      fill(enabled ? col : C_EDGE);
      text(hotkey, x + 10, y - lift + 7);
    }
  }
}

// ---------------------------------------------------------------- the space backdrop
class SpaceBg {
  PGraphics img;
  float[] sx = new float[90], sy = new float[90], sp = new float[90];

  SpaceBg() {
    img = createGraphics(W, H);
    img.beginDraw();
    img.noStroke();
    for (int y = 0; y < H; y += 4) {
      float k = y / (float) H;
      img.fill(lerpColor(#0A1024, #04060D, k));
      img.rect(0, y, W, 4);
    }
    randomSeed(7);
    // soft nebula blobs
    for (int i = 0; i < 26; i++) {
      float x = random(W), y = random(H), r = random(120, 320);
      int c = i % 3 == 0 ? #2B7A4B : (i % 3 == 1 ? #3B2B7A : #1E4F7A);
      for (int k = 8; k >= 1; k--) {
        img.fill(c, 5);
        img.ellipse(x, y, r * k / 4, r * k / 5);
      }
    }
    for (int i = 0; i < 700; i++) {
      float b = random(80, 255);
      img.fill(b, b, 255, random(90, 230));
      float s = random(1) < 0.94 ? random(0.8, 1.8) : random(2, 3.2);
      img.ellipse(random(W), random(H), s, s);
    }
    img.endDraw();
    for (int i = 0; i < sx.length; i++) {
      sx[i] = random(W);
      sy[i] = random(H);
      sp[i] = random(0.5, 3);
    }
    randomSeed(millis());
  }

  void draw() {
    image(img, 0, 0);
    noStroke();
    for (int i = 0; i < sx.length; i++) {
      float a = 120 + 120 * sin(T * sp[i] + i);
      fill(220, 235, 255, a);
      ellipse(sx[i], sy[i], 2.4, 2.4);
    }
  }
}
