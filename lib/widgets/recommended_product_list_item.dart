import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recommended_product.dart';
import '../pages/product_detail_page.dart';

class RecommendedProductListItem extends StatelessWidget {
  final RecommendedProduct product;
  final int rank;

  const RecommendedProductListItem({
    super.key,
    required this.product,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Ranking Number
              Text(
                '#$rank',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Image.asset(
                product.image,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: Icon(
                    product.type == ProductType.laptop ? Icons.laptop_mac : Icons.phone_android,
                    size: 50,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      priceFormatter.format(product.price),
                      style: const TextStyle(color: Color(0xFFe74c3c), fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        'Value: ${product.valueScore.toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: product.valueScore > 0 ? const Color(0xFF2980b9) : const Color(0xFFc0392b),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
