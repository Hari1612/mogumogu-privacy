# Privacy Policy for MoguMogu

**Effective date:** 2026-05-23

## Who we are

MoguMogu is developed and maintained by Hari (trading as sapporosoft), a solo developer based in Sapporo, Japan. For any privacy-related questions or requests, please contact us at info.hari07@gmail.com.

## What MoguMogu does

MoguMogu is a food label scanning app. It uses your device's camera to scan barcodes and ingredient labels on food packaging, then checks the results against allergen lists and dietary restrictions (including halal/haram, vegetarian, and vegan classifications) to help you make informed food choices. Users may optionally create an account to save their dietary preferences across sessions.

## Information you provide if you register

Registration is optional. The app works in anonymous mode without an account. If you choose to register, we collect:

- Email address
- Password (transmitted to our server and stored as a cryptographic hash; your plaintext password is never stored)
- Display name
- Dietary preferences and allergen selections you configure
- Language preference and exceptions list

## Scan data sent to our servers

Whether or not you are registered, the following data is sent to our backend server (hosted in Japan on Sakura Internet infrastructure) when you use the app:

- Scanned barcode values
- OCR text extracted from ingredient labels (text only — raw camera images are not transmitted)
- Scan result records
- Unknown ingredient submissions, which are aggregated and anonymized server-side and used to improve the shared ingredient dataset; these are not linked to your identity
- Basic application usage events (app-usage telemetry)

## Third-party services we use

- **Open Food Facts** ([world.openfoodfacts.org](https://world.openfoodfacts.org)) — when a barcode is scanned, our backend may query Open Food Facts to retrieve product information. Only the barcode value is sent in this request; no user identifier is attached. Open Food Facts terms of use: [world.openfoodfacts.org/terms-of-use](https://world.openfoodfacts.org/terms-of-use).

## On-device processing

Ingredient label OCR is performed using Google ML Kit, which runs entirely on your device. Raw camera frames and label images are processed on-device and are not transmitted off the device.

## Data transmission security

Data transmitted between the app and our backend at `api.sapporosoft.com` is encrypted in transit using HTTPS (TLS), with certificates issued by Let's Encrypt and renewed automatically. Plain HTTP requests to this host are automatically redirected to HTTPS.

## How we use your information

- To perform barcode lookups and dietary-matching features within the app
- To improve the shared ingredient dataset (contributions are aggregated and anonymized and are not linked to your identity)
- To respond to support requests you send us

## Data sharing and selling

We do not sell personal data. We do not share personal data with third parties, except as described above (barcode values sent to Open Food Facts, which carry no user identifier).

## Data retention and deletion

- Scan data is retained on our server to improve the shared ingredient dataset.
- To request deletion of your account and all associated personal data, email info.hari07@gmail.com from the address you registered with. We will action the request within 30 days.
- An in-app account deletion option will be added before MoguMogu is promoted beyond Internal Testing on Google Play.

## Children's privacy

MoguMogu is not directed at children under the age of 13. We do not knowingly collect personal data from children under 13.

## Changes to this policy

We will publish any updates to this policy at this same URL with an updated effective date.

## Contact

Email: info.hari07@gmail.com
