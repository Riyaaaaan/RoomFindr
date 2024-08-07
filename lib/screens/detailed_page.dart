import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/widgets/my_ios_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DetailedPage extends StatelessWidget {
  final RentalProperty rental;

  final _controller = PageController();

  DetailedPage({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Convert Timestamp to DateTime
    DateTime createdAt = rental.createdAt.toDate();

    // Format the createdAt date
    String formattedDate = DateFormat('yMMMMd').format(createdAt);

    return Scaffold(
      appBar: AppBar(
        leading: const IosButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: size.height * 0.7,
              child: PageView.builder(
                controller: _controller,
                itemCount: rental.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    rental.imageUrls[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: rental.imageUrls.length,
                effect: const WormEffect(
                  radius: 16,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rental.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: rental.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              rental.isAvailable ? 'Available' : 'Unavailable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            rental.type,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ' ₹${rental.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rental.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Property Type : ${rental.propertyType}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location : ${rental.place}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted on : $formattedDate',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        launchUrlString('tel:+91${rental.contactNumber}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[100],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
