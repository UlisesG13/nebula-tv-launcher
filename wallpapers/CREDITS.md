# Créditos de los wallpapers

Los fondos incluidos provienen de agencias espaciales públicas (NASA / ESA). Las imágenes de la
**NASA** son de **dominio público**; las de la **ESA/Hubble** suelen estar bajo **CC BY 4.0** y
requieren atribución. Todos se redimensionaron (lado largo ≤ 2560 px) y comprimieron para que
rindan bien en TVs de 1 GB de RAM.

> ⚠️ **Verifica la fuente de cada imagen en su página original antes de reutilizarlas** en otro
> proyecto. Las atribuciones de abajo son las mejores conocidas para los archivos incluidos; si vas
> a publicar, confirma el enlace y la licencia exacta de cada una.

| Archivo | Descripción | Fuente / crédito | Licencia |
|---|---|---|---|
| `amanecer.jpg` | Amanecer / horizonte terrestre | NASA | Dominio público |
| `dia.jpg` | Vista diurna / Tierra | NASA | Dominio público |
| `tarde.jpg` | *Cosmic Cliffs* (Nebulosa de Carina), JWST | NASA, ESA, CSA, STScI | Uso libre con crédito |
| `noche.jpg` | Galaxia de Andrómeda (M31) | NASA / ESA (Hubble) | CC BY 4.0 (crédito requerido) |

Créditos recomendados al reutilizar:
- NASA: "Image credit: NASA".
- JWST / Cosmic Cliffs: "Image: NASA, ESA, CSA, and STScI".
- Hubble: "Image: ESA/Hubble & NASA" (CC BY 4.0).

## Cómo usar tus propios wallpapers

1. Pon tus 4 imágenes en `wallpapers/` (idealmente 1920×1080 o más, horizontales).
2. Apunta a ellas en tu `config/config.json` (campos `wallpapers.morning/day/afternoon/night`).
3. Vuelve a correr el script de instalación (o pídele a tu agente que reaplique la config).

Consejo: los fondos **oscuros** lucen mejor con el estilo glassmorphism y mantienen el texto
legible. Los scripts las redimensionan automáticamente si son muy grandes.
