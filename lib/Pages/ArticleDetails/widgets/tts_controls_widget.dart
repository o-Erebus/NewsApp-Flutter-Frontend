import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Providers/tts_provider.dart';

class TTSControlsWidget extends StatelessWidget {
  final String textToRead;

  const TTSControlsWidget({super.key, required this.textToRead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ttsProvider = Provider.of<TTSProvider>(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Voice selection button (left)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => ttsProvider.toggleVoice(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            color: theme.colorScheme.onSurface,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Voice ${ttsProvider.currentVoiceIndex + 1}",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Play/Pause button (center)
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => ttsProvider.togglePlayPause(textToRead),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    ttsProvider.isPlaying
                        ? Icons.pause
                        : ttsProvider.isPaused
                        ? Icons
                              .play_arrow // resume
                        : Icons.play_arrow, // fresh start
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),

            // Speed control button (right)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => ttsProvider.changeSpeed(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed,
                            color: theme.colorScheme.onSurface,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${ttsProvider.currentUiSpeed}x",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
