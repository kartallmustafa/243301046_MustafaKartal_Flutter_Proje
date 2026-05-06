-- ============================================================
-- OptikTakip - Supabase PostgreSQL Şema ve Test Verileri
-- supabase.com → SQL Editor'da bu dosyayı çalıştırın
-- ============================================================

-- 1. TOPTANCI
CREATE TABLE IF NOT EXISTS toptanci (
  top_id    SERIAL PRIMARY KEY,
  firma_adi VARCHAR(100) NOT NULL,
  vergi_no  VARCHAR(20),
  telefon   VARCHAR(20),
  email     VARCHAR(100),
  adres     TEXT,
  sehir     VARCHAR(50),
  kayit_tarihi DATE DEFAULT CURRENT_DATE
);

-- 2. PERAKENDECI
CREATE TABLE IF NOT EXISTS perakendeci (
  per_id       SERIAL PRIMARY KEY,
  magaza_adi   VARCHAR(100) NOT NULL,
  sahip_adi    VARCHAR(100),
  vergi_no     VARCHAR(20),
  telefon      VARCHAR(20),
  email        VARCHAR(100),
  adres        TEXT,
  sehir        VARCHAR(50),
  kayit_tarihi DATE DEFAULT CURRENT_DATE
);

-- 3. URUN_KATEGORI
CREATE TABLE IF NOT EXISTS urun_kategori (
  kat_id       SERIAL PRIMARY KEY,
  kategori_adi VARCHAR(50),
  aciklama     TEXT
);

-- 4. URUN
CREATE TABLE IF NOT EXISTS urun (
  urun_id     SERIAL PRIMARY KEY,
  kat_id      INT REFERENCES urun_kategori(kat_id),
  top_id      INT REFERENCES toptanci(top_id),
  urun_adi    VARCHAR(100),
  marka       VARCHAR(50),
  model       VARCHAR(50),
  renk        VARCHAR(30),
  malzeme     VARCHAR(50),
  birim_fiyat DECIMAL(10,2),
  tip         VARCHAR(10) CHECK (tip IN ('CAM','CERCEVE'))
);

-- 5. STOK
CREATE TABLE IF NOT EXISTS stok (
  stok_id          SERIAL PRIMARY KEY,
  urun_id          INT REFERENCES urun(urun_id),
  top_id           INT REFERENCES toptanci(top_id),
  miktar           INT DEFAULT 0,
  min_stok         INT DEFAULT 5,
  guncelleme_tarihi DATE DEFAULT CURRENT_DATE
);

-- 6. SIPARIS
CREATE TABLE IF NOT EXISTS siparis (
  sip_id        SERIAL PRIMARY KEY,
  per_id        INT REFERENCES perakendeci(per_id),
  top_id        INT REFERENCES toptanci(top_id),
  siparis_tarihi DATE DEFAULT CURRENT_DATE,
  durum         VARCHAR(30) DEFAULT 'Hazırlanıyor'
                CHECK (durum IN ('Hazırlanıyor','Kargoda','Teslim Edildi','İptal')),
  toplam_tutar  DECIMAL(10,2),
  odeme_turu    VARCHAR(20) CHECK (odeme_turu IN ('Havale','Kredi Kartı')),
  teslim_tarihi DATE
);

-- 7. SIPARIS_DETAY
CREATE TABLE IF NOT EXISTS siparis_detay (
  detay_id     SERIAL PRIMARY KEY,
  sip_id       INT REFERENCES siparis(sip_id) ON DELETE CASCADE,
  urun_id      INT REFERENCES urun(urun_id),
  miktar       INT,
  birim_fiyat  DECIMAL(10,2),
  indirim_orani DECIMAL(5,2) DEFAULT 0,
  ara_toplam   DECIMAL(10,2)
);

-- 8. KARGO
CREATE TABLE IF NOT EXISTS kargo (
  kargo_id      SERIAL PRIMARY KEY,
  sip_id        INT REFERENCES siparis(sip_id) ON DELETE CASCADE UNIQUE,
  kargo_firmasi VARCHAR(50),
  takip_no      VARCHAR(50),
  gonderim_tarihi DATE,
  teslim_tarihi DATE,
  kargo_durumu  VARCHAR(30) DEFAULT 'Hazırlanıyor'
                CHECK (kargo_durumu IN ('Hazırlanıyor','Dağıtımda','Teslim Edildi','İptal'))
);

-- 9. PROFILES (Supabase Auth ile bağlantı)
CREATE TABLE IF NOT EXISTS profiles (
  id         UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role       VARCHAR(20) NOT NULL CHECK (role IN ('perakendeci','toptanci')),
  per_id     INT REFERENCES perakendeci(per_id),
  top_id     INT REFERENCES toptanci(top_id),
  full_name  VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. ISLEM_LOG
CREATE TABLE IF NOT EXISTS islem_log (
  log_id     SERIAL PRIMARY KEY,
  user_id    UUID REFERENCES auth.users(id),
  islem_turu VARCHAR(50),
  tablo_adi  VARCHAR(50),
  kayit_id   INT,
  aciklama   TEXT,
  tarih      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- SUPABASE FUNCTION: create_siparis (sp_YeniSiparisOlustur)
-- ============================================================
CREATE OR REPLACE FUNCTION create_siparis(
  p_per_id   INT,
  p_top_id   INT,
  p_urun_id  INT,
  p_miktar   INT,
  p_odeme_turu TEXT
) RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_fiyat      DECIMAL(10,2);
  v_ara_toplam DECIMAL(10,2);
  v_sip_id     INT;
BEGIN
  SELECT birim_fiyat INTO v_fiyat FROM urun WHERE urun_id = p_urun_id;
  IF v_fiyat IS NULL THEN
    RAISE EXCEPTION 'Ürün bulunamadı: %', p_urun_id;
  END IF;

  v_ara_toplam := v_fiyat * p_miktar;

  INSERT INTO siparis(per_id, top_id, toplam_tutar, odeme_turu, siparis_tarihi)
    VALUES (p_per_id, p_top_id, v_ara_toplam, p_odeme_turu, CURRENT_DATE)
    RETURNING sip_id INTO v_sip_id;

  INSERT INTO siparis_detay(sip_id, urun_id, miktar, birim_fiyat, indirim_orani, ara_toplam)
    VALUES (v_sip_id, p_urun_id, p_miktar, v_fiyat, 0, v_ara_toplam);

  UPDATE stok SET
    miktar = miktar - p_miktar,
    guncelleme_tarihi = CURRENT_DATE
  WHERE urun_id = p_urun_id AND top_id = p_top_id;

  INSERT INTO kargo(sip_id, kargo_durumu) VALUES (v_sip_id, 'Hazırlanıyor');

  RETURN v_sip_id;
END;
$$;

-- ============================================================
-- TRIGGER: İptal edilince stok iade
-- ============================================================
CREATE OR REPLACE FUNCTION restore_stok_on_iptal()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.durum = 'İptal' AND OLD.durum != 'İptal' THEN
    UPDATE stok s SET
      miktar = s.miktar + sd.miktar,
      guncelleme_tarihi = CURRENT_DATE
    FROM siparis_detay sd
    WHERE sd.sip_id = NEW.sip_id
      AND s.urun_id = sd.urun_id
      AND s.top_id = NEW.top_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_siparis_iptal_stoku_guncelle ON siparis;
CREATE TRIGGER tr_siparis_iptal_stoku_guncelle
  AFTER UPDATE ON siparis
  FOR EACH ROW
  EXECUTE FUNCTION restore_stok_on_iptal();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE siparis      ENABLE ROW LEVEL SECURITY;
ALTER TABLE siparis_detay ENABLE ROW LEVEL SECURITY;
ALTER TABLE stok         ENABLE ROW LEVEL SECURITY;
ALTER TABLE islem_log    ENABLE ROW LEVEL SECURITY;

-- Profiles: kullanıcı kendi profilini okur
CREATE POLICY "profiles_self" ON profiles
  FOR ALL USING (auth.uid() = id);

-- Siparis: perakendeci kendi siparişlerini görür, toptancı kendi siparişlerini
CREATE POLICY "siparis_read" ON siparis
  FOR SELECT USING (
    per_id IN (SELECT per_id FROM profiles WHERE id = auth.uid() AND role = 'perakendeci')
    OR
    top_id IN (SELECT top_id FROM profiles WHERE id = auth.uid() AND role = 'toptanci')
  );

CREATE POLICY "siparis_insert" ON siparis
  FOR INSERT WITH CHECK (
    per_id IN (SELECT per_id FROM profiles WHERE id = auth.uid() AND role = 'perakendeci')
  );

CREATE POLICY "siparis_update" ON siparis
  FOR UPDATE USING (
    top_id IN (SELECT top_id FROM profiles WHERE id = auth.uid() AND role = 'toptanci')
  );

-- Siparis detay: sipariş sahibi görebilir
CREATE POLICY "detay_read" ON siparis_detay
  FOR SELECT USING (
    sip_id IN (SELECT sip_id FROM siparis
               WHERE per_id IN (SELECT per_id FROM profiles WHERE id = auth.uid())
                  OR top_id IN (SELECT top_id FROM profiles WHERE id = auth.uid()))
  );

-- Stok: toptancı kendi stoğunu yönetir; perakendeci okuyabilir
CREATE POLICY "stok_read" ON stok
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "stok_update" ON stok
  FOR UPDATE USING (
    top_id IN (SELECT top_id FROM profiles WHERE id = auth.uid() AND role = 'toptanci')
  );

-- İslem log: kullanıcı kendi loglarını insert/read eder
CREATE POLICY "log_insert" ON islem_log
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "log_read" ON islem_log
  FOR SELECT USING (auth.uid() = user_id);

-- Genel okuma politikaları (kimlik doğrulaması yeterli)
ALTER TABLE toptanci     ENABLE ROW LEVEL SECURITY;
ALTER TABLE perakendeci  ENABLE ROW LEVEL SECURITY;
ALTER TABLE urun         ENABLE ROW LEVEL SECURITY;
ALTER TABLE urun_kategori ENABLE ROW LEVEL SECURITY;
ALTER TABLE kargo        ENABLE ROW LEVEL SECURITY;

CREATE POLICY "toptanci_read"      ON toptanci      FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "perakendeci_read"   ON perakendeci   FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "urun_read"          ON urun          FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "urun_kategori_read" ON urun_kategori FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "kargo_read"         ON kargo         FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "perakendeci_insert" ON perakendeci   FOR INSERT WITH CHECK (true);
CREATE POLICY "toptanci_insert"    ON toptanci      FOR INSERT WITH CHECK (true);

-- ============================================================
-- TEST VERİLERİ
-- ============================================================

-- Toptancılar (15 kayıt)
INSERT INTO toptanci (firma_adi, vergi_no, telefon, email, adres, sehir) VALUES
('Ankara Optik A.Ş.',         '1111111111', '0312 111 11 11', 'info@ankaraoptik.com',    'Kızılay Cad. No:1',    'Ankara'),
('İstanbul Lens San.',         '2222222222', '0212 222 22 22', 'info@istanbullens.com',   'Bağcılar Yolu No:5',   'İstanbul'),
('Konya Optik Dağıtım',        '3333333333', '0332 333 33 33', 'info@konyaoptik.com',     'Selçuk Cad. No:10',    'Konya'),
('İzmir Gözlük Toptan',        '4444444444', '0232 444 44 44', 'info@izmiroptik.com',     'Karşıyaka Blv. No:20', 'İzmir'),
('Bursa Lens Merkezi',         '5555555555', '0224 555 55 55', 'info@bursalens.com',      'Nilüfer Cad. No:15',   'Bursa'),
('Antalya Optik Ltd.',         '6666666666', '0242 666 66 66', 'info@antalyaoptik.com',   'Lara Yolu No:8',       'Antalya'),
('Adana Çerçeve A.Ş.',         '7777777777', '0322 777 77 77', 'info@adanacerceve.com',   'Seyhan Cad. No:3',     'Adana'),
('Gaziantep Cam San.',          '8888888888', '0342 888 88 88', 'info@gazioptik.com',      'Şahinbey Blv. No:12',  'Gaziantep'),
('Mersin Optik Toptancı',      '9999999999', '0324 999 99 99', 'info@mersinoptik.com',    'Mezitli Cad. No:6',    'Mersin'),
('Kayseri Lens Dağıtım',       '1010101010', '0352 101 10 10', 'info@kayserilens.com',    'Melikgazi No:9',       'Kayseri'),
('Eskişehir Optik Toptancı',   '1111212121', '0222 111 21 21', 'info@eskioptik.com',      'Tepebaşı Cad. No:4',   'Eskişehir'),
('Diyarbakır Cam Merkezi',     '1212121212', '0412 121 21 21', 'info@diyarcam.com',       'Sur İlçesi No:7',      'Diyarbakır'),
('Samsun Lens A.Ş.',           '1313131313', '0362 131 31 31', 'info@samsunlens.com',     'İlkadım Blv. No:11',   'Samsun'),
('Trabzon Optik San.',          '1414141414', '0462 141 41 41', 'info@trabzonoptik.com',   'Meydan Cad. No:2',     'Trabzon'),
('Malatya Gözlük Ltd.',        '1515151515', '0422 151 51 51', 'info@malatyaoptik.com',   'Battalgazi No:13',     'Malatya');

-- Perakendeciler (15 kayıt — per_id=1 Mustafa Kartal)
INSERT INTO perakendeci (magaza_adi, sahip_adi, vergi_no, telefon, email, adres, sehir) VALUES
('Konya Gözlükçüsü',           'Mustafa Kartal',    '243301046',   '0332 100 00 01', 'mustafa@konyagoz.com',  'Mevlana Cad. No:1',    'Konya'),
('İstanbul Optik',             'Ahmet Yılmaz',      '2000000002',  '0212 200 00 02', 'ahmet@istoptik.com',    'Bağcılar No:2',        'İstanbul'),
('Ankara Gözlükcü',            'Mehmet Demir',      '2000000003',  '0312 300 00 03', 'mehmet@angoz.com',      'Çankaya No:3',         'Ankara'),
('İzmir Optik Center',         'Fatma Kaya',        '2000000004',  '0232 400 00 04', 'fatma@izmiroptik.com',  'Konak No:4',           'İzmir'),
('Bursa Gözlük Evi',           'Ayşe Çelik',        '2000000005',  '0224 500 00 05', 'ayse@bursagoz.com',     'Osmangazi No:5',       'Bursa'),
('Antalya Optikçi',            'Ali Şahin',         '2000000006',  '0242 600 00 06', 'ali@antgoz.com',        'Muratpaşa No:6',       'Antalya'),
('Adana Lens Mağazası',        'Hatice Öztürk',     '2000000007',  '0322 700 00 07', 'hatice@adalens.com',    'Çukurova No:7',        'Adana'),
('Gaziantep Optik',            'Hüseyin Arslan',    '2000000008',  '0342 800 00 08', 'huseyin@gaziopt.com',   'Şehitkamil No:8',      'Gaziantep'),
('Mersin Gözlükçü',            'Zeynep Doğan',      '2000000009',  '0324 900 00 09', 'zeynep@mersigoz.com',   'Akdeniz No:9',         'Mersin'),
('Kayseri Optik Dünyası',      'Emre Yıldız',       '2000000010',  '0352 100 00 10', 'emre@kayoptik.com',     'Kocasinan No:10',      'Kayseri'),
('Eskişehir Gözlük Stüdyo',   'Deniz Aydın',       '2000000011',  '0222 110 00 11', 'deniz@eskigoz.com',     'Odunpazarı No:11',     'Eskişehir'),
('Diyarbakır Optikçisi',       'Serkan Güneş',      '2000000012',  '0412 120 00 12', 'serkan@diyaropt.com',   'Bağlar No:12',         'Diyarbakır'),
('Samsun Lens Dünyası',        'Elif Çetin',        '2000000013',  '0362 130 00 13', 'elif@samslens.com',     'Atakum No:13',         'Samsun'),
('Trabzon Optik Merkezi',      'Burak Kılıç',       '2000000014',  '0462 140 00 14', 'burak@trabopt.com',     'Ortahisar No:14',      'Trabzon'),
('Malatya Gözlük Evi',        'Selin Erdoğan',     '2000000015',  '0422 150 00 15', 'selin@maloptik.com',    'Yeşilyurt No:15',      'Malatya');

-- Ürün Kategorileri
INSERT INTO urun_kategori (kategori_adi, aciklama) VALUES
('Cam',     'Gözlük camları — tek odaklı, çift odaklı, progresif'),
('Çerçeve', 'Gözlük çerçeveleri — metal, plastik, titanyum');

-- Ürünler (15 kayıt — mix CAM ve CERCEVE)
INSERT INTO urun (kat_id, top_id, urun_adi, marka, model, renk, malzeme, birim_fiyat, tip) VALUES
(1, 1,  'Zeiss Single Vision',    'Zeiss',   'SV Clear',       'Renksiz', 'Cam',       450.00,  'CAM'),
(1, 2,  'Essilor Varilux',        'Essilor', 'Varilux X',      'Renksiz', 'Cam',       850.00,  'CAM'),
(1, 3,  'Hoya Progressive',       'Hoya',    'ID MyStyle',     'Renksiz', 'Cam',       620.00,  'CAM'),
(1, 1,  'Zeiss Blue Guard',       'Zeiss',   'Blue Guard 1.6', 'Mavi AR', 'Cam',       380.00,  'CAM'),
(1, 2,  'Essilor Crizal',         'Essilor', 'Crizal Forte',   'Renksiz', 'Cam',       290.00,  'CAM'),
(2, 4,  'Ray-Ban Classic',        'Ray-Ban', 'RB5228',         'Siyah',   'Asetat',    1200.00, 'CERCEVE'),
(2, 5,  'Oakley Titanium',        'Oakley',  'OX3218',         'Gümüş',   'Titanyum',  1800.00, 'CERCEVE'),
(2, 6,  'Prada Minimal',          'Prada',   'PR 05YV',        'Kahve',   'Metal',     2500.00, 'CERCEVE'),
(2, 4,  'Gucci Fashion',          'Gucci',   'GG0522O',        'Altın',   'Metal',     3200.00, 'CERCEVE'),
(2, 7,  'Tom Ford Luxury',        'Tom Ford','FT5634-B',       'Siyah',   'Asetat',    2800.00, 'CERCEVE'),
(1, 3,  'Hoya Blue Control',      'Hoya',    'Blue Control',   'Renksiz', 'Cam',       340.00,  'CAM'),
(2, 5,  'Oakley Sport',           'Oakley',  'OX8046',         'Mat Siyah','Plastik',  1400.00, 'CERCEVE'),
(2, 6,  'Prada Sport',            'Prada',   'PR 03WV',        'Lacivert', 'Asetat',   2200.00, 'CERCEVE'),
(1, 1,  'Zeiss Photofusion',      'Zeiss',   'Photofusion 3',  'Gri',     'Fotokromik',520.00,  'CAM'),
(2, 7,  'Tom Ford Classic',       'Tom Ford','FT5294',         'Havana',  'Asetat',    2600.00, 'CERCEVE');

-- Stok (15 kayıt — çeşitli durumlar)
INSERT INTO stok (urun_id, top_id, miktar, min_stok) VALUES
(1,  1,  25, 5),   -- NORMAL
(2,  2,  12, 5),   -- NORMAL
(3,  3,   3, 5),   -- DÜŞÜK
(4,  1,  18, 5),   -- NORMAL
(5,  2,   0, 5),   -- KRİTİK
(6,  4,   8, 5),   -- NORMAL
(7,  5,   2, 5),   -- DÜŞÜK
(8,  6,  15, 5),   -- NORMAL
(9,  4,   1, 5),   -- KRİTİK
(10, 7,  20, 5),   -- NORMAL
(11, 3,   4, 5),   -- DÜŞÜK
(12, 5,  10, 5),   -- NORMAL
(13, 6,   6, 5),   -- NORMAL
(14, 1,   0, 5),   -- KRİTİK
(15, 7,  14, 5);   -- NORMAL

-- Siparişler (15 kayıt — sip_id 1001-1015, ilk 4'ü Mustafa Kartal)
-- NOT: SERIAL otomatik 1'den başlar. Aşağıdaki ID'leri 1001'den başlatmak için:
SELECT setval('siparis_sip_id_seq', 1000);

INSERT INTO siparis (per_id, top_id, siparis_tarihi, durum, toplam_tutar, odeme_turu, teslim_tarihi) VALUES
(1,  1, '2024-11-01', 'Teslim Edildi', 900.00,  'Havale',      '2024-11-05'),  -- 1001
(1,  2, '2024-11-10', 'Kargoda',       1700.00, 'Kredi Kartı', '2024-11-15'),  -- 1002
(1,  3, '2024-11-20', 'Hazırlanıyor',  620.00,  'Havale',      NULL),           -- 1003
(1,  4, '2024-11-25', 'İptal',         1200.00, 'Kredi Kartı', NULL),           -- 1004
(2,  1, '2024-11-02', 'Teslim Edildi', 850.00,  'Havale',      '2024-11-06'),  -- 1005
(3,  2, '2024-11-12', 'Kargoda',       2500.00, 'Kredi Kartı', '2024-11-17'),  -- 1006
(4,  3, '2024-11-15', 'Teslim Edildi', 1240.00, 'Havale',      '2024-11-20'),  -- 1007
(5,  4, '2024-11-18', 'Hazırlanıyor',  1800.00, 'Kredi Kartı', NULL),           -- 1008
(6,  5, '2024-11-20', 'Kargoda',       3200.00, 'Havale',      '2024-11-25'),  -- 1009
(7,  6, '2024-11-22', 'Teslim Edildi', 2800.00, 'Kredi Kartı', '2024-11-26'),  -- 1010
(8,  7, '2024-11-23', 'Hazırlanıyor',  1400.00, 'Havale',      NULL),           -- 1011
(9,  1, '2024-11-24', 'Kargoda',       760.00,  'Kredi Kartı', '2024-11-29'),  -- 1012
(10, 2, '2024-11-25', 'Teslim Edildi', 1700.00, 'Havale',      '2024-11-29'),  -- 1013
(11, 3, '2024-11-26', 'Hazırlanıyor',  620.00,  'Kredi Kartı', NULL),           -- 1014
(12, 4, '2024-11-27', 'İptal',         2400.00, 'Havale',      NULL);           -- 1015

-- Sipariş Detaylar (her sipariş için 1 satır)
INSERT INTO siparis_detay (sip_id, urun_id, miktar, birim_fiyat, indirim_orani, ara_toplam) VALUES
(1001, 1,  2, 450.00,  0, 900.00),
(1002, 2,  2, 850.00,  0, 1700.00),
(1003, 3,  1, 620.00,  0, 620.00),
(1004, 6,  1, 1200.00, 0, 1200.00),
(1005, 2,  1, 850.00,  0, 850.00),
(1006, 8,  1, 2500.00, 0, 2500.00),
(1007, 4,  2, 380.00,  0, 760.00),
(1008, 7,  1, 1800.00, 0, 1800.00),
(1009, 9,  1, 3200.00, 0, 3200.00),
(1010, 10, 1, 2800.00, 0, 2800.00),
(1011, 12, 1, 1400.00, 0, 1400.00),
(1012, 11, 2, 340.00,  0, 680.00),
(1013, 2,  2, 850.00,  0, 1700.00),
(1014, 3,  1, 620.00,  0, 620.00),
(1015, 13, 1, 2200.00, 0, 2200.00);

-- Kargo (15 kayıt)
INSERT INTO kargo (sip_id, kargo_firmasi, takip_no, gonderim_tarihi, teslim_tarihi, kargo_durumu) VALUES
(1001, 'Yurtiçi Kargo', 'YK202411010001', '2024-11-02', '2024-11-05', 'Teslim Edildi'),
(1002, 'Aras Kargo',    'AK202411100002', '2024-11-11', NULL,          'Dağıtımda'),
(1003, 'MNG Kargo',     'MNG20241120003', NULL,          NULL,          'Hazırlanıyor'),
(1004, 'PTT Kargo',     'PTT20241125004', NULL,          NULL,          'İptal'),
(1005, 'Yurtiçi Kargo', 'YK202411020005', '2024-11-03', '2024-11-06', 'Teslim Edildi'),
(1006, 'Aras Kargo',    'AK202411120006', '2024-11-13', NULL,          'Dağıtımda'),
(1007, 'MNG Kargo',     'MNG20241115007', '2024-11-16', '2024-11-20', 'Teslim Edildi'),
(1008, 'PTT Kargo',     'PTT20241118008', NULL,          NULL,          'Hazırlanıyor'),
(1009, 'Yurtiçi Kargo', 'YK202411200009', '2024-11-21', NULL,          'Dağıtımda'),
(1010, 'Aras Kargo',    'AK202411220010', '2024-11-23', '2024-11-26', 'Teslim Edildi'),
(1011, 'MNG Kargo',     'MNG20241123011', NULL,          NULL,          'Hazırlanıyor'),
(1012, 'PTT Kargo',     'PTT20241124012', '2024-11-25', NULL,          'Dağıtımda'),
(1013, 'Yurtiçi Kargo', 'YK202411250013', '2024-11-26', '2024-11-29', 'Teslim Edildi'),
(1014, 'Aras Kargo',    'AK202411260014', NULL,          NULL,          'Hazırlanıyor'),
(1015, 'MNG Kargo',     'MNG20241127015', NULL,          NULL,          'İptal');

-- ============================================================
-- TEST KULLANICILARI OLUŞTURMA
-- Aşağıdaki adımları Supabase Dashboard'da yapın:
-- 1. Authentication → Users → "Add User" → "Create New User"
--    Email: perakendeci@optik.com | Şifre: Optik2026!
--    Email: toptanci@optik.com    | Şifre: Optik2026!
-- 2. UUID'leri kopyalayın ve aşağıdaki SQL'i çalıştırın:
-- ============================================================
-- INSERT INTO profiles (id, role, per_id, full_name) VALUES
--   ('<UUID_PERAKENDECI>', 'perakendeci', 1, 'Mustafa Kartal');
-- INSERT INTO profiles (id, role, top_id, full_name) VALUES
--   ('<UUID_TOPTANCI>', 'toptanci', 1, 'Ankara Optik Yönetici');
