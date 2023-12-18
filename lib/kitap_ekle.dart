// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/anasayfa.dart';
import 'package:flutter_application_1/kitap_s%C4%B1n%C4%B1f%C4%B1.dart';


class KitapEkle extends StatefulWidget {
  const KitapEkle({
    Key? key,
    this.updateBookProperties,
  }) : super(key: key);

  final KitapSinifi? updateBookProperties;
  @override
  State<KitapEkle> createState() => _KitapEkleState();
}

class _KitapEkleState extends State<KitapEkle> {
  final GlobalKey<FormState> _key = GlobalKey();
  String? _selectedBookCategory;
  final List<String> _items = ['Roman', 'Piskoloji', 'Tarih', 'Bilim Kurgu', 'Polisiye'];
  bool _isChecked = true;

  // FormField Controller değişkenleri
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _bookPageNumberController = TextEditingController();
  final TextEditingController _bookPublishedsYear = TextEditingController();
  @override
  void initState() {
    if (widget.updateBookProperties != null) {
      final book = widget.updateBookProperties;
      _bookNameController.text = book?.kitapIsmi ?? "";
      _publisherController.text = book?.yayinEvi ?? "";
      _authorController.text = book?.yazarlar ?? "";
      _bookPageNumberController.text = book!.sayfaSayisi.toString();
      _bookPublishedsYear.text = book.basimYili.toString();
      _selectedBookCategory = book.kitapTuru;
      _isChecked = book.yayinlanacakMi ?? true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomTextField(
                    hintText: "Kitap Adı",
                    controller: _bookNameController,
                  ),
                  CustomTextField(
                    hintText: "Yayınevi",
                    controller: _publisherController,
                  ),
                  CustomTextField(
                    hintText: "Yazarlar",
                    controller: _authorController,
                  ),
                  DropdownButton(
                      hint: const Text("Kitap Türünü Seçin"),
                      value: _selectedBookCategory,
                      items: _items
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          _selectedBookCategory = item;
                        });
                      }),
                  CustomTextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    hintText: "Sayfa Sayısı",
                    controller: _bookPageNumberController,
                  ),
                  CustomTextField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    hintText: "Basım Yılı",
                    controller: _bookPublishedsYear,
                  ),
                  ListTile(
                    title: const Text("Listede Yayınlanacak Mı?"),
                    trailing: Checkbox(
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false;
                            print(_isChecked);
                          });
                        }),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_key.currentState?.validate() ?? false) {
                          if (_selectedBookCategory != null) {
                            final bookName = _bookNameController.text.trim();
                            final publisher = _publisherController.text.trim();
                            final author = _authorController.text.trim();
                            final pageNumber = int.parse(_bookPageNumberController.text);
                            final publishedYear = int.tryParse(_bookPublishedsYear.text);
                            final bookCategory = _selectedBookCategory;
                            final isPublished = _isChecked;

                            final book = KitapSinifi(
                                    yazarlar: author,
                                    kitapIsmi: bookName,
                                    kitapTuru: bookCategory,
                                    yayinlanacakMi: isPublished,
                                    sayfaSayisi: pageNumber,
                                    basimYili: publishedYear,
                                    yayinEvi: publisher)
                                .toJson();

                            await FirebaseFirestore.instance.collection("kitaplar").doc(bookName).set(book);
                            Navigator.of(context)
                                .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Anasayfa()), (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen Kitap Türünü Seçin!')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Formu doğru bilgilerle doldurun")));
                        }
                      },
                      child: const Text("Kaydet"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey)),
      child: TextFormField(
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        validator: (value) {
          if (value?.isEmpty ?? false) {
            return "Lütfen bir değer girin";
          }
          return null;
        },
        controller: controller,
        decoration: InputDecoration(hintText: hintText),
      ),
    );
  }
}