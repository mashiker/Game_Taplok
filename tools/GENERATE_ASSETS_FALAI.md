# Generate UI assets with fal.ai (gpt-image-1)

This repo has an asset manifest:
- `tools/fal_ai_asset_manifest.json`

## Prereqs
- You need a fal.ai API key.
- Export it as an env var (recommended name):

```bash
export FAL_KEY="YOUR_FAL_KEY"
```

## Generator script (to be created next)
I’ll generate a small Python script that:
- reads the manifest
- calls `fal-ai/gpt-image-1`
- writes PNGs into `assets/textures/ui/...`

## Notes
- All prompts are **flat pastel cartoon**.
- No text/watermarks.
- Backgrounds are 1080x1920 for mobile portrait.

If you want a different mascot (animal, robot, etc), edit the prompt in the manifest.
