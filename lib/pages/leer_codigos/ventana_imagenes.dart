// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:vientri/constants/app_colors.dart';

class ImagenesArticuloScreen extends StatefulWidget {
  final String codigoBarra;
  final String articuloDes;
  final String rubroDes;
  final Function(String base64Image) onImageSelected;

  const ImagenesArticuloScreen({
    super.key,
    required this.codigoBarra,
    required this.articuloDes,
    required this.rubroDes,
    required this.onImageSelected,
  });

  @override
  State<ImagenesArticuloScreen> createState() => _ImagenesArticuloScreenState();
}

class _ImagenesArticuloScreenState extends State<ImagenesArticuloScreen> {
  List<String> imageUrls = [];
  bool isLoading = true;
  String selectedFilter = 'Por código de barras';

  final List<String> filtros = [
    'Por código de barras',
    'Por rubro',
    'Por nombre del art.'
  ];

  @override
  void initState() {
    super.initState();

    if (widget.codigoBarra.trim().isEmpty) {
      selectedFilter = 'Por nombre del art.';
    } else {
      selectedFilter = 'Por código de barras';
    }

    _buscarImagenes();
  }

  Future<void> _buscarImagenes() async {
    try {
      setState(() => isLoading = true);

      await _buscarImagenesGoogle();
      
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _buscarImagenesGoogle() async {
    String url = "https://www.google.com/search?tbm=isch&q=${widget.codigoBarra}";
    if (selectedFilter == "Por código de barras") {
      url = "https://www.google.com/search?tbm=isch&q=${widget.codigoBarra}";
    } else if (selectedFilter ==  "Por rubro") {
      url = "https://www.google.com/search?tbm=isch&q=${widget.rubroDes.trim()}";
    } else if (selectedFilter ==  "Por nombre del art.") {
      url = "https://www.google.com/search?tbm=isch&q=${widget.articuloDes.trim()}";
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0 Safari/537.36',
      });

      final document = parser.parse(response.body);
      final images = document.querySelectorAll('img');

      final urls = images
          .map((img) => img.attributes['src'])
          .where((src) => src != null && src.startsWith('http'))
          .toSet()
          .take(20)
          .cast<String>()
          .toList();

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      print("Error al buscar imágenes en Google: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _convertirYSeleccionar(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      Uint8List bytes = response.bodyBytes;
      String base64Image = base64Encode(bytes);
      widget.onImageSelected(base64Image);
      Navigator.pop(context);
    } catch (e) {
      print("Error al convertir imagen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: filtros.map((filtro) {
            final selected = filtro == selectedFilter;
            return Theme(
              data: Theme.of(context).copyWith(
                chipTheme: Theme.of(context).chipTheme.copyWith(
                  side: BorderSide.none,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ChoiceChip(
                  label: Text(
                    filtro,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.semantics.text.body,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => selectedFilter = filtro);
                    _buscarImagenes();
                  },
                  selectedColor: AppColors.semantics.surface.action,
                  backgroundColor: AppColors.semantics.surface.disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            );
          }).toList(),
        ),
        
        
        const SizedBox(height: 10),
        
        SizedBox(
          width: double.maxFinite,
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : imageUrls.isEmpty
                    ? const Center(
                        child: Text(
                          "No se encontraron imágenes 😕",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: imageUrls.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          return Material(
                            child: GestureDetector(
                              onTap: () => _convertirYSeleccionar(url),
                              child: Hero(
                                tag: url,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
