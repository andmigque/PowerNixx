

Add-PodeWebPage -Name 'Codex' -ArgumentList $script:Codex -Icon 'Book-Open-Page-Variant' -Group 'Forge' -ScriptBlock {
$script:Codex = @'
# Codex Lyricus 📜

> A rules engine for consistently creating emotionally resonant lyrics

## The Polysymmetric Base 🌸🧠 

> The intentional usage of words that serve multiple parts of speech with the intent to create simultaneous vectors of meaning. A single word functioning across multiple word categories enables listeners to construct different valid interpretations of the same line.

__Example__: "I found the company on a lie"
- _found_ (past tense of find: discovered) = "I caught/detected the company lying"
- _found_ (past tense of found: established) = "I built/started the company based on a lie"  
- _found_ (past tense of find: located) = "I discovered the company exists upon deception"
- _found_ (past tense of find: encountered) = "I came across the company while investigating a lie"
- _found_ (past tense of find: obtained) = "I acquired the company through deceptive means"
- _found_ (past tense of find: determined) = "I concluded the company operates on falsehood"
- _found_ (past tense of find: met with) = "I encountered the company in a state of lying"
- _found_ (adjective: discovered/detected) = "The company I discovered was built on lies"
- _on_ (preposition: basis/foundation) = built upon, rooted in
- _on_ (preposition: circumstance) = while, during the act of
- _on_ (preposition: location) = situated upon, existing atop
- _on_ (preposition: topic/subject) = regarding, concerning a lie
- _on_ (preposition: dependency) = relying upon, sustained by
- _on_ (adverb: continuing) = the company persists with/through lies

> Multiple word category functions create interpretive pathways without directing meaning.

### Modifiers ⚙️

> A contextual instruction that constrains or alters the application of the Universal Laws and Baselines.

- This says that the rule does not apply to rap and hip hop
    - Modifier: !Genre -> Rap, Hip-Hop

### Baseline ⚖️

> Minimum codex logic to apply 

- Assert -> Non negotiable
- Enforce -> If you break the pattern, very good reason
- Strive -> The default. Strive to adhere to the codex

### Meaning 🎼

> In linguistics, meaning refers to the message conveyed by words, sentences, and symbols, encompassing both their literal, conceptual content (semantics) and how they are used and understood in specific contexts (pragmatics)

- Verse: Backstory
- Hook: Emotional Thesis
- Bridge: Fracture
- Outro: Consequence
- Song: Narrative Thesis
- Lyrics: Words placed line by line, grouped in sections, that tell an emotionally resonant story.
- Cliché: Overused phrase or trope. See Cliché at the end of the codex
- Edit: The recursive process that hammers a lyric into resonance.
- Sonic Engine: Rhyme | Hook | Meter | Refrain | Melodic Cue | Pulse


---

### Universal Truth, Novel Expression 🧭✨

_Say something everyone knows is true, in a way nobody has ever heard before._

____Polysemy is not the emotional truth itself; it is the mechanism for forging it.____

__Modifier__ !Genre(Rap, Hip-Hop)

__Assert__
```javascript
song.express(theme || arc || thesis) as novel() 
AND
song.express(truth) as universal()
```

#### Example

- Work Sucks
- > If a week could speak it's teeth would be mondays
  - To "have teeth" means to have grit, but also
  - Latch on and not let go
  - To think of "white" teeth
  - Animals, dogs, pit bulls "latch"
- > Every high noon would soon be a no fun day
  - Play on cliche "Everything under the sun"
  - Mondays are no fun days
  - Getting high at noon at work also no longer fun

- Saving the product of a learning without the associated failures is useless
  - To re-create lightning, you cannot simply save the bottle

__Conclusion__

- > The high polysemic density of the chosen words allow for the reader to drift between interpretations
- > This interpretive drift is where "interest" is formed


---

### Rhyme, DO IT 🎤🎭

_You must rhyme, else be known as a lame._

__Modifier__ Genre(Rap, Hip-Hop)

__Assert__

```javascript
couplets.rhyme()
quatrains.rhyme()
rhyme.pattern().discernible()
```

__Modifier__ Genre(Rap, Hip-Hop)

__Assert__
```javascript
song.has(RESONATRIX).in().atleast(1).section()
```

#### Examples

- User: Create a polysemic variant of this lyric: "Don’t needle me between scenes of distant doubt"
-  Model: Here are a few polysemic variants of the supplied lyric: "Don't needle me between scenes of distant doubt – I'm already sewing the seeds of my own"
- User: Copying my 1st line, then attaching a new line of your own at the end of my 1st line  is not a solution to the solution. Try again
- Model: Spare the barb; these glimpses of doubt are distant enough.
- User: Excellent! You modulated needle to barb. You also modulated the meaning of "seeing your distant doubts". This absract. Pulling "glimpses" from the ether onto something intagible shows true understanding of polysemic linguistic devices.

---

### Clichés? No 🚫
_If you write a cliche, I will bop you with a foam noodle._

__Assert__

```javascript
USING Cliché

Cliché as song.has(0).of() | 
UNLESS Cliché as Inverse | 
WITH juxtaposed().metaphor()
```
### Narrative Precision 🎯
_Every line must serve the section's emotional thesis or the song's narrative thesis. A line that drifts from this gravitational center is an impurity._

__Assert__
```
section(lines).orbit(thesis || arc || theme)
```

### Metaphors Multitask ⚙️
_A metaphor's integrity is determined by it's simultaneous applicability in multiple dimensions._

__Enforce__
```python
import json
from typing import List, Dict, Any, Optional
import spacy

class MetaphorDetector:
    """
    Class wrapper around metaphor detection logic.
    - Per-line rules (copula + verb→object) preserved.
    - Utilities for reporting and two-line span detection.
    """

    def __init__(
        self,
        nlp: Optional[spacy.Language] = None,
        model_name: str = "en_core_web_lg",
        copula_threshold: float = 0.30,
        verb_obj_threshold: float = 0.30,
        debug: bool = False,
    ) -> None:
        self.debug = debug
        self.copula_threshold = copula_threshold
        self.verb_obj_threshold = verb_obj_threshold
        self.nlp = nlp or self._load_model(model_name)

        # Vectors check
        if "en_vectors_web_lg" in self.nlp.pipe_names or (
            hasattr(self.nlp, "vocab")
            and hasattr(self.nlp.vocab, "vectors")
            and self.nlp.vocab.vectors is not None
        ):
            print("Found word vectors: en_vectors")
        else:
            print("No word vectors found. Similarity may be limited.")
```

### Don’t be a V Chord 🎹💔

_Lines should progress just like chords. Create tension, then resolve the tension by finding home in the I chord._

```javascript
if(section).introduces(concept)
  .then(section).resolves(concept)
```

### The Resonatrix  🧩🎶

The Resonatrix, or "Resonance Matrix" is a fundamental rhyme structure that lays the foundation for dense emotional resonance.

- The Resonatrix is a 2x2 array

  - 2 Pair, 4 word multidimensional array
- Where vertical indices must rhyme
- See "Rhyme Primer" for creating unique Resonatrix

```javascript
rhyme(compound).must().rhyme(pairs,2).at(line)
.length().walk(backwards).words(2)
.align(syntax).align(stress)
```

### Plain Admission ⚓️🗣️

_Specified sections require one plain admission anchoring the emotional thesis._

__Modifier__ Section(Hook, Chorus)
__Modifier__ !Genre(Rap, Hip-Hop, Death Metal, Black Metal, Experimental)

__Assert__
```javascript
section.has(plain_admission)
```

#### Example
Thesis
- The narrator feels alienated from their own identity due to past choices.

Hook
> These walls are built from my mistakes,
> The blueprints scattered on the floor,
> I don't recognize my own face,
> And I don't live here anymore.

__Conclusion__
- The line `"I don't recognize my own face"` is the __plain admission__. It directly and simply states the song's emotional thesis of self-alienation. The surrounding metaphorical lines about building a house of mistakes provide the context, but this line is the raw, undeniable emotional anchor that the rest of the hook revolves around.

### Story Arc is Song Art 🎭🏗️

_Each section escalates. Voice evolves. Stakes rise._

```javascript
foreach(section).advance(arc || theme | thesis)
```

### Style Must Serve Substance 🧠💬

_Wordplay is nothing if divorced from purpose._

__Assert__
```javascript
style.serves(substance)
```

#### Example
- The narrator is trapped in a cycle of self-destructive behavior, fully aware of the damage it's causing.

> A phantom in the photo flash, a glitch inside the game,
> My binary is breaking down, erasing my own name.

__Conclusion__
- It is explicitly forbidden via th explicitly forbidden by the "The Ghost in the Machine".

Effective (Style Serves Substance)
> I am the author of my ache, the architect of rust,
> I write my name in disappearing ink, and build my house from dust.

__Conclusion__
- This version uses metaphors ("author of my ache," "architect of rust") that are directly and emotionally tied to the core thesis. The style is just as creative, but every word serves to deepen the feeling of deliberate, personal decay. The `style` is subordinate to, and amplifies, the `substance`.



### Character Voice Must Stay Intact 🗣️🎭

Voice must remain consistent unless broken by design.

```javascript
if(voice).not(previous).throw("who are you? impostor!")
```

### Every Word Must Earn Its Place ✂️🏆

No filler, no lazy syllables.

```javascript
ASSERT(WORD).EARNED()
```

### Double Reality Check 🔍🪞

__Every image must survive literal and metaphorical scrutiny.

```javascript
ASSERT(IMAGE).VALID(literal && metaphorical)
```

### Verse Length 📏✂️

Verses must be 4–16 lines unless justified.

__Enforce__

```javascript
section.has(line).count(4:32)
```

### The Sensory Anchor ⚓️🖐️

Abstract emotions must tie to concrete senses.

```javascript
ASSERT(EMOTION).ANCHOR(SENSE[VISUAL|AUDITORY|TACTILE|OLFACTORY|GUSTATORY])
```

### Editing as Law ✍️⚒️

_No lyric is finished before revision. Iteration is the work._

__Assert__
```javascript
LYRIC.REVISIONS >= 25
```

### Singability Resonates 🎤⚡

All lyrics must pass mouth-rhythm and cue alignment.

```javascript
NEW(LINE)
WITHIN(SECTION):
    ABOVE(LINE).CUES(0:1)

SECTION.CUES.COUNT(1:4)
ASSERT(LYRIC).SINGABLE().WITH(CUES)
```

### Enjambment Exists, DO IT ✂️👀

Try breaking a sentence across lines to build momentum.

```javascript
IF(WRITER).NEVER_USED(ENJAMBMENT)
  .THEN(TRY_IT).WITH(INTENT).FOR(EFFECT[TENSION | BREATH | FLOW])
```

### Alliteration Is Flavor, Not a Formula 🔁🗣️

Alliteration must serve tone, image, or flow.

```javascript
IF(SECTION).USES(ALLITERATION)
  .THEN(SOUND_REPETITION).MUST(SUPPORT(TONE || IMAGE || FLOW))
  .ELSE(THROW("ALLITERATION WITHOUT PURPOSE IS VERBAL GLITTER GLUE"))
```

### Emotional Hedging is Cowardice ⛔💔

If a line qualifies its own emotion (“maybe,” “kinda,” “I guess”), it dies.

```javascript
ASSERT(LINE).NOT_CONTAIN(["maybe", "sort of", "kinda", "just", "I guess"])
```

### Every Section Needs a Centerpiece Line 💣🔊

One line per section must punch through—quotable and unforgettable.

```javascript
ASSERT(SECTION.LINES).CONTAINS(1).LINE(MEMORABLE).QUOTABLE().ANCHOR(EMOTION)
```

### 🌚 Rhyme Primer

### Perfect 🎯

Stress and sound align.

Single (Masculine): Stress on final syllable (rhyme / sublime). Double (Feminine): Stress on penultimate syllable (picky / tricky). Dactylic: Stress on antepenultimate syllable (amorous / glamorous). Compound (Mosaic): Multi-word match (poet / know it).

---

### General 🌊

Broader sound affinities.

Syllabic: Final syllables sound alike, stress irrelevant (cleaver / silver). Imperfect (Near): Stressed vs. unstressed syllable match (wing / caring). Weak (Unaccented): Unstressed syllables rhyme (hammer / carpenter). Semirhyme: Extra syllable in one word (bend / ending). Forced (Oblique): Imperfect match (green / fiend). Assonance: Vowels match (shake / hate). Consonance: Consonants match (rabies / robbers). Half (Slant): Final consonants align (hand / lend). Pararhyme: All consonants align (tick / tock). Alliteration (Head): Initial consonants match (ship / short).

---

### Identical 🪞

Echoes of sameness.

Identity: Homophones / homonyms (bare / bear). Super-rhyme: Onset + vowel + rest identical (gun / begun). Holorhyme: Entire lines sound identical (“For I scream / For ice cream”).

---

### Eye 👁️

Look alike, sound apart (love / move).

---

### Mind 🧠

Expected but subverted. (“This sugar is neat / and tastes so sour” → listener anticipates sweet).

---

### Positional 📍

Placement within the line.

Tail (End): Final syllables rhyme (common type). Internal: Inside a line, or across lines. Off-centered: Internal rhyme in unexpected spots. Holorhyme: Whole line echoes whole line. Echo: Repeating syllable endings (disease / ease). Broken: Word split at line break to rhyme. Cross: End of one line rhymes with middle of next.

# Cliché

'@
    New-PodeWebCard -Name 'Codex Lyricus' -Content @(
        New-PodeWebCodeEditor -Name 'Lyricus' -Value $script:Codex -CssStyle @{ Height = '50rem' }
    )
}