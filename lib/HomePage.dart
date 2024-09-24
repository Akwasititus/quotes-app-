import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:finalcquotes/sharedPrefFavList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:share_it/share_it.dart';


import 'QuoteProvider.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> backgroundImages = [
    'asset/img6.jpg',
    'asset/img2.jpg',
    'asset/img3.jpg',
    'asset/img4.jpg',
    'asset/img.jpg',
    'asset/img7.jpg',
  ];

  int currentImageIndex = 0;
  Timer? _timer;


  @override
  void initState() {
    super.initState();
    _startImageTimer();
    Future.microtask(
        () => Provider.of<QuoteProvider>(context, listen: false).fetchQuotes());
  }



  String appLink =
      "https://play.google.com/store/apps/details?id=com.titi.newcquote";


  @override
  void dispose() {
    _stopImageTimer();
    super.dispose();
  }

  void _startImageTimer() {
    _timer = Timer.periodic(const Duration(minutes: 3), (Timer timer) {
      setState(() {
        currentImageIndex = (currentImageIndex + 1) % backgroundImages.length;
      });
    });
  }

  void _stopImageTimer() {
    _timer?.cancel();
  }

  void _copyQuote(String quoteText) {
    Clipboard.setData(ClipboardData(text: quoteText));
    EasyLoading.showSuccess('Quote copied to clipboard');
  }

  void shareAppLink() {
    ShareIt.link(
        androidSheetTitle:
            'Looking for an inspirational quote that will inspire your life? Download this app now',
        url: appLink);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Wise Christian Quotes"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  ),
              child: Text("Wise Christian Quotes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  wordSpacing: 1.5,
                  letterSpacing: 1.5,
                ),),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite_border_outlined),
                title: const Text('Favorite'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LikedQuotesPage()));
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share App'),
                onTap: () {
                  Navigator.pop(context);
                  shareAppLink();
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      body:
      Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImages[currentImageIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Consumer<QuoteProvider>(
            builder: (context, quoteProvider, child) {
              if (quoteProvider.quotes.isEmpty) {

                return const Center(child: CircularProgressIndicator());
              } else {
                return Center(
                  child: CarouselSlider.builder(
                    itemCount: quoteProvider.quotes.length,
                    itemBuilder: (context, index, pageViewIndex) {
                      final quote = quoteProvider.quotes[index];
                      final quoteText = quote.text;
                      final author = quote.author;

                      void share() {
                        final shareText =
                            '"$quoteText" - $author \n\n $appLink';
                        ShareIt.text(
                          content: shareText,
                          androidSheetTitle: 'Share Quote',
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              quoteText,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 15,
                                wordSpacing: 1.5,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Divider(),
                            Text('Author: $author'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: share,
                                  icon: const Icon(Icons.share),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  onPressed: () => _copyQuote(quoteText),
                                  icon: const Icon(Icons.copy),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: Icon(
                                      quoteProvider.isFavorite(quote)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red),
                                  onPressed: () {
                                    if (quoteProvider.isFavorite(quote)) {
                                      quoteProvider.removeFavorite(quote);
                                    } else {
                                      quoteProvider.addFavorite(quote);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: height * 3,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(minutes: 1),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 1000),
                      autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                      enlargeFactor: 0.3,
                      scrollDirection: Axis.vertical,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
