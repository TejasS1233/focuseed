import 'dart:convert';
import 'package:just_audio/just_audio.dart';

class TrackConfig {
  final String key;
  final String label;

  const TrackConfig({required this.key, required this.label});
}

class AudioMixerService {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {};
  bool _initialized = false;

  static const tracks = [
    TrackConfig(key: 'rain', label: 'Rain'),
    TrackConfig(key: 'lofi', label: 'Lo-fi'),
    TrackConfig(key: 'whitenoise', label: 'White Noise'),
    TrackConfig(key: 'forest', label: 'Forest'),
    TrackConfig(key: 'drone', label: 'Drone'),
  ];

  static const _urls = {
    'rain': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'lofi': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'whitenoise': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'forest': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    'drone': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  };

  Future<void> init() async {
    if (_initialized) return;
    for (final track in tracks) {
      final player = AudioPlayer();
      await player.setUrl(_urls[track.key]!);
      await player.setLoopMode(LoopMode.all);
      player.setVolume(0);
      _players[track.key] = player;
      _volumes[track.key] = 0.0;
    }
    _initialized = true;
  }

  double getVolume(String key) => _volumes[key] ?? 0;

  Future<void> setVolume(String key, double volume) async {
    _volumes[key] = volume;
    await _players[key]?.setVolume(volume);
    if (volume > 0 && _players[key]?.playing != true) {
      await _players[key]?.play();
    } else if (volume == 0 && _players[key]?.playing == true) {
      await _players[key]?.stop();
    }
  }

  bool get isPlaying => _players.values.any((p) => p.playing);

  Future<void> applyMix(Map<String, double> mix) async {
    for (final entry in mix.entries) {
      await setVolume(entry.key, entry.value);
    }
  }

  Future<void> playAll() async {
    for (final entry in _players.entries) {
      if ((_volumes[entry.key] ?? 0) > 0) {
        await entry.value.play();
      }
    }
  }

  Future<void> pauseAll() async {
    for (final player in _players.values) {
      await player.pause();
    }
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _volumes.clear();
    _initialized = false;
  }

  static String serializeMix(Map<String, double> mix) {
    return jsonEncode(mix);
  }

  static Map<String, double> deserializeMix(String? data) {
    if (data == null || data.isEmpty) return {};
    try {
      if (data.startsWith('{')) {
        final parsed = jsonDecode(data) as Map<String, dynamic>;
        return parsed.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
      return {data: 0.8};
    } catch (_) {
      return {};
    }
  }

  static bool isEmptyMix(Map<String, double> mix) {
    return mix.values.every((v) => v <= 0);
  }
}
