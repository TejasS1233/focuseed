import 'package:just_audio/just_audio.dart';

class AudioService {
  final _player = AudioPlayer();
  bool _isPlaying = false;

  final Map<String, String> sounds = {
    'rain': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'lofi': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'whitenoise': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  };

  bool get isPlaying => _isPlaying;

  Future<void> play(String soundKey) async {
    final url = sounds[soundKey];
    if (url == null) return;
    await _player.setUrl(url);
    await _player.setLoopMode(LoopMode.all);
    await _player.play();
    _isPlaying = true;
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }
}
