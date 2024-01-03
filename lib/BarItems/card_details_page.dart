import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardDetailsPage extends StatelessWidget {
  final int cardNumber;

  const CardDetailsPage({Key? key, required this.cardNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Room $cardNumber',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Details for Card $cardNumber'),
      ),
    );
  }
}
