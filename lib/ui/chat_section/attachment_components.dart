import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'models.dart';

// Widget to display attachment preview in input area
class AttachmentPreviewWidget extends StatelessWidget {
  final List<ChatAttachment> attachments;
  final Function(int) onRemove;

  const AttachmentPreviewWidget({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            attachments.length,
            (index) => _buildAttachmentTile(attachments[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentTile(ChatAttachment attachment, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAttachmentIcon(attachment),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  child: Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.formattedSize,
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentIcon(ChatAttachment attachment) {
    if (attachment.isImage) {
      return Image.file(
        File(attachment.filePath),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    } else if (attachment.isVideo) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.videocam,
          color: Colors.white,
          size: 30,
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.insert_drive_file,
          color: Colors.white,
          size: 30,
        ),
      );
    }
  }
}

// Widget to display attachments in chat messages
class MessageAttachmentsWidget extends StatelessWidget {
  final List<ChatAttachment> attachments;

  const MessageAttachmentsWidget({
    super.key,
    required this.attachments,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        attachments.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildAttachmentWidget(attachments[index]),
        ),
      ),
    );
  }

  Widget _buildAttachmentWidget(ChatAttachment attachment) {
    if (attachment.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(attachment.filePath),
          width: 300,
          fit: BoxFit.cover,
        ),
      );
    } else if (attachment.isVideo) {
      return Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 60,
              color: Colors.grey[600],
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                attachment.fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Generic file attachment
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.formattedSize,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.download, color: Colors.blue, size: 20),
          ],
        ),
      );
    }
  }
}

// Bottom sheet for selecting attachment type
class AttachmentBottomSheet extends StatelessWidget {
  final Function(String) onSelected;

  const AttachmentBottomSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Attach',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachmentOption(
                context,
                icon: Icons.image,
                label: 'Images',
                onTap: () {
                  Navigator.pop(context);
                  onSelected('image');
                },
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.videocam,
                label: 'Videos',
                onTap: () {
                  Navigator.pop(context);
                  onSelected('video');
                },
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.insert_drive_file,
                label: 'Files',
                onTap: () {
                  Navigator.pop(context);
                  onSelected('file');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying an attachment from the server (network URL)
class ServerAttachmentWidget extends StatelessWidget {
  final String? fileUrl;
  final String? fileName;
  final String? fileType;

  const ServerAttachmentWidget({
    super.key,
    this.fileUrl,
    this.fileName,
    this.fileType,
  });

  bool get _isImage {
    if (fileType != null && fileType!.startsWith('image/')) return true;
    if (fileName != null) {
      final ext = fileName!.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (fileUrl == null || fileUrl!.isEmpty) return const SizedBox.shrink();

    if (_isImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: fileUrl!,
              width: 220,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 220,
                height: 140,
                color: Colors.grey[300],
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                width: 220,
                height: 140,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          if (fileName != null && fileName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                fileName!,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.blue[700], size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                fileName ?? 'File',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }
}
