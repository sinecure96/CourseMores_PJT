import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../course_search/course_detail.dart' as detail;
import '../course_search/search.dart';
import 'mypage.dart';

class DetailTapCourseCommentsListSection extends StatelessWidget {
  const DetailTapCourseCommentsListSection({
    super.key,
    required this.commentsList,
  });

  final List commentsList;

  @override
  Widget build(BuildContext context) {
    return commentsList.isEmpty
        ? Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 60),
                child: Column(
                  children: const [
                    Text("☺", style: TextStyle(fontSize: 70)),
                    SizedBox(height: 20),
                    Text("아직 코멘트가 없어요."),
                    SizedBox(height: 10),
                    Text("다른 사람의 코스에 댓글을 남겨보세요.")
                  ],
                )),
          )
        : SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                children: List.generate(
              commentsList.length,
              (index) {
                // ListView.builder(
                //     // padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                //     padding: EdgeInsets.all(8),
                //     itemCount: commentsList.length,
                //     itemBuilder: (context, index) {
                return Card(
                  // elevation: 6,
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(255, 211, 211, 211),
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                          offset: Offset(3, 3)),
                    ], color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  print('mypage 코스리스트 == ${myPageController.myReview}');
                                  int courseId = (myPageController.myReview[index]['courseId'] as int);

                                  await searchController.changeNowCourseId(courseId: courseId);

                                  await detailController.getCourseInfo('코스 소개');
                                  await detailController.getIsLikeCourse();
                                  await detailController.getIsInterestCourse();
                                  await detailController.getCourseDetailList();

                                  Get.to(() => detail.Detail());

                                  // Get.to(() => detail.CourseDetail(index: index));
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              commentsList[index]['courseTitle'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Text(' 코스에 작성한 리뷰  ',
                                              textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.favorite, size: 24, color: Colors.pink[300]),
                                        SizedBox(width: 5),
                                        Text('${commentsList[index]['likeCount']}', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 16),
                            SizedBox(width: 5),
                            // Text(
                            //     '${DateFormat('MM-dd').format(DateTime.parse(commentsList[index]['date']))}'),
                            Text(DateFormat('MM.dd').format(DateTime.parse(commentsList[index]['createTime'])),
                                style: TextStyle(fontSize: 12)),
                            SizedBox(width: 10),
                            Icon(Icons.people, size: 16),
                            SizedBox(width: 5),
                            Text('${commentsList[index]['people']}', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        // SizedBox(height: 10),
                        // SizedBox(height: 10),
                        if (commentsList[index]['imageList'].length > 0)
                          ImageGridView(commentImageList: commentsList[index]['imageList']),
                        SizedBox(height: 10),
                        Text('${commentsList[index]['content']}', style: TextStyle(fontSize: 12, height: 1.5)),
                        // Row(
                        //   children: [
                        //     // Text('받은 좋아요 '),
                        //     Icon(Icons.favorite_outline),
                        //     SizedBox(width: 5),
                        //     Text('${commentsList[index]['likeCount']}'),
                        //   ],
                        // ),
                        // // ],
                        // // ),
                        // SizedBox(height: 5),
                        // Row(
                        //   children: [
                        //     Icon(Icons.calendar_month, size: 16),
                        //     SizedBox(width: 5),
                        //     // Text(
                        //     //     '${DateFormat('MM-dd').format(DateTime.parse(commentsList[index]['date']))}'),
                        //     Text(DateFormat('MM-dd').format(DateTime.parse(commentsList[index]['createTime']))),
                        //     SizedBox(width: 10),
                        //     Icon(Icons.people, size: 16),
                        //     SizedBox(width: 5),
                        //     Text('${commentsList[index]['people']}'),
                        //   ],
                        // ),
                        // SizedBox(height: 10),
                        SizedBox(height: 10),
                        // Text(
                        //   '${commentsList[index]['content']}',
                        //   softWrap: true,
                        // ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ));
  }
}

class ImageGridView extends StatelessWidget {
  const ImageGridView({
    Key? key,
    required this.commentImageList,
  }) : super(key: key);

  final List<dynamic> commentImageList;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: commentImageList.length > 3 ? 3 : commentImageList.length,
      itemBuilder: (context, imageIndex) {
        if (imageIndex == 2 && commentImageList.length > 3) {
          return Stack(
            children: [
              ImageInkWell(commentImageList: commentImageList, imageIndex: imageIndex),
              Positioned(
                right: 9,
                bottom: 9,
                child: ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(2),
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Text(
                        '+${commentImageList.length - 3}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return ImageInkWell(commentImageList: commentImageList, imageIndex: imageIndex);
        }
      },
    );
  }
}

class ImageInkWell extends StatelessWidget {
  const ImageInkWell({
    super.key,
    required this.commentImageList,
    required this.imageIndex,
  });

  final List<dynamic> commentImageList;
  final imageIndex;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => CommentGallery(
              images: commentImageList,
              initialIndex: imageIndex,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Hero(
          tag: 'image${commentImageList}_$imageIndex',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              commentImageList[imageIndex],
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          ),
        ),
      ),
    );
  }
}

class CommentGallery extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const CommentGallery({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<CommentGallery> createState() => _CommentGalleryState();
}

class _CommentGalleryState extends State<CommentGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'image${widget.initialIndex}_$index',
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              );
            },
            itemCount: widget.images.length,
            pageController: PageController(initialPage: widget.initialIndex),
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Positioned(
            top: 50,
            left: 30,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.map((image) {
                int index = widget.images.indexOf(image);
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.grey.shade800 : Colors.grey.shade600,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
