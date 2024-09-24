import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_it/share_it.dart';

import 'QuoteProvider.dart';

class LikedQuotesPage extends StatelessWidget {
  const LikedQuotesPage({super.key});

  static const appLink =
      'https://play.google.com/store/apps/details?id=com.titi.newcquote';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Quotes'),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('asset/img6.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Consumer<QuoteProvider>(
          builder: (context, quoteProvider, child) {
            if (quoteProvider.favorites.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 10,
                      color: Colors.green,
                    ),
                    Text("No Like quote", style: TextStyle(color: Colors.white),)
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: quoteProvider.favorites.length,
                itemBuilder: (context, index) {
                  final quote = quoteProvider.favorites[index];

                  final quoteText = quote.text;
                  final author = quote.author;

                  void share() {
                    final shareText =
                        '"$quoteText" - $author $appLink';
                    ShareIt.text(
                      content: shareText,
                      androidSheetTitle: 'Share Quote',
                    );
                  }

                  return Card(
                    child: ListTile(
                      title: Text(quote.text),
                      subtitle: Column(
                        children: [
                          const SizedBox(height: 10,),
                          Text('Author: ${quote.author}'
                            ,style: const TextStyle(fontSize: 10)),
                          const Divider(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red,),
                                onPressed: () {
                                  quoteProvider.removeFavorite(quote);
                                },
                              ),

                              IconButton(
                                onPressed: share,
                                icon: const Icon(Icons.share),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ]),
    );
  }
}
