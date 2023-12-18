class KitapSinifi {
  String? kitapIsmi;
  String? yayinEvi;
  String? yazarlar;
  String? kitapTuru;
  int? sayfaSayisi;
  int? basimYili;
  bool? yayinlanacakMi;

  KitapSinifi(
      {this.kitapIsmi,
      this.yayinEvi,
      this.yazarlar,
      this.kitapTuru,
      this.sayfaSayisi,
      this.basimYili,
      this.yayinlanacakMi});

  KitapSinifi.fromJson(Map<String, dynamic> json) {
    kitapIsmi = json['kitapIsmi'];
    yayinEvi = json['yayinEvi'];
    yazarlar = json['yazarlar'];
    kitapTuru = json['kitapTuru'];
    sayfaSayisi = json['sayfaSayisi'];
    basimYili = json['basimYili'];
    yayinlanacakMi = json['yayinlanacakMi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kitapIsmi'] = kitapIsmi;
    data['yayinEvi'] = yayinEvi;
    data['yazarlar'] = yazarlar;
    data['kitapTuru'] = kitapTuru;
    data['sayfaSayisi'] = sayfaSayisi;
    data['basimYili'] = basimYili;
    data['yayinlanacakMi'] = yayinlanacakMi;
    return data;
  }
}
