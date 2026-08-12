# Entra Object ID ↔ SID Converter

En statisk Cloud247-webapp for å konvertere mellom:

- Microsoft Entra Object ID (GUID)
- Windows SID-formatet `S-1-12-1-x-x-x-x`

## Funksjoner

- Object ID → SID
- SID → Object ID
- Validering og normalisering
- Massekonvertering med CSV-eksport
- Kopier-knapper
- Nedlastbart PowerShell-script for begge retninger
- Ingen innlogging, Microsoft Graph-kall eller backend
- Behandling skjer lokalt i nettleseren

## Teknisk prinsipp

Microsofts dokumenterte PowerShell-eksempel parser Object ID som en `Guid`, bruker
`Guid.ToByteArray()`, kopierer de 16 bytene til fire `UInt32`-verdier og bygger en SID med
prefikset `S-1-12-1`.

Appen bruker samme byte-rekkefølge i JavaScript. Den motsatte retningen gjenoppbygger de
16 bytene fra de fire 32-bits delverdiene og formatterer dem som en GUID.

## Viktig

- Verktøyet bekrefter ikke at objektet finnes i Microsoft Entra.
- Det utfører ikke et Microsoft Graph-oppslag.
- Bare SID-formatet `S-1-12-1` med fire 32-bits delverdier støttes.
- Dette er ikke det samme som en tradisjonell on-premises Active Directory `objectSid`.


