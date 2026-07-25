/* ============================================================
   JARVIS — Project Atlas
   Interactive holographic diagrams for the four career projects:
     C1 Medicine    · the human skeleton
     C2 Computer Sci· processor & memory architecture
     C3 Chemistry   · the atom
     C4 Engineering · four-stroke engine
   Every diagram is generated SVG with named, hoverable parts and
   an essential-notes dossier for each.
   ============================================================ */
(function () {
  'use strict';

  const P = (d, extra) => `<path d="${d}"${extra ? ' ' + extra : ''}/>`;
  const E = (cx, cy, rx, ry, extra) => `<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}"${extra ? ' ' + extra : ''}/>`;
  const R = (x, y, w, h, r) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r == null ? 3 : r}"/>`;
  const L = (x1, y1, x2, y2, w) => `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke-width="${w || 2}" stroke-linecap="round"/>`;
  const part = (id, body) => `<g class="ap" data-part="${id}">${body}</g>`;
  const mirror = (fn) => fn(1) + fn(-1);   // draw a side, then its mirror

  /* ---------------- C1 · HUMAN SKELETON ---------------- */
  // A long bone: tapered shaft with bulbous articular ends.
  function longBone(x1, y1, x2, y2, w, ew) {
    ew = ew || w * 1.9;
    return E(x1, y1, ew / 2, ew / 2.4) + E(x2, y2, ew / 2, ew / 2.4) + L(x1, y1, x2, y2, w);
  }
  function skeletonSVG() {
    let s = '';

    // ---- Skull ----
    s += part('cranium',
      P('M200 24 C166 24 142 47 139 78 C136 102 143 120 155 131 L157 142 L243 142 L245 131 C257 120 264 102 261 78 C258 47 234 24 200 24 Z') +
      E(179, 86, 13, 11, 'class="socket"') + E(221, 86, 13, 11, 'class="socket"') +
      P('M200 98 L192 118 L208 118 Z', 'class="socket"') +
      P('M163 60 C180 44 220 44 237 60', 'class="hair"'));
    s += part('mandible',
      P('M157 139 L160 160 C167 176 183 183 200 183 C217 183 233 176 240 160 L243 139 L233 139 L230 158 C225 169 214 175 200 175 C186 175 175 169 170 158 L167 139 Z'));

    // ---- Spine ----
    const vert = (y, w, h) => R(200 - w / 2, y, w, h, 2.5);
    let cerv = '', thor = '', lumb = '';
    for (let i = 0; i < 7; i++) cerv += vert(190 + i * 8, 26 - i * 0.4, 6);         // C1–C7
    for (let i = 0; i < 12; i++) thor += vert(248 + i * 9.2, 24 + i * 0.7, 7);      // T1–T12
    for (let i = 0; i < 5; i++) lumb += vert(360 + i * 11, 34 + i * 0.8, 8.5);      // L1–L5
    s += part('cervical', cerv);
    s += part('thoracic', thor);
    s += part('lumbar', lumb);

    // ---- Shoulder girdle ----
    s += part('clavicle', mirror((k) =>
      P(`M${200 + k * 12} 252 C${200 + k * 45} 244 ${200 + k * 75} 246 ${200 + k * 96} 256`, 'class="thick"')));
    s += part('scapula', mirror((k) =>
      P(`M${200 + k * 40} 258 L${200 + k * 104} 262 L${200 + k * 92} 316 L${200 + k * 46} 300 Z`, 'class="flat"')));

    // ---- Sternum + ribs ----
    s += part('sternum',
      P('M200 262 L190 268 L191 300 L196 344 L204 344 L209 300 L210 268 Z'));
    let ribs = '';
    for (let i = 0; i < 12; i++) {
      const y = 258 + i * 9.2;
      const spread = i < 7 ? 74 + i * 6 : 112 - (i - 7) * 9;
      const drop = 26 + i * 5.5;
      const endX = i < 7 ? 14 : 34 + (i - 7) * 10;      // true ribs reach the sternum
      const endY = y + drop + (i < 7 ? 8 : 16);
      ribs += mirror((k) =>
        P(`M${200 + k * 13} ${y} C${200 + k * spread} ${y + 2} ${200 + k * (spread + 6)} ${y + drop} ${200 + k * endX} ${endY}`, 'class="rib"'));
    }
    s += part('ribs', ribs);

    // ---- Arms ----
    s += part('humerus', mirror((k) => longBone(200 + k * 100, 268, 200 + k * 118, 400, 9)));
    s += part('ulna', mirror((k) => longBone(200 + k * 116, 404, 200 + k * 132, 520, 6)));
    s += part('radius', mirror((k) => longBone(200 + k * 126, 406, 200 + k * 146, 518, 5.5)));
    s += part('hand', mirror((k) => {
      let h = E(200 + k * 140, 530, 11, 9);                        // carpals
      for (let f = 0; f < 5; f++) {
        const a = -0.42 + f * 0.2;
        const bx = 200 + k * (140 + f * 1.5), by = 538;
        const mx = bx + k * Math.sin(a) * 20, my = by + Math.cos(a) * 20;
        const tx = bx + k * Math.sin(a) * 40, ty = by + Math.cos(a) * 40;
        h += L(bx, by, mx, my, 3.4) + L(mx, my, tx, ty, 2.8);
      }
      return h;
    }));

    // ---- Pelvis ----
    s += part('sacrum', P('M186 415 L214 415 L210 462 L200 478 L190 462 Z'));
    s += part('pelvis', mirror((k) =>
      P(`M${200 + k * 8} 412 C${200 + k * 62} 404 ${200 + k * 96} 424 ${200 + k * 88} 462 C${200 + k * 82} 490 ${200 + k * 44} 496 ${200 + k * 30} 474 C${200 + k * 20} 456 ${200 + k * 12} 436 ${200 + k * 8} 412 Z`, 'class="flat"')));

    // ---- Legs ----
    s += part('femur', mirror((k) => longBone(200 + k * 52, 470, 200 + k * 60, 664, 12, 26)));
    s += part('patella', mirror((k) => E(200 + k * 60, 676, 11, 9)));
    s += part('tibia', mirror((k) => longBone(200 + k * 56, 690, 200 + k * 52, 846, 10, 22)));
    s += part('fibula', mirror((k) => longBone(200 + k * 76, 694, 200 + k * 70, 842, 5, 12)));
    s += part('foot', mirror((k) => {
      let f = P(`M${200 + k * 40} 852 L${200 + k * 74} 852 L${200 + k * 80} 872 L${200 + k * 34} 872 Z`, 'class="flat"');
      for (let t = 0; t < 5; t++) {
        const x = 200 + k * (38 + t * 10);
        f += L(x, 874, x + k * 3, 892, 3);
      }
      return f;
    }));

    return `<svg viewBox="0 0 400 940" class="atlas-svg" xmlns="http://www.w3.org/2000/svg">${s}</svg>`;
  }

  const SKELETON_PARTS = {
    cranium: { name: 'Cranium', fn: 'The braincase — eight fused bones forming a rigid vault around the brain.', ref: 'Human skull', notes: [
      'Eight cranial bones: frontal, two parietal, two temporal, occipital, sphenoid, ethmoid.',
      'Joined by sutures — immovable fibrous joints that fuse through childhood.',
      'The foramen magnum in the occipital bone lets the brainstem pass to the spinal cord.',
      'The temporal bone houses the middle and inner ear, including the three ossicles.',
      'Newborn fontanelles (soft spots) let the skull deform during birth and allow brain growth.',
    ] },
    mandible: { name: 'Mandible', fn: 'The lower jaw — the only freely movable bone of the skull.', ref: 'Mandible', notes: [
      'The strongest bone of the face; articulates at the temporomandibular joint (TMJ).',
      'Carries the lower teeth in its alveolar process.',
      'Moved by masseter, temporalis and pterygoid muscles for chewing.',
      'The mental foramen transmits the mental nerve — a landmark for dental anaesthesia.',
      'Common fracture site, often in two places because it forms a bony ring.',
    ] },
    cervical: { name: 'Cervical Vertebrae · C1–C7', fn: 'The neck — the most mobile part of the spine, and it carries the head.', ref: 'Cervical vertebrae', notes: [
      'C1 (atlas) has no body and cradles the skull — it produces the "yes" nod.',
      'C2 (axis) has the odontoid peg (dens) that C1 pivots on — the "no" rotation.',
      'Uniquely, cervical vertebrae have transverse foramina carrying the vertebral arteries.',
      'C7 (vertebra prominens) has a long spinous process you can feel at the neck base.',
      'Cervical spinal cord injury above C4 threatens the diaphragm and breathing.',
    ] },
    thoracic: { name: 'Thoracic Vertebrae · T1–T12', fn: 'The chest spine — each pair anchors a rib.', ref: 'Thoracic vertebrae', notes: [
      'Twelve vertebrae, each with costal facets that articulate with the ribs.',
      'Long, downward-sloping spinous processes overlap like roof tiles, limiting extension.',
      'Naturally kyphotic (convex backwards); exaggeration causes a hunched posture.',
      'The thoracic spine is the least mobile region — stability protects the heart and lungs.',
      'Common site of osteoporotic compression fractures in the elderly.',
    ] },
    lumbar: { name: 'Lumbar Vertebrae · L1–L5', fn: 'The lower back — the largest vertebrae, bearing most of the body\'s load.', ref: 'Lumbar vertebrae', notes: [
      'Massive kidney-shaped bodies built for weight bearing; no costal facets, no transverse foramina.',
      'Naturally lordotic (convex forwards).',
      'The spinal cord ends around L1–L2 (conus medullaris); below it runs the cauda equina.',
      'L4–L5 and L5–S1 are the commonest sites of disc herniation and sciatica.',
      'Lumbar puncture is performed at L3–L4 or L4–L5, safely below the cord.',
    ] },
    clavicle: { name: 'Clavicle', fn: 'The collarbone — the only bony strut linking the arm to the axial skeleton.', ref: 'Clavicle', notes: [
      'S-shaped; articulates with the sternum medially and the acromion laterally.',
      'Holds the shoulder out from the chest so the arm can swing freely.',
      'The most commonly fractured bone in the body — typically the middle third.',
      'First bone to begin ossifying (5th week in utero) and last to finish (~25 years).',
      'The subclavian vessels and brachial plexus run just beneath it.',
    ] },
    scapula: { name: 'Scapula', fn: 'The shoulder blade — a floating plate that gives the arm its enormous range.', ref: 'Scapula', notes: [
      'Held to the trunk almost entirely by muscle, not bone — hence its mobility.',
      'The glenoid cavity is a shallow socket for the humeral head: mobile but unstable.',
      'Key landmarks: acromion, coracoid process and the spine of the scapula.',
      'Anchors the rotator cuff — supraspinatus, infraspinatus, teres minor, subscapularis.',
      'Scapulohumeral rhythm: the scapula rotates ~1° for every 2° of humeral abduction.',
    ] },
    sternum: { name: 'Sternum', fn: 'The breastbone — the front anchor of the rib cage.', ref: 'Sternum', notes: [
      'Three parts: manubrium, body and xiphoid process.',
      'The sternal angle (of Louis) marks rib 2 — the key landmark for counting ribs.',
      'Ribs 1–7 attach directly via costal cartilage ("true ribs").',
      'Rich in red marrow, so it is used for bone marrow aspiration.',
      'The landmark for CPR hand placement is the lower half of the sternum.',
    ] },
    ribs: { name: 'Ribs · 12 pairs', fn: 'The cage that shields the heart and lungs and drives breathing.', ref: 'Rib cage', notes: [
      'Ribs 1–7 true (direct to sternum), 8–10 false (shared cartilage), 11–12 floating.',
      'Elevated by intercostal muscles in a "bucket handle" motion to expand the chest.',
      'Each rib has a costal groove carrying the intercostal nerve and vessels along its lower border.',
      'Needles are inserted just ABOVE a rib to avoid that neurovascular bundle.',
      'Flail chest — three or more ribs broken in two places — causes paradoxical breathing.',
    ] },
    humerus: { name: 'Humerus', fn: 'The upper arm bone — from shoulder ball to elbow hinge.', ref: 'Humerus', notes: [
      'Its head forms the ball of the shoulder\'s ball-and-socket joint.',
      'The radial nerve spirals in the radial groove — mid-shaft fractures cause wrist drop.',
      'The surgical neck is a frequent fracture site and endangers the axillary nerve.',
      'Distally, the trochlea and capitulum articulate with the ulna and radius.',
      'The medial epicondyle shelters the ulnar nerve — the "funny bone".',
    ] },
    radius: { name: 'Radius', fn: 'The thumb-side forearm bone — it rotates to turn the palm.', ref: 'Radius (bone)', notes: [
      'Pronation and supination happen as the radius crosses over the ulna.',
      'Bears about 80% of the load at the wrist joint.',
      'Colles fracture — distal radius with dorsal displacement — is classic after a fall on an outstretched hand.',
      'The radial head is the elbow pivot; a pulled elbow in toddlers subluxes it.',
      'The radial pulse is taken just proximal to its distal end.',
    ] },
    ulna: { name: 'Ulna', fn: 'The little-finger-side forearm bone — the stable hinge of the elbow.', ref: 'Ulna', notes: [
      'The olecranon forms the point of the elbow.',
      'Its trochlear notch grips the humerus, making the elbow a true hinge.',
      'It is the stabiliser: the radius rotates around a relatively fixed ulna.',
      'Tapers distally — it contributes little to the wrist joint.',
      'A nightstick fracture is an isolated ulnar shaft break from a direct blow.',
    ] },
    hand: { name: 'Carpals, Metacarpals & Phalanges', fn: 'The hand — 27 bones per side, the most dexterous structure in the body.', ref: 'Human hand', notes: [
      '8 carpals in two rows: scaphoid, lunate, triquetrum, pisiform, trapezium, trapezoid, capitate, hamate.',
      '5 metacarpals and 14 phalanges — three per finger, two in the thumb.',
      'The scaphoid is the most fractured carpal; its blood supply risks avascular necrosis.',
      'The thumb\'s saddle joint gives opposition — the basis of a precision grip.',
      'The carpal tunnel carries the median nerve; compression causes carpal tunnel syndrome.',
    ] },
    pelvis: { name: 'Pelvis · Hip Bones', fn: 'The basin transmitting the body\'s weight from spine to legs.', ref: 'Pelvis', notes: [
      'Each hip bone fuses from three: ilium, ischium and pubis.',
      'They meet at the acetabulum — the deep socket of the hip joint.',
      'The female pelvis is wider with a rounder inlet and broader subpubic angle for childbirth.',
      'Protects the bladder, rectum and reproductive organs.',
      'Pelvic fractures can bleed catastrophically from the rich venous plexus.',
    ] },
    sacrum: { name: 'Sacrum & Coccyx', fn: 'The fused base of the spine, wedged between the hip bones.', ref: 'Sacrum', notes: [
      'The sacrum is five fused vertebrae (S1–S5); the coccyx is three to five more.',
      'Transmits the entire upper-body load into the pelvic ring at the sacroiliac joints.',
      'Sacral foramina transmit the sacral nerve roots.',
      'The sacral hiatus is the access point for caudal epidural anaesthesia.',
      'The coccyx anchors the pelvic floor; coccydynia follows falls onto the tailbone.',
    ] },
    femur: { name: 'Femur', fn: 'The thigh bone — the longest, strongest bone in the body.', ref: 'Femur', notes: [
      'Roughly a quarter of adult height; withstands several times body weight when running.',
      'Its head sits in the acetabulum; the neck is the classic osteoporotic fracture site.',
      'A fractured neck of femur classically shortens and externally rotates the leg.',
      'Blood supply to the head runs retrograde up the neck — fracture risks avascular necrosis.',
      'The greater and lesser trochanters anchor the gluteal and iliopsoas muscles.',
    ] },
    patella: { name: 'Patella', fn: 'The kneecap — the body\'s largest sesamoid bone.', ref: 'Patella', notes: [
      'Sits inside the quadriceps tendon, sliding in the femoral groove.',
      'Acts as a pulley, increasing the quadriceps\' leverage by roughly 30%.',
      'Has the thickest articular cartilage in the body — it takes huge compressive loads.',
      'Dislocates laterally; patellofemoral pain is a very common knee complaint.',
      'The patellar reflex tests the L3–L4 nerve roots.',
    ] },
    tibia: { name: 'Tibia', fn: 'The shin bone — the weight-bearing bone of the lower leg.', ref: 'Tibia', notes: [
      'Second largest bone; carries essentially all the load from knee to ankle.',
      'Its subcutaneous anterior border (the shin) makes open fractures common.',
      'The medial malleolus forms the inner ankle bump.',
      'The tibial plateau articulates with the femur through the menisci.',
      'Poor anterior soft-tissue cover means slow healing and infection risk.',
    ] },
    fibula: { name: 'Fibula', fn: 'The slender outer strut — muscle anchor and ankle stabiliser.', ref: 'Fibula', notes: [
      'Bears only about 10% of body weight — it is chiefly for muscle attachment.',
      'The lateral malleolus forms the outer ankle and stabilises the joint.',
      'The common peroneal nerve wraps its neck — injury causes foot drop.',
      'Frequently harvested as a graft to reconstruct other bones, e.g. the mandible.',
      'A Maisonneuve fracture pairs a proximal fibular break with an ankle injury.',
    ] },
    foot: { name: 'Tarsals, Metatarsals & Phalanges', fn: 'The foot — 26 bones per side forming shock-absorbing arches.', ref: 'Human foot', notes: [
      '7 tarsals: calcaneus, talus, navicular, cuboid and three cuneiforms.',
      'The talus takes the body\'s entire weight and has no muscle attachments.',
      'The calcaneus is the heel and the largest tarsal — the Achilles tendon inserts on it.',
      'Medial, lateral and transverse arches absorb impact and return energy in gait.',
      'A march (stress) fracture typically affects the 2nd or 3rd metatarsal.',
    ] },
  };

  /* ---------------- C2 · COMPUTER ARCHITECTURE ---------------- */
  function computerSVG() {
    let s = '';
    const box = (id, x, y, w, h, label, sub) => part(id,
      R(x, y, w, h, 8) +
      `<text x="${x + w / 2}" y="${y + h / 2 - (sub ? 4 : -4)}" class="lbl">${label}</text>` +
      (sub ? `<text x="${x + w / 2}" y="${y + h / 2 + 13}" class="sublbl">${sub}</text>` : ''));

    // CPU package
    s += `<g class="frame">${R(60, 40, 280, 250, 12)}<text x="200" y="30" class="lbl">CPU PACKAGE</text></g>`;
    s += box('alu', 82, 70, 112, 58, 'ALU', 'arithmetic');
    s += box('cu', 206, 70, 112, 58, 'Control', 'decode/issue');
    s += box('registers', 82, 142, 236, 42, 'Registers', 'nanosecond storage');
    s += box('l1', 82, 196, 112, 36, 'L1 cache', '~32 KB');
    s += box('l2', 206, 196, 112, 36, 'L2 cache', '~1 MB');
    s += box('l3', 82, 242, 236, 34, 'L3 cache · shared', '~32 MB');

    // Bus
    s += part('bus', L(200, 292, 200, 330, 6) + L(96, 330, 344, 330, 6) +
      `<text x="200" y="322" class="sublbl">SYSTEM BUS</text>`);

    s += box('ram', 60, 344, 130, 62, 'RAM', 'volatile · ns');
    s += box('gpu', 210, 344, 130, 62, 'GPU', 'parallel cores');
    s += box('storage', 60, 424, 130, 62, 'SSD', 'persistent · µs');
    s += box('io', 210, 424, 130, 62, 'I/O · NIC', 'ms latency');
    return `<svg viewBox="0 0 400 520" class="atlas-svg wire" xmlns="http://www.w3.org/2000/svg">${s}</svg>`;
  }
  const COMPUTER_PARTS = {
    alu: { name: 'ALU — Arithmetic Logic Unit', fn: 'The part that actually computes: adds, compares, shifts and does boolean logic.', ref: 'Arithmetic logic unit', notes: [
      'Executes integer arithmetic and bitwise logic; floating point goes to a separate FPU/SIMD unit.',
      'Sets condition flags (zero, carry, overflow, negative) that drive branch instructions.',
      'Modern cores have several ALUs so independent instructions issue in the same cycle.',
      'Built from adders and multiplexers — a ripple-carry adder is O(n), carry-lookahead is O(log n).',
      'ALU work is nearly free compared to memory access; that ratio drives most optimisation.',
    ] },
    cu: { name: 'Control Unit', fn: 'Fetches, decodes and schedules instructions — the conductor of the core.', ref: 'Control unit', notes: [
      'Runs the fetch–decode–execute cycle, tracked by the program counter.',
      'Decodes machine code into micro-operations for the execution units.',
      'Pipelining overlaps stages so one instruction can retire per cycle despite multi-cycle latency.',
      'Branch prediction guesses the path ahead; a misprediction costs ~15–20 cycles.',
      'Out-of-order execution reorders work around stalls, then retires results in program order.',
    ] },
    registers: { name: 'Registers', fn: 'The handful of storage slots inside the core — the fastest memory that exists.', ref: 'Processor register', notes: [
      'Access takes a single cycle — roughly 100× faster than L1 cache.',
      'x86-64 exposes 16 general-purpose registers; ARM64 exposes 31.',
      'Register allocation is one of a compiler\'s most consequential jobs.',
      'Register renaming removes false dependencies so instructions can run out of order.',
      'A context switch must save and restore the whole register file — part of its cost.',
    ] },
    l1: { name: 'L1 Cache', fn: 'The tiny, blisteringly fast cache closest to the core.', ref: 'CPU cache', notes: [
      'Typically 32–64 KB, split into separate instruction and data caches.',
      'Roughly 4 cycles to access — about 1 ns.',
      'Private to a single core.',
      'Data moves in 64-byte cache lines, which is why sequential access is so much faster.',
      'False sharing — two cores writing different variables in one line — silently destroys performance.',
    ] },
    l2: { name: 'L2 Cache', fn: 'The mid-level cache backing L1.', ref: 'CPU cache', notes: [
      'Around 256 KB – 2 MB per core; roughly 12–20 cycles.',
      'Usually unified — instructions and data together.',
      'Catches what L1 misses before the expensive trip to L3 or RAM.',
      'Hardware prefetchers here spot access patterns and pull lines in early.',
      'The working-set size relative to L2 often decides whether an algorithm is fast.',
    ] },
    l3: { name: 'L3 Cache', fn: 'The large last-level cache shared by every core on the die.', ref: 'CPU cache', notes: [
      'Typically 8–64 MB, shared; roughly 40–75 cycles.',
      'Being shared, it is also the medium for inter-core coherence traffic.',
      'Cache coherence protocols (MESI) keep every core\'s view of memory consistent.',
      'A last-level miss means a DRAM access — hundreds of cycles.',
      'The full hierarchy exists because memory is far slower than logic: the "memory wall".',
    ] },
    bus: { name: 'System Bus / Interconnect', fn: 'The pathways carrying addresses, data and control between every component.', ref: 'Bus (computing)', notes: [
      'Classically three buses: address, data and control.',
      'Bus width and clock set peak bandwidth (width × frequency).',
      'Modern designs use point-to-point links and on-die meshes instead of one shared bus.',
      'PCIe connects the GPU and NVMe storage over serial lanes.',
      'The von Neumann bottleneck: CPU and memory share a path, and it limits throughput.',
    ] },
    ram: { name: 'RAM — Main Memory', fn: 'Volatile working memory holding running programs and their data.', ref: 'Random-access memory', notes: [
      'DRAM stores each bit as charge in a capacitor and must be refreshed thousands of times a second.',
      'Access latency ~60–100 ns — hundreds of CPU cycles.',
      'Volatile: contents vanish when power is lost.',
      'Virtual memory maps process addresses to physical frames via page tables and the TLB.',
      'When RAM is exhausted the OS swaps pages to disk, and performance collapses.',
    ] },
    gpu: { name: 'GPU', fn: 'Thousands of simple cores for problems that are wide rather than branchy.', ref: 'Graphics processing unit', notes: [
      'Optimised for throughput, not latency — the opposite trade-off from a CPU.',
      'SIMT execution: threads run in lockstep warps, so divergent branches cost dearly.',
      'Very high memory bandwidth (HBM/GDDR) feeds the cores.',
      'Excels at matrix maths — hence graphics, and hence deep learning.',
      'Transfers over PCIe are expensive; keeping data resident on the device matters.',
    ] },
    storage: { name: 'SSD — Persistent Storage', fn: 'Non-volatile storage that survives power loss.', ref: 'Solid-state drive', notes: [
      'NAND flash; NVMe latency ~50–100 µs, roughly 1000× slower than RAM.',
      'Erased in large blocks but written in smaller pages — hence write amplification.',
      'Wear levelling spreads writes because cells tolerate limited erase cycles.',
      'The TRIM command lets the drive reclaim deleted blocks.',
      'Filesystems and databases assume this latency gap — it is why they buffer and batch.',
    ] },
    io: { name: 'I/O & Network Interface', fn: 'The boundary to the outside world — the slowest tier by far.', ref: 'Input/output', notes: [
      'Network latency runs from ~0.5 ms on a LAN to hundreds of ms across the world.',
      'DMA lets devices move data to memory without occupying the CPU.',
      'Interrupts signal completion so the CPU need not poll.',
      'Blocking I/O wastes a thread; async I/O and event loops exist to avoid that.',
      'Know the latency ladder: register → cache → RAM → SSD → network, each ~100–1000× slower.',
    ] },
  };

  /* ---------------- C3 · THE ATOM ---------------- */
  function atomSVG() {
    let s = '';
    const cx = 200, cy = 260;
    s += part('shell_n', `<circle cx="${cx}" cy="${cy}" r="200" class="orb"/>` +
      `<text x="${cx}" y="${cy - 205}" class="sublbl">N · 4th shell</text>`);
    s += part('shell_m', `<circle cx="${cx}" cy="${cy}" r="152" class="orb"/>` +
      `<text x="${cx}" y="${cy - 157}" class="sublbl">M · 3rd shell</text>`);
    s += part('shell_l', `<circle cx="${cx}" cy="${cy}" r="104" class="orb"/>` +
      `<text x="${cx}" y="${cy - 109}" class="sublbl">L · 2nd shell</text>`);
    s += part('shell_k', `<circle cx="${cx}" cy="${cy}" r="58" class="orb"/>` +
      `<text x="${cx}" y="${cy - 63}" class="sublbl">K · 1st shell</text>`);

    // electrons on each shell
    const shellE = (r, n, cls) => {
      let e = '';
      for (let i = 0; i < n; i++) {
        const a = (i / n) * Math.PI * 2 + r * 0.03;
        e += `<circle cx="${(cx + Math.cos(a) * r).toFixed(1)}" cy="${(cy + Math.sin(a) * r).toFixed(1)}" r="7" class="${cls}"/>`;
      }
      return e;
    };
    s += part('electron', shellE(58, 2, 'el') + shellE(104, 8, 'el') + shellE(152, 8, 'el'));
    s += part('valence', shellE(200, 4, 'el val'));

    // nucleus
    let nuc = '';
    const NP = [[0, -12], [11, -5], [-11, -5], [6, 8], [-6, 8], [0, 0], [15, 6], [-15, 6], [8, -14], [-8, -14]];
    NP.forEach(([dx, dy], i) => {
      nuc += `<circle cx="${cx + dx}" cy="${cy + dy}" r="9" class="${i % 2 ? 'neutron' : 'proton'}"/>`;
    });
    s += part('nucleus', nuc);
    return `<svg viewBox="0 0 400 520" class="atlas-svg wire" xmlns="http://www.w3.org/2000/svg">${s}</svg>`;
  }
  const ATOM_PARTS = {
    nucleus: { name: 'Nucleus', fn: 'The dense core holding protons and neutrons — essentially all of the atom\'s mass.', ref: 'Atomic nucleus', notes: [
      'About 10⁻¹⁵ m across — roughly 100,000× smaller than the atom, yet >99.9% of its mass.',
      'Held together by the strong nuclear force, which overcomes proton–proton repulsion at short range.',
      'The proton count (atomic number Z) defines the element; the neutron count defines the isotope.',
      'Mass defect: the nucleus weighs less than its parts, and E = mc² accounts for the binding energy.',
      'Too many or too few neutrons makes it unstable — it decays by alpha, beta or gamma emission.',
    ] },
    electron: { name: 'Electrons & Inner Shells', fn: 'Negatively charged particles occupying quantised energy levels around the nucleus.', ref: 'Electron', notes: [
      'Charge −1, mass ~1/1836 of a proton.',
      'Shell capacity is 2n²: K holds 2, L holds 8, M holds 18, N holds 32.',
      'They occupy orbitals (s, p, d, f) — probability clouds, not neat planetary paths.',
      'Pauli exclusion: no two electrons in an atom share all four quantum numbers.',
      'Absorbing a photon promotes an electron; falling back emits one at a characteristic wavelength — the basis of spectroscopy.',
    ] },
    valence: { name: 'Valence Electrons', fn: 'The outermost electrons — they alone determine chemical behaviour.', ref: 'Valence electron', notes: [
      'Chemistry is almost entirely the story of the valence shell.',
      'The octet rule: atoms tend toward eight valence electrons (two for hydrogen and helium).',
      'A group number in the periodic table tells you the valence count — which is why groups behave alike.',
      'Lose them → cation; gain them → anion; share them → covalent bond.',
      'Metals hold them loosely, giving a delocalised "sea" and hence conductivity.',
    ] },
    shell_k: { name: 'K Shell · n = 1', fn: 'The innermost, lowest-energy shell — closest to the nucleus.', ref: 'Electron shell', notes: [
      'Holds a maximum of 2 electrons in a single 1s orbital.',
      'Most tightly bound — the hardest electrons to remove.',
      'Knocking out a K electron produces the characteristic X-rays used in XRF analysis.',
      'Helium fills it exactly, which is why it is inert.',
      'Shell energies are quantised: electrons cannot exist between levels.',
    ] },
    shell_l: { name: 'L Shell · n = 2', fn: 'The second shell — home to the 2s and 2p orbitals.', ref: 'Electron shell', notes: [
      'Holds up to 8 electrons: 2 in 2s, 6 across three 2p orbitals.',
      'It is the valence shell for period 2 — lithium through neon.',
      'Carbon\'s four L-shell valence electrons enable the whole of organic chemistry.',
      'Hybridisation (sp, sp², sp³) mixes 2s and 2p to explain molecular geometry.',
      'Neon fills it, hence its inertness.',
    ] },
    shell_m: { name: 'M Shell · n = 3', fn: 'The third shell — 3s, 3p and 3d orbitals.', ref: 'Electron shell', notes: [
      'Capacity 18: 2 in 3s, 6 in 3p, 10 in 3d.',
      'The 4s orbital fills before 3d (the Aufbau order), which is why potassium precedes scandium.',
      'Partially filled 3d orbitals give transition metals their variable oxidation states and colour.',
      'Expanded octets become possible from period 3 — hence SF₆ and PCl₅.',
      'Argon fills 3s and 3p, completing a stable configuration.',
    ] },
    shell_n: { name: 'N Shell · n = 4 (Valence)', fn: 'The outer shell shown here — the frontier where bonding happens.', ref: 'Electron shell', notes: [
      'Capacity 32: 4s, 4p, 4d and 4f.',
      'Electrons here are shielded from the nucleus by the inner shells, so they are held loosely.',
      'Ionisation energy falls down a group as this distance and shielding grow.',
      'Effective nuclear charge rises across a period, shrinking atoms left to right.',
      'The 4f orbitals give the lanthanides their near-identical chemistry.',
    ] },
  };

  /* ---------------- C4 · FOUR-STROKE ENGINE ---------------- */
  function engineSVG() {
    let s = '';
    // cylinder + head
    s += part('cylinder', R(120, 60, 160, 250, 10) + `<text x="200" y="50" class="lbl">CYLINDER</text>`);
    s += part('sparkplug', R(188, 20, 24, 44, 5) + L(200, 64, 200, 82, 3));
    s += part('valve', mirror((k) => L(200 + k * 46, 70, 200 + k * 46, 128, 7) + E(200 + k * 46, 132, 17, 6)));
    s += part('piston', R(132, 150, 136, 56, 6) + L(140, 162, 260, 162, 3) + L(140, 172, 260, 172, 3));
    s += part('conrod', L(200, 206, 200, 300, 12));
    s += part('crankshaft', `<circle cx="200" cy="342" r="46" class="orb"/>` + L(200, 300, 200, 342, 12) + `<circle cx="200" cy="342" r="12"/>`);
    s += part('flywheel', `<circle cx="200" cy="342" r="72" class="orb dash"/>`);
    s += part('camshaft', mirror((k) => `<circle cx="${200 + k * 46}" cy="${34}" r="16" class="orb"/>` + E(200 + k * 46, 26, 7, 11)));
    s += part('bearing', mirror((k) => `<circle cx="${200 + k * 96}" cy="342" r="18" class="orb"/>` + `<circle cx="${200 + k * 96}" cy="342" r="7"/>`));
    return `<svg viewBox="0 0 400 440" class="atlas-svg wire" xmlns="http://www.w3.org/2000/svg">${s}</svg>`;
  }
  const ENGINE_PARTS = {
    cylinder: { name: 'Cylinder & Block', fn: 'The bore the piston travels in — the pressure vessel where combustion happens.', ref: 'Cylinder (engine)', notes: [
      'Swept volume × cylinder count = engine displacement.',
      'Compression ratio = (swept + clearance) ÷ clearance; ~10:1 petrol, ~18:1 diesel.',
      'Walls are honed with a cross-hatch pattern to retain an oil film.',
      'Surrounded by water jackets — roughly a third of fuel energy leaves as heat.',
      'Bore/stroke ratio sets character: oversquare revs high, undersquare makes low-end torque.',
    ] },
    piston: { name: 'Piston', fn: 'Converts gas pressure into linear force, and takes the beating for it.', ref: 'Piston', notes: [
      'Aluminium alloy — light, because it reverses direction thousands of times a minute.',
      'Rings seal combustion gases and control oil; blow-by past them costs power.',
      'Peak acceleration can exceed 10,000 g at high rpm.',
      'The crown shape controls swirl, turbulence and flame propagation.',
      'Piston slap and thermal expansion are why cold clearances are specified precisely.',
    ] },
    conrod: { name: 'Connecting Rod', fn: 'Links piston to crank, turning reciprocating motion into rotary motion.', ref: 'Connecting rod', notes: [
      'Loaded in compression on the power stroke and in tension on the exhaust stroke.',
      'Rod ratio (length ÷ stroke) governs side-thrust on the cylinder wall.',
      'The big end runs on a plain bearing fed by pressurised oil.',
      'Buckling is the critical failure mode — hence the I-beam section.',
      'A thrown rod is catastrophic; over-revving is the usual cause.',
    ] },
    crankshaft: { name: 'Crankshaft', fn: 'Collects each piston\'s push and delivers smooth rotation.', ref: 'Crankshaft', notes: [
      'Offset journals convert linear motion to rotation; the offset sets the stroke.',
      'Counterweights balance reciprocating mass and reduce vibration.',
      'Torsional vibration is damped by a harmonic balancer at the nose.',
      'Firing order is chosen to spread power pulses and cancel forces.',
      'Journals ride on hydrodynamic oil films — metal never touches metal in health.',
    ] },
    valve: { name: 'Valves', fn: 'Gatekeepers of intake and exhaust — they set how well the engine breathes.', ref: 'Poppet valve', notes: [
      'Exhaust valves run red hot (~700 °C) and are often sodium-filled to shed heat.',
      'Valve timing and overlap trade low-end torque against top-end power.',
      'Volumetric efficiency — how completely the cylinder fills — largely decides output.',
      'Valve float at high rpm is when springs cannot close them fast enough.',
      'In an interference engine, a snapped cam belt lets pistons strike valves.',
    ] },
    camshaft: { name: 'Camshaft', fn: 'The lobed shaft that opens the valves at exactly the right moment.', ref: 'Camshaft', notes: [
      'Turns at half crankshaft speed — one cycle spans two crank revolutions.',
      'Lobe profile sets lift and duration, and thus the engine\'s whole personality.',
      'Driven by belt, chain or gears in strict time with the crank.',
      'Variable valve timing rotates the cam to shift the powerband.',
      'DOHC separates intake and exhaust cams, allowing four valves per cylinder.',
    ] },
    sparkplug: { name: 'Spark Plug', fn: 'Ignites the compressed charge at a precisely timed instant.', ref: 'Spark plug', notes: [
      'Fires tens of thousands of volts across a gap of roughly 0.7–1.1 mm.',
      'Ignition timing is advanced before top dead centre so peak pressure lands just after it.',
      'Too much advance causes knock — uncontrolled detonation that destroys pistons.',
      'Heat range describes how fast the plug sheds heat, not how hot the spark is.',
      'Diesels have no plugs: compression alone raises the charge above autoignition.',
    ] },
    flywheel: { name: 'Flywheel', fn: 'Stores rotational energy to carry the engine through its non-powered strokes.', ref: 'Flywheel', notes: [
      'Only one stroke in four makes power; the flywheel\'s inertia smooths the other three.',
      'Energy stored = ½Iω² — inertia matters, and so does speed, squared.',
      'A heavy flywheel idles smoothly; a light one revs faster but idles roughly.',
      'Carries the ring gear the starter motor engages.',
      'Its face is the clutch friction surface in a manual transmission.',
    ] },
    bearing: { name: 'Bearings', fn: 'Low-friction supports carrying the crank\'s enormous loads.', ref: 'Plain bearing', notes: [
      'Plain (journal) bearings float the shaft on a pressurised oil film — hydrodynamic lubrication.',
      'They are designed as the sacrificial part: soft shells protect the hard crank.',
      'The Stribeck curve maps boundary, mixed and hydrodynamic regimes.',
      'Most engine wear happens at cold start, before oil pressure builds.',
      'Oil clearance is measured with Plastigauge — typically ~0.001 in per inch of journal.',
    ] },
  };

  const PROJECTS = {
    c1: { code: 'C1', domain: 'medicine', title: 'Human Skeleton', accent: '#5ce1b6',
      blurb: 'Full articulated skeleton — hover a bone to inspect, click for the full dossier.',
      svg: skeletonSVG, parts: SKELETON_PARTS, deck: 'bones' },
    c2: { code: 'C2', domain: 'cs', title: 'Processor & Memory Architecture', accent: '#46b6ff',
      blurb: 'The machine beneath the code — from ALU to network, with the latency ladder.',
      svg: computerSVG, parts: COMPUTER_PARTS, deck: 'bigo' },
    c3: { code: 'C3', domain: 'chemistry', title: 'The Atom', accent: '#b48cff',
      blurb: 'Nucleus, shells and valence electrons — where all chemistry begins.',
      svg: atomSVG, parts: ATOM_PARTS, deck: 'elements' },
    c4: { code: 'C4', domain: 'engineering', title: 'Four-Stroke Engine', accent: '#ffc46b',
      blurb: 'Intake, compression, power, exhaust — and every component that survives it.',
      svg: engineSVG, parts: ENGINE_PARTS, deck: 'mechanics' },
  };

  window.JarvisAtlas = {
    PROJECTS,
    get(code) { return PROJECTS[String(code || '').toLowerCase()] || null; },
    codes: Object.keys(PROJECTS),
  };
})();
