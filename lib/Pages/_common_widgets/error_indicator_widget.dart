import 'package:flutter/material.dart';


class ErrorIndicatorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const ErrorIndicatorWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Try again later.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed:
          //       onRetry ??
          //       () {
          //         // Default retry action if not provided
          //         final newsProvider = context.read<NewsProvider>();
          //         // Refresh the global paging controller
          //         newsProvider.globalPagingController.refresh();
          //       },
          //   child: const Text('Retry'),
          // ),
        ],
      ),
    );
  }
}
