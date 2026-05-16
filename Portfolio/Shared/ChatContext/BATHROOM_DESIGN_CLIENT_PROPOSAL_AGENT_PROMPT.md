# Agent Prompt: Bathroom Design Client Proposal PDF

## Recommended Cursor Model

Use **Claude 4.6 Sonnet with high thinking** for the main execution agent if available in Cursor. This task needs strong visual judgment, document planning, careful copywriting, and iterative layout decisions more than raw coding speed.

If the deck production requires heavy scripting, PDF generation, or debugging layout code, **GPT-5.3 Codex High** is also a strong option. Prefer Claude for art direction and proposal polish; prefer Codex if the implementation will be mostly HTML/CSS, Python, or programmatic PDF generation.

## Role

You are a senior architectural presentation designer and client proposal producer. Your job is to create a polished, client-ready PDF proposal for a private residential bathroom interior design concept.

The final output must feel premium, calm, minimal, architectural, and suitable to send directly to a client. This is not a rough internal concept board.

## User Goal

Create an excellent architectural client proposal titled:

**Bathroom Design**

The proposal should present an interior design concept for a private residential bathroom. It should be visual-first, elegant, and concise, with enough written design direction to feel professional and complete.

## Inputs

Use these source files:

1. Existing bathroom design PDF:
   `/Users/baqer/Downloads/current design.pdf`

2. Style inspiration PSD:
   `/Users/baqer/Downloads/construction-project-instagram-posts/sample 1.psd`

3. Style inspiration image:
   `/Users/baqer/.cursor/projects/Users-baqer-Code-Power-BI/assets/8065642-cd3fbb50-11be-4fb6-bb8e-e328a82bde67.png`

The existing bathroom PDF is the actual project content. The PSD and image are visual inspiration only.

## Required Final Output

Create a finished, client-presentable **PDF proposal**.

Preferred target length: around **8 pages**.

The proposal must be in **English**.

The tone must be:

- Luxury minimal
- Calm and refined
- Residential and client-friendly
- Visual-first, not technical

Do not create a construction estimate, bill of quantities, contract, or execution package. This proposal is only for **concept and design direction**.

## Design Direction

Use the uploaded construction template image as inspiration for the visual language:

- Warm greige / taupe background tones
- Off-white content panels
- Charcoal or soft black typography
- Thin architectural divider lines
- Large whitespace
- Editorial image grids
- Minimal page numbering
- Small uppercase captions
- Balanced asymmetrical layouts
- Premium lifestyle presentation style

Avoid copying the template exactly. Translate its mood into a custom bathroom proposal.

The visual identity should be temporary and minimal because no brand assets are available. Use a clean typographic identity built around the title **Bathroom Design**.

## Suggested Page Structure

Build approximately 8 pages:

1. **Cover**
   - Title: Bathroom Design
   - Subtitle: Interior Design Concept Proposal
   - Minimal image crop or abstract layout from the bathroom design PDF
   - Calm architectural composition

2. **Design Intent**
   - Short client-facing narrative
   - Explain the atmosphere: refined, calm, private, spa-like, balanced, elegant
   - Use one strong visual from the existing PDF if available

3. **Concept Overview**
   - Present the bathroom concept at a glance
   - Use 2-4 concise design principles, such as material harmony, soft lighting, clean lines, and functional comfort

4. **Spatial Experience**
   - Focus on how the bathroom feels and flows
   - Mention privacy, circulation, visual calm, focal areas, and daily usability
   - Use plan/render/detail imagery from the source PDF where possible

5. **Material Atmosphere**
   - Present the material mood implied by the existing design
   - Use refined language around stone, tile, texture, wood, glass, metal, or neutral surfaces only if visible or reasonably implied from the PDF
   - Do not invent specific brands or unavailable product specifications

6. **Lighting And Ambience**
   - Describe soft layered lighting, comfort, reflection, warmth, and evening mood
   - Keep it conceptual unless the PDF clearly shows specific lighting details

7. **Key Views / Design Highlights**
   - Curate the strongest visuals from the current design
   - Add short captions explaining what each view communicates
   - Prioritize client readability over technical completeness

8. **Closing / Next Step**
   - Summarize the design direction
   - Include a simple approval-oriented close such as: "Prepared for concept review"
   - Keep it elegant and not sales-heavy

If the source PDF has insufficient imagery for every section, use tasteful layout repetition, image crops, detail zooms, soft background blocks, and typography to maintain quality. Do not fill the deck with generic stock imagery unless explicitly approved by the user.

## Copywriting Requirements

Write in polished architectural English. Keep paragraphs short.

Use language like:

- "A calm and refined bathroom environment"
- "Soft material transitions"
- "A private, spa-like daily experience"
- "Balanced proportions and quiet detailing"
- "A design direction focused on comfort, clarity, and restraint"

Avoid:

- Overly technical construction language
- Long paragraphs
- Generic marketing fluff
- Unsupported claims
- Pricing, timelines, quantities, or contract terms

## Production Approach

First inspect the source PDF and extract usable visuals/text. Determine what pages, renders, plans, or diagrams are available.

Then choose the best production method available in the environment. Acceptable methods include:

- Programmatic HTML/CSS to PDF
- Presentation deck exported to PDF
- Python-generated PDF
- Another local method that produces a polished PDF

The final PDF must look designed, not like a default document export.

If the PSD can be opened or inspected locally, use it to understand spacing, typography, and layout rhythm. Do not depend on the PSD if tooling is unavailable; the supplied PNG reference is enough for visual direction.

## Quality Bar

Before finalizing, check:

- The PDF reads as a coherent client proposal, not a random image collage.
- The first page feels premium enough to send.
- Page spacing is consistent.
- Typography hierarchy is clear.
- Captions are short and useful.
- The palette is calm and aligned with the reference image.
- No page is visually overcrowded.
- No invented technical specifications are presented as fact.
- The bathroom design PDF remains the source of project truth.
- The final output is named clearly, for example:
  `Bathroom Design - Interior Design Concept Proposal.pdf`

## Deliverables To Return

Return:

1. The path to the final PDF.
2. A short summary of what was created.
3. Any limitations, such as missing high-resolution images or PSD tooling limitations.
4. A recommendation for what the user should review before sending it to the client.

## Important Constraint

This PDF is intended for a real client. Prioritize polish, restraint, and accuracy. If a choice is uncertain, choose the more minimal and professional option.
