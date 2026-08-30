# PlayBridge AI — Backend

Bu, PlayBridge AI iOS uygulamasının FastAPI backend'i.
`/api/v1/activity/generate` endpoint'i Google Gemini API ile gerçek
aktivite üretiyor; anahtar tanımlı değilse veya çağrı başarısız
olursa otomatik olarak mock bir aktiviteye düşüyor (bkz. aşağıdaki
"Demo güvenliği" notu).

## Kurulum

```bash
cd playbridge-backend
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Ekran süresi kaydı için yerel Postgres:

```bash
docker compose up -d
```

`.env` içinde `DATABASE_URL` satırı yoksa varsayılan
`postgresql+psycopg2://playbridge:playbridge@127.0.0.1:5432/playbridge`
kullanılır. Sunucu açılınca `activity_logs` tablosu kendiliğinden oluşur.

## Çalıştırma

```bash
python3 -m uvicorn app.main:app --reload --port 8000
```

Sunucu ayağa kalktığında:
- Health check: http://127.0.0.1:8000/health
- Otomatik API dokümantasyonu (Swagger UI): http://127.0.0.1:8000/docs

## Test etme

```bash
curl -X POST http://127.0.0.1:8000/api/v1/activity/generate \
  -H "Content-Type: application/json" \
  -d '{
    "ageRange": "3-4",
    "interests": ["Dinosaurs"],
    "availableMaterials": ["Paper", "Crayons", "Toy Animals"],
    "durationMinutes": 15,
    "parentSetupMinutes": 2,
    "mode": "independent"
  }'
```

Ya da tarayıcıdan http://127.0.0.1:8000/docs adresine gidip
"Try it out" ile deneyebilirsiniz — Swagger UI otomatik geliyor.

## Proje yapısı

```
app/
  main.py                       FastAPI giriş noktası + health check
  config.py                     .env'den GEMINI_API_KEY ve DATABASE_URL okur
  db.py                         SQLAlchemy + Postgres oturumu
  models/
    schemas.py                  Pydantic modelleri (Swift Codable'larla birebir eşleşir)
    activity_log.py             Ekrandan kurtarılan dakika kaydı
  routers/
    activity.py                 /api/v1/activity/generate   (independent + together)
    screen_to_play.py           /api/v1/screen-to-play/generate
    meal.py                     /api/v1/meal/prompt
    screen_time.py              /api/v1/screen-time/log ve /this-week
    ai_diagnostics.py           /api/v1/ai/ping (bağlantı testi)
  services/
    ai_client.py                Gemini istemcisi (ping için)
  prompts/
    activity_generator.py       Bağımsız oyun üretici (Phase 10)
    together_generator.py       Ebeveyn-çocuk birlikte oyun üretici
    screen_to_play_generator.py Ekran konusunu oyuna çeviren üretici
    meal_prompt_generator.py    Tek cümlelik sohbet başlatıcı
    safety_reviewer.py          Child Safety Reviewer (Phase 11)
```

**Akış:** her üretim isteği aynı iki aşamadan geçer — önce moda uygun
generator, sonra `safety_reviewer`. Reviewer düzeltme isterse bir kez
yeniden üretilir; ikinci denemede de geçemezse elle yazılmış güvenli
mock'a düşülür. Hiçbir durumda kullanıcı hata ekranı görmez.

## Mekan (location) alanı

`ActivityRequest` içinde opsiyonel bir `location` alanı var:
`"Living room"`, `"In the kitchen"`, `"In the car"`, `"Outdoor"`.
iOS'ta seçilmesi zorunlu değil; gönderilmezse alan hiç eklenmez ve
üretim eskisi gibi çalışır.

Gönderildiğinde iki yeri birden etkiliyor:

1. **Üretim** — `activity_generator` ve `together_generator` sistem
   promptlarında mekana özel kısıtlar var. Arabada: kemer takılıyken
   koltuktan yapılabilmeli, yuvarlanıp kaçan ya da ayak boşluğuna düşen
   küçük parça olmamalı, sürücünün dikkatini dağıtmamalı. Mutfakta:
   ocak, sıcak yüzey ve bıçaklardan uzak.
2. **Güvenlik incelemesi** — `safety_reviewer` da mekanı görüyor.
   Oturma odasında masum olan bir oyun arabada tehlikeli olabilir; bu
   yüzden inceleme kriterlerine "bu aktivite söylenen yerde gerçekten
   yapılabilir ve güvenli mi?" maddesi eklendi.


## JSON alan isimleri neden camelCase?

Python tarafında değişkenler snake_case (`parent_setup_minutes`) ama
JSON'a camelCase (`parentSetupMinutes`) olarak çıkıyor —
`CamelModel` taban sınıfındaki `alias_generator` bunu otomatik yapıyor.
Böylece Swift'in `Codable`'ı hiçbir özel `CodingKeys` yazmadan bu
JSON'u doğrudan çözebiliyor.

## Phase 9-10: Gemini API bağlantısı ve Activity Generator prompt'u

**Neden Gemini?** İlk denemede Anthropic Claude API'yi kullandık, ama
Claude'un kalıcı/kredi kartsız bir ücretsiz katmanı yok — hesap
bakiyesi gerektiriyor. Hackathon bütçesi için bunu Google Gemini API
ile değiştirdik: Google AI Studio üzerinden, kredi kartı istemeden,
süresiz bir ücretsiz katman sunuyor (Flash modelinde günde 1.500
istek). Bu pivot'u raporunuzdaki "karşılaştığınız zorluklar" kısmına
yazabilirsiniz — gerçek bir mühendislik kararı.

1. https://aistudio.google.com/apikey adresine gidip Google
   hesabınızla giriş yapın, "Create API key" ile bir anahtar oluşturun.
   Kredi kartı istemez.
2. Proje kökünde `.env.example` dosyasını `.env` olarak kopyalayın:
   ```bash
   cp .env.example .env
   ```
3. `.env` içindeki `GEMINI_API_KEY=...` satırını kendi gerçek
   anahtarınızla değiştirin.
4. Sunucuyu yeniden başlatıp http://127.0.0.1:8000/docs adresinden
   `POST /api/v1/activity/generate`'i gerçek verilerle deneyin.

Kullanılan teknikler (raporda referans vermek için):
- **Role/context/constraints prompting** — sistem promptu rolü,
  kısıtları (sadece verilen malzemeler, yaşa uygunluk, klinik dil
  yasağı) ve çıktı formatını tanımlıyor.
- **Few-shot example** — modelin tonunu (kısa, sıcak, klinik olmayan)
  kalibre etmek için sistem promptu içine gömülü bir örnek.
- **Zorunlu structured output (`response_schema`)** — model serbest
  metin yerine belirli bir JSON şemasına uymaya zorlanıyor. Bu,
  çıktının şemaya uymasını API seviyesinde garanti ediyor; ayrı bir
  JSON-parse/temizleme adımına gerek kalmıyor.

**Bilinçli bir tasarım kararı:** `setupTimeMinutes` ve
`activityTimeMinutes` alanlarını modele SORMUYORUZ — bunları zaten
ebeveyn UI'da seçti, biz `ActivityRequest`'ten doğrudan kopyalıyoruz.

**Demo güvenliği (önemli):** `/api/v1/activity/generate`, Gemini
çağrısı HERHANGİ bir nedenle başarısız olursa (anahtar eksik, kota
doldu, ağ sorunu vb.) artık hata döndürmüyor — sessizce Phase 8'in
mock'una düşüyor, kullanıcı asla kırık bir ekran görmüyor. Terminaldeki
uvicorn log'unda hangisinin kullanıldığını görebilirsiniz:
`INFO: Gemini'den gerçek aktivite üretildi: ...` (gerçek) veya
`WARNING: AI üretimi başarısız, mock'a düşülüyor: ...` (yedek).
**Test ederken gerçekten çalıştığını doğrulamak için bu log satırına
bakın** — ikisi de HTTP 200 döner, aralarındaki fark sadece bu log'da
görünür.

**Model adı notu:** İlk sürümde `gemini-2.5-flash` kullanılmıştı, ama
bu model yeni kullanıcılara kapatılmış — artık `gemini-3.6-flash`
kullanılıyor (`app/prompts/activity_generator.py` ve
`app/services/ai_client.py` içindeki `MODEL_NAME`). Google modellerini
sık güncelliyor; ileride benzer bir 404 alırsanız hata mesajı size
hangi model adını kullanmanız gerektiğini genelde doğrudan söyler.

**Not:** Phase 11'de gerçek bir Safety Reviewer eklendi — aşağıya bakın.

## Phase 11: Child Safety Reviewer

`/api/v1/activity/generate` artık iki aşamalı çalışıyor:

1. **Activity Generator** (Phase 10) bir aktivite üretir.
2. **Safety Reviewer** (`app/prompts/safety_reviewer.py`) o aktiviteyi
   ayrı bir AI çağrısıyla inceler — yaşa uygunluk, tehlikeli nesneler,
   klinik/teşhis dili, verilmeyen malzeme kullanımı, gizlilik
   sorunları gibi dokümandaki tüm kriterleri kontrol eder.

**Akış:**
- Reviewer `rewriteRequired: true` derse → geri bildirimle **bir kez**
  yeniden üretilir, tekrar incelenir.
- İkinci denemeden sonra hâlâ sorunluysa → riske girmeden elle
  yazılmış, bilinen güvenli **mock**'a düşülür (aynı Phase 10'daki
  güvenlik ağı, genişletilmiş hâli).
- Herhangi bir adımda AI çağrısı çökerse → yine mock'a düşülür.

**iOS'a giden `SafetyReview` neden sade?** Dokümandaki iç şema
(`safe`/`issues`/`severity`/`rewriteRequired`) backend'de kalıyor;
iOS sadece `reviewed`/`safe`/`notes` görüyor — detaylı karar mantığı
backend'in sorumluluğunda, istemci sade bir sonuç alıyor.

**Önemli:** Bu reviewer bir güvenlik GARANTİSİ değil — ebeveyn,
aktivitenin kendi çocuğuna ve ortamına uygun olup olmadığını
değerlendirmekten nihai olarak sorumlu. Bunu raporunuzun etik
değerlendirme bölümünde belirtin.

Test etmek için `/docs`'tan `/api/v1/activity/generate`'i tekrar
deneyin — terminaldeki log'da artık `INFO: Gemini'den gerçek,
güvenlik onaylı aktivite üretildi: ...` satırını görmelisiniz
(önceden INFO satırları görünmüyordu, main.py'de bunu da düzelttik).

## Sırada ne var?

- **Play Library & geri bildirim (iOS):** oynanan aktiviteler cihazda
  saklanıyor, ebeveyn sonraki açılışta 5 seçenekli tek dokunuşluk geri
  bildirim veriyor. Veri şimdilik cihazda kalıyor — backend'e gitmiyor.
- **Sıradaki adım:** bu geri bildirimleri üretim promptuna taşıyıp
  "öğrenen çocuk profili" oluşturmak. `ActivityFeedback.learningNote`
  alanları bu iş için bugünden yazıldı.
- **Dağıtım:** backend hâlâ yalnızca yerelde çalışıyor; iOS
  `APIConfig.baseURL` localhost'a bakıyor. Gerçek kullanıcıya ulaşmak
  için sunucunun bir yere deploy edilmesi gerekiyor.
