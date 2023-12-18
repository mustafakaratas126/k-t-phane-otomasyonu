import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/kitap_ekle.dart';
import 'package:flutter_application_1/kitap_s%C4%B1n%C4%B1f%C4%B1.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
 final List<BottomNavigationBarItem> _items = [
    const BottomNavigationBarItem(icon: Icon(Icons.book), label: "Kitaplar"),
    const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Satın Al"),
    const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ayarlar")
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> getBooks() {
    return FirebaseFirestore.instance.collection("kitaplar").where("yayinlanacakMi", isEqualTo: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(items: _items),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const KitapEkle()));
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            )),
        appBar: AppBar(
          title: const Text("MUSTAFA KARATAŞ KÜTÜPHANESİ"),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getBooks(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Hata Oluştu'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                final allBooks = snapshot.data?.docs;
                return Center(
                  child: ListView.builder(
                    itemCount: allBooks?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final book = KitapSinifi.fromJson(allBooks?[index].data() as Map<String, dynamic>);
                      return BooksCard(
                        book: book,
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: Text("Kütüphaneye Kayıtlı bir kitap yok"));
              }
            }));
  }
}


class BooksCard extends StatelessWidget {
  const BooksCard({
    Key? key,
    required this.book,
  }) : super(key: key);

  final KitapSinifi book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text("${book.kitapIsmi} -Basim yili: ${book.basimYili}"),
          subtitle: Text("Yazar: ${book.yazarlar}, Sayfa Sayısı: ${book.sayfaSayisi}"),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => KitapEkle(updateBookProperties: book)));
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          title: Center(child: Text("${book.kitapIsmi}")),
                          content: SizedBox(
                            height: 150,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                "${book.kitapIsmi} adlı kitabı kütüphaneden silmek istediğinize emin msisiniz?",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("İptal Et")),
                            ElevatedButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection("kitaplar").doc(book.kitapIsmi).delete();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text("Bu kitap başarıyla silindi: ${book.kitapIsmi}")));
                                },
                                child: const Text("Sil")),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.restore_from_trash_rounded)),
          ]),
        ),
      ),
    );
  }
}