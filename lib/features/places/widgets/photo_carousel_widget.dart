import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/widget/app_image.dart';

class PhotoCarouselWidget extends StatefulWidget {
  final List<String> photos;
  final double height;
  final double borderRadius;

  const PhotoCarouselWidget({
    super.key,
    required this.photos,
    this.height = 200,
    this.borderRadius = 8,
  });

  @override
  State<PhotoCarouselWidget> createState() => _PhotoCarouselWidgetState();
}

class _PhotoCarouselWidgetState extends State<PhotoCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenImage() {
    if (widget.photos.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                '${_currentPage + 1} из ${widget.photos.length}',
                style: const TextStyle(color: Colors.white),
              ),
              centerTitle: true,
            ),
            body: PageView.builder(
              controller: PageController(initialPage: _currentPage),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Можно добавить дополнительную функциональность при нажатии
                  },
                  child: Center(
                    child: AppImage(
                      widget.photos[index],
                      backgroundColor: Colors.black,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.bgText200,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Text(
          'Фотографии места еще нет,\nно скоро появится',
          style: TextStyle(color: AppColor.bgText500),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (widget.photos.length == 1) {
      return GestureDetector(
        onTap: _showFullScreenImage,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: AppImage(
            widget.photos.first,
            backgroundColor: AppColor.bgText00,
            height: widget.height,
          ),
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _showFullScreenImage,
          child: SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: AppImage(
                      widget.photos[index],
                      backgroundColor: AppColor.bgText00,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? AppColor.bgText900 : AppColor.bgText400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
