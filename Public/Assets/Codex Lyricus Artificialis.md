# Codex Lyricus Artificialis 📜

> A subordinate ruleset to the Codex Lyricus, this codex acts as a prepended filter, specifically targeting and correcting common AI failure modes before the main Codex Lyricus is even engaged.

> This ruleset is PRE-PENDED to rule "Universal Truth: Novel Expression" and inherits all lexicon of it's parent codex

### The Ghost in the Machine Prohibition 🚫🤖

_Avoid overused metaphors that pretend to be deep._

__Assert__
```javascript
lyric.has(0).of(bankrupt_concepts)
```
```javascript
// Defined Constants
const BANKRUPT_CONCEPTS = [
  /phantom( in| of)?/i,
  /ghost( in| of)?/i,
  /memory.ghost/i,
  /echo.(bone|chest|silence|voice)/i,
  /silence.(screams|rings|echoes)/i,
  /static.(between|signal|heart)/i,
  /you.left.(damage|scar)/i
]
```

#### Example
Thesis
- The narrator is haunted by a past relationship.

Violation
> The echo of your voice still rings inside my chest,
> A ghost of what we used to be, won't let my heart just rest.

__Conclusion__
- This lyric is a direct violation. It relies on two separate `bankrupt_concepts`—"echo of your voice" and "ghost of what we used to be"—as a substitute for genuine emotional expression. It uses cliché imagery as a crutch instead of forging a novel way to articulate the feeling of being haunted by a memory. The lyric fails the assertion because it contains multiple prohibited phrases.

### Syllabic Consistency is Sacred 📏🗣️

_Keep rhythmic architecture tight unless syncopation is intended and resolved._

__Assert__
```javascript
section.syllables().variance().is_under(0.25)
  .unless(section.is_flagged("ASYMMETRY" || "SYNCOPATION"))

// Further assertions for specific contexts
hook.syllables().variance_from(previous_verse).is_under(0.5)

section.flagged("SYNCOPATION").must()
  .align_with(intent.emotional || intent.musical)
  .and.resolve_on_beat()
```

#### Example
Thesis
- A feeling of mounting, unresolved anxiety.

Violation (Unintentional Variance)
> The clock on the wall keeps ticking out the time (10)
> Every single second is a mountain I must climb (12)
> My thoughts are racing faster now (7)
> I wish that I could just press rewind (8)

__Conclusion__
- The syllable count per line (10, 12, 7, 8) is erratic and lacks a discernible pattern. The standard deviation is high, and no `SYNCOPATION` or `ASYMMETRY` flag was declared. This creates a rhythmically clumsy and unfocused section, failing the assertion for syllabic consistency.

Effective (Intentional Variance / Syncopation)
> The clock on the wall is tick- (7)
> -ing out of time, my thoughts are racing faster now (12)
> I can't catch a breath, I can't find a rhyme (10)
> Just this crushing weight I can't leave behind (10)

__Conclusion__
- Here, the variance is intentional. The enjambment and sudden short line ("The clock on the wall is tick-") create a syncopated, breathless feeling that directly serves the emotional thesis of anxiety. This would pass the assertion because the variance is justified by an `INTENT` (emotional) and `FLAG` (syncopation).

### Avoid List Writing 🚫📋

_Do not begin multiple lines identically unless for intentional effect._

__Assert__
```javascript
section.lines().starting_with(same_word).count().is_under(3)
  .unless(section.is_flagged("REPETITION"))
```

#### Example
Thesis
- The narrator is reflecting on their past with a sense of confused, disjointed identity.

Violation
> I became once a plane
> I was before that the same
> I realize it could be lame
> I don't care, I'm a plane

__Conclusion__
- This section violates the rule. Four consecutive lines begin with "I," creating a monotonous, uninspired structure often seen in unrefined AI outputs. This is "list writing"—a simple recitation of "I" statements rather than a crafted lyrical passage. It fails the assertion because the count of lines starting with the same word (4) exceeds the threshold (3) without an intentional `REPETITION` flag.