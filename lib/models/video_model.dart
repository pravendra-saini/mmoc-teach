class VideoModel {
  final String title;
  final String videoUrl;
  final int duration;
  bool completed;

  VideoModel({
    required this.title,
    required this.videoUrl,
    required this.duration,
    this.completed = false,
  });
}