/* ============================================================
   JARVIS — Career Lab knowledge base
   Domain-tailored study decks (medicine, chemistry, computer
   science, engineering). Each deck expands into individually
   labelled items so JARVIS can scatter, drill and quiz them.
   ============================================================ */
(function () {
  'use strict';

  const g = (name, items) => ({ name, items });
  const one = (label, sub) => ({ label, sub: sub || '' });
  // A bone that exists on both sides of the body.
  const pair = (label, sub) => [
    { label: label + ' · L', sub: sub || '', side: 'left' },
    { label: label + ' · R', sub: sub || '', side: 'right' },
  ];
  const series = (fmt, from, to, sub) => {
    const out = [];
    for (let i = from; i <= to; i++) out.push({ label: fmt.replace('#', i), sub: sub || '' });
    return out;
  };
  const pairSeries = (fmt, from, to, sub) => {
    const out = [];
    for (let i = from; i <= to; i++) out.push(...pair(fmt.replace('#', i), sub));
    return out;
  };

  /* ---------------- MEDICINE ---------------- */

  // The complete adult human skeleton — 206 bones, individually named.
  function skeletonGroups() {
    const CARPALS = ['Scaphoid', 'Lunate', 'Triquetrum', 'Pisiform', 'Trapezium', 'Trapezoid', 'Capitate', 'Hamate'];
    const TARSALS = ['Calcaneus', 'Talus', 'Navicular', 'Cuboid', 'Medial cuneiform', 'Intermediate cuneiform', 'Lateral cuneiform'];
    const ROMAN = ['I', 'II', 'III', 'IV', 'V'];
    const FINGERS = ['Index', 'Middle', 'Ring', 'Little'];
    const TOES = ['2nd', '3rd', '4th', '5th'];

    const cranial = [
      one('Frontal', 'cranial'), ...pair('Parietal', 'cranial'), ...pair('Temporal', 'cranial'),
      one('Occipital', 'cranial'), one('Sphenoid', 'cranial'), one('Ethmoid', 'cranial'),
    ];                                                                        // 8
    const facial = [
      ...pair('Maxilla', 'facial'), ...pair('Palatine', 'facial'), ...pair('Zygomatic', 'facial'),
      ...pair('Nasal', 'facial'), ...pair('Lacrimal', 'facial'), ...pair('Inferior nasal concha', 'facial'),
      one('Vomer', 'facial'), one('Mandible', 'facial'),
    ];                                                                        // 14
    const ossicles = [...pair('Malleus', 'ear'), ...pair('Incus', 'ear'), ...pair('Stapes', 'ear')]; // 6
    const hyoid = [one('Hyoid', 'neck')];                                     // 1

    const vertebrae = [
      one('C1 · Atlas', 'cervical'), one('C2 · Axis', 'cervical'), ...series('C# vertebra', 3, 7, 'cervical'),
      ...series('T# vertebra', 1, 12, 'thoracic'),
      ...series('L# vertebra', 1, 5, 'lumbar'),
      one('Sacrum', 'fused'), one('Coccyx', 'fused'),
    ];                                                                        // 26
    const thorax = [one('Sternum', 'chest'), ...pairSeries('Rib #', 1, 12, 'chest')]; // 25

    const pectoral = [...pair('Clavicle', 'girdle'), ...pair('Scapula', 'girdle')];   // 4
    const arm = [...pair('Humerus', 'arm'), ...pair('Radius', 'forearm'), ...pair('Ulna', 'forearm')]; // 6
    const carpals = CARPALS.flatMap((c) => pair(c, 'wrist'));                 // 16
    const metacarpals = ROMAN.flatMap((r) => pair('Metacarpal ' + r, 'hand')); // 10
    const handPhalanges = [
      ...pair('Thumb proximal phalanx', 'hand'), ...pair('Thumb distal phalanx', 'hand'),
      ...FINGERS.flatMap((f) => [...pair(f + ' proximal phalanx', 'hand'), ...pair(f + ' middle phalanx', 'hand'), ...pair(f + ' distal phalanx', 'hand')]),
    ];                                                                        // 28

    const pelvic = [...pair('Hip bone (coxal)', 'girdle')];                   // 2
    const leg = [...pair('Femur', 'thigh'), ...pair('Patella', 'knee'), ...pair('Tibia', 'leg'), ...pair('Fibula', 'leg')]; // 8
    const tarsals = TARSALS.flatMap((t) => pair(t, 'ankle'));                 // 14
    const metatarsals = ROMAN.flatMap((r) => pair('Metatarsal ' + r, 'foot')); // 10
    const footPhalanges = [
      ...pair('Hallux proximal phalanx', 'foot'), ...pair('Hallux distal phalanx', 'foot'),
      ...TOES.flatMap((t) => [...pair(t + ' toe proximal phalanx', 'foot'), ...pair(t + ' toe middle phalanx', 'foot'), ...pair(t + ' toe distal phalanx', 'foot')]),
    ];                                                                        // 28

    return [
      g('Cranium', cranial), g('Facial bones', facial), g('Auditory ossicles', ossicles), g('Hyoid', hyoid),
      g('Vertebral column', vertebrae), g('Thoracic cage', thorax),
      g('Pectoral girdle', pectoral), g('Arm & forearm', arm), g('Carpals', carpals),
      g('Metacarpals', metacarpals), g('Hand phalanges', handPhalanges),
      g('Pelvic girdle', pelvic), g('Leg', leg), g('Tarsals', tarsals),
      g('Metatarsals', metatarsals), g('Foot phalanges', footPhalanges),
    ];
  }

  const CRANIAL_NERVES = [
    ['I', 'Olfactory', 'smell · sensory'], ['II', 'Optic', 'vision · sensory'],
    ['III', 'Oculomotor', 'eye movement · motor'], ['IV', 'Trochlear', 'superior oblique · motor'],
    ['V', 'Trigeminal', 'face sensation, chewing · both'], ['VI', 'Abducens', 'lateral rectus · motor'],
    ['VII', 'Facial', 'expression, taste · both'], ['VIII', 'Vestibulocochlear', 'hearing, balance · sensory'],
    ['IX', 'Glossopharyngeal', 'taste, swallowing · both'], ['X', 'Vagus', 'viscera, parasympathetic · both'],
    ['XI', 'Accessory', 'neck muscles · motor'], ['XII', 'Hypoglossal', 'tongue · motor'],
  ];

  const ORGAN_SYSTEMS = [
    ['Skeletal', 'support, movement, blood cell production'], ['Muscular', 'movement, posture, heat'],
    ['Nervous', 'sensing, signalling, control'], ['Cardiovascular', 'heart, blood, transport'],
    ['Respiratory', 'gas exchange'], ['Digestive', 'breakdown and absorption'],
    ['Endocrine', 'hormonal regulation'], ['Urinary', 'filtration and balance'],
    ['Reproductive', 'gamete production'], ['Integumentary', 'skin, barrier, thermoregulation'],
    ['Lymphatic / Immune', 'fluid balance, defence'],
  ];

  const VITALS = [
    ['Heart rate', '60–100 bpm'], ['Respiratory rate', '12–20 /min'], ['Blood pressure', '~120/80 mmHg'],
    ['Temperature', '36.5–37.5 °C'], ['SpO₂', '95–100 %'], ['Blood glucose (fasting)', '70–99 mg/dL'],
    ['Haemoglobin', 'M 13.5–17.5, F 12–15.5 g/dL'], ['Sodium', '135–145 mmol/L'],
    ['Potassium', '3.5–5.0 mmol/L'], ['pH (arterial)', '7.35–7.45'],
  ];

  /* ---------------- CHEMISTRY ---------------- */

  const ELEMENTS = ('H:Hydrogen He:Helium Li:Lithium Be:Beryllium B:Boron C:Carbon N:Nitrogen O:Oxygen F:Fluorine ' +
    'Ne:Neon Na:Sodium Mg:Magnesium Al:Aluminium Si:Silicon P:Phosphorus S:Sulfur Cl:Chlorine Ar:Argon K:Potassium ' +
    'Ca:Calcium Sc:Scandium Ti:Titanium V:Vanadium Cr:Chromium Mn:Manganese Fe:Iron Co:Cobalt Ni:Nickel Cu:Copper ' +
    'Zn:Zinc Ga:Gallium Ge:Germanium As:Arsenic Se:Selenium Br:Bromine Kr:Krypton Rb:Rubidium Sr:Strontium Y:Yttrium ' +
    'Zr:Zirconium Nb:Niobium Mo:Molybdenum Tc:Technetium Ru:Ruthenium Rh:Rhodium Pd:Palladium Ag:Silver Cd:Cadmium ' +
    'In:Indium Sn:Tin Sb:Antimony Te:Tellurium I:Iodine Xe:Xenon Cs:Caesium Ba:Barium La:Lanthanum Ce:Cerium ' +
    'Pr:Praseodymium Nd:Neodymium Pm:Promethium Sm:Samarium Eu:Europium Gd:Gadolinium Tb:Terbium Dy:Dysprosium ' +
    'Ho:Holmium Er:Erbium Tm:Thulium Yb:Ytterbium Lu:Lutetium Hf:Hafnium Ta:Tantalum W:Tungsten Re:Rhenium Os:Osmium ' +
    'Ir:Iridium Pt:Platinum Au:Gold Hg:Mercury Tl:Thallium Pb:Lead Bi:Bismuth Po:Polonium At:Astatine Rn:Radon ' +
    'Fr:Francium Ra:Radium Ac:Actinium Th:Thorium Pa:Protactinium U:Uranium Np:Neptunium Pu:Plutonium Am:Americium ' +
    'Cm:Curium Bk:Berkelium Cf:Californium Es:Einsteinium Fm:Fermium Md:Mendelevium No:Nobelium Lr:Lawrencium ' +
    'Rf:Rutherfordium Db:Dubnium Sg:Seaborgium Bh:Bohrium Hs:Hassium Mt:Meitnerium Ds:Darmstadtium Rg:Roentgenium ' +
    'Cn:Copernicium Nh:Nihonium Fl:Flerovium Mc:Moscovium Lv:Livermorium Ts:Tennessine Og:Oganesson').split(/\s+/);

  function elementGroups() {
    const bands = [
      ['Period 1–2 · the light elements', 0, 10],
      ['Period 3 · everyday chemistry', 10, 18],
      ['Period 4 · first transition series', 18, 36],
      ['Period 5', 36, 54],
      ['Period 6 · incl. lanthanides', 54, 86],
      ['Period 7 · incl. actinides', 86, 118],
    ];
    return bands.map(([name, a, b]) => g(name, ELEMENTS.slice(a, b).map((e, i) => {
      const [sym, nm] = e.split(':');
      return { label: sym, sub: nm, badge: String(a + i + 1) };
    })));
  }

  const POLYATOMIC = [
    ['NH₄⁺', 'ammonium'], ['OH⁻', 'hydroxide'], ['NO₃⁻', 'nitrate'], ['NO₂⁻', 'nitrite'],
    ['SO₄²⁻', 'sulfate'], ['SO₃²⁻', 'sulfite'], ['CO₃²⁻', 'carbonate'], ['HCO₃⁻', 'bicarbonate'],
    ['PO₄³⁻', 'phosphate'], ['CH₃COO⁻', 'acetate'], ['CN⁻', 'cyanide'], ['MnO₄⁻', 'permanganate'],
    ['Cr₂O₇²⁻', 'dichromate'], ['ClO₃⁻', 'chlorate'], ['O₂²⁻', 'peroxide'],
  ];

  const CHEM_CONSTANTS = [
    ['Avogadro', '6.022 × 10²³ /mol'], ['Gas constant R', '8.314 J/(mol·K)'],
    ['Molar volume STP', '22.4 L/mol'], ['Planck h', '6.626 × 10⁻³⁴ J·s'],
    ['Faraday', '96 485 C/mol'], ['Kw at 25 °C', '1.0 × 10⁻¹⁴'],
    ['Speed of light c', '2.998 × 10⁸ m/s'], ['Boltzmann k', '1.381 × 10⁻²³ J/K'],
  ];

  /* ---------------- COMPUTER SCIENCE ---------------- */

  const COMPLEXITY = [
    ['Binary search', 'O(log n)'], ['Linear search', 'O(n)'], ['Merge sort', 'O(n log n)'],
    ['Quick sort (avg)', 'O(n log n)'], ['Quick sort (worst)', 'O(n²)'], ['Bubble sort', 'O(n²)'],
    ['Heap sort', 'O(n log n)'], ['Counting sort', 'O(n + k)'], ['Dijkstra (binary heap)', 'O((V+E) log V)'],
    ['BFS / DFS', 'O(V + E)'], ['Floyd–Warshall', 'O(V³)'], ['Knapsack (DP)', 'O(nW)'],
  ];
  const STRUCTURES = [
    ['Array', 'index O(1), insert O(n)'], ['Linked list', 'insert O(1), index O(n)'],
    ['Hash table', 'avg O(1) lookup'], ['Binary search tree', 'O(log n) balanced'],
    ['Heap', 'O(log n) push/pop, O(1) peek'], ['Stack', 'LIFO, O(1)'], ['Queue', 'FIFO, O(1)'],
    ['Trie', 'O(k) by key length'], ['Graph', 'V vertices, E edges'], ['Union–Find', 'near O(1) amortised'],
  ];
  const CS_CONCEPTS = [
    ['Big-O', 'upper bound on growth'], ['Recursion', 'base case + self-call'],
    ['Memoisation', 'cache subproblem results'], ['Divide & conquer', 'split, solve, combine'],
    ['Greedy', 'best local choice'], ['Dynamic programming', 'optimal substructure'],
    ['ACID', 'atomicity, consistency, isolation, durability'], ['REST', 'stateless resource HTTP'],
    ['Race condition', 'timing-dependent bug'], ['Deadlock', 'circular resource wait'],
    ['Normalisation', 'remove DB redundancy'], ['Idempotence', 'same result on repeat'],
  ];

  /* ---------------- ENGINEERING ---------------- */

  const MECHANICS = [
    ['Newton II', 'F = ma'], ['Kinetic energy', 'KE = ½mv²'], ['Momentum', 'p = mv'],
    ['Work', 'W = F·d'], ['Power', 'P = W/t'], ['Torque', 'τ = r × F'],
    ['Stress', 'σ = F/A'], ['Strain', 'ε = ΔL/L'], ["Young's modulus", 'E = σ/ε'],
    ['Hooke', 'F = kx'], ['Pressure', 'P = F/A'], ['Bernoulli', 'P + ½ρv² + ρgh = const'],
  ];
  const ELECTRICAL = [
    ['Ohm', 'V = IR'], ['Power', 'P = VI = I²R'], ['Capacitance', 'C = Q/V'],
    ['Series R', 'R = R₁ + R₂'], ['Parallel R', '1/R = 1/R₁ + 1/R₂'],
    ['Impedance', 'Z = √(R² + X²)'], ['Resonance', 'f = 1/(2π√(LC))'],
    ['RC time constant', 'τ = RC'], ['Faraday', 'ε = −dΦ/dt'], ['Kirchhoff', 'ΣI = 0, ΣV = 0'],
  ];
  const ENG_CONSTANTS = [
    ['g (Earth)', '9.81 m/s²'], ['Gravitational G', '6.674 × 10⁻¹¹'],
    ['Speed of sound (air)', '343 m/s'], ['Water density', '1000 kg/m³'],
    ['Atmospheric pressure', '101.325 kPa'], ['Steel E', '~200 GPa'],
    ['Copper resistivity', '1.68 × 10⁻⁸ Ω·m'], ['Stefan–Boltzmann σ', '5.67 × 10⁻⁸'],
  ];

  const simple = (rows) => rows.map(([a, b]) => one(a, b));

  const DOMAINS = {
    medicine: {
      id: 'medicine', name: 'Medical Science', icon: '⚕', accent: '#5ce1b6',
      title: 'Doctor / Medical Student',
      blurb: 'Anatomy, physiology and clinical reference — drilled visually.',
      decks: [
        { id: 'bones', name: 'The 206 Bones', icon: '🦴', blurb: 'Every bone of the adult human skeleton, named individually.', groups: skeletonGroups() },
        { id: 'nerves', name: 'Cranial Nerves', icon: '🧠', blurb: 'All twelve, with function.', groups: [g('Cranial nerves I–XII', CRANIAL_NERVES.map(([r, n, f]) => ({ label: n, sub: f, badge: r })))] },
        { id: 'systems', name: 'Organ Systems', icon: '🫀', blurb: 'The eleven systems and their roles.', groups: [g('Organ systems', simple(ORGAN_SYSTEMS))] },
        { id: 'vitals', name: 'Vitals & Labs', icon: '📈', blurb: 'Normal adult reference ranges.', groups: [g('Reference ranges', simple(VITALS))] },
      ],
    },
    chemistry: {
      id: 'chemistry', name: 'Chemistry', icon: '⚗', accent: '#b48cff',
      title: 'Chemist / Scientist',
      blurb: 'The periodic table, ions and constants — as a holographic field.',
      decks: [
        { id: 'elements', name: 'Periodic Table · 118', icon: '⚛', blurb: 'Every element, symbol and atomic number.', groups: elementGroups() },
        { id: 'ions', name: 'Polyatomic Ions', icon: '🧪', blurb: 'The ions worth memorising.', groups: [g('Polyatomic ions', simple(POLYATOMIC))] },
        { id: 'constants', name: 'Constants', icon: '📐', blurb: 'Numbers you use constantly.', groups: [g('Chemical constants', simple(CHEM_CONSTANTS))] },
      ],
    },
    cs: {
      id: 'cs', name: 'Computer Science', icon: '⌘', accent: '#46b6ff',
      title: 'Software Engineer',
      blurb: 'Complexity, structures and the concepts interviews live on.',
      decks: [
        { id: 'bigo', name: 'Complexity · Big-O', icon: '📊', blurb: 'What each algorithm actually costs.', groups: [g('Time complexity', simple(COMPLEXITY))] },
        { id: 'ds', name: 'Data Structures', icon: '🗂', blurb: 'Trade-offs at a glance.', groups: [g('Data structures', simple(STRUCTURES))] },
        { id: 'concepts', name: 'Core Concepts', icon: '💡', blurb: 'The vocabulary of the field.', groups: [g('Concepts', simple(CS_CONCEPTS))] },
      ],
    },
    engineering: {
      id: 'engineering', name: 'Engineering', icon: '⚙', accent: '#ffc46b',
      title: 'Engineer',
      blurb: 'Mechanics, electrical theory and the constants behind them.',
      decks: [
        { id: 'mechanics', name: 'Mechanics & Materials', icon: '🛠', blurb: 'Force, energy, stress and strain.', groups: [g('Mechanics', simple(MECHANICS))] },
        { id: 'electrical', name: 'Electrical', icon: '⚡', blurb: 'Circuits and signals.', groups: [g('Electrical', simple(ELECTRICAL))] },
        { id: 'engconst', name: 'Constants', icon: '📏', blurb: 'Physical values worth knowing cold.', groups: [g('Constants', simple(ENG_CONSTANTS))] },
      ],
    },
  };

  // Flatten a deck's groups into a single ordered item list.
  function deckItems(deck) {
    const out = [];
    deck.groups.forEach((grp) => grp.items.forEach((it) => out.push({ ...it, group: grp.name })));
    return out;
  }
  function findDeck(deckId) {
    for (const d of Object.keys(DOMAINS)) {
      const hit = DOMAINS[d].decks.find((k) => k.id === deckId);
      if (hit) return { domain: DOMAINS[d], deck: hit };
    }
    return null;
  }

  window.JarvisCareer = {
    DOMAINS,
    domainIds: Object.keys(DOMAINS),
    getDomain: (id) => DOMAINS[id] || null,
    getDeck: findDeck,
    items: deckItems,
    count: (deckId) => { const f = findDeck(deckId); return f ? deckItems(f.deck).length : 0; },
  };
})();
