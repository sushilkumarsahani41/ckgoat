import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FileUploadWidget extends StatefulWidget {
  final Function(List<File>) onFilesSelected;

  const FileUploadWidget({super.key, required this.onFilesSelected});

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  List<File> selectedFiles = [];
  final int maxFileSize = 200 * 1024 * 1024; // 200 MB in bytes
  final int maxFiles = 6;
  Map<String, String?> videoThumbnails = {};

  void _pickAndUploadFiles() async {
    // Pick multiple files (images and videos)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif', 'mp4', 'avi', 'mov', 'mkv'],
    );

    if (result != null) {
      // Convert the picked files to a list of Dart files
      List<File> files = result.paths.map((path) => File(path!)).toList();

      // Check file sizes
      bool allFilesValid = true;
      for (File file in files) {
        if (file.lengthSync() > maxFileSize) {
          allFilesValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File ${file.path.split('/').last} exceeds the 200 MB size limit.',
              ),
            ),
          );
        }
      }

      if (!allFilesValid) {
        // Do not add any files if one or more files exceed the size limit
        return;
      } else if (selectedFiles.length + files.length > maxFiles) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only select up to $maxFiles files.')),
        );
      } else {
        // Add selected files to the state and generate thumbnails for video files
        setState(() {
          selectedFiles.addAll(files);
        });
        for (File file in files) {
          if (!_isImage(file)) {
            String? thumbnail = await _generateVideoThumbnail(file.path);
            setState(() {
              videoThumbnails[file.path] = thumbnail;
            });
          }
        }
        widget.onFilesSelected(selectedFiles); // Notify parent widget
      }
    } else {
      // User canceled the picker
    }
  }

  bool _isImage(File file) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = file.path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 150,
        quality: 75,
      );
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  void _previewFile(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilePreviewScreen(file: file),
      ),
    );
  }

  Widget _buildPreviewBox() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      dashPattern: const [8, 2],
      color: Colors.deepOrange,
      strokeWidth: 2,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade50.withOpacity(.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: selectedFiles.isEmpty
            ? GestureDetector(
                onTap: _pickAndUploadFiles,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.deepOrange, size: 50),
                      SizedBox(height: 8),
                      Text(
                        'Add Files',
                        style:
                            TextStyle(color: Colors.deepOrange, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFiles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _pickAndUploadFiles,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.deepOrange, width: 1),
                            ),
                            child: const Center(
                              child: Icon(Icons.add,
                                  color: Colors.deepOrange, size: 30),
                            ),
                          ),
                        ),
                      );
                    }

                    File file = selectedFiles[index - 1];
                    return Container(
                      margin: const EdgeInsets.all(5),
                      width: 100,
                      child: Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _previewFile(file),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isImage(file)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return const Center(
                                            child: Text('Invalid image',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          );
                                        },
                                      ),
                                    )
                                  : videoThumbnails.containsKey(file.path)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(videoThumbnails[file.path]!),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              return const Center(
                                                child: Text(
                                                    'Invalid video thumbnail',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              );
                                            },
                                          ),
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFiles.removeAt(index - 1);
                                  videoThumbnails.remove(file.path);
                                });
                                widget.onFilesSelected(
                                    selectedFiles); // Notify parent widget
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildPreviewBox(),
      ],
    );
  }
}

class FilePreviewScreen extends StatelessWidget {
  final File file;

  const FilePreviewScreen({super.key, required this.file});

  bool _isImage(File file) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = file.path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Preview'),
      ),
      body: Center(
        child:
            _isImage(file) ? Image.file(file) : VideoPlayerWidget(file: file),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  const VideoPlayerWidget({super.key, required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
