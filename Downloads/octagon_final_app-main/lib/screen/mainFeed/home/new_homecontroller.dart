import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';

class NewHomecontroller extends GetxController {
  static const _pageSize = 10;

  // Remove late initialization
  PagingController<int, PostResponseModelData>? pagingController;

  final PostRepository _postRepository = PostRepository();

  // Remove onInit
  var _lastApiCallTime = DateTime(0);
  var _isLoading = false;
  var _hasLoadedFirstPage = false;

  @override
  void onInit() {
    super.onInit();
    _initializePagingController();
  }

  void _initializePagingController() {
    pagingController = PagingController<int, PostResponseModelData>(firstPageKey: 1);
    pagingController!.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  Future<void> fetchPage(int pageKey) async {
    if (_isLoading || DateTime.now().difference(_lastApiCallTime).inSeconds < 15) {
      return;
    }

    // For first page, only load once unless forced
    if (pageKey == 1 && _hasLoadedFirstPage) {
      return;
    }

    _isLoading = true;
    try {
      final Resource<PostResponseModel> res = await _postRepository.getPosts(pageNo: pageKey);
      final postResponse = res.data;
      final newItems = postResponse?.success ?? [];
      final hasMore = postResponse?.more ?? false;

      if (hasMore) {
        pagingController?.appendPage(newItems, pageKey + 1);
      } else {
        pagingController?.appendLastPage(newItems);
      }
    } catch (error) {
      pagingController?.error = error;
    } finally {
      _isLoading = false;
    }
  }

  // Add refresh method to reload all posts
  Future<void> refreshPosts() async {
    // Reset cooldown and flags for refresh
    _lastApiCallTime = DateTime(0);
    _hasLoadedFirstPage = false;

    if (pagingController != null) {
      pagingController!.refresh();
    }
  }

  @override
  void onClose() {
    pagingController?.dispose();
    super.onClose();
  }
}
