
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/modules/administrator/home_admin_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../../core/context/tb_context.dart';
import '../../core/context/tb_context_widget.dart';

class TbMainNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;
  final String path;

  TbMainNavigationItem({
    required this.page,
    required this.title,
    required this.icon,
    required this.path
  });

  static Map<Authority, Set<String>> mainPageStateMap = {
    Authority.TENANT_ADMIN: Set.unmodifiable(['/home_admin']),
    //Authority.CUSTOMER_USER: Set.unmodifiable(['/home_farmer']),
  };

  static bool isMainPageState(TbContext tbContext, String path) {
    if (tbContext.isAuthenticated) {
      return mainPageStateMap[tbContext.tbClient.getAuthUser()!.authority]!
          .contains(path);
    } else {
      return false;
    }
  }

  static List<TbMainNavigationItem> getItems(TbContext tbContext) {
    if (tbContext.isAuthenticated) {
      List<TbMainNavigationItem> items = [
        TbMainNavigationItem(
            page: HomeAdminView(tbContext),
            title: 'Home',
            icon: Icon(Icons.home),
            path: '/home_admin'
        )
      ];
      switch(tbContext.tbClient.getAuthUser()!.authority) {
        case Authority.SYS_ADMIN:
          break;
        case Authority.TENANT_ADMIN:
        case Authority.CUSTOMER_USER:
          items.addAll([
          ]);
          break;
        case Authority.REFRESH_TOKEN:
          break;
        case Authority.ANONYMOUS:
          break;
      }
      return items;
    } else {
      return [];
    }
  }
}

class MainPage extends TbPageWidget {

  final String _path;

  MainPage(TbContext tbContext, {required String path}):
        _path = path, super(tbContext);

  @override
  _MainPageState createState() => _MainPageState();

}

class _MainPageState extends TbPageState<MainPage> with TbMainState, TickerProviderStateMixin {

  late ValueNotifier<int> _currentIndexNotifier;
  late final List<TbMainNavigationItem> _tabItems;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabItems = TbMainNavigationItem.getItems(tbContext);
    int currentIndex = _indexFromPath(widget._path);
    _tabController = TabController(initialIndex: currentIndex, length: _tabItems.length, vsync: this);
    _currentIndexNotifier = ValueNotifier(currentIndex);
    _tabController.animation!.addListener(_onTabAnimation);
  }

  @override
  void dispose() {
    _tabController.animation!.removeListener(_onTabAnimation);
    super.dispose();
  }

  _onTabAnimation () {
    var value = _tabController.animation!.value;
    var targetIndex;
    if (value >= _tabController.previousIndex) {
      targetIndex = value.round();
    } else {
      targetIndex = value.floor();
    }
    _currentIndexNotifier.value = targetIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_tabController.index > 0) {
            _setIndex(0);
            return false;
          }
          return true;
        },
        child: Scaffold(
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: _tabItems.map((item) => item.page).toList(),
            ),
            bottomNavigationBar: ValueListenableBuilder<int>(
              valueListenable: _currentIndexNotifier,
              builder: (context, index, child) => BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: index,
                  onTap: (int index) => _setIndex(index) /*_currentIndex = index*/,
                  items: _tabItems.map((item) => BottomNavigationBarItem(
                      icon: item.icon,
                      label: item.title
                  )).toList()
              ),
            )
        )
    );
  }

  int _indexFromPath(String path) {
    return _tabItems.indexWhere((item) => item.path == path);
  }

  @override
  bool canNavigate(String path) {
    return _indexFromPath(path) > -1;
  }

  @override
  navigateToPath(String path) {
    int targetIndex = _indexFromPath(path);
    _setIndex(targetIndex);
  }

  @override
  bool isHomePage() {
    return _tabController.index == 0;
  }

  _setIndex(int index) {
    _tabController.index = index;
  }

}