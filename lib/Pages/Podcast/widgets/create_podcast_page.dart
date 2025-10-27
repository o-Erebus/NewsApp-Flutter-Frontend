import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finalyear/Providers/podcast_provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import '../../../Models/podcast_model.dart' as pm;

class CreatePodcastPage extends StatefulWidget {
  final pm.Podcast? existingPodcast;
  const CreatePodcastPage({super.key, this.existingPodcast});

  @override
  State<CreatePodcastPage> createState() => _CreatePodcastPageState();
}

class _CreatePodcastPageState extends State<CreatePodcastPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _topicController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  bool _isPublic = true;
  bool _isLoading = false;
  late final bool _isEdit;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
    _isEdit = widget.existingPodcast != null;

    if (_isEdit) {
      final p = widget.existingPodcast!;
      _titleController.text = p.title;
      _descriptionController.text = p.description;
      _imageUrlController.text = p.imageUrl;
      _isPublic = p.isPublic;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: colorScheme.onSurface,
                            size: 28,
                          ),
                        ),
                      ),
                      Text(
                        _isEdit ? 'Edit Podcast' : 'Create Podcast',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(width: 48), // Spacer for alignment
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Conditionally show Topic or Title based on mode
                        if (!_isEdit) ...[
                          // Topic Field (for creation only)
                          Text(
                            'Topic',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _topicController,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Enter podcast topic or description',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter a podcast topic';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          // Title Field (for editing only)
                          Text(
                            'Podcast Title',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Enter podcast title',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter a podcast title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Description Field (only in edit mode)
                        if (_isEdit) ...[
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(color: colorScheme.onSurface),
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe your podcast',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // // Image URL Field (only in edit mode)
                        // if (_isEdit) ...[
                        //   Text(
                        //     'Podcast Image URL',
                        //     style: Theme.of(context).textTheme.titleSmall
                        //         ?.copyWith(
                        //           color: colorScheme.onSurface,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //   ),
                        //   const SizedBox(height: 12),
                        //   TextFormField(
                        //     controller: _imageUrlController,
                        //     style: TextStyle(color: colorScheme.onSurface),
                        //     decoration: InputDecoration(
                        //       hintText: 'https://example.com/image.png',
                        //       hintStyle: TextStyle(
                        //         color: colorScheme.onSurfaceVariant,
                        //       ),
                        //       filled: true,
                        //       fillColor: colorScheme.surfaceContainer,
                        //       border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //       contentPadding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //         vertical: 14,
                        //       ),
                        //     ),
                        //     validator: (value) {
                        //       if (value?.isEmpty ?? true) {
                        //         return 'Please enter image URL';
                        //       }
                        //       if (!value!.startsWith('http')) {
                        //         return 'Please enter a valid URL';
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        //   const SizedBox(height: 24),
                        // ],

                        // Public/Private Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Make Podcast Public',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            StatefulBuilder(
                              builder: (context, setModalState) => Switch(
                                value: _isPublic,
                                onChanged: (value) {
                                  setModalState(() {
                                    _isPublic = value;
                                  });
                                },
                                activeColor: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Create / Update Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      try {
                                        if (_isEdit) {
                                          // Update existing podcast
                                          final success = await context
                                              .read<PodcastProvider>()
                                              .updatePodcast(
                                                podcastId:
                                                    widget.existingPodcast!.id,
                                                title: _titleController.text,
                                                description:
                                                    _descriptionController.text,
                                                imageUrl:
                                                    _imageUrlController.text,
                                                isPublic: _isPublic,
                                              );

                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });

                                            if (success) {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.success(
                                                  message: 'Podcast updated',
                                                ),
                                                displayDuration: const Duration(
                                                  seconds: 2,
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                            } else {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.error(
                                                  message:
                                                      'Failed to update podcast',
                                                ),
                                                displayDuration: const Duration(
                                                  seconds: 2,
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          // Create new podcast
                                          final podcastId = await context
                                              .read<PodcastProvider>()
                                              .createPodcast(
                                                topic: _topicController.text,
                                                isPublic: _isPublic,
                                              );

                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });

                                            if (podcastId != null) {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.success(
                                                  message:
                                                      'Podcast generation started',
                                                ),
                                                displayDuration: const Duration(
                                                  seconds: 2,
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                              // Refresh the user's podcasts
                                              context
                                                  .read<PodcastProvider>()
                                                  .fetchUserPodcasts();
                                            } else {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.error(
                                                  message:
                                                      'Failed to create podcast',
                                                ),
                                                displayDuration: const Duration(
                                                  seconds: 2,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            CustomSnackBar.error(
                                              message: 'Error: $e',
                                            ),
                                            displayDuration: const Duration(
                                              seconds: 2,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: colorScheme.primary
                                  .withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _isEdit
                                        ? 'Update Podcast'
                                        : 'Create Podcast',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: colorScheme.onPrimary,
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
          ),
        ),
      ),
    );
  }
}
